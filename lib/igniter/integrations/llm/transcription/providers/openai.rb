# frozen_string_literal: true

module Igniter
  module LLM
    module Transcription
      module Providers
        # OpenAI Whisper transcription provider.
        #
        # API: POST /v1/audio/transcriptions (multipart/form-data)
        # Docs: https://platform.openai.com/docs/api-reference/audio
        #
        # Limitations vs other providers:
        #   - No speaker diarization (speakers will be nil in result)
        #   - 20 MB file size limit
        #   - Only word-level granularity (no sentence-level)
        #
        # Extra options passed through:
        #   prompt:          String  — context hint to guide spelling/vocabulary
        #   response_format: Symbol  — :srt or :vtt stores raw subtitles in result.raw[:subtitle_text]
        class OpenAI < Base
          API_BASE = "https://api.openai.com"

          def initialize(api_key: ENV["OPENAI_API_KEY"], base_url: API_BASE, timeout: 120)
            super()
            @api_key  = api_key
            @base_url = base_url.to_s.chomp("/")
            @timeout  = timeout
          end

          def transcribe(audio_source, model:, language: nil, _diarize: false, # rubocop:disable Metrics/MethodLength,Metrics/ParameterLists
                         word_timestamps: true, **options)
            validate_api_key!

            audio = read_audio(audio_source)
            fname = filename_from(audio_source)
            ctype = audio_content_type(fname)

            fields = {
              "file" => { data: audio, filename: fname, content_type: ctype },
              "model" => model,
              "response_format" => "verbose_json"
            }
            fields["language"] = language if language
            fields["prompt"]   = options[:prompt] if options[:prompt]
            # Request word-level timestamps
            fields["timestamp_granularities[]"] = "word" if word_timestamps

            body, boundary = build_multipart(fields)
            raw = post_multipart("/v1/audio/transcriptions", body, boundary)
            build_result(raw, model: model)
          end

          private

          def build_result(raw, model:) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
            words = (raw["words"] || []).map do |w|
              TranscriptWord.new(
                word: w["word"].to_s.strip,
                start_time: w["start"].to_f,
                end_time: w["end"].to_f,
                confidence: w["confidence"]&.to_f,
                speaker: nil # Whisper has no diarization
              )
            end

            TranscriptResult.new(
              text: raw["text"].to_s,
              words: words,
              speakers: nil,
              language: raw["language"],
              duration: raw["duration"]&.to_f,
              provider: :openai,
              model: model,
              raw: raw
            )
          end

          def post_multipart(path, body, boundary)
            uri  = URI.parse("#{@base_url}#{path}")
            http = http_for(uri)

            request = Net::HTTP::Post.new(uri.path)
            request["Authorization"] = "Bearer #{@api_key}"
            request["Content-Type"]  = "multipart/form-data; boundary=#{boundary}"
            request.body             = body

            handle_response(http.request(request))
          rescue Errno::ECONNREFUSED, SocketError, Net::OpenTimeout => e
            raise Igniter::LLM::ProviderError, "Cannot connect to OpenAI API: #{e.message}"
          end

          def validate_api_key!
            return if @api_key && !@api_key.empty?

            raise Igniter::LLM::ConfigurationError,
                  "OpenAI API key not configured. Set OPENAI_API_KEY or pass api_key: to the provider."
          end
        end
      end
    end
  end
end
