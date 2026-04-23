# frozen_string_literal: true

module Igniter
  module Cluster
    module Consensus
    # Finds the current leader in a Cluster.
    # Raises +Igniter::ResolutionError+ if no leader is available —
    # the Resolver will enrich the error with graph/node context.
    class FindLeader < Igniter::Executor
      def call(cluster:)
        ref = cluster.leader
        raise Igniter::ResolutionError, "No leader in cluster — retry later" unless ref
        s = ref.state
        { ref: ref, term: s[:term], node_id: s[:node_id] }
      end
    end

    # Reads a single key from the leader's committed state machine.
    class ReadValue < Igniter::Executor
      def call(leader:, key:)
        leader[:ref].state[:state_machine][key]
      end
    end

    # Submits an arbitrary command to the consensus log and returns the command.
    # Useful for fan-out patterns (e.g., multiple parallel writes in a Contract).
    #
    # Receives +cluster:+ plus any additional named keyword arguments; those
    # extra kwargs become the command body:
    #
    #   compute :write1, with: [:cluster, :cmd1], call: SubmitCommand
    #
    # The executor forwards +:cluster+ as the Cluster ref and treats all other
    # keyword arguments as the command payload.
    class SubmitCommand < Igniter::Executor
      def call(cluster:, **command_kwargs)
        ref = cluster.leader
        raise Igniter::ResolutionError, "No leader — cannot submit command" unless ref
        ref.send(:client_write, command: command_kwargs)
        command_kwargs
      end
    end
    end
  end
end
