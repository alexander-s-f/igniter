# frozen_string_literal: true

require_relative "../../igniter"
require "igniter/core"
require_relative "consensus/errors"
require_relative "consensus/state_machine"
require_relative "consensus/node"
require_relative "consensus/cluster"
require_relative "consensus/executors"
require_relative "consensus/read_query"

module Igniter
  module Cluster
    # Consensus protocol primitives built on Igniter::Agent and Igniter::Contract.
    module Consensus
    end
  end
end
