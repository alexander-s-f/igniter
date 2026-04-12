# frozen_string_literal: true

module Igniter
  module Cluster
    module Consensus
    # Manages a consensus cluster: node lifecycle, leader discovery,
    # high-level read/write, quorum checks, and Igniter::Contract integration.
    #
    # == Quick start (default KV state machine)
    #
    #   cluster = Igniter::Cluster::Consensus::Cluster.start(nodes: %i[n1 n2 n3 n4 n5])
    #   cluster.wait_for_leader
    #   cluster.write(key: :price, value: 99)
    #   cluster.read(:price)   # => 99
    #   cluster.stop!
    #
    # == Custom state machine
    #
    #   class OrderBook < Igniter::Cluster::Consensus::StateMachine
    #     apply :add    do |state, cmd| state.merge(cmd[:id] => cmd[:data]) end
    #     apply :cancel do |state, cmd| state.reject { |k, _| k == cmd[:id] } end
    #   end
    #
    #   cluster = Igniter::Cluster::Consensus::Cluster.start(
    #     nodes: %i[n1 n2 n3 n4 n5],
    #     state_machine: OrderBook,
    #   )
    #   cluster.write(type: :add, id: "o1", data: { price: 42 })
    #   cluster.read("o1")   # => { price: 42 }
    #
    # == Contract integration
    #
    #   q = cluster.read_contract(key: :price)
    #   q.resolve_all
    #   q.result.value   # => 99
    class Cluster
      attr_reader :node_ids, :state_machine_class

      # Start a cluster. Does NOT wait for leader election.
      # Call +wait_for_leader+ if you need a leader before proceeding.
      #
      # @param nodes          [Array<Symbol>] Registry names for each node
      # @param state_machine  [Class]         StateMachine subclass (default: StateMachine)
      # @param verbose        [Boolean]       print Raft events to stdout
      def self.start(nodes:, state_machine: nil, verbose: false)
        new(nodes: nodes, state_machine: state_machine, verbose: verbose).tap(&:start!)
      end

      def initialize(nodes:, state_machine: nil, verbose: false)
        @node_ids            = nodes.freeze
        @state_machine_class = state_machine || StateMachine
        @verbose             = verbose
      end

      # Start all nodes.
      def start!
        @node_ids.each do |nid|
          Node.start(
            name:          nid,
            peers:         @node_ids.reject { |id| id == nid },
            state_machine: @state_machine_class,
            verbose:       @verbose,
          )
        end
        self
      end

      # Stop all nodes gracefully.
      def stop!(timeout: 2)
        @node_ids.each do |nid|
          begin
            Igniter::Registry.find(nid)&.stop(timeout: timeout)
            Igniter::Registry.unregister(nid)
          rescue StandardError
            nil
          end
        end
        self
      end

      # Returns the Ref for the current leader, or +nil+ if none is available.
      def leader
        @node_ids.each do |nid|
          ref = Igniter::Registry.find(nid)
          next unless ref&.alive?
          return ref if ref.state[:role] == :leader
        end
        nil
      end

      # Block until a leader is elected or +timeout+ seconds elapse.
      #
      # @param timeout [Float] seconds to wait (default: ~2s, covers max election jitter)
      # @return [Agent::Ref] the leader Ref
      # @raise [NoLeaderError] if no leader is elected within the timeout
      def wait_for_leader(timeout: ELECTION_TIMEOUT_BASE + ELECTION_TIMEOUT_JITTER + 0.5)
        deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + timeout
        loop do
          ref = leader
          return ref if ref

          remaining = deadline - Process.clock_gettime(Process::CLOCK_MONOTONIC)
          raise NoLeaderError, "No leader elected within #{timeout}s — cluster may lack quorum" if remaining <= 0

          sleep 0.05
        end
      end

      # Submit a command to the consensus log via the current leader.
      #
      # Default KV protocol:   +cluster.write(key: :x, value: 42)+
      # Custom state machine:  +cluster.write(type: :add_order, id: "o1", data: {...})+
      #
      # @raise [NoLeaderError] if no leader is currently available
      def write(command = {})
        raise NoLeaderError, "No quorum available — cluster cannot commit writes" unless has_quorum?

        ref = leader
        raise NoLeaderError, "No leader available — cluster may be electing or lacks quorum" unless ref
        ref.send(:client_write, command: command)
        self
      end

      # Read a key from the current leader's committed state machine.
      #
      # @raise [NoLeaderError] if no leader is available
      def read(key)
        ref = leader
        raise NoLeaderError, "No leader available" unless ref
        ref.state[:state_machine][key]
      end

      # Return a snapshot of the full state machine from the current leader.
      #
      # @raise [NoLeaderError] if no leader is available
      def state_machine_snapshot
        ref = leader
        raise NoLeaderError, "No leader available" unless ref
        ref.state[:state_machine].dup
      end

      # Number of alive nodes.
      def alive_count
        @node_ids.count { |nid| Igniter::Registry.find(nid)&.alive? }
      end

      # Minimum votes required for any Raft decision (⌊N/2⌋ + 1).
      def quorum_size
        (@node_ids.size / 2) + 1
      end

      # Returns +true+ if enough nodes are alive to elect a leader.
      def has_quorum?
        alive_count >= quorum_size
      end

      # Returns a +ReadQuery+ contract pre-configured for this cluster and key.
      # Resolve it like any Igniter::Contract:
      #
      #   q = cluster.read_contract(key: :price)
      #   q.resolve_all
      #   q.result.value   # => 99
      def read_contract(key:)
        ReadQuery.new(cluster: self, key: key)
      end

      # Status snapshot for every alive node in the cluster.
      # @return [Array<Hash>] one hash per alive node
      def status
        @node_ids.filter_map do |nid|
          ref = Igniter::Registry.find(nid)
          next unless ref&.alive?
          s = ref.state
          {
            node_id:      s[:node_id],
            role:         s[:role],
            term:         s[:term],
            commit_index: s[:commit_index],
            log_size:     s[:log].size,
            state_machine: s[:state_machine],
          }
        end
      end
    end
    end
  end
end
