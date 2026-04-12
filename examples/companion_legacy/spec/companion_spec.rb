# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe "Companion AI Assistant" do
  def call_handler(klass, type, state, payload = {})
    handler = klass.handlers[type]
    raise "No handler :#{type} on #{klass}" unless handler

    handler.call(state: state, payload: payload)
  end

  # ── Tools ────────────────────────────────────────────────────────────────────

  describe Companion::TimeTool do
    it "returns current time as a string" do
      result = described_class.new.call
      expect(result).to be_a(String)
      expect(result).not_to be_empty
    end

    it "produces an Anthropic-compatible schema" do
      schema = described_class.to_schema(:anthropic)
      expect(schema[:name]).to eq("time_tool")
      expect(schema[:input_schema]).to include("type" => "object")
    end
  end

  describe Companion::WeatherTool do
    it "returns temperature and condition for a location" do
      result = described_class.new.call(location: "London")
      expect(result).to be_a(String)
      expect(result).to include("London")
    end

    it "requires :network capability" do
      expect(described_class.required_capabilities).to include(:network)
    end
  end

  describe "NotesStore + SaveNoteTool + GetNotesTool" do
    it "saves and retrieves a note by key" do
      Companion::NotesStore.save("greeting", "hello")
      expect(Companion::NotesStore.get("greeting")).to eq("hello")
    end

    it "lists all notes" do
      Companion::NotesStore.save("x", "1")
      Companion::NotesStore.save("y", "2")
      all = Companion::NotesStore.all
      expect(all).to include("x" => "1", "y" => "2")
    end

    it "SaveNoteTool stores a note (with :storage capability)" do
      tool   = Companion::SaveNoteTool.new
      result = tool.call_with_capability_check!(
        allowed_capabilities: [:storage], key: "lang", value: "Ruby"
      )
      expect(result).to include("Saved").and include("lang")
      expect(Companion::NotesStore.get("lang")).to eq("Ruby")
    end

    it "SaveNoteTool raises CapabilityError without :storage" do
      tool = Companion::SaveNoteTool.new
      expect do
        tool.call_with_capability_check!(allowed_capabilities: [], key: "k", value: "v")
      end.to raise_error(Igniter::Tool::CapabilityError)
    end

    it "GetNotesTool retrieves a stored value" do
      Companion::NotesStore.save("city", "Tokyo")
      tool   = Companion::GetNotesTool.new
      result = tool.call_with_capability_check!(allowed_capabilities: [:storage], key: "city")
      expect(result).to include("Tokyo")
    end
  end

  # ── Skills ───────────────────────────────────────────────────────────────────

  describe Companion::ResearchSkill do
    it "returns a summary string for a known topic (mock mode)" do
      result = described_class.new.call(topic: "Ruby")
      expect(result).to be_a(String)
      expect(result.downcase).to include("ruby")
    end

    it "returns a fallback string for an unknown topic" do
      result = described_class.new.call(topic: "quantum entanglement")
      expect(result).to be_a(String)
      expect(result).not_to be_empty
    end

    it "requires :network capability" do
      expect(described_class.required_capabilities).to include(:network)
    end
  end

  describe Companion::RemindMeSkill do
    it "parses a reminder request and saves a note" do
      described_class.new.call(request: "remind me to call Alice tomorrow at 9am")
      notes = Companion::NotesStore.all
      expect(notes).not_to be_empty
    end

    it "returns a confirmation string" do
      result = described_class.new.call(request: "remind me to review PR #42 at 3pm")
      expect(result).to be_a(String)
      expect(result).not_to be_empty
    end
  end

  # ── Contracts ────────────────────────────────────────────────────────────────

  describe "Individual contracts (mock executors)" do
    let(:fake_audio) { Base64.strict_encode64("\x00\x00" * 1600) }

    it "ASRContract returns a transcript string" do
      result = Companion::ASRContract.new(audio_data: fake_audio).result.transcript
      expect(result).to be_a(String)
      expect(result).not_to be_empty
    end

    it "IntentContract classifies a text input" do
      intent = Companion::IntentContract.new(text: "Hello there").result.intent
      expect(intent).to include(:category, :confidence, :language)
      expect(intent[:confidence]).to be_between(0.0, 1.0)
    end

    it "ChatContract returns a response_text" do
      result = Companion::ChatContract.new(
        message:              "Hi",
        conversation_history: [],
        intent:               { category: "greeting", confidence: 0.9, language: "en" }
      ).result.response_text
      expect(result).to be_a(String)
      expect(result).not_to be_empty
    end

    it "TTSContract returns Base64-encoded audio" do
      audio = Companion::TTSContract.new(text: "Hello").result.audio_response
      expect(audio).to be_a(String)
      # Should be valid Base64
      expect { Base64.strict_decode64(audio) }.not_to raise_error
    end
  end

  describe "LocalPipelineContract — end-to-end mock pipeline" do
    let(:fake_audio) { Base64.strict_encode64("\x00\x00" * 1600) }

    it "runs a complete ASR→Intent→Chat→TTS pipeline" do
      result = Companion::LocalPipelineContract.new(
        audio_data:           fake_audio,
        conversation_history: [],
        session_id:           "spec-session"
      ).result

      expect(result.transcript).to    be_a(String)
      expect(result.intent).to        include(:category, :confidence)
      expect(result.response_text).to be_a(String)
      expect(result.audio_response).to be_a(String)
    end

    it "runs multiple turns preserving history" do
      history = []
      3.times do
        result = Companion::LocalPipelineContract.new(
          audio_data:           fake_audio,
          conversation_history: history,
          session_id:           "spec-session-multi"
        ).result
        history << { role: "user",      content: result.transcript }
        history << { role: "assistant", content: result.response_text }
      end
      expect(history.size).to eq(6)  # 3 turns × 2 roles
    end
  end

  # ── Agents ───────────────────────────────────────────────────────────────────

  describe Companion::ConversationNudgeAgent do
    it "fires :long_silence nudge after 3 unanswered user turns" do
      state = described_class.default_state
      3.times { |i| state = call_handler(described_class, :record_turn, state, role: :user, text: "Hello #{i}") }
      state  = call_handler(described_class, :_scan, state)
      nudges = call_handler(described_class, :nudges, state)

      expect(nudges).not_to be_empty
      expect(nudges.map(&:kind)).to include(:silence)
    end

    it "fires :topic_stagnation nudge when same topic repeats" do
      state = described_class.default_state
      Thread.current[:nudge_silent_turns]  = 0
      Thread.current[:nudge_recent_topics] = %w[weather weather weather]
      state  = call_handler(described_class, :_scan, state)
      nudges = call_handler(described_class, :nudges, state)

      expect(nudges.map(&:kind)).to include(:stagnation)
    end

    it "supports :pause and :resume" do
      state  = described_class.default_state
      state  = call_handler(described_class, :pause, state)
      status = call_handler(described_class, :status, state)
      expect(status.active).to be false

      state  = call_handler(described_class, :resume, state)
      status = call_handler(described_class, :status, state)
      expect(status.active).to be true
    end
  end

  describe Companion::SystemWatch::SystemAlertAgent do
    it "fires an alert when error_rate exceeds threshold" do
      klass = Class.new(Companion::SystemWatch::SystemAlertAgent) do
        monitor :error_rate, source: -> { 0.15 }   # above the 0.05 threshold
        threshold :error_rate, above: 0.05
        proactive_initial_state alerts: [], silenced: false
      end

      state  = klass.default_state
      state  = call_handler(klass, :_scan, state)
      alerts = call_handler(klass, :alerts, state)

      expect(alerts).not_to be_empty
      expect(alerts.first.metric).to eq(:error_rate)
      expect(alerts.first.kind).to   eq(:above)
    end

    it "suppresses new alerts while silenced" do
      klass = Class.new(Companion::SystemWatch::SystemAlertAgent) do
        monitor :rps, source: -> { 2000 }
        threshold :rps, above: 1000
        proactive_initial_state alerts: [], silenced: false
      end

      state  = klass.default_state
      state  = call_handler(klass, :silence, state)
      state  = call_handler(klass, :_scan, state)
      alerts = call_handler(klass, :alerts, state)

      expect(alerts).to be_empty
    end
  end

  describe Companion::SystemWatch::DependencyHealthAgent do
    it "marks a service as unhealthy when poll returns false" do
      klass = Class.new(Companion::SystemWatch::DependencyHealthAgent) do
        check :test_service, poll: -> { false }
        proactive_initial_state health: {}, transitions: []
      end

      state  = klass.default_state
      state  = call_handler(klass, :_scan, state)
      health = call_handler(klass, :health, state)

      expect(health[:test_service]).to eq(:unhealthy)
    end
  end
end
