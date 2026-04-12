# frozen_string_literal: true

require "time"

module Igniter
  module Channels
    class Message
      attr_reader :to, :body, :subject, :sender, :reply_to,
                  :attachments, :metadata, :content_type,
                  :template, :template_vars, :idempotency_key,
                  :correlation_id, :created_at

      def self.coerce(message = nil, **attrs)
        case message
        when nil
          new(**attrs)
        when self
          attrs.empty? ? message : message.with(**attrs)
        when Hash
          new(**message.transform_keys(&:to_sym).merge(attrs))
        when String
          new(body: message, **attrs)
        else
          raise ArgumentError, "Expected Igniter::Channels::Message, Hash, String, or nil"
        end
      end

      def initialize(
        to: nil,
        body: nil,
        subject: nil,
        sender: nil,
        reply_to: nil,
        attachments: [],
        metadata: {},
        content_type: :text,
        template: nil,
        template_vars: {},
        idempotency_key: nil,
        correlation_id: nil,
        created_at: Time.now.utc
      )
        @to = to
        @body = body
        @subject = subject
        @sender = sender
        @reply_to = reply_to
        @attachments = Array(attachments).dup.freeze
        @metadata = (metadata || {}).dup.freeze
        @content_type = content_type&.to_sym
        @template = template&.to_sym
        @template_vars = (template_vars || {}).dup.freeze
        @idempotency_key = idempotency_key
        @correlation_id = correlation_id
        @created_at = created_at.is_a?(String) ? Time.iso8601(created_at) : created_at
        freeze
      end

      def with(**attrs)
        self.class.new(**to_h.merge(attrs))
      end

      def to_h
        {
          to: to,
          body: body,
          subject: subject,
          sender: sender,
          reply_to: reply_to,
          attachments: attachments,
          metadata: metadata,
          content_type: content_type,
          template: template,
          template_vars: template_vars,
          idempotency_key: idempotency_key,
          correlation_id: correlation_id,
          created_at: created_at
        }
      end

      def as_json(*)
        to_h.transform_values { |value| serialize_value(value) }
      end

      private

      def serialize_value(value)
        case value
        when Time
          value.iso8601
        when Hash
          value.each_with_object({}) { |(key, nested), memo| memo[key] = serialize_value(nested) }
        when Array
          value.map { |item| serialize_value(item) }
        else
          value
        end
      end
    end
  end
end
