# frozen_string_literal: true

require_relative "host_registry"
require_relative "app_host"
require_relative "cluster_app_host"

Igniter::App::HostRegistry.register(:app) do
  Igniter::App::AppHost.new
end

Igniter::App::HostRegistry.register(:cluster_app) do
  Igniter::App::ClusterAppHost.new
end
