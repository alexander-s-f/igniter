# frozen_string_literal: true

module Companion
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
