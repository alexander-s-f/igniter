# frozen_string_literal: true

require_relative "../../spec_helper"

RSpec.describe Igniter::Cluster::Environment do
  def build_peer_transport(contracts_profile)
    lambda do |request:|
      result =
        case request.kind
        when :compose
          Igniter::Contracts.execute(
            request.compiled_graph,
            inputs: request.inputs,
            profile: contracts_profile
          )
        when :collection
          Igniter::Extensions::Contracts::CollectionPack::LocalInvoker.call(
            invocation: Igniter::Extensions::Contracts::CollectionPack::Invocation.new(
              operation: Igniter::Contracts::Operation.new(
                kind: :collection,
                name: request.operation_name,
                attributes: {}
              ),
              items: request.items,
              inputs: request.inputs,
              compiled_graph: request.compiled_graph,
              profile: contracts_profile,
              key_name: request.key_name,
              window: request.window
            )
          )
        else
          raise "unsupported request kind #{request.kind.inspect}"
        end

      Igniter::Application::TransportResponse.new(
        result: result,
        metadata: { adapter: :in_memory_peer }
      )
    end
  end

  it "routes compose sessions through capability-aware peers" do
    cluster = Igniter::Cluster.build_kernel(Igniter::Extensions::Contracts::ComposePack)
                              .capability(:pricing, traits: [:financial], labels: { domain: "commerce" })
                              .finalize
    cluster = described_class.new(profile: cluster)

    cluster.register_peer(
      :pricing_node,
      capabilities: %i[pricing compose],
      transport: build_peer_transport(cluster.application.profile.contracts_profile),
      metadata: { owner: :mesh },
      roles: %i[pricing compute],
      labels: { tier: "gold" },
      region: :eu_west,
      zone: :eu_west_1a
    )

    result = cluster.run(inputs: { subtotal: 100, rate: 0.2 }) do
      input :subtotal
      input :rate

      compose :pricing_total,
              inputs: { amount: :subtotal, tax_rate: :rate },
              output: :total,
              via: cluster.compose_invoker(
                capabilities: [:pricing],
                namespace: :mesh,
                metadata: { source: :cluster_spec }
              ) do
        input :amount
        input :tax_rate

        compute :total, depends_on: %i[amount tax_rate] do |amount:, tax_rate:|
          amount + (amount * tax_rate)
        end

        output :total
      end

      output :pricing_total
    end

    entry = cluster.application.fetch_session("mesh/pricing_total/1")

    expect(result.output(:pricing_total)).to eq(120.0)
    expect(entry.payload.fetch(:transport)).to include(adapter: :in_memory_peer)
    expect(entry.payload.fetch(:transport).dig(:cluster, :query, :required_capabilities)).to eq([:pricing])
    expect(entry.payload.fetch(:transport).dig(:cluster, :query, :required_capability_definitions)).to contain_exactly(
      include(name: :pricing, traits: [:financial], labels: { domain: "commerce" })
    )
    expect(entry.payload.fetch(:transport).dig(:cluster, :route, :peer)).to eq(:pricing_node)
    expect(entry.payload.fetch(:transport).dig(:cluster, :route, :mode)).to eq(:capability)
    expect(entry.payload.fetch(:transport).dig(:cluster, :route, :explanation)).to include(
      code: :capability_route,
      message: "capability route to pricing_node"
    )
    expect(entry.payload.fetch(:transport).dig(:cluster, :route, :metadata, :selected_peer_profile)).to include(
      name: :pricing_node,
      roles: %i[compute pricing],
      labels: { tier: "gold" },
      region: "eu_west",
      zone: "eu_west_1a",
      metadata: { owner: :mesh }
    )
    expect(entry.payload.fetch(:transport).dig(:cluster, :route, :metadata, :selected_peer_profile,
                                               :capability_definitions))
      .to contain_exactly(include(name: :pricing, traits: [:financial], labels: { domain: "commerce" }))
    expect(entry.payload.fetch(:transport).dig(:cluster, :admission, :reason)).to include(
      code: :permissive_accept
    )
    expect(entry.payload.fetch(:transport).dig(:cluster, :admission, :metadata, :peer_profile)).to include(
      name: :pricing_node,
      roles: %i[compute pricing]
    )
  end

  it "accepts an explicit capability query object for compose routing" do
    cluster = Igniter::Cluster.with(Igniter::Extensions::Contracts::ComposePack)
    query = Igniter::Cluster::CapabilityQuery.new(
      required_capabilities: [:pricing],
      preferred_peer: :pricing_node,
      metadata: { region: "eu-west" }
    )

    cluster.register_peer(
      :pricing_node,
      capabilities: %i[pricing compose],
      transport: build_peer_transport(cluster.application.profile.contracts_profile)
    )

    result = cluster.run(inputs: { subtotal: 100, rate: 0.2 }) do
      input :subtotal
      input :rate

      compose :pricing_total,
              inputs: { amount: :subtotal, tax_rate: :rate },
              output: :total,
              via: cluster.compose_invoker(query: query, namespace: :mesh) do
        input :amount
        input :tax_rate

        compute :total, depends_on: %i[amount tax_rate] do |amount:, tax_rate:|
          amount + (amount * tax_rate)
        end

        output :total
      end

      output :pricing_total
    end

    entry = cluster.application.fetch_session("mesh/pricing_total/1")

    expect(result.output(:pricing_total)).to eq(120.0)
    expect(entry.payload.fetch(:transport).dig(:cluster, :query)).to include(
      required_capabilities: [:pricing],
      preferred_peer: :pricing_node,
      metadata: { region: "eu-west" }
    )
    expect(entry.payload.fetch(:transport).dig(:cluster, :route, :mode)).to eq(:pinned)
    expect(entry.payload.fetch(:transport).dig(:cluster, :route, :explanation)).to include(
      code: :pinned_route
    )
  end

  it "routes collection sessions through a pinned peer" do
    cluster = Igniter::Cluster.with(Igniter::Extensions::Contracts::CollectionPack)

    cluster.register_peer(
      :batch_node,
      capabilities: %i[pricing collection],
      transport: build_peer_transport(cluster.application.profile.contracts_profile)
    )

    result = cluster.run(
      inputs: {
        items: [
          { sku: "a", amount: 10 },
          { sku: "b", amount: 20 }
        ],
        tax_rate: 0.2
      }
    ) do
      input :items
      input :tax_rate

      collection :priced_items,
                 from: :items,
                 key: :sku,
                 inputs: { tax_rate: :tax_rate },
                 via: cluster.collection_invoker(peer: :batch_node, namespace: :mesh) do
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

    entry = cluster.application.fetch_session("mesh/priced_items/1")

    expect(result.output(:priced_items).fetch("b").output(:total)).to eq(24.0)
    expect(entry.payload.fetch(:transport).dig(:cluster, :route, :peer)).to eq(:batch_node)
    expect(entry.payload.fetch(:transport).dig(:cluster, :route, :mode)).to eq(:pinned)
  end

  it "supports declarative route policies on the cluster kernel" do
    cluster = Igniter::Cluster.build_kernel(Igniter::Extensions::Contracts::ComposePack)
                              .route_policy(:loose, require_capabilities: false)
                              .finalize
    environment = described_class.new(profile: cluster)
    environment.register_peer(
      :fallback_node,
      capabilities: [:compose],
      transport: build_peer_transport(environment.application.profile.contracts_profile)
    )
    environment.register_peer(
      :pricing_node,
      capabilities: %i[pricing compose],
      transport: build_peer_transport(environment.application.profile.contracts_profile)
    )

    result = environment.run(inputs: { subtotal: 100, rate: 0.2 }) do
      input :subtotal
      input :rate

      compose :pricing_total,
              inputs: { amount: :subtotal, tax_rate: :rate },
              output: :total,
              via: environment.compose_invoker(
                capabilities: [:pricing],
                namespace: :mesh
              ) do
        input :amount
        input :tax_rate
        compute :total, depends_on: %i[amount tax_rate] do |amount:, tax_rate:|
          amount + (amount * tax_rate)
        end
        output :total
      end

      output :pricing_total
    end

    entry = environment.application.fetch_session("mesh/pricing_total/1")

    expect(result.output(:pricing_total)).to eq(120.0)
    expect(entry.payload.fetch(:transport).dig(:cluster, :route, :peer)).to eq(:fallback_node)
    expect(entry.payload.fetch(:transport).dig(:cluster, :route, :mode)).to eq(:capability)
    expect(entry.payload.fetch(:transport).dig(:cluster, :route, :metadata, :policy)).to include(
      name: :loose,
      require_capabilities: false
    )
  end

  it "supports declarative placement policies on the cluster kernel" do
    cluster = Igniter::Cluster.build_kernel(Igniter::Extensions::Contracts::ComposePack)
                              .route_policy(:loose, require_capabilities: false)
                              .placement_policy(:targeted, filter_capabilities: true, candidate_limit: 1)
                              .finalize
    environment = described_class.new(profile: cluster)
    environment.register_peer(
      :fallback_node,
      capabilities: [:compose],
      transport: build_peer_transport(environment.application.profile.contracts_profile)
    )
    environment.register_peer(
      :pricing_node,
      capabilities: %i[pricing compose],
      transport: build_peer_transport(environment.application.profile.contracts_profile)
    )

    result = environment.run(inputs: { subtotal: 100, rate: 0.2 }) do
      input :subtotal
      input :rate

      compose :pricing_total,
              inputs: { amount: :subtotal, tax_rate: :rate },
              output: :total,
              via: environment.compose_invoker(capabilities: [:pricing], namespace: :mesh) do
        input :amount
        input :tax_rate
        compute :total, depends_on: %i[amount tax_rate] do |amount:, tax_rate:|
          amount + (amount * tax_rate)
        end
        output :total
      end

      output :pricing_total
    end

    entry = environment.application.fetch_session("mesh/pricing_total/1")

    expect(result.output(:pricing_total)).to eq(120.0)
    expect(entry.payload.fetch(:transport).dig(:cluster, :placement, :mode)).to eq(:capability_filtered)
    expect(entry.payload.fetch(:transport).dig(:cluster, :placement, :candidates)).to eq([:pricing_node])
    expect(entry.payload.fetch(:transport).dig(:cluster, :placement, :metadata, :candidate_profiles)).to contain_exactly(
      include(name: :pricing_node, capabilities: %i[compose pricing])
    )
    expect(entry.payload.fetch(:transport).dig(:cluster, :placement, :metadata, :policy)).to include(
      name: :targeted,
      filter_capabilities: true,
      candidate_limit: 1
    )
    expect(entry.payload.fetch(:transport).dig(:cluster, :route, :peer)).to eq(:pricing_node)
  end

  it "routes and places using richer query intent over traits, labels, and zone" do
    cluster = Igniter::Cluster.build_kernel(Igniter::Extensions::Contracts::ComposePack)
                              .capability(:pricing, traits: [:financial], labels: { domain: "commerce" })
                              .placement_policy(:targeted, filter_capabilities: true)
                              .finalize
    environment = described_class.new(profile: cluster)
    environment.register_peer(
      :fallback_node,
      capabilities: %i[pricing compose],
      labels: { tier: "silver" },
      region: :eu_west,
      zone: :eu_west_1b,
      transport: build_peer_transport(environment.application.profile.contracts_profile)
    )
    environment.register_peer(
      :pricing_node,
      capabilities: %i[pricing compose],
      labels: { tier: "gold" },
      region: :eu_west,
      zone: :eu_west_1a,
      transport: build_peer_transport(environment.application.profile.contracts_profile)
    )

    result = environment.run(inputs: { subtotal: 100, rate: 0.2 }) do
      input :subtotal
      input :rate

      compose :pricing_total,
              inputs: { amount: :subtotal, tax_rate: :rate },
              output: :total,
              via: environment.compose_invoker(
                capabilities: [:pricing],
                traits: [:financial],
                labels: { tier: "gold" },
                region: :eu_west,
                zone: :eu_west_1a,
                namespace: :mesh
              ) do
        input :amount
        input :tax_rate
        compute :total, depends_on: %i[amount tax_rate] do |amount:, tax_rate:|
          amount + (amount * tax_rate)
        end
        output :total
      end

      output :pricing_total
    end

    entry = environment.application.fetch_session("mesh/pricing_total/1")

    expect(result.output(:pricing_total)).to eq(120.0)
    expect(entry.payload.fetch(:transport).dig(:cluster, :query)).to include(
      required_capabilities: [:pricing],
      required_traits: [:financial],
      required_labels: { tier: "gold" },
      preferred_region: "eu_west",
      preferred_zone: "eu_west_1a"
    )
    expect(entry.payload.fetch(:transport).dig(:cluster, :placement, :mode)).to eq(:capability_filtered)
    expect(entry.payload.fetch(:transport).dig(:cluster, :placement, :candidates)).to eq([:pricing_node])
    expect(entry.payload.fetch(:transport).dig(:cluster, :route, :peer)).to eq(:pricing_node)
    expect(entry.payload.fetch(:transport).dig(:cluster, :route, :explanation)).to include(
      code: :intent_route
    )
  end

  it "surfaces admission failures before transport dispatch" do
    denying_admission = Class.new do
      def admit(request:, route:)
        Igniter::Cluster::AdmissionResult.denied(
          code: :policy_denied,
          metadata: { peer: route.peer.name },
          reason: Igniter::Cluster::DecisionExplanation.new(
            code: :policy_denied,
            message: "policy rejected #{request.session_id}",
            metadata: { peer: route.peer.name }
          )
        )
      end
    end.new

    cluster = Igniter::Cluster.build_kernel(Igniter::Extensions::Contracts::ComposePack)
                              .admission(:strict, seam: denying_admission)
                              .finalize
    environment = described_class.new(profile: cluster)
    environment.register_peer(
      :pricing_node,
      capabilities: %i[pricing compose],
      transport: build_peer_transport(environment.application.profile.contracts_profile)
    )

    expect do
      environment.run(inputs: { subtotal: 100, rate: 0.2 }) do
        input :subtotal
        input :rate

        compose :pricing_total,
                inputs: { amount: :subtotal, tax_rate: :rate },
                output: :total,
                via: environment.compose_invoker(capabilities: [:pricing], namespace: :mesh) do
          input :amount
          input :tax_rate
          compute :total, depends_on: %i[amount tax_rate] do |amount:, tax_rate:|
            amount + (amount * tax_rate)
          end
          output :total
        end

        output :pricing_total
      end
    end.to raise_error(Igniter::Cluster::AdmissionError, /policy_denied/)
  end

  it "supports declarative admission policies on the cluster kernel" do
    cluster = Igniter::Cluster.build_kernel(Igniter::Extensions::Contracts::ComposePack)
                              .admission_policy(:restricted, blocked_peers: [:pricing_node])
                              .finalize
    environment = described_class.new(profile: cluster)
    environment.register_peer(
      :pricing_node,
      capabilities: %i[pricing compose],
      transport: build_peer_transport(environment.application.profile.contracts_profile)
    )

    expect do
      environment.run(inputs: { subtotal: 100, rate: 0.2 }) do
        input :subtotal
        input :rate

        compose :pricing_total,
                inputs: { amount: :subtotal, tax_rate: :rate },
                output: :total,
                via: environment.compose_invoker(capabilities: [:pricing], namespace: :mesh) do
          input :amount
          input :tax_rate
          compute :total, depends_on: %i[amount tax_rate] do |amount:, tax_rate:|
            amount + (amount * tax_rate)
          end
          output :total
        end

        output :pricing_total
      end
    end.to raise_error(Igniter::Cluster::AdmissionError, /blocked_peer/)
  end

  it "finalizes cluster profiles over application profiles and peers" do
    cluster = Igniter::Cluster.build_kernel(Igniter::Extensions::Contracts::ComposePack)
    cluster.register_peer(
      :pricing_node,
      capabilities: [:pricing],
      transport: build_peer_transport(cluster.application_kernel.finalize.contracts_profile)
    )
    profile = cluster.finalize

    expect(profile.to_h).to include(
      transport: :direct,
      router: :capability,
      route_policy: include(name: :capability),
      admission: :permissive,
      admission_policy: include(name: :permissive),
      placement: :direct,
      placement_policy: include(name: :direct),
      peer_registry: :memory
    )
    expect(profile.to_h.fetch(:capability_catalog)).to eq(definitions: [])
    expect(profile.to_h.fetch(:application_profile).fetch(:contracts_packs)).to include("Igniter::Extensions::Contracts::ComposePack")
    expect(profile.to_h.fetch(:peers)).to contain_exactly(
      include(
        name: :pricing_node,
        capabilities: [:pricing],
        capability_definitions: [],
        roles: [],
        labels: {},
        region: nil,
        zone: nil
      )
    )
  end
end
