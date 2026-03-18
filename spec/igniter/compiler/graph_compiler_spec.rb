# frozen_string_literal: true

require "spec_helper"

RSpec.describe Igniter::Compiler::GraphCompiler do
  it "compiles a graph with deterministic resolution order" do
    graph = Igniter::Model::Graph.new(
      name: "PriceGraph",
      nodes: [
        Igniter::Model::InputNode.new(id: "1", name: :country),
        Igniter::Model::InputNode.new(id: "2", name: :order_total),
        Igniter::Model::ComputeNode.new(id: "3", name: :vat_rate, dependencies: [:country], callable: ->(country:) { country == "UA" ? 0.2 : 0.0 }),
        Igniter::Model::ComputeNode.new(id: "4", name: :gross_total, dependencies: %i[order_total vat_rate], callable: ->(order_total:, vat_rate:) { order_total * (1 + vat_rate) }),
        Igniter::Model::OutputNode.new(id: "5", name: :gross_total, source: :gross_total)
      ]
    )

    compiled = described_class.call(graph)

    expect(compiled.outputs.map(&:name)).to eq([:gross_total])
    expect(compiled.resolution_order.map(&:name)).to eq(%i[country order_total vat_rate gross_total])
  end

  it "raises on missing dependencies" do
    graph = Igniter::Model::Graph.new(
      name: "BrokenGraph",
      nodes: [
        Igniter::Model::ComputeNode.new(id: "1", name: :gross_total, dependencies: [:vat_rate], callable: ->(vat_rate:) { vat_rate }),
        Igniter::Model::OutputNode.new(id: "2", name: :gross_total, source: :gross_total)
      ]
    )

    expect { described_class.call(graph) }
      .to raise_error(Igniter::ValidationError, /Unknown dependency 'vat_rate'/)
  end

  it "raises on duplicate output names" do
    graph = Igniter::Model::Graph.new(
      name: "BrokenGraph",
      nodes: [
        Igniter::Model::InputNode.new(id: "1", name: :country),
        Igniter::Model::OutputNode.new(id: "2", name: :country, source: :country),
        Igniter::Model::OutputNode.new(id: "3", name: :country, source: :country)
      ]
    )

    expect { described_class.call(graph) }
      .to raise_error(Igniter::ValidationError, /Duplicate output name: country/)
  end

  it "includes source location in validation errors for DSL-defined graphs" do
    expect do
      Igniter.compile do
        compute :gross_total, depends_on: [:missing_dep] do |missing_dep:|
          missing_dep
        end
        output :gross_total
      end
    end.to raise_error(Igniter::ValidationError, /declared at .*graph_compiler_spec\.rb/)
  end
end
