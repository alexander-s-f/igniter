#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-application/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-web/lib", __dir__))

require "fileutils"
require "tmpdir"

require "igniter/application"
require "igniter/web"

Dir.mktmpdir("igniter-capsule-bundle") do |root|
  FileUtils.mkdir_p(File.join(root, "contracts"))
  FileUtils.mkdir_p(File.join(root, "services"))
  File.write(File.join(root, "contracts/resolve_incident.rb"), "# contract\n")
  File.write(File.join(root, "services/incident_queue.rb"), "# service\n")

  capsule = Igniter::Application.capsule(:operator, root: root, env: :test) do
    layout :capsule
    groups :contracts, :services
    export :resolve_incident, kind: :contract, target: "Contracts::ResolveIncident"
    import :incident_runtime, kind: :service, from: :host
    import :audit_log, kind: :service, from: :host, optional: true
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
    surface_metadata: surface_metadata
  ).to_h

  puts "application_capsule_transfer_bundle_subject=#{plan.fetch(:subject)}"
  puts "application_capsule_transfer_bundle_allowed=#{plan.fetch(:bundle_allowed)}"
  puts "application_capsule_transfer_bundle_capsules=#{plan.fetch(:capsules).map { |entry| entry.fetch(:name) }.join(",")}"
  puts "application_capsule_transfer_bundle_files=#{plan.fetch(:included_file_count)}"
  puts "application_capsule_transfer_bundle_blockers=#{plan.fetch(:blockers).map { |entry| entry.fetch(:code) }.uniq.sort.join(",")}"
  puts "application_capsule_transfer_bundle_warnings=#{plan.fetch(:warnings).map { |entry| entry.fetch(:code) }.uniq.sort.join(",")}"
  puts "application_capsule_transfer_bundle_surfaces=#{plan.fetch(:surfaces).length}"
end
