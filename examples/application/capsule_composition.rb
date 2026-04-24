#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-application/lib", __dir__))

require "igniter/application"

root = File.expand_path("../../tmp/capsule_composition", __dir__)
incident_core = Igniter::Application.blueprint(
  name: :incident_core,
  root: File.join(root, "incident_core"),
  env: :test,
  layout_profile: :capsule,
  groups: %i[contracts services],
  exports: [
    { name: :incident_runtime, kind: :service, target: "Services::IncidentRuntime" }
  ]
)
operator = Igniter::Application.capsule(:operator, root: File.join(root, "operator"), env: :test) do
  layout :capsule
  groups :contracts, :services
  export :resolve_incident, kind: :contract, target: "Contracts::ResolveIncident"
  import :incident_runtime, kind: :service, from: :incident_core
  import :audit_log, kind: :service, from: :host, capabilities: [:audit]
  import :optional_notifier, kind: :service, from: :observability, optional: true
end

report = Igniter::Application.compose_capsules(
  incident_core,
  operator,
  host_exports: [
    { name: :audit_log, kind: :service, target: "Host::AuditLog" }
  ],
  host_capabilities: [:audit]
).to_h

puts "application_capsule_composition_capsules=#{report.fetch(:capsules).map { |entry| entry.fetch(:name) }.join(",")}"
puts "application_capsule_composition_exports=#{report.fetch(:exports).map { |entry| entry.fetch(:name) }.join(",")}"
puts "application_capsule_composition_satisfied=#{report.fetch(:satisfied_imports).map { |entry| entry.fetch(:name) }.join(",")}"
puts "application_capsule_composition_host_satisfied=#{report.fetch(:host_satisfied_imports).map { |entry| entry.fetch(:name) }.join(",")}"
puts "application_capsule_composition_unresolved=#{report.fetch(:unresolved_required_imports).map { |entry| entry.fetch(:name) }.join(",")}"
puts "application_capsule_composition_optional_missing=#{report.fetch(:missing_optional_imports).map { |entry| entry.fetch(:name) }.join(",")}"
puts "application_capsule_composition_ready=#{report.fetch(:ready)}"
