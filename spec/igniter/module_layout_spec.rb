# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Igniter module layout" do
  MODULE_LAYOUT_ROOT = File.expand_path("../..", __dir__)
  IGNITER_LIB = File.join(MODULE_LAYOUT_ROOT, "lib/igniter")
  CORE_LIB = File.join(MODULE_LAYOUT_ROOT, "packages/igniter-core/lib/igniter")
  AI_LIB = File.join(MODULE_LAYOUT_ROOT, "packages/igniter-ai/lib/igniter")
  SDK_LIB = File.join(MODULE_LAYOUT_ROOT, "packages/igniter-sdk/lib/igniter")
  EXTENSIONS_LIB = File.join(MODULE_LAYOUT_ROOT, "packages/igniter-extensions/lib/igniter")
  APP_LIB = File.join(MODULE_LAYOUT_ROOT, "packages/igniter-app/lib/igniter")
  SERVER_LIB = File.join(MODULE_LAYOUT_ROOT, "packages/igniter-server/lib/igniter")
  CLUSTER_LIB = File.join(MODULE_LAYOUT_ROOT, "packages/igniter-cluster/lib/igniter")
  RAILS_LIB = File.join(MODULE_LAYOUT_ROOT, "packages/igniter-rails/lib/igniter")

  def children_for(path)
    Dir.children(path).sort
  end

  it "keeps only canonical top-level runtime and registry entrypoints under lib/igniter" do
    expect(children_for(IGNITER_LIB)).to eq(%w[
      monorepo_packages.rb
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

  it "keeps server entrypoints inside the local server package" do
    expect(children_for(SERVER_LIB)).to eq(%w[
      server
      server.rb
    ])
  end

  it "keeps server packs under the canonical server namespace inside the package" do
    expect(children_for(File.join(SERVER_LIB, "server"))).to include(
      "app_host.rb",
      "client.rb",
      "config.rb",
      "handlers",
      "http_server.rb",
      "rack_app.rb",
      "registry.rb",
      "remote_adapter.rb",
      "router.rb",
      "server_logger.rb"
    )
  end

  it "keeps cluster entrypoints inside the local cluster package" do
    expect(children_for(CLUSTER_LIB)).to eq(%w[
      cluster
      cluster.rb
    ])
  end

  it "keeps cluster packs under the canonical cluster namespace inside the package" do
    expect(children_for(File.join(CLUSTER_LIB, "cluster"))).to include(
      "consensus",
      "consensus.rb",
      "diagnostics",
      "diagnostics.rb",
      "events",
      "events.rb",
      "governance",
      "governance.rb",
      "identity",
      "identity.rb",
      "mesh",
      "mesh.rb",
      "ownership",
      "ownership.rb",
      "projection_store.rb",
      "rag",
      "rag.rb",
      "remote_adapter.rb",
      "replication",
      "replication.rb",
      "routing_plan_executor.rb",
      "routing_plan_result.rb",
      "trust",
      "trust.rb"
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

  it "keeps AI SDK pack entrypoints inside the local ai package" do
    expect(children_for(AI_LIB)).to eq(%w[
      ai
      ai.rb
    ])
  end

  it "keeps AI packs under the canonical ai namespace inside the package" do
    expect(children_for(File.join(AI_LIB, "ai"))).to include(
      "agents",
      "agents.rb",
      "config.rb",
      "context.rb",
      "executor.rb",
      "providers",
      "skill",
      "skill.rb",
      "tool_registry.rb",
      "transcription"
    )
  end

  it "does not keep sdk/ai entrypoints inside the sdk package" do
    expect(children_for(File.join(SDK_LIB, "sdk"))).not_to include(
      "ai",
      "ai.rb"
    )
  end

  it "keeps sdk packs under the canonical sdk namespace inside the package" do
    expect(children_for(File.join(SDK_LIB, "sdk"))).to eq(%w[
      agents
      agents.rb
      channels
      channels.rb
      data
      data.rb
      tools
      tools.rb
    ])
  end

  it "keeps extension entrypoints inside the local extensions package" do
    expect(children_for(EXTENSIONS_LIB)).to eq(%w[
      extensions
      extensions.rb
    ])
  end

  it "keeps public extension entrypoints under the canonical extensions namespace inside the package" do
    expect(children_for(File.join(EXTENSIONS_LIB, "extensions"))).to eq(%w[
      auditing.rb
      capabilities.rb
      content_addressing.rb
      dataflow.rb
      differential.rb
      execution_report.rb
      incremental.rb
      introspection.rb
      invariants.rb
      provenance.rb
      reactive.rb
      saga.rb
    ])
  end

  it "keeps rails plugin entrypoints inside the local rails package" do
    expect(children_for(File.join(RAILS_LIB, "plugins"))).to eq(%w[
      rails
      rails.rb
    ])
  end
end
