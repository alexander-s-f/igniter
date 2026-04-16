# frozen_string_literal: true

require "base64"
require_relative "../shared/notes_store"
require_relative "../../../apps/main/app/skills/research_skill"
require_relative "../../../apps/main/app/skills/remind_me_skill"

module Companion
  class MockWhisperExecutor < Igniter::Executor
    TRANSCRIPTS = [
      "What is Igniter and how does it work?",
      "Tell me something interesting about Ruby.",
      "What time is it?",
      "How is the weather today in New York?",
      "Remember that my favorite language is Ruby.",
      "What did I ask you to remember?",
      "Hello, are you there?"
    ].freeze

    def call(audio_data:)
      TRANSCRIPTS.sample.tap { |text| puts "  [ASR mock] → \"#{text}\"" }
    end
  end

  class MockIntentExecutor < Igniter::Executor
    PATTERNS = {
      /\?$/ => "question",
      /what|who|where|when|why|how/i => "question",
      /hello|hi\b|hey\b|good morning/i => "greeting",
      /bye|goodbye|see you|good night/i => "farewell",
      /set|start|open|play|stop|remind/i => "command",
      /remember|save|note/i => "command",
      /sorry|what did|can you repeat/i => "clarification"
    }.freeze

    def call(text:)
      category = PATTERNS.find { |pattern, _| text.match?(pattern) }&.last || "other"
      { category: category, confidence: 0.92, language: "en" }.tap do |result|
        puts "  [Intent mock] → #{result[:category]}"
      end
    end
  end

  class MockChatExecutor < Igniter::Executor
    RESPONSES = {
      "question" => [
        "Great question! Igniter is a Ruby gem for declaring business logic as validated dependency graphs.",
        "Based on what I know, that's a fascinating topic worth exploring further.",
        "I'd need a moment to look that up, but here's what I can tell you right now."
      ],
      "command" => [
        "Done! I've processed your request.",
        "Consider it handled.",
        "I'm on it!"
      ],
      "greeting" => [
        "Hello! Great to hear from you. How can I help?",
        "Hi there! What's on your mind?",
        "Hey! Nice to chat. What can I do for you?"
      ],
      "farewell" => [
        "Take care! I'll be here when you need me.",
        "Goodbye! Have a great day.",
        "See you later!"
      ],
      "clarification" => [
        "Of course! Let me explain that more clearly.",
        "Sure, happy to clarify."
      ],
      "other" => [
        "Interesting! Tell me more.",
        "I'm listening.",
        "That's worth thinking about."
      ]
    }.freeze

    def call(message:, conversation_history:, intent:)
      response = tool_simulation(message) || intent_response(intent)
      puts "  [Chat mock] → \"#{response}\""
      response
    end

    private

    def tool_simulation(message) # rubocop:disable Metrics/MethodLength
      case message
      when /what time/i
        now = Time.now
        "[tool: time] The current time is #{now.strftime("%I:%M %p")}."
      when /weather.*in\s+(\w[\w\s]*?)(\?|$)/i, /weather.*today/i
        location = Regexp.last_match(1)&.strip || "your area"
        "[tool: weather] It looks #{%w[sunny cloudy rainy].sample} in #{location} today."
      when /remember(?:.*that)?\s+(.+)/i
        note = Regexp.last_match(1).to_s.strip
        key = "note_#{Time.now.to_i % 1000}"
        NotesStore.save(key, note)
        "[tool: save_note] Got it, I've saved that: \"#{note}\""
      when /what did.*remember|what.*notes|recall/i
        notes = NotesStore.all
        if notes.empty?
          "[tool: get_notes] I don't have any saved notes yet."
        else
          items = notes.map { |key, value| "#{key}: #{value}" }.join("; ")
          "[tool: get_notes] Here's what I have saved: #{items}"
        end
      when /research|tell me about|explain|how does/i
        topic = message.sub(/^(?:research|tell me about|explain|how does)\s*/i, "").strip
        "[skill: research] #{Companion::ResearchSkill.new.call(topic: topic)}"
      when /remind me|don.t let me forget|set a reminder/i
        "[skill: remind_me] #{Companion::RemindMeSkill.new.call(request: message)}"
      end
    end

    def intent_response(intent)
      category = (intent[:category] || intent["category"] || "other").to_s
      (RESPONSES[category] || RESPONSES["other"]).sample
    end
  end

  class MockPiperExecutor < Igniter::Executor
    def call(text:)
      puts "  [TTS mock] → synthesising #{text.length} chars"
      Base64.strict_encode64(silence_wav)
    end

    private

    def silence_wav
      sample_rate = 16_000
      pcm = "\x00\x00" * (sample_rate / 10)
      data_size = pcm.bytesize
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
