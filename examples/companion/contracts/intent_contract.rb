# frozen_string_literal: true

module Companion
  # Fast intent classification. Runs on the inference node (RPi).
  #
  # input  :text    — user utterance String
  # output :intent  — Hash { category:, confidence:, language: }
  class IntentContract < Igniter::Contract
    define do
      input :text

      compute :intent,
              depends_on: :text,
              call: Companion::IntentExecutor

      output :intent
    end
  end
end
