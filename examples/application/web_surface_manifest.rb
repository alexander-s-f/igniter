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
  root title: "Operator" do
    main { h1 "Operator" }
  end

  command "/incidents/:id/resolve", to: Igniter::Web.contract("Contracts::ResolveIncident")
  query "/status", to: Igniter::Web.service(:cluster_status)
  stream "/events", to: Igniter::Web.projection("Projections::ClusterEvents")

  screen :execution, intent: :live_process do
    stream :events, from: "Projections::ClusterEvents"
    chat with: "Agents::ProjectLead"
    action :pause, run: "Contracts::PauseProject"
  end

  screen_route "/execution", :execution
end

surface = Igniter::Web.surface_manifest(web, name: :operator_console, path: "/operator")
blueprint = Igniter::Application.blueprint(
  name: :operator,
  root: "/tmp/igniter_operator_web_surface_manifest",
  env: :test,
  layout_profile: :capsule,
  web_surfaces: [:operator_console],
  exports: [surface.to_capsule_export]
)
manifest = blueprint.to_manifest
web_export = manifest.exports.first
surface_metadata = web_export.fetch(:metadata).fetch(:surface_manifest)
exports = surface_metadata.fetch(:exports).map { |entry| "#{entry.fetch(:kind)}:#{entry[:path] || entry[:name]}" }
imports = surface_metadata.fetch(:imports).map { |entry| "#{entry.fetch(:kind)}:#{entry.fetch(:name)}" }

puts "application_web_manifest_name=#{surface.name}"
puts "application_web_manifest_path=#{surface.path}"
puts "application_web_manifest_capsule_export=#{web_export.fetch(:kind)}:#{web_export.fetch(:name)}"
puts "application_web_manifest_exports=#{exports.join(",")}"
puts "application_web_manifest_imports=#{imports.join(",")}"
puts "application_web_manifest_contract=#{imports.include?("contract:Contracts::ResolveIncident")}"
puts "application_web_manifest_service=#{imports.include?("service:cluster_status")}"
puts "application_web_manifest_projection=#{imports.include?("projection:Projections::ClusterEvents")}"
puts "application_web_manifest_agent=#{imports.include?("agent:Agents::ProjectLead")}"
