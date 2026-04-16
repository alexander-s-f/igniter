# frozen_string_literal: true

module Companion
  class ASRContract < Igniter::Contract
    define do
      input :audio_data

      compute :transcript,
              depends_on: :audio_data,
              call: Companion::WhisperExecutor

      output :transcript
    end
  end
end
