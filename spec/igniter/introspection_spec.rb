# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Igniter introspection" do
  let(:contract_class) do
    Class.new(Igniter::Contract) do
      define do
        input :order_total, type: :numeric
        input :country, type: :string

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

  it "formats compiled graph as text" do
    text = contract_class.graph.to_text

    expect(text).to include("Graph AnonymousContract")
    expect(text).to include("input order_total")
    expect(text).to include("compute gross_total depends_on=order_total,vat_rate")
    expect(text).to include("output.gross_total -> gross_total")
  end

  it "formats compiled graph as mermaid" do
    mermaid = contract_class.graph.to_mermaid

    expect(mermaid).to include("graph TD")
    expect(mermaid).to include('node_order_total["input: order_total"]')
    expect(mermaid).to include('node_vat_rate --> node_gross_total')
    expect(mermaid).to include('node_gross_total --> output_gross_total')
  end

  it "returns normalized runtime states" do
    contract = contract_class.new(order_total: 100, country: "UA")
    contract.result.gross_total

    states = contract.result.states

    expect(states[:gross_total]).to include(
      path: "gross_total",
      kind: :compute,
      status: :succeeded,
      value: 120.0
    )
  end

  it "explains output dependency resolution" do
    contract = contract_class.new(order_total: 100, country: "UA")

    explanation = contract.result.explain(:gross_total)

    expect(explanation[:output]).to eq(:gross_total)
    expect(explanation[:source]).to eq(:gross_total)
    expect(explanation[:dependencies].dig(:dependencies, 0, :name)).to eq(:order_total)
    expect(explanation[:dependencies].dig(:dependencies, 1, :name)).to eq(:vat_rate)
  end

  it "exposes runtime explain API on execution" do
    contract = contract_class.new(order_total: 100, country: "UA")
    contract.result.gross_total

    explanation = contract.execution.explain_output(:gross_total)

    expect(explanation[:dependencies][:status]).to eq(:succeeded)
    expect(explanation[:dependencies][:value]).to eq(120.0)
  end
end
