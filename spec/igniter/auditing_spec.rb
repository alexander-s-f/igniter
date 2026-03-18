# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Igniter auditing" do
  let(:contract_class) do
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
      end
    end
  end

  it "collects runtime events in an audit timeline" do
    contract = contract_class.new(order_total: 100, country: "UA")

    contract.result.gross_total
    contract.update_inputs(order_total: 150)
    contract.result.gross_total

    snapshot = contract.audit_snapshot

    expect(snapshot[:graph]).to eq(contract.execution.compiled_graph.name)
    expect(snapshot[:event_count]).to be > 0
    expect(snapshot[:events].map { |event| event[:type] }).to include(:node_started, :node_succeeded, :input_updated, :node_invalidated)
    expect(snapshot[:states][:gross_total]).to include(
      status: :succeeded,
      value: 180.0
    )
  end

  it "includes stable event identifiers in the timeline" do
    contract = contract_class.new(order_total: 100, country: "UA")

    contract.result.gross_total

    event_ids = contract.audit.events.map(&:event_id)
    expect(event_ids).not_to be_empty
    expect(event_ids.uniq).to eq(event_ids)
  end

  it "captures child execution snapshots for composition nodes" do
    pricing_contract = contract_class

    checkout_contract = Class.new(Igniter::Contract) do
      define do
        input :order_total
        input :country

        compose :pricing, contract: pricing_contract, inputs: {
          order_total: :order_total,
          country: :country
        }

        output :pricing
      end
    end

    contract = checkout_contract.new(order_total: 100, country: "UA")
    contract.result.pricing.gross_total

    snapshot = contract.audit_snapshot
    child = snapshot[:children].first

    expect(child[:node_name]).to eq(:pricing)
    expect(child[:snapshot][:graph]).to eq(pricing_contract.graph.name)
    expect(child[:snapshot][:states][:gross_total][:value]).to eq(120.0)
  end
end
