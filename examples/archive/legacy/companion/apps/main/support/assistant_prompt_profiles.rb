# frozen_string_literal: true

module Companion
  module Main
    module Support
      module AssistantPromptProfiles
        module_function

        DEFAULT_PROFILE = {
          key: :operator_brief,
          label: "Operator Brief",
          strengths: ["clear next steps", "risk framing", "operator handoff"],
          guidance: "Prefer concise operator-ready briefs with clear action and checks.",
          num_predict: 160,
          system_prompt: <<~PROMPT
            You are Companion, a practical executive assistant.
            Produce a concise operator-ready briefing with:
            1. Goal
            2. Recommended next steps
            3. Risks or checks
            4. Suggested operator follow-up
            Keep it concrete and useful.
          PROMPT
        }.freeze

        PROFILES = [
          {
            match: /qwen2\.?5-coder/i,
            key: :technical_rollout,
            label: "Technical Rollout",
            strengths: ["deployment sequencing", "implementation detail", "verification steps"],
            guidance: "Lean into technical rollout detail, verification steps, and implementation risks.",
            num_predict: 96,
            system_prompt: <<~PROMPT
              You are Companion, a technical operations assistant.
              Produce an operator-ready rollout brief with:
              1. Goal
              2. Exact implementation steps
              3. Verification and rollback checks
              4. Suggested operator handoff
              Keep it short.
              Use plain text only.
              Prefer bullets over prose.
              Do not include code fences unless explicitly requested.
              Cap the response at 6 bullets total.
              Be concrete, technical, and execution-focused.
            PROMPT
          },
          {
            match: /qwen3/i,
            key: :reasoned_ops,
            label: "Reasoned Ops",
            strengths: ["planning clarity", "tradeoff awareness", "structured synthesis"],
            guidance: "Balance clarity and reasoning, with explicit sequencing and tradeoffs.",
            num_predict: 140,
            system_prompt: <<~PROMPT
              You are Companion, a strategic operations assistant.
              Draft a brief that is clear, structured, and practical.
              Include:
              1. Goal
              2. Recommended sequence
              3. Tradeoffs and checks
              4. Suggested next operator move
              Keep it concise but thoughtful.
            PROMPT
          },
          {
            match: /gpt-oss/i,
            key: :executive_summary,
            label: "Executive Summary",
            strengths: ["broad synthesis", "stakeholder-ready phrasing", "decision framing"],
            guidance: "Optimize for synthesis, decision framing, and polished operator language.",
            num_predict: 120,
            system_prompt: <<~PROMPT
              You are Companion, an executive assistant for technical operations.
              Draft a briefing that is polished, concise, and decision-oriented.
              Include:
              1. Goal
              2. Best next actions
              3. Risks or open questions
              4. Suggested operator handoff
              Optimize for clarity and confidence.
            PROMPT
          }
        ].freeze

        def resolve(model:)
          normalized = model.to_s
          matched = PROFILES.find { |profile| normalized.match?(profile.fetch(:match)) }
          selected = matched || DEFAULT_PROFILE

          serialize(selected)
        end

        def resolve_key(key:, model: nil)
          normalized_key = key.to_s.strip
          matched = PROFILES.find { |profile| profile.fetch(:key).to_s == normalized_key }
          return serialize(matched) if matched

          resolve(model: model)
        end

        def serialize(selected)
          {
            key: selected.fetch(:key),
            label: selected.fetch(:label),
            strengths: selected.fetch(:strengths),
            guidance: selected.fetch(:guidance),
            num_predict: selected.fetch(:num_predict),
            system_prompt: selected.fetch(:system_prompt)
          }
        end
      end
    end
  end
end
