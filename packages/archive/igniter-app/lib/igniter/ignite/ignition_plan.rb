# frozen_string_literal: true

module Igniter
  module Ignite
    class IgnitionPlan
      attr_reader :id, :ignite_mode, :strategy, :approval_mode, :intents, :requested_by, :requested_from,
                  :seed_node, :metadata

      def initialize(id:, ignite_mode:, strategy:, approval_mode:, intents:, requested_by:, requested_from:, seed_node:, metadata: {})
        @id = id.to_s.strip
        @ignite_mode = ignite_mode.to_sym
        @strategy = strategy.to_sym
        @approval_mode = approval_mode.to_sym
        @intents = Array(intents).freeze
        @requested_by = immutable_hash(requested_by)
        @requested_from = immutable_hash(requested_from)
        @seed_node = immutable_hash(seed_node)
        @metadata = immutable_hash(metadata)

        validate!
        freeze
      end

      def local_replica_intents
        intents.select(&:local_replica?)
      end

      def remote_intents
        intents.reject(&:local_replica?)
      end

      def approval_required?
        approval_mode == :required
      end

      def empty?
        intents.empty?
      end

      def to_h
        {
          id: id,
          ignite_mode: ignite_mode,
          strategy: strategy,
          approval_mode: approval_mode,
          intents: intents.map(&:to_h),
          requested_by: requested_by,
          requested_from: requested_from,
          seed_node: seed_node,
          metadata: metadata,
          summary: {
            total_intents: intents.size,
            local_replicas: local_replica_intents.size,
            remote_targets: remote_intents.size
          }
        }
      end

      private

      def validate!
        raise ArgumentError, "ignition plan id cannot be empty" if id.empty?
        unless intents.all? { |intent| intent.is_a?(DeploymentIntent) }
          raise ArgumentError, "ignition plan intents must be Igniter::Ignite::DeploymentIntent objects"
        end
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
