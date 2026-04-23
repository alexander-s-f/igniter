# frozen_string_literal: true

require "time"

module Igniter
  class App
    module Credentials
      module Events
        class CredentialEvent
          EVENT_TYPES = %i[
            lease_requested
            lease_issued
            lease_denied
            lease_used
            lease_revoked
            replication_requested
            replication_denied
            replication_revoked
            access_denied
          ].freeze

          STATUS_TYPES = %i[
            requested
            issued
            denied
            used
            revoked
          ].freeze

          attr_reader :event, :status, :credential_key, :policy_name, :node, :target_node,
                      :lease_id, :actor, :origin, :source, :reason, :timestamp, :metadata

          def initialize(event:, credential_key:, policy_name:, status: nil, node: nil, target_node: nil,
                         lease_id: nil, actor: nil, origin: nil, source: nil, reason: nil,
                         timestamp: Time.now.utc.iso8601, metadata: {})
            @event = normalize_event(event)
            @status = normalize_status(status || default_status_for(@event))
            @credential_key = credential_key.to_sym
            @policy_name = policy_name.to_sym
            @node = node&.to_s
            @target_node = target_node&.to_s
            @lease_id = lease_id&.to_s
            @actor = actor&.to_s
            @origin = origin&.to_s
            @source = source&.to_sym
            @reason = reason&.to_sym
            @timestamp = normalize_timestamp(timestamp)
            @metadata = normalize_metadata(metadata)
            freeze
          end

          def self.from_h(event_hash)
            normalized = (event_hash || {}).each_with_object({}) do |(key, value), memo|
              memo[key.to_sym] = value
            end

            new(
              event: normalized.fetch(:event),
              status: normalized[:status],
              credential_key: normalized.fetch(:credential_key),
              policy_name: normalized.fetch(:policy_name),
              node: normalized[:node],
              target_node: normalized[:target_node],
              lease_id: normalized[:lease_id],
              actor: normalized[:actor],
              origin: normalized[:origin],
              source: normalized[:source],
              reason: normalized[:reason],
              timestamp: normalized[:timestamp],
              metadata: normalized.fetch(:metadata, {})
            )
          end

          def lease_event?
            event.to_s.start_with?("lease_")
          end

          def replication_event?
            event.to_s.start_with?("replication_")
          end

          def denied?
            status == :denied
          end

          def granted?
            status == :issued || status == :used
          end

          def with(**overrides)
            self.class.new(
              event: overrides.fetch(:event, event),
              status: overrides.fetch(:status, status),
              credential_key: overrides.fetch(:credential_key, credential_key),
              policy_name: overrides.fetch(:policy_name, policy_name),
              node: overrides.fetch(:node, node),
              target_node: overrides.fetch(:target_node, target_node),
              lease_id: overrides.fetch(:lease_id, lease_id),
              actor: overrides.fetch(:actor, actor),
              origin: overrides.fetch(:origin, origin),
              source: overrides.fetch(:source, source),
              reason: overrides.fetch(:reason, reason),
              timestamp: overrides.fetch(:timestamp, timestamp),
              metadata: metadata.merge(normalize_metadata(overrides.fetch(:metadata, {})))
            )
          end

          def to_h
            {
              event: event,
              status: status,
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
              metadata: metadata
            }.compact.freeze
          end

          private

          def normalize_event(value)
            normalized = value.to_sym
            return normalized if EVENT_TYPES.include?(normalized)

            raise ArgumentError, "unknown credential event: #{value}"
          end

          def normalize_status(value)
            normalized = value.to_sym
            return normalized if STATUS_TYPES.include?(normalized)

            raise ArgumentError, "unknown credential event status: #{value}"
          end

          def default_status_for(event_name)
            case event_name.to_sym
            when :lease_requested, :replication_requested
              :requested
            when :lease_issued
              :issued
            when :lease_used
              :used
            when :lease_denied, :replication_denied, :access_denied
              :denied
            when :lease_revoked, :replication_revoked
              :revoked
            else
              :requested
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
end
