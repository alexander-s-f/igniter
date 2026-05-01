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
    "ext/**/*.{rb,rs,toml}",
    "examples/**/*.rb",
    "exe/*",
    "README.md"
  ].sort

  spec.bindir      = "exe"
  spec.executables = ["igniter-store-server"]

  spec.require_paths = ["lib"]
  spec.extensions    = ["ext/igniter_store_native/extconf.rb"]

  spec.add_development_dependency "rb_sys", "~> 0.9"
  spec.add_development_dependency "rake-compiler", "~> 1.2"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rake", "~> 13.0"
end
