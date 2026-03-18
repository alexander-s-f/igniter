# frozen_string_literal: true

require "spec_helper"

RSpec.describe Igniter::Contract do
  let(:contract_class) do
    Class.new(described_class) do
      define do
        input :order_total
        input :country

        compute :vat_rate, depends_on: [:country], call: :resolve_vat_rate
        compute :gross_total, depends_on: %i[order_total vat_rate] do |order_total:, vat_rate:|
          order_total * (1 + vat_rate)
        end

        output :gross_total
      end

      def resolve_vat_rate(country:)
        country == "UA" ? 0.2 : 0.0
      end
    end
  end

  it "resolves outputs lazily through the result facade" do
    contract = contract_class.new(order_total: 100, country: "UA")

    expect(contract.result.gross_total).to eq(120.0)
    expect(contract.result.to_h).to eq(gross_total: 120.0)
  end

  it "invalidates only downstream nodes after input update" do
    contract = contract_class.new(order_total: 100, country: "UA")

    contract.result.gross_total
    contract.update_inputs(order_total: 150)

    invalidated_paths = contract.events
      .select { |event| event.type == :node_invalidated }
      .map(&:path)

    expect(invalidated_paths).to include("gross_total", "output.gross_total")
    expect(invalidated_paths).not_to include("country")
    expect(contract.result.gross_total).to eq(180.0)
  end

  it "tracks node state versions and invalidation causes" do
    contract = contract_class.new(order_total: 100, country: "UA")

    contract.result.gross_total
    first_state = contract.execution.cache.fetch(:gross_total)
    contract.update_inputs(order_total: 150)
    stale_state = contract.execution.cache.fetch(:gross_total)
    contract.result.gross_total
    second_state = contract.execution.cache.fetch(:gross_total)

    expect(first_state.version).to eq(1)
    expect(stale_state.version).to eq(2)
    expect(stale_state.invalidated_by).to eq(:order_total)
    expect(second_state.version).to eq(3)
    expect(second_state.value).to eq(180.0)
  end
end
