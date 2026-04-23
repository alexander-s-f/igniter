# frozen_string_literal: true

module Igniter
  module Runtime
    class NodeState
      attr_reader :node, :status, :value, :error, :version, :value_version,
                  :resolved_at, :invalidated_by, :dep_snapshot, :details

      def initialize(node:, status:, value: nil, error: nil, version: nil, value_version: nil, # rubocop:disable Metrics/ParameterLists
                     resolved_at: Time.now.utc, invalidated_by: nil, dep_snapshot: nil, details: {})
        @node = node
        @status = status
        @value = value
        @error = error
        @version = version
        @value_version = value_version
        @resolved_at = resolved_at
        @invalidated_by = invalidated_by
        @dep_snapshot = dep_snapshot
        @details = (details || {}).freeze
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

      def to_h
        {
          node_name: node.name,
          status: status,
          version: version,
          value_version: value_version,
          resolved_at: resolved_at,
          invalidated_by: invalidated_by,
          details: details,
          value: value,
          error: error
        }
      end
    end
  end
end
