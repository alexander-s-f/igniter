# frozen_string_literal: true

require_relative "../../spec_helper"

RSpec.describe Igniter::LedgerClient::Results do
  ReceiptLike = Struct.new(
    :schema_version,
    :kind,
    :status,
    :store,
    :key,
    :fact_id,
    :value_hash,
    :warnings,
    :errors,
    keyword_init: true
  )

  it "normalizes local receipt-like objects into write results" do
    raw = ReceiptLike.new(
      schema_version: 1,
      kind: :receipt,
      status: :accepted,
      store: :orders,
      key: "o1",
      fact_id: "fact_1",
      value_hash: "hash_1",
      warnings: [],
      errors: []
    )

    result = described_class.wrap(:write, raw)

    expect(result).to be_a(described_class::WriteResult)
    expect(result).to be_accepted
    expect(result.store).to eq(:orders)
    expect(result[:fact_id]).to eq("fact_1")
    expect(result.to_h).to include(status: :accepted, store: :orders, key: "o1")
    expect(result).to be_frozen
  end

  it "normalizes remote string-key receipt hashes into append results" do
    result = described_class.wrap(
      :append,
      {
        "kind" => "append_receipt",
        "status" => "accepted",
        "store" => "events",
        "key" => "generated-key",
        "fact_id" => "fact_2",
        "value_hash" => "hash_2",
        "warnings" => ["metadata key ignored"],
        "errors" => []
      }
    )

    expect(result).to be_a(described_class::AppendResult)
    expect(result).to be_accepted
    expect(result.kind).to eq(:append_receipt)
    expect(result.store).to eq(:events)
    expect(result.warnings).to eq(["metadata key ignored"])
  end

  it "normalizes read results and keeps hash-like access" do
    result = described_class.wrap(:read, { "value" => { status: "open" }, "found" => true })

    expect(result).to be_found
    expect(result.value).to eq(status: "open")
    expect(result[:value]).to eq(status: "open")
    expect(result.to_h).to eq(value: { status: "open" }, found: true)
  end

  it "normalizes query and replay counts" do
    query = described_class.wrap(:query, { "results" => [{ status: "open" }] })
    replay = described_class.wrap(:replay, { "facts" => [{ key: "evt_1" }] })

    expect(query.results).to eq([{ status: "open" }])
    expect(query.count).to eq(1)
    expect(replay.facts).to eq([{ key: "evt_1" }])
    expect(replay.count).to eq(1)
  end

  it "leaves snapshot-like operations raw" do
    raw = { stores: {} }

    expect(described_class.wrap(:metadata_snapshot, raw)).to be(raw)
  end
end
