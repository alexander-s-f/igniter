# frozen_string_literal: true

require_relative "lib/igniter/version"

Gem::Specification.new do |spec|
  package_libs = %w[
    packages/igniter-contracts/lib
    packages/igniter-extensions/lib
    packages/igniter-application/lib
    packages/igniter-mcp-adapter/lib
  ].freeze

  spec.name = "igniter"
  spec.version = Igniter::VERSION
  spec.authors = ["Alexander"]
  spec.email = ["alexander.s.fokin@gmail.com"]

  spec.summary = "Contracts-native runtime umbrella for Igniter"
  spec.description = "Igniter provides a contracts-native embedded kernel, extension packs, local application runtime, and MCP adapter surfaces without shipping archived legacy layers."
  spec.homepage = "https://github.com/alexander-s-f/igniter"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["rubygems_mfa_required"] = "true"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir[
    "lib/igniter.rb",
    "lib/igniter/contract.rb",
    "lib/igniter/diagnostics.rb",
    "lib/igniter/monorepo_packages.rb",
    "lib/igniter/runtime.rb",
    "lib/igniter/version.rb",
    "packages/igniter-contracts/lib/**/*.rb",
    "packages/igniter-contracts/README.md",
    "packages/igniter-extensions/lib/**/*.rb",
    "packages/igniter-extensions/README.md",
    "packages/igniter-application/lib/**/*.rb",
    "packages/igniter-application/README.md",
    "packages/igniter-mcp-adapter/lib/**/*.rb",
    "packages/igniter-mcp-adapter/exe/*",
    "packages/igniter-mcp-adapter/README.md",
    "sig/*.rbs",
    "README.md",
    "LICENSE.txt",
    "CHANGELOG.md",
    "examples/README.md",
    "examples/contracts/*.rb",
    "examples/run.rb",
    "examples/catalog.rb",
    "docs/**/*.md"
  ].sort

  spec.bindir = "bin"
  spec.executables = []
  spec.require_paths = ["lib", *package_libs]

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
