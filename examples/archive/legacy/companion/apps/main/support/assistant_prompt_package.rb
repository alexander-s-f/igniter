# frozen_string_literal: true

require "time"
require_relative "assistant_artifacts"
require_relative "assistant_prompt_profiles"
require_relative "assistant_scenarios"
require_relative "assistant_scenario_context"

module Companion
  module Main
    module Support
      module AssistantPromptPackage
        module_function

        def build(requester:, request:, runtime_config:, profile: nil, delivery_target: nil,
                  scenario: nil, scenario_context: nil,
                  artifacts: nil,
                  local_draft: nil, final_briefing: nil)
          resolved_profile = profile || resolve_profile(runtime_config)
          resolved_scenario = scenario || Companion::Main::Support::AssistantScenarios.resolve(request: request)
          resolved_context = Companion::Main::Support::AssistantScenarioContext.normalize(
            scenario: resolved_scenario,
            context: scenario_context || {}
          )
          resolved_artifacts = Companion::Main::Support::AssistantArtifacts.normalize(raw: artifacts)
          request_text = request.to_s.strip
          requester_text = requester.to_s.strip
          draft_text = local_draft.to_s.strip
          final_text = final_briefing.to_s.strip
          resolved_target = delivery_target || {}

          {
            target: resolved_target.fetch(:key, :chatgpt_api),
            target_label: resolved_target.fetch(:label, "ChatGPT API"),
            target_model: resolved_target[:model],
            mode: :prompt_prep,
            profile_key: resolved_profile.fetch(:key),
            profile_label: resolved_profile.fetch(:label),
            scenario_key: resolved_scenario.fetch(:key),
            scenario_label: resolved_scenario.fetch(:label),
            scenario_context: resolved_context,
            artifacts: resolved_artifacts,
            artifact_summary: Companion::Main::Support::AssistantArtifacts.summary(resolved_artifacts),
            strategy: resolved_profile.fetch(:guidance),
            prefix_warmup: build_prefix_warmup(resolved_profile, resolved_scenario, resolved_context, requester_text, request_text),
            system_prompt: resolved_profile.fetch(:system_prompt),
            user_prompt: build_user_prompt(
              resolved_profile,
              resolved_scenario,
              resolved_context,
              resolved_artifacts,
              requester_text,
              request_text,
              draft_text,
              final_text
            ),
            local_draft: draft_text.empty? ? nil : draft_text,
            final_briefing: final_text.empty? ? nil : final_text,
            generated_at: Time.now.utc.iso8601
          }.compact
        end

        def resolve_profile(runtime_config)
          if runtime_config[:profile].is_a?(Hash) && runtime_config[:profile][:key]
            Companion::Main::Support::AssistantPromptProfiles.resolve_key(
              key: runtime_config[:profile][:key],
              model: runtime_config[:model]
            )
          else
            Companion::Main::Support::AssistantPromptProfiles.resolve(model: runtime_config[:model])
          end
        end

        def build_prefix_warmup(profile, scenario, scenario_context, requester, request)
          lines = [
            "Act as Companion in #{profile.fetch(:label)} mode.",
            "Scenario: #{scenario.fetch(:label)}.",
            "Scenario focus: #{scenario.fetch(:summary)}",
            "Keep the external model aligned to #{profile.fetch(:guidance).downcase}",
            "Requester: #{requester}.",
            "Primary task: #{request}"
          ]
          lines.concat(Companion::Main::Support::AssistantScenarioContext.prompt_lines(
            scenario: scenario,
            context: scenario_context
          ))
          lines.join(" ")
        end

        def build_user_prompt(profile, scenario, scenario_context, artifacts, requester, request, local_draft, final_briefing)
          lines = []
          lines << "Prepare the best possible response for #{requester}."
          lines << "Scenario:"
          lines << "#{scenario.fetch(:label)} — #{scenario.fetch(:summary)}"
          context_lines = Companion::Main::Support::AssistantScenarioContext.prompt_lines(
            scenario: scenario,
            context: scenario_context
          )
          unless context_lines.empty?
            lines << ""
            lines << "Scenario context:"
            lines.concat(context_lines)
          end
          artifact_lines = Companion::Main::Support::AssistantArtifacts.prompt_lines(artifacts)
          lines << "Task:"
          lines << request
          lines << ""
          lines << "Operating guidance:"
          lines << "- #{profile.fetch(:guidance)}"
          lines << "- #{scenario.fetch(:prompt_hint)}"
          lines << "- End with: #{scenario.fetch(:operator_handoff)}"
          Array(profile[:strengths]).each do |strength|
            lines << "- Lean into #{strength}"
          end
          lines << ""
          lines << "Expected sections:"
          Array(scenario[:output_sections]).each do |section|
            lines << "- #{section}"
          end
          unless artifact_lines.empty?
            lines << ""
            lines << "Attached artifacts:"
            lines.concat(artifact_lines)
          end

          unless local_draft.empty?
            lines << ""
            lines << "Local prompt-prep draft:"
            lines << local_draft
          end

          unless final_briefing.empty?
            lines << ""
            lines << "Operator-approved briefing to preserve:"
            lines << final_briefing
          end

          lines << ""
          lines << "Return a concise, high-quality final answer suitable for the external ChatGPT API lane."
          lines.join("\n")
        end
      end
    end
  end
end
