# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe Companion::Stack do
  describe Companion::Boot do
    it "builds default stores from stack and app config" do
      expect(described_class.default_data_store(app_name: :main)).to be_a(Igniter::Data::Stores::InMemory)
      expect(described_class.default_execution_store(app_name: :main)).to be_a(Igniter::Runtime::Stores::MemoryStore)
      expect(described_class.default_execution_store(app_name: :inference)).to be_a(Igniter::Runtime::Stores::MemoryStore)
      expect(described_class.default_execution_store(app_name: :dashboard)).to be_a(Igniter::Runtime::Stores::MemoryStore)
    end
  end

  describe "app registry" do
    it "registers main, inference, and dashboard apps" do
      expect(described_class.default_app).to eq(:main)
      expect(described_class.app_names).to include(:main, :inference, :dashboard)
      expect(described_class.app(:main)).to be(Companion::MainApp)
      expect(described_class.app(:inference)).to be(Companion::InferenceApp)
      expect(described_class.app(:dashboard)).to be(Companion::DashboardApp)
    end
  end

  describe "workspace wiring" do
    it "maps each app name to its leaf application class" do
      expect(described_class.app(:main)).to eq(Companion::MainApp)
      expect(described_class.app(:inference)).to eq(Companion::InferenceApp)
      expect(described_class.app(:dashboard)).to eq(Companion::DashboardApp)
    end
  end

  describe "current scaffold wiring" do
    it "ships stack metadata in stack.yml" do
      expect(File.exist?(File.join(Companion::Boot.root, "stack.yml"))).to be(true)
    end

    it "ships environment overlays in config/environments" do
      root = Companion::Boot.root

      expect(File.exist?(File.join(root, "config", "environments", "development.yml"))).to be(true)
      expect(File.exist?(File.join(root, "config", "environments", "production.yml"))).to be(true)
    end

    it "generates local dev commands against stack.rb inside the example root" do
      procfile = described_class.procfile_dev

      expect(procfile).to include("bundle exec ruby stack.rb main")
      expect(procfile).to include("bundle exec ruby stack.rb inference")
      expect(procfile).to include("bundle exec ruby stack.rb dashboard")
      expect(procfile).not_to include("examples/companion/stack.rb")
    end
  end

  describe Companion::LocalPipelineContract do
    let(:fake_audio) { Base64.strict_encode64("\x00\x00" * 1600) }

    it "runs a complete ASR→Intent→Chat→TTS pipeline" do
      result = described_class.new(
        audio_data: fake_audio,
        conversation_history: [],
        session_id: "spec-session"
      ).result

      expect(result.transcript).to be_a(String)
      expect(result.intent).to include(:category, :confidence)
      expect(result.response_text).to be_a(String)
      expect(result.audio_response).to be_a(String)
    end

    it "runs multiple turns preserving history" do
      history = []

      3.times do
        result = described_class.new(
          audio_data: fake_audio,
          conversation_history: history,
          session_id: "spec-session-multi"
        ).result
        history << { role: "user", content: result.transcript }
        history << { role: "assistant", content: result.response_text }
      end

      expect(history.size).to eq(6)
    end
  end
end
