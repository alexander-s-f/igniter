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
                          .remediation_policy(:default)
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

incident_plan = environment.plan_failover(target: "order-42", capabilities: [:pricing], traits: [:financial])
environment.execute_failover_plan(incident_plan) do
  raise "simulated failover failure"
end

remediation_plan = environment.plan_remediation
remediation_report = environment.execute_remediation_plan(remediation_plan)

puts "cluster_remediation_mode=#{remediation_plan.mode}"
puts "cluster_remediation_steps=#{remediation_plan.steps.length}"
puts "cluster_remediation_actions=#{remediation_plan.action_kinds.join(",")}"
puts "cluster_remediation_target=#{remediation_plan.targets.join(",")}"
puts "cluster_remediation_status=#{remediation_report.status}"
