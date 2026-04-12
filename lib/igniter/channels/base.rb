# frozen_string_literal: true

module Igniter
  module Channels
    class Base < Igniter::Effect
      effect_type :messaging

      class << self
        def inherited(subclass)
          super
          subclass.instance_variable_set(:@channel_name, @channel_name)
        end

        def channel_name(value = nil)
          return @channel_name || infer_channel_name if value.nil?

          @channel_name = value.to_sym
        end

        private

        def infer_channel_name
          name.to_s.split("::").last
              .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
              .gsub(/([a-z\d])([A-Z])/, '\1_\2')
              .downcase
              .to_sym
        end
      end

      def call(message: nil, **attrs)
        deliver(message, **attrs)
      end

      def deliver(message = nil, **attrs)
        resolved_message = Message.coerce(message, **attrs)
        coerce_result(deliver_message(resolved_message), resolved_message)
      rescue Igniter::Channels::Error
        raise
      rescue StandardError => e
        raise DeliveryError.new(
          e.message,
          context: {
            channel: self.class.channel_name,
            recipient: resolved_message&.to
          }.compact
        )
      end

      private

      def deliver_message(_message)
        raise NotImplementedError, "#{self.class.name} must implement #deliver_message"
      end

      def coerce_result(result, message)
        case result
        when DeliveryResult
          result
        when Hash
          DeliveryResult.new(
            **{ provider: self.class.channel_name, recipient: message.to }
              .merge(result.transform_keys(&:to_sym))
          )
        when String
          DeliveryResult.new(
            provider: self.class.channel_name,
            recipient: message.to,
            external_id: result,
            status: :sent
          )
        when nil
          DeliveryResult.new(
            provider: self.class.channel_name,
            recipient: message.to,
            status: :sent
          )
        else
          raise ArgumentError, "Expected DeliveryResult, Hash, String, or nil from #deliver_message"
        end
      end
    end
  end
end
