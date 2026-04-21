# frozen_string_literal: true

module Igniter
  class App
    module Credentials
      class Credential
        attr_reader :key, :label, :provider, :scope, :node, :policy, :metadata

        def initialize(key:, label:, provider:, scope:, policy:, node: nil, metadata: {})
          @key = key.to_sym
          @label = label.to_s
          @provider = provider.to_sym
          @scope = scope.to_sym
          @node = node&.to_s
          @policy = normalize_policy(policy)
          @metadata = normalize_metadata(metadata)
          freeze
        end

        def self.from_h(credential_hash)
          normalized = (credential_hash || {}).each_with_object({}) do |(key, value), memo|
            memo[key.to_sym] = value
          end

          new(
            key: normalized.fetch(:key),
            label: normalized.fetch(:label),
            provider: normalized.fetch(:provider),
            scope: normalized.fetch(:scope),
            node: normalized[:node],
            policy: normalized.fetch(:policy),
            metadata: normalized.fetch(:metadata, {})
          )
        end

        def local?
          scope == :local
        end

        def remote?
          !local?
        end

        def allowed_in_scope?(target_scope)
          policy.allows_scope?(target_scope)
        end

        def with(**overrides)
          self.class.new(
            key: overrides.fetch(:key, key),
            label: overrides.fetch(:label, label),
            provider: overrides.fetch(:provider, provider),
            scope: overrides.fetch(:scope, scope),
            node: overrides.fetch(:node, node),
            policy: overrides.fetch(:policy, policy),
            metadata: metadata.merge(normalize_metadata(overrides.fetch(:metadata, {})))
          )
        end

        def to_h
          {
            key: key,
            label: label,
            provider: provider,
            scope: scope,
            node: node,
            policy: policy.to_h,
            metadata: metadata
          }.compact.freeze
        end

        private

        def normalize_policy(value)
          case value
          when CredentialPolicy
            value
          when Hash
            CredentialPolicy.from_h(value)
          else
            raise ArgumentError, "policy must be a CredentialPolicy or Hash"
          end
        end

        def normalize_metadata(hash)
          (hash || {}).each_with_object({}) do |(key, value), memo|
            memo[key.to_sym] = value
          end.freeze
        end
      end
    end
  end
end
