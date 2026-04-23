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
    expect(entry.status).to eq(:completed)
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
    expect(entry.status).to eq(:completed)
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

  it "exposes application-owned compose invokers for contracts via:" do
    environment = Igniter::Application.with(Igniter::Extensions::Contracts::ComposePack)

    result = environment.run(inputs: { subtotal: 100, rate: 0.2 }) do
      input :subtotal
      input :rate

      compose :pricing_total,
              inputs: { amount: :subtotal, tax_rate: :rate },
              output: :total,
              via: environment.compose_invoker(namespace: :quotes, metadata: { source: :dsl }) do
        input :amount
        input :tax_rate

        compute :total, depends_on: %i[amount tax_rate] do |amount:, tax_rate:|
          amount + (amount * tax_rate)
        end

        output :total
      end

      output :pricing_total
    end

    entry = environment.fetch_session("quotes/pricing_total/1")

    expect(result.output(:pricing_total)).to eq(120.0)
    expect(entry.kind).to eq(:compose)
    expect(entry.status).to eq(:completed)
    expect(entry.metadata).to include(namespace: "quotes", source: :dsl, session_id: "quotes/pricing_total/1")
  end

  it "exposes application-owned collection invokers for contracts via:" do
    environment = Igniter::Application.with(Igniter::Extensions::Contracts::CollectionPack)

    result = environment.run(inputs: {
      items: [
        { sku: "a", amount: 10 },
        { sku: "b", amount: 20 }
      ],
      tax_rate: 0.2
    }) do
      input :items
      input :tax_rate

      collection :priced_items,
                 from: :items,
                 key: :sku,
                 inputs: { tax_rate: :tax_rate },
                 via: environment.collection_invoker(namespace: :quotes, metadata: { source: :dsl }) do
        input :sku
        input :amount
        input :tax_rate

        compute :total, depends_on: %i[amount tax_rate] do |amount:, tax_rate:|
          amount + (amount * tax_rate)
        end

        output :total
      end

      output :priced_items
    end

    entry = environment.fetch_session("quotes/priced_items/1")

    expect(result.output(:priced_items).fetch("a").output(:total)).to eq(12.0)
    expect(entry.kind).to eq(:collection)
    expect(entry.status).to eq(:completed)
    expect(entry.metadata).to include(namespace: "quotes", source: :dsl, session_id: "quotes/priced_items/1")
  end

  it "records failed compose sessions in the session store" do
    environment = Igniter::Application.with(Igniter::Extensions::Contracts::ComposePack)
    graph = environment.compile do
      input :amount
      output :amount
    end

    expect do
      environment.run_compose_session(
        session_id: "pricing/failure",
        compiled_graph: graph,
        inputs: { amount: 10 },
        invoker: ->(invocation:) { raise "transport unavailable for #{invocation.operation.name}" }
      )
    end.to raise_error(RuntimeError, /transport unavailable/)

    entry = environment.fetch_session("pricing/failure")

    expect(entry.status).to eq(:failed)
    expect(entry.payload.fetch(:error)).to include(
      class: "RuntimeError",
      message: "transport unavailable for pricing/failure"
    )
  end

  it "builds transport-ready remote compose invokers" do
    environment = Igniter::Application.with(Igniter::Extensions::Contracts::ComposePack)
    requests = []
    transport = lambda do |request:|
      requests << request
      result = Igniter::Contracts.execute(
        request.compiled_graph,
        inputs: request.inputs,
        profile: environment.profile.contracts_profile
      )
      Igniter::Application::TransportResponse.new(
        result: result,
        metadata: { adapter: :stub_remote, target: "node-a" }
      )
    end

    result = environment.run(inputs: { subtotal: 50, rate: 0.1 }) do
      input :subtotal
      input :rate

      compose :pricing_total,
              inputs: { amount: :subtotal, tax_rate: :rate },
              output: :total,
              via: environment.remote_compose_invoker(transport: transport, namespace: :mesh) do
        input :amount
        input :tax_rate
        compute :total, depends_on: %i[amount tax_rate] do |amount:, tax_rate:|
          amount + (amount * tax_rate)
        end
        output :total
      end

      output :pricing_total
    end

    entry = environment.fetch_session("mesh/pricing_total/1")

    expect(result.output(:pricing_total)).to eq(55.0)
    expect(requests.length).to eq(1)
    expect(requests.first).to be_a(Igniter::Application::TransportRequest)
    expect(requests.first.kind).to eq(:compose)
    expect(requests.first.session_id).to eq("mesh/pricing_total/1")
    expect(entry.payload.fetch(:transport)).to eq(adapter: :stub_remote, target: "node-a")
  end

  it "builds transport-ready remote collection invokers" do
    environment = Igniter::Application.with(Igniter::Extensions::Contracts::CollectionPack)
    requests = []
    transport = lambda do |request:|
      requests << request
      result = Igniter::Extensions::Contracts::CollectionPack::LocalInvoker.call(
        invocation: Igniter::Extensions::Contracts::CollectionPack::Invocation.new(
          operation: Igniter::Contracts::Operation.new(kind: :collection, name: request.operation_name, attributes: {}),
          items: request.items,
          inputs: request.inputs,
          compiled_graph: request.compiled_graph,
          profile: environment.profile.contracts_profile,
          key_name: request.key_name,
          window: request.window
        )
      )
      Igniter::Application::TransportResponse.new(
        result: result,
        metadata: { adapter: :stub_remote, target: "node-b" }
      )
    end

    result = environment.run(inputs: {
      items: [
        { sku: "a", amount: 10 },
        { sku: "b", amount: 20 }
      ],
      tax_rate: 0.2
    }) do
      input :items
      input :tax_rate

      collection :priced_items,
                 from: :items,
                 key: :sku,
                 inputs: { tax_rate: :tax_rate },
                 via: environment.remote_collection_invoker(transport: transport, namespace: :mesh) do
        input :sku
        input :amount
        input :tax_rate
        compute :total, depends_on: %i[amount tax_rate] do |amount:, tax_rate:|
          amount + (amount * tax_rate)
        end
        output :total
      end

      output :priced_items
    end

    entry = environment.fetch_session("mesh/priced_items/1")

    expect(result.output(:priced_items).fetch("b").output(:total)).to eq(24.0)
    expect(requests.length).to eq(1)
    expect(requests.first.kind).to eq(:collection)
    expect(requests.first.session_id).to eq("mesh/priced_items/1")
    expect(requests.first.key_name).to eq(:sku)
    expect(entry.payload.fetch(:transport)).to eq(adapter: :stub_remote, target: "node-b")
  end
end
