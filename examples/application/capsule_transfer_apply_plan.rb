#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-application/lib", __dir__))

require "fileutils"
require "tmpdir"

require "igniter/application"

Dir.mktmpdir("igniter-capsule-apply") do |root|
  capsule_root = File.join(root, "operator")
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
  intake = Igniter::Application.transfer_intake_plan(
    verification,
    destination_root: File.join(root, "destination")
  )
  apply_plan = Igniter::Application.transfer_apply_plan(intake).to_h

  puts "application_capsule_transfer_apply_executable=#{apply_plan.fetch(:executable)}"
  puts "application_capsule_transfer_apply_operations=#{apply_plan.fetch(:operation_count)}"
  puts "application_capsule_transfer_apply_blockers=#{apply_plan.fetch(:blockers).length}"
  puts "application_capsule_transfer_apply_warnings=#{apply_plan.fetch(:warnings).length}"
  puts "application_capsule_transfer_apply_surfaces=#{apply_plan.fetch(:surface_count)}"
end
