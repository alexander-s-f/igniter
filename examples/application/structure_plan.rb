#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-application/lib", __dir__))

require "tmpdir"

require "igniter/application"

Dir.mktmpdir("igniter-structure") do |root|
  blueprint = Igniter::Application.blueprint(
    name: :operator,
    root: root,
    env: :test,
    web_surfaces: [:operator_console],
    metadata: { owner: :operations }
  )

  initial_plan = blueprint.structure_plan
  result = blueprint.materialize_structure!
  refreshed_plan = blueprint.structure_plan

  puts "application_structure_name=#{blueprint.name}"
  puts "application_structure_initial_missing=#{initial_plan.to_h.fetch(:missing_count)}"
  puts "application_structure_applied=#{result.fetch(:applied_count)}"
  puts "application_structure_config=#{File.file?(File.join(root, "config/igniter.rb"))}"
  puts "application_structure_contracts=#{File.directory?(File.join(root, "app/contracts"))}"
  puts "application_structure_final_present=#{refreshed_plan.to_h.fetch(:present_count)}"
  puts "application_structure_final_missing=#{refreshed_plan.to_h.fetch(:missing_count)}"
end
