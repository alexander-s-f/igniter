# frozen_string_literal: true

require_relative "../application/host_registry"
require_relative "../application/cluster_host"

module Igniter
  module Cluster
    Igniter::Application::HostRegistry.register(:cluster) do
      Igniter::Application::ClusterHost.new
    end

    ApplicationHost = Igniter::Application::ClusterHost unless const_defined?(:ApplicationHost, false)
  end
end
