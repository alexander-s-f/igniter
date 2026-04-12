# frozen_string_literal: true

module Igniter
  module Cluster
    module Replication
    # Module-level registry of named NodeRoles.
    #
    # @example
    #   RoleRegistry.define(:worker,
    #     contracts:     ["ComputeContract"],
    #     capabilities:  [:compute],
    #     env_overrides: { "WORKER_POOL" => "4" }
    #   )
    #
    #   role = RoleRegistry.fetch(:worker)
    #   role.env_overrides  # => { "WORKER_POOL" => "4" }
    module RoleRegistry
      @roles = {}

      class << self
        # Define and register a new role.
        #
        # @param name          [Symbol, String]
        # @param contracts     [Array<String>]
        # @param capabilities  [Array<Symbol>]
        # @param env_overrides [Hash]
        # @param tags          [Array<Symbol>]
        # @return [NodeRole]
        def define(name, contracts: [], capabilities: [], env_overrides: {}, tags: [])
          role = NodeRole.new(
            name:          name,
            contracts:     contracts,
            capabilities:  capabilities,
            env_overrides: env_overrides,
            tags:          tags
          )
          @roles[role.name] = role
        end

        # Fetch a role by name.
        #
        # @param name [Symbol, String]
        # @return [NodeRole]
        # @raise [ArgumentError] if not registered
        def fetch(name)
          @roles.fetch(name.to_sym) do
            raise ArgumentError,
                  "Unknown role: #{name}. Available: #{@roles.keys.join(", ")}"
          end
        end

        # Returns true if a role with the given name is registered.
        #
        # @param name [Symbol, String]
        # @return [Boolean]
        def registered?(name)
          @roles.key?(name.to_sym)
        end

        # All registered roles (copy to prevent external mutation).
        #
        # @return [Hash{Symbol => NodeRole}]
        def all
          @roles.dup
        end

        # Remove all registrations. Useful in tests.
        def reset!
          @roles = {}
        end
      end
    end
    end
  end
end
