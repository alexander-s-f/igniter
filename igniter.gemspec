# frozen_string_literal: true

require_relative "packages/igniter-core/lib/igniter/core/version"

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
    "lib/igniter/**/*.rb",
    "sig/*.rbs",
    "README.md",
    "LICENSE.txt",
    "CHANGELOG.md",
    "examples/README.md",
    "examples/*.rb",
    "docs/*.md"
  ].sort

  spec.bindir = "bin"
  spec.executables = ["igniter-stack"]
  # spec.bindir = "exe"
  # spec.executables = ["igniter-stack"]
  spec.require_paths = ["lib"]

  spec.add_dependency "igniter-core", Igniter::VERSION
  spec.add_dependency "igniter-sdk", Igniter::VERSION
  spec.add_dependency "igniter-extensions", Igniter::VERSION
  spec.add_dependency "igniter-app", Igniter::VERSION
  spec.add_dependency "igniter-server", Igniter::VERSION
  spec.add_dependency "igniter-cluster", Igniter::VERSION
  spec.add_dependency "igniter-rails", Igniter::VERSION

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
