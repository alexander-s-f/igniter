# frozen_string_literal: true

module Companion
  module Main
    module Support
      module AssistantScenarioContext
        module_function

        INCIDENT_URGENCY = %w[critical high medium low].freeze

        def normalize(scenario:, context: {})
          scenario_key = scenario_key_for(scenario)
          normalized = symbolize_keys(context)

          case scenario_key
          when :technical_rollout
            target_environment = normalized.fetch(:target_environment, "").to_s.strip
            change_scope = normalized.fetch(:change_scope, "").to_s.strip
            verification_plan = normalized.fetch(:verification_plan, "").to_s.strip
            rollback_plan = normalized.fetch(:rollback_plan, "").to_s.strip

            {
              target_environment: target_environment.empty? ? nil : target_environment,
              change_scope: change_scope.empty? ? nil : change_scope,
              verification_plan: verification_plan.empty? ? nil : verification_plan,
              rollback_plan: rollback_plan.empty? ? nil : rollback_plan
            }.compact
          when :incident_triage
            urgency = normalized.fetch(:urgency, "medium").to_s.strip.downcase
            urgency = "medium" unless INCIDENT_URGENCY.include?(urgency)

            affected_system = normalized.fetch(:affected_system, "").to_s.strip
            symptoms = normalized.fetch(:symptoms, "").to_s.strip

            {
              affected_system: affected_system.empty? ? nil : affected_system,
              urgency: urgency,
              symptoms: symptoms.empty? ? nil : symptoms
            }.compact
          when :research_synthesis
            sources = normalized.fetch(:sources, "").to_s.strip
            decision_focus = normalized.fetch(:decision_focus, "").to_s.strip
            constraints = normalized.fetch(:constraints, "").to_s.strip

            {
              sources: sources.empty? ? nil : sources,
              decision_focus: decision_focus.empty? ? nil : decision_focus,
              constraints: constraints.empty? ? nil : constraints
            }.compact
          else
            {}
          end
        end

        def summary(scenario:, context:)
          normalized = normalize(scenario: scenario, context: context)
          return nil if normalized.empty?

          case scenario_key_for(scenario)
          when :technical_rollout
            [
              ("env=#{normalized[:target_environment]}" if normalized[:target_environment]),
              ("scope=#{truncate_summary(normalized[:change_scope])}" if normalized[:change_scope]),
              ("verify=#{truncate_summary(normalized[:verification_plan])}" if normalized[:verification_plan])
            ].compact.join(" · ")
          when :incident_triage
            [
              ("system=#{normalized[:affected_system]}" if normalized[:affected_system]),
              "urgency=#{normalized[:urgency]}",
              ("symptoms=#{normalized[:symptoms]}" if normalized[:symptoms])
            ].compact.join(" · ")
          when :research_synthesis
            [
              ("decision=#{normalized[:decision_focus]}" if normalized[:decision_focus]),
              ("sources=#{truncate_summary(normalized[:sources])}" if normalized[:sources]),
              ("constraints=#{truncate_summary(normalized[:constraints])}" if normalized[:constraints])
            ].compact.join(" · ")
          end
        end

        def prompt_lines(scenario:, context:)
          normalized = normalize(scenario: scenario, context: context)
          return [] if normalized.empty?

          case scenario_key_for(scenario)
          when :technical_rollout
            [
              ("Target environment: #{normalized[:target_environment]}" if normalized[:target_environment]),
              ("Change scope: #{normalized[:change_scope]}" if normalized[:change_scope]),
              ("Verification plan: #{normalized[:verification_plan]}" if normalized[:verification_plan]),
              ("Rollback plan: #{normalized[:rollback_plan]}" if normalized[:rollback_plan])
            ].compact
          when :incident_triage
            [
              ("Affected system: #{normalized[:affected_system]}" if normalized[:affected_system]),
              "Urgency: #{normalized[:urgency]}",
              ("Observed symptoms: #{normalized[:symptoms]}" if normalized[:symptoms])
            ].compact
          when :research_synthesis
            [
              ("Decision focus: #{normalized[:decision_focus]}" if normalized[:decision_focus]),
              ("Available sources: #{normalized[:sources]}" if normalized[:sources]),
              ("Constraints: #{normalized[:constraints]}" if normalized[:constraints])
            ].compact
          else
            []
          end
        end

        def operator_checklist(scenario:, context:)
          normalized = normalize(scenario: scenario, context: context)

          case scenario_key_for(scenario)
          when :technical_rollout
            checklist = []
            checklist << "Confirm the exact rollout scope before touching the target environment." if normalized[:change_scope]
            checklist << "Validate readiness of #{normalized[:target_environment]} before starting." if normalized[:target_environment]
            checklist << "Follow the stated verification plan after each rollout step." if normalized[:verification_plan]
            checklist << "Keep rollback criteria explicit before the first change." if normalized[:rollback_plan]
            checklist << "Leave the operator with the next rollout gate and its pass condition."
            checklist.uniq
          when :incident_triage
            checklist = []
            checklist << "Confirm current impact and whether user-visible degradation is still active."
            checklist << "Check recent deploys, config changes, and infra events affecting #{normalized[:affected_system]}." if normalized[:affected_system]
            checklist << "Capture concrete symptoms and timestamps before making changes." if normalized[:symptoms]
            checklist << "Choose the next containment step before deeper diagnosis." if %w[critical high].include?(normalized[:urgency])
            checklist << "Prepare an escalation update if the issue is not quickly reversible." if normalized[:urgency] == "critical"
            checklist << "Record the next diagnostic checkpoint for the operator."
            checklist.uniq
          when :research_synthesis
            checklist = []
            checklist << "Clarify the decision that this research should support." if normalized[:decision_focus]
            checklist << "Review the listed sources before drafting the synthesis." if normalized[:sources]
            checklist << "Separate findings from recommendations so the operator can challenge assumptions."
            checklist << "Call out the highest-value next question if the evidence is still weak."
            checklist << "Leave the operator with a concrete decision or evidence gap to close next."
            checklist.uniq
          else
            []
          end
        end

        def incident_triage?(scenario)
          scenario_key_for(scenario) == :incident_triage
        end

        def technical_rollout?(scenario)
          scenario_key_for(scenario) == :technical_rollout
        end

        def research_synthesis?(scenario)
          scenario_key_for(scenario) == :research_synthesis
        end

        def scenario_key_for(scenario)
          case scenario
          when Hash
            scenario[:key]&.to_sym
          else
            scenario.to_sym
          end
        end

        def symbolize_keys(value)
          return {} unless value.is_a?(Hash)

          value.each_with_object({}) do |(key, entry), normalized|
            normalized[key.to_sym] = entry
          end
        end

        def truncate_summary(value, limit: 36)
          text = value.to_s.strip
          return text if text.length <= limit

          "#{text[0, limit]}..."
        end
      end
    end
  end
end
