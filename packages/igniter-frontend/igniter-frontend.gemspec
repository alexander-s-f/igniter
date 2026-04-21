# frozen_string_literal: true

require_relative "../igniter-core/lib/igniter/core/version"
require_relative "lib/igniter/frontend/version"

Gem::Specification.new do |spec|
  spec.name = "igniter-frontend"
  spec.version = Igniter::Frontend::VERSION
  spec.authors = ["Alexander"]
  spec.email = ["alexander.s.fokin@gmail.com"]

  spec.summary = "App web surface framework for Igniter"
  spec.description = "HTML-first app surface layer for Igniter apps: routing helpers, handlers, contexts, Arbre pages, and semantic UI components."
  spec.homepage = "https://github.com/alexander-s-f/igniter"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.files = Dir[
    "lib/**/*.rb",
    "README.md"
  ].sort

  spec.require_paths = ["lib"]

  spec.add_dependency "arbre"
  spec.add_dependency "igniter-app", Igniter::VERSION
end
