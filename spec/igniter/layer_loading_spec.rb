# frozen_string_literal: true

require "spec_helper"
require "json"
require "open3"
require "rbconfig"

RSpec.describe "Igniter layer loading" do
  ROOT = File.expand_path("../..", __dir__)

  def loaded_igniter_features(entrypoint)
    script = <<~RUBY
      require "json"
      $LOAD_PATH.unshift(File.expand_path("lib", #{ROOT.inspect}))
      require #{entrypoint.inspect}

      features = $LOADED_FEATURES.filter_map do |feature|
        next unless feature.include?("/lib/igniter") || feature.end_with?("/lib/igniter.rb")

        feature.sub(%r{.*?/lib/}, "")
      end

      puts JSON.generate(features.sort.uniq)
    RUBY

    stdout, stderr, status = Open3.capture3(RbConfig.ruby, "-e", script, chdir: ROOT)
    raise "Failed to inspect #{entrypoint}: #{stderr}" unless status.success?

    JSON.parse(stdout)
  end

  def runtime_remote_adapter_classes_for(entrypoint)
    script = <<~RUBY
      require "json"
      $LOAD_PATH.unshift(File.expand_path("lib", #{ROOT.inspect}))
      require "igniter"
      before = Igniter::Runtime.remote_adapter.class.name
      require #{entrypoint.inspect}
      after = Igniter::Runtime.remote_adapter.class.name

      puts JSON.generate({ before: before, after: after })
    RUBY

    stdout, stderr, status = Open3.capture3(RbConfig.ruby, "-e", script, chdir: ROOT)
    raise "Failed to inspect runtime adapter for #{entrypoint}: #{stderr}" unless status.success?

    JSON.parse(stdout)
  end

  def registered_host_names_for(entrypoint)
    script = <<~RUBY
      require "json"
      $LOAD_PATH.unshift(File.expand_path("lib", #{ROOT.inspect}))
      require #{entrypoint.inspect}
      puts JSON.generate(Igniter::Application::HostRegistry.names.map(&:to_s).sort)
    RUBY

    stdout, stderr, status = Open3.capture3(RbConfig.ruby, "-e", script, chdir: ROOT)
    raise "Failed to inspect host registry for #{entrypoint}: #{stderr}" unless status.success?

    JSON.parse(stdout)
  end

  def registered_scheduler_names_for(entrypoint)
    script = <<~RUBY
      require "json"
      $LOAD_PATH.unshift(File.expand_path("lib", #{ROOT.inspect}))
      require #{entrypoint.inspect}
      puts JSON.generate(Igniter::Application::SchedulerRegistry.names.map(&:to_s).sort)
    RUBY

    stdout, stderr, status = Open3.capture3(RbConfig.ruby, "-e", script, chdir: ROOT)
    raise "Failed to inspect scheduler registry for #{entrypoint}: #{stderr}" unless status.success?

    JSON.parse(stdout)
  end

  def registered_loader_names_for(entrypoint)
    script = <<~RUBY
      require "json"
      $LOAD_PATH.unshift(File.expand_path("lib", #{ROOT.inspect}))
      require #{entrypoint.inspect}
      puts JSON.generate(Igniter::Application::LoaderRegistry.names.map(&:to_s).sort)
    RUBY

    stdout, stderr, status = Open3.capture3(RbConfig.ruby, "-e", script, chdir: ROOT)
    raise "Failed to inspect loader registry for #{entrypoint}: #{stderr}" unless status.success?

    JSON.parse(stdout)
  end

  it "`require \"igniter\"` stays inside the embedded core layer" do
    features = loaded_igniter_features("igniter")

    expect(features).to include("igniter.rb")
    expect(features).not_to include("igniter/core.rb")
    expect(features).not_to include("igniter/tools.rb")
    expect(features).not_to include("igniter/server.rb")
    expect(features).not_to include("igniter/application.rb")
    expect(features).not_to include("igniter/cluster.rb")
    expect(features).not_to include("igniter/ai.rb")
    expect(features).not_to include("igniter/channels.rb")
  end

  it "`require \"igniter/core\"` loads actor/tool primitives without built-in operational tools" do
    features = loaded_igniter_features("igniter/core")

    expect(features).to include("igniter/core.rb")
    expect(features).to include("igniter/core/tool.rb")
    expect(features).not_to include("igniter/tools.rb")
    expect(features).not_to include("igniter/core/tool/system_discovery_tool.rb")
    expect(features).not_to include("igniter/core/tool/local_workflow_selector_tool.rb")
    expect(features).not_to include("igniter/core/tool/agent_bootstrap_tool.rb")
    expect(features).not_to include("igniter/server.rb")
    expect(features).not_to include("igniter/application.rb")
    expect(features).not_to include("igniter/cluster.rb")
    expect(features).not_to include("igniter/ai.rb")
  end

  it "`require \"igniter/workspace\"` loads workspace support without the application runtime pack" do
    features = loaded_igniter_features("igniter/workspace")

    expect(features).to include("igniter/workspace.rb")
    expect(features).to include("igniter/application/workspace_pack.rb")
    expect(features).to include("igniter/application/workspace.rb")
    expect(features).not_to include("igniter/application.rb")
    expect(features).not_to include("igniter/application/runtime_pack.rb")
    expect(features).not_to include("igniter/application/server_host_pack.rb")
    expect(features).not_to include("igniter/server.rb")
    expect(features).not_to include("igniter/cluster.rb")
  end

  it "`require \"igniter/application/runtime\"` loads the application runtime without workspace support" do
    features = loaded_igniter_features("igniter/application/runtime")

    expect(features).to include("igniter/application/runtime.rb")
    expect(features).to include("igniter/application/runtime_pack.rb")
    expect(features).not_to include("igniter/application.rb")
    expect(features).not_to include("igniter/workspace.rb")
    expect(features).not_to include("igniter/application/workspace_pack.rb")
  end

  it "`require \"igniter/tools\"` opt-ins the built-in operational tool pack" do
    features = loaded_igniter_features("igniter/tools")

    expect(features).to include("igniter/tools.rb")
    expect(features).to include("igniter/core.rb")
    expect(features).to include("igniter/core/tool/system_discovery_tool.rb")
    expect(features).to include("igniter/core/tool/local_workflow_selector_tool.rb")
    expect(features).to include("igniter/core/tool/agent_bootstrap_tool.rb")
    expect(features).not_to include("igniter/server.rb")
    expect(features).not_to include("igniter/application.rb")
    expect(features).not_to include("igniter/cluster.rb")
    expect(features).not_to include("igniter/ai.rb")
  end

  it "`require \"igniter/server\"` does not mutate the runtime remote adapter by itself" do
    adapter_classes = runtime_remote_adapter_classes_for("igniter/server")

    expect(adapter_classes).to eq({
      "before" => "Igniter::Runtime::RemoteAdapter",
      "after" => "Igniter::Runtime::RemoteAdapter"
    })
  end

  it "`require \"igniter/application\"` registers only the server host profile" do
    host_names = registered_host_names_for("igniter/application")

    expect(host_names).to eq(["server"])
  end

  it "`require \"igniter/application\"` loads the default server host through its host pack" do
    features = loaded_igniter_features("igniter/application")

    expect(features).to include("igniter/application/runtime.rb")
    expect(features).to include("igniter/application/runtime_pack.rb")
    expect(features).to include("igniter/application/workspace_pack.rb")
    expect(features).to include("igniter/application/server_host_pack.rb")
    expect(features).to include("igniter/server/application_host.rb")
  end

  it "`require \"igniter/application\"` registers the default threaded scheduler pack" do
    scheduler_names = registered_scheduler_names_for("igniter/application")
    features = loaded_igniter_features("igniter/application")

    expect(scheduler_names).to eq(["threaded"])
    expect(features).to include("igniter/application/scheduler_pack.rb")
    expect(features).to include("igniter/application/threaded_scheduler_adapter.rb")
  end

  it "`require \"igniter/application\"` registers the default filesystem loader pack" do
    loader_names = registered_loader_names_for("igniter/application")
    features = loaded_igniter_features("igniter/application")

    expect(loader_names).to eq(["filesystem"])
    expect(features).to include("igniter/application/loader_pack.rb")
    expect(features).to include("igniter/application/filesystem_loader_adapter.rb")
    expect(features).not_to include("igniter/application/scaffold_pack.rb")
    expect(features).not_to include("igniter/application/generator.rb")
  end

  it "`require \"igniter/application/scaffold_pack\"` opt-ins the scaffold generator pack" do
    features = loaded_igniter_features("igniter/application/scaffold_pack")

    expect(features).to include("igniter/application/scaffold_pack.rb")
    expect(features).to include("igniter/application/generator.rb")
  end

  it "`require \"igniter/cluster\"` does not mutate the runtime remote adapter by itself" do
    adapter_classes = runtime_remote_adapter_classes_for("igniter/cluster")

    expect(adapter_classes).to eq({
      "before" => "Igniter::Runtime::RemoteAdapter",
      "after" => "Igniter::Runtime::RemoteAdapter"
    })
  end

  it "`require \"igniter/cluster\"` registers both server and cluster host profiles" do
    host_names = registered_host_names_for("igniter/cluster")

    expect(host_names).to eq(["cluster", "server"])
  end
end
