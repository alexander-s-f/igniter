# frozen_string_literal: true

module Igniter
  module Cluster
    module Consensus
    # Built-in single-shot read Contract. Dependency graph: find_leader → read_value.
    #
    # Prefer +Cluster#read_contract+ for convenience:
    #
    #   q = cluster.read_contract(key: :price)
    #   q.resolve_all
    #   q.result.value   # => 99
    #
    # Or instantiate directly:
    #
    #   q = Igniter::Cluster::Consensus::ReadQuery.new(cluster: my_cluster, key: :price)
    #   q.resolve_all
    #   q.result.value   # => 99
    class ReadQuery < Igniter::Contract
      define do
        input :cluster   # Igniter::Cluster::Consensus::Cluster
        input :key       # key to read from the state machine

        compute :leader, with: :cluster,        call: FindLeader
        compute :value,  with: [:leader, :key], call: ReadValue

        output :value
      end
    end
    end
  end
end
