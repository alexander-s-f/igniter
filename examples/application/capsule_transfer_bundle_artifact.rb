#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-application/lib", __dir__))

require "fileutils"
require "tmpdir"

require "igniter/application"

Dir.mktmpdir("igniter-capsule-artifact") do |root|
  capsule_root = File.join(root, "operator")
  FileUtils.mkdir_p(File.join(capsule_root, "contracts"))
  FileUtils.mkdir_p(File.join(capsule_root, "spec"))
  File.write(File.join(capsule_root, "contracts/resolve_incident.rb"), "# contract\n")
  File.write(File.join(capsule_root, "igniter.rb"), "# config\n")

  capsule = Igniter::Application.capsule(:operator, root: capsule_root, env: :test) do
    layout :capsule
    groups :contracts
    import :incident_runtime, kind: :service, from: :host
  end
  plan = Igniter::Application.transfer_bundle_plan(
    capsule,
    subject: :operator_bundle,
    host_exports: [
      { name: :incident_runtime, kind: :service, target: "Host::IncidentRuntime" }
    ]
  )
  result = Igniter::Application.write_transfer_bundle(
    plan,
    output: File.join(root, "operator_bundle"),
    metadata: { example: :capsule_transfer_bundle_artifact }
  ).to_h

  puts "application_capsule_transfer_artifact_written=#{result.fetch(:written)}"
  puts "application_capsule_transfer_artifact_file=#{File.basename(result.fetch(:artifact_path))}"
  puts "application_capsule_transfer_artifact_included=#{result.fetch(:included_file_count)}"
  puts "application_capsule_transfer_artifact_metadata=#{result.fetch(:metadata_entry)}"
  puts "application_capsule_transfer_artifact_refusals=#{result.fetch(:refusals).length}"
end
