# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe Companion::DashboardApp do
  it "uses apps/dashboard as its root directory" do
    expect(described_class.root_dir).to eq(File.expand_path("..", __dir__))
  end

  describe Companion::Dashboard::OverviewHandler do
    it "returns a JSON snapshot of dashboard state" do
      Companion::NotesStore.save("status", "green")
      Companion::ReminderStore.create(
        task: "Call Alice",
        timing: "tomorrow",
        request: "remind me to call Alice tomorrow",
        channel: "telegram",
        chat_id: "12345",
        notifications_enabled: true
      )
      Companion::TelegramBindingsStore.upsert(
        {
          "chat" => { "id" => 12345, "username" => "alex" },
          "from" => { "id" => 7, "username" => "alex" }
        },
        prefer: true
      )
      Companion::NotificationPreferencesStore.set_telegram_enabled("12345", true)

      result = described_class.call(
        params: {},
        body: {},
        headers: {},
        raw_body: "",
        config: nil
      )

      parsed = JSON.parse(result[:body])

      expect(result[:status]).to eq(200)
      expect(result[:headers]["Content-Type"]).to eq("application/json")
      expect(parsed.dig("counts", "notes")).to eq(1)
      expect(parsed.dig("counts", "active_reminders")).to eq(1)
      expect(parsed.dig("telegram", "preferred_chat_id")).to eq("12345")
    end
  end

  describe Companion::Dashboard::TelegramPreferenceHandler do
    it "updates persisted Telegram notification preferences" do
      result = described_class.call(
        params: {},
        body: { "chat_id" => "12345", "enabled" => false },
        headers: {},
        raw_body: '{"chat_id":"12345","enabled":false}',
        config: nil
      )

      parsed = JSON.parse(result[:body])

      expect(result[:status]).to eq(200)
      expect(parsed).to include("ok" => true, "telegram_enabled" => false)
      expect(Companion::NotificationPreferencesStore.telegram_enabled?("12345")).to be(false)
    end
  end

  describe Companion::Dashboard::ReminderActionHandler do
    it "marks a reminder as completed" do
      reminder = Companion::ReminderStore.create(
        task: "Call Alice",
        timing: "tomorrow",
        request: "remind me to call Alice tomorrow"
      )

      result = described_class.call(
        params: { id: reminder.fetch("id") },
        body: {},
        headers: {},
        raw_body: "",
        config: nil
      )

      parsed = JSON.parse(result[:body])

      expect(result[:status]).to eq(200)
      expect(parsed.dig("reminder", "status")).to eq("completed")
      expect(Companion::ReminderStore.active).to be_empty
    end
  end

  describe Companion::Dashboard::HomeHandler do
    it "renders an HTML overview page" do
      Companion::TelegramBindingsStore.upsert(
        {
          "chat" => { "id" => 12345, "username" => "alex" },
          "from" => { "id" => 7, "username" => "alex" }
        },
        prefer: true
      )
      Companion::NotificationPreferencesStore.set_telegram_enabled("12345", true)
      Companion::ReminderStore.create(
        task: "Pay rent",
        timing: "tomorrow",
        request: "remind me to pay rent tomorrow",
        channel: "telegram",
        chat_id: "12345",
        notifications_enabled: true
      )

      result = described_class.call(
        params: {},
        body: {},
        headers: {},
        raw_body: "",
        config: nil
      )

      expect(result[:status]).to eq(200)
      expect(result[:headers]["Content-Type"]).to include("text/html")
      expect(result[:body]).to include("Companion Dashboard")
      expect(result[:body]).to include("/api/overview")
      expect(result[:body]).to include("/api/telegram/preferences")
      expect(result[:body]).to include("Mark Completed")
    end
  end
end
