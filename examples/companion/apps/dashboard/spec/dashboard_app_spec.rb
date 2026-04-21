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
    expect(html).to include("Scenario Presets")
    expect(html).to include("Prompt Profile")
    expect(html).to include("Incident Triage Details")
    expect(html).to include("Technical Rollout Details")
    expect(html).to include("Research Synthesis Details")
    expect(html).to include("Rollout Inputs")
    expect(html).to include("Artifacts")
    expect(html).to include("Prompt Package")
    expect(html).to include("Routing")
    expect(html).to include("Credential Policy")
    expect(html).to include("Credential Source")
    expect(html).to include("node-local")
    expect(html).to include("Best Current Lane")
    expect(html).to include("Evaluation Memory")
    expect(html).to include("Available Channels")
    expect(html).to include("Actionable Follow-ups")
    expect(html).to include("Completed Briefings")
    expect(html).to include("Workflow Feed")
    expect(html).to include('action="/assistant/requests"')
    expect(html).to include('action="/assistant/runtime"')
    expect(html).to include('name="scenario"')
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

  it "offers a note-to-assistant jump with prefilled evidence" do
    Companion::Shared::NoteStore.add("Top off the UPS rack")
    app = described_class.rack_app

    status, _headers, body = app.call(
      "REQUEST_METHOD" => "GET",
      "PATH_INFO" => "/",
      "rack.input" => StringIO.new
    )

    html = body.each.to_a.join

    expect(status).to eq(200)
    expect(html).to include("Use in Assistant")
    expect(html).to include("/assistant?scenario=general_brief")
    expect(html).to include("artifacts=note%3A+Top+off+the+UPS+rack")
  end

  it "offers followup and runtime-node jumps into the assistant lane" do
    Companion::Main::Support::AssistantAPI.submit_request(
      requester: "Alex",
      request: "Prepare a dashboard stabilization brief"
    )

    app = described_class.rack_app

    status, _headers, body = app.call(
      "REQUEST_METHOD" => "GET",
      "PATH_INFO" => "/",
      "rack.input" => StringIO.new
    )

    html = body.each.to_a.join

    expect(status).to eq(200)
    expect(html).to include("/assistant?scenario=incident_triage")
    expect(html).to include("affected_system=briefing")
    expect(html).to include("request=Use+the+attached+orchestration+follow-up+as+evidence+and+propose+the+next+best+operator+action.")
    expect(html).to include("/assistant?scenario=technical_rollout")
    expect(html).to include("target_environment=main")
    expect(html).to include("request=Use+the+attached+runtime+node+snippet+and+prepare+the+next+operator+follow-up.")
  end

  it "offers runtime-signal and snapshot-preview jumps into the assistant lane" do
    app = described_class.rack_app

    status, _headers, body = app.call(
      "REQUEST_METHOD" => "GET",
      "PATH_INFO" => "/",
      "rack.input" => StringIO.new
    )

    html = body.each.to_a.join

    expect(status).to eq(200)
    expect(html).to include("/assistant?scenario=incident_triage")
    expect(html).to include("request=Use+the+attached+runtime+signal+snapshot+as+evidence+and+propose+the+next+best+operator+follow-up.")
    expect(html).to include("/assistant?scenario=research_synthesis")
    expect(html).to include("request=Synthesize+the+attached+runtime+snapshot+and+recommend+the+next+best+operator+action.")
    expect(html).to include("sources=operator+snapshot+preview")
  end

  it "prefills the assistant intake from query params" do
    app = described_class.rack_app

    status, headers, body = app.call(
      "REQUEST_METHOD" => "GET",
      "PATH_INFO" => "/assistant",
      "QUERY_STRING" => URI.encode_www_form(
        "scenario" => "general_brief",
        "request" => "Use the attached operator note as evidence and prepare the next best operator follow-up.",
        "artifacts" => "note: Top off the UPS rack"
      ),
      "rack.input" => StringIO.new
    )

    html = body.each.to_a.join

    expect(status).to eq(200)
    expect(headers["Content-Type"]).to include("text/html")
    expect(html).to include("Use the attached operator note as evidence and prepare the next best operator follow-up.")
    expect(html).to include("note: Top off the UPS rack")
  end

  it "creates and completes an assistant request from the dashboard" do
    app = described_class.rack_app

    create_status, create_headers, = app.call(
        "REQUEST_METHOD" => "POST",
        "PATH_INFO" => "/assistant/requests",
        "CONTENT_TYPE" => "application/x-www-form-urlencoded",
        "rack.input" => StringIO.new(
          URI.encode_www_form(
            "requester" => "Alex",
            "scenario" => "incident_triage",
            "affected_system" => "dashboard-api",
            "urgency" => "critical",
            "symptoms" => "5xx spikes after deploy",
            "request" => "Stabilize the dashboard incident and propose the next operator move"
          )
        )
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
    expect(refreshed.dig(:scenario, :key)).to eq(:incident_triage)
    expect(refreshed.dig(:scenario_context, :affected_system)).to eq("dashboard-api")
    expect(refreshed.dig(:operator_checklist)).not_to be_empty
    expect(refreshed.fetch(:briefing)).to include("one seed")
  end

  it "creates a technical-rollout request from the dashboard with rollout context" do
    app = described_class.rack_app

    create_status, create_headers, = app.call(
      "REQUEST_METHOD" => "POST",
      "PATH_INFO" => "/assistant/requests",
      "CONTENT_TYPE" => "application/x-www-form-urlencoded",
      "rack.input" => StringIO.new(
        URI.encode_www_form(
          "requester" => "Alex",
          "scenario" => "technical_rollout",
          "target_environment" => "staging",
          "change_scope" => "roll out dashboard v2",
          "verification_plan" => "health + smoke",
          "rollback_plan" => "revert to v1",
          "request" => "Prepare the next rollout gate"
        )
      )
    )

    request_record = Companion::Main::Support::AssistantAPI.all.first

    expect(create_status).to eq(303)
    expect(create_headers["Location"]).to eq("/assistant?assistant_created=1")
    expect(request_record.dig(:scenario, :key)).to eq(:technical_rollout)
    expect(request_record.dig(:scenario_context, :target_environment)).to eq("staging")
    expect(request_record.fetch(:scenario_summary)).to include("env=staging")
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

  it "saves a completed briefing as an operator note from the assistant page" do
    result = Companion::Main::Support::AssistantAPI.submit_request(
      requester: "Alex",
      request: "Prepare a cluster rollout brief"
    )
    request_record = result.fetch(:request)
    Companion::Main::Support::AssistantAPI.approve_request(
      request_id: request_record.fetch(:id),
      briefing: "Roll out to staging, verify health checks, then promote.",
      note: "approved"
    )

    app = described_class.rack_app

    save_status, save_headers, = app.call(
      "REQUEST_METHOD" => "POST",
      "PATH_INFO" => "/assistant/requests/note",
      "CONTENT_TYPE" => "application/x-www-form-urlencoded",
      "rack.input" => StringIO.new(
        URI.encode_www_form(
          "request_id" => request_record.fetch(:id)
        )
      )
    )

    note = Companion::Shared::NoteStore.all.first

    expect(save_status).to eq(303)
    expect(save_headers["Location"]).to eq("/assistant?assistant_noted=1")
    expect(note.fetch("source")).to eq("assistant")
    expect(note.fetch("text")).to include("Assistant briefing")
    expect(note.fetch("text")).to include("Roll out to staging")
  end

  it "offers completed-briefing actions back into the operator loop" do
    result = Companion::Main::Support::AssistantAPI.submit_request(
      requester: "Alex",
      request: "Prepare a cluster rollout brief",
      scenario: "technical_rollout",
      scenario_context: {
        target_environment: "staging",
        verification_plan: "health + smoke",
        rollback_plan: "revert to previous release"
      }
    )
    request_record = result.fetch(:request)
    Companion::Main::Support::AssistantAPI.approve_request(
      request_id: request_record.fetch(:id),
      briefing: "Roll out to staging, verify health checks, then promote.",
      note: "approved"
    )

    app = described_class.rack_app

    status, _headers, body = app.call(
      "REQUEST_METHOD" => "GET",
      "PATH_INFO" => "/assistant",
      "rack.input" => StringIO.new
    )

    html = body.each.to_a.join

    expect(status).to eq(200)
    expect(html).to include("Save as Note")
    expect(html).to include("Promote to Rollout")
    expect(html).to include("Re-open as Manual Action")
    expect(html).to include("/assistant?scenario=technical_rollout")
    expect(html).to include("request=Turn+the+attached+completed+briefing+into+a+rollout-ready+plan+with+verification+and+rollback+gates.")
    expect(html).to include("target_environment=staging")
  end

  it "reopens a completed briefing as a manual assistant action from the dashboard" do
    result = Companion::Main::Support::AssistantAPI.submit_request(
      requester: "Alex",
      scenario: "incident_triage",
      request: "Prepare an operator incident brief"
    )
    request_record = result.fetch(:request)
    Companion::Main::Support::AssistantAPI.approve_request(
      request_id: request_record.fetch(:id),
      briefing: "Operator-approved incident brief.",
      note: "approved"
    )

    app = described_class.rack_app

    reopen_status, reopen_headers, = app.call(
      "REQUEST_METHOD" => "POST",
      "PATH_INFO" => "/assistant/requests/reopen",
      "CONTENT_TYPE" => "application/x-www-form-urlencoded",
      "rack.input" => StringIO.new(
        URI.encode_www_form(
          "request_id" => request_record.fetch(:id)
        )
      )
    )

    reopened = Companion::Main::Support::AssistantAPI.all.first

    expect(reopen_status).to eq(303)
    expect(reopen_headers["Location"]).to eq("/assistant?assistant_reopened=1")
    expect(reopened.fetch(:status)).to eq(:open)
    expect(reopened.fetch(:request)).to eq("Use the attached completed briefing as evidence and propose the next concrete operator follow-up.")
    expect(reopened.dig(:delivery, :reason)).to eq(:reopened_manual_followup)
  end

  it "shows evaluation memory after assistant outcome actions" do
    result = Companion::Main::Support::AssistantAPI.submit_request(
      requester: "Alex",
      scenario: "technical_rollout",
      request: "Prepare a cluster rollout brief"
    )
    request_record = result.fetch(:request)
    Companion::Main::Support::AssistantAPI.approve_request(
      request_id: request_record.fetch(:id),
      briefing: "Operator-approved rollout brief.",
      note: "approved"
    )
    Companion::Main::Support::AssistantAPI.redeliver_request(request_id: request_record.fetch(:id))

    app = described_class.rack_app

    app.call(
      "REQUEST_METHOD" => "POST",
      "PATH_INFO" => "/assistant/requests/note",
      "CONTENT_TYPE" => "application/x-www-form-urlencoded",
      "rack.input" => StringIO.new(
        URI.encode_www_form(
          "request_id" => request_record.fetch(:id)
        )
      )
    )

    status, _headers, body = app.call(
      "REQUEST_METHOD" => "GET",
      "PATH_INFO" => "/assistant",
      "rack.input" => StringIO.new
    )

    html = body.each.to_a.join

    expect(status).to eq(200)
    expect(html).to include("Evaluation Memory")
    expect(html).to include("Completed Manual Followup")
    expect(html).to include("Redelivered")
    expect(html).to include("Saved As Note")
  end

  it "records explicit operator feedback on a completed briefing" do
    result = Companion::Main::Support::AssistantAPI.submit_request(
      requester: "Alex",
      scenario: "research_synthesis",
      request: "Prepare a research synthesis brief"
    )
    request_record = result.fetch(:request)
    Companion::Main::Support::AssistantAPI.approve_request(
      request_id: request_record.fetch(:id),
      briefing: "Operator-approved research synthesis.",
      note: "approved"
    )

    app = described_class.rack_app

    feedback_status, feedback_headers, = app.call(
      "REQUEST_METHOD" => "POST",
      "PATH_INFO" => "/assistant/requests/feedback",
      "CONTENT_TYPE" => "application/x-www-form-urlencoded",
      "rack.input" => StringIO.new(
        URI.encode_www_form(
          "request_id" => request_record.fetch(:id),
          "feedback" => "useful"
        )
      )
    )

    status, _headers, body = app.call(
      "REQUEST_METHOD" => "GET",
      "PATH_INFO" => "/assistant",
      "rack.input" => StringIO.new
    )

    html = body.each.to_a.join

    expect(feedback_status).to eq(303)
    expect(feedback_headers["Location"]).to eq("/assistant?assistant_feedback=1")
    expect(html).to include("Quick Feedback")
    expect(html).to include("Useful")
    expect(html).to include("Feedback Useful")
  end

  it "shows learning insights derived from evaluation memory" do
    result = Companion::Main::Support::AssistantAPI.submit_request(
      requester: "Alex",
      scenario: "research_synthesis",
      request: "Prepare a research synthesis brief"
    )
    request_record = result.fetch(:request)
    Companion::Main::Support::AssistantAPI.approve_request(
      request_id: request_record.fetch(:id),
      briefing: "Operator-approved research synthesis."
    )
    Companion::Main::Support::AssistantAPI.observe_request(
      request_id: request_record.fetch(:id),
      action: :feedback_useful,
      source: :spec,
      metadata: { feedback: "useful" }
    )

    app = described_class.rack_app

    status, _headers, body = app.call(
      "REQUEST_METHOD" => "GET",
      "PATH_INFO" => "/assistant",
      "rack.input" => StringIO.new
    )

    html = body.each.to_a.join

    expect(status).to eq(200)
    expect(html).to include("Evaluation Memory")
    expect(html).to include("Research Synthesis is getting useful operator feedback.")
  end

  it "uses learned defaults on the assistant page when evaluation memory has a clear winner" do
    result = Companion::Main::Support::AssistantAPI.submit_request(
      requester: "Alex",
      scenario: "research_synthesis",
      request: "Prepare a research synthesis brief"
    )
    request_record = result.fetch(:request)
    Companion::Main::Support::AssistantAPI.approve_request(
      request_id: request_record.fetch(:id),
      briefing: "Operator-approved research synthesis."
    )
    Companion::Main::Support::AssistantAPI.observe_request(
      request_id: request_record.fetch(:id),
      action: :feedback_useful,
      source: :spec,
      metadata: { feedback: "useful" }
    )
    Companion::Main::Support::AssistantAPI.observe_request(
      request_id: request_record.fetch(:id),
      action: :saved_as_note,
      source: :spec,
      metadata: {}
    )

    app = described_class.rack_app

    status, _headers, body = app.call(
      "REQUEST_METHOD" => "GET",
      "PATH_INFO" => "/assistant",
      "rack.input" => StringIO.new
    )

    html = body.each.to_a.join

    expect(status).to eq(200)
    expect(html).to include("Learned Defaults")
    expect(html).to include("Research Synthesis")
    expect(html).to include('value="research_synthesis" selected')
    expect(html).to include(request_record.fetch(:runtime_model))
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
    expect(payload.dig("assistant", "runtime", "credential_policy", "key")).to eq("local_only")
    expect(payload.dig("assistant", "runtime", "recommendation", "title")).to eq("Best Current Lane")
  end

  it "renders a model comparison on the assistant page" do
    expect(Companion::Main::Support::AssistantAPI).to receive(:compare_runtime_outputs).with(
      requester: "Alex",
      request: "Compare rollout briefings",
      models: ["qwen3:latest", "gpt-oss:latest"],
      scenario: "research_synthesis",
      scenario_context: {
        target_environment: "",
        change_scope: "",
        verification_plan: "",
        rollback_plan: "",
        affected_system: "",
        urgency: "",
        symptoms: "",
        sources: "docs/current/agents.md, notes",
        decision_focus: "Which lane to harden next?",
        constraints: "Keep it visible in Companion"
      },
      artifacts: "url: https://example.com/brief\nfile: docs/current/agents.md"
    ).and_return(
      {
        generated_at: "2026-04-21T10:00:00Z",
        scenario_key: :research_synthesis,
        scenario_label: "Research Synthesis",
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
          "scenario" => "research_synthesis",
          "sources" => "docs/current/agents.md, notes",
          "decision_focus" => "Which lane to harden next?",
          "constraints" => "Keep it visible in Companion",
          "artifacts" => "url: https://example.com/brief\nfile: docs/current/agents.md",
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
    expect(html).to include("Research Synthesis")
    expect(html).to include("Artifacts")
    expect(html).to include("What Companion would hand off to the external API lane")
  end
end
