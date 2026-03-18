# frozen_string_literal: true

module Igniter
  module Runtime
    class NodeState
      attr_reader :node, :status, :value, :error, :version, :resolved_at, :invalidated_by

      def initialize(node:, status:, value: nil, error: nil, version: nil, resolved_at: Time.now.utc, invalidated_by: nil)
        @node = node
        @status = status
        @value = value
        @error = error
        @version = version
        @resolved_at = resolved_at
        @invalidated_by = invalidated_by
      end

      def stale?
        status == :stale
      end

      def pending?
        status == :pending
      end

      def running?
        status == :running
      end

      def succeeded?
        status == :succeeded
      end

      def failed?
        status == :failed
      end
    end
  end
end
