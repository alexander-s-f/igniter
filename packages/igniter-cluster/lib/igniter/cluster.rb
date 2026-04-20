# frozen_string_literal: true

require "igniter/core"
require "igniter/agent"
require "igniter/core/contract"
require "igniter/core/dsl"
require "igniter/core/model"
require "igniter/core/compiler"
require "igniter/core/type_system"
require "igniter/core/diagnostics"
require "igniter/core/memory"
require "igniter/sdk"
require "igniter/server"
require_relative "cluster/governance"
require_relative "cluster/identity"
require_relative "cluster/trust"
require_relative "cluster/mesh"
require_relative "cluster/remote_adapter"
require_relative "cluster/agent_route_resolver"
require_relative "cluster/routed_agent_adapter"
require_relative "cluster/events"
require_relative "cluster/ownership"
require_relative "cluster/projection_store"
require_relative "cluster/routing_plan_result"
require_relative "cluster/routing_plan_executor"
require_relative "cluster/consensus"
require_relative "cluster/replication"
require_relative "cluster/diagnostics"
require_relative "cluster/rag"

module Igniter
  module Cluster
    class << self
      def remote_adapter
        @remote_adapter ||= RemoteAdapter.new
      end

      def activate_remote_adapter!
        Igniter::Runtime.remote_adapter = remote_adapter
      end

      def agent_adapter
        @agent_adapter ||= RoutedAgentAdapter.new
      end

      def activate_agent_adapter!
        Igniter::Runtime.agent_adapter = agent_adapter
      end

      def deactivate_remote_adapter!
        Igniter::Runtime.remote_adapter = Igniter::Runtime::RemoteAdapter.new
      end

      def deactivate_agent_adapter!
        Igniter::Runtime.agent_adapter = Igniter::Runtime::RegistryAgentAdapter.new
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
