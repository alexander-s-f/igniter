# frozen_string_literal: true

require_relative "home_context"

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
            { label: "Assistant API", href: "/v1/assistant/requests" },
            { label: "Operator Console", href: route("/operator") },
            { label: "Overview API", href: route("/api/overview") }
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
          assistant_credential_policy.fetch(:notes, [])
        end

        def assistant_recommendation
          assistant_runtime.fetch(:recommendation, {})
        end

        def assistant_recommendation_rows
          recommendation = assistant_recommendation
          return [] if recommendation.empty?

          [
            { label: :prep, value: recommendation.fetch(:prep, "--"), as: :badge },
            { label: :prep_model, value: recommendation.fetch(:prep_model, "--"), as: :code },
            { label: :delivery, value: recommendation.fetch(:delivery, "--"), as: :badge },
            { label: :delivery_model, value: recommendation.fetch(:delivery_model, "--"), as: :code }
          ]
        end

        def assistant_recommendation_summary
          assistant_recommendation.fetch(:summary, "--")
        end

        def assistant_recommendation_notes
          assistant_recommendation.fetch(:notes, [])
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
          assistant_runtime_channels.map do |channel|
            {
              label: channel.fetch(:label),
              kind: channel.fetch(:kind),
              provider: channel.fetch(:provider),
              model: channel[:model],
              available: channel.fetch(:available),
              credentials_ready: channel.fetch(:credentials_ready),
              credential_policy: channel.fetch(:credential_policy, nil),
              policy_allowed: channel.fetch(:policy_allowed, true),
              reason: channel.fetch(:reason)
            }
          end
        end

        def available_model_badges
          assistant_runtime_status.fetch(:available_models, [])
        end

        def assistant_profile
          assistant_runtime_config.fetch(:profile, {})
        end

        def assistant_profile_rows
          [
            { label: :profile, value: assistant_profile.fetch(:label, "Operator Brief"), as: :badge },
            { label: :guidance, value: assistant_profile.fetch(:guidance, "--"), as: :code },
            { label: :num_predict, value: assistant_profile.fetch(:num_predict, "--"), as: :number }
          ]
        end

        def assistant_profile_strengths
          assistant_profile.fetch(:strengths, [])
        end

        def assistant_request_rows
          super.map do |row|
            record = assistant_requests.find { |entry| entry.fetch(:id) == row.fetch(:id) }
            row.merge(
              runtime_mode: record&.fetch(:runtime_mode, nil),
              runtime_model: record&.fetch(:runtime_model, nil)
            )
          end
        end

        def completed_assistant_requests
          assistant_requests.select { |record| record.fetch(:status) == :completed }.first(4)
        end

        def prompt_package_rows(record)
          package = record.fetch(:prompt_package, {})

          [
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
            prefix_warmup: package[:prefix_warmup],
            system_prompt: package[:system_prompt],
            user_prompt: package[:user_prompt]
          }.compact
        end

        def compare_form_defaults
          {
            "requester" => compare_form_values.fetch("requester", assistant_form_defaults.fetch("requester", "")),
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
            { label: :requested_models, value: summary.fetch(:requested_models), as: :number },
            { label: :completed, value: summary.fetch(:completed), as: :number },
            { label: :unavailable, value: summary.fetch(:unavailable), as: :number },
            { label: :generated_at, value: compare_results.fetch(:generated_at), as: :datetime }
          ]
        end

        def default_compare_models
          models = available_model_badges.first(3)
          models = [assistant_runtime_config.fetch(:model, "qwen3:latest")] if models.empty?
          models
        end
      end
    end
  end
end
