# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Igniter diagnostics" do
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

  it "builds a structured diagnostics report" do
    contract = contract_class.new(order_total: 100, country: "UA")

    report = contract.diagnostics.to_h

    expect(report).to include(
      graph: "AnonymousContract",
      execution_id: contract.execution.events.execution_id,
      status: :succeeded,
      outputs: { gross_total: 120.0 }
    )
    expect(report[:nodes]).to include(total: 4, succeeded: 4, failed: 0, stale: 0)
    expect(report[:events]).to include(latest_type: :execution_finished)
  end

  it "formats diagnostics as text and markdown" do
    contract = contract_class.new(order_total: 100, country: "UA")

    text = contract.diagnostics_text
    markdown = contract.diagnostics_markdown

    expect(text).to include("Diagnostics AnonymousContract")
    expect(text).to include("Status: succeeded")
    expect(markdown).to include("# Diagnostics AnonymousContract")
    expect(markdown).to include("- Status: `succeeded`")
  end

  it "surfaces failed nodes in the diagnostics report" do
    failing_contract = Class.new(Igniter::Contract) do
      define do
        input :order_total

        compute :gross_total, depends_on: [:order_total] do |order_total:|
          raise "boom #{order_total}"
        end

        output :gross_total
      end
    end

    contract = failing_contract.new(order_total: 100)

    report = contract.diagnostics.to_h
    expect(report[:status]).to eq(:failed)
    expect(report[:nodes][:failed_nodes].first).to include(node_name: :gross_total)
    expect(report[:errors].first[:message]).to include("boom 100")
  end
end
