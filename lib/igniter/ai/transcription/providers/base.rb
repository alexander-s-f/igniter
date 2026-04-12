# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

module Igniter
  module AI
    module Transcription
      module Providers
        # Abstract base for all transcription providers.
        #
        # Subclasses must implement #transcribe and may override the protected helpers.
        # All helpers use only stdlib (Net::HTTP, JSON) — zero production dependencies.
        class Base
          # @param audio_source [String, Pathname, IO] File path or IO object.
          # @param model        [String]
          # @param language     [String, nil]  BCP-47 code, or nil for auto-detection.
          # @param diarize      [Boolean]      Request speaker labels.
          # @param word_timestamps [Boolean]   Request per-word timing.
          # @param options      [Hash]         Provider-specific extras.
          # @return [TranscriptResult]
          def transcribe(audio_source, model:, language: nil, diarize: false, # rubocop:disable Metrics/ParameterLists
                         word_timestamps: true, **options)
            raise NotImplementedError, "#{self.class}#transcribe must be implemented"
          end

          private

          # ── Audio helpers ──────────────────────────────────────────────────

          def read_audio(source)
            case source
            when String then File.binread(source)
            when Pathname then File.binread(source.to_s)
            when StringIO then source.string.b
            when IO then source.read.b
            else
              raise ArgumentError, "audio_source must be a file path or IO object, got #{source.class}"
            end
          end

          def filename_from(source)
            case source
            when String then File.basename(source)
            when Pathname then source.basename.to_s
            else "audio.wav"
            end
          end

          # Best-effort MIME type from file extension.
          def audio_content_type(filename)
            ext = File.extname(filename.to_s).downcase
            {
              ".mp3" => "audio/mpeg", ".mp4" => "video/mp4", ".m4a" => "audio/mp4",
              ".wav" => "audio/wav",  ".webm" => "audio/webm", ".ogg" => "audio/ogg",
              ".flac" => "audio/flac", ".mpeg" => "audio/mpeg", ".mpga" => "audio/mpeg"
            }.fetch(ext, "application/octet-stream")
          end

          # ── Multipart form-data builder ────────────────────────────────────
          #
          # Returns [body (binary String), boundary (String)].
          # Hash values that contain :data are treated as file parts.
          def build_multipart(fields) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
            boundary = "IgniterBdy#{Time.now.to_i}"
            crlf     = "\r\n"
            body     = String.new("", encoding: "BINARY")

            fields.each do |name, value|
              body << "--#{boundary}#{crlf}"
              if value.is_a?(Hash) && value.key?(:data)
                body << "Content-Disposition: form-data; name=\"#{name}\"; filename=\"#{value[:filename]}\"#{crlf}"
                body << "Content-Type: #{value[:content_type]}#{crlf}#{crlf}"
                data = value[:data]
                data = data.b if data.respond_to?(:b)
                body << data
              else
                body << "Content-Disposition: form-data; name=\"#{name}\"#{crlf}#{crlf}"
                body << value.to_s
              end
              body << crlf
            end

            body << "--#{boundary}--#{crlf}"
            [body, boundary]
          end

          # ── HTTP helpers ───────────────────────────────────────────────────

          def http_for(uri)
            http             = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl     = uri.scheme == "https"
            http.read_timeout = @timeout || 300
            http.open_timeout = 15
            http
          end

          def handle_response(response) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
            unless response.is_a?(Net::HTTPSuccess)
              body = begin
                JSON.parse(response.body)
              rescue StandardError
                {}
              end
              msg = body["error"].is_a?(Hash) ? body.dig("error", "message") : body["error"]
              msg ||= response.body.to_s.slice(0, 200)
              raise Igniter::AI::ProviderError, "#{provider_name} error #{response.code}: #{msg}"
            end
            JSON.parse(response.body)
          rescue JSON::ParserError => e
            raise Igniter::AI::ProviderError, "#{provider_name} returned invalid JSON: #{e.message}"
          end

          def provider_name
            self.class.name.to_s.split("::").last
          end
        end
      end
    end
  end
end
