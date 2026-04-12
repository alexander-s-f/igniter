# frozen_string_literal: true

require_relative "server"
require_relative "cluster/mesh"
require_relative "cluster/remote_adapter"
require_relative "cluster/consensus"
require_relative "cluster/replication"

module Igniter
  module Cluster
  end
end

Igniter::Runtime.remote_adapter = Igniter::Cluster::RemoteAdapter.new
