# frozen_string_literal: true

module Igniter
  module AI
    module Transcription
      module Providers
        # Deepgram transcription provider (Nova-3 and others).
        #
        # API: POST /v1/listen (raw binary body, model/options as query params)
        # Docs: https://developers.deepgram.com/docs/getting-started-with-pre-recorded-audio
        #
        # Strengths:
        #   - Speaker diarization (diarize: true)
        #   - Per-second billing (cheapest for variable-length calls)
        #   - Synchronous response (no polling)
        #   - Intelligence features via options: :sentiment, :topics, :intents, :summarize
        #
        # Extra options:
        #   sentiment:    Boolean — per-sentence sentiment analysis
        #   topics:       Boolean — topic detection
        #   intents:      Boolean — intent recognition
        #   summarize:    Boolean — extractive summary
        #   smart_format: Boolean — punctuation + capitalization (default: true)
        #   punctuate:    Boolean — add punctuation (default: true)
        class Deepgram < Base # rubocop:disable Metrics/ClassLength
          API_BASE = "https://api.deepgram.com"

          def initialize(api_key: ENV["DEEPGRAM_API_KEY"], base_url: API_BASE, timeout: 300)
            super()
            @api_key  = api_key
            @base_url = base_url.to_s.chomp("/")
            @timeout  = timeout
          end

          def transcribe(audio_source, model:, language: nil, diarize: false, # rubocop:disable Metrics/ParameterLists
                         _word_timestamps: true, **options)
            validate_api_key!

            audio = read_audio(audio_source)
            fname = filename_from(audio_source)
            ctype = audio_content_type(fname)

            params = build_params(model: model, language: language, diarize: diarize, options: options)
            raw = post_binary("/v1/listen", audio, ctype, params)
            build_result(raw, model: model, diarize: diarize)
          end

          private

          def build_params(model:, language:, diarize:, options:) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
            p = { model: model }
            p[:language]     = language if language
            p[:diarize]      = "true" if diarize
            p[:utterances]   = "true" if diarize  # structured speaker segments
            p[:punctuate]    = options.fetch(:punctuate, true) ? "true" : "false"
            p[:smart_format] = options.fetch(:smart_format, true) ? "true" : "false"
            p[:sentiment]    = "true" if options[:sentiment]
            p[:topics]       = "true" if options[:topics]
            p[:intents]      = "true" if options[:intents]
            p[:summarize]    = "v2" if options[:summarize]
            p
          end

          def build_result(raw, model:, diarize:) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
            alternative = raw.dig("results", "channels", 0, "alternatives", 0) || {}

            words = (alternative["words"] || []).map do |w|
              TranscriptWord.new(
                word: (w["punctuated_word"] || w["word"]).to_s,
                start_time: w["start"].to_f,
                end_time: w["end"].to_f,
                confidence: w["confidence"]&.to_f,
                speaker: w["speaker"] # Integer (0-based) when diarize: true, else nil
              )
            end

            speakers = diarize ? build_speakers(raw.dig("results", "utterances"), words) : nil
            lang     = raw.dig("results", "channels", 0, "detected_language") ||
                       raw.dig("metadata", "detected_language")

            TranscriptResult.new(
              text: alternative["transcript"].to_s,
              words: words,
              speakers: speakers,
              language: lang,
              duration: raw.dig("metadata", "duration")&.to_f,
              provider: :deepgram,
              model: model,
              raw: raw
            )
          end

          # Build SpeakerSegment list from Deepgram utterances (preferred) or word grouping.
          def build_speakers(utterances, words) # rubocop:disable Metrics/MethodLength
            if utterances&.any?
              utterances.map do |u|
                SpeakerSegment.new(
                  speaker: u["speaker"],
                  start_time: u["start"].to_f,
                  end_time: u["end"].to_f,
                  text: u["transcript"].to_s
                )
              end
            else
              # Fall back: group consecutive words by speaker
              group_words_by_speaker(words)
            end
          end

          def group_words_by_speaker(words) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
            return [] if words.empty?

            segments = []
            current  = nil

            words.each do |w|
              if current.nil? || w.speaker != current[:speaker]
                segments << current if current
                current = { speaker: w.speaker, start_time: w.start_time, end_time: w.end_time, words: [w.word] }
              else
                current[:end_time] = w.end_time
                current[:words] << w.word
              end
            end
            segments << current if current

            segments.map do |seg|
              SpeakerSegment.new(
                speaker: seg[:speaker],
                start_time: seg[:start_time],
                end_time: seg[:end_time],
                text: seg[:words].join(" ")
              )
            end
          end

          def post_binary(path, audio_data, content_type, params)
            query = URI.encode_www_form(params)
            uri   = URI.parse("#{@base_url}#{path}?#{query}")
            http  = http_for(uri)

            request = Net::HTTP::Post.new("#{uri.path}?#{uri.query}")
            request["Authorization"] = "Token #{@api_key}"
            request["Content-Type"]  = content_type
            request.body             = audio_data

            handle_response(http.request(request))
          rescue Errno::ECONNREFUSED, SocketError, Net::OpenTimeout => e
            raise Igniter::AI::ProviderError, "Cannot connect to Deepgram API: #{e.message}"
          end

          def validate_api_key!
            return if @api_key && !@api_key.empty?

            raise Igniter::AI::ConfigurationError,
                  "Deepgram API key not configured. Set DEEPGRAM_API_KEY or pass api_key: to the provider."
          end
        end
      end
    end
  end
end
