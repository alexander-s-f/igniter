# frozen_string_literal: true

require_relative "../../spec_helper"

RSpec.describe "ledger client transports" do
  it "wraps objects exposing dispatch(envelope)" do
    target = Class.new do
      attr_reader :received

      def dispatch(envelope)
        @received = envelope
        { protocol: :igniter_store, schema_version: 1, request_id: envelope[:request_id], status: :ok, result: :accepted }
      end
    end.new

    client = Igniter::LedgerClient.wrap(target)

    expect(client.metadata_snapshot).to eq(:accepted)
    expect(target.received[:op]).to eq(:metadata_snapshot)
  end

  it "normalizes remote HTTP endpoint root to /v1/dispatch" do
    transport = Igniter::LedgerClient::Transports::RemoteHTTP.new("http://example.test")

    expect(transport.uri.path).to eq("/v1/dispatch")
  end
end
