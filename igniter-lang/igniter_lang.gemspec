# frozen_string_literal: true

require_relative "lib/igniter_lang/version"

Gem::Specification.new do |spec|
  spec.name = "igniter_lang"
  spec.version = IgniterLang::VERSION
  spec.summary = "Igniter-Lang compiler proof package skeleton"
  spec.description = "Minimal Stage 2 compiler package skeleton for Igniter-Lang."
  spec.authors = ["Igniter"]
  spec.email = ["dev@igniter.local"]
  spec.homepage = "https://example.invalid/igniter-lang"
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
    "source_code_uri" => "https://example.invalid/igniter-lang"
  }
end
