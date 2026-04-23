# frozen_string_literal: true

require_relative "../../lib/igniter/version"

Gem::Specification.new do |spec|
  spec.name = "igniter-rails"
  spec.version = Igniter::VERSION
  spec.authors = ["Alexander"]
  spec.email = ["alexander.s.fokin@gmail.com"]

  spec.summary = "Rails integration layer for Igniter"
  spec.description = "ActiveJob, controller/webhook, ActionCable, Railtie, and Rails generators for Igniter."
  spec.homepage = "https://github.com/alexander-s-f/igniter"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.files = Dir[
    "lib/**/*",
    "README.md"
  ].select { |path| File.file?(path) }.sort

  spec.require_paths = ["lib"]

  spec.add_dependency "igniter-core", Igniter::VERSION
end
