# frozen_string_literal: true

module Companion
  class TTSContract < Igniter::Contract
    define do
      input :text

      compute :audio_response,
              depends_on: :text,
              call: Companion::PiperExecutor

      output :audio_response
    end
  end
end
