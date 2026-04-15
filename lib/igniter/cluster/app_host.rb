# frozen_string_literal: true

require_relative "../app/host_registry"
require_relative "../app/cluster_app_host"

module Igniter
  module Cluster
    Igniter::Application::HostRegistry.register(:cluster_app) do
      Igniter::Application::ClusterAppHost.new
    end
  end
end
