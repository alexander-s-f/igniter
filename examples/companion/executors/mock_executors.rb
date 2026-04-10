# frozen_string_literal: true

require "base64"

# Stub executors for local demo and testing.
# No hardware, no Ollama, no Whisper, no Piper required.
module Companion
  class MockWhisperExecutor < Igniter::Executor
    TRANSCRIPTS = [
      "What is Igniter and how does it work?",
      "Tell me something interesting about Ruby.",
      "What time is it?",
      "How is the weather today?",
      "Set a reminder for five minutes.",
      "Hello, are you there?"
    ].freeze

    def call(audio_data:)
      TRANSCRIPTS.sample.tap { |t| puts "  [ASR mock] → \"#{t}\"" }
    end
  end

  class MockIntentExecutor < Igniter::Executor
    PATTERNS = {
      /\?$/                               => "question",
      /what|who|where|when|why|how/i      => "question",
      /hello|hi\b|hey\b|good morning/i    => "greeting",
      /bye|goodbye|see you|good night/i   => "farewell",
      /set|start|open|play|stop|remind/i  => "command",
      /sorry|what did|can you repeat/i    => "clarification"
    }.freeze

    def call(text:)
      category = PATTERNS.find { |pattern, _| text.match?(pattern) }&.last || "other"
      { category: category, confidence: 0.92, language: "en" }.tap do |r|
        puts "  [Intent mock] → #{r[:category]}"
      end
    end
  end

  class MockChatExecutor < Igniter::Executor
    RESPONSES = {
      "question"      => [
        "Great question! Igniter is a Ruby gem for declaring business logic as validated dependency graphs.",
        "Based on what I know, that's a fascinating topic worth exploring further.",
        "I'd need a moment to look that up, but here's what I can tell you right now."
      ],
      "command"       => [
        "Done! I've processed your request.",
        "Consider it handled.",
        "I'm on it!"
      ],
      "greeting"      => [
        "Hello! Great to hear from you. How can I help?",
        "Hi there! What's on your mind?",
        "Hey! Nice to chat. What can I do for you?"
      ],
      "farewell"      => [
        "Take care! I'll be here when you need me.",
        "Goodbye! Have a great day.",
        "See you later!"
      ],
      "clarification" => [
        "Of course! Let me explain that more clearly.",
        "Sure, happy to clarify."
      ],
      "other"         => [
        "Interesting! Tell me more.",
        "I'm listening.",
        "That's worth thinking about."
      ]
    }.freeze

    def call(message:, conversation_history:, intent:)
      category = (intent[:category] || intent["category"] || "other").to_s
      response = (RESPONSES[category] || RESPONSES["other"]).sample
      puts "  [Chat mock] → \"#{response}\""
      response
    end
  end

  class MockPiperExecutor < Igniter::Executor
    # Returns a minimal valid WAV (0.1s of silence at 16kHz) so the pipeline runs end-to-end.
    def call(text:)
      puts "  [TTS mock] → synthesising #{text.length} chars"
      Base64.strict_encode64(silence_wav)
    end

    private

    def silence_wav
      sample_rate = 16_000
      pcm         = "\x00\x00" * (sample_rate / 10)  # 0.1 s
      data_size   = pcm.bytesize
      [
        "RIFF", [36 + data_size].pack("V"), "WAVE",
        "fmt ", [16].pack("V"),
        [1, 1].pack("vv"),
        [sample_rate].pack("V"), [sample_rate * 2].pack("V"),
        [2, 16].pack("vv"),
        "data", [data_size].pack("V"), pcm
      ].join
    end
  end
end
