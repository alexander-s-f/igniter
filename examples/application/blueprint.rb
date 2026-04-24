#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-application/lib", __dir__))

require "tmpdir"

require "igniter/application"

Dir.mktmpdir("igniter-operator") do |root|
  blueprint = Igniter::Application.blueprint(
    name: :operator,
    root: root,
    env: :test,
    packs: [Igniter::Extensions::Contracts::ComposePack],
    contracts: ["PricingContract"],
    services: [:pricing_api],
    effects: [:audit_log],
    web_surfaces: %i[operator_console agent_chat],
    config: {
      runtime: { mode: :test }
    },
    metadata: {
      owner: :operations
    }
  )

  kernel = blueprint.apply_to(Igniter::Application.build_kernel)
  profile = kernel.finalize
  manifest = blueprint.to_manifest

  puts "application_blueprint_name=#{blueprint.name}"
  puts "application_blueprint_env=#{blueprint.env}"
  puts "application_blueprint_web=#{blueprint.web_surfaces.join(",")}"
  puts "application_blueprint_paths=#{blueprint.planned_paths.map { |entry| entry.fetch(:group) }.join(",")}"
  puts "application_blueprint_manifest=#{manifest.metadata.fetch(:blueprint)}"
  puts "application_blueprint_owner=#{manifest.metadata.fetch(:owner)}"
  puts "application_blueprint_profile_env=#{profile.manifest.env}"
  puts "application_blueprint_profile_web=#{profile.manifest.metadata.fetch(:web_surfaces).join(",")}"
  puts "application_blueprint_runtime=#{profile.config.fetch(:runtime).fetch(:mode)}"
end
