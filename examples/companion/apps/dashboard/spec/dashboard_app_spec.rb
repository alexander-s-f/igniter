# frozen_string_literal: true

require_relative "spec_helper"
require "json"
require "stringio"
require "uri"

RSpec.describe Companion::DashboardApp do
  before do
    Companion::Shared::NoteStore.reset!
  end

  it "renders the overview endpoint" do
    app = described_class.rack_app

    status, headers, body = app.call(
      "REQUEST_METHOD" => "GET",
      "PATH_INFO" => "/api/overview",
      "rack.input" => StringIO.new
    )

    payload = JSON.parse(body.each.to_a.join)

    expect(status).to eq(200)
    expect(headers["Content-Type"]).to include("application/json")
    expect(payload.dig("stack", "default_app")).to eq("main")
    expect(payload.dig("stack", "default_service")).to eq("seed")
    expect(payload.dig("services", "seed", "apps")).to eq(%w[main dashboard])
    expect(payload.dig("current_node", "node", "service")).to eq("seed")
    expect(payload.dig("current_node", "identity", "node_id")).to eq("companion-seed")
    expect(payload.dig("counts", "notes")).to eq(0)
  end

  it "renders the home page" do
    app = described_class.rack_app

    status, headers, body = app.call(
      "REQUEST_METHOD" => "GET",
      "PATH_INFO" => "/",
      "rack.input" => StringIO.new
    )

    html = body.each.to_a.join

    expect(status).to eq(200)
    expect(headers["Content-Type"]).to include("text/html")
    expect(html).to include("Companion Dashboard")
    expect(html).to include("Overview API")
    expect(html).to include("Current Node")
    expect(html).to include('action="/notes"')
    expect(html).to include("Shared Notes")
  end

  it "creates a note from the dashboard form and exposes it in the overview" do
    app = described_class.rack_app

    create_status, create_headers, = app.call(
      "REQUEST_METHOD" => "POST",
      "PATH_INFO" => "/notes",
      "CONTENT_TYPE" => "application/x-www-form-urlencoded",
      "rack.input" => StringIO.new(URI.encode_www_form("text" => "Top off the UPS rack"))
    )

    overview_status, overview_headers, overview_body = app.call(
      "REQUEST_METHOD" => "GET",
      "PATH_INFO" => "/api/overview",
      "rack.input" => StringIO.new
    )

    payload = JSON.parse(overview_body.each.to_a.join)

    expect(create_status).to eq(303)
    expect(create_headers["Location"]).to eq("/?note_created=1")
    expect(overview_status).to eq(200)
    expect(overview_headers["Content-Type"]).to include("application/json")
    expect(payload.dig("counts", "notes")).to eq(1)
    expect(payload.dig("notes", 0, "text")).to eq("Top off the UPS rack")
  end
end
