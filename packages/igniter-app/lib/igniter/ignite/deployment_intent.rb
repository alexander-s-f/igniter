# frozen_string_literal: true

module Igniter
  module Ignite
    class DeploymentIntent
      IGNITE_MODES = %i[cold_start expand].freeze
      STRATEGIES = %i[serial parallel].freeze
      APPROVAL_MODES = %i[required auto].freeze

      attr_reader :id, :ignite_mode, :strategy, :approval_mode, :target, :requested_capabilities,
                  :requested_by, :requested_from, :seed_node, :join_policy, :correlation, :metadata

      def initialize(id:, ignite_mode:, strategy:, approval_mode:, target:, requested_capabilities: [],
                     requested_by:, requested_from:, seed_node:, join_policy:, correlation:, metadata: {})
        @id = id.to_s.strip
        @ignite_mode = ignite_mode.to_sym
        @strategy = strategy.to_sym
        @approval_mode = approval_mode.to_sym
        @target = target
        @requested_capabilities = Array(requested_capabilities).map(&:to_sym).freeze
        @requested_by = immutable_hash(requested_by)
        @requested_from = immutable_hash(requested_from)
        @seed_node = immutable_hash(seed_node)
        @join_policy = immutable_hash(join_policy)
        @correlation = immutable_hash(correlation)
        @metadata = immutable_hash(metadata)

        validate!
        freeze
      end

      def local_replica?
        target.local_replica?
      end

      def ssh_server?
        target.ssh_server?
      end

      def to_h
        {
          id: id,
          ignite_mode: ignite_mode,
          strategy: strategy,
          approval_mode: approval_mode,
          target: target.to_h,
          requested_capabilities: requested_capabilities,
          requested_by: requested_by,
          requested_from: requested_from,
          seed_node: seed_node,
          join_policy: join_policy,
          correlation: correlation,
          metadata: metadata
        }
      end

      private

      def validate!
        raise ArgumentError, "deployment intent id cannot be empty" if id.empty?
        raise ArgumentError, "unknown ignite mode #{ignite_mode.inspect}" unless IGNITE_MODES.include?(ignite_mode)
        raise ArgumentError, "unknown ignite strategy #{strategy.inspect}" unless STRATEGIES.include?(strategy)
        raise ArgumentError, "unknown approval mode #{approval_mode.inspect}" unless APPROVAL_MODES.include?(approval_mode)
        raise ArgumentError, "deployment intent target must be an Igniter::Ignite::BootstrapTarget" unless target.is_a?(BootstrapTarget)
      end

      def immutable_hash(hash)
        Hash(hash).each_with_object({}) do |(key, value), result|
          result[key.to_s] =
            case value
            when Hash
              immutable_hash(value)
            when Array
              value.map { |item| item.is_a?(Hash) ? immutable_hash(item) : item }.freeze
            else
              value
            end
        end.freeze
      end
    end
  end
end
