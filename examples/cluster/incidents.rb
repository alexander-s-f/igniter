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
failed_report = environment.execute_failover_plan(plan) do
  raise "peer write failed"
end
resolved_report = environment.execute_failover_plan(plan)
last_entry = environment.incidents.last

puts "cluster_incident_plan_targets=#{plan.targets.join(",")}"
puts "cluster_incident_failed_status=#{failed_report.status}"
puts "cluster_active_incidents_before=#{environment.incidents.first.active? ? 1 : 0}"
puts "cluster_incident_history=#{environment.incidents.size}"
puts "cluster_incident_resolved_status=#{resolved_report.status}"
puts "cluster_incident_last_resolution=#{last_entry.resolution}"
puts "cluster_active_incidents_after=#{environment.active_incidents.count}"
