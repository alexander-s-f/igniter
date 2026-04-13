# frozen_string_literal: true

module Igniter
  module Tools
    class AgentBootstrapTool < Igniter::Tool
      BOOTSTRAP_PROFILES = {
        "esp32_bringup" => {
          label: "ESP32 bring-up",
          goals: %w[esp32 hardware embedded],
          preferred_workflows: %w[platformio_esp32 arduino_esp32 ruby_workspace_dev],
          checklist: [
            "Verify the node can run the recommended firmware workflow.",
            "Confirm the workspace services needed by the device are reachable.",
            "Use serial monitor output to validate request/response flow.",
            "Capture missing utilities or configuration gaps before flashing again."
          ],
          success_criteria: [
            "A firmware toolchain is available.",
            "The target workspace endpoint responds locally.",
            "The device can complete one end-to-end request cycle."
          ]
        },
        "cluster_debug" => {
          label: "Cluster debug",
          goals: %w[cluster debug ruby],
          preferred_workflows: %w[ruby_workspace_dev local_sqlite_ops docker_compose_dev],
          checklist: [
            "Start the workspace in a debuggable local mode.",
            "Inspect cluster ownership, events, and projections.",
            "Check persistence tooling for local-first state.",
            "Capture a minimal repro path before changing cluster logic."
          ],
          success_criteria: [
            "The workspace can be started locally.",
            "Event/projection debug surfaces are reachable.",
            "Local data stores can be inspected."
          ]
        },
        "local_ai_node" => {
          label: "Local AI node",
          goals: %w[ai inference local_llm media],
          preferred_workflows: %w[local_llm_ollama media_pipeline python_sidecar ruby_workspace_dev],
          checklist: [
            "Verify local model or media tooling availability.",
            "Check the node can run the relevant workspace services.",
            "Confirm preprocessing or helper scripts are available.",
            "Choose the smallest viable local inference loop first."
          ],
          success_criteria: [
            "At least one AI or media workflow is available.",
            "The inference-related workspace path can be run locally."
          ]
        },
        "dashboard_dev" => {
          label: "Dashboard development",
          goals: %w[ui frontend ruby debug],
          preferred_workflows: %w[ruby_workspace_dev node_frontend_tooling docker_compose_dev],
          checklist: [
            "Start the workspace app(s) needed by the dashboard.",
            "Check whether node-based tooling is available for UI assets.",
            "Use the local debug surfaces to inspect current state.",
            "Prefer the simplest server-rendered loop before adding more tooling."
          ],
          success_criteria: [
            "The dashboard app can start locally.",
            "A suitable UI/tooling workflow is available."
          ]
        }
      }.freeze

      description "Turn a system snapshot into a concrete bootstrap plan for a named local development goal."

      param :goal, type: :string, required: true,
                   desc: "Bootstrap target such as esp32_bringup, cluster_debug, local_ai_node, or dashboard_dev."
      param :include_discovery, type: :boolean, default: false,
                                desc: "Include the underlying discovery snapshot in the returned plan."
      param :include_unavailable, type: :boolean, default: true,
                                  desc: "Include unavailable workflows and missing utilities in the selector output."

      requires_capability :system_read

      def call(goal:, include_discovery: false, include_unavailable: true)
        profile = BOOTSTRAP_PROFILES.fetch(goal.to_s) do
          raise ArgumentError, "Unknown bootstrap goal #{goal.inspect}. Known goals: #{BOOTSTRAP_PROFILES.keys.sort.join(", ")}"
        end

        selector = Igniter::Tools::LocalWorkflowSelectorTool.new.call(
          goals: profile.fetch(:goals),
          workflow_candidates: profile.fetch(:preferred_workflows),
          include_discovery: include_discovery,
          include_unavailable: include_unavailable
        )

        chosen = Array(selector[:recommended_workflows]).first

        {
          generated_at: Time.now.utc.iso8601,
          goal: goal.to_s,
          label: profile.fetch(:label),
          selected_workflow: chosen,
          recommended_workflows: selector.fetch(:recommended_workflows),
          unavailable_workflows: selector.fetch(:unavailable_workflows, []),
          bootstrap_steps: build_bootstrap_steps(profile, chosen),
          checklist: profile.fetch(:checklist),
          success_criteria: profile.fetch(:success_criteria),
          suggested_commands: chosen ? Array(chosen[:recommended_commands]).first(3) : [],
          notes: build_notes(profile, chosen, selector),
          discovery: selector[:discovery]
        }.compact
      end

      private

      def build_bootstrap_steps(profile, chosen)
        steps = [
          "Start with the goal profile #{profile.fetch(:label).inspect}."
        ]

        if chosen
          steps << "Use the workflow #{chosen.fetch(:label).inspect} because it is available on this node."
          Array(chosen[:recommended_commands]).first(3).each do |command|
            steps << "Run #{command.inspect}."
          end
        else
          steps << "No preferred workflow is currently available on this node."
          steps << "Inspect missing utilities and either install them or switch to another node."
        end

        steps.concat(profile.fetch(:checklist))
      end

      def build_notes(profile, chosen, selector)
        notes = []

        notes << "Preferred workflows were filtered to: #{profile.fetch(:preferred_workflows).join(", ")}."
        if chosen
          notes << "Selected workflow id: #{chosen.fetch(:id)}."
        else
          missing = Array(selector[:unavailable_workflows]).map do |workflow|
            next if Array(workflow[:missing_utilities]).empty?

            "#{workflow[:id]} missing #{workflow[:missing_utilities].join(", ")}"
          end.compact
          notes << "Unavailable workflow diagnostics: #{missing.join(" | ")}." unless missing.empty?
        end

        notes
      end
    end
  end
end
