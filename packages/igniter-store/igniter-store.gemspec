# frozen_string_literal: true

require_relative "../../lib/igniter/version"

Gem::Specification.new do |spec|
  spec.name = "igniter-store"
  spec.version = Igniter::VERSION
  spec.authors = ["Alexander"]
  spec.email = ["alexander.s.fokin@gmail.com"]

  spec.summary = "Contract-native experimental store for Igniter"
  spec.description = "Research package for Igniter contract-native storage: immutable facts, time-travel reads, reactive invalidation, and WAL-backed local experiments."
  spec.homepage = "https://github.com/alexander-s-f/igniter"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.files = Dir[
    "lib/**/*.rb",
    "examples/**/*.rb",
    "README.md"
  ].sort

  spec.require_paths = ["lib"]
end
