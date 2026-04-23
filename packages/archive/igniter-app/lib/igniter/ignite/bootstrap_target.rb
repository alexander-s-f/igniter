# frozen_string_literal: true

module Igniter
  module Ignite
    class BootstrapTarget
      KINDS = %i[local_replica ssh_server].freeze

      attr_reader :id, :kind, :locator, :base_server, :capability_intent, :bootstrap_requirements, :metadata

      def initialize(id:, kind:, locator:, base_server:, capability_intent: [], bootstrap_requirements: {}, metadata: {})
        @id = id.to_s.strip
        @kind = kind.to_sym
        @locator = immutable_hash(locator)
        @base_server = immutable_hash(base_server)
        @capability_intent = Array(capability_intent).map(&:to_sym).freeze
        @bootstrap_requirements = immutable_hash(bootstrap_requirements)
        @metadata = immutable_hash(metadata)

        validate!
        freeze
      end

      def local_replica?
        kind == :local_replica
      end

      def ssh_server?
        kind == :ssh_server
      end

      def server_settings
        return base_server unless local_replica?

        base_server.merge(extract_server_overrides(locator)).freeze
      end

      def to_h
        {
          id: id,
          kind: kind,
          locator: locator,
          base_server: base_server,
          capability_intent: capability_intent,
          bootstrap_requirements: bootstrap_requirements,
          metadata: metadata
        }
      end

      private

      def validate!
        raise ArgumentError, "bootstrap target id cannot be empty" if id.empty?
        raise ArgumentError, "unknown bootstrap target kind #{kind.inspect}" unless KINDS.include?(kind)
      end

      def extract_server_overrides(hash)
        hash.each_with_object({}) do |(key, value), result|
          next unless %w[host port].include?(key)

          result[key] = value
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
