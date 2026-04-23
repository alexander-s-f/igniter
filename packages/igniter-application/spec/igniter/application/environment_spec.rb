# frozen_string_literal: true

require_relative "../../spec_helper"

RSpec.describe Igniter::Application::Environment do
  it "persists compose sessions through the application session store" do
    environment = Igniter::Application.with(Igniter::Extensions::Contracts::ComposePack)
    pricing_graph = environment.compile do
      input :amount
      input :tax_rate

      compute :total, depends_on: %i[amount tax_rate] do |amount:, tax_rate:|
        amount + (amount * tax_rate)
      end

      output :total
    end

    result = environment.run_compose_session(
      session_id: "pricing/1",
      compiled_graph: pricing_graph,
      inputs: { amount: 100, tax_rate: 0.2 },
      metadata: { origin: :quote_preview }
    )
    entry = environment.fetch_session("pricing/1")

    expect(result.output(:total)).to eq(120.0)
    expect(entry.kind).to eq(:compose)
    expect(entry.metadata).to include(origin: :quote_preview)
    expect(entry.payload).to include(
      inputs: { amount: 100, tax_rate: 0.2 },
      outputs: { total: 120.0 },
      output_names: [:total]
    )
    expect(environment.snapshot.to_h.fetch(:runtime).fetch(:session_count)).to eq(1)
  end

  it "persists collection sessions through the application session store" do
    environment = Igniter::Application.with(Igniter::Extensions::Contracts::CollectionPack)
    item_graph = environment.compile do
      input :sku
      input :amount
      input :tax_rate

      compute :total, depends_on: %i[amount tax_rate] do |amount:, tax_rate:|
        amount + (amount * tax_rate)
      end

      output :total
    end

    result = environment.run_collection_session(
      session_id: "pricing-collection/1",
      items: [
        { sku: "a", amount: 10 },
        { sku: "b", amount: 20 }
      ],
      compiled_graph: item_graph,
      key: :sku,
      inputs: { tax_rate: 0.2 },
      metadata: { origin: :quote_batch }
    )
    entry = environment.fetch_session("pricing-collection/1")

    expect(result.keys).to eq(%w[a b])
    expect(result.fetch("b").output(:total)).to eq(24.0)
    expect(entry.kind).to eq(:collection)
    expect(entry.metadata).to include(origin: :quote_batch, key: :sku)
    expect(entry.payload).to include(
      inputs: { tax_rate: 0.2 },
      item_count: 2,
      keys: %w[a b]
    )
    expect(entry.payload.fetch(:summary)).to include(total: 2, added: 2)
  end

  it "allows replacing the default session store seam" do
    custom_store = Class.new do
      attr_reader :written

      def initialize
        @written = {}
      end

      def write(entry)
        @written[entry.id] = entry
        entry
      end

      def fetch(id)
        @written.fetch(id.to_s)
      end

      def entries
        @written.values.sort_by(&:id)
      end
    end.new

    profile = Igniter::Application.build_kernel(Igniter::Extensions::Contracts::ComposePack)
                                  .session_store(:custom, seam: custom_store)
                                  .finalize

    expect(profile.session_store_name).to eq(:custom)
    expect(profile.to_h.fetch(:session_store)).to eq(:custom)

    environment = described_class.new(profile: profile)
    graph = environment.compile do
      input :amount
      output :amount
    end
    environment.run_compose_session(
      session_id: "manual/1",
      compiled_graph: graph,
      inputs: { amount: 10 },
      metadata: { source: :manual_spec }
    )

    expect(custom_store.fetch("manual/1").payload).to include(outputs: { amount: 10 })
  end
end
