# frozen_string_literal: true

require_relative "sdk"
require_relative "server"
require_relative "cluster/mesh"
require_relative "cluster/remote_adapter"
require_relative "cluster/events"
require_relative "cluster/ownership"
require_relative "cluster/projection_store"
require_relative "cluster/consensus"
require_relative "cluster/replication"

module Igniter
  module Cluster
    class << self
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

Igniter::Runtime.remote_adapter = Igniter::Cluster::RemoteAdapter.new
