# frozen_string_literal: true

require_relative "../../lib/igniter/version"

Gem::Specification.new do |spec|
  spec.name = "igniter-extensions"
  spec.version = Igniter::VERSION
  spec.authors = ["Alexander"]
  spec.email = ["alexander.s.fokin@gmail.com"]

  spec.summary = "Public extension entrypoints for contracts and legacy Igniter extensions"
  spec.description = "Public extension activation entrypoints for Igniter, including legacy core-backed extension activators kept for migration and contracts-facing extension packs built on the public Igniter::Contracts surface."
  spec.homepage = "https://github.com/alexander-s-f/igniter"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.files = Dir[
    "lib/**/*.rb",
    "README.md"
  ].sort

  spec.require_paths = ["lib"]

  spec.add_dependency "igniter-core", Igniter::VERSION
  spec.add_dependency "igniter-contracts", Igniter::VERSION
end
