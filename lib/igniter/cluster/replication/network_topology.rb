# frozen_string_literal: true

module Igniter
  module Cluster
    module Replication
    # Thread-safe in-memory registry of known nodes in the deployment network.
    #
    # Updated by ReflectiveReplicationAgent as nodes are spawned, heartbeat-ed,
    # or removed. Can be shared across agent handler invocations via state.
    #
    # @example
    #   topology = NetworkTopology.new
    #   topology.register(node_id: "abc", host: "10.0.0.2", role: :worker)
    #   topology.nodes(role: :worker)      # => [NodeEntry]
    #   topology.needs_role?(:coordinator) # => true
    class NetworkTopology
      # Mutable record for a single live node (mutated only inside the Mutex).
      NodeEntry = Struct.new(:node_id, :host, :role,
                             :registered_at, :last_seen_at, :healthy,
                             keyword_init: true)

      def initialize
        @nodes = {}
        @mutex = Mutex.new
      end

      # Register or overwrite a node entry.
      #
      # @param node_id [String]
      # @param host    [String]
      # @param role    [Symbol, nil]
      # @return [NodeEntry]
      def register(node_id:, host:, role: nil)
        now   = Time.now
        entry = NodeEntry.new(
          node_id:       node_id,
          host:          host,
          role:          role&.to_sym,
          registered_at: now,
          last_seen_at:  now,
          healthy:       true
        )
        @mutex.synchronize { @nodes[node_id] = entry }
        entry
      end

      # Update last_seen_at for a known node (heartbeat).
      #
      # @param node_id [String]
      # @return [Boolean] true if the node was found
      def touch(node_id:)
        @mutex.synchronize do
          entry = @nodes[node_id]
          return false unless entry

          entry.last_seen_at = Time.now
          true
        end
      end

      # Mark a node as unhealthy (e.g. SSH unreachable).
      #
      # @param node_id [String]
      # @return [Boolean] true if the node was found
      def mark_unhealthy(node_id:)
        @mutex.synchronize do
          entry = @nodes[node_id]
          return false unless entry

          entry.healthy = false
          true
        end
      end

      # Remove a node from the topology.
      #
      # @param node_id [String]
      # @return [NodeEntry, nil] the removed entry, or nil if not found
      def remove(node_id:)
        @mutex.synchronize { @nodes.delete(node_id) }
      end

      # Return nodes, optionally filtered by role.
      #
      # @param role [Symbol, nil]
      # @return [Array<NodeEntry>]
      def nodes(role: nil)
        @mutex.synchronize do
          entries = @nodes.values.dup
          role ? entries.select { |e| e.role == role.to_sym } : entries
        end
      end

      # True when no healthy node with the given role exists.
      #
      # @param role [Symbol, String]
      # @return [Boolean]
      def needs_role?(role)
        nodes(role: role).none?(&:healthy)
      end

      # Count of healthy nodes across all roles.
      #
      # @return [Integer]
      def healthy_count
        @mutex.synchronize { @nodes.values.count(&:healthy) }
      end

      # Total number of registered nodes.
      #
      # @return [Integer]
      def size
        @mutex.synchronize { @nodes.size }
      end

      # All registered node IDs.
      #
      # @return [Array<String>]
      def node_ids
        @mutex.synchronize { @nodes.keys.dup }
      end
    end
    end
  end
end
