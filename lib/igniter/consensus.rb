# frozen_string_literal: true

require "igniter"
require "igniter/integrations/agents"
require_relative "consensus/errors"
require_relative "consensus/state_machine"
require_relative "consensus/node"
require_relative "consensus/cluster"
require_relative "consensus/executors"
require_relative "consensus/read_query"

module Igniter
  # Consensus protocol primitives built on Igniter::Agent and Igniter::Contract.
  #
  # Provides a Raft-inspired cluster where:
  # - +Igniter::Consensus::Node+  encapsulates the full Raft protocol as an Agent
  # - +Igniter::Consensus::Cluster+ manages node lifecycle + high-level read/write
  # - +Igniter::Consensus::StateMachine+ lets users define custom command reducers
  # - +Igniter::Consensus::ReadQuery+ is a ready-made Contract for cluster reads
  #
  # == Minimal example
  #
  #   require "igniter/consensus"
  #
  #   cluster = Igniter::Consensus::Cluster.start(nodes: %i[n1 n2 n3 n4 n5])
  #   cluster.wait_for_leader
  #
  #   cluster.write(key: :price, value: 99)   # default KV protocol
  #   cluster.read(:price)                     # => 99
  #
  #   cluster.stop!
  #
  # == Custom state machine
  #
  #   class PriceStore < Igniter::Consensus::StateMachine
  #     apply :set    do |state, cmd| state.merge(cmd[:key] => cmd[:value]) end
  #     apply :delete do |state, cmd| state.reject { |k, _| k == cmd[:key] } end
  #   end
  #
  #   cluster = Igniter::Consensus::Cluster.start(
  #     nodes: %i[n1 n2 n3 n4 n5],
  #     state_machine: PriceStore,
  #   )
  #   cluster.write(type: :set, key: :price, value: 99)
  #
  # == Contract integration
  #
  #   class PriceCheck < Igniter::Contract
  #     define do
  #       input :cluster
  #       compute :leader, with: :cluster, call: Igniter::Consensus::FindLeader
  #       compute :price,  with: [:leader], call: MyPriceReader
  #       output :price
  #     end
  #   end
  module Consensus
  end
end
