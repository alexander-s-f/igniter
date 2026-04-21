# frozen_string_literal: true

require "time"
require_relative "assistant_prompt_profiles"

module Companion
  module Main
    module Support
      module AssistantPromptPackage
        module_function

        def build(requester:, request:, runtime_config:, profile: nil, delivery_target: nil,
                  local_draft: nil, final_briefing: nil)
          resolved_profile = profile || resolve_profile(runtime_config)
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
            strategy: resolved_profile.fetch(:guidance),
            prefix_warmup: build_prefix_warmup(resolved_profile, requester_text, request_text),
            system_prompt: resolved_profile.fetch(:system_prompt),
            user_prompt: build_user_prompt(resolved_profile, requester_text, request_text, draft_text, final_text),
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

        def build_prefix_warmup(profile, requester, request)
          [
            "Act as Companion in #{profile.fetch(:label)} mode.",
            "Keep the external model aligned to #{profile.fetch(:guidance).downcase}",
            "Requester: #{requester}.",
            "Primary task: #{request}"
          ].join(" ")
        end

        def build_user_prompt(profile, requester, request, local_draft, final_briefing)
          lines = []
          lines << "Prepare the best possible response for #{requester}."
          lines << "Task:"
          lines << request
          lines << ""
          lines << "Operating guidance:"
          lines << "- #{profile.fetch(:guidance)}"
          Array(profile[:strengths]).each do |strength|
            lines << "- Lean into #{strength}"
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
