# frozen_string_literal: true

module Igniter
  module Cluster
    module Replication
    # Immutable description of a specialised role a differentiated node can assume.
    #
    # When a node replicates with differentiation it carries a NodeRole that
    # shapes its remote configuration: which contracts to activate, which env
    # vars to inject, and which capability tags to advertise in the mesh.
    #
    # @example
    #   role = NodeRole.new(
    #     name:          :worker,
    #     contracts:     ["ComputeContract"],
    #     capabilities:  [:compute],
    #     env_overrides: { "WORKER_POOL" => "8" },
    #     tags:          [:cpu_heavy]
    #   )
    class NodeRole
      attr_reader :name, :contracts, :capabilities, :env_overrides, :tags

      def initialize(name:, contracts: [], capabilities: [], env_overrides: {}, tags: [])
        @name          = name.to_sym
        @contracts     = Array(contracts).map(&:to_s).freeze
        @capabilities  = Array(capabilities).map(&:to_sym).freeze
        @env_overrides = Hash(env_overrides).transform_keys(&:to_s).freeze
        @tags          = Array(tags).map(&:to_sym).freeze
        freeze
      end

      def to_h
        {
          name:          @name,
          contracts:     @contracts,
          capabilities:  @capabilities,
          env_overrides: @env_overrides,
          tags:          @tags
        }
      end
    end
    end
  end
end
