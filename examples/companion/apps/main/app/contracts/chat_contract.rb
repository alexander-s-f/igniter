# frozen_string_literal: true

module Companion
  class ChatContract < Igniter::Contract
    define do
      input :message
      input :conversation_history
      input :intent

      compute :response_text,
              depends_on: [:message, :conversation_history, :intent],
              call: Companion::ChatExecutor

      output :response_text
    end
  end
end
