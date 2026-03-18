# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Igniter composition" do
  let(:pricing_contract) do
    Class.new(Igniter::Contract) do
      define do
        input :order_total
        input :country

        compute :vat_rate, depends_on: [:country] do |country:|
          country == "UA" ? 0.2 : 0.0
        end

        compute :gross_total, depends_on: %i[order_total vat_rate] do |order_total:, vat_rate:|
          order_total * (1 + vat_rate)
        end

        output :gross_total
        output :vat_rate
      end
    end
  end

  let(:checkout_contract) do
    child_contract = pricing_contract

    Class.new(Igniter::Contract) do
      define do
        input :order_total
        input :country

        compose :pricing, contract: child_contract, inputs: {
          order_total: :order_total,
          country: :country
        }

        output :pricing
      end
    end
  end

  it "returns a nested result for composition outputs" do
    contract = checkout_contract.new(order_total: 100, country: "UA")

    pricing_result = contract.result.pricing

    expect(pricing_result).to be_a(Igniter::Runtime::Result)
    expect(pricing_result.gross_total).to eq(120.0)
    expect(contract.result.to_h).to eq(
      pricing: {
        gross_total: 120.0,
        vat_rate: 0.2
      }
    )
  end

  it "keeps child execution isolated from parent execution" do
    contract = checkout_contract.new(order_total: 100, country: "UA")

    pricing_result = contract.result.pricing
    child_execution_id = pricing_result.execution.events.execution_id
    parent_execution_id = contract.execution.events.execution_id

    expect(child_execution_id).not_to eq(parent_execution_id)
    expect(contract.events.map(&:path)).to include("pricing")
    expect(contract.events.map(&:path)).not_to include("gross_total")

    pricing_result.gross_total
    expect(pricing_result.execution.events.events.map(&:path)).to include("gross_total")
  end

  it "creates a new child execution after parent invalidation" do
    contract = checkout_contract.new(order_total: 100, country: "UA")

    first_child = contract.result.pricing
    first_execution_id = first_child.execution.events.execution_id

    contract.update_inputs(order_total: 150)
    second_child = contract.result.pricing

    expect(second_child.gross_total).to eq(180.0)
    expect(second_child.execution.events.execution_id).not_to eq(first_execution_id)
  end
end
