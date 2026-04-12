# frozen_string_literal: true

module Igniter
  module AI
    module Transcription
      module Providers
        # AssemblyAI transcription provider.
        #
        # Uses a 3-step async workflow:
        #   1. Upload audio file to AssemblyAI CDN → upload_url
        #   2. Submit transcription job             → job_id
        #   3. Poll until completed / error         → result
        #
        # Docs: https://www.assemblyai.com/docs/api-reference
        #
        # Strengths:
        #   - Speaker diarization (diarize: true → speaker_labels: true)
        #   - Rich intelligence features via options
        #   - Free tier (333 hr/month)
        #
        # Extra options:
        #   sentiment_analysis: Boolean — per-sentence sentiment
        #   auto_chapters:      Boolean — topic-based chapters
        #   entity_detection:   Boolean — named entity recognition
        #   pii_redact:         Array   — entity types to redact (e.g. [:name, :phone_number])
        #   auto_highlights:    Boolean — key phrases extraction
        #   summarization:      Boolean — extractive summary
        #   custom_vocabulary:  Array   — boost accuracy for specific words
        class AssemblyAI < Base # rubocop:disable Metrics/ClassLength
          API_BASE       = "https://api.assemblyai.com"
          MIN_INTERVAL   = 1   # seconds
          MAX_INTERVAL   = 30  # seconds — exponential backoff cap

          def initialize(api_key: ENV["ASSEMBLYAI_API_KEY"], base_url: API_BASE,
                         timeout: 60, poll_interval: 2, poll_timeout: 300)
            super()
            @api_key       = api_key
            @base_url      = base_url.to_s.chomp("/")
            @timeout       = timeout
            @poll_interval = poll_interval
            @poll_timeout  = poll_timeout
          end

          def transcribe(audio_source, model:, language: nil, diarize: false, # rubocop:disable Metrics/ParameterLists
                         _word_timestamps: true, poll_interval: nil, poll_timeout: nil, **options)
            validate_api_key!

            interval = poll_interval || @poll_interval
            deadline = poll_timeout  || @poll_timeout

            audio      = read_audio(audio_source)
            fname      = filename_from(audio_source)
            upload_url = upload_file(audio, fname)
            job_id     = submit_job(upload_url, model: model, language: language,
                                                diarize: diarize, options: options)
            raw        = poll_until_complete(job_id, interval: interval, timeout: deadline)
            build_result(raw, model: model, diarize: diarize)
          end

          private

          # ── Step 1: Upload ─────────────────────────────────────────────────

          def upload_file(audio_data, filename)
            ctype    = audio_content_type(filename)
            uri      = URI.parse("#{@base_url}/v2/upload")
            http     = http_for(uri)
            request  = Net::HTTP::Post.new(uri.path, auth_headers)
            request["Content-Type"] = ctype
            request.body            = audio_data

            response = handle_response(http.request(request))
            response["upload_url"] || raise(Igniter::AI::ProviderError, "AssemblyAI: no upload_url in response")
          rescue Errno::ECONNREFUSED, SocketError, Net::OpenTimeout => e
            raise Igniter::AI::ProviderError, "Cannot connect to AssemblyAI API: #{e.message}"
          end

          # ── Step 2: Submit job ─────────────────────────────────────────────

          def submit_job(upload_url, model:, language:, diarize:, options:) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
            body = { audio_url: upload_url }
            body[:speech_model]        = model if model && model != "default"
            body[:language_code]       = language if language
            body[:speaker_labels]      = true if diarize
            body[:word_boost]          = options[:custom_vocabulary] if options[:custom_vocabulary]
            body[:sentiment_analysis]  = true if options[:sentiment_analysis]
            body[:auto_chapters]       = true if options[:auto_chapters]
            body[:entity_detection]    = true if options[:entity_detection]
            body[:auto_highlights]     = true if options[:auto_highlights]
            body[:summarization]       = true if options[:summarization]
            body[:summary_model]       = "informative" if options[:summarization]
            body[:summary_type]        = "bullets" if options[:summarization]
            body[:redact_pii]          = true if options[:pii_redact]
            body[:redact_pii_policies] = options[:pii_redact].map(&:to_s) if options[:pii_redact]

            uri      = URI.parse("#{@base_url}/v2/transcripts")
            http     = http_for(uri)
            request  = Net::HTTP::Post.new(uri.path, json_headers)
            request.body = JSON.generate(body)

            response = handle_response(http.request(request))
            response["id"] || raise(Igniter::AI::ProviderError, "AssemblyAI: no transcript id in response")
          end

          # ── Step 3: Poll ───────────────────────────────────────────────────

          def poll_until_complete(job_id, interval:, timeout:) # rubocop:disable Metrics/MethodLength
            deadline = Time.now + timeout
            wait     = [interval.to_f, MIN_INTERVAL].max

            loop do
              result = fetch_transcript(job_id)

              case result["status"]
              when "completed" then return result
              when "error"
                raise Igniter::AI::ProviderError,
                      "AssemblyAI transcription failed: #{result["error"]}"
              end

              if Time.now > deadline
                raise Igniter::AI::ProviderError,
                      "AssemblyAI transcription timed out after #{timeout}s (job_id: #{job_id})"
              end

              sleep(wait)
              wait = [wait * 1.5, MAX_INTERVAL].min
            end
          end

          def fetch_transcript(job_id)
            uri      = URI.parse("#{@base_url}/v2/transcripts/#{job_id}")
            http     = http_for(uri)
            request  = Net::HTTP::Get.new(uri.path, auth_headers)
            handle_response(http.request(request))
          rescue Errno::ECONNREFUSED, SocketError, Net::OpenTimeout => e
            raise Igniter::AI::ProviderError, "Cannot connect to AssemblyAI API: #{e.message}"
          end

          # ── Result building ────────────────────────────────────────────────

          def build_result(raw, model:, diarize:) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
            words = (raw["words"] || []).map do |w|
              TranscriptWord.new(
                word: w["text"].to_s,
                start_time: w["start"].to_f / 1000.0, # AssemblyAI uses milliseconds
                end_time: w["end"].to_f / 1000.0,
                confidence: w["confidence"]&.to_f,
                speaker: w["speaker"] # "A", "B", ... or nil
              )
            end

            speakers = diarize ? build_speakers(raw["utterances"], words) : nil

            TranscriptResult.new(
              text: raw["text"].to_s,
              words: words,
              speakers: speakers,
              language: raw["language_code"],
              duration: raw["audio_duration"]&.to_f,
              provider: :assemblyai,
              model: model,
              raw: raw
            )
          end

          def build_speakers(utterances, _words)
            return [] unless utterances&.any?

            utterances.map do |u|
              SpeakerSegment.new(
                speaker: u["speaker"], # "A", "B", ...
                start_time: u["start"].to_f / 1000.0,
                end_time: u["end"].to_f / 1000.0,
                text: u["text"].to_s
              )
            end
          end

          # ── Helpers ────────────────────────────────────────────────────────

          def auth_headers
            { "Authorization" => @api_key }
          end

          def json_headers
            auth_headers.merge("Content-Type" => "application/json")
          end

          def validate_api_key!
            return if @api_key && !@api_key.empty?

            raise Igniter::AI::ConfigurationError,
                  "AssemblyAI API key not configured. Set ASSEMBLYAI_API_KEY or pass api_key: to the provider."
          end
        end
      end
    end
  end
end
