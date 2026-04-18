# frozen_string_literal: true

require "time"

module Igniter
  module Channels
    class DeliveryResult
      SUCCESS_STATUSES = %i[queued sent delivered].freeze
      FAILURE_STATUSES = %i[failed rejected].freeze

      attr_reader :status, :provider, :recipient, :message_id,
                  :external_id, :payload, :error, :delivered_at

      def initialize(
        status: :sent,
        provider: nil,
        recipient: nil,
        message_id: nil,
        external_id: nil,
        payload: {},
        error: nil,
        delivered_at: Time.now.utc
      )
        @status = status.to_sym
        @provider = provider&.to_sym
        @recipient = recipient
        @message_id = message_id
        @external_id = external_id
        @payload = (payload || {}).dup.freeze
        @error = error
        @delivered_at = delivered_at.is_a?(String) ? Time.iso8601(delivered_at) : delivered_at
        freeze
      end

      def success?
        SUCCESS_STATUSES.include?(status)
      end

      def failure?
        FAILURE_STATUSES.include?(status)
      end

      def to_h
        {
          status: status,
          provider: provider,
          recipient: recipient,
          message_id: message_id,
          external_id: external_id,
          payload: payload,
          error: error,
          delivered_at: delivered_at
        }
      end

      def as_json(*)
        to_h.transform_values { |value| value.is_a?(Time) ? value.iso8601 : value }
      end
    end
  end
end
