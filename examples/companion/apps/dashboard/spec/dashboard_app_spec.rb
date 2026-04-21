# frozen_string_literal: true

require_relative "spec_helper"
require "json"
require "stringio"
require "uri"

RSpec.describe Companion::DashboardApp do
  before do
    Companion::Shared::NoteStore.reset!
  end

  it "renders the canonical operator endpoint" do
    app = described_class.rack_app

    status, headers, body = app.call(
      "REQUEST_METHOD" => "GET",
      "PATH_INFO" => "/api/operator",
      "rack.input" => StringIO.new
    )

    payload = JSON.parse(body.each.to_a.join)

    expect(status).to eq(200)
    expect(headers["Content-Type"]).to include("application/json")
    expect(payload["app"]).to eq("Companion::DashboardApp")
    expect(payload["scope"]).to eq("mode" => "app")
    expect(payload.dig("summary", "total")).to eq(0)
  end

  it "renders the built-in operator console" do
    app = described_class.rack_app

    status, headers, body = app.call(
      "REQUEST_METHOD" => "GET",
      "PATH_INFO" => "/operator",
      "rack.input" => StringIO.new
    )

    html = body.each.to_a.join

    expect(status).to eq(200)
    expect(headers["Content-Type"]).to include("text/html")
    expect(html).to include("Operator Console")
    expect(html).to include("/api/operator")
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
    expect(payload.dig("stack", "root_app")).to eq("main")
    expect(payload.dig("stack", "default_node")).to eq("main")
    expect(payload.dig("nodes", "main", "mounts", "dashboard")).to eq("/dashboard")
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
    expect(html).to include("Assistant and operator proving ground")
    expect(html).to include("Operator Desk")
    expect(html).to include("Companion Operator Desk")
    expect(html).to include("Overview API")
    expect(html).to include("Operator API")
    expect(html).to include('action="/notes"')
    expect(html).to include("Operator Notes")
    expect(html).to include("Snapshot Preview")
    expect(html).to include("Node Filters")
    expect(html).to include('name="q"')
  end

  it "preserves node filter query values on the home page" do
    app = described_class.rack_app

    status, _headers, body = app.call(
      "REQUEST_METHOD" => "GET",
      "PATH_INFO" => "/",
      "QUERY_STRING" => URI.encode_www_form("q" => "main", "public" => "false"),
      "rack.input" => StringIO.new
    )

    html = body.each.to_a.join

    expect(status).to eq(200)
    expect(html).to include('value="main"')
    expect(html).to include('name="public"')
    expect(html).to include('value="false" selected')
  end

  it "paginates operator notes while preserving other query params" do
    4.times do |index|
      Companion::Shared::NoteStore.add("Follow-up ##{index + 1}")
    end

    app = described_class.rack_app

    status, _headers, body = app.call(
      "REQUEST_METHOD" => "GET",
      "PATH_INFO" => "/",
      "QUERY_STRING" => URI.encode_www_form("q" => "main", "notes_page" => "2"),
      "rack.input" => StringIO.new
    )

    html = body.each.to_a.join

    expect(status).to eq(200)
    expect(html).to include("Showing 4-4 of 4 notes")
    expect(html).to include("Follow-up #1")
    expect(html).to include('/?q=main')
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
