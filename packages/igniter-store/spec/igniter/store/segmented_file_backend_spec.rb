# frozen_string_literal: true

require_relative "../../spec_helper"
require "tmpdir"
require "fileutils"

RSpec.describe Igniter::Store::SegmentedFileBackend do
  let(:root)    { Dir.mktmpdir("igniter-seg-spec-") }
  let(:backend) { described_class.new(root) }

  after do
    backend.close rescue nil
    FileUtils.rm_rf(root)
  end

  def make_fact(key: "k1", value: { x: 1 }, store: :readings)
    Igniter::Store::Fact.build(store: store, key: key, value: value)
  end

  def manifests_for(store_name = "readings")
    Dir[File.join(root, "wal", "store=#{store_name}", "**", "*#{described_class::MANIFEST_SUFFIX}")]
  end

  def segment_files_for(store_name = "readings")
    Dir[File.join(root, "wal", "store=#{store_name}", "**", "segment-*.wal")]
      .reject { |p| p.end_with?(described_class::MANIFEST_SUFFIX) }
  end

  # ── Write + Replay ──────────────────────────────────────────────────────────

  describe "write_fact + replay" do
    it "replays written facts sorted by timestamp" do
      3.times { |i| backend.write_fact(make_fact(key: "k#{i}", value: { n: i })) }
      backend.close

      b2      = described_class.new(root)
      facts   = b2.replay
      b2.close

      expect(facts.size).to eq(3)
      expect(facts.map(&:key)).to match_array(%w[k0 k1 k2])
      expect(facts).to eq(facts.sort_by(&:timestamp))
    end

    it "persists facts across independent backend instances" do
      backend.write_fact(make_fact(key: "durable"))
      backend.close

      b2    = described_class.new(root)
      facts = b2.replay
      b2.close

      expect(facts.first.key).to eq("durable")
    end

    it "keeps stores isolated — different store names do not cross-contaminate" do
      backend.write_fact(make_fact(store: :readings))
      backend.write_fact(make_fact(store: :signals))
      backend.close

      b2 = described_class.new(root)
      expect(b2.replay(store: :readings).map(&:store)).to all(eq(:readings))
      expect(b2.replay(store: :signals).map(&:store)).to all(eq(:signals))
      b2.close
    end

    it "replay without store: filter returns facts from all stores" do
      backend.write_fact(make_fact(store: :readings))
      backend.write_fact(make_fact(store: :signals))
      backend.close

      b2    = described_class.new(root)
      facts = b2.replay
      b2.close

      expect(facts.map(&:store).uniq).to match_array(%i[readings signals])
    end
  end

  # ── Directory structure ─────────────────────────────────────────────────────

  describe "segment directory layout" do
    it "creates store= and date= partitioned directories" do
      backend.write_fact(make_fact)
      backend.close

      today = Time.now.utc.strftime("%Y-%m-%d")
      expect(Dir.exist?(File.join(root, "wal", "store=readings", "date=#{today}"))).to be true
    end

    it "names segments with zero-padded numbers" do
      backend.write_fact(make_fact)
      backend.close

      seg_names = segment_files_for.map { |p| File.basename(p) }
      expect(seg_names).to include("segment-000001.wal")
    end

    it "reported store names match directories on disk" do
      backend.write_fact(make_fact(store: :readings))
      backend.write_fact(make_fact(store: :signals))
      backend.close

      b2 = described_class.new(root)
      expect(b2.stored_store_names).to match_array(%w[readings signals])
      b2.close
    end
  end

  # ── Manifest ────────────────────────────────────────────────────────────────

  describe "manifest on seal" do
    it "writes a manifest sidecar when closed" do
      backend.write_fact(make_fact)
      backend.close

      expect(manifests_for.size).to eq(1)
    end

    it "manifest is valid JSON with required fields" do
      backend.write_fact(make_fact)
      backend.close

      m = JSON.parse(File.read(manifests_for.first))
      expect(m["store"]).to        eq("readings")
      expect(m["fact_count"]).to   eq(1)
      expect(m["byte_size"]).to    be > 0
      expect(m["min_timestamp"]).not_to be_nil
      expect(m["max_timestamp"]).not_to be_nil
      expect(m["sealed"]).to       be true
      expect(m["codec"]).to        eq("json_crc32")
      expect(m["segment_id"]).to   match(%r{readings/.+/000001})
    end

    it "manifest write is atomic — a crash during tmp write leaves no partial manifest" do
      backend.write_fact(make_fact)
      # Simulate crash between write and mv: leave a .tmp file behind
      seg_path = segment_files_for.first
      tmp_path = seg_path + described_class::MANIFEST_SUFFIX + ".tmp"
      File.write(tmp_path, "CORRUPT")
      backend.close

      # close overwrites the tmp correctly — real manifest exists
      m = JSON.parse(File.read(manifests_for.first))
      expect(m["sealed"]).to be true
    end
  end

  # ── Segment rotation ────────────────────────────────────────────────────────

  describe "segment rotation by size" do
    let(:tiny) { described_class.new(root, max_bytes: 1024) }
    after { tiny.close rescue nil }

    it "rotates into a new segment when max_bytes is exceeded" do
      20.times { |i| tiny.write_fact(make_fact(key: "k#{i}")) }
      expect(tiny.segment_count).to be > 1
    end

    it "seals rotated segments with a manifest" do
      20.times { |i| tiny.write_fact(make_fact(key: "k#{i}")) }
      expect(manifests_for.size).to be >= 1
    end

    it "all facts survive across multiple segments" do
      20.times { |i| tiny.write_fact(make_fact(key: "k#{i}")) }
      tiny.close

      b2    = described_class.new(root)
      facts = b2.replay
      b2.close

      expect(facts.size).to eq(20)
      expect(facts.map(&:key)).to match_array((0..19).map { |i| "k#{i}" })
    end
  end

  # ── checkpoint! ─────────────────────────────────────────────────────────────

  describe "#checkpoint!" do
    it "seals the current segment and opens a fresh one" do
      backend.write_fact(make_fact(key: "before"))
      backend.checkpoint!
      backend.write_fact(make_fact(key: "after"))

      expect(backend.segment_count).to eq(2)
    end

    it "sealed segment has a manifest; new live segment does not" do
      backend.write_fact(make_fact)
      backend.checkpoint!

      expect(manifests_for.size).to eq(1)
      live = segment_files_for.reject { |p| File.exist?(p + described_class::MANIFEST_SUFFIX) }
      expect(live.size).to eq(1)
    end

    it "all facts are replayed after several checkpoints" do
      3.times do |i|
        backend.write_fact(make_fact(key: "k#{i}"))
        backend.checkpoint! if i < 2
      end
      backend.close

      b2    = described_class.new(root)
      facts = b2.replay
      b2.close

      expect(facts.size).to eq(3)
    end
  end

  # ── Resume after unclean shutdown ───────────────────────────────────────────

  describe "resuming an unsealed segment" do
    it "resumes writing to the live segment after a crash (no seal)" do
      backend.write_fact(make_fact(key: "pre_crash"))
      # Simulate crash: close the raw file handle without sealing
      backend.instance_variable_get(:@segments)["readings"][:file].close

      b2 = described_class.new(root)
      b2.write_fact(make_fact(key: "post_crash"))
      b2.close

      b3    = described_class.new(root)
      facts = b3.replay
      b3.close

      expect(facts.map(&:key)).to include("pre_crash", "post_crash")
    end

    it "does not create a second segment when resuming into the same bucket" do
      backend.write_fact(make_fact)
      backend.instance_variable_get(:@segments)["readings"][:file].close

      b2 = described_class.new(root)
      b2.close

      expect(b2.segment_count).to eq(1)
    end
  end

  # ── Time range filtering ────────────────────────────────────────────────────

  describe "replay with since: / as_of: filters" do
    it "returns all facts when no filter given" do
      3.times { |i| backend.write_fact(make_fact(key: "k#{i}")) }
      backend.close

      b2    = described_class.new(root)
      facts = b2.replay
      b2.close

      expect(facts.size).to eq(3)
    end

    it "skips sealed segments whose max_timestamp is before since:" do
      backend.write_fact(make_fact(key: "early"))
      t_mid = Process.clock_gettime(Process::CLOCK_REALTIME)
      backend.checkpoint!
      sleep(0.02)   # ensure segment 2 timestamps are strictly after t_mid
      backend.write_fact(make_fact(key: "late"))
      backend.close

      b2     = described_class.new(root)
      facts  = b2.replay(since: t_mid + 0.01)
      b2.close

      expect(facts.map(&:key)).to     include("late")
      expect(facts.map(&:key)).not_to include("early")
    end

    it "always includes the live (unsealed) segment regardless of filters" do
      backend.write_fact(make_fact(key: "live"))
      far_future = Process.clock_gettime(Process::CLOCK_REALTIME) + 9_999

      facts = backend.replay(since: far_future)
      # live segment has no manifest so it is never skipped
      expect(facts.map(&:key)).to include("live")
    end
  end

  # ── Codec dispatch ──────────────────────────────────────────────────────────

  describe "codec selection" do
    context "with codec: :compact_delta (single codec for all stores)" do
      let(:cd_backend) { described_class.new(root, codec: :compact_delta) }
      after { cd_backend.close rescue nil }

      it "writes and replays facts correctly" do
        5.times { |i| cd_backend.write_fact(make_fact(key: "k#{i}", value: { reading: i * 1.5, sensor: "s1" })) }
        cd_backend.close

        b2    = described_class.new(root, codec: :compact_delta)
        facts = b2.replay
        b2.close

        expect(facts.size).to eq(5)
        expect(facts.map(&:key)).to match_array((0..4).map { |i| "k#{i}" })
      end

      it "preserves value fields" do
        cd_backend.write_fact(make_fact(key: "sensor_1", value: { reading: 42.0, unit: "celsius" }))
        cd_backend.close

        b2    = described_class.new(root, codec: :compact_delta)
        fact  = b2.replay.first
        b2.close

        expect(fact.value[:reading]).to eq(42.0)
        expect(fact.value[:unit]).to    eq("celsius")
      end

      it "records codec name in manifest" do
        cd_backend.write_fact(make_fact)
        cd_backend.close

        m = JSON.parse(File.read(manifests_for("readings").first))
        expect(m["codec"]).to eq("compact_delta_zlib")
      end

      it "produces smaller segments than json_crc32 for homogeneous data" do
        value = { lat: 34.052, lng: -118.243, accuracy_m: 10.0, battery_pct: 85 }
        200.times { |i| cd_backend.write_fact(make_fact(key: "tech_#{i % 10}", value: value)) }
        cd_backend.close

        json_backend = described_class.new(File.join(root, "json_ref"))
        200.times { |i| json_backend.write_fact(make_fact(key: "tech_#{i % 10}", value: value)) }
        json_backend.close

        compact_bytes = segment_files_for("readings").sum { |p| File.size(p) }
        json_bytes    = Dir[File.join(root, "json_ref/wal/store=readings/**/*.wal")]
                          .reject { |p| p.end_with?(".manifest.json") }
                          .sum { |p| File.size(p) }

        expect(compact_bytes).to be < json_bytes / 3
      end

      it "facts survive multiple segments (rotation)" do
        tiny = described_class.new(root, codec: :compact_delta, max_bytes: 512)
        50.times { |i| tiny.write_fact(make_fact(key: "k#{i}", value: { v: i.to_f })) }
        tiny.close

        b2    = described_class.new(root, codec: :compact_delta)
        facts = b2.replay
        b2.close

        expect(facts.size).to eq(50)
      end
    end

    context "with per-store codec map" do
      let(:mixed_backend) {
        described_class.new(root, codec: {
          technician_locations: :compact_delta,
          crm_records:          :json_crc32
        })
      }
      after { mixed_backend.close rescue nil }

      it "writes gps facts with compact_delta and crm facts with json_crc32" do
        mixed_backend.write_fact(make_fact(store: :technician_locations,
                                           key: "tech_1",
                                           value: { lat: 34.0, lng: -118.0, accuracy_m: 5.0 }))
        mixed_backend.write_fact(make_fact(store: :crm_records,
                                           key: "job_1",
                                           value: { status: "scheduled", zip: "90210" }))
        mixed_backend.close

        gps_manifest = Dir[File.join(root, "wal/store=technician_locations/**/*.manifest.json")].first
        crm_manifest = Dir[File.join(root, "wal/store=crm_records/**/*.manifest.json")].first

        expect(JSON.parse(File.read(gps_manifest))["codec"]).to eq("compact_delta_zlib")
        expect(JSON.parse(File.read(crm_manifest))["codec"]).to  eq("json_crc32")
      end

      it "replays facts from both stores correctly" do
        mixed_backend.write_fact(make_fact(store: :technician_locations,
                                           key: "tech_1",
                                           value: { lat: 34.0, lng: -118.0, accuracy_m: 5.0 }))
        mixed_backend.write_fact(make_fact(store: :crm_records,
                                           key: "job_1",
                                           value: { status: "scheduled", zip: "90210" }))
        mixed_backend.close

        b2    = described_class.new(root, codec: {
          technician_locations: :compact_delta, crm_records: :json_crc32
        })
        facts = b2.replay
        b2.close

        stores = facts.map(&:store)
        expect(stores).to include(:technician_locations, :crm_records)
      end
    end
  end

  # ── Retention policies ──────────────────────────────────────────────────────

  describe "retention policies" do
    def purged_receipts_for(store_name = "readings")
      Dir[File.join(root, "wal", "store=#{store_name}", "**", "*#{described_class::PURGED_SUFFIX}")]
    end

    context ":rolling_window strategy" do
      it "purges sealed segments older than duration" do
        b = described_class.new(root,
              retention: { readings: { strategy: :rolling_window, duration: 60 } })
        b.write_fact(make_fact(key: "old"))
        b.checkpoint!
        b.write_fact(make_fact(key: "new"))
        b.close

        old_seg = manifests_for.min
        m = JSON.parse(File.read(old_seg))
        old_ts = Process.clock_gettime(Process::CLOCK_REALTIME) - 120
        m["max_timestamp"] = old_ts
        m["min_timestamp"] = old_ts
        File.write(old_seg, JSON.generate(m))

        b2 = described_class.new(root,
               retention: { readings: { strategy: :rolling_window, duration: 60 } })
        receipts = b2.purge!
        b2.close

        expect(receipts.size).to eq(1)
        expect(receipts.first["purge_strategy"]).to eq("rolling_window")
      end

      it "does not purge segments within the window" do
        b = described_class.new(root,
              retention: { readings: { strategy: :rolling_window, duration: 3600 } })
        b.write_fact(make_fact(key: "recent"))
        b.checkpoint!
        b.write_fact(make_fact(key: "newest"))
        b.close

        b2 = described_class.new(root,
               retention: { readings: { strategy: :rolling_window, duration: 3600 } })
        receipts = b2.purge!
        b2.close

        expect(receipts).to be_empty
      end

      it "never touches the live (unsealed) segment" do
        b = described_class.new(root,
              retention: { readings: { strategy: :rolling_window, duration: 0 } })
        b.write_fact(make_fact(key: "live"))

        receipts = b.purge!
        b.close

        expect(receipts).to be_empty
        expect(segment_files_for.size).to eq(1)
      end
    end

    context ":ephemeral strategy" do
      it "keeps only the newest sealed segment" do
        b = described_class.new(root,
              retention: { readings: { strategy: :ephemeral } })
        3.times { |i|
          b.write_fact(make_fact(key: "k#{i}"))
          b.checkpoint!
        }
        b.close

        b2 = described_class.new(root,
               retention: { readings: { strategy: :ephemeral } })
        receipts = b2.purge!
        b2.close

        expect(receipts.size).to eq(2)
        remaining = segment_files_for.select { |p|
          File.exist?(p + described_class::MANIFEST_SUFFIX)
        }
        expect(remaining.size).to eq(1)
      end

      it "returns empty receipts when only one sealed segment exists" do
        b = described_class.new(root,
              retention: { readings: { strategy: :ephemeral } })
        b.write_fact(make_fact(key: "only"))
        b.close

        b2 = described_class.new(root,
               retention: { readings: { strategy: :ephemeral } })
        receipts = b2.purge!
        b2.close

        expect(receipts).to be_empty
      end
    end

    context ":permanent strategy" do
      it "never purges any segment" do
        b = described_class.new(root,
              retention: { readings: { strategy: :permanent } })
        3.times { |i|
          b.write_fact(make_fact(key: "k#{i}"))
          b.checkpoint!
        }
        b.close

        b2 = described_class.new(root,
               retention: { readings: { strategy: :permanent } })
        receipts = b2.purge!
        b2.close

        expect(receipts).to be_empty
      end
    end

    context "receipt audit trail" do
      it "writes a .purged.json receipt before deleting" do
        b = described_class.new(root,
              retention: { readings: { strategy: :ephemeral } })
        2.times { |i|
          b.write_fact(make_fact(key: "k#{i}"))
          b.checkpoint!
        }
        b.close

        b2 = described_class.new(root,
               retention: { readings: { strategy: :ephemeral } })
        b2.purge!
        b2.close

        expect(purged_receipts_for.size).to eq(1)
        receipt = JSON.parse(File.read(purged_receipts_for.first))
        expect(receipt["purge_strategy"]).to eq("ephemeral")
        expect(receipt["purged_at"]).to      be_a(Float)
        expect(receipt["segment_path"]).to   be_a(String)
      end

      it "purge_receipts returns all written receipts" do
        b = described_class.new(root,
              retention: { readings: { strategy: :ephemeral } })
        3.times { |i|
          b.write_fact(make_fact(key: "k#{i}"))
          b.checkpoint!
        }
        b.close

        b2 = described_class.new(root,
               retention: { readings: { strategy: :ephemeral } })
        b2.purge!
        b2.close

        b3 = described_class.new(root)
        receipts = b3.purge_receipts(store: :readings)
        b3.close

        expect(receipts.size).to eq(2)
        expect(receipts).to all(include("purge_strategy" => "ephemeral"))
      end
    end

    context "set_retention at runtime" do
      it "applies a policy set after construction" do
        b = described_class.new(root)
        3.times { |i|
          b.write_fact(make_fact(key: "k#{i}"))
          b.checkpoint!
        }
        b.close

        b2 = described_class.new(root)
        b2.set_retention(:readings, strategy: :ephemeral)
        receipts = b2.purge!
        b2.close

        expect(receipts.size).to eq(2)
      end
    end

    context "purge scope" do
      it "purge!(store:) only affects the named store" do
        b = described_class.new(root,
              retention: {
                readings: { strategy: :ephemeral },
                signals:  { strategy: :ephemeral }
              })
        2.times {
          b.write_fact(make_fact(store: :readings, key: "r"))
          b.write_fact(make_fact(store: :signals,  key: "s"))
          b.checkpoint!
        }
        b.close

        b2 = described_class.new(root,
               retention: {
                 readings: { strategy: :ephemeral },
                 signals:  { strategy: :ephemeral }
               })
        receipts = b2.purge!(store: :readings)
        b2.close

        expect(receipts.size).to eq(1)
        expect(receipts.first["store"]).to eq("readings")
      end
    end

    context "replay after purge" do
      it "replays only facts from surviving segments" do
        b = described_class.new(root,
              retention: { readings: { strategy: :ephemeral } })
        b.write_fact(make_fact(key: "k0"))
        b.checkpoint!
        b.write_fact(make_fact(key: "k1"))
        b.close

        b2 = described_class.new(root,
               retention: { readings: { strategy: :ephemeral } })
        b2.purge!
        facts = b2.replay(store: :readings)
        b2.close

        expect(facts.map(&:key)).to     include("k1")
        expect(facts.map(&:key)).not_to include("k0")
      end
    end
  end

  # ── IgniterStore integration ────────────────────────────────────────────────

  describe "Igniter::Store.segmented factory" do
    it "opens a store backed by SegmentedFileBackend" do
      store = Igniter::Store.segmented(root)
      store.write(store: :tasks, key: "t1", value: { done: false })
      store.close

      store2 = Igniter::Store.segmented(root)
      expect(store2.read(store: :tasks, key: "t1")).to include(done: false)
      store2.close
    end

    it "replays across stores on reopen" do
      store = Igniter::Store.segmented(root)
      store.write(store: :tasks,   key: "t1", value: { v: 1 })
      store.write(store: :signals, key: "s1", value: { v: 2 })
      store.close

      store2 = Igniter::Store.segmented(root)
      expect(store2.read(store: :tasks,   key: "t1")).to include(v: 1)
      expect(store2.read(store: :signals, key: "s1")).to include(v: 2)
      store2.close
    end
  end
end
