#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-application/lib", __dir__))

require "tmpdir"

require "igniter/application"

Dir.mktmpdir("igniter-capsule") do |root|
  blueprint = Igniter::Application.blueprint(
    name: :pricing,
    root: root,
    env: :test,
    layout_profile: :capsule,
    groups: %i[contracts services],
    contracts: ["QuoteTotal"],
    services: [:tax_table]
  )

  sparse_plan = blueprint.structure_plan
  result = blueprint.materialize_structure!
  profile = blueprint.apply_to(Igniter::Application.build_kernel).finalize

  puts "application_capsule_name=#{blueprint.name}"
  puts "application_capsule_layout=#{blueprint.layout_profile}"
  puts "application_capsule_contracts_path=#{blueprint.layout.path(:contracts)}"
  puts "application_capsule_config_path=#{blueprint.layout.path(:config)}"
  puts "application_capsule_active_groups=#{blueprint.active_groups.join(",")}"
  puts "application_capsule_sparse_groups=#{sparse_plan.to_h.fetch(:missing_groups).join(",")}"
  puts "application_capsule_applied=#{result.fetch(:applied_count)}"
  puts "application_capsule_config=#{File.file?(File.join(root, "igniter.rb"))}"
  puts "application_capsule_web=#{File.exist?(File.join(root, "web"))}"
  puts "application_capsule_profile_paths=#{profile.path_groups.join(",")}"
end
