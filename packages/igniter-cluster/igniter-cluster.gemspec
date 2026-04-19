# frozen_string_literal: true

require_relative "../igniter-core/lib/igniter/core/version"

Gem::Specification.new do |spec|
  spec.name = "igniter-cluster"
  spec.version = Igniter::VERSION
  spec.authors = ["Alexander"]
  spec.email = ["alexander.s.fokin@gmail.com"]

  spec.summary = "Cluster and mesh orchestration layer for Igniter"
  spec.description = "Cluster routing, mesh discovery, governance, trust, replication, and distributed diagnostics for Igniter."
  spec.homepage = "https://github.com/alexander-s-f/igniter"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.files = Dir[
    "lib/**/*.rb",
    "README.md"
  ].sort

  spec.require_paths = ["lib"]

  spec.add_dependency "igniter-core", Igniter::VERSION
  spec.add_dependency "igniter-agents", Igniter::VERSION
  spec.add_dependency "igniter-sdk", Igniter::VERSION
  spec.add_dependency "igniter-server", Igniter::VERSION
end
