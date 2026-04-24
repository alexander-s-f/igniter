#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-application/lib", __dir__))

require "igniter/application"

root = File.expand_path("../../tmp/capsule_assembly", __dir__)
incident_core = Igniter::Application.blueprint(
  name: :incident_core,
  root: File.join(root, "incident_core"),
  env: :test,
  layout_profile: :capsule,
  exports: [
    { name: :incident_runtime, kind: :service, target: "Services::IncidentRuntime" }
  ]
)
operator = Igniter::Application.capsule(:operator, root: File.join(root, "operator"), env: :test) do
  layout :capsule
  groups :contracts, :services
  export :resolve_incident, kind: :contract, target: "Contracts::ResolveIncident"
  import :incident_runtime, kind: :service, from: :incident_core
  import :audit_log, kind: :service, from: :host
  web_surface :operator_console
end

surface_metadata = {
  name: :operator_console,
  kind: :web_surface,
  status: :aligned,
  flows: [:incident_review]
}
plan = Igniter::Application.assemble_capsules(
  incident_core,
  operator,
  host_exports: [
    { name: :audit_log, kind: :service, target: "Host::AuditLog" }
  ],
  host_capabilities: [:audit],
  mount_intents: [
    { capsule: :operator, kind: :web, at: "/operator", capabilities: %i[screen stream] }
  ],
  surface_metadata: [surface_metadata]
).to_h

puts "application_capsule_assembly_capsules=#{plan.fetch(:capsules).join(",")}"
puts "application_capsule_assembly_ready=#{plan.fetch(:ready)}"
puts "application_capsule_assembly_mounts=#{plan.fetch(:mount_intents).map { |entry| "#{entry.fetch(:capsule)}:#{entry.fetch(:kind)}:#{entry.fetch(:at)}" }.join(",")}"
puts "application_capsule_assembly_composition_ready=#{plan.fetch(:composition_ready)}"
puts "application_capsule_assembly_unresolved=#{plan.fetch(:unresolved_mount_intents).map { |entry| entry.fetch(:capsule) }.join(",")}"
puts "application_capsule_assembly_surfaces=#{plan.fetch(:surfaces).map { |entry| entry.fetch(:name) }.join(",")}"
