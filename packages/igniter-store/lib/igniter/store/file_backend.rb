# frozen_string_literal: true

# Pure-Ruby fallback — skipped when the Rust native extension is loaded.
return if defined?(Igniter::Store::NATIVE) && Igniter::Store::NATIVE

require "json"
require "zlib"
require "set"
require "fileutils"
require_relative "wire_protocol"

module Igniter
  module Store
    # WAL format (v2): length-prefixed frames with CRC32 integrity check.
    #
    # Each frame:
    #   [4 bytes BE uint32: body_len][body_len bytes: JSON][4 bytes BE uint32: CRC32(body)]
    #
    # On replay, a frame with a bad CRC or truncated body stops replay at that
    # point — everything after is treated as an uncommitted write. Silent data
    # loss from a mid-write process kill is now detectable.
    #
    # Snapshot format (path + ".snap"):
    #   [header frame: JSON { type: "snapshot_header", fact_count: N, written_at: T }]
    #   [fact frame 1] ... [fact frame N]
    #
    # On open, if a snapshot file exists: snapshot facts are loaded first, WAL
    # facts whose IDs are already in the snapshot are skipped. Combined result
    # is sorted by timestamp. Startup cost is O(snapshot_size + delta_wal_size)
    # instead of O(total_wal_size).
    class FileBackend
      include WireProtocol

      SNAPSHOT_SUFFIX = ".snap"

      def initialize(path)
        @path = path.to_s
        @file = File.open(@path, "ab")
        @file.sync = true
      end

      def write_fact(fact)
        body  = JSON.generate(fact.to_h)
        @file.write(encode_frame(body))
      end

      # Combines snapshot (if present) + WAL delta into a chronologically
      # ordered list of facts.  Facts in the snapshot are deduplicated against
      # the WAL by ID so a checkpoint never causes double-replay.
      def replay
        snapshot_facts, seen_ids = load_snapshot
        wal_facts = read_wal_frames.reject { |f| seen_ids.include?(f.id) }
        (snapshot_facts + wal_facts).sort_by(&:timestamp)
      end

      # Atomically writes all +facts+ to a snapshot file (<wal_path>.snap).
      # Uses a tmp file + rename so a partial write never corrupts an existing
      # snapshot.  The WAL file is untouched; the snapshot is a parallel read
      # artefact only.
      def write_snapshot(facts)
        tmp = "#{snapshot_path}.tmp"
        File.open(tmp, "wb") do |f|
          header = JSON.generate({
            type:       "snapshot_header",
            fact_count: facts.size,
            written_at: Process.clock_gettime(Process::CLOCK_REALTIME)
          })
          f.write(encode_frame(header))
          facts.each { |fact| f.write(encode_frame(JSON.generate(fact.to_h))) }
        end
        FileUtils.mv(tmp, snapshot_path)
      end

      def snapshot_path
        @path + SNAPSHOT_SUFFIX
      end

      def close
        @file.close
      end

      private

      # Parses a raw JSON body into a frozen Fact.  Returns nil on parse error.
      def decode_fact(body)
        payload = JSON.parse(body, symbolize_names: true)
        payload[:store]     = payload.fetch(:store).to_sym
        payload[:timestamp] = payload.fetch(:timestamp).to_f
        Fact.new(**payload).freeze
      rescue JSON::ParserError
        nil
      end

      # --- WAL reading ---

      def read_wal_frames
        return [] unless File.exist?(@path)
        facts = []
        File.open(@path, "rb") do |f|
          loop do
            body = read_frame(f)
            break unless body
            fact = decode_fact(body)
            facts << fact if fact
          end
        end
        facts
      end

      # --- Snapshot reading ---

      # Returns [Array<Fact>, Set<id>] from the snapshot file, or [[], Set[]]
      # if no snapshot exists or the snapshot is corrupt.
      def load_snapshot
        return [[], Set.new] unless File.exist?(snapshot_path)

        facts = []
        File.open(snapshot_path, "rb") do |f|
          header_body = read_frame(f)
          return [[], Set.new] unless header_body

          header = JSON.parse(header_body, symbolize_names: true)
          return [[], Set.new] unless header[:type] == "snapshot_header"

          loop do
            body = read_frame(f)
            break unless body
            fact = decode_fact(body)
            facts << fact if fact
          end
        end

        [facts, Set.new(facts.map(&:id))]
      rescue StandardError
        [[], Set.new]
      end
    end
  end
end
