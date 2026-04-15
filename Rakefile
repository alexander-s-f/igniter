# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rubocop/rake_task"

RuboCop::RakeTask.new

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = "{spec,examples/companion/spec}/**/*_spec.rb"
end

RSpec::Core::RakeTask.new(:architecture) do |t|
  t.pattern = %w[
    spec/igniter/layer_loading_spec.rb
    spec/igniter/module_layout_spec.rb
    spec/igniter/dependency_boundaries_spec.rb
    spec/igniter/namespace_ownership_spec.rb
  ].join(",")
end

task default: %i[spec rubocop]
