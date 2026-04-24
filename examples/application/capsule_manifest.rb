#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-application/lib", __dir__))

require "igniter/application"

blueprint = Igniter::Application.blueprint(
  name: :operator,
  root: "/tmp/igniter_operator_capsule_manifest",
  env: :test,
  layout_profile: :capsule,
  groups: %i[contracts services],
  exports: [
    { name: :cluster_status, as: :service, target: "Services::ClusterStatus" },
    { name: :resolve_incident, kind: :contract, target: "Contracts::ResolveIncident" }
  ],
  imports: [
    { name: :incident_runtime, kind: :service, from: :host, capabilities: [:incidents] },
    { name: :audit_log, kind: :service, from: :observability, optional: true }
  ]
)

profile = blueprint.apply_to(Igniter::Application.build_kernel).finalize
manifest = profile.manifest

puts "application_capsule_manifest_name=#{manifest.name}"
puts "application_capsule_manifest_layout=#{manifest.metadata.fetch(:layout_profile)}"
puts "application_capsule_manifest_groups=#{manifest.metadata.fetch(:groups).join(",")}"
puts "application_capsule_manifest_exports=#{manifest.exports.map { |entry| entry.fetch(:name) }.join(",")}"
puts "application_capsule_manifest_imports=#{manifest.imports.map { |entry| entry.fetch(:name) }.join(",")}"
puts "application_capsule_manifest_required_imports=#{manifest.imports.reject { |entry| entry.fetch(:optional) }.map { |entry| entry.fetch(:name) }.join(",")}"
puts "application_capsule_manifest_optional_imports=#{manifest.imports.select { |entry| entry.fetch(:optional) }.map { |entry| entry.fetch(:name) }.join(",")}"
puts "application_capsule_manifest_paths=#{profile.path_groups.join(",")}"
