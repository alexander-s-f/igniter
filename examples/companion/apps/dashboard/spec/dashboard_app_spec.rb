# frozen_string_literal: true

require_relative "spec_helper"
require "json"
require "stringio"
require "uri"

RSpec.describe Companion::DashboardApp do
  before do
    Companion::Shared::NoteStore.reset!
    Companion::Main::Support::AssistantAPI.reset!
    Companion::Main::Support::AssistantAPI.configure_runtime(
      mode: "manual",
      provider: "ollama",
      model: "qwen2.5-coder:latest",
      base_url: "http://127.0.0.1:11434",
      timeout_seconds: 20,
      delivery_mode: "simulate",
      delivery_strategy: "manual_only",
      openai_model: "gpt-4o",
      anthropic_model: "claude-sonnet-4-6"
    )
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
    expect(payload.dig("counts", "assistant_requests")).to eq(0)
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
    expect(html).to include("Operator desk and runtime visibility")
    expect(html).to include("Operator Desk")
    expect(html).to include("Companion Operator Desk")
    expect(html).to include("Dashboard")
    expect(html).to include("Assistant")
    expect(html).to include("Overview API")
    expect(html).to include("Operator API")
    expect(html).to include('action="/notes"')
    expect(html).to include("Operator Notes")
    expect(html).to include("Runtime Signals")
    expect(html).to include("Snapshot Preview")
    expect(html).to include("Orchestration Feed")
    expect(html).to include("Node Filters")
    expect(html).to include('name="q"')
  end

  it "renders the assistant page" do
    app = described_class.rack_app

    status, headers, body = app.call(
      "REQUEST_METHOD" => "GET",
      "PATH_INFO" => "/assistant",
      "rack.input" => StringIO.new
    )

    html = body.each.to_a.join

    expect(status).to eq(200)
    expect(headers["Content-Type"]).to include("text/html")
    expect(html).to include("Companion Assistant")
    expect(html).to include("Assistant intake and follow-up lane")
    expect(html).to include("Assistant Requests")
    expect(html).to include("Assistant Runtime")
    expect(html).to include("Prompt Profile")
    expect(html).to include("Prompt Package")
    expect(html).to include("Routing")
    expect(html).to include("Best Current Lane")
    expect(html).to include("Available Channels")
    expect(html).to include("Actionable Follow-ups")
    expect(html).to include("Completed Briefings")
    expect(html).to include("Workflow Feed")
    expect(html).to include('action="/assistant/requests"')
    expect(html).to include('action="/assistant/runtime"')
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

  it "creates and completes an assistant request from the dashboard" do
    app = described_class.rack_app

    create_status, create_headers, = app.call(
      "REQUEST_METHOD" => "POST",
      "PATH_INFO" => "/assistant/requests",
      "CONTENT_TYPE" => "application/x-www-form-urlencoded",
      "rack.input" => StringIO.new(URI.encode_www_form("requester" => "Alex", "request" => "Prepare a cluster rollout brief"))
    )

    request_record = Companion::Main::Support::AssistantAPI.all.first

    complete_status, complete_headers, = app.call(
      "REQUEST_METHOD" => "POST",
      "PATH_INFO" => "/assistant/followups/approve",
      "CONTENT_TYPE" => "application/x-www-form-urlencoded",
      "rack.input" => StringIO.new(
        URI.encode_www_form(
          "request_id" => request_record.fetch(:id),
          "briefing" => "Roll out with one seed, verify operator visibility, then add replicas.",
          "note" => "done"
        )
      )
    )

    refreshed = Companion::Main::Support::AssistantAPI.all.first

    expect(create_status).to eq(303)
    expect(create_headers["Location"]).to eq("/assistant?assistant_created=1")
    expect(complete_status).to eq(303)
    expect(complete_headers["Location"]).to eq("/assistant?assistant_completed=1")
    expect(refreshed.fetch(:status)).to eq(:completed)
    expect(refreshed.fetch(:briefing)).to include("one seed")
  end

  it "re-delivers a completed assistant request from the dashboard" do
    result = Companion::Main::Support::AssistantAPI.submit_request(
      requester: "Alex",
      request: "Prepare a cluster rollout brief"
    )
    request_record = result.fetch(:request)
    Companion::Main::Support::AssistantAPI.approve_request(
      request_id: request_record.fetch(:id),
      briefing: "Operator-approved rollout brief."
    )

    allow(Companion::Main::Support::AssistantExternalDelivery).to receive(:deliver).and_return(
      {
        status: :simulated,
        channel: :openai_api,
        channel_label: "OpenAI API",
        provider: :openai,
        model: "gpt-4o",
        mode: :simulate,
        output: "Simulated external delivery result.",
        reason: :simulation_mode
      }
    )

    app = described_class.rack_app

    redeliver_status, redeliver_headers, = app.call(
      "REQUEST_METHOD" => "POST",
      "PATH_INFO" => "/assistant/requests/redeliver",
      "CONTENT_TYPE" => "application/x-www-form-urlencoded",
      "rack.input" => StringIO.new(
        URI.encode_www_form(
          "request_id" => request_record.fetch(:id)
        )
      )
    )

    refreshed = Companion::Main::Support::AssistantAPI.all.first

    expect(redeliver_status).to eq(303)
    expect(redeliver_headers["Location"]).to eq("/assistant?assistant_redelivered=1")
    expect(refreshed.dig(:delivery, :status)).to eq(:simulated)
    expect(refreshed.dig(:delivery, :output)).to eq("Simulated external delivery result.")
  end

  it "updates the assistant runtime configuration from the dashboard" do
    app = described_class.rack_app

    update_status, update_headers, = app.call(
      "REQUEST_METHOD" => "POST",
      "PATH_INFO" => "/assistant/runtime",
      "CONTENT_TYPE" => "application/x-www-form-urlencoded",
      "rack.input" => StringIO.new(
        URI.encode_www_form(
          "mode" => "ollama",
          "provider" => "ollama",
          "model" => "qwen3:latest",
          "base_url" => "http://127.0.0.1:11434",
          "delivery_mode" => "simulate",
          "delivery_strategy" => "prefer_openai",
          "openai_model" => "gpt-4o",
          "anthropic_model" => "claude-sonnet-4-6"
        )
      )
    )

    overview_status, _overview_headers, overview_body = app.call(
      "REQUEST_METHOD" => "GET",
      "PATH_INFO" => "/api/overview",
      "rack.input" => StringIO.new
    )

    payload = JSON.parse(overview_body.each.to_a.join)

    expect(update_status).to eq(303)
    expect(update_headers["Location"]).to eq("/assistant?runtime_updated=1")
    expect(overview_status).to eq(200)
    expect(payload.dig("assistant", "runtime", "config", "mode")).to eq("ollama")
    expect(payload.dig("assistant", "runtime", "config", "model")).to eq("qwen3:latest")
    expect(payload.dig("assistant", "runtime", "config", "delivery_mode")).to eq("simulate")
    expect(payload.dig("assistant", "runtime", "config", "delivery_strategy")).to eq("prefer_openai")
    expect(payload.dig("assistant", "runtime", "recommendation", "title")).to eq("Best Current Lane")
  end

  it "renders a model comparison on the assistant page" do
    allow(Companion::Main::Support::AssistantAPI).to receive(:compare_runtime_outputs).and_return(
      {
        generated_at: "2026-04-21T10:00:00Z",
        summary: {
          requested_models: 2,
          completed: 1,
          unavailable: 1
        },
        results: [
          {
            model: "qwen3:latest",
            profile_key: :reasoned_ops,
            profile_label: "Reasoned Ops",
            status: :completed,
            reason: :ready,
            ready: true,
            briefing: "Draft from qwen3",
            prompt_package: {
              target: :openai_api,
              target_label: "OpenAI API",
              target_model: "gpt-4o",
              mode: :prompt_prep,
              profile_label: "Reasoned Ops",
              prefix_warmup: "Act as Companion in Reasoned Ops mode.",
              system_prompt: "System prompt",
              user_prompt: "User prompt"
            },
            checked_at: "2026-04-21T10:00:00Z"
          },
          {
            model: "gpt-oss:latest",
            profile_key: :executive_summary,
            profile_label: "Executive Summary",
            status: :unavailable,
            reason: :model_missing,
            ready: false,
            briefing: "Model not ready for drafting yet.",
            checked_at: "2026-04-21T10:00:00Z"
          }
        ]
      }
    )

    app = described_class.rack_app

    status, headers, body = app.call(
      "REQUEST_METHOD" => "POST",
      "PATH_INFO" => "/assistant/compare",
      "CONTENT_TYPE" => "application/x-www-form-urlencoded",
      "rack.input" => StringIO.new(
        URI.encode_www_form(
          "requester" => "Alex",
          "request" => "Compare rollout briefings",
          "models_csv" => "qwen3:latest, gpt-oss:latest"
        )
      )
    )

    html = body.each.to_a.join

    expect(status).to eq(200)
    expect(headers["Content-Type"]).to include("text/html")
    expect(html).to include("Model Lab")
    expect(html).to include("Comparison Summary")
    expect(html).to include("qwen3:latest")
    expect(html).to include("gpt-oss:latest")
    expect(html).to include("Draft from qwen3")
    expect(html).to include("What Companion would hand off to the external API lane")
  end
end
