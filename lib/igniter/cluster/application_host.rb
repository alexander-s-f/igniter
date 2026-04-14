# frozen_string_literal: true

require_relative "../app/host_registry"
require_relative "../app/cluster_host"

module Igniter
  module Cluster
    Igniter::Application::HostRegistry.register(:cluster) do
      Igniter::Application::ClusterHost.new
    end
  end
end
