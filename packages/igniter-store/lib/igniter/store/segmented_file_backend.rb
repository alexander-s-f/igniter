# frozen_string_literal: true

require "json"
require "fileutils"
require_relative "wire_protocol"
require_relative "codecs"

module Igniter
  module Store
    # Partitioned, manifest-tracked WAL backend with pluggable per-store codecs.
    #
    # A single instance replaces FileBackend for a whole IgniterStore — facts
    # from every store are written into per-store, per-time-bucket segment
    # files under a shared root directory.
    #
    # Layout:
    #   {root_dir}/
    #     wal/
    #       store={name}/
    #         date={bucket}/
    #           segment-000001.wal
    #           segment-000001.wal.manifest.json   ← written atomically on seal
    #           segment-000002.wal
    #
    # Codec selection:
    #
    #   # All stores use the default codec (json_crc32):
    #   SegmentedFileBackend.new(root)
    #
    #   # All stores use compact_delta:
    #   SegmentedFileBackend.new(root, codec: :compact_delta)
    #
    #   # Per-store codec map (string or symbol keys):
    #   SegmentedFileBackend.new(root,
    #     codec: { technician_locations: :compact_delta,
    #              vendor_leads:         :compact_delta,
    #              crm_records:          :json_crc32 })
    #
    # compact_delta is recommended for high-frequency History stores (sensor
    # readings, GPS tracks) and gives ~16x size reduction over json_crc32.
    # It is NOT resumable after a crash — any live compact_delta segment is
    # sealed on the next startup and a fresh segment is opened.
    #
    # Public interface is identical to FileBackend: write_fact, replay, close.
    class SegmentedFileBackend
      include WireProtocol

      MANIFEST_SUFFIX   = ".manifest.json"
      PURGED_SUFFIX     = ".purged.json"
      DEFAULT_MAX_BYTES = 64 * 1024 * 1024  # 64 MB
      DEFAULT_CODEC     = :json_crc32

      attr_reader :root_dir

      # +root_dir+    — root data directory shared by all stores.
      # +max_bytes+   — rotate segment when file reaches this size (default 64 MB).
      # +time_bucket+ — :day (default), :hour, or :none.
      # +codec+       — Symbol or Hash{store_name => Symbol}.  See class docs.
      # +retention+ — Hash{ store_name => { strategy:, duration: } }
      #   Strategies:
      #     :permanent      — never purge (default when no policy set)
      #     :rolling_window — purge sealed segments where max_timestamp < now - duration (Float seconds)
      #     :ephemeral      — keep only the single newest sealed segment per store
      def initialize(root_dir, max_bytes: DEFAULT_MAX_BYTES, time_bucket: :day,
                     codec: DEFAULT_CODEC, retention: {})
        @root_dir           = root_dir.to_s
        @max_bytes          = max_bytes
        @time_bucket        = time_bucket
        @codec_spec         = codec      # Symbol or Hash
        @segments           = {}         # store_name (String) → segment state Hash
        @retention_policies = {}
        @mutex              = Mutex.new

        FileUtils.mkdir_p(File.join(@root_dir, "wal"))
        retention.each { |store, policy| set_retention(store, **policy) }
      end

      def write_fact(fact)
        store = fact.store.to_s
        @mutex.synchronize do
          seg = active_segment_for(store)
          seg[:codec].encode_fact(seg[:file], fact)
          seg[:count] += 1
          ts = fact.timestamp.to_f
          seg[:min_ts] = seg[:min_ts] ? [seg[:min_ts], ts].min : ts
          seg[:max_ts] = seg[:max_ts] ? [seg[:max_ts], ts].max : ts
        end
      end

      # Returns all facts from matching segments sorted by timestamp.
      # +store+  — restrict to one store name (Symbol or String); nil = all stores.
      # +since+  — skip sealed segments with max_timestamp < since (Float unix sec).
      # +as_of+  — skip sealed segments with min_timestamp > as_of (Float unix sec).
      def replay(store: nil, since: nil, as_of: nil)
        segment_paths_for(store: store ? store.to_s : nil, since: since, as_of: as_of)
          .flat_map { |path| read_segment(path) }
          .sort_by(&:timestamp)
      end

      # Seal every open segment and open a fresh one per store.
      def checkpoint!
        @mutex.synchronize do
          old = @segments.dup
          @segments.clear
          old.each do |store, seg|
            seal_segment!(seg)
            @segments[store] = open_new_segment(store)
          end
        end
      end

      def close
        @mutex.synchronize do
          @segments.values.each { |seg| seal_segment!(seg) }
          @segments.clear
        end
      end

      def segment_count
        all_segment_paths.size
      end

      def stored_store_names
        Dir[File.join(@root_dir, "wal", "store=*")]
          .select { |d| File.directory?(d) }
          .map    { |d| File.basename(d).sub("store=", "") }
      end

      # Register (or replace) the retention policy for a store.
      def set_retention(store, strategy:, duration: nil)
        @mutex.synchronize do
          @retention_policies[store.to_s] = { strategy: strategy.to_sym, duration: duration }
        end
      end

      # Delete eligible sealed segments for stores that have a policy.
      # Returns an Array of receipt hashes (one per deleted segment).
      # Live (unsealed) segments are never touched.
      # +store+ — restrict purge to one store; nil = all stores with a policy.
      def purge!(store: nil)
        @mutex.synchronize do
          targets = store ? [store.to_s] : @retention_policies.keys
          targets.flat_map { |s| purge_store!(s) }
        end
      end

      # List purge receipts written by previous purge! calls.
      # +store+ — restrict to one store; nil = all stores.
      def purge_receipts(store: nil)
        glob = store ? "store=#{store}" : "store=*"
        Dir[File.join(@root_dir, "wal", glob, "**", "*#{PURGED_SUFFIX}")]
          .map { |p| JSON.parse(File.read(p)) rescue nil }
          .compact
      end

      private

      # ── Retention ────────────────────────────────────────────────────────

      def purge_store!(store)
        policy = @retention_policies[store]
        return [] unless policy

        now    = Process.clock_gettime(Process::CLOCK_REALTIME)
        live   = @segments[store]&.dig(:path)
        sealed = sealed_segment_paths(store)

        to_delete = select_for_purge(sealed, policy, now)
        to_delete.reject! { |p| p == live }

        to_delete.map { |p| delete_segment_with_receipt!(p, policy, now) }.compact
      end

      def sealed_segment_paths(store)
        Dir[File.join(@root_dir, "wal", "store=#{store}", "**", "segment-*.wal")]
          .reject { |p| p.end_with?(MANIFEST_SUFFIX) || p.end_with?(PURGED_SUFFIX) }
          .select { |p| File.exist?(p + MANIFEST_SUFFIX) }
          .sort
      end

      def select_for_purge(paths, policy, now)
        case policy[:strategy]
        when :permanent
          []
        when :rolling_window
          duration = policy[:duration].to_f
          paths.select { |p|
            m      = JSON.parse(File.read(p + MANIFEST_SUFFIX)) rescue nil
            next false unless m
            max_ts = m["max_timestamp"]
            max_ts && max_ts < (now - duration)
          }
        when :ephemeral
          paths.empty? ? [] : paths[0..-2]
        else
          []
        end
      end

      def delete_segment_with_receipt!(path, policy, now)
        mpath = path + MANIFEST_SUFFIX
        manifest = File.exist?(mpath) ? (JSON.parse(File.read(mpath)) rescue {}) : {}

        receipt = manifest.merge(
          "purged_at"        => now,
          "purge_strategy"   => policy[:strategy].to_s,
          "purge_duration"   => policy[:duration],
          "segment_path"     => path
        )

        receipt_path = path + PURGED_SUFFIX
        File.write(receipt_path, JSON.generate(receipt))

        FileUtils.rm_f(path)
        FileUtils.rm_f(mpath)
        receipt
      end

      # ── Codec resolution ─────────────────────────────────────────────────

      def codec_name_for(store)
        case @codec_spec
        when Symbol, String then @codec_spec.to_sym
        when Hash
          (@codec_spec[store.to_sym] || @codec_spec[store.to_s] || DEFAULT_CODEC).to_sym
        else DEFAULT_CODEC
        end
      end

      # ── Segment lifecycle ─────────────────────────────────────────────────

      def active_segment_for(store)
        @segments[store] ||= open_or_resume_segment(store)
        rotate_if_needed!(store)
        @segments[store]
      end

      def rotate_if_needed!(store)
        seg      = @segments[store]
        on_disk  = File.size?(seg[:path]) || 0
        if current_bucket != seg[:bucket] || on_disk >= @max_bytes
          seal_segment!(seg)
          @segments[store] = open_new_segment(store)
        end
      end

      # Resume a live (unsealed) json_crc32 segment if one exists in the
      # current bucket.  compact_delta segments are NOT resumable — any live
      # segment is sealed and a fresh one is started.
      def open_or_resume_segment(store)
        bucket = current_bucket
        dir    = store_bucket_dir(store, bucket)
        FileUtils.mkdir_p(dir)

        live = Dir[File.join(dir, "segment-*.wal")]
                 .reject { |p| p.end_with?(MANIFEST_SUFFIX) }
                 .reject { |p| File.exist?(p + MANIFEST_SUFFIX) }
                 .max_by { |p| segment_number_from_path(p) }

        cname = codec_name_for(store)

        if live && cname == :json_crc32
          resume_segment(live, store, bucket, cname)
        else
          seal_orphaned_live!(live) if live
          open_new_segment_in(store, bucket, cname)
        end
      end

      def resume_segment(path, store, bucket, codec_name)
        file = File.open(path, "ab")
        file.sync = true
        codec = Codecs.build(codec_name)
        { path: path, file: file, store: store, bucket: bucket,
          number: segment_number_from_path(path), codec_name: codec_name,
          codec: codec, count: count_frames(path), min_ts: nil, max_ts: nil }
      end

      def open_new_segment(store)
        open_new_segment_in(store, current_bucket, codec_name_for(store))
      end

      def open_new_segment_in(store, bucket, codec_name)
        dir      = store_bucket_dir(store, bucket)
        FileUtils.mkdir_p(dir)
        next_num = (segment_numbers_in(dir).max || 0) + 1
        path     = segment_path_for(store, bucket, next_num)
        file     = File.open(path, "ab")
        file.sync = true
        codec    = Codecs.build(codec_name)
        codec.start_segment(file, store: store)
        { path: path, file: file, store: store, bucket: bucket,
          number: next_num, codec_name: codec_name,
          codec: codec, count: 0, min_ts: nil, max_ts: nil }
      end

      # Seal a live segment that belongs to a previous session or a codec
      # that cannot be resumed (compact_delta).  No manifest metadata is
      # available so we only write a minimal one.
      def seal_orphaned_live!(path)
        file = File.open(path, "ab")
        file.flush
        file.close
        write_manifest(path, codec: "json_crc32", fact_count: count_frames(path),
                       byte_size: File.size(path), min_ts: nil, max_ts: nil,
                       store: path.split("store=").last.split("/").first,
                       bucket: path.split("date=").last.split("/").first,
                       number: segment_number_from_path(path))
      end

      def seal_segment!(seg)
        return unless seg
        seg[:codec].flush(seg[:file])
        seg[:file].flush
        seg[:file].close
        if seg[:count] == 0
          FileUtils.rm_f(seg[:path])
          return
        end
        write_manifest(seg[:path],
                       codec:      seg[:codec].name,
                       fact_count: seg[:count],
                       byte_size:  File.size(seg[:path]),
                       min_ts:     seg[:min_ts],
                       max_ts:     seg[:max_ts],
                       store:      seg[:store],
                       bucket:     seg[:bucket],
                       number:     seg[:number])
      end

      def write_manifest(path, codec:, fact_count:, byte_size:, min_ts:, max_ts:,
                         store:, bucket:, number:)
        manifest = {
          segment_id:    segment_id(store, bucket, number),
          store:         store,
          codec:         codec,
          fact_count:    fact_count,
          byte_size:     byte_size,
          min_timestamp: min_ts,
          max_timestamp: max_ts,
          sealed:        true,
          sealed_at:     Process.clock_gettime(Process::CLOCK_REALTIME)
        }
        tmp = path + MANIFEST_SUFFIX + ".tmp"
        File.write(tmp, JSON.generate(manifest))
        FileUtils.mv(tmp, path + MANIFEST_SUFFIX)
      end

      # ── Replay ────────────────────────────────────────────────────────────

      def segment_paths_for(store:, since:, as_of:)
        glob = store ? "store=#{store}" : "store=*"
        all  = Dir[File.join(@root_dir, "wal", glob, "date=*", "segment-*.wal")]
                 .reject { |p| p.end_with?(MANIFEST_SUFFIX) }
                 .sort
        return all unless since || as_of

        all.select { |path|
          mpath = path + MANIFEST_SUFFIX
          next true unless File.exist?(mpath)

          m      = JSON.parse(File.read(mpath))
          max_ts = m["max_timestamp"]
          min_ts = m["min_timestamp"]
          next false if since && max_ts && max_ts < since
          next false if as_of  && min_ts && min_ts > as_of
          true
        }
      end

      def read_segment(path)
        codec_name = manifest_codec_for(path)
        codec = Codecs.build(codec_name)
        File.open(path, "rb") { |io| codec.decode(io) }
      rescue StandardError
        []
      end

      def manifest_codec_for(path)
        mpath = path + MANIFEST_SUFFIX
        return DEFAULT_CODEC unless File.exist?(mpath)
        (JSON.parse(File.read(mpath))["codec"] || DEFAULT_CODEC.to_s).to_sym
      rescue StandardError
        DEFAULT_CODEC
      end

      # ── Path helpers ──────────────────────────────────────────────────────

      def store_bucket_dir(store, bucket)
        File.join(@root_dir, "wal", "store=#{store}", "date=#{bucket}")
      end

      def segment_path_for(store, bucket, number)
        File.join(store_bucket_dir(store, bucket), "segment-#{number.to_s.rjust(6, "0")}.wal")
      end

      def segment_id(store, bucket, number)
        "#{store}/#{bucket}/#{number.to_s.rjust(6, "0")}"
      end

      def segment_number_from_path(path)
        File.basename(path, ".wal").split("-").last.to_i
      end

      def all_segment_paths
        Dir[File.join(@root_dir, "wal", "store=*", "date=*", "segment-*.wal")]
          .reject { |p| p.end_with?(MANIFEST_SUFFIX) }
      end

      def segment_numbers_in(dir)
        Dir[File.join(dir, "segment-*.wal")]
          .reject { |p| p.end_with?(MANIFEST_SUFFIX) }
          .map    { |p| segment_number_from_path(p) }
      end

      def current_bucket
        case @time_bucket
        when :hour then Time.now.utc.strftime("%Y-%m-%dT%H")
        when :none then "flat"
        else            Time.now.utc.strftime("%Y-%m-%d")
        end
      end

      def count_frames(path)
        return 0 unless File.exist?(path)
        n = 0
        File.open(path, "rb") { |f| n += 1 while read_frame(f) }
        n
      rescue StandardError
        0
      end
    end
  end
end
