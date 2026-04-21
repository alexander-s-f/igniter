# frozen_string_literal: true

require_relative "packages/igniter-core/lib/igniter/core/version"

Gem::Specification.new do |spec|
  package_libs = %w[
    packages/igniter-core/lib
    packages/igniter-agents/lib
    packages/igniter-ai/lib
    packages/igniter-sdk/lib
    packages/igniter-extensions/lib
    packages/igniter-app/lib
    packages/igniter-server/lib
    packages/igniter-cluster/lib
    packages/igniter-rails/lib
    packages/igniter-frontend/lib
    packages/igniter-schema-rendering/lib
  ].freeze

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
    "packages/igniter-core/lib/**/*.rb",
    "packages/igniter-core/README.md",
    "packages/igniter-agents/lib/**/*.rb",
    "packages/igniter-agents/README.md",
    "packages/igniter-ai/lib/**/*.rb",
    "packages/igniter-ai/README.md",
    "packages/igniter-sdk/lib/**/*.rb",
    "packages/igniter-sdk/README.md",
    "packages/igniter-extensions/lib/**/*.rb",
    "packages/igniter-extensions/README.md",
    "packages/igniter-app/lib/**/*",
    "packages/igniter-app/README.md",
    "packages/igniter-server/lib/**/*.rb",
    "packages/igniter-server/README.md",
    "packages/igniter-cluster/lib/**/*.rb",
    "packages/igniter-cluster/README.md",
    "packages/igniter-rails/lib/**/*",
    "packages/igniter-rails/README.md",
    "packages/igniter-frontend/lib/**/*.rb",
    "packages/igniter-frontend/README.md",
    "packages/igniter-schema-rendering/lib/**/*.rb",
    "packages/igniter-schema-rendering/README.md",
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
  spec.require_paths = ["lib", *package_libs]

  spec.add_dependency "arbre"

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
