#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-application/lib", __dir__))

require "fileutils"
require "tmpdir"

require "igniter/application"

Dir.mktmpdir("igniter-capsule-transfer") do |root|
  FileUtils.mkdir_p(File.join(root, "contracts"))
  FileUtils.mkdir_p(File.join(root, "services"))
  File.write(File.join(root, "contracts/resolve_incident.rb"), "# contract\n")
  File.write(File.join(root, "services/incident_queue.rb"), "# service\n")

  capsule = Igniter::Application.capsule(:operator, root: root, env: :test) do
    layout :capsule
    groups :contracts, :services
    export :resolve_incident, kind: :contract, target: "Contracts::ResolveIncident"
    import :incident_runtime, kind: :service, from: :host
    web_surface :operator_console
  end

  inventory = Igniter::Application.transfer_inventory(
    capsule,
    surface_metadata: [
      {
        name: :operator_console,
        kind: :web_surface,
        path: "web",
        status: :declared
      }
    ]
  ).to_h
  capsule_inventory = inventory.fetch(:capsules).first

  puts "application_capsule_transfer_inventory_capsules=#{inventory.fetch(:capsules).map { |entry| entry.fetch(:name) }.join(",")}"
  puts "application_capsule_transfer_inventory_expected=#{capsule_inventory.fetch(:expected_paths).map { |entry| entry.fetch(:group) }.join(",")}"
  puts "application_capsule_transfer_inventory_missing=#{capsule_inventory.fetch(:missing_expected_paths).map { |entry| entry.fetch(:group) }.join(",")}"
  puts "application_capsule_transfer_inventory_files=#{inventory.fetch(:file_count)}"
  puts "application_capsule_transfer_inventory_ready=#{inventory.fetch(:ready)}"
  puts "application_capsule_transfer_inventory_surfaces=#{inventory.fetch(:surfaces).map { |entry| entry.fetch(:name) }.join(",")}"
end
