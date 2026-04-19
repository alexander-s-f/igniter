# frozen_string_literal: true

require_relative "lib/igniter/core/version"

Gem::Specification.new do |spec|
  spec.name = "igniter-core"
  spec.version = Igniter::VERSION
  spec.authors = ["Alexander"]
  spec.email = ["alexander.s.fokin@gmail.com"]

  spec.summary = "Core runtime and graph kernel for Igniter"
  spec.description = "Contracts, compiler, runtime, diagnostics, tools, and shared graph primitives for Igniter."
  spec.homepage = "https://github.com/alexander-s-f/igniter"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.files = Dir[
    "lib/**/*.rb",
    "README.md"
  ].sort

  spec.require_paths = ["lib"]
end
