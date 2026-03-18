# frozen_string_literal: true

require_relative "lib/igniter/version"

Gem::Specification.new do |spec|
  spec.name = "igniter"
  spec.version = Igniter::VERSION
  spec.authors = ["Alexander"]
  spec.email = ["alexander.s.fokin@gmail.com"]

  spec.summary = "Declarative dependency-graph runtime for business logic"
  spec.description = "Igniter provides a contract DSL, graph compiler, runtime execution engine, auditing, reactivity, and introspection for business logic expressed as dependency graphs."
  spec.homepage = "https://github.com/alexander-s-f/igniter"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["rubygems_mfa_required"] = "true"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir[
    "lib/igniter.rb",
    "lib/igniter/version.rb",
    "lib/igniter/errors.rb",
    "lib/igniter/contract.rb",
    "lib/igniter/model.rb",
    "lib/igniter/model/*.rb",
    "lib/igniter/compiler.rb",
    "lib/igniter/compiler/*.rb",
    "lib/igniter/events.rb",
    "lib/igniter/events/*.rb",
    "lib/igniter/runtime.rb",
    "lib/igniter/runtime/cache.rb",
    "lib/igniter/runtime/execution.rb",
    "lib/igniter/runtime/invalidator.rb",
    "lib/igniter/runtime/input_validator.rb",
    "lib/igniter/runtime/node_state.rb",
    "lib/igniter/runtime/resolver.rb",
    "lib/igniter/runtime/result.rb",
    "lib/igniter/dsl.rb",
    "lib/igniter/dsl/contract_builder.rb",
    "lib/igniter/diagnostics.rb",
    "lib/igniter/diagnostics/*.rb",
    "lib/igniter/extensions.rb",
    "lib/igniter/extensions/*.rb",
    "lib/igniter/extensions/auditing/*.rb",
    "lib/igniter/extensions/reactive/*.rb",
    "lib/igniter/extensions/introspection/*.rb",
    "sig/*.rbs",
    "README.md",
    "LICENSE.txt",
    "CHANGELOG.md",
    "docs/*.md"
  ].sort

  spec.bindir = "bin"
  spec.executables = []
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
