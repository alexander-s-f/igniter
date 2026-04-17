# frozen_string_literal: true

require_relative "spec_helper"
require "json"
require "stringio"

RSpec.describe Companion::MainApp do
  before do
    Companion::Shared::NoteStore.reset!
  end

  it "builds and registers the greet contract" do
    config = described_class.send(:build!)
    expect(config.registry.registered?("GreetContract")).to be(true)
    expect(config.peer_name).to eq("companion-seed")
    expect(config.peer_capabilities).to include(:mesh_seed, :notifications, :notes_api, :routing)
    expect(config.peer_identity).not_to be_nil
    expect(config.peer_identity.node_id).to eq("companion-seed")
    expect(config.peer_trust_store.size).to eq(3)
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
    expect(payload.dig("stack", "default_app")).to eq("main")
    expect(payload.dig("stack", "default_service")).to eq("seed")
    expect(payload.dig("current_node", "node", "name")).to eq("companion-seed")
    expect(payload.dig("current_node", "identity", "node_id")).to eq("companion-seed")
    expect(payload.dig("current_node", "trust", "known_peers")).to eq(3)
    expect(payload.dig("current_node", "capabilities", "mocked")).to include("notifications")
    expect(payload.dig("services", "seed", "apps")).to eq(%w[main dashboard])
    expect(payload.dig("services", "edge", "port")).to eq(4668)
    expect(payload.dig("services", "analyst", "port")).to eq(4669)
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
