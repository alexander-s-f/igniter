# frozen_string_literal: true

require_relative "../../spec_helper"

RSpec.describe Igniter::Store::Fact do
  it "uses stable content hashes independent of hash insertion order" do
    first = described_class.build(store: :items, key: "a", value: { b: 2, a: 1 })
    second = described_class.build(store: :items, key: "b", value: { a: 1, b: 2 })

    expect(first.value_hash).to eq(second.value_hash)
  end
end
