# frozen_string_literal: true

module Companion
  module Main
    module Support
      module AssistantScenarios
        module_function

        DEFAULT_KEY = :general_brief

        SCENARIOS = [
          {
            key: :general_brief,
            label: "General Brief",
            summary: "A concise assistant brief with clear next steps, checks, and operator handoff.",
            prompt_hint: "Use when the task is broad or still forming.",
            operator_handoff: "Leave the operator with one clear next move.",
            output_sections: ["Goal", "Recommended Next Steps", "Checks Or Risks", "Suggested Handoff"],
            match: nil
          },
          {
            key: :technical_rollout,
            label: "Technical Rollout",
            summary: "Plan an implementation or rollout with sequencing, validation, and rollback thinking.",
            prompt_hint: "Good for deploys, migrations, cluster changes, and environment updates.",
            operator_handoff: "End with the next rollout step and the validation checkpoint.",
            output_sections: ["Goal", "Implementation Sequence", "Verification", "Rollback Or Risk", "Suggested Handoff"],
            match: /(rollout|deploy|deployment|release|migration|cluster|replica|bootstrap|cutover|upgrade)/i
          },
          {
            key: :incident_triage,
            label: "Incident Triage",
            summary: "Stabilize an issue quickly with likely causes, immediate checks, and escalation posture.",
            prompt_hint: "Use for failures, outages, alerts, broken flows, and suspicious runtime behavior.",
            operator_handoff: "End with the next diagnostic or containment step.",
            output_sections: ["Situation", "Likely Causes", "Immediate Checks", "Stabilization", "Suggested Handoff"],
            match: /(incident|outage|failure|broken|error|degraded|latency|alert|triage|debug)/i
          },
          {
            key: :research_synthesis,
            label: "Research Synthesis",
            summary: "Condense research, options, or findings into a practical decision-ready brief.",
            prompt_hint: "Use for comparisons, market scans, design choices, or evidence gathering.",
            operator_handoff: "End with the decision to make or the gap to close next.",
            output_sections: ["Question", "Key Findings", "Options", "Recommendation", "Suggested Handoff"],
            match: /(research|compare|comparison|analyze|analysis|synthesis|evaluate|options|tradeoff)/i
          },
          {
            key: :executive_update,
            label: "Executive Update",
            summary: "Prepare a short stakeholder-ready update with status, movement, and key asks.",
            prompt_hint: "Use for status updates, summaries, decisions, and stakeholder communication.",
            operator_handoff: "End with the decision, approval, or follow-up needed.",
            output_sections: ["Status", "What Changed", "Risks Or Open Questions", "Recommendation", "Suggested Handoff"],
            match: /(summary|update|status|stakeholder|executive|briefing|decision|memo)/i
          }
        ].freeze

        def catalog
          SCENARIOS.map { |scenario| serialize(scenario) }
        end

        def resolve(key: nil, request: nil)
          scenario = find_by_key(key) || infer_from_request(request) || find_by_key(DEFAULT_KEY)
          serialize(scenario)
        end

        def find_by_key(key)
          normalized_key = key.to_s.strip
          return nil if normalized_key.empty?

          SCENARIOS.find { |scenario| scenario.fetch(:key).to_s == normalized_key }
        end

        def infer_from_request(request)
          request_text = request.to_s.strip
          return nil if request_text.empty?

          SCENARIOS.find do |scenario|
            matcher = scenario[:match]
            matcher && request_text.match?(matcher)
          end
        end

        def serialize(scenario)
          {
            key: scenario.fetch(:key),
            label: scenario.fetch(:label),
            summary: scenario.fetch(:summary),
            prompt_hint: scenario.fetch(:prompt_hint),
            operator_handoff: scenario.fetch(:operator_handoff),
            output_sections: scenario.fetch(:output_sections)
          }
        end
      end
    end
  end
end
