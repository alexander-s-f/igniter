# frozen_string_literal: true

require_relative "spec_helper"
require "uri"

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

  describe Companion::Dashboard::ReminderCreateHandler do
    it "creates a reminder from form params and redirects back to dashboard" do
      result = described_class.call(
        params: {},
        body: {
          "task" => "Pay rent",
          "timing" => "tomorrow morning",
          "channel" => "telegram",
          "chat_id" => "12345",
          "notifications_enabled" => "1"
        },
        headers: { "Content-Type" => "application/x-www-form-urlencoded" },
        raw_body: "task=Pay+rent",
        config: nil
      )

      reminder = Companion::ReminderStore.active.first

      expect(result[:status]).to eq(303)
      expect(result[:headers]["Location"]).to include("/?created_reminder=")
      expect(reminder).to include(
        "task" => "Pay rent",
        "timing" => "tomorrow morning",
        "channel" => "telegram",
        "chat_id" => "12345",
        "notifications_enabled" => true
      )
    end

    it "returns a validation error page when task is blank" do
      result = described_class.call(
        params: {},
        body: { "task" => "", "timing" => "tomorrow" },
        headers: {},
        raw_body: "",
        config: nil
      )

      expect(result[:status]).to eq(422)
      expect(result[:headers]["Content-Type"]).to include("text/html")
      expect(result[:body]).to include("Reminder could not be created")
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
      expect(result[:body]).to include("<form")
      expect(result[:body]).to include('action="/reminders"')
      expect(result[:body]).to include('method="post"')
      expect(result[:body]).to include("/api/telegram/preferences")
      expect(result[:body]).to include("Mark Completed")
      expect(result[:body]).to include("/views/training-checkin")
      expect(result[:body]).to include("@tailwindcss/browser@4")
      expect(result[:body]).to include("font-display")
    end
  end

  describe Companion::Dashboard::SchemaPageHandler do
    it "renders a schema-driven view from the store" do
      Companion::Dashboard::ViewSchemaCatalog.seed!

      result = described_class.call(
        params: { id: "training-checkin" },
        body: {},
        headers: {},
        raw_body: "",
        config: nil
      )

      expect(result[:status]).to eq(200)
      expect(result[:headers]["Content-Type"]).to include("text/html")
      expect(result[:body]).to include("Daily Training Check-in")
      expect(result[:body]).to include("Schema-driven page rendered from persisted view definition.")
      expect(result[:body]).to include('action="/views/training-checkin/submissions"')
    end
  end

  describe Companion::Dashboard::SchemaSubmissionHandler do
    it "stores a schema submission and redirects back to the schema page" do
      Companion::Dashboard::ViewSchemaCatalog.seed!

      result = described_class.call(
        params: { id: "training-checkin" },
        body: {
          "_action" => "submit_checkin",
          "mood" => "great",
          "duration_minutes" => "45",
          "notes" => "Strong session",
          "share_with_coach" => "1"
        },
        headers: { "Content-Type" => "application/x-www-form-urlencoded" },
        raw_body: "mood=great",
        config: nil
      )

      submissions = Companion::Dashboard::ViewSubmissionStore.for_view("training-checkin")
      checkins = Companion::Dashboard::TrainingCheckinStore.all

      expect(result[:status]).to eq(303)
      expect(result[:headers]["Location"]).to include("/views/training-checkin")
      expect(submissions.size).to eq(1)
      expect(submissions.first).to include(
        "action_id" => "submit_checkin",
        "schema_version" => 1,
        "status" => "processed"
      )
      expect(submissions.first.dig("raw_payload", "duration_minutes")).to eq("45")
      expect(submissions.first.dig("normalized_payload", "duration_minutes")).to eq(45)
      expect(submissions.first.dig("normalized_payload", "share_with_coach")).to eq(true)
      expect(submissions.first.dig("processing_result", "type")).to eq("contract")
      expect(checkins.size).to eq(1)
      expect(checkins.first.dig("checkin", "duration_minutes")).to eq(45)
      expect(checkins.first.dig("checkin", "share_with_coach")).to eq(true)
    end

    it "re-renders the schema form with validation errors and preserves values" do
      Companion::Dashboard::ViewSchemaCatalog.seed!

      result = described_class.call(
        params: { id: "training-checkin" },
        body: {
          "_action" => "submit_checkin",
          "mood" => "great",
          "duration_minutes" => "",
          "notes" => "Still showed up"
        },
        headers: { "Content-Type" => "application/x-www-form-urlencoded" },
        raw_body: "mood=great",
        config: nil
      )

      expect(result[:status]).to eq(422)
      expect(result[:headers]["Content-Type"]).to include("text/html")
      expect(result[:body]).to include("Please review the highlighted fields.")
      expect(result[:body]).to include("is required")
      expect(result[:body]).to include('name="notes"')
      expect(result[:body]).to include(">Still showed up</textarea>")
      expect(result[:body]).to include('<option value="great" selected>Great</option>')
      expect(Companion::Dashboard::ViewSubmissionStore.for_view("training-checkin")).to be_empty
      expect(Companion::Dashboard::TrainingCheckinStore.all).to be_empty
    end
  end

  describe Companion::Dashboard::ViewSchemasHandler do
    it "lists stored schemas" do
      Companion::Dashboard::ViewSchemaCatalog.seed!

      result = described_class.call(
        params: {},
        body: {},
        headers: {},
        raw_body: "",
        config: nil
      )

      parsed = JSON.parse(result[:body])

      expect(result[:status]).to eq(200)
      expect(parsed.fetch("schemas")).to include(
        include(
          "id" => "training-checkin",
          "title" => "Daily Training Check-in"
        )
      )
    end

    it "creates a schema via POST payload" do
      result = described_class.call(
        params: {},
        body: {
          "id" => "public-poll",
          "version" => 1,
          "kind" => "page",
          "title" => "Public Poll",
          "actions" => {
            "submit_poll" => { "method" => "post", "path" => "/views/public-poll/submissions" }
          },
          "layout" => {
            "type" => "stack",
            "children" => [
              { "type" => "heading", "level" => 1, "text" => "Public Poll" },
              {
                "type" => "form",
                "action" => "submit_poll",
                "children" => [
                  { "type" => "input", "name" => "answer", "label" => "Your answer" },
                  { "type" => "submit", "label" => "Send" }
                ]
              }
            ]
          }
        },
        headers: { "Content-Type" => "application/json" },
        raw_body: '{"id":"public-poll"}',
        config: nil
      )

      parsed = JSON.parse(result[:body])

      expect(result[:status]).to eq(201)
      expect(parsed.dig("schema", "id")).to eq("public-poll")
      expect(Companion::Dashboard::ViewSchemaCatalog.store.get("public-poll")).not_to be_nil
    end
  end

  describe Companion::Dashboard::ViewSchemaHandler do
    it "returns one stored schema" do
      Companion::Dashboard::ViewSchemaCatalog.seed!

      result = described_class.call(
        params: { id: "training-checkin" },
        body: {},
        headers: {},
        raw_body: "",
        config: nil
      )

      parsed = JSON.parse(result[:body])
      expect(result[:status]).to eq(200)
      expect(parsed.dig("schema", "id")).to eq("training-checkin")
    end
  end

  describe Companion::Dashboard::ViewSchemaPatchHandler do
    it "patches a schema and increments version" do
      Companion::Dashboard::ViewSchemaCatalog.seed!

      result = described_class.call(
        params: { id: "training-checkin" },
        body: { "title" => "Training Poll" },
        headers: { "Content-Type" => "application/json" },
        raw_body: '{"title":"Training Poll"}',
        config: nil
      )

      parsed = JSON.parse(result[:body])
      expect(result[:status]).to eq(200)
      expect(parsed.dig("schema", "title")).to eq("Training Poll")
      expect(parsed.dig("schema", "version")).to eq(2)
    end
  end

  describe Companion::Dashboard::ViewSchemaDeleteHandler do
    it "deletes a stored schema" do
      Companion::Dashboard::ViewSchemaCatalog.seed!

      result = described_class.call(
        params: { id: "training-checkin" },
        body: {},
        headers: {},
        raw_body: "",
        config: nil
      )

      parsed = JSON.parse(result[:body])
      expect(result[:status]).to eq(200)
      expect(parsed).to include("ok" => true, "deleted" => "training-checkin")
      expect(Companion::Dashboard::ViewSchemaCatalog.store.get("training-checkin")).to be_nil
    end
  end
end
