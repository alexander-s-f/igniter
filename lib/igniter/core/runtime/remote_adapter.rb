# frozen_string_literal: true

module Igniter
  module Runtime
    # Base transport seam for remote nodes.
    #
    # Core runtime delegates remote execution to this adapter instead of
    # directly knowing about HTTP clients, mesh routing, or cluster topology.
    class RemoteAdapter
      def call(node:, inputs:, execution: nil) # rubocop:disable Lint/UnusedMethodArgument
        raise ResolutionError,
              "remote :#{node.name} requires a configured transport adapter. " \
              "Add `require 'igniter/server'` or set `Igniter::Runtime.remote_adapter`."
      end
    end

    class << self
      attr_writer :remote_adapter

      def remote_adapter
        @remote_adapter ||= RemoteAdapter.new
      end
    end
  end
end
