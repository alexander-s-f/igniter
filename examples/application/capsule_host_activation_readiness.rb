#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-application/lib", __dir__))

require "fileutils"
require "tmpdir"

require "igniter/application"

Dir.mktmpdir("igniter-capsule-host-readiness") do |root|
  capsule_root = File.join(root, "operator")
  artifact = File.join(root, "operator_bundle")
  destination = File.join(root, "destination")
  host_exports = [
    { name: :incident_runtime, kind: :service, target: "Host::IncidentRuntime" }
  ]
  surface_metadata = [
    { name: :operator_console, kind: :web_surface, path: "web" }
  ]
  mount_intents = [
    {
      capsule: :operator,
      kind: :web,
      at: "/operator",
      capabilities: %i[screen stream],
      metadata: { surface: :operator_console }
    }
  ]

  FileUtils.mkdir_p(File.join(capsule_root, "contracts"))
  FileUtils.mkdir_p(File.join(capsule_root, "spec"))
  FileUtils.mkdir_p(File.join(capsule_root, "web"))
  File.write(File.join(capsule_root, "contracts/resolve_incident.rb"), "# contract\n")
  File.write(File.join(capsule_root, "igniter.rb"), "# config\n")

  capsule = Igniter::Application.capsule(:operator, root: capsule_root, env: :test) do
    layout :capsule
    groups :contracts
    import :incident_runtime, kind: :service, from: :host
    web_surface :operator_console
  end
  handoff = Igniter::Application.handoff_manifest(
    subject: :operator_bundle,
    capsules: [capsule],
    host_exports: host_exports,
    mount_intents: mount_intents,
    surface_metadata: surface_metadata
  )
  inventory = Igniter::Application.transfer_inventory(capsule, surface_metadata: surface_metadata)
  readiness = Igniter::Application.transfer_readiness(
    handoff_manifest: handoff,
    transfer_inventory: inventory
  )
  bundle_plan = Igniter::Application.transfer_bundle_plan(transfer_readiness: readiness)
  Igniter::Application.write_transfer_bundle(bundle_plan, output: artifact)
  bundle_verification = Igniter::Application.verify_transfer_bundle(artifact)
  intake = Igniter::Application.transfer_intake_plan(bundle_verification, destination_root: destination)
  apply_plan = Igniter::Application.transfer_apply_plan(intake)
  committed = Igniter::Application.apply_transfer_plan(apply_plan, commit: true)
  applied_verification = Igniter::Application.verify_applied_transfer(committed, apply_plan: apply_plan)
  receipt = Igniter::Application.transfer_receipt(
    applied_verification,
    apply_result: committed,
    apply_plan: apply_plan
  )
  activation = Igniter::Application.host_activation_readiness(
    receipt,
    handoff_manifest: handoff,
    host_exports: host_exports,
    load_paths: ["operator"],
    providers: [:incident_runtime],
    contracts: ["Contracts::ResolveIncident"],
    lifecycle: { boot: :manual_review },
    mount_decisions: [
      { capsule: :operator, kind: :web, at: "/operator", status: :accepted }
    ],
    surface_metadata: surface_metadata
  ).to_h

  puts "application_capsule_host_activation_ready=#{activation.fetch(:ready)}"
  puts "application_capsule_host_activation_blockers=#{activation.fetch(:blockers).length}"
  puts "application_capsule_host_activation_warnings=#{activation.fetch(:warnings).length}"
  puts "application_capsule_host_activation_manual=#{activation.fetch(:manual_actions).length}"
  puts "application_capsule_host_activation_mounts=#{activation.fetch(:mount_intents).length}"
  puts "application_capsule_host_activation_surfaces=#{activation.fetch(:surface_count)}"
end
