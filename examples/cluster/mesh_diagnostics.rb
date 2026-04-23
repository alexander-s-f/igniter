#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-application/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-cluster/lib", __dir__))

require "igniter/cluster"

accepting_transport = lambda do |request:|
  Igniter::Cluster::MeshExecutionResponse.new(
    status: :completed,
    metadata: {
      accepted_by: request.metadata.fetch(:peer).fetch(:name),
      trace_id: request.trace_id
    },
    explanation: Igniter::Cluster::DecisionExplanation.new(
      code: :mesh_peer_accept,
      message: "mesh peer accepted #{request.plan_kind}",
      metadata: { peer: request.metadata.fetch(:peer).fetch(:name) }
    )
  )
end

failing_transport = lambda do |request:|
  Igniter::Cluster::MeshExecutionResponse.new(
    status: :failed,
    metadata: {
      rejected_by: request.metadata.fetch(:peer).fetch(:name),
      trace_id: request.trace_id
    },
    explanation: Igniter::Cluster::DecisionExplanation.new(
      code: :mesh_peer_reject,
      message: "mesh peer rejected #{request.plan_kind}",
      metadata: { peer: request.metadata.fetch(:peer).fetch(:name) }
    )
  )
end

profile = Igniter::Cluster.build_kernel(Igniter::Extensions::Contracts::ComposePack)
                          .capability(:pricing, traits: [:financial], labels: { domain: "commerce" })
                          .topology_policy(
                            :locality,
                            required_labels: { tier: "gold" },
                            preferred_zone: :eu_west_1a
                          )
                          .ownership_policy(:distributed, owner_limit: 1)
                          .finalize

environment = Igniter::Cluster::Environment.new(profile: profile)

environment.register_peer(
  :pricing_node_a,
  capabilities: %i[pricing compose],
  labels: { tier: "gold" },
  region: :eu_west,
  zone: :eu_west_1a,
  transport: failing_transport
)
environment.register_peer(
  :pricing_node_b,
  capabilities: %i[pricing compose],
  labels: { tier: "gold" },
  region: :eu_west,
  zone: :eu_west_1a,
  transport: accepting_transport
)

plan = environment.plan_ownership(target: "order-42", capabilities: [:pricing], traits: [:financial])
report = environment.execute_plan_via_mesh(
  plan,
  executor: environment.mesh_executor(
    retry_policy: Igniter::Cluster::MeshRetryPolicy.new(name: :fallback, max_attempts: 2)
  ),
  metadata: { source: :example }
)

mesh = report.action_results.first.metadata.fetch(:mesh)
attempts = mesh.fetch(:attempts)
diagnostics = mesh.dig(:metadata, :diagnostics_report)

puts "cluster_mesh_plan_kind=#{report.plan_kind}"
puts "cluster_mesh_status=#{report.status}"
puts "cluster_mesh_attempts=#{attempts.map { |attempt| "#{attempt.fetch(:peer)}:#{attempt.fetch(:status)}" }.join(",")}"
puts "cluster_mesh_projection_mode=#{mesh.dig(:metadata, :candidate_projection_report, :mode)}"
puts "cluster_mesh_diagnostics_events=#{diagnostics.dig(:event_log, :events).map { |event| event.fetch(:kind) }.join(",")}"
puts "cluster_mesh_trace_id=#{mesh.fetch(:trace_id)}"
