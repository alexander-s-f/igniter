# frozen_string_literal: true

module Companion
  # LLM response generation. Runs on the orchestrator (HP t740).
  #
  # input  :message               — current user utterance
  # input  :conversation_history  — Array<Hash> of prior {role:, content:} turns
  # input  :intent                — Hash from IntentContract
  # output :response_text         — assistant reply String (voice-optimised)
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
