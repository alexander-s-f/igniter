# frozen_string_literal: true

module Companion
  # Text-to-speech synthesis. Runs on the inference node (RPi).
  #
  # input  :text           — text to speak
  # output :audio_response — Base64 WAV to stream back to ESP32
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
