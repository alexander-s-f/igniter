# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe Companion::Stack do
  around do |example|
    stack_class = Companion::Stack
    original_env_name = stack_class.instance_variable_get(:@environment_name)
    original_igniter_env = ENV["IGNITER_ENV"]

    example.run
  ensure
    stack_class.instance_variable_set(:@environment_name, original_env_name)
    stack_class.send(:reset_stack_state!)

    if original_igniter_env.nil?
      ENV.delete("IGNITER_ENV")
    else
      ENV["IGNITER_ENV"] = original_igniter_env
    end
  end

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

  describe "stack cli smoke" do
    it "prints Procfile.dev commands for all apps" do
      expect do
        described_class.start_cli(%w[--print-procfile-dev])
      end.to output(
        a_string_including(
          "main:",
          "bundle exec ruby stack.rb main",
          "inference:",
          "bundle exec ruby stack.rb inference",
          "dashboard:",
          "bundle exec ruby stack.rb dashboard"
        )
      ).to_stdout
    end

    it "prints compose yaml for the current scaffold" do
      expect do
        described_class.start_cli(%w[--print-compose])
      end.to output(
        a_string_including(
          "services:",
          "command: bundle exec ruby stack.rb main",
          "command: bundle exec ruby stack.rb inference",
          "command: bundle exec ruby stack.rb dashboard",
          "companion_var:"
        )
      ).to_stdout
    end

    it "prints env-aware Procfile.dev output when an overlay is selected" do
      expect do
        described_class.start_cli(%w[--env production --print-procfile-dev])
      end.to output(
        a_string_including(
          "IGNITER_ENV=production",
          "bundle exec ruby stack.rb main",
          "bundle exec ruby stack.rb inference",
          "bundle exec ruby stack.rb dashboard"
        )
      ).to_stdout
    end
  end

  describe "http handler compatibility" do
    it "accepts the current router env keyword across companion handlers" do
      handlers = [
        Companion::Dashboard::HomeHandler,
        Companion::Dashboard::OverviewHandler,
        Companion::Dashboard::ReminderActionHandler,
        Companion::Dashboard::ReminderCreateHandler,
        Companion::Dashboard::SchemaPageHandler,
        Companion::Dashboard::SchemaSubmissionHandler,
        Companion::Dashboard::TelegramPreferenceHandler,
        Companion::Dashboard::ViewSchemaDeleteHandler,
        Companion::Dashboard::ViewSchemaHandler,
        Companion::Dashboard::ViewSchemaPatchHandler,
        Companion::Dashboard::ViewSchemasHandler,
        Companion::Dashboard::ViewSubmissionHandler,
        Companion::TelegramWebhook
      ]

      handlers.each do |handler|
        env_param = handler.method(:call).parameters.find { |type, name| [:key, :keyreq].include?(type) && name == :env }
        expect(env_param).not_to be_nil, "#{handler} must accept env: for router compatibility"
      end
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
