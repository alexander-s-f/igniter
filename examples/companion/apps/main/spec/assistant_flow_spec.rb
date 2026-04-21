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
    expect(payload.dig("request", "prompt_package", "mode")).to eq("prompt_prep")
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
    expect(refreshed.dig(:prompt_package, :final_briefing)).to include("Cluster rollout brief")
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
      request: "Draft a cluster rollout plan"
    )

    record = result.fetch(:request)

    expect(record.fetch(:status)).to eq(:completed)
    expect(record.fetch(:briefing)).to include("seed node")
    expect(record.fetch(:runtime_mode)).to eq(:ollama)
    expect(record.fetch(:runtime_profile_key)).to eq(:reasoned_ops)
    expect(record.fetch(:runtime_profile_label)).to eq("Reasoned Ops")
    expect(record.dig(:prompt_package, :target)).to eq(:openai_api)
    expect(result.dig(:followup, :summary, :total)).to eq(0)
  end
end
