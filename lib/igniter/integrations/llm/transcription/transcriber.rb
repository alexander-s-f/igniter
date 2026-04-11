# frozen_string_literal: true

module Igniter
  module LLM
    # Base class for audio transcription executors.
    #
    # A Transcriber is a fully-fledged Igniter::Executor — it can be used as a
    # compute node in a Contract graph, paired with cache_ttl:, and composed
    # with downstream LLM::Executor skills:
    #
    #   class CallTranscriber < Igniter::LLM::Transcriber
    #     transcription_provider :deepgram
    #     model "nova-3"
    #     language "ru"
    #     diarize true
    #
    #     def call(audio_path:)
    #       transcribe(audio_path)
    #     end
    #   end
    #
    #   # Standalone
    #   result = CallTranscriber.call(audio_path: "call_123.mp3")
    #   result.text          # => "Добрый день, чем могу помочь?"
    #   result.speakers      # => [#<SpeakerSegment speaker=0 ...>, ...]
    #
    #   # Inside a Contract graph
    #   compute :transcript, call: CallTranscriber, with: :audio_path, cache_ttl: 3600
    class Transcriber < Igniter::Executor
      PROVIDERS = %i[openai deepgram assemblyai].freeze
      DEFAULT_MODELS = { openai: "whisper-1", deepgram: "nova-3", assemblyai: "universal-2" }.freeze

      class << self
        def inherited(subclass)
          super
          TRANSCRIBER_IVARS.each do |ivar|
            subclass.instance_variable_set(ivar, instance_variable_get(ivar))
          end
        end

        # ── Provider DSL ───────────────────────────────────────────────────

        def transcription_provider(name = nil)
          return @transcription_provider if name.nil?

          name = name.to_sym
          unless PROVIDERS.include?(name)
            raise ArgumentError, "Unknown transcription provider #{name.inspect}. Available: #{PROVIDERS.inspect}"
          end

          @transcription_provider = name
        end

        def model(name = nil)
          return @transcription_model if name.nil?

          @transcription_model = name.to_s
        end

        def language(lang = nil)
          return @language if lang.nil?

          @language = lang.to_s
        end

        def diarize(bool = nil)
          return @diarize.nil? ? false : @diarize if bool.nil?

          @diarize = bool
        end
        alias diarize? diarize

        def word_timestamps(bool = nil)
          return @word_timestamps.nil? || @word_timestamps if bool.nil?

          @word_timestamps = bool
        end

        # ── Polling DSL (AssemblyAI) ───────────────────────────────────────

        # Seconds between poll attempts (uses exponential backoff up to 30s).
        def poll_interval(secs = nil)
          return @poll_interval || 2 if secs.nil?

          @poll_interval = secs.to_f
        end

        # Maximum total seconds to wait for async transcription.
        def poll_timeout(secs = nil)
          return @poll_timeout || 300 if secs.nil?

          @poll_timeout = secs.to_f
        end
      end

      # All instance variables the DSL manages — copied in inherited hook.
      TRANSCRIBER_IVARS = %i[
        @transcription_provider @transcription_model @language
        @diarize @word_timestamps @poll_interval @poll_timeout
      ].freeze
      private_constant :TRANSCRIBER_IVARS

      protected

      # Transcribe audio and return a TranscriptResult.
      # Call this from your #call implementation.
      #
      # @param audio_source [String, Pathname, IO] File path or IO object.
      # @param options [Hash] Provider-specific extras forwarded verbatim.
      # @return [Transcription::TranscriptResult]
      def transcribe(audio_source, **options)
        provider_instance.transcribe(
          audio_source,
          model: current_model,
          language: self.class.language,
          diarize: self.class.diarize?,
          word_timestamps: self.class.word_timestamps,
          poll_interval: self.class.poll_interval,
          poll_timeout: self.class.poll_timeout,
          **options
        )
      end

      private

      def provider_instance
        pname = self.class.transcription_provider
        unless pname
          raise Igniter::LLM::ConfigurationError,
                "#{self.class.name}: transcription_provider not configured. " \
                "Call transcription_provider :openai, :deepgram, or :assemblyai in your class."
        end

        @provider_instance ||= Igniter::LLM.transcription_provider_instance(pname)
      end

      def current_model
        self.class.model ||
          Transcriber::DEFAULT_MODELS[self.class.transcription_provider] ||
          raise(Igniter::LLM::ConfigurationError,
                "No model configured for provider #{self.class.transcription_provider}")
      end
    end
  end
end
