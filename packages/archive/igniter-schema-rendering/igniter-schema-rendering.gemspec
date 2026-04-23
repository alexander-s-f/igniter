# frozen_string_literal: true

require_relative "../../lib/igniter/version"
require_relative "lib/igniter/schema_rendering/version"

Gem::Specification.new do |spec|
  spec.name = "igniter-schema-rendering"
  spec.version = Igniter::SchemaRendering::VERSION
  spec.authors = ["Alexander"]
  spec.email = ["alexander.s.fokin@gmail.com"]

  spec.summary = "Schema-driven rendering lane for Igniter"
  spec.description = "Agent-facing and schema-driven page rendering, storage, patching, and submission processing for Igniter."
  spec.homepage = "https://github.com/alexander-s-f/igniter"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.files = Dir[
    "lib/**/*.rb",
    "README.md"
  ].sort

  spec.require_paths = ["lib"]

  spec.add_dependency "igniter-frontend", Igniter::VERSION
  spec.add_dependency "igniter-sdk", Igniter::VERSION
end
