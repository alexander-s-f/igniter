# frozen_string_literal: true

require "spec_helper"

RSpec.describe "gemspec packaging" do
  ROOT = File.expand_path("../..", __dir__)

  def load_gemspec(path)
    absolute_path = File.join(ROOT, path)

    Dir.chdir(File.dirname(absolute_path)) do
      Gem::Specification.load(File.basename(absolute_path))
    end
  end

  it "ships only the current root package graph in the umbrella gem" do
    spec = load_gemspec("igniter.gemspec")

    expect(spec.files).to include("packages/igniter-contracts/lib/igniter/contracts.rb")
    expect(spec.files).to include("packages/igniter-extensions/lib/igniter/extensions/contracts.rb")
    expect(spec.files).to include("packages/igniter-application/lib/igniter/application.rb")
    expect(spec.files).to include("packages/igniter-cluster/lib/igniter/cluster.rb")
    expect(spec.files).to include("packages/igniter-mcp-adapter/lib/igniter/mcp/adapter.rb")
    expect(spec.files.grep(/examples\/archive/)).to eq([])
    expect(spec.require_paths).not_to include("packages/archive/igniter-core/lib")
  end

  it "keeps igniter-extensions free from igniter-core runtime dependency" do
    spec = load_gemspec("packages/igniter-extensions/igniter-extensions.gemspec")

    dependency_names = spec.dependencies.select { |dependency| dependency.type == :runtime }.map(&:name)
    expect(dependency_names).to eq(["igniter-contracts"])
  end

  it "declares igniter-application runtime dependencies through current package layers only" do
    spec = load_gemspec("packages/igniter-application/igniter-application.gemspec")

    dependency_names = spec.dependencies.select { |dependency| dependency.type == :runtime }.map(&:name)
    expect(dependency_names).to eq(["igniter-contracts", "igniter-extensions"])
  end

  it "declares igniter-cluster runtime dependency through igniter-application only" do
    spec = load_gemspec("packages/igniter-cluster/igniter-cluster.gemspec")

    dependency_names = spec.dependencies.select { |dependency| dependency.type == :runtime }.map(&:name)
    expect(dependency_names).to eq(["igniter-application"])
  end
end
