#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-application/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-cluster/lib", __dir__))

require "igniter/cluster"

noop_transport = lambda do |request:|
  Igniter::Application::TransportResponse.new(
    result: request,
    metadata: { adapter: :noop_peer }
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
                          .health_policy(:availability_aware, trigger_statuses: [:unhealthy])
                          .finalize

environment = Igniter::Cluster::Environment.new(profile: profile)

environment.register_peer(
  :fallback_node,
  capabilities: %i[pricing compose],
  labels: { tier: "silver" },
  region: :eu_west,
  zone: :eu_west_1b,
  health_status: :unhealthy,
  transport: noop_transport
)
environment.register_peer(
  :pricing_node,
  capabilities: %i[pricing compose],
  labels: { tier: "gold" },
  region: :eu_west,
  zone: :eu_west_1a,
  transport: noop_transport
)

plan = environment.plan_failover(target: "order-42", capabilities: [:pricing], traits: [:financial])
environment.execute_failover_plan(plan) do
  raise "simulated failover failure"
end

environment.acknowledge_incident("degraded_health/1", actor: :operator, note: "triaged")
environment.assign_incident("degraded_health/1", assignee: :sre, actor: :operator)
environment.silence_incident("degraded_health/1", actor: :operator, metadata: { minutes: 15 })

workflow_before_resolution = environment.incident_workflow("degraded_health/1")
active_before_resolution = environment.active_incidents.count

environment.resolve_incident("degraded_health/1", actor: :operator, note: "manual recovery confirmed")

workflow_after_resolution = environment.incident_workflow("degraded_health/1")

puts "cluster_incident_workflow_before=#{workflow_before_resolution.state}"
puts "cluster_incident_workflow_actions=#{workflow_after_resolution.action_kinds.join(",")}"
puts "cluster_incident_workflow_active_before=#{active_before_resolution}"
puts "cluster_incident_workflow_after=#{workflow_after_resolution.state}"
puts "cluster_incident_workflow_active_after=#{environment.active_incidents.count}"
