# frozen_string_literal: true

require_relative "../../spec_helper"

RSpec.describe "Changefeed subsystem" do
  def build_fact(store: :tasks, key: "k1", value: { n: 1 })
    Igniter::Store::Fact.build(store: store, key: key, value: value)
  end

  # Small helper to wait for async worker threads to deliver events.
  def wait_delivery(timeout: 0.3, poll: 0.005)
    deadline = Time.now + timeout
    yield while Time.now < deadline
    nil
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
        sleep 0.05

        expect(received.size).to eq(1)
        expect(received.first).to be_a(Igniter::Store::ChangeEvent)
        expect(received.first.store).to eq(:tasks)
        expect(received.first.key).to   eq("k1")
      end

      it "does not deliver to subscribers of other stores" do
        received = []
        buf.subscribe(stores: [:reminders]) { |e| received << e }

        buf.emit(build_fact(store: :tasks))
        sleep 0.05

        expect(received).to be_empty
      end

      it "one subscription covers multiple stores" do
        received = []
        buf.subscribe(stores: [:tasks, :reminders]) { |e| received << e.store }

        buf.emit(build_fact(store: :tasks))
        buf.emit(build_fact(store: :reminders))
        buf.emit(build_fact(store: :other))
        sleep 0.05

        expect(received.sort).to eq(%i[reminders tasks])
      end

      it "multiple subscribers each receive the event" do
        buckets = Array.new(3) { [] }
        buckets.each { |b| buf.subscribe(stores: [:items]) { |e| b << e.key } }

        buf.emit(build_fact(store: :items, key: "x"))
        sleep 0.05

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
        sleep 0.05

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
        handle.close            # joins worker; drains first event
        buf.emit(build_fact)    # no subscriber, ignored

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
        sleep 0.05

        expect(received).to eq(%w[k0 k1 k2 k3 k4])
      end
    end

    describe "failing subscriber behavior" do
      it "removes a subscriber that raises and increments failed_total" do
        called   = 0
        buf.subscribe(stores: [:tasks]) { |_e| called += 1; raise "boom" }

        buf.emit(build_fact)
        buf.emit(build_fact)
        sleep 0.05

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
        sleep 0.05

        expect(good_received).to eq(["x"])
      end

      it "does not raise from emit when all subscribers fail" do
        buf.subscribe(stores: [:tasks]) { raise "boom" }
        expect { buf.emit(build_fact) }.not_to raise_error
        sleep 0.02  # let worker thread exit cleanly
      end
    end

    describe "observability counters" do
      it "snapshot has all required keys" do
        snap = buf.snapshot
        expected = %i[
          emitted_total delivered_total dropped_total overflow_dropped_total
          failed_total buffered max_size subscriber_count oldest_sequence newest_sequence
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
        sleep 0.05
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
        sleep 0.1  # wait for worker thread to drain all 10 events

        snap = buf.snapshot
        expect(snap[:emitted_total]).to    eq(10)
        expect(snap[:delivered_total]).to  eq(10)
        expect(received.size).to           eq(10)
        expect(received.sort).to           eq(received.uniq.sort)
      end
    end

    # ── Async fan-out behavior ─────────────────────────────────────────────────

    describe "async fan-out behavior" do
      let(:buf) { described_class.new(max_size: 100, subscriber_queue_size: 5, overflow: :drop_oldest) }

      it "emit returns quickly even when subscriber handler is slow" do
        latch  = Mutex.new
        go     = ConditionVariable.new
        paused = true

        handle = buf.subscribe(stores: []) do |_e|
          latch.synchronize { go.wait(latch) while paused }
        end

        t_start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        buf.emit(build_fact)
        elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - t_start

        expect(elapsed).to be < 0.05

        latch.synchronize { paused = false; go.broadcast }
        handle.close
      end

      it "drops oldest events when subscriber queue overflows (:drop_oldest)" do
        latch  = Mutex.new
        go     = ConditionVariable.new
        paused = true
        delivered = []

        handle = buf.subscribe(stores: []) do |e|
          latch.synchronize { go.wait(latch) while paused }
          delivered << e.cursor[:sequence]
        end

        # Pause handler so queue fills; emit more than queue capacity
        10.times { buf.emit(build_fact) }
        sleep 0.02  # fan_out has time to enqueue

        latch.synchronize { paused = false; go.broadcast }
        handle.close

        # queue_size=5: 1 being processed + 5 in queue → 6 max, rest dropped
        expect(delivered.size).to be <= 6
        expect(buf.snapshot[:overflow_dropped_total]).to be > 0
        # newest events should be retained (drop_oldest policy)
        expect(delivered.last).to eq(10)
      end

      it "drop_oldest preserves newest events in queue" do
        latch  = Mutex.new
        go     = ConditionVariable.new
        paused = true
        delivered = []

        handle = buf.subscribe(stores: []) do |e|
          latch.synchronize { go.wait(latch) while paused }
          delivered << e.cursor[:sequence]
        end

        6.times { buf.emit(build_fact) }  # exactly fills queue (1 running + 5)
        sleep 0.02

        # Overflow: emit 4 more, oldest in queue dropped each time
        4.times { buf.emit(build_fact) }
        sleep 0.02

        latch.synchronize { paused = false; go.broadcast }
        handle.close

        # Sequences 7–10 should survive; early sequences may be dropped
        expect(delivered).to include(7, 8, 9, 10)
      end

      it "raising subscriber is removed and counted as failed" do
        buf2   = described_class.new
        handle = buf2.subscribe(stores: []) { |_e| raise "boom" }

        buf2.emit(build_fact)
        sleep 0.05

        expect(buf2.snapshot[:failed_total]).to   eq(1)
        expect(buf2.snapshot[:delivered_total]).to eq(0)
        expect(buf2.subscriber_count).to           eq(0)
        handle.close  # idempotent
      end

      it "Subscription#close stops delivery and releases the worker thread" do
        buf2      = described_class.new
        delivered = []
        handle    = buf2.subscribe(stores: []) { |e| delivered << e }

        buf2.emit(build_fact)
        handle.close  # drains first event, stops worker

        count_after_close = delivered.size

        buf2.emit(build_fact)  # no subscriber
        sleep 0.05

        expect(delivered.size).to eq(count_after_close)
        expect(handle.instance_variable_get(:@record).thread.alive?).to be false
      end

      it "overflow_dropped_total is 0 when queue never fills" do
        buf2   = described_class.new(subscriber_queue_size: 100)
        handle = buf2.subscribe(stores: []) { }
        5.times { buf2.emit(build_fact) }
        sleep 0.05
        expect(buf2.snapshot[:overflow_dropped_total]).to eq(0)
        handle.close
      end

      it "wildcard subscription (stores: []) receives events from all stores" do
        buf2     = described_class.new
        received = []
        handle   = buf2.subscribe(stores: []) { |e| received << e.store }

        buf2.emit(build_fact(store: :tasks))
        buf2.emit(build_fact(store: :reminders))
        buf2.emit(build_fact(store: :other))
        sleep 0.05

        expect(received.map(&:to_s).sort).to eq(%w[other reminders tasks])
        handle.close
      end

      it "multiple worker threads do not corrupt delivered_total counter" do
        buf2       = described_class.new
        n_subs     = 5
        n_emits    = 20
        handles    = n_subs.times.map { buf2.subscribe(stores: []) { } }

        n_emits.times { buf2.emit(build_fact) }
        sleep 0.2

        expect(buf2.snapshot[:delivered_total]).to eq(n_subs * n_emits)
        handles.each(&:close)
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
      sleep 0.05

      expect(received.size).to eq(1)
      expect(received.first.store).to eq(:tasks)
      expect(received.first.key).to   eq("t1")
    end

    it "emits ChangeEvent after append" do
      received = []
      feed.subscribe(stores: [:events]) { |e| received << e }

      store.append(history: :events, event: { type: "order_placed" })
      sleep 0.05

      expect(received.size).to eq(1)
      expect(received.first.store).to eq(:events)
    end

    it "emits for each write independently" do
      seqs = []
      feed.subscribe(stores: [:tasks]) { |e| seqs << e.cursor[:sequence] }

      3.times { |i| store.write(store: :tasks, key: "k#{i}", value: {}) }
      sleep 0.05

      expect(seqs).to eq([1, 2, 3])
    end

    it "does not emit for stores not subscribed to" do
      received = []
      feed.subscribe(stores: [:other]) { |e| received << e }

      store.write(store: :tasks, key: "t1", value: {})
      sleep 0.05

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

  # ── ChangefeedBuffer#replay cursor semantics ──────────────────────────────────

  describe "ChangefeedBuffer#replay" do
    let(:buf) { Igniter::Store::ChangefeedBuffer.new }

    def emit_n(n, store: :tasks)
      n.times { |i| buf.emit(build_fact(store: store, key: "k#{i}")) }
    end

    describe "nil cursor — full retained replay" do
      it "returns all retained events in sequence order" do
        emit_n(3)
        result = buf.replay
        expect(result[:status]).to        eq(:ok)
        expect(result[:events].size).to   eq(3)
        seqs = result[:events].map { |e| e.cursor[:sequence] }
        expect(seqs).to eq([1, 2, 3])
      end

      it "returns empty events when ring is empty" do
        result = buf.replay
        expect(result[:status]).to        eq(:ok)
        expect(result[:events]).to        be_empty
        expect(result[:cursor]).to        be_nil
        expect(result[:oldest_cursor]).to be_nil
        expect(result[:newest_cursor]).to be_nil
      end

      it "result has all required keys" do
        emit_n(2)
        result = buf.replay
        %i[status events cursor oldest_cursor newest_cursor dropped_total].each do |k|
          expect(result).to have_key(k)
        end
      end
    end

    describe "cursor { sequence: N } — replay after N" do
      it "returns events with sequence > N" do
        emit_n(5)
        result = buf.replay(cursor: { sequence: 2 })
        expect(result[:status]).to       eq(:ok)
        seqs = result[:events].map { |e| e.cursor[:sequence] }
        expect(seqs).to eq([3, 4, 5])
      end

      it "cursor in result equals last returned event's sequence" do
        emit_n(5)
        result = buf.replay(cursor: { sequence: 2 })
        expect(result[:cursor]).to eq({ sequence: 5 })
      end

      it "returns empty when cursor is at newest sequence" do
        emit_n(3)
        result = buf.replay(cursor: { sequence: 3 })
        expect(result[:status]).to      eq(:ok)
        expect(result[:events]).to      be_empty
        expect(result[:cursor]).to      eq({ sequence: 3 })
      end

      it "returns empty when cursor is beyond newest sequence" do
        emit_n(3)
        result = buf.replay(cursor: { sequence: 99 })
        expect(result[:status]).to      eq(:ok)
        expect(result[:events]).to      be_empty
      end

      it "oldest_cursor and newest_cursor always reflect ring boundaries" do
        emit_n(5)
        result = buf.replay(cursor: { sequence: 2 })
        expect(result[:oldest_cursor]).to eq({ sequence: 1 })
        expect(result[:newest_cursor]).to eq({ sequence: 5 })
      end
    end

    describe ":cursor_too_old — gap due to ring overflow" do
      it "returns :cursor_too_old when cursor is before oldest retained with a gap" do
        small = Igniter::Store::ChangefeedBuffer.new(max_size: 3)
        5.times { |i| small.emit(build_fact(key: "k#{i}")) }
        # Ring now holds [3,4,5], oldest=3, dropped=2
        # cursor seq=1 → gap: need seq 2 which is gone
        result = small.replay(cursor: { sequence: 1 })
        expect(result[:status]).to        eq(:cursor_too_old)
        expect(result[:events]).to        be_empty
        expect(result[:oldest_cursor]).to eq({ sequence: 3 })
        expect(result[:newest_cursor]).to eq({ sequence: 5 })
      end

      it "does NOT return :cursor_too_old when cursor is exactly oldest_seq - 1 (no gap)" do
        small = Igniter::Store::ChangefeedBuffer.new(max_size: 3)
        5.times { |i| small.emit(build_fact(key: "k#{i}")) }
        # oldest=3, cursor=2: seq 3 = cursor+1, no gap
        result = small.replay(cursor: { sequence: 2 })
        expect(result[:status]).to      eq(:ok)
        seqs = result[:events].map { |e| e.cursor[:sequence] }
        expect(seqs).to eq([3, 4, 5])
      end

      it "includes dropped_total in :cursor_too_old result" do
        small = Igniter::Store::ChangefeedBuffer.new(max_size: 2)
        5.times { |i| small.emit(build_fact(key: "k#{i}")) }
        result = small.replay(cursor: { sequence: 1 })
        expect(result[:dropped_total]).to eq(3)
      end
    end

    describe "store-filtered replay" do
      it "returns only events matching the requested stores" do
        buf.emit(build_fact(store: :tasks,     key: "t1"))
        buf.emit(build_fact(store: :reminders, key: "r1"))
        buf.emit(build_fact(store: :tasks,     key: "t2"))

        result = buf.replay(stores: [:tasks])
        stores = result[:events].map(&:store)
        expect(stores).to eq(%i[tasks tasks])
      end

      it "returns empty when store filter matches nothing" do
        emit_n(3)
        result = buf.replay(stores: [:other])
        expect(result[:status]).to    eq(:ok)
        expect(result[:events]).to    be_empty
      end

      it "nil stores returns all stores" do
        buf.emit(build_fact(store: :tasks))
        buf.emit(build_fact(store: :reminders))
        result = buf.replay(stores: nil)
        expect(result[:events].size).to eq(2)
      end
    end

    describe "limit parameter" do
      it "caps the number of returned events" do
        emit_n(5)
        result = buf.replay(limit: 3)
        expect(result[:events].size).to     eq(3)
        seqs = result[:events].map { |e| e.cursor[:sequence] }
        expect(seqs).to eq([1, 2, 3])
      end

      it "cursor reflects the last returned event when limit is applied" do
        emit_n(5)
        result = buf.replay(limit: 2)
        expect(result[:cursor]).to eq({ sequence: 2 })
      end

      it "limit with cursor returns next page" do
        emit_n(6)
        page1 = buf.replay(limit: 3)
        page2 = buf.replay(cursor: page1[:cursor], limit: 3)
        seqs2 = page2[:events].map { |e| e.cursor[:sequence] }
        expect(seqs2).to eq([4, 5, 6])
      end
    end

    describe "subscriber cursor handoff" do
      it "subscriber can replay missed events using last received cursor" do
        received_live = []
        handle = buf.subscribe(stores: [:tasks]) { |e| received_live << e }

        # Subscriber receives first 3 live
        emit_n(3)

        # Subscription close drains queue and joins worker — all 3 delivered
        handle.close
        last_cursor = received_live.last.cursor

        # 2 more events emitted while subscriber is away
        buf.emit(build_fact(key: "k3"))
        buf.emit(build_fact(key: "k4"))

        # Subscriber replays from last_cursor to catch up
        result = buf.replay(cursor: last_cursor, stores: [:tasks])
        expect(result[:status]).to     eq(:ok)
        expect(result[:events].size).to eq(2)
        keys = result[:events].map(&:key)
        expect(keys).to eq(%w[k3 k4])
      end
    end
  end

  # ── Emission ordering: source-first policy ────────────────────────────────────

  describe "Emission ordering policy (source before derived/scatter)" do
    it "source fact is emitted before derived facts" do
      feed  = Igniter::Store::ChangefeedBuffer.new
      store = Igniter::Store::IgniterStore.new(changefeed: feed)

      store.register_derivation(
        source_store: :tasks,
        source_filters: {},
        target_store: :summaries,
        target_key: "count",
        rule: ->(facts) { { n: facts.size } }
      )

      all_events = []
      feed.subscribe(stores: [:tasks, :summaries]) { |e| all_events << e }

      store.write(store: :tasks, key: "t1", value: { status: :open })
      sleep 0.05

      # Source (:tasks) must appear before derived (:summaries)
      expect(all_events.size).to be >= 2
      first  = all_events[0]
      second = all_events[1]
      expect(first.store).to  eq(:tasks)
      expect(second.store).to eq(:summaries)
      # Sequence is also monotonically increasing
      expect(first.cursor[:sequence]).to  eq(1)
      expect(second.cursor[:sequence]).to eq(2)
    end

    it "source fact is emitted before scatter-derived facts" do
      feed  = Igniter::Store::ChangefeedBuffer.new
      store = Igniter::Store::IgniterStore.new(changefeed: feed)

      store.register_scatter(
        source_store: :comments,
        partition_by: :article_id,
        target_store: :article_index,
        rule: lambda { |part_key, existing, new_fact|
          ids = existing ? existing[:ids].dup : []
          ids << new_fact.key unless ids.include?(new_fact.key)
          { article_id: part_key, ids: ids }
        }
      )

      all_events = []
      feed.subscribe(stores: [:comments, :article_index]) { |e| all_events << e }

      store.write(store: :comments, key: "c1", value: { article_id: "a1", body: "hi" })
      sleep 0.05

      expect(all_events.size).to be >= 2
      expect(all_events[0].store).to eq(:comments)
      expect(all_events[1].store).to eq(:article_index)
    end

    it "multiple writes produce strictly increasing sequences across source + derived" do
      feed  = Igniter::Store::ChangefeedBuffer.new
      store = Igniter::Store::IgniterStore.new(changefeed: feed)

      store.register_derivation(
        source_store: :items,
        source_filters: {},
        target_store: :item_counts,
        target_key: "total",
        rule: ->(facts) { { n: facts.size } }
      )

      seqs = []
      feed.subscribe(stores: [:items, :item_counts]) { |e| seqs << e.cursor[:sequence] }

      2.times { |i| store.write(store: :items, key: "i#{i}", value: {}) }
      sleep 0.05

      expect(seqs).to eq(seqs.sort)
      expect(seqs.uniq).to eq(seqs)
    end

    it "append does not trigger derivations so ordering is trivial" do
      feed  = Igniter::Store::ChangefeedBuffer.new
      store = Igniter::Store::IgniterStore.new(changefeed: feed)

      events = []
      feed.subscribe(stores: [:audit]) { |e| events << e }

      store.append(history: :audit, event: { action: "login" })
      store.append(history: :audit, event: { action: "logout" })
      sleep 0.05

      expect(events.size).to eq(2)
      expect(events.map { |e| e.cursor[:sequence] }).to eq([1, 2])
    end
  end
end
