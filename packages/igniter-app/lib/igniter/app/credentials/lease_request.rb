# frozen_string_literal: true

require "securerandom"
require "time"

module Igniter
  class App
    module Credentials
      class LeaseRequest
        attr_reader :request_id, :credential, :requested_scope, :node, :target_node, :actor, :origin,
                    :source, :reason, :lease_id, :requested_at, :metadata

        def initialize(credential:, target_node:, request_id: SecureRandom.uuid, requested_scope: :remote, node: nil,
                       actor: nil, origin: nil, source:, reason: nil, lease_id: nil,
                       requested_at: Time.now.utc.iso8601, metadata: {})
          @request_id = request_id.to_s
          @credential = normalize_credential(credential)
          @requested_scope = requested_scope.to_sym
          @node = (node || @credential.node)&.to_s
          @target_node = target_node.to_s
          @actor = actor&.to_s
          @origin = origin&.to_s
          @source = source&.to_sym
          @reason = reason&.to_sym
          @lease_id = lease_id&.to_s
          @requested_at = normalize_timestamp(requested_at)
          @metadata = normalize_metadata(metadata)
          freeze
        end

        def self.from_h(request_hash)
          normalized = (request_hash || {}).each_with_object({}) do |(key, value), memo|
            memo[key.to_sym] = value
          end

          new(
            credential: normalized.fetch(:credential),
            request_id: normalized.fetch(:request_id),
            requested_scope: normalized.fetch(:requested_scope, :remote),
            node: normalized[:node],
            target_node: normalized.fetch(:target_node),
            actor: normalized[:actor],
            origin: normalized[:origin],
            source: normalized.fetch(:source),
            reason: normalized[:reason],
            lease_id: normalized[:lease_id],
            requested_at: normalized[:requested_at],
            metadata: normalized.fetch(:metadata, {})
          )
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
            metadata: self.metadata.merge(normalize_metadata(metadata)),
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
            metadata: self.metadata.merge(normalize_metadata(metadata)),
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
            metadata: self.metadata.merge(normalize_metadata(metadata)),
            timestamp: timestamp
          )
        end

        def with(**overrides)
          self.class.new(
            credential: overrides.fetch(:credential, credential),
            request_id: overrides.fetch(:request_id, request_id),
            requested_scope: overrides.fetch(:requested_scope, requested_scope),
            node: overrides.fetch(:node, node),
            target_node: overrides.fetch(:target_node, target_node),
            actor: overrides.fetch(:actor, actor),
            origin: overrides.fetch(:origin, origin),
            source: overrides.fetch(:source, source),
            reason: overrides.fetch(:reason, reason),
            lease_id: overrides.fetch(:lease_id, lease_id),
            requested_at: overrides.fetch(:requested_at, requested_at),
            metadata: metadata.merge(normalize_metadata(overrides.fetch(:metadata, {})))
          )
        end

        def to_h
          {
            request_id: request_id,
            credential: credential.to_h,
            requested_scope: requested_scope,
            node: node,
            target_node: target_node,
            actor: actor,
            origin: origin,
            source: source,
            reason: reason,
            lease_id: lease_id,
            requested_at: requested_at,
            metadata: metadata
          }.compact.freeze
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

        def normalize_credential(value)
          case value
          when Credential
            value
          when Hash
            Credential.from_h(value)
          else
            raise ArgumentError, "credential must be a Credential or Hash"
          end
        end

        def normalize_timestamp(value)
          case value
          when Time
            value.utc.iso8601
          else
            Time.parse(value.to_s).utc.iso8601
          end
        rescue ArgumentError
          Time.now.utc.iso8601
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
