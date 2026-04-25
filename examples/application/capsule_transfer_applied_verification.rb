#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-application/lib", __dir__))

require "fileutils"
require "tmpdir"

require "igniter/application"

Dir.mktmpdir("igniter-capsule-applied-verify") do |root|
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
  ).to_h

  puts "application_capsule_transfer_applied_verify_valid=#{applied_verification.fetch(:valid)}"
  puts "application_capsule_transfer_applied_verify_committed=#{applied_verification.fetch(:committed)}"
  puts "application_capsule_transfer_applied_verify_verified=#{applied_verification.fetch(:verified).length}"
  puts "application_capsule_transfer_applied_verify_findings=#{applied_verification.fetch(:findings).length}"
  puts "application_capsule_transfer_applied_verify_refusals=#{applied_verification.fetch(:refusals).length}"
  puts "application_capsule_transfer_applied_verify_skipped=#{applied_verification.fetch(:skipped).length}"
  puts "application_capsule_transfer_applied_verify_surfaces=#{applied_verification.fetch(:surface_count)}"
end
