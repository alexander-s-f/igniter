# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Igniter module layout" do
  MODULE_LAYOUT_ROOT = File.expand_path("../..", __dir__)
  IGNITER_LIB = File.join(MODULE_LAYOUT_ROOT, "lib/igniter")
  CORE_LIB = File.join(MODULE_LAYOUT_ROOT, "packages/igniter-core/lib/igniter")
  SDK_LIB = File.join(MODULE_LAYOUT_ROOT, "packages/igniter-sdk/lib/igniter")
  APP_LIB = File.join(MODULE_LAYOUT_ROOT, "packages/igniter-app/lib/igniter")

  def children_for(path)
    Dir.children(path).sort
  end

  it "keeps only canonical top-level runtime and registry entrypoints under lib/igniter" do
    expect(children_for(IGNITER_LIB)).to eq(%w[
      cluster
      cluster.rb
      extensions
      monorepo_packages.rb
      plugins
      plugins.rb
      server
      server.rb
      stack.rb
    ])
  end

  it "keeps app entrypoints inside the local app package" do
    expect(children_for(APP_LIB)).to eq(%w[
      app
      app.rb
    ])
  end

  it "keeps app packs under the canonical app namespace inside the package" do
    expect(children_for(File.join(APP_LIB, "app"))).to include(
      "app_config.rb",
      "app_host.rb",
      "app_host_pack.rb",
      "diagnostics.rb",
      "evolution.rb",
      "generator.rb",
      "generators",
      "runtime.rb",
      "runtime_pack.rb",
      "scaffold_pack.rb",
      "stack.rb",
      "stack_pack.rb"
    )
  end

  it "keeps core entrypoints inside the local core package" do
    expect(children_for(CORE_LIB)).to eq(%w[
      core
      core.rb
    ])
  end

  it "keeps core packs under the canonical core namespace inside the package" do
    expect(children_for(File.join(CORE_LIB, "core"))).to include(
      "agent",
      "agent.rb",
      "compiler",
      "compiler.rb",
      "contract.rb",
      "diagnostics.rb",
      "dsl.rb",
      "errors.rb",
      "events.rb",
      "executor.rb",
      "extensions.rb",
      "model.rb",
      "runtime.rb",
      "tool.rb",
      "type_system.rb",
      "version.rb"
    )
  end

  it "keeps sdk entrypoints inside the local sdk package" do
    expect(children_for(SDK_LIB)).to eq(%w[
      sdk
      sdk.rb
    ])
  end

  it "keeps sdk packs under the canonical sdk namespace inside the package" do
    expect(children_for(File.join(SDK_LIB, "sdk"))).to eq(%w[
      agents
      agents.rb
      ai
      ai.rb
      channels
      channels.rb
      data
      data.rb
      tools
      tools.rb
    ])
  end

  it "keeps plugins under the canonical plugins namespace" do
    expect(children_for(File.join(IGNITER_LIB, "plugins"))).to eq(%w[
      rails
      rails.rb
    ])
  end
end
