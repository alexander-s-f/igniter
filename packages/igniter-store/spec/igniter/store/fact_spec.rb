# frozen_string_literal: true

require_relative "../../spec_helper"

RSpec.describe Igniter::Store::Fact do
  it "uses stable content hashes independent of hash insertion order" do
    first  = described_class.build(store: :items, key: "a", value: { b: 2, a: 1 })
    second = described_class.build(store: :items, key: "b", value: { a: 1, b: 2 })

    expect(first.value_hash).to eq(second.value_hash)
  end

  it "assigns a unique UUID id to each fact regardless of content" do
    f1 = described_class.build(store: :items, key: "a", value: { x: 1 })
    f2 = described_class.build(store: :items, key: "a", value: { x: 1 })

    expect(f1.id).not_to eq(f2.id)
    expect(f1.value_hash).to eq(f2.value_hash)
  end

  it "sets causation to the previous fact id, not the value hash" do
    f1 = described_class.build(store: :items, key: "a", value: { v: 1 })
    f2 = described_class.build(store: :items, key: "a", value: { v: 2 }, causation: f1.id)

    expect(f2.causation).to eq(f1.id)
    expect(f2.causation).not_to eq(f1.value_hash)
  end

  it "causation chain is unambiguous when the same value is written twice" do
    f1 = described_class.build(store: :items, key: "a", value: { status: :open })
    f2 = described_class.build(store: :items, key: "a", value: { status: :open }, causation: f1.id)

    # Same content → same value_hash, but each fact has a distinct id
    expect(f1.value_hash).to eq(f2.value_hash)
    expect(f2.causation).to eq(f1.id)
    expect(f2.causation).not_to eq(f2.value_hash)
  end


end
