# frozen_string_literal: true

require_relative "lib/igniter_lang/version"

Gem::Specification.new do |spec|
  spec.name = "igniter_lang"
  spec.version = IgniterLang::VERSION
  spec.summary = "Contract-native language compiler for Igniter"
  spec.description = "Igniter-Lang provides the packageable compiler facade and CLI for the Igniter contract-native language research workspace."
  spec.authors = ["Alexander"]
  spec.email = ["alexander.s.fokin@gmail.com"]
  spec.homepage = "https://github.com/alexander-s-f/igniter"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.files = Dir.chdir(__dir__) do
    Dir["lib/**/*.rb", "bin/igc", "README.md"].select { |path| File.file?(path) }
  end
  spec.bindir = "bin"
  spec.executables = ["igc"]
  spec.require_paths = ["lib"]

  spec.metadata = {
    "rubygems_mfa_required" => "true",
    "homepage_uri" => spec.homepage,
    "source_code_uri" => "#{spec.homepage}/tree/main/igniter-lang"
  }
end
