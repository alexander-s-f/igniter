# frozen_string_literal: true

module Companion
  # Speech-to-text. Runs on the inference node (RPi).
  #
  # input  :audio_data  — Base64 WAV/PCM (16kHz, 16-bit, mono)
  # output :transcript  — recognised text String
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
