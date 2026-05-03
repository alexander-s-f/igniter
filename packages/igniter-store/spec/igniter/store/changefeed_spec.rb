# frozen_string_literal: true

require_relative "../../spec_helper"

RSpec.describe "Changefeed subsystem" do
  def build_fact(store: :tasks, key: "k1", value: { n: 1 })
    Igniter::Store::Fact.build(store: store, key: key, value: value)
  end

  # ── ChangeEvent ───────────────────────────────────────────────────────────────

  describe Igniter::Store::ChangeEvent do
    it "has stable shape from ChangeEvent.from_fact" do
      fact  = build_fact
      event = described_class.from_fact(fact, sequence: 7)

      expect(event.schema_version).to   eq(1)
      expect(event.id).to               match(/\Achange_/)
      expect(event.type).to             eq(:fact_committed)
      expect(event.store).to            eq(:tasks)
      expect(event.key).to              eq("k1")
      expect(event.fact_id).to          eq(fact.id)
      expect(event.transaction_time).to eq(fact.transaction_time)
      expect(event.emitted_at).to       be_a(Float)
      expect(event.causation).to        eq(fact.causation)
      expect(event.cursor).to           eq({ sequence: 7 })
      expect(event.fact).to             equal(fact)
    end

    it "is frozen" do
      event = described_class.from_fact(build_fact, sequence: 1)
      expect(event).to be_frozen
    end

    it "cursor is frozen" do
      event = described_class.from_fact(build_fact, sequence: 5)
      expect(event.cursor).to be_frozen
    end

    it "to_h does not include :fact field" do
      event = described_class.from_fact(build_fact, sequence: 1)
      h = event.to_h
      expect(h).not_to have_key(:fact)
      expect(h).to     have_key(:schema_version)
      expect(h).to     have_key(:cursor)
      expect(h[:cursor]).to eq({ sequence: 1 })
    end

    it "each event has a unique id" do
      fact   = build_fact
      ids    = 5.times.map { described_class.from_fact(fact, sequence: 1).id }
      expect(ids.uniq.size).to eq(5)
    end

    it "carries producer from fact when present" do
      fact  = Igniter::Store::Fact.build(store: :s, key: "k", value: {}, producer: { system: :test })
      event = described_class.from_fact(fact, sequence: 1)
      expect(event.producer).to eq({ system: :test })
    end
  end

  # ── ChangefeedBuffer ──────────────────────────────────────────────────────────

  describe Igniter::Store::ChangefeedBuffer do
    let(:buf) { described_class.new }

    describe "#subscribe / #emit basic delivery" do
      it "delivers a ChangeEvent to a matching subscriber" do
        received = []
        buf.subscribe(stores: [:tasks]) { |e| received << e }

        fact = build_fact(store: :tasks)
        buf.emit(fact)

        expect(received.size).to eq(1)
        expect(received.first).to be_a(Igniter::Store::ChangeEvent)
        expect(received.first.store).to eq(:tasks)
        expect(received.first.key).to   eq("k1")
      end

      it "does not deliver to subscribers of other stores" do
        received = []
        buf.subscribe(stores: [:reminders]) { |e| received << e }

        buf.emit(build_fact(store: :tasks))

        expect(received).to be_empty
      end

      it "one subscription covers multiple stores" do
        received = []
        buf.subscribe(stores: [:tasks, :reminders]) { |e| received << e.store }

        buf.emit(build_fact(store: :tasks))
        buf.emit(build_fact(store: :reminders))
        buf.emit(build_fact(store: :other))

        expect(received.sort).to eq(%i[reminders tasks])
      end

      it "multiple subscribers each receive the event" do
        buckets = Array.new(3) { [] }
        buckets.each { |b| buf.subscribe(stores: [:items]) { |e| b << e.key } }

        buf.emit(build_fact(store: :items, key: "x"))

        buckets.each { |b| expect(b).to eq(["x"]) }
      end

      it "returns the emitted ChangeEvent" do
        buf.subscribe(stores: [:tasks]) { }
        fact  = build_fact
        event = buf.emit(fact)
        expect(event).to be_a(Igniter::Store::ChangeEvent)
        expect(event.fact_id).to eq(fact.id)
      end
    end

    describe "monotonic sequence / cursor" do
      it "assigns sequential cursors across multiple emits" do
        events = []
        buf.subscribe(stores: [:tasks]) { |e| events << e }

        3.times { |i| buf.emit(build_fact(key: "k#{i}")) }

        seqs = events.map { |e| e.cursor[:sequence] }
        expect(seqs).to eq([1, 2, 3])
      end
    end

    describe "#emit returns event even with no subscribers" do
      it "returns ChangeEvent without raising" do
        fact  = build_fact
        event = buf.emit(fact)
        expect(event).to be_a(Igniter::Store::ChangeEvent)
      end
    end

    describe "Subscription#close" do
      it "unsubscribes the handler" do
        received = []
        handle   = buf.subscribe(stores: [:tasks]) { |e| received << e }

        buf.emit(build_fact)
        handle.close
        buf.emit(build_fact)

        expect(received.size).to eq(1)
      end
    end

    describe "#subscriber_count" do
      it "reflects active subscriber count per store" do
        buf.subscribe(stores: [:tasks]) { }
        buf.subscribe(stores: [:tasks]) { }
        buf.subscribe(stores: [:other]) { }

        expect(buf.subscriber_count(:tasks)).to eq(2)
        expect(buf.subscriber_count(:other)).to  eq(1)
        expect(buf.subscriber_count).to           eq(3)
      end

      it "drops to zero after handle.close" do
        h = buf.subscribe(stores: [:tasks]) { }
        expect(buf.subscriber_count(:tasks)).to eq(1)
        h.close
        expect(buf.subscriber_count(:tasks)).to eq(0)
      end
    end

    describe "bounded buffer behavior" do
      it "does not exceed max_size in the ring" do
        small = described_class.new(max_size: 3)
        5.times { |i| small.emit(build_fact(key: "k#{i}")) }
        snap = small.snapshot
        expect(snap[:buffered]).to eq(3)
      end

      it "increments dropped_total when ring overflows" do
        small = described_class.new(max_size: 2)
        5.times { |i| small.emit(build_fact(key: "k#{i}")) }
        snap = small.snapshot
        expect(snap[:dropped_total]).to eq(3)
      end

      it "keeps the newest events when ring overflows" do
        small    = described_class.new(max_size: 2)
        received = []
        small.subscribe(stores: [:tasks]) { |e| received << e.key }

        5.times { |i| small.emit(build_fact(key: "k#{i}")) }

        expect(received).to eq(%w[k0 k1 k2 k3 k4])
      end
    end

    describe "failing subscriber behavior" do
      it "removes a subscriber that raises and increments failed_total" do
        called   = 0
        buf.subscribe(stores: [:tasks]) { |_e| called += 1; raise "boom" }

        buf.emit(build_fact)
        buf.emit(build_fact)

        snap = buf.snapshot
        expect(snap[:failed_total]).to   eq(1)
        expect(snap[:delivered_total]).to eq(0)
        expect(called).to                eq(1)
        expect(buf.subscriber_count(:tasks)).to eq(0)
      end

      it "other subscribers still receive events when one fails" do
        good_received = []
        buf.subscribe(stores: [:tasks]) { |_e| raise "bad" }
        buf.subscribe(stores: [:tasks]) { |e| good_received << e.key }

        buf.emit(build_fact(key: "x"))

        expect(good_received).to eq(["x"])
      end

      it "does not raise from emit when all subscribers fail" do
        buf.subscribe(stores: [:tasks]) { raise "boom" }
        expect { buf.emit(build_fact) }.not_to raise_error
      end
    end

    describe "observability counters" do
      it "snapshot has all required keys" do
        snap = buf.snapshot
        expected = %i[
          emitted_total delivered_total dropped_total failed_total
          buffered max_size subscriber_count oldest_sequence newest_sequence
        ]
        expected.each { |k| expect(snap).to have_key(k) }
      end

      it "emitted_total grows with each emit" do
        3.times { buf.emit(build_fact) }
        expect(buf.snapshot[:emitted_total]).to eq(3)
      end

      it "delivered_total grows with each successful delivery" do
        buf.subscribe(stores: [:tasks]) { }
        buf.subscribe(stores: [:tasks]) { }
        buf.emit(build_fact)
        expect(buf.snapshot[:delivered_total]).to eq(2)
      end

      it "oldest_sequence and newest_sequence reflect ring content" do
        5.times { |i| buf.emit(build_fact(key: "k#{i}")) }
        snap = buf.snapshot
        expect(snap[:oldest_sequence]).to eq(1)
        expect(snap[:newest_sequence]).to eq(5)
      end

      it "oldest/newest are nil when ring is empty" do
        snap = buf.snapshot
        expect(snap[:oldest_sequence]).to be_nil
        expect(snap[:newest_sequence]).to be_nil
      end
    end

    describe "thread safety" do
      it "handles concurrent emits and subscribes without corruption" do
        received = []
        mu       = Mutex.new

        buf.subscribe(stores: [:tasks]) { |e| mu.synchronize { received << e.cursor[:sequence] } }

        threads = 10.times.map do |i|
          Thread.new { buf.emit(build_fact(key: "k#{i}")) }
        end
        threads.each(&:join)

        snap = buf.snapshot
        expect(snap[:emitted_total]).to    eq(10)
        expect(snap[:delivered_total]).to  eq(10)
        expect(received.size).to           eq(10)
        expect(received.sort).to           eq(received.uniq.sort)
      end
    end
  end

  # ── IgniterStore changefeed integration ──────────────────────────────────────

  describe "IgniterStore changefeed integration" do
    let(:feed)  { Igniter::Store::ChangefeedBuffer.new }
    let(:store) { Igniter::Store::IgniterStore.new(changefeed: feed) }

    it "emits ChangeEvent after write" do
      received = []
      feed.subscribe(stores: [:tasks]) { |e| received << e }

      store.write(store: :tasks, key: "t1", value: { status: :open })

      expect(received.size).to eq(1)
      expect(received.first.store).to eq(:tasks)
      expect(received.first.key).to   eq("t1")
    end

    it "emits ChangeEvent after append" do
      received = []
      feed.subscribe(stores: [:events]) { |e| received << e }

      store.append(history: :events, event: { type: "order_placed" })

      expect(received.size).to eq(1)
      expect(received.first.store).to eq(:events)
    end

    it "emits for each write independently" do
      seqs = []
      feed.subscribe(stores: [:tasks]) { |e| seqs << e.cursor[:sequence] }

      3.times { |i| store.write(store: :tasks, key: "k#{i}", value: {}) }

      expect(seqs).to eq([1, 2, 3])
    end

    it "does not emit for stores not subscribed to" do
      received = []
      feed.subscribe(stores: [:other]) { |e| received << e }

      store.write(store: :tasks, key: "t1", value: {})

      expect(received).to be_empty
    end

    it "works without changefeed (nil — default)" do
      plain = Igniter::Store::IgniterStore.new
      expect { plain.write(store: :tasks, key: "t1", value: {}) }.not_to raise_error
    end
  end

  # ── StoreServer observability includes changefeed ─────────────────────────────

  describe "StoreServer observability includes changefeed snapshot" do
    def free_port
      s = TCPServer.new("127.0.0.1", 0)
      p = s.addr[1]; s.close; p
    end

    def null_logger
      Igniter::Store::ServerLogger.new(nil, :error)
    end

    after(:each) { @server&.stop }

    it "observability_snapshot includes changefeed key with required fields" do
      port    = free_port
      @server = Igniter::Store::StoreServer.new(address: "127.0.0.1:#{port}", logger: null_logger)
      @server.start_async
      @server.wait_until_ready

      snap = @server.observability_snapshot
      expect(snap).to have_key(:changefeed)
      cf = snap[:changefeed]

      %i[emitted_total delivered_total dropped_total failed_total
         buffered max_size subscriber_count].each do |k|
        expect(cf).to have_key(k)
      end
    end

    it "changefeed emitted_total grows after write_fact ops" do
      port    = free_port
      @server = Igniter::Store::StoreServer.new(address: "127.0.0.1:#{port}", logger: null_logger)
      @server.start_async
      @server.wait_until_ready

      c = Igniter::Store::NetworkBackend.new(address: "127.0.0.1:#{port}")
      3.times { |i| c.write_fact(Igniter::Store::Fact.build(store: :x, key: "k#{i}", value: {})) }
      sleep 0.05

      snap = @server.observability_snapshot
      expect(snap[:changefeed][:emitted_total]).to eq(3)
      c.close
    end
  end
end
