# frozen_string_literal: true

require_relative "../igniter-core/lib/igniter/core/version"

Gem::Specification.new do |spec|
  spec.name = "igniter-sdk"
  spec.version = Igniter::VERSION
  spec.authors = ["Alexander"]
  spec.email = ["alexander.s.fokin@gmail.com"]

  spec.summary = "Optional SDK packs for Igniter"
  spec.description = "AI, agents, channels, tools, and data capability packs for Igniter, published as a local monorepo gem."
  spec.homepage = "https://github.com/alexander-s-f/igniter"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.files = Dir[
    "lib/**/*.rb",
    "README.md"
  ].sort

  spec.require_paths = ["lib"]

  spec.add_dependency "igniter-core", Igniter::VERSION
end
