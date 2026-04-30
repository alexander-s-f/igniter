# frozen_string_literal: true

require_relative "../../spec_helper"

RSpec.describe Igniter::Store::IgniterStore do
  it "writes immutable facts, reads current state, and preserves causation" do
    store = described_class.new

    first = store.write(store: :reminders, key: "r1", value: { title: "Buy milk", status: :open })
    second = store.write(store: :reminders, key: "r1", value: { title: "Buy milk", status: :closed })

    expect(second.causation).to eq(first.value_hash)
    expect(store.read(store: :reminders, key: "r1")).to include(status: :closed)
    expect(store.causation_chain(store: :reminders, key: "r1").length).to eq(2)
  end

  it "supports time-travel reads" do
    store = described_class.new

    store.write(store: :reminders, key: "r1", value: { status: :open })
    sleep 0.01
    middle = Process.clock_gettime(Process::CLOCK_REALTIME)
    sleep 0.01
    store.write(store: :reminders, key: "r1", value: { status: :closed })

    expect(store.time_travel(store: :reminders, key: "r1", at: middle)).to include(status: :open)
    expect(store.read(store: :reminders, key: "r1")).to include(status: :closed)
  end

  it "registers access paths and pushes invalidation signals" do
    store = described_class.new
    invalidations = []

    store.register_path(
      Igniter::Store::AccessPath.new(
        store: :reminders,
        lookup: :primary_key,
        scope: nil,
        filters: nil,
        cache_ttl: 60,
        consumers: [->(store_name, key) { invalidations << [store_name, key] }]
      )
    )

    store.write(store: :reminders, key: "r1", value: { status: :open })
    store.write(store: :reminders, key: "r1", value: { status: :closed })

    expect(store.schema_graph.paths_for(:reminders).length).to eq(1)
    expect(invalidations).to eq([[:reminders, "r1"], [:reminders, "r1"]])
  end

  it "stores append-only history facts" do
    store = described_class.new

    store.append(history: :reminder_logs, event: { action: :created })
    store.append(history: :reminder_logs, event: { action: :closed })

    expect(store.history(store: :reminder_logs).map { |fact| fact.value.fetch(:action) }).to eq(%i[created closed])
  end

  describe "#query" do
    let(:store) { described_class.new }

    before do
      store.register_path(
        Igniter::Store::AccessPath.new(
          store: :tasks,
          lookup: :primary_key,
          scope: :pending,
          filters: { status: :pending },
          cache_ttl: nil,
          consumers: []
        )
      )
      store.register_path(
        Igniter::Store::AccessPath.new(
          store: :tasks,
          lookup: :primary_key,
          scope: :done,
          filters: { status: :done },
          cache_ttl: nil,
          consumers: []
        )
      )
    end

    it "returns facts matching the scope filters" do
      store.write(store: :tasks, key: "t1", value: { title: "A", status: :pending })
      store.write(store: :tasks, key: "t2", value: { title: "B", status: :done })
      store.write(store: :tasks, key: "t3", value: { title: "C", status: :pending })

      results = store.query(store: :tasks, scope: :pending)
      expect(results.map { |f| f.value[:title] }.sort).to eq(%w[A C])
    end

    it "reflects state after updates" do
      store.write(store: :tasks, key: "t1", value: { title: "A", status: :pending })
      store.write(store: :tasks, key: "t1", value: { title: "A", status: :done })

      pending_results = store.query(store: :tasks, scope: :pending)
      done_results    = store.query(store: :tasks, scope: :done)

      expect(pending_results).to be_empty
      expect(done_results.map { |f| f.value[:title] }).to eq(["A"])
    end

    it "invalidates scope cache on write" do
      store.write(store: :tasks, key: "t1", value: { title: "A", status: :pending })
      first_query = store.query(store: :tasks, scope: :pending)
      expect(first_query.length).to eq(1)

      store.write(store: :tasks, key: "t2", value: { title: "B", status: :pending })
      second_query = store.query(store: :tasks, scope: :pending)
      expect(second_query.length).to eq(2)
    end

    it "raises ArgumentError for unknown scope" do
      expect { store.query(store: :tasks, scope: :unknown) }
        .to raise_error(ArgumentError, /scope=:unknown/)
    end

    it "applies cache_ttl from registered AccessPath automatically" do
      store_with_ttl = described_class.new
      store_with_ttl.register_path(
        Igniter::Store::AccessPath.new(
          store: :items,
          lookup: :primary_key,
          scope: :active,
          filters: { active: true },
          cache_ttl: 60,
          consumers: []
        )
      )
      store_with_ttl.write(store: :items, key: "i1", value: { active: true })
      first  = store_with_ttl.query(store: :items, scope: :active)
      second = store_with_ttl.query(store: :items, scope: :active)
      expect(first).to equal(second)
    end

    it "supports time-travel via as_of" do
      store.write(store: :tasks, key: "t1", value: { title: "A", status: :pending })
      sleep 0.01
      checkpoint = Process.clock_gettime(Process::CLOCK_REALTIME)
      sleep 0.01
      store.write(store: :tasks, key: "t1", value: { title: "A", status: :done })

      at_checkpoint = store.query(store: :tasks, scope: :pending, as_of: checkpoint)
      expect(at_checkpoint.map { |f| f.value[:title] }).to eq(["A"])

      now = store.query(store: :tasks, scope: :pending)
      expect(now).to be_empty
    end
  end

  describe "reactive scope consumers" do
    it "notifies scope consumers when a fact in the store changes" do
      store = described_class.new
      notifications = []

      store.register_path(
        Igniter::Store::AccessPath.new(
          store: :tasks,
          lookup: :primary_key,
          scope: :pending,
          filters: { status: :pending },
          cache_ttl: nil,
          consumers: [->(s, scope) { notifications << [s, scope] }]
        )
      )

      store.write(store: :tasks, key: "t1", value: { status: :pending })
      # cache is cold — no scope entry yet, no notification
      expect(notifications).to be_empty

      # warm the cache with a query
      store.query(store: :tasks, scope: :pending)

      # second write invalidates the scope cache → notifies consumer
      store.write(store: :tasks, key: "t1", value: { status: :done })
      expect(notifications).to eq([[:tasks, :pending]])
    end

    it "notifies only scope consumers for the matching store" do
      store = described_class.new
      pending_calls = []
      done_calls    = []

      store.register_path(
        Igniter::Store::AccessPath.new(
          store: :tasks,
          lookup: :primary_key,
          scope: :pending,
          filters: { status: :pending },
          cache_ttl: nil,
          consumers: [->(s, sc) { pending_calls << sc }]
        )
      )
      store.register_path(
        Igniter::Store::AccessPath.new(
          store: :tasks,
          lookup: :primary_key,
          scope: :done,
          filters: { status: :done },
          cache_ttl: nil,
          consumers: [->(s, sc) { done_calls << sc }]
        )
      )

      store.write(store: :tasks, key: "t1", value: { status: :pending })
      # warm both scopes
      store.query(store: :tasks, scope: :pending)
      store.query(store: :tasks, scope: :done)
      pending_calls.clear
      done_calls.clear

      store.write(store: :tasks, key: "t1", value: { status: :done })

      # both scope caches were invalidated — both consumers notified
      expect(pending_calls).to eq([:pending])
      expect(done_calls).to eq([:done])
    end

    it "does not notify scope consumers for a different store" do
      store = described_class.new
      calls = []

      store.register_path(
        Igniter::Store::AccessPath.new(
          store: :tasks,
          lookup: :primary_key,
          scope: :pending,
          filters: { status: :pending },
          cache_ttl: nil,
          consumers: [->(s, sc) { calls << s }]
        )
      )

      # warm tasks scope
      store.query(store: :tasks, scope: :pending)
      calls.clear

      # write to a different store — should NOT trigger tasks scope consumer
      store.write(store: :other, key: "x1", value: { status: :pending })
      expect(calls).to be_empty
    end

    it "does not notify point-read consumers for scope paths" do
      store = described_class.new
      point_calls = []
      scope_calls = []

      store.register_path(
        Igniter::Store::AccessPath.new(
          store: :tasks,
          lookup: :primary_key,
          scope: nil,
          filters: nil,
          cache_ttl: nil,
          consumers: [->(s, k) { point_calls << k }]
        )
      )
      store.register_path(
        Igniter::Store::AccessPath.new(
          store: :tasks,
          lookup: :primary_key,
          scope: :pending,
          filters: { status: :pending },
          cache_ttl: nil,
          consumers: [->(s, sc) { scope_calls << sc }]
        )
      )

      store.write(store: :tasks, key: "t1", value: { status: :pending })
      # warm scope cache
      store.query(store: :tasks, scope: :pending)
      point_calls.clear
      scope_calls.clear

      store.write(store: :tasks, key: "t1", value: { status: :done })

      expect(point_calls).to eq(["t1"])     # point consumer fires for key
      expect(scope_calls).to eq([:pending]) # scope consumer fires for scope
    end
  end
end
