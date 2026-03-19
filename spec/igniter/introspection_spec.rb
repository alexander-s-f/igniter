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
    expect(text).to include("compute gross_total depends_on=order_total,vat_rate callable=proc")
    expect(text).to include("output.gross_total -> gross_total")
  end

  it "formats compiled graph as mermaid" do
    mermaid = contract_class.graph.to_mermaid

    expect(mermaid).to include("graph TD")
    expect(mermaid).to include('node_order_total["input: order_total"]')
    expect(mermaid).to include('node_vat_rate --> node_gross_total')
    expect(mermaid).to include('node_gross_total["compute: gross_total\nproc"]')
    expect(mermaid).to include('node_gross_total --> output_gross_total')
  end

  it "returns normalized runtime states" do
    contract = contract_class.new(order_total: 100, country: "UA")
    contract.result.gross_total

    states = contract.result.states

    expect(states[:gross_total]).to include(
      id: contract.execution.compiled_graph.fetch_node(:gross_total).id,
      path: "gross_total",
      kind: :compute,
      status: :succeeded,
      value: 120.0
    )
  end

  it "includes invalidation details in runtime states" do
    contract = contract_class.new(order_total: 100, country: "UA")
    contract.result.gross_total
    contract.update_inputs(order_total: 150)

    states = contract.execution.states

    expect(states[:gross_total][:invalidated_by]).to eq(
      node_id: contract.execution.compiled_graph.fetch_node(:order_total).id,
      node_name: :order_total,
      node_path: "order_total"
    )
  end

  it "explains output dependency resolution" do
    contract = contract_class.new(order_total: 100, country: "UA")

    explanation = contract.result.explain(:gross_total)

    expect(explanation[:output_id]).to eq(contract.execution.compiled_graph.fetch_output(:gross_total).id)
    expect(explanation[:output]).to eq(:gross_total)
    expect(explanation[:source_id]).to eq(contract.execution.compiled_graph.fetch_node(:gross_total).id)
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

  it "builds a machine-readable execution plan with ready and blocked nodes" do
    contract = contract_class.new(order_total: 100, country: "UA")

    plan = contract.execution.plan

    expect(plan[:targets]).to eq([:gross_total])
    expect(plan[:ready]).to include(:order_total, :country, :vat_rate)
    expect(plan[:blocked]).to include(:gross_total)
    expect(plan[:nodes][:gross_total][:waiting_on]).to include(:vat_rate)
  end

  it "preserves scoped paths in plans and graph formatting" do
    contract_class = Class.new(Igniter::Contract) do
      define do
        input :country, type: :string

        scope :taxes do
          compute :vat_rate, with: :country do |country:|
            country == "UA" ? 0.2 : 0.0
          end
        end

        output :vat_rate
      end
    end

    contract = contract_class.new(country: "UA")

    expect(contract.class.graph.to_text).to include("taxes.vat_rate")
    expect(contract.execution.plan[:nodes][:vat_rate][:path]).to eq("taxes.vat_rate")
  end

  it "explains the execution plan without resolving compute nodes" do
    calls = 0

    contract_class = Class.new(Igniter::Contract) do
      define do
        input :order_total, type: :numeric
        input :country, type: :string

        compute :vat_rate, depends_on: [:country] do |country:|
          calls += 1
          country == "UA" ? 0.2 : 0.0
        end

        compute :gross_total, depends_on: %i[order_total vat_rate] do |order_total:, vat_rate:|
          calls += 1
          order_total * (1 + vat_rate)
        end

        output :gross_total
      end
    end

    contract = contract_class.new(order_total: 100, country: "UA")

    explanation = contract.explain_plan

    expect(explanation).to include("Plan AnonymousContract")
    expect(explanation).to include("Targets: gross_total")
    expect(explanation).to include("Ready: order_total,country,vat_rate")
    expect(explanation).to include("Blocked: gross_total")
    expect(explanation).to include("compute gross_total")
    expect(explanation).to include("waiting_on=vat_rate")
    expect(calls).to eq(0)
    expect(contract.events).to be_empty
  end
end
