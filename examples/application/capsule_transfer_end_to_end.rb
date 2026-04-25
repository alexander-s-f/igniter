#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-application/lib", __dir__))

require "fileutils"
require "tmpdir"

require "igniter/application"

Dir.mktmpdir("igniter-capsule-transfer-e2e") do |root|
  capsule_root = File.join(root, "operator")
  artifact = File.join(root, "operator_bundle")
  destination = File.join(root, "destination")

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
  host_exports = [
    { name: :incident_runtime, kind: :service, target: "Host::IncidentRuntime" }
  ]
  surface_metadata = [
    { name: :operator_console, kind: :web_surface, path: "web" }
  ]

  inventory = Igniter::Application.transfer_inventory(
    capsule,
    surface_metadata: surface_metadata
  )
  readiness = Igniter::Application.transfer_readiness(
    handoff_manifest: Igniter::Application.handoff_manifest(
      subject: :operator_bundle,
      capsules: [capsule],
      host_exports: host_exports,
      surface_metadata: surface_metadata
    ),
    transfer_inventory: inventory
  )
  bundle_plan = Igniter::Application.transfer_bundle_plan(transfer_readiness: readiness)
  Igniter::Application.write_transfer_bundle(bundle_plan, output: artifact)
  bundle_verification = Igniter::Application.verify_transfer_bundle(artifact)
  intake = Igniter::Application.transfer_intake_plan(bundle_verification, destination_root: destination)
  apply_plan = Igniter::Application.transfer_apply_plan(intake)
  dry_run = Igniter::Application.apply_transfer_plan(apply_plan)
  committed = Igniter::Application.apply_transfer_plan(apply_plan, commit: true)
  applied_verification = Igniter::Application.verify_applied_transfer(committed, apply_plan: apply_plan)
  receipt = Igniter::Application.transfer_receipt(
    applied_verification,
    apply_result: committed,
    apply_plan: apply_plan
  )

  puts "application_capsule_transfer_end_to_end_ready=#{readiness.to_h.fetch(:ready)}"
  puts "application_capsule_transfer_end_to_end_bundle_allowed=#{bundle_plan.to_h.fetch(:bundle_allowed)}"
  puts "application_capsule_transfer_end_to_end_bundle_verified=#{bundle_verification.to_h.fetch(:valid)}"
  puts "application_capsule_transfer_end_to_end_intake_accepted=#{intake.to_h.fetch(:ready)}"
  puts "application_capsule_transfer_end_to_end_apply_executable=#{apply_plan.to_h.fetch(:executable)}"
  puts "application_capsule_transfer_end_to_end_dry_run_committed=#{dry_run.to_h.fetch(:committed)}"
  puts "application_capsule_transfer_end_to_end_committed=#{committed.to_h.fetch(:committed)}"
  puts "application_capsule_transfer_end_to_end_applied_valid=#{applied_verification.to_h.fetch(:valid)}"
  puts "application_capsule_transfer_end_to_end_receipt_complete=#{receipt.to_h.fetch(:complete)}"
end
