# frozen_string_literal: true

require_relative "spec_helper"
require "json"
require "stringio"

RSpec.describe Companion::MainApp do
  before do
    Companion::Shared::NoteStore.reset!
    Companion::Main::Support::AssistantAPI.reset!
  end

  it "builds and registers the greet contract" do
    config = described_class.send(:build!)
    expect(config.registry.registered?("GreetContract")).to be(true)
  end

  it "exposes non-secret credentials loader status" do
    status = described_class.credentials_status
    openai = status.dig(:providers, :openai)

    expect(status[:path]).to include("credentials.local.yml")
    expect([true, false]).to include(status[:loaded])
    expect(status[:override]).to be(false)
    expect(status.fetch(:providers)).to include(:openai, :anthropic)
    expect(openai[:env_key]).to eq("OPENAI_API_KEY")
    expect(%i[local_file environment file_present_not_loaded missing]).to include(openai[:source])
  end

  it "exposes the canonical notes interface for sibling apps" do
    expect(described_class.interface(:notes_api)).to be(Companion::Main::Support::NotesAPI)
  end

  it "exposes the playground ops interface for sibling apps" do
    expect(described_class.interface(:playground_ops_api)).to be(Companion::Main::Support::PlaygroundOpsAPI)
  end

  it "exposes the assistant interface for sibling apps" do
    expect(described_class.interface(:assistant_api)).to be(Companion::Main::Support::AssistantAPI)
  end

  it "exposes a status endpoint for the stack snapshot" do
    app = described_class.rack_app

    status, headers, body = app.call(
      "REQUEST_METHOD" => "GET",
      "PATH_INFO" => "/v1/home/status",
      "rack.input" => StringIO.new
    )

    payload = JSON.parse(body.each.to_a.join)

    expect(status).to eq(200)
    expect(headers["Content-Type"]).to include("application/json")
    expect(payload.dig("stack", "root_app")).to eq("main")
    expect(payload.dig("stack", "default_node")).to eq("main")
    expect(payload.dig("nodes", "main", "mounts", "dashboard")).to eq("/dashboard")
    expect(payload.dig("counts", "notes")).to eq(0)
  end

  it "creates and lists shared notes" do
    app = described_class.rack_app

    create_status, create_headers, create_body = app.call(
      "REQUEST_METHOD" => "POST",
      "PATH_INFO" => "/v1/notes",
      "CONTENT_TYPE" => "application/json",
      "rack.input" => StringIO.new(JSON.generate(text: "Check UPS battery"))
    )

    created = JSON.parse(create_body.each.to_a.join)

    list_status, list_headers, list_body = app.call(
      "REQUEST_METHOD" => "GET",
      "PATH_INFO" => "/v1/notes",
      "rack.input" => StringIO.new
    )

    listed = JSON.parse(list_body.each.to_a.join)

    expect(create_status).to eq(201)
    expect(create_headers["Content-Type"]).to include("application/json")
    expect(created.dig("note", "text")).to eq("Check UPS battery")
    expect(created["count"]).to eq(1)
    expect(list_status).to eq(200)
    expect(list_headers["Content-Type"]).to include("application/json")
    expect(listed["count"]).to eq(1)
    expect(listed.dig("notes", 0, "text")).to eq("Check UPS battery")
  end
end

RSpec.describe Companion::GreetContract do
  it "returns a greeting" do
    result = described_class.new(name: "Alice").result.greeting

    expect(result[:message]).to include("Alice")
    expect(result[:greeted_at]).to be_a(String)
  end
end
