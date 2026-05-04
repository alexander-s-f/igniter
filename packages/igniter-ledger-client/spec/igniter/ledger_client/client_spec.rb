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
      @response || {
        protocol: :igniter_store,
        schema_version: 1,
        request_id: envelope[:request_id],
        status: :ok,
        result: { op: envelope[:op], packet: envelope[:packet] }
      }
    end
  end

  it "dispatches write through a protocol envelope and returns result" do
    transport = FakeTransport.new
    client = described_class.new(transport: transport)

    result = client.write(store: :orders, key: "o1", value: { status: :open })

    expect(result[:op]).to eq(:write)
    expect(result[:packet]).to include(store: :orders, key: "o1", value: { status: :open })
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

    client.append(
      history: :contractable_events,
      event: { event_id: "evt_1", observation_id: "obs_1" },
      key: "client-key-1",
      partition_key: :observation_id,
      producer: { system: :spec }
    )

    packet = transport.requests.first[:packet]
    expect(transport.requests.first[:op]).to eq(:append)
    expect(packet).to include(history: :contractable_events, key: "client-key-1")
    expect(packet[:event]).to include(event_id: "evt_1")
    expect(packet[:partition_key]).to eq(:observation_id)
    expect(packet[:producer]).to eq(system: :spec)
  end
end
