# frozen_string_literal: true

require "open3"
require "tempfile"
require "base64"

module Companion
  # Synthesises speech using the Piper TTS engine (subprocess).
  #
  # Install on RPi:
  #   pip install piper-tts
  #   # Or download binary: https://github.com/rhasspy/piper/releases
  #   # Download voice model, e.g.:
  #   #   piper --download-voice en_US-lessac-medium
  #
  # Config:
  #   PIPER_BIN   — path or name of piper binary (default: "piper")
  #   PIPER_MODEL — voice model name (default: en_US-lessac-medium)
  #
  # text — String to speak
  # Returns Base64-encoded WAV
  class PiperExecutor < Igniter::Executor
    PIPER_BIN   = ENV.fetch("PIPER_BIN",   "piper")
    PIPER_MODEL = ENV.fetch("PIPER_MODEL", "en_US-lessac-medium")

    def call(text:)
      Base64.strict_encode64(synthesize(text))
    end

    private

    def synthesize(text) # rubocop:disable Metrics/MethodLength
      out_file = Tempfile.new(["companion_tts", ".wav"])
      out_file.close

      cmd = [
        PIPER_BIN,
        "--model",            PIPER_MODEL,
        "--output_file",      out_file.path,
        "--sentence-silence", "0.25"
      ]

      _stdout, stderr, status = Open3.capture3(*cmd, stdin_data: text)
      raise Igniter::ResolutionError, "Piper failed (#{status.exitstatus}): #{stderr}" \
        unless status.success?

      File.binread(out_file.path)
    ensure
      out_file&.unlink
    end
  end
end
