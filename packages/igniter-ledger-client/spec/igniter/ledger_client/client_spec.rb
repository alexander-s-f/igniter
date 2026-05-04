# frozen_string_literal: true

require_relative "../../spec_helper"

RSpec.describe Igniter::LedgerClient::Client do
  class FakeTransport
    attr_reader :requests

    def initialize(response: nil)
      @response = response
      @requests = []
    end

    def dispatch(envelope)
      @requests << envelope
      result = case envelope[:op]
               when :register_descriptor
                 { kind: :store, status: :accepted, name: envelope[:packet][:name], warnings: [], errors: [] }
               when :write
                 { kind: :receipt, status: :accepted, store: envelope[:packet][:store], key: envelope[:packet][:key], fact_id: "fact_w", value_hash: "hash_w" }
               when :append
                 { kind: :append_receipt, status: :accepted, store: envelope[:packet][:history], key: "generated-key", fact_id: "fact_a", value_hash: "hash_a" }
               when :read
                 { value: { status: :open }, found: true }
               when :query
                 { results: [{ status: :open }], count: 1 }
               when :replay
                 { facts: [{ key: "evt_1" }], count: 1 }
               else
                 { op: envelope[:op], packet: envelope[:packet] }
               end

      @response || {
        protocol: :igniter_store,
        schema_version: 1,
        request_id: envelope[:request_id],
        status: :ok,
        result: result
      }
    end
  end

  it "dispatches write through a protocol envelope and returns result" do
    transport = FakeTransport.new
    client = described_class.new(transport: transport)

    result = client.write(store: :orders, key: "o1", value: { status: :open })

    expect(result).to be_a(Igniter::LedgerClient::Results::WriteResult)
    expect(result).to be_accepted
    expect(result.store).to eq(:orders)
    expect(result.key).to eq("o1")
    expect(transport.requests.first).to include(protocol: :igniter_store, schema_version: 1, op: :write)
  end

  it "raises LedgerClient::Error for error envelopes" do
    transport = FakeTransport.new(
      response: {
        protocol: :igniter_store,
        schema_version: 1,
        request_id: "req_test",
        status: :error,
        error: "boom"
      }
    )
    client = described_class.new(transport: transport)

    expect { client.metadata_snapshot }.to raise_error(Igniter::LedgerClient::Error, "boom")
  end

  it "wraps metadata and compaction reads" do
    transport = FakeTransport.new
    client = described_class.new(transport: transport)

    client.metadata_snapshot
    client.compaction_activity(store: :orders, kind: :exact_prune, limit: 10)

    expect(transport.requests.map { |r| r[:op] }).to eq(%i[metadata_snapshot compaction_activity])
    expect(transport.requests.last[:packet]).to include(store: :orders, kind: :exact_prune, limit: 10)
  end

  it "dispatches append through a first-class protocol operation" do
    transport = FakeTransport.new
    client = described_class.new(transport: transport)

    result = client.append(
      history: :contractable_events,
      event: { event_id: "evt_1", observation_id: "obs_1" },
      key: "client-key-1",
      partition_key: :observation_id,
      producer: { system: :spec }
    )

    packet = transport.requests.first[:packet]
    expect(result).to be_a(Igniter::LedgerClient::Results::AppendResult)
    expect(result).to be_accepted
    expect(result.store).to eq(:contractable_events)
    expect(result.key).to eq("generated-key")
    expect(transport.requests.first[:op]).to eq(:append)
    expect(packet).to include(history: :contractable_events, key: "client-key-1")
    expect(packet[:event]).to include(event_id: "evt_1")
    expect(packet[:partition_key]).to eq(:observation_id)
    expect(packet[:producer]).to eq(system: :spec)
  end

  it "normalizes descriptor, read, query, and replay results" do
    transport = FakeTransport.new
    client = described_class.new(transport: transport)

    descriptor = client.register_descriptor(kind: :store, name: :orders)
    read = client.read(store: :orders, key: "o1")
    query = client.query(store: :orders, where: { status: :open })
    replay = client.replay(store: :order_events)

    expect(descriptor).to be_a(Igniter::LedgerClient::Results::ReceiptResult)
    expect(descriptor).to be_accepted
    expect(read).to be_a(Igniter::LedgerClient::Results::ReadResult)
    expect(read).to be_found
    expect(read.value).to eq(status: :open)
    expect(query.results).to eq([{ status: :open }])
    expect(query.count).to eq(1)
    expect(replay.facts).to eq([{ key: "evt_1" }])
    expect(replay.count).to eq(1)
  end
end
