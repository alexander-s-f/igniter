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
end
