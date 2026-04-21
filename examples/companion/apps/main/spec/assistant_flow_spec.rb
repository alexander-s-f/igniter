# frozen_string_literal: true

require_relative "spec_helper"
require "json"
require "stringio"

RSpec.describe "Companion assistant flow" do
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

  it "opens an incident-triage request with structured context and a manual follow-up" do
    app = Companion::MainApp.rack_app

    status, headers, body = app.call(
      "REQUEST_METHOD" => "POST",
      "PATH_INFO" => "/v1/assistant/requests",
      "CONTENT_TYPE" => "application/json",
      "rack.input" => StringIO.new(
        JSON.generate(
          requester: "Alex",
          scenario: "incident_triage",
          artifacts: "url: https://status.example.com/incidents/42\nfile: logs/dashboard-api.log",
          affected_system: "dashboard-api",
          urgency: "high",
          symptoms: "5xx spikes after deploy",
          request: "Stabilize the dashboard incident and propose the next operator move"
        )
      )
    )

    payload = JSON.parse(body.each.to_a.join)

    expect(status).to eq(201)
    expect(headers["Content-Type"]).to include("application/json")
    expect(payload.dig("request", "requester")).to eq("Alex")
    expect(payload.dig("request", "status")).to eq("open")
    expect(payload.dig("request", "scenario_key")).to eq("incident_triage")
    expect(payload.dig("request", "scenario", "label")).to eq("Incident Triage")
    expect(payload.dig("request", "scenario_context", "affected_system")).to eq("dashboard-api")
    expect(payload.dig("request", "scenario_context", "urgency")).to eq("high")
    expect(payload.dig("request", "scenario_summary")).to include("system=dashboard-api")
    expect(payload.dig("request", "artifact_summary", "total")).to eq(2)
    expect(payload.dig("request", "artifacts", 0, "kind")).to eq("url")
    expect(payload.dig("request", "prompt_package", "mode")).to eq("prompt_prep")
    expect(payload.dig("request", "prompt_package", "artifact_summary", "total")).to eq(2)
    expect(payload.dig("request", "prompt_package", "scenario_label")).to eq("Incident Triage")
    expect(payload.dig("request", "prompt_package", "scenario_context", "symptoms")).to eq("5xx spikes after deploy")
    expect(payload.dig("request", "operator_checklist")).not_to be_empty
    expect(payload.dig("followup", "summary", "total")).to eq(1)
    expect(payload.dig("followup", "summary", "manual_completion")).to eq(1)
  end

  it "approves a manual assistant follow-up and exposes the completed briefing" do
    result = Companion::Main::Support::AssistantAPI.submit_request(
      requester: "Alex",
      scenario: "incident_triage",
      request: "Prepare a concise cluster rollout brief"
    )

    record = result.fetch(:request)

    Companion::Main::Support::AssistantAPI.approve_request(
      request_id: record.fetch(:id),
      briefing: "Cluster rollout brief: start with one seed node, validate joins, then add two replicas."
    )

    refreshed = Companion::Main::Support::AssistantAPI.all.first

    expect(refreshed.fetch(:status)).to eq(:completed)
    expect(refreshed.dig(:scenario, :key)).to eq(:incident_triage)
    expect(refreshed.dig(:prompt_package, :scenario_label)).to eq("Incident Triage")
    expect(refreshed.fetch(:briefing)).to include("Cluster rollout brief")
    expect(refreshed.dig(:prompt_package, :final_briefing)).to include("Cluster rollout brief")
  end

  it "opens a research-synthesis request with structured evidence context" do
    result = Companion::Main::Support::AssistantAPI.submit_request(
      requester: "Alex",
      scenario: "research_synthesis",
      scenario_context: {
        sources: "docs/current/agents.md, operator notes, model lab output",
        decision_focus: "Which assistant lane should we harden next?",
        constraints: "Prefer something visible in Companion within one slice"
      },
      request: "Synthesize the current evidence and recommend the next assistant product lane"
    )

    record = result.fetch(:request)

    expect(record.fetch(:status)).to eq(:open)
    expect(record.dig(:scenario, :key)).to eq(:research_synthesis)
    expect(record.dig(:scenario_context, :sources)).to include("docs/current/agents.md")
    expect(record.fetch(:scenario_summary)).to include("decision=Which assistant lane should we harden next?")
    expect(record.dig(:prompt_package, :scenario_context, :constraints)).to include("visible in Companion")
    expect(record.fetch(:operator_checklist)).not_to be_empty
  end

  it "opens a technical-rollout request with rollout context and checklist" do
    result = Companion::Main::Support::AssistantAPI.submit_request(
      requester: "Alex",
      scenario: "technical_rollout",
      scenario_context: {
        target_environment: "production-eu",
        change_scope: "roll out the new operator dashboard to two replicas",
        verification_plan: "check health endpoint, smoke the assistant page, confirm follow-up creation",
        rollback_plan: "revert the release and pin traffic to the seed node"
      },
      request: "Prepare the next rollout plan for the dashboard release"
    )

    record = result.fetch(:request)

    expect(record.fetch(:status)).to eq(:open)
    expect(record.dig(:scenario, :key)).to eq(:technical_rollout)
    expect(record.dig(:scenario_context, :target_environment)).to eq("production-eu")
    expect(record.fetch(:scenario_summary)).to include("env=production-eu")
    expect(record.dig(:prompt_package, :scenario_context, :rollback_plan)).to include("seed node")
    expect(record.fetch(:operator_checklist)).not_to be_empty
  end

  it "passes rollout context into model comparison when requested" do
    expect(Companion::Main::Support::AssistantRuntime).to receive(:compare_drafts).with(
      requester: "Alex",
      request: "Compare two rollout drafts",
      models: ["qwen3:latest", "qwen2.5-coder:latest"],
      scenario: "technical_rollout",
      scenario_context: {
        target_environment: "staging",
        change_scope: "roll out dashboard v2",
        verification_plan: "health + smoke",
        rollback_plan: "revert to v1"
      },
      artifacts: "url: https://example.com/runbook\nfile: logs/deploy.log"
    ).and_return(
      generated_at: "2026-04-21T10:00:00Z",
      scenario_key: :technical_rollout,
      scenario_label: "Technical Rollout",
      summary: { requested_models: 2, completed: 0, unavailable: 0 },
      results: []
    )

    result = Companion::Main::Support::AssistantAPI.compare_runtime_outputs(
      requester: "Alex",
      request: "Compare two rollout drafts",
      models: ["qwen3:latest", "qwen2.5-coder:latest"],
      scenario: "technical_rollout",
      scenario_context: {
        target_environment: "staging",
        change_scope: "roll out dashboard v2",
        verification_plan: "health + smoke",
        rollback_plan: "revert to v1"
      },
      artifacts: "url: https://example.com/runbook\nfile: logs/deploy.log"
    )

    expect(result[:scenario_label]).to eq("Technical Rollout")
  end

  it "auto-completes a request when the assistant runtime can draft locally" do
    allow(Companion::Main::Support::AssistantRuntime).to receive(:overview).and_return(
      {
        config: {
          mode: :ollama,
          provider: :ollama,
          model: "qwen3:latest",
          base_url: "http://127.0.0.1:11434"
        },
        status: {
          state: :ready,
          reason: :ready,
          auto_draft_ready: true,
          checked_at: Time.now.utc.iso8601,
          available_models: ["qwen3:latest"],
          available_model_count: 1,
          selected_model_available: true
        }
      }
    )

    allow(Companion::Main::Support::AssistantRuntime).to receive(:auto_draft).and_return(
      {
        status: :succeeded,
        briefing: "Auto draft: start with the seed node, validate health, then add replicas.",
        prompt_package: {
          target: :openai_api,
          target_label: "OpenAI API",
          target_model: "gpt-4o",
          mode: :prompt_prep,
          scenario_key: :technical_rollout,
          scenario_label: "Technical Rollout",
          profile_key: :reasoned_ops,
          profile_label: "Reasoned Ops",
          prefix_warmup: "Act as Companion in Reasoned Ops mode.",
          system_prompt: "System prompt",
          user_prompt: "User prompt"
        },
        config: {
          mode: :ollama,
          provider: :ollama,
          model: "qwen3:latest",
          base_url: "http://127.0.0.1:11434",
          profile: {
            key: :reasoned_ops,
            label: "Reasoned Ops"
          }
        },
        runtime: {
          state: :ready,
          reason: :ready,
          auto_draft_ready: true,
          checked_at: Time.now.utc.iso8601,
          outcome: :auto_drafted
        }
      }
    )

    result = Companion::Main::Support::AssistantAPI.submit_request(
      requester: "Alex",
      scenario: "technical_rollout",
      request: "Draft a cluster rollout plan"
    )

    record = result.fetch(:request)

    expect(record.fetch(:status)).to eq(:completed)
    expect(record.dig(:scenario, :key)).to eq(:technical_rollout)
    expect(record.dig(:prompt_package, :scenario_label)).to eq("Technical Rollout")
    expect(record.fetch(:briefing)).to include("seed node")
    expect(record.fetch(:runtime_mode)).to eq(:ollama)
    expect(record.fetch(:runtime_profile_key)).to eq(:reasoned_ops)
    expect(record.fetch(:runtime_profile_label)).to eq("Reasoned Ops")
    expect(record.dig(:prompt_package, :target)).to eq(:openai_api)
    expect(result.dig(:followup, :summary, :total)).to eq(0)
  end

  it "completes through a simulated external delivery when a delivery channel is selected" do
    allow(Companion::Main::Support::AssistantRuntime).to receive(:overview).and_return(
      {
        config: {
          mode: :ollama,
          provider: :ollama,
          model: "qwen2.5-coder:latest",
          base_url: "http://127.0.0.1:11434",
          timeout_seconds: 20,
          delivery_mode: :simulate,
          delivery_strategy: :prefer_openai,
          openai_model: "gpt-4o",
          anthropic_model: "claude-sonnet-4-6",
          profile: {
            key: :technical_rollout,
            label: "Technical Rollout",
            guidance: "Lean into technical rollout detail.",
            strengths: ["deployment sequencing"],
            system_prompt: "System prompt"
          }
        },
        status: {
          state: :ready,
          reason: :ready,
          auto_draft_ready: true,
          checked_at: Time.now.utc.iso8601,
          available_models: ["qwen2.5-coder:latest"],
          available_model_count: 1,
          selected_model_available: true
        },
        routing: {
          delivery_channel: {
            key: :openai_api,
            label: "OpenAI API",
            provider: :openai,
            model: "gpt-4o",
            available: true
          }
        }
      }
    )
    allow(Companion::Main::Support::AssistantRuntime).to receive(:configuration).and_return(
      Companion::Main::Support::AssistantRuntime.overview.fetch(:config)
    )
    allow(Companion::Main::Support::AssistantRuntime).to receive(:auto_draft).and_return(
      {
        status: :succeeded,
        briefing: "Local prep draft for external delivery.",
        prompt_package: {
          target: :openai_api,
          target_label: "OpenAI API",
          target_model: "gpt-4o",
          mode: :prompt_prep,
          profile_key: :technical_rollout,
          profile_label: "Technical Rollout",
          prefix_warmup: "Warmup",
          system_prompt: "System prompt",
          user_prompt: "User prompt",
          local_draft: "Local prep draft for external delivery."
        },
        config: {
          mode: :ollama,
          provider: :ollama,
          model: "qwen2.5-coder:latest",
          base_url: "http://127.0.0.1:11434",
          profile: {
            key: :technical_rollout,
            label: "Technical Rollout"
          }
        },
        runtime: {
          state: :ready,
          reason: :ready,
          auto_draft_ready: true,
          checked_at: Time.now.utc.iso8601,
          outcome: :auto_drafted
        }
      }
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

    result = Companion::Main::Support::AssistantAPI.submit_request(
      requester: "Alex",
      scenario: "executive_update",
      request: "Draft the final response through OpenAI"
    )

    record = result.fetch(:request)

    expect(record.fetch(:status)).to eq(:completed)
    expect(record.dig(:scenario, :key)).to eq(:executive_update)
    expect(record.fetch(:briefing)).to eq("Simulated external delivery result.")
    expect(record.dig(:delivery, :status)).to eq(:simulated)
    expect(record.dig(:delivery, :channel)).to eq(:openai_api)
  end

  it "re-delivers a completed request and preserves the original briefing" do
    result = Companion::Main::Support::AssistantAPI.submit_request(
      requester: "Alex",
      request: "Prepare a concise cluster rollout brief"
    )

    record = result.fetch(:request)

    Companion::Main::Support::AssistantAPI.approve_request(
      request_id: record.fetch(:id),
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

    refreshed = Companion::Main::Support::AssistantAPI.redeliver_request(request_id: record.fetch(:id))

    expect(refreshed.fetch(:briefing)).to eq("Operator-approved rollout brief.")
    expect(refreshed.dig(:delivery, :status)).to eq(:simulated)
    expect(refreshed.dig(:delivery, :output)).to eq("Simulated external delivery result.")
  end

  it "reopens a completed briefing as a manual follow-up regardless of runtime mode" do
    result = Companion::Main::Support::AssistantAPI.submit_request(
      requester: "Alex",
      scenario: "technical_rollout",
      scenario_context: {
        target_environment: "staging",
        verification_plan: "health + smoke",
        rollback_plan: "revert to v1"
      },
      request: "Prepare a concise cluster rollout brief"
    )

    record = result.fetch(:request)

    Companion::Main::Support::AssistantAPI.approve_request(
      request_id: record.fetch(:id),
      briefing: "Operator-approved rollout brief."
    )

    Companion::Main::Support::AssistantAPI.configure_runtime(
      mode: "ollama",
      provider: "ollama",
      model: "qwen3:latest",
      base_url: "http://127.0.0.1:11434",
      timeout_seconds: 20,
      delivery_mode: "simulate",
      delivery_strategy: "manual_only",
      openai_model: "gpt-4o",
      anthropic_model: "claude-sonnet-4-6"
    )

    reopened = Companion::Main::Support::AssistantAPI.reopen_request_as_followup(
      request_id: record.fetch(:id)
    )

    reopened_request = reopened.fetch(:request)

    expect(reopened_request.fetch(:status)).to eq(:open)
    expect(reopened_request.fetch(:request)).to eq("Use the attached completed briefing as evidence and propose the next concrete operator follow-up.")
    expect(reopened_request.dig(:delivery, :reason)).to eq(:reopened_manual_followup)
    expect(reopened_request.dig(:prompt_package, :target)).to eq(:manual_completion)
    expect(reopened_request.dig(:artifact_summary, :total)).to be >= 2
    expect(reopened.fetch(:followup).dig(:summary, :manual_completion)).to eq(1)
  end

  it "includes evaluation memory in assistant overview" do
    result = Companion::Main::Support::AssistantAPI.submit_request(
      requester: "Alex",
      scenario: "technical_rollout",
      request: "Prepare a concise cluster rollout brief"
    )

    record = result.fetch(:request)
    Companion::Main::Support::AssistantAPI.approve_request(
      request_id: record.fetch(:id),
      briefing: "Operator-approved rollout brief."
    )
    Companion::Main::Support::AssistantAPI.redeliver_request(request_id: record.fetch(:id))
    Companion::Main::Support::AssistantAPI.reopen_request_as_followup(request_id: record.fetch(:id))

    overview = Companion::Main::Support::AssistantAPI.overview

    expect(overview.dig(:evaluation, :summary, :total)).to be >= 4
    expect(overview.dig(:evaluation, :summary, :by_action, :completed_manual_followup)).to eq(1)
    expect(overview.dig(:evaluation, :summary, :by_action, :redelivered)).to eq(1)
    expect(overview.dig(:evaluation, :summary, :by_action, :reopened_manual_action)).to eq(1)
    expect(overview.dig(:evaluation, :recent)).not_to be_empty
  end
end
