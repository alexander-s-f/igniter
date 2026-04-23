#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-application/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-cluster/lib", __dir__))

require "igniter/cluster"

cluster = Igniter::Cluster.with(Igniter::Extensions::Contracts::ComposePack)

peer_transport = lambda do |request:|
  result = Igniter::Contracts.execute(
    request.compiled_graph,
    inputs: request.inputs,
    profile: cluster.application.profile.contracts_profile
  )

  Igniter::Application::TransportResponse.new(
    result: result,
    metadata: { adapter: :in_memory_peer, target: :pricing_node }
  )
end

cluster.register_peer(
  :pricing_node,
  capabilities: %i[pricing compose],
  transport: peer_transport,
  metadata: { zone: "eu-west" }
)

query = Igniter::Cluster::CapabilityQuery.new(
  required_capabilities: [:pricing],
  metadata: { region: "eu-west" }
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

puts "cluster_compose_total=#{result.output(:pricing_total)}"
puts "cluster_query_capabilities=#{entry.payload.fetch(:transport).dig(:cluster, :query, :required_capabilities).inspect}"
puts "cluster_route_peer=#{entry.payload.fetch(:transport).dig(:cluster, :route, :peer)}"
puts "cluster_route_mode=#{entry.payload.fetch(:transport).dig(:cluster, :route, :mode)}"
