#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-application/lib", __dir__))

require "fileutils"
require "tmpdir"

require "igniter/application"

Dir.mktmpdir("igniter-capsule-transfer-receipt") do |root|
  capsule_root = File.join(root, "operator")
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
  bundle_plan = Igniter::Application.transfer_bundle_plan(
    capsule,
    subject: :operator_bundle,
    host_exports: [
      { name: :incident_runtime, kind: :service, target: "Host::IncidentRuntime" }
    ],
    surface_metadata: [
      { name: :operator_console, kind: :web_surface, path: "web" }
    ]
  )
  artifact = File.join(root, "operator_bundle")
  Igniter::Application.write_transfer_bundle(bundle_plan, output: artifact)
  verification = Igniter::Application.verify_transfer_bundle(artifact)
  intake = Igniter::Application.transfer_intake_plan(verification, destination_root: destination)
  apply_plan = Igniter::Application.transfer_apply_plan(intake)
  apply_result = Igniter::Application.apply_transfer_plan(apply_plan, commit: true)
  applied_verification = Igniter::Application.verify_applied_transfer(
    apply_result,
    apply_plan: apply_plan
  )
  receipt = Igniter::Application.transfer_receipt(
    applied_verification,
    apply_result: apply_result,
    apply_plan: apply_plan
  ).to_h
  counts = receipt.fetch(:counts)

  puts "application_capsule_transfer_receipt_complete=#{receipt.fetch(:complete)}"
  puts "application_capsule_transfer_receipt_valid=#{receipt.fetch(:valid)}"
  puts "application_capsule_transfer_receipt_committed=#{receipt.fetch(:committed)}"
  puts "application_capsule_transfer_receipt_verified=#{counts.fetch(:verified)}"
  puts "application_capsule_transfer_receipt_findings=#{counts.fetch(:findings)}"
  puts "application_capsule_transfer_receipt_refusals=#{counts.fetch(:refusals)}"
  puts "application_capsule_transfer_receipt_skipped=#{counts.fetch(:skipped)}"
  puts "application_capsule_transfer_receipt_manual=#{counts.fetch(:manual_actions)}"
  puts "application_capsule_transfer_receipt_surfaces=#{receipt.fetch(:surface_count)}"
end
