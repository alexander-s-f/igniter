# frozen_string_literal: true

require_relative "spec_helper"
require "json"
require "stringio"

RSpec.describe "Companion assistant flow" do
  before do
    Companion::Shared::NoteStore.reset!
    Companion::Main::Support::AssistantAPI.reset!
  end

  it "opens a store-backed assistant request with a manual follow-up" do
    app = Companion::MainApp.rack_app

    status, headers, body = app.call(
      "REQUEST_METHOD" => "POST",
      "PATH_INFO" => "/v1/assistant/requests",
      "CONTENT_TYPE" => "application/json",
      "rack.input" => StringIO.new(JSON.generate(requester: "Alex", request: "Prepare a concise cluster rollout brief"))
    )

    payload = JSON.parse(body.each.to_a.join)

    expect(status).to eq(201)
    expect(headers["Content-Type"]).to include("application/json")
    expect(payload.dig("request", "requester")).to eq("Alex")
    expect(payload.dig("request", "status")).to eq("open")
    expect(payload.dig("followup", "summary", "total")).to eq(1)
    expect(payload.dig("followup", "summary", "manual_completion")).to eq(1)
  end

  it "approves a manual assistant follow-up and exposes the completed briefing" do
    result = Companion::Main::Support::AssistantAPI.submit_request(
      requester: "Alex",
      request: "Prepare a concise cluster rollout brief"
    )

    record = result.fetch(:request)

    Companion::Main::Support::AssistantAPI.approve_request(
      request_id: record.fetch(:id),
      briefing: "Cluster rollout brief: start with one seed node, validate joins, then add two replicas."
    )

    refreshed = Companion::Main::Support::AssistantAPI.all.first

    expect(refreshed.fetch(:status)).to eq(:completed)
    expect(refreshed.fetch(:briefing)).to include("Cluster rollout brief")
  end
end
