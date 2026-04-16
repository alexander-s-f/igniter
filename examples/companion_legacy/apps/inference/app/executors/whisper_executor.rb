# frozen_string_literal: true

require "net/http"
require "json"
require "base64"
require "tempfile"
require "securerandom"

module Companion
  class WhisperExecutor < Igniter::Executor
    WHISPER_URL = ENV.fetch("WHISPER_URL", "http://localhost:8765")
    WHISPER_MODEL = ENV.fetch("WHISPER_MODEL", "Systran/faster-whisper-small")

    def call(audio_data:)
      raw = Base64.decode64(audio_data)

      Tempfile.create(["companion_audio", ".wav"]) do |file|
        file.binmode
        file.write(ensure_wav(raw))
        file.flush
        transcribe(file.path)
      end
    end

    private

    def transcribe(wav_path) # rubocop:disable Metrics/MethodLength
      boundary = "CompanionBoundary#{SecureRandom.hex(8)}"
      body = multipart_body(wav_path, boundary)
      uri = URI("#{WHISPER_URL}/v1/audio/transcriptions")

      request = Net::HTTP::Post.new(uri)
      request["Content-Type"] = "multipart/form-data; boundary=#{boundary}"
      request.body = body

      response = Net::HTTP.start(uri.host, uri.port, read_timeout: 30) { |http| http.request(request) }
      raise Igniter::ResolutionError, "Whisper HTTP #{response.code}: #{response.body}" unless response.is_a?(Net::HTTPSuccess)

      JSON.parse(response.body).fetch("text", "").strip
    end

    def multipart_body(wav_path, boundary) # rubocop:disable Metrics/MethodLength
      content = File.binread(wav_path)
      [
        "--#{boundary}\r\n",
        "Content-Disposition: form-data; name=\"file\"; filename=\"audio.wav\"\r\n",
        "Content-Type: audio/wav\r\n\r\n",
        content,
        "\r\n--#{boundary}\r\n",
        "Content-Disposition: form-data; name=\"model\"\r\n\r\n",
        WHISPER_MODEL,
        "\r\n--#{boundary}--\r\n"
      ].join
    end

    def ensure_wav(data) # rubocop:disable Metrics/MethodLength
      return data if data[0, 4] == "RIFF"

      sample_rate = 16_000
      channels = 1
      bits = 16
      byte_rate = sample_rate * channels * (bits / 8)
      block_align = channels * (bits / 8)
      data_size = data.bytesize

      [
        "RIFF", [36 + data_size].pack("V"), "WAVE",
        "fmt ", [16].pack("V"),
        [1].pack("v"), [channels].pack("v"),
        [sample_rate].pack("V"), [byte_rate].pack("V"),
        [block_align].pack("v"), [bits].pack("v"),
        "data", [data_size].pack("V"),
        data
      ].join
    end
  end
end
