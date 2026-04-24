#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-application/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-web/lib", __dir__))

require "igniter/application"
require "igniter/web"

web = Igniter::Web.application do
  screen :incident_review, intent: :human_decision do
    ask :clarification, as: :textarea
    action :approve_plan, run: "Contracts::ResolveIncident", action_type: :contract
  end

  screen_route "/incident-review", :incident_review
end

root = File.expand_path("../../tmp/capsule_composition", __dir__)
surface = Igniter::Web.surface_manifest(web, name: :operator_console, path: "/operator")
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
  export :operator_console,
         kind: :web_surface,
         target: surface.path,
         metadata: surface.to_capsule_export.fetch(:metadata)
  import :incident_runtime, kind: :service, from: :incident_core
  import :audit_log, kind: :service, from: :host, capabilities: [:audit]
  import :optional_notifier, kind: :service, from: :observability, optional: true
end
operator_client = Igniter::Application.blueprint(
  name: :operator_client,
  root: File.join(root, "operator_client"),
  env: :test,
  layout_profile: :capsule,
  imports: [
    { name: :operator_console, kind: :web_surface, from: :operator }
  ]
)

report = Igniter::Application.compose_capsules(
  incident_core,
  operator,
  operator_client,
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
puts "application_capsule_composition_web_exports=#{report.fetch(:exports).select { |entry| entry.fetch(:kind) == :web_surface }.map { |entry| entry.fetch(:name) }.join(",")}"
puts "application_capsule_composition_web_satisfied=#{report.fetch(:satisfied_imports).select { |entry| entry.fetch(:kind) == :web_surface }.map { |entry| entry.fetch(:name) }.join(",")}"
