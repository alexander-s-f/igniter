# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe Companion::MainApp do
  def call_handler(klass, type, state, payload = {})
    handler = klass.handlers[type]
    raise "No handler :#{type} on #{klass}" unless handler

    handler.call(state: state, payload: payload)
  end

  it "uses apps/main as its root directory" do
    expect(described_class.root_dir).to eq(File.expand_path("..", __dir__))
  end

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
      expect(Companion::NotesStore.all).to include("x" => "1", "y" => "2")
    end

    it "SaveNoteTool stores a note (with :storage capability)" do
      tool = Companion::SaveNoteTool.new
      result = tool.call_with_capability_check!(allowed_capabilities: [:storage], key: "lang", value: "Ruby")
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
      tool = Companion::GetNotesTool.new
      result = tool.call_with_capability_check!(allowed_capabilities: [:storage], key: "city")
      expect(result).to include("Tokyo")
    end
  end

  describe Companion::SendTelegramTool do
    it "returns a helpful message when Telegram is not configured" do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("TELEGRAM_BOT_TOKEN").and_return(nil)
      allow(ENV).to receive(:[]).with("TELEGRAM_CHAT_ID").and_return(nil)

      result = described_class.new.call(message: "Hello from Igniter")

      expect(result).to include("Telegram is not configured")
    end

    it "sends a Telegram message through Igniter::Channels::Telegram" do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("TELEGRAM_BOT_TOKEN").and_return("bot-token")
      allow(ENV).to receive(:[]).with("TELEGRAM_CHAT_ID").and_return("12345")

      channel = instance_double(Igniter::Channels::Telegram)
      result = Igniter::Channels::DeliveryResult.new(
        status: :delivered,
        provider: :telegram,
        recipient: "12345",
        external_id: "777"
      )
      allow(Igniter::Channels::Telegram).to receive(:new).and_return(channel)
      allow(channel).to receive(:deliver).and_return(result)

      response = described_class.new.call(
        message: "Call summary is ready",
        title: "Summary"
      )

      expect(channel).to have_received(:deliver).with(
        to: nil,
        subject: "Summary",
        body: "Call summary is ready"
      )
      expect(response).to include("Sent Telegram message to 12345")
      expect(response).to include("777")
    end
  end

  describe Companion::TelegramWebhook do
    let(:channel) { instance_double(Igniter::Channels::Telegram) }
    let(:delivery_result) do
      Igniter::Channels::DeliveryResult.new(
        status: :delivered,
        provider: :telegram,
        recipient: "12345",
        external_id: "888"
      )
    end

    before do
      allow(Igniter::Channels::Telegram).to receive(:new).and_return(channel)
      allow(channel).to receive(:deliver).and_return(delivery_result)
    end

    it "returns 401 when the Telegram secret token does not match" do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("TELEGRAM_WEBHOOK_SECRET").and_return("secret-1")

      result = described_class.call(
        params: {},
        body: { "message" => { "text" => "hello", "chat" => { "id" => 12345 } } },
        headers: { "X-Telegram-Bot-Api-Secret-Token" => "wrong" },
        raw_body: "{}",
        config: nil
      )

      expect(result[:status]).to eq(401)
      expect(channel).not_to have_received(:deliver)
    end

    it "responds to /start with a welcome message" do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("TELEGRAM_WEBHOOK_SECRET").and_return(nil)

      result = described_class.call(
        params: {},
        body: { "message" => { "text" => "/start", "message_id" => 10, "chat" => { "id" => 12345 } } },
        headers: {},
        raw_body: '{"message":{"text":"/start"}}',
        config: nil
      )

      expect(result[:status]).to eq(200)
      expect(channel).to have_received(:deliver).with(
        to: "12345",
        body: include("Hello! I'm Companion"),
        metadata: { reply_to_message_id: 10 }
      )
    end

    it "runs ChatContract and sends the response back to Telegram" do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("TELEGRAM_WEBHOOK_SECRET").and_return(nil)

      contract = instance_double(Companion::ChatContract, result: double(response_text: "It is sunny and 21C."))
      allow(Companion::ChatContract).to receive(:new).and_return(contract)

      result = described_class.call(
        params: {},
        body: { "message" => { "text" => "weather in Kyiv", "message_id" => 11, "chat" => { "id" => 12345 } } },
        headers: {},
        raw_body: '{"message":{"text":"weather in Kyiv"}}',
        config: nil
      )

      expect(result[:status]).to eq(200)
      expect(Companion::ChatContract).to have_received(:new).with(
        message: "weather in Kyiv",
        conversation_history: [],
        intent: { category: "other", confidence: 0.5, language: "en" }
      )
      expect(channel).to have_received(:deliver).with(
        to: "12345",
        body: "It is sunny and 21C.",
        metadata: { reply_to_message_id: 11 }
      )
      expect(Companion::ConversationStore.history("telegram:12345")).to eq(
        [
          { role: "user", content: "weather in Kyiv" },
          { role: "assistant", content: "It is sunny and 21C." }
        ]
      )
    end
  end

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
      expect(Companion::NotesStore.all).not_to be_empty
    end

    it "returns a confirmation string" do
      result = described_class.new.call(request: "remind me to review PR #42 at 3pm")
      expect(result).to be_a(String)
      expect(result).not_to be_empty
    end
  end

  describe Companion::ChatContract do
    it "exposes :response_text in the compiled graph" do
      node = described_class.graph.fetch_node(:response_text)

      expect(node.name).to eq(:response_text)
    end
  end

  describe Companion::ConversationNudgeAgent do
    it "fires :long_silence nudge after 3 unanswered user turns" do
      state = described_class.default_state
      3.times { |i| state = call_handler(described_class, :record_turn, state, role: :user, text: "Hello #{i}") }
      state = call_handler(described_class, :_scan, state)
      nudges = call_handler(described_class, :nudges, state)

      expect(nudges).not_to be_empty
      expect(nudges.map(&:kind)).to include(:silence)
    end

    it "fires :topic_stagnation nudge when same topic repeats" do
      state = described_class.default_state
      Thread.current[:nudge_silent_turns] = 0
      Thread.current[:nudge_recent_topics] = %w[weather weather weather]
      state = call_handler(described_class, :_scan, state)
      nudges = call_handler(described_class, :nudges, state)

      expect(nudges.map(&:kind)).to include(:stagnation)
    end

    it "supports :pause and :resume" do
      state = described_class.default_state
      state = call_handler(described_class, :pause, state)
      status = call_handler(described_class, :status, state)
      expect(status.active).to be false

      state = call_handler(described_class, :resume, state)
      status = call_handler(described_class, :status, state)
      expect(status.active).to be true
    end
  end

  describe Companion::SystemWatch::SystemAlertAgent do
    it "fires an alert when error_rate exceeds threshold" do
      klass = Class.new(Companion::SystemWatch::SystemAlertAgent) do
        monitor :error_rate, source: -> { 0.15 }
        threshold :error_rate, above: 0.05
        proactive_initial_state alerts: [], silenced: false
      end

      state = klass.default_state
      state = call_handler(klass, :_scan, state)
      alerts = call_handler(klass, :alerts, state)

      expect(alerts).not_to be_empty
      expect(alerts.first.metric).to eq(:error_rate)
      expect(alerts.first.kind).to eq(:above)
    end

    it "suppresses new alerts while silenced" do
      klass = Class.new(Companion::SystemWatch::SystemAlertAgent) do
        monitor :rps, source: -> { 2000 }
        threshold :rps, above: 1000
        proactive_initial_state alerts: [], silenced: false
      end

      state = klass.default_state
      state = call_handler(klass, :silence, state)
      state = call_handler(klass, :_scan, state)
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

      state = klass.default_state
      state = call_handler(klass, :_scan, state)
      health = call_handler(klass, :health, state)

      expect(health[:test_service]).to eq(:unhealthy)
    end
  end
end
