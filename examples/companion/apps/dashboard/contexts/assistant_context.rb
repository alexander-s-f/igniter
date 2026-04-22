# frozen_string_literal: true

require_relative "home_context"
require_relative "../../main/support/assistant_artifacts"
require_relative "../../main/support/assistant_scenarios"

module Companion
  module Dashboard
    module Contexts
      class AssistantContext < HomeContext
        def title
          "Companion Assistant"
        end

        def description
          "Dedicated intake and follow-up lane for assistant workflows."
        end

        def shell_subtitle
          "Assistant intake and follow-up lane"
        end

        def current_nav_key
          :assistant
        end

        def summary_metrics
          [
            {
              label: "Requests",
              value: assistant_summary.fetch(:total_requests, 0),
              hint: "assistant workflows captured by the desk"
            },
            {
              label: "Open",
              value: assistant_summary.fetch(:pending_requests, 0),
              hint: "requests waiting for operator follow-up"
            },
            {
              label: "Completed",
              value: assistant_summary.fetch(:completed_requests, 0),
              hint: "requests resolved into a stored briefing"
            }
          ]
        end

        def breadcrumbs
          [
            { label: "Companion", href: operator_desk_href },
            { label: "Dashboard", href: operator_desk_href },
            { label: "Assistant", current: true }
          ]
        end

        def operator_links
          [
            { label: "Operator Desk", href: operator_desk_href },
            { label: "Cluster View", href: cluster_href },
            { label: "Assistant API", href: "/v1/assistant/requests" },
            { label: "Operator Console", href: route("/operator") },
            { label: "Overview API", href: route("/api/overview") }
          ]
        end

        def assistant_scenarios
          Companion::Main::Support::AssistantScenarios.catalog
        end

        def assistant_form_defaults
          {
            "requester" => assistant_form_values.fetch("requester", ""),
            "scenario" => assistant_form_values.fetch("scenario", learned_default_scenario_key),
            "target_environment" => assistant_form_values.fetch("target_environment", ""),
            "change_scope" => assistant_form_values.fetch("change_scope", ""),
            "verification_plan" => assistant_form_values.fetch("verification_plan", ""),
            "rollback_plan" => assistant_form_values.fetch("rollback_plan", ""),
            "affected_system" => assistant_form_values.fetch("affected_system", ""),
            "urgency" => assistant_form_values.fetch("urgency", "medium"),
            "symptoms" => assistant_form_values.fetch("symptoms", ""),
            "sources" => assistant_form_values.fetch("sources", ""),
            "decision_focus" => assistant_form_values.fetch("decision_focus", ""),
            "constraints" => assistant_form_values.fetch("constraints", ""),
            "artifacts" => assistant_form_values.fetch("artifacts", ""),
            "request" => assistant_form_values.fetch("request", "")
          }
        end

        def assistant_selected_scenario
          Companion::Main::Support::AssistantScenarios.resolve(
            key: assistant_form_defaults.fetch("scenario"),
            request: assistant_form_defaults.fetch("request")
          )
        end

        def assistant_scenario_cards
          assistant_scenarios
        end

        def incident_triage_selected?
          assistant_selected_scenario.fetch(:key) == :incident_triage
        end

        def technical_rollout_selected?
          assistant_selected_scenario.fetch(:key) == :technical_rollout
        end

        def technical_rollout_form_rows
          [
            { label: :target_environment, value: assistant_form_defaults.fetch("target_environment"), as: :code },
            { label: :change_scope, value: assistant_form_defaults.fetch("change_scope"), as: :code },
            { label: :verification_plan, value: assistant_form_defaults.fetch("verification_plan"), as: :code },
            { label: :rollback_plan, value: assistant_form_defaults.fetch("rollback_plan"), as: :code }
          ]
        end

        def incident_triage_form_rows
          [
            { label: :affected_system, value: assistant_form_defaults.fetch("affected_system"), as: :code },
            { label: :urgency, value: assistant_form_defaults.fetch("urgency"), as: :badge },
            { label: :symptoms, value: assistant_form_defaults.fetch("symptoms"), as: :code }
          ]
        end

        def research_synthesis_selected?
          assistant_selected_scenario.fetch(:key) == :research_synthesis
        end

        def research_synthesis_form_rows
          [
            { label: :sources, value: assistant_form_defaults.fetch("sources"), as: :code },
            { label: :decision_focus, value: assistant_form_defaults.fetch("decision_focus"), as: :code },
            { label: :constraints, value: assistant_form_defaults.fetch("constraints"), as: :code }
          ]
        end

        def assistant_signal_rows
          [
            {
              label: :runtime_state,
              value: assistant_runtime_status.fetch(:state, :manual),
              as: :indicator
            },
            { label: :pending_requests, value: assistant_summary.fetch(:pending_requests, 0), as: :number },
            { label: :completed_requests, value: assistant_summary.fetch(:completed_requests, 0), as: :number },
            { label: :actionable_followups, value: assistant_summary.fetch(:actionable_followups, 0), as: :number },
            { label: :generated_at, value: generated_at, as: :datetime }
          ]
        end

        def assistant_runtime_rows
          [
            { label: :mode, value: assistant_runtime_config.fetch(:mode, :manual), as: :badge },
            { label: :provider, value: assistant_runtime_config.fetch(:provider, :ollama), as: :badge },
            { label: :model, value: assistant_runtime_config.fetch(:model, "qwen2.5-coder:latest"), as: :code },
            { label: :base_url, value: assistant_runtime_config.fetch(:base_url, "http://127.0.0.1:11434"), as: :code },
            { label: :timeout_seconds, value: assistant_runtime_config.fetch(:timeout_seconds, 20), as: :number },
            { label: :delivery_mode, value: assistant_runtime_config.fetch(:delivery_mode, :simulate), as: :badge },
            { label: :delivery_strategy, value: assistant_runtime_config.fetch(:delivery_strategy, :prefer_openai), as: :badge },
            { label: :openai_model, value: assistant_runtime_config.fetch(:openai_model, "gpt-4o"), as: :code },
            { label: :anthropic_model, value: assistant_runtime_config.fetch(:anthropic_model, "claude-sonnet-4-6"), as: :code },
            { label: :ready, value: assistant_runtime_status.fetch(:auto_draft_ready, false), as: :boolean },
            { label: :reason, value: assistant_runtime_status.fetch(:reason, :unknown), as: :badge },
            { label: :available_models, value: assistant_runtime_status.fetch(:available_model_count, 0), as: :number },
            { label: :checked_at, value: assistant_runtime_status.fetch(:checked_at, generated_at), as: :datetime }
          ]
        end

        def assistant_routing_rows
          prep = assistant_runtime_routing.fetch(:prep_channel, {})
          delivery = assistant_runtime_routing.fetch(:delivery_channel, {})

          [
            { label: :strategy, value: assistant_runtime_routing.fetch(:strategy, :prefer_openai), as: :badge },
            { label: :prep_channel, value: prep.fetch(:label, "--"), as: :badge },
            { label: :prep_model, value: prep.fetch(:model, "--"), as: :code },
            { label: :delivery_channel, value: delivery.fetch(:label, "--"), as: :badge },
            { label: :delivery_model, value: delivery.fetch(:model, "--"), as: :code },
            { label: :delivery_mode, value: assistant_runtime_config.fetch(:delivery_mode, :simulate), as: :badge },
            { label: :external_delivery_ready, value: assistant_runtime_routing.fetch(:external_delivery_ready, false), as: :boolean }
          ]
        end

        def assistant_credential_policy_rows
          policy = assistant_credential_policy
          return [] if policy.empty?

          [
            { label: :policy, value: policy.fetch(:label, "--"), as: :badge },
            { label: :secret_class, value: policy.fetch(:secret_class, "--"), as: :badge },
            { label: :propagation, value: policy.fetch(:propagation, "--"), as: :badge },
            { label: :route_over_replicate, value: policy.fetch(:route_over_replicate, false), as: :boolean },
            { label: :weak_trust_behavior, value: policy.fetch(:weak_trust_behavior, "--"), as: :badge },
            { label: :operator_approval_for_replication, value: policy.fetch(:operator_approval_for_replication, false), as: :boolean }
          ]
        end

        def assistant_credential_policy_summary
          assistant_credential_policy.fetch(:summary, "--")
        end

        def assistant_credential_policy_notes
          array_or_empty(assistant_credential_policy.fetch(:notes, []))
        end

        def assistant_credential_status
          hash_or_empty(assistant_runtime.fetch(:credential_status, {}))
        end

        def assistant_credential_status_rows
          status = assistant_credential_status
          return [] if status.empty?

          [
            { label: :default_scope, value: "node-local", as: :badge },
            { label: :default_node, value: "current", as: :badge },
            { label: :local_file_loaded, value: status.fetch(:loaded, false), as: :boolean },
            { label: :override, value: status.fetch(:override, false), as: :boolean },
            { label: :applied_keys, value: status.fetch(:applied_keys, []).size, as: :number },
            { label: :path, value: status.fetch(:path, "--"), as: :code }
          ]
        end

        def assistant_credential_source_summary
          policy = assistant_credential_policy

          if policy.fetch(:propagation, nil) == :disabled || policy.fetch(:secret_class, nil) == :local_only
            "External API credentials are node-local by default. Companion reads them from the current node only and prefers routing work over copying secrets."
          else
            "Credential sourcing is active for this node."
          end
        end

        def assistant_credential_source_notes
          [
            "Place local API keys in the current node app config, not in the repository.",
            "Use routing before considering any future credential propagation."
          ]
        end

        def assistant_credential_provider_rows
          hash_or_empty(assistant_credential_status.fetch(:providers, {})).map do |provider, entry|
            {
              provider: provider,
              env_key: entry.fetch(:env_key),
              configured_in_file: entry.fetch(:configured_in_file, false),
              env_present: entry.fetch(:env_present, false),
              source: entry.fetch(:source, :missing),
              scope: :node_local,
              node: :current
            }
          end
        end

        def assistant_recommendation
          hash_or_empty(assistant_runtime.fetch(:recommendation, {}))
        end

        def assistant_evaluation
          hash_or_empty(assistant.fetch(:evaluation, {}))
        end

        def assistant_evaluation_rows
          summary = assistant_evaluation.fetch(:summary, {})
          return [] if summary.empty?

          [
            { label: :total, value: summary.fetch(:total, 0), as: :number },
            { label: :actions, value: summary.fetch(:by_action, {}).keys, as: :badge },
            { label: :scenarios, value: summary.fetch(:by_scenario, {}).keys, as: :badge },
            { label: :models, value: summary.fetch(:by_model, {}).keys, as: :badge }
          ]
        end

        def assistant_evaluation_recent_rows
          array_or_empty(assistant_evaluation.fetch(:recent, [])).map do |entry|
            {
              created_at: entry.fetch(:created_at, nil),
              action: entry.fetch(:action, nil),
              scenario: entry[:scenario_label] || entry[:scenario_key],
              model: entry.fetch(:runtime_model, nil),
              status: entry.fetch(:status, nil),
              source: entry.fetch(:source, nil)
            }
          end
        end

        def assistant_evaluation_insights
          array_or_empty(assistant_evaluation.fetch(:insights, []))
        end

        def assistant_evaluation_recommendation
          hash_or_empty(assistant_evaluation.fetch(:recommendations, {}))
        end

        def assistant_evaluation_recommendation_rows
          recommendation = assistant_evaluation_recommendation
          return [] if recommendation.empty?

          [
            { label: :scenario, value: recommendation.fetch(:scenario_label, "--"), as: :badge },
            { label: :model, value: recommendation.fetch(:model, "--"), as: :code }
          ]
        end

        def assistant_evaluation_recommendation_summary
          assistant_evaluation_recommendation.fetch(:summary, "--")
        end

        def assistant_evaluation_recommendation_notes
          array_or_empty(assistant_evaluation_recommendation.fetch(:notes, []))
        end

        def assistant_recommendation_rows
          recommendation = assistant_recommendation
          return [] if recommendation.empty?

          rows = [
            { label: :prep, value: recommendation.fetch(:prep, "--"), as: :badge },
            { label: :prep_model, value: recommendation.fetch(:prep_model, "--"), as: :code },
            { label: :delivery, value: recommendation.fetch(:delivery, "--"), as: :badge },
            { label: :delivery_model, value: recommendation.fetch(:delivery_model, "--"), as: :code }
          ]

          if recommendation[:learned_scenario_label]
            rows << { label: :learned_scenario, value: recommendation.fetch(:learned_scenario_label), as: :badge }
          end

          if recommendation[:learned_model]
            rows << { label: :learned_model, value: recommendation.fetch(:learned_model), as: :code }
          end

          rows
        end

        def assistant_recommendation_summary
          assistant_recommendation.fetch(:summary, "--")
        end

        def assistant_recommendation_notes
          array_or_empty(assistant_recommendation.fetch(:notes, []))
        end

        def delivery_rows(record)
          delivery = record.fetch(:delivery, {})
          return [] if delivery.empty?

          [
            { label: :status, value: delivery.fetch(:status, "--"), as: :badge },
            { label: :channel, value: delivery.fetch(:channel_label, delivery.fetch(:channel, "--")), as: :badge },
            { label: :model, value: delivery.fetch(:model, "--"), as: :code },
            { label: :mode, value: delivery.fetch(:mode, "--"), as: :badge },
            { label: :reason, value: delivery.fetch(:reason, "--"), as: :badge }
          ]
        end

        def delivery_preview(record)
          delivery = record.fetch(:delivery, {})
          return {} if delivery.empty?

          {
            output: delivery[:output],
            error: delivery[:error]
          }.compact
        end

        def assistant_channel_rows
          array_or_empty(assistant_runtime_channels).map do |channel|
            {
              label: channel.fetch(:label),
              kind: channel.fetch(:kind),
              provider: channel.fetch(:provider),
              model: channel[:model],
              available: channel.fetch(:available),
              credentials_ready: channel.fetch(:credentials_ready),
              credential_source: channel.fetch(:credential_source, nil),
              credential_scope: channel.fetch(:credential_scope, nil),
              credential_node: channel.fetch(:credential_node, nil),
              credential_policy: channel.fetch(:credential_policy, nil),
              policy_allowed: channel.fetch(:policy_allowed, true),
              reason: channel.fetch(:reason)
            }
          end
        end

        def available_model_badges
          array_or_empty(assistant_runtime_status.fetch(:available_models, []))
        end

        def assistant_profile
          hash_or_empty(assistant_runtime_config.fetch(:profile, {}))
        end

        def assistant_profile_rows
          [
            { label: :profile, value: assistant_profile.fetch(:label, "Operator Brief"), as: :badge },
            { label: :guidance, value: assistant_profile.fetch(:guidance, "--"), as: :code },
            { label: :num_predict, value: assistant_profile.fetch(:num_predict, "--"), as: :number }
          ]
        end

        def assistant_profile_strengths
          array_or_empty(assistant_profile.fetch(:strengths, []))
        end

        def assistant_request_rows
          super.map do |row|
            record = assistant_requests.find { |entry| entry.fetch(:id) == row.fetch(:id) }
            row.merge(
              scenario: record&.dig(:scenario, :label) || record&.fetch(:scenario_label, nil),
              scenario_summary: record&.fetch(:scenario_summary, nil),
              artifacts: record&.dig(:artifact_summary, :total),
              runtime_mode: record&.fetch(:runtime_mode, nil),
              runtime_model: record&.fetch(:runtime_model, nil)
            )
          end
        end

        def completed_assistant_requests
          assistant_requests.select { |record| record.fetch(:status) == :completed }.first(4)
        end

        def completed_briefing_note_text(record)
          scenario = record.dig(:scenario, :label) || record.fetch(:scenario_label, "General Brief")
          requester = record.fetch(:requester, "Operator")
          briefing = record.fetch(:briefing, "").to_s.strip

          "Assistant briefing (#{scenario}) for #{requester}: #{briefing}"
        end

        def feedback_options
          [
            { label: "Useful", value: "useful" },
            { label: "Too Verbose", value: "too_verbose" },
            { label: "Too Slow", value: "too_slow" },
            { label: "Wrong Lane", value: "wrong_lane" }
          ]
        end

        def completed_briefing_rollout_href(record)
          params = URI.encode_www_form(
            "scenario" => "technical_rollout",
            "requester" => record.fetch(:requester, ""),
            "target_environment" => record.dig(:scenario_context, :target_environment).to_s,
            "change_scope" => record.fetch(:request, "").to_s,
            "verification_plan" => record.dig(:scenario_context, :verification_plan).to_s,
            "rollback_plan" => record.dig(:scenario_context, :rollback_plan).to_s,
            "request" => "Turn the attached completed briefing into a rollout-ready plan with verification and rollback gates.",
            "artifacts" => completed_briefing_rollout_artifacts(record)
          )

          "#{route("/assistant")}?#{params}"
        end

        def prompt_package_rows(record)
          package = record.fetch(:prompt_package, {})

          [
            { label: :scenario, value: package.fetch(:scenario_label, "--"), as: :badge },
            { label: :artifacts, value: package.dig(:artifact_summary, :total) || 0, as: :number },
            { label: :target, value: package.fetch(:target, "--"), as: :badge },
            { label: :target_label, value: package.fetch(:target_label, "--"), as: :badge },
            { label: :target_model, value: package.fetch(:target_model, "--"), as: :code },
            { label: :mode, value: package.fetch(:mode, "--"), as: :badge },
            { label: :profile, value: package.fetch(:profile_label, "--"), as: :badge },
            { label: :generated_at, value: package.fetch(:generated_at, nil), as: :datetime }
          ]
        end

        def prompt_package_preview(record)
          package = record.fetch(:prompt_package, {})
          {
            scenario_context: package[:scenario_context],
            artifacts: package[:artifacts],
            prefix_warmup: package[:prefix_warmup],
            system_prompt: package[:system_prompt],
            user_prompt: package[:user_prompt]
          }.compact
        end

        def artifact_rows(record)
          Array(record[:artifacts]).map do |entry|
            {
              kind: entry.fetch(:kind),
              label: entry.fetch(:label),
              value: entry.fetch(:value)
            }
          end
        end

        def scenario_context_rows(record)
          context = record.fetch(:scenario_context, {})
          return [] if context.empty?

          context.map do |key, value|
            { label: key, value: value, as: key.to_sym == :urgency ? :badge : :code }
          end
        end

        def operator_checklist_rows(record)
          Array(record[:operator_checklist]).map do |entry|
            { label: :check, value: entry, as: :code }
          end
        end

        def compare_form_defaults
          {
            "requester" => compare_form_values.fetch("requester", assistant_form_defaults.fetch("requester", "")),
            "scenario" => compare_form_values.fetch("scenario", assistant_form_defaults.fetch("scenario", learned_default_scenario_key)),
            "target_environment" => compare_form_values.fetch("target_environment", assistant_form_defaults.fetch("target_environment", "")),
            "change_scope" => compare_form_values.fetch("change_scope", assistant_form_defaults.fetch("change_scope", "")),
            "verification_plan" => compare_form_values.fetch("verification_plan", assistant_form_defaults.fetch("verification_plan", "")),
            "rollback_plan" => compare_form_values.fetch("rollback_plan", assistant_form_defaults.fetch("rollback_plan", "")),
            "sources" => compare_form_values.fetch("sources", assistant_form_defaults.fetch("sources", "")),
            "decision_focus" => compare_form_values.fetch("decision_focus", assistant_form_defaults.fetch("decision_focus", "")),
            "constraints" => compare_form_values.fetch("constraints", assistant_form_defaults.fetch("constraints", "")),
            "artifacts" => compare_form_values.fetch("artifacts", assistant_form_defaults.fetch("artifacts", "")),
            "request" => compare_form_values.fetch("request", assistant_form_defaults.fetch("request", "")),
            "models_csv" => compare_form_values.fetch("models_csv", default_compare_models.join(", "))
          }
        end

        def compare_results_present?
          compare_results.is_a?(Hash) && compare_results.fetch(:results, []).any?
        end

        def compare_result_rows
          return [] unless compare_results_present?

          compare_results.fetch(:results).map do |entry|
            {
              model: entry.fetch(:model),
              profile: entry.fetch(:profile_label),
              status: entry.fetch(:status),
              reason: entry.fetch(:reason),
              ready: entry.fetch(:ready)
            }
          end
        end

        def compare_result_cards
          return [] unless compare_results_present?

          compare_results.fetch(:results)
        end

        def compare_prompt_package_rows(entry)
          package = entry.fetch(:prompt_package, {})
          [
            { label: :scenario, value: package.fetch(:scenario_label, "--"), as: :badge },
            { label: :target, value: package.fetch(:target, "--"), as: :badge },
            { label: :target_label, value: package.fetch(:target_label, "--"), as: :badge },
            { label: :target_model, value: package.fetch(:target_model, "--"), as: :code },
            { label: :mode, value: package.fetch(:mode, "--"), as: :badge },
            { label: :profile, value: package.fetch(:profile_label, "--"), as: :badge }
          ]
        end

        def compare_prompt_package_preview(entry)
          package = entry.fetch(:prompt_package, {})
          {
            prefix_warmup: package[:prefix_warmup],
            system_prompt: package[:system_prompt],
            user_prompt: package[:user_prompt]
          }.compact
        end

        def compare_summary_rows
          return [] unless compare_results_present?

          summary = compare_results.fetch(:summary)
          [
            { label: :scenario, value: compare_results.fetch(:scenario_label, compare_form_defaults.fetch("scenario")), as: :badge },
            { label: :requested_models, value: summary.fetch(:requested_models), as: :number },
            { label: :completed, value: summary.fetch(:completed), as: :number },
            { label: :unavailable, value: summary.fetch(:unavailable), as: :number },
            { label: :generated_at, value: compare_results.fetch(:generated_at), as: :datetime }
          ]
        end

        def default_compare_models
          models = available_model_badges.first(3)
          learned = assistant_evaluation_recommendation.fetch(:model, nil)
          models.unshift(learned) if learned
          models = [assistant_runtime_config.fetch(:model, "qwen3:latest")] if models.compact.empty?
          models.compact.map(&:to_s).reject(&:empty?).uniq.first(3)
        end

        private

        def learned_default_scenario_key
          assistant_evaluation_recommendation.fetch(:scenario_key, "general_brief").to_s
        end

        def completed_briefing_rollout_artifacts(record)
          lines = [
            "note: completed_request_id=#{record.fetch(:id)}",
            "note: scenario=#{record.dig(:scenario, :label) || record.fetch(:scenario_label, "General Brief")}",
            "note: original_request=#{record.fetch(:request, "")}",
            "note: completed_briefing=#{record.fetch(:briefing, "")}"
          ]

          lines.concat(
            Array(record[:artifacts]).map do |entry|
              "#{entry.fetch(:kind)}: #{entry.fetch(:value)}"
            end
          )

          lines.join("\n")
        end
      end
    end
  end
end
