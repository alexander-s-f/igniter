# frozen_string_literal: true

module Igniter
  class Agent
    # Immutable message passed between agents through a Mailbox.
    #
    #   type     — Symbol identifying the message kind (e.g. :increment, :get)
    #   payload  — frozen Hash of message data (default: {})
    #   reply_to — one-shot Mailbox for sync request-reply (nil for async)
    class Message
      attr_reader :type, :payload, :reply_to

      def initialize(type:, payload: {}, reply_to: nil)
        @type     = type.to_sym
        @payload  = (payload || {}).freeze
        @reply_to = reply_to
        freeze
      end
    end
  end
end
