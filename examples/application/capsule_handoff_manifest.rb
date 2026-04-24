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

root = File.expand_path("../../tmp/capsule_handoff", __dir__)
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
  import :audit_log, kind: :service, from: :host, capabilities: [:audit]
  web_surface :operator_console
end
web_mount = Igniter::Web.mount(:operator_console, path: "/operator", application: web)
surface = Igniter::Web.surface_manifest(web, name: :operator_console, path: web_mount.path)
surface_metadata = Igniter::Web.surface_metadata(surface)
ready_manifest = Igniter::Application.handoff_manifest(
  subject: :operator_bundle,
  capsules: [incident_core, operator],
  host_exports: [
    { name: :audit_log, kind: :service, target: "Host::AuditLog" }
  ],
  host_capabilities: [:audit],
  mount_intents: [
    {
      capsule: :operator,
      kind: :web,
      at: web_mount.path,
      capabilities: %i[screen stream],
      metadata: { surface: surface.name }
    }
  ],
  surface_metadata: [surface_metadata]
).to_h
missing_manifest = Igniter::Application.handoff_manifest(
  subject: :operator_bundle_missing_host,
  capsules: [incident_core, operator],
  mount_intents: [
    {
      capsule: :operator,
      kind: :web,
      at: web_mount.path,
      capabilities: %i[screen stream],
      metadata: { surface: surface.name }
    }
  ],
  surface_metadata: [surface_metadata]
).to_h

puts "application_capsule_handoff_subject=#{ready_manifest.fetch(:subject)}"
puts "application_capsule_handoff_capsules=#{ready_manifest.fetch(:capsules).map { |entry| entry.fetch(:name) }.join(",")}"
puts "application_capsule_handoff_ready=#{ready_manifest.fetch(:ready)}"
puts "application_capsule_handoff_required=#{ready_manifest.fetch(:imports).reject { |entry| entry.fetch(:optional) }.map { |entry| entry.fetch(:name) }.join(",")}"
puts "application_capsule_handoff_unresolved=#{missing_manifest.fetch(:unresolved_required_imports).map { |entry| entry.fetch(:name) }.join(",")}"
puts "application_capsule_handoff_mounts=#{ready_manifest.fetch(:mount_intents).map { |entry| "#{entry.fetch(:capsule)}:#{entry.fetch(:kind)}:#{entry.fetch(:at)}" }.join(",")}"
puts "application_capsule_handoff_surfaces=#{ready_manifest.fetch(:surfaces).map { |entry| entry.fetch(:name) }.join(",")}"
puts "application_capsule_handoff_surface_kind=#{ready_manifest.fetch(:surfaces).map { |entry| entry.fetch(:kind) }.join(",")}"
puts "application_capsule_handoff_web_mount=#{web_mount.name}:#{web_mount.path}"
