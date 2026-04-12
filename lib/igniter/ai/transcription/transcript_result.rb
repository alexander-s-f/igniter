# frozen_string_literal: true

module Igniter
  module AI
    module Transcription
      # Single word with timing and optional speaker label.
      # end_time is used instead of `end` to avoid the Ruby keyword conflict.
      TranscriptWord = Struct.new(:word, :start_time, :end_time, :confidence, :speaker, keyword_init: true)

      # A contiguous block of speech from one speaker.
      SpeakerSegment = Struct.new(:speaker, :start_time, :end_time, :text, keyword_init: true)

      # Normalised result returned by every Transcription provider.
      #
      # @attr text      [String]                   Full transcript text.
      # @attr words     [Array<TranscriptWord>]     Word-level timestamps (empty Array if not requested).
      # @attr speakers  [Array<SpeakerSegment>, nil] Speaker segments or nil when diarization was not requested.
      # @attr language  [String, nil]               BCP-47 language code detected/specified (e.g. "en", "ru").
      # @attr duration  [Float, nil]                Audio duration in seconds.
      # @attr provider  [Symbol]                    Provider used (:openai, :deepgram, :assemblyai).
      # @attr model     [String]                    Model string (e.g. "whisper-1", "nova-3").
      # @attr raw       [Hash]                      Original provider response — provider-specific extras live here.
      TranscriptResult = Struct.new(
        :text, :words, :speakers, :language, :duration, :provider, :model, :raw,
        keyword_init: true
      )
    end
  end
end
