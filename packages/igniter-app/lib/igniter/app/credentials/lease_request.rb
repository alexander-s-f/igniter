# frozen_string_literal: true

require "securerandom"
require "time"

module Igniter
  class App
    module Credentials
      class LeaseRequest < Igniter::DTO::Record
        field :request_id, default: -> { SecureRandom.uuid }, coerce: ->(value) { value.to_s }
        field :credential, required: true, coerce: :normalize_credential
        field :requested_scope, default: :remote, coerce: ->(value) { value.to_sym }
        field :node, coerce: ->(value) { value&.to_s }
        field :target_node, required: true, coerce: ->(value) { value.to_s }
        field :actor, coerce: ->(value) { value&.to_s }
        field :origin, coerce: ->(value) { value&.to_s }
        field :source, required: true, coerce: ->(value) { value&.to_sym }
        field :reason, coerce: ->(value) { value&.to_sym }
        field :lease_id, coerce: ->(value) { value&.to_s }
        field :requested_at, default: -> { Time.now.utc.iso8601 }, coerce: :normalize_timestamp
        field :metadata, default: -> { {} }, coerce: :normalize_metadata, merge: true

        def initialize(**attributes)
          normalized = self.class.send(:normalize_input_attributes, attributes)
          normalized[:credential] = self.class.send(:normalize_credential, normalized[:credential]) if normalized.key?(:credential)
          if normalized[:node].nil? && normalized[:credential].respond_to?(:node)
            normalized[:node] = normalized[:credential].node
          end

          super(**normalized)
        end

        def credential_key
          credential.key
        end

        def policy_name
          credential.policy.name
        end

        def policy
          credential.policy
        end

        def policy_allows_request?
          credential.allowed_in_scope?(requested_scope)
        end

        def local_request?
          requested_scope == :local
        end

        def remote_request?
          !local_request?
        end

        def request_event
          build_event(:lease_requested, timestamp: requested_at)
        end

        def issue_event(lease_id: nil, actor: nil, origin: nil, source: nil, metadata: {}, timestamp: Time.now.utc.iso8601)
          build_event(
            :lease_issued,
            lease_id: lease_id || self.lease_id,
            actor: actor || self.actor,
            origin: origin || self.origin,
            source: source || self.source,
            metadata: self.metadata.merge(self.class.send(:normalize_metadata, metadata)),
            timestamp: timestamp
          )
        end

        def deny_event(reason:, actor: nil, origin: nil, source: nil, metadata: {}, timestamp: Time.now.utc.iso8601)
          build_event(
            :lease_denied,
            actor: actor || self.actor,
            origin: origin || self.origin,
            source: source || self.source,
            reason: reason,
            metadata: self.metadata.merge(self.class.send(:normalize_metadata, metadata)),
            timestamp: timestamp
          )
        end

        def revoke_event(lease_id: nil, reason: nil, actor: nil, origin: nil, source: nil, metadata: {}, timestamp: Time.now.utc.iso8601)
          build_event(
            :lease_revoked,
            lease_id: lease_id || self.lease_id,
            actor: actor || self.actor,
            origin: origin || self.origin,
            source: source || self.source,
            reason: reason || self.reason,
            metadata: self.metadata.merge(self.class.send(:normalize_metadata, metadata)),
            timestamp: timestamp
          )
        end

        private

        def build_event(event_name, lease_id: self.lease_id, actor: self.actor, origin: self.origin,
                        source: self.source, reason: self.reason, metadata: self.metadata,
                        timestamp: Time.now.utc.iso8601)
          Events::CredentialEvent.new(
            event: event_name,
            credential_key: credential_key,
            policy_name: policy_name,
            node: node,
            target_node: target_node,
            lease_id: lease_id,
            actor: actor,
            origin: origin,
            source: source,
            reason: reason,
            timestamp: timestamp,
            metadata: metadata.merge(
              credential_provider: credential.provider,
              requested_scope: requested_scope,
              request_id: request_id
            )
          )
        end

        def self.normalize_credential(value)
          case value
          when Credential
            value
          when Hash
            Credential.from_h(value)
          else
            raise ArgumentError, "credential must be a Credential or Hash"
          end
        end

        def self.normalize_timestamp(value)
          case value
          when Time
            value.utc.iso8601
          else
            Time.parse(value.to_s).utc.iso8601
          end
        rescue ArgumentError
          Time.now.utc.iso8601
        end

        def self.normalize_metadata(hash)
          (hash || {}).each_with_object({}) do |(key, value), memo|
            memo[key.to_sym] = value
          end.freeze
        end
      end
    end
  end
end
