# frozen_string_literal: true

require_relative "sdk"
require_relative "server"
require_relative "application/cluster_host"
require_relative "cluster/mesh"
require_relative "cluster/remote_adapter"
require_relative "cluster/events"
require_relative "cluster/ownership"
require_relative "cluster/projection_store"
require_relative "cluster/consensus"
require_relative "cluster/replication"

module Igniter
  module Cluster
    ApplicationHost = Igniter::Application::ClusterHost unless const_defined?(:ApplicationHost, false)

    class << self
      def remote_adapter
        @remote_adapter ||= RemoteAdapter.new
      end

      def activate_remote_adapter!
        Igniter::Runtime.remote_adapter = remote_adapter
      end

      def deactivate_remote_adapter!
        Igniter::Runtime.remote_adapter = Igniter::Runtime::RemoteAdapter.new
      end

      def use(*names)
        resolved_names = names.flatten.map(&:to_sym)
        Igniter::SDK.activate!(*resolved_names, layer: :cluster)
        @sdk_capabilities ||= []
        @sdk_capabilities |= resolved_names
        self
      end

      def sdk_capabilities
        @sdk_capabilities ||= []
      end
    end
  end
end
