#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-application/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-web/lib", __dir__))

require "fileutils"
require "json"
require "tmpdir"

require "igniter/application"
require "igniter/web"

Dir.mktmpdir("igniter-capsule-artifact") do |root|
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
  blueprint = capsule.to_blueprint
  web_structure = Igniter::Web.surface_structure(blueprint)
  surface_metadata = [
    {
      name: :operator_console,
      kind: :web_surface,
      path: web_structure.web_root,
      status: :declared,
      screens_path: web_structure.path(:screens)
    }
  ]
  plan = Igniter::Application.transfer_bundle_plan(
    blueprint,
    subject: :operator_bundle,
    host_exports: [
      { name: :incident_runtime, kind: :service, target: "Host::IncidentRuntime" }
    ],
    surface_metadata: surface_metadata
  )
  result = Igniter::Application.write_transfer_bundle(
    plan,
    output: File.join(root, "operator_bundle"),
    metadata: { example: :capsule_transfer_bundle_artifact }
  ).to_h
  manifest = JSON.parse(
    File.read(File.join(result.fetch(:artifact_path), result.fetch(:metadata_entry))),
    symbolize_names: true
  )

  puts "application_capsule_transfer_artifact_written=#{result.fetch(:written)}"
  puts "application_capsule_transfer_artifact_file=#{File.basename(result.fetch(:artifact_path))}"
  puts "application_capsule_transfer_artifact_included=#{result.fetch(:included_file_count)}"
  puts "application_capsule_transfer_artifact_metadata=#{result.fetch(:metadata_entry)}"
  puts "application_capsule_transfer_artifact_refusals=#{result.fetch(:refusals).length}"
  puts "application_capsule_transfer_artifact_surfaces=#{manifest.fetch(:plan).fetch(:surfaces).length}"
end
