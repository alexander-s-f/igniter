# frozen_string_literal: true

require "time"
require_relative "../contracts/briefing_request_contract"
require_relative "../../../lib/companion/shared/assistant_evaluation_store"
require_relative "../../../lib/companion/shared/assistant_request_store"
require_relative "../../../lib/companion/shared/runtime_profile"
require_relative "assistant_external_delivery"
require_relative "assistant_runtime"
require_relative "assistant_artifacts"
require_relative "assistant_prompt_package"
require_relative "assistant_scenarios"
require_relative "assistant_scenario_context"

module Companion
  module Main
    module Support
      module AssistantAPI
        module_function

        def submit_request(requester:, request:, scenario: nil, scenario_context: {}, artifacts: nil)
          requester_text = requester.to_s.strip
          request_text = request.to_s.strip
          resolved_scenario = Companion::Main::Support::AssistantScenarios.resolve(key: scenario, request: request_text)
          resolved_context = Companion::Main::Support::AssistantScenarioContext.normalize(
            scenario: resolved_scenario,
            context: scenario_context
          )
          resolved_artifacts = Companion::Main::Support::AssistantArtifacts.normalize(raw: artifacts)

          raise ArgumentError, "requester is required" if requester_text.empty?
          raise ArgumentError, "request is required" if request_text.empty?

          runtime_attempt = Companion::Main::Support::AssistantRuntime.auto_draft(
            requester: requester_text,
            request: request_text,
            scenario: resolved_scenario.fetch(:key),
            scenario_context: resolved_context,
            artifacts: resolved_artifacts
          )
          runtime = Companion::Main::Support::AssistantRuntime.overview
          runtime_configuration = Companion::Main::Support::AssistantRuntime.configuration
          base_prompt_package = Companion::Main::Support::AssistantPromptPackage.build(
            requester: requester_text,
            request: request_text,
            runtime_config: runtime_configuration,
            profile: runtime_configuration.fetch(:profile),
            scenario: resolved_scenario,
            scenario_context: resolved_context,
            artifacts: resolved_artifacts,
            delivery_target: runtime.dig(:routing, :delivery_channel)
          )
          prompt_package = runtime_attempt[:prompt_package] || base_prompt_package
          delivery = Companion::Main::Support::AssistantExternalDelivery.deliver(
            prompt_package: prompt_package,
            runtime_overview: runtime
          )

          if %i[succeeded simulated].include?(delivery.fetch(:status))
            record = Companion::Shared::AssistantRequestStore.add(
              requester: requester_text,
              request: request_text,
              graph: "Companion::AssistantDelivery",
              execution_id: "assistant-delivery-#{Time.now.utc.strftime("%Y%m%d%H%M%S%6N")}",
              followup_ids: [],
              status: "completed",
              completed_at: Time.now.utc.iso8601,
              completed_briefing: delivery.fetch(:output),
              runtime_mode: runtime_configuration.fetch(:mode),
              runtime_provider: runtime_configuration.fetch(:provider),
              runtime_model: runtime_configuration.fetch(:model),
              runtime_profile_key: runtime_configuration.dig(:profile, :key),
              runtime_profile_label: runtime_configuration.dig(:profile, :label),
              scenario_key: resolved_scenario.fetch(:key),
              scenario_label: resolved_scenario.fetch(:label),
              scenario_context: resolved_context,
              artifacts: resolved_artifacts,
              prompt_package: prompt_package,
              delivery: delivery
            )

            return {
              request: request_record(record),
              followup: {
                opened: [],
                existing: [],
                summary: { total: 0, manual_completion: 0 }
              }
            }.tap do
              record_observation(
                request: request_record(record),
                action: :completed_external_delivery,
                source: :assistant_api,
                metadata: { delivery_status: delivery[:status], channel: delivery[:channel] }
              )
            end
          end

          if runtime_attempt.fetch(:status) == :succeeded
            record = Companion::Shared::AssistantRequestStore.add(
              requester: requester_text,
              request: request_text,
              graph: "Companion::AssistantRuntime",
              execution_id: "assistant-runtime-#{Time.now.utc.strftime("%Y%m%d%H%M%S%6N")}",
              followup_ids: [],
              status: "completed",
              completed_at: Time.now.utc.iso8601,
              completed_briefing: runtime_attempt.fetch(:briefing),
              runtime_mode: runtime_attempt.dig(:config, :mode),
              runtime_provider: runtime_attempt.dig(:config, :provider),
              runtime_model: runtime_attempt.dig(:config, :model),
              runtime_profile_key: runtime_attempt.dig(:config, :profile, :key),
              runtime_profile_label: runtime_attempt.dig(:config, :profile, :label),
              scenario_key: resolved_scenario.fetch(:key),
              scenario_label: resolved_scenario.fetch(:label),
              scenario_context: resolved_context,
              artifacts: resolved_artifacts,
              prompt_package: prompt_package,
              delivery: delivery
            )

            return {
              request: request_record(record),
              followup: {
                opened: [],
                existing: [],
                summary: { total: 0, manual_completion: 0 }
              }
            }.tap do
              record_observation(
                request: request_record(record),
                action: :completed_local_draft,
                source: :assistant_api,
                metadata: { runtime_mode: runtime_attempt.dig(:config, :mode) }
              )
            end
          end

          open_manual_followup(
            requester: requester_text,
            request: request_text,
            resolved_scenario: resolved_scenario,
            resolved_context: resolved_context,
            resolved_artifacts: resolved_artifacts,
            runtime: runtime,
            prompt_package: prompt_package,
            delivery: delivery
          )
        end

        def approve_request(request_id:, briefing:, note: nil)
          briefing_text = briefing.to_s.strip
          raise ArgumentError, "briefing is required" if briefing_text.empty?

          record = Companion::Shared::AssistantRequestStore.fetch(request_id)
          contract = restore_request_contract(record)
          operator_record = request_operator_record(record, target: contract)

          raise KeyError, "No active follow-up found for request #{request_id.inspect}" unless operator_record

          Companion::MainApp.approve_operator_item(
            operator_record.fetch(:id),
            target: contract,
            value: briefing_text,
            note: note
          )

          updated_record = Companion::Shared::AssistantRequestStore.save(
            record.merge(
              "status" => "completed",
              "completed_at" => Time.now.utc.iso8601,
              "completed_briefing" => briefing_text,
              "delivery" => record["delivery"],
              "prompt_package" => build_prompt_package(
                record,
                local_draft: record.dig("prompt_package", "local_draft"),
                final_briefing: briefing_text
              )
            )
          )

          request_record(updated_record).tap do |request|
            record_observation(
              request: request,
              action: :completed_manual_followup,
              source: :assistant_api,
              metadata: { note: note.to_s.strip }
            )
          end
        end

        def redeliver_request(request_id:)
          record = Companion::Shared::AssistantRequestStore.fetch(request_id)
          prompt_package = normalize_prompt_package(record["prompt_package"] || build_prompt_package(record))
          runtime = Companion::Main::Support::AssistantRuntime.overview
          delivery = Companion::Main::Support::AssistantExternalDelivery.deliver(
            prompt_package: prompt_package,
            runtime_overview: runtime
          )

          updated_record = Companion::Shared::AssistantRequestStore.save(
            record.merge(
              "delivery" => delivery,
              "prompt_package" => prompt_package,
              "status" => record.fetch("status", "completed"),
              "completed_at" => record["completed_at"] || Time.now.utc.iso8601,
              "completed_briefing" => record["completed_briefing"] || delivery[:output]
            )
          )

          request_record(updated_record).tap do |request|
            record_observation(
              request: request,
              action: :redelivered,
              source: :assistant_api,
              metadata: { delivery_status: delivery[:status], channel: delivery[:channel] }
            )
          end
        end

        def fetch_request(request_id)
          request_record(Companion::Shared::AssistantRequestStore.fetch(request_id))
        end

        def reopen_request_as_followup(request_id:, request: nil)
          original_record = Companion::Shared::AssistantRequestStore.fetch(request_id)
          original = request_record(original_record)
          runtime_configuration = Companion::Main::Support::AssistantRuntime.configuration
          runtime = { config: runtime_configuration }
          request_text = request.to_s.strip
          request_text = "Use the attached completed briefing as evidence and propose the next concrete operator follow-up." if request_text.empty?
          resolved_scenario = original.fetch(:scenario, nil) || resolve_scenario(original_record)
          resolved_context = normalize_prompt_package(original_record["scenario_context"] || {})
          resolved_artifacts = reopen_artifacts_for(original)
          prompt_package = Companion::Main::Support::AssistantPromptPackage.build(
            requester: original.fetch(:requester),
            request: request_text,
            runtime_config: runtime_configuration,
            profile: runtime_configuration.fetch(:profile),
            scenario: resolved_scenario,
            scenario_context: resolved_context,
            artifacts: resolved_artifacts,
            delivery_target: manual_delivery_target,
            final_briefing: original.fetch(:briefing, nil)
          )

          open_manual_followup(
            requester: original.fetch(:requester),
            request: request_text,
            resolved_scenario: resolved_scenario,
            resolved_context: resolved_context,
            resolved_artifacts: resolved_artifacts,
            runtime: runtime,
            prompt_package: prompt_package,
            delivery: {
              status: :skipped,
              channel: :manual_completion,
              channel_label: "Manual Completion",
              mode: :manual,
              reason: :reopened_manual_followup,
              source_request_id: original.fetch(:id)
            }
          ).tap do |result|
            record_observation(
              request: result.fetch(:request),
              action: :reopened_manual_action,
              source: :assistant_api,
              metadata: { source_request_id: original.fetch(:id) }
            )
          end
        end

        def observe_request(request_id:, action:, source: nil, metadata: {})
          request = fetch_request(request_id)
          record_observation(request: request, action: action, source: source, metadata: metadata)
        end

        def overview(limit: 6)
          records = Companion::Shared::AssistantRequestStore.all.first(limit).map { |record| request_record(record) }
          operator_records = Companion::MainApp.operator_query.limit(limit).to_a
          runtime = Companion::Main::Support::AssistantRuntime.overview
          evaluations = evaluation_overview(limit: limit)

          {
            summary: {
              total_requests: Companion::Shared::AssistantRequestStore.count,
              pending_requests: records.count { |record| %i[pending open acknowledged].include?(record[:status]) },
              completed_requests: records.count { |record| record[:status] == :completed },
              actionable_followups: operator_records.count do |record|
                record[:record_kind] == :orchestration && !%i[resolved dismissed].include?(record[:status])
              end
            },
            runtime: runtime.merge(
              recommendation: merge_runtime_recommendation(
                runtime.fetch(:recommendation, {}),
                evaluations.fetch(:recommendations, {})
              )
            ),
            requests: records,
            followups: operator_records.select { |record| record[:record_kind] == :orchestration },
            evaluation: evaluations
          }
        end

        def configure_runtime(mode:, model:, base_url:, provider: "ollama", timeout_seconds: 20,
                              delivery_mode: "simulate", delivery_strategy: "prefer_openai",
                              openai_model: nil, anthropic_model: nil)
          Companion::Main::Support::AssistantRuntime.configure(
            mode: mode,
            model: model,
            base_url: base_url,
            provider: provider,
            timeout_seconds: timeout_seconds,
            delivery_mode: delivery_mode,
            delivery_strategy: delivery_strategy,
            openai_model: openai_model,
            anthropic_model: anthropic_model
          )
        end

        def compare_runtime_outputs(requester:, request:, models:, scenario: nil, scenario_context: {}, artifacts: nil)
          Companion::Main::Support::AssistantRuntime.compare_drafts(
            requester: requester,
            request: request,
            models: models,
            scenario: scenario,
            scenario_context: scenario_context,
            artifacts: artifacts
          )
        end

        def all
          Companion::Shared::AssistantRequestStore.all.map { |record| request_record(record) }
        end

        def count
          Companion::Shared::AssistantRequestStore.count
        end

        def reset!
          Companion::Shared::AssistantRequestStore.reset!
          Companion::Shared::AssistantRuntimeStore.reset!
          Companion::Shared::AssistantEvaluationStore.reset!
          Companion::MainApp.reset_orchestration_inbox!
        end

        def request_record(record)
          if record["status"].to_s == "completed" && record["completed_briefing"]
            return {
              id: record.fetch("id"),
              requester: record.fetch("requester"),
              request: record.fetch("request"),
              submitted_at: record.fetch("submitted_at"),
              graph: record.fetch("graph"),
              execution_id: record.fetch("execution_id"),
              followup_ids: Array(record["followup_ids"]),
              status: :completed,
              followup_id: Array(record["followup_ids"]).first,
              followup_status: :resolved,
              policy: :manual_completion,
              lane: :manual_completions,
              queue: "manual-completions",
              channel: "inbox://manual-completions",
              runtime_state: :completed,
              runtime_mode: record["runtime_mode"]&.to_sym,
              runtime_provider: record["runtime_provider"]&.to_sym,
              runtime_model: record["runtime_model"],
              runtime_profile_key: record["runtime_profile_key"]&.to_sym,
              runtime_profile_label: record["runtime_profile_label"],
              scenario_key: record["scenario_key"]&.to_sym,
              scenario_label: record["scenario_label"],
              scenario: resolve_scenario(record),
              scenario_context: normalize_prompt_package(record["scenario_context"] || {}),
              scenario_summary: scenario_summary(record),
              artifacts: normalize_prompt_package(record["artifacts"] || []),
              artifact_summary: artifact_summary(record),
              operator_checklist: operator_checklist(record),
              delivery: normalize_delivery(record["delivery"]),
              prompt_package: normalize_prompt_package(record["prompt_package"] || build_prompt_package(
                record,
                local_draft: record["completed_briefing"],
                final_briefing: record["completed_briefing"]
              )),
              briefing: record["completed_briefing"],
              completed_at: record["completed_at"]
            }
          end

          operator_record = request_operator_record(record)
          contract = restore_request_contract(record)
          briefing_value = contract.pending? ? nil : contract.result.briefing

          {
            id: record.fetch("id"),
            requester: record.fetch("requester"),
            request: record.fetch("request"),
            submitted_at: record.fetch("submitted_at"),
            graph: record.fetch("graph"),
            execution_id: record.fetch("execution_id"),
            followup_ids: Array(record["followup_ids"]),
            status: derive_status(operator_record, contract),
            followup_id: operator_record&.fetch(:id, nil),
            followup_status: operator_record&.fetch(:status, nil),
            policy: operator_record&.dig(:policy, :name),
            lane: operator_record&.dig(:lane, :name),
            queue: operator_record&.fetch(:queue, nil),
            channel: operator_record&.fetch(:channel, nil),
            runtime_state: contract.orchestration_overview[:summary][:by_state]&.keys&.first,
            runtime_mode: record["runtime_mode"]&.to_sym,
            runtime_provider: record["runtime_provider"]&.to_sym,
            runtime_model: record["runtime_model"],
            runtime_profile_key: record["runtime_profile_key"]&.to_sym,
            runtime_profile_label: record["runtime_profile_label"],
            scenario_key: record["scenario_key"]&.to_sym,
            scenario_label: record["scenario_label"],
            scenario: resolve_scenario(record),
            scenario_context: normalize_prompt_package(record["scenario_context"] || {}),
            scenario_summary: scenario_summary(record),
            artifacts: normalize_prompt_package(record["artifacts"] || []),
            artifact_summary: artifact_summary(record),
            operator_checklist: operator_checklist(record),
            delivery: normalize_delivery(record["delivery"]),
            prompt_package: normalize_prompt_package(record["prompt_package"] || build_prompt_package(record)),
            briefing: briefing_value
          }
        rescue StandardError => e
          {
            id: record.fetch("id"),
            requester: record.fetch("requester"),
            request: record.fetch("request"),
            submitted_at: record.fetch("submitted_at"),
            graph: record.fetch("graph"),
            execution_id: record.fetch("execution_id"),
            followup_ids: Array(record["followup_ids"]),
            status: :unavailable,
            runtime_mode: record["runtime_mode"]&.to_sym,
            runtime_provider: record["runtime_provider"]&.to_sym,
            runtime_model: record["runtime_model"],
            runtime_profile_key: record["runtime_profile_key"]&.to_sym,
            runtime_profile_label: record["runtime_profile_label"],
            scenario_key: record["scenario_key"]&.to_sym,
            scenario_label: record["scenario_label"],
            scenario: resolve_scenario(record),
            scenario_context: normalize_prompt_package(record["scenario_context"] || {}),
            scenario_summary: scenario_summary(record),
            artifacts: normalize_prompt_package(record["artifacts"] || []),
            artifact_summary: artifact_summary(record),
            operator_checklist: operator_checklist(record),
            delivery: normalize_delivery(record["delivery"]),
            prompt_package: normalize_prompt_package(record["prompt_package"]),
            error: e.message
          }
        end

        def restore_request_contract(record)
          Companion::BriefingRequestContract.restore_from_store(
            record.fetch("execution_id"),
            store: Companion::Shared::RuntimeProfile.execution_store(:main)
          )
        end

        def request_operator_record(record, target: nil)
          query_target = target || restore_request_contract(record)
          Companion::MainApp.operator_query(query_target).to_a.find do |entry|
            Array(record["followup_ids"]).include?(entry[:id])
          end
        end

        def derive_status(operator_record, contract)
          return :completed if operator_record.nil? && !contract.pending? && !contract.failed?
          return :completed if operator_record&.dig(:status) == :resolved || contract.success?
          return operator_record[:status] if operator_record
          return :failed if contract.failed?

          :pending
        end

        def build_prompt_package(record, local_draft: nil, final_briefing: nil)
          runtime_config = {
            model: record["runtime_model"],
            profile: {
              key: record["runtime_profile_key"]&.to_sym,
              label: record["runtime_profile_label"]
            }
          }

          Companion::Main::Support::AssistantPromptPackage.build(
            requester: record.fetch("requester"),
            request: record.fetch("request"),
            runtime_config: runtime_config,
            scenario: resolve_scenario(record),
            scenario_context: record["scenario_context"],
            artifacts: record["artifacts"],
            delivery_target: nil,
            local_draft: local_draft,
            final_briefing: final_briefing
          )
        end

        def resolve_scenario(record)
          Companion::Main::Support::AssistantScenarios.resolve(
            key: record["scenario_key"],
            request: record["request"]
          )
        end

        def scenario_summary(record)
          Companion::Main::Support::AssistantScenarioContext.summary(
            scenario: resolve_scenario(record),
            context: record["scenario_context"] || {}
          )
        end

        def operator_checklist(record)
          Companion::Main::Support::AssistantScenarioContext.operator_checklist(
            scenario: resolve_scenario(record),
            context: record["scenario_context"] || {}
          )
        end

        def artifact_summary(record)
          Companion::Main::Support::AssistantArtifacts.summary(record["artifacts"] || [])
        end

        def normalize_prompt_package(package)
          case package
          when Hash
            package.each_with_object({}) do |(key, value), normalized|
              normalized[key.to_sym] = normalize_prompt_package(value)
            end
          when Array
            package.map { |value| normalize_prompt_package(value) }
          else
            package
          end
        end

        def normalize_delivery(delivery)
          normalized = normalize_prompt_package(delivery)
          return normalized unless normalized.is_a?(Hash)

          %i[status channel provider reason mode].each do |key|
            normalized[key] = normalized[key].to_sym if normalized[key].is_a?(String)
          end

          normalized
        end

        def open_manual_followup(requester:, request:, resolved_scenario:, resolved_context:, resolved_artifacts:, runtime:, prompt_package:, delivery:)
          store = Companion::Shared::RuntimeProfile.execution_store(:main)
          contract = Companion::BriefingRequestContract.start(
            { requester: requester, request: request },
            store: store
          )
          followups = Companion::MainApp.open_orchestration_followups(contract)

          record = Companion::Shared::AssistantRequestStore.add(
            requester: requester,
            request: request,
            graph: contract.execution.compiled_graph.name,
            execution_id: contract.execution.events.execution_id,
            followup_ids: followups.opened.map { |entry| entry[:id] } + followups.existing.map { |entry| entry[:id] },
            runtime_mode: runtime.dig(:config, :mode),
            runtime_provider: runtime.dig(:config, :provider),
            runtime_model: runtime.dig(:config, :model),
            runtime_profile_key: runtime.dig(:config, :profile, :key),
            runtime_profile_label: runtime.dig(:config, :profile, :label),
            scenario_key: resolved_scenario.fetch(:key),
            scenario_label: resolved_scenario.fetch(:label),
            scenario_context: resolved_context,
            artifacts: resolved_artifacts,
            prompt_package: prompt_package,
            delivery: delivery
          )

          {
            request: request_record(record),
            followup: {
              opened: followups.opened,
              existing: followups.existing,
              summary: Companion::MainApp.orchestration_followup(contract).summary
            }
          }.tap do |result|
            record_observation(
              request: result.fetch(:request),
              action: :opened_manual_followup,
              source: :assistant_api,
              metadata: {
                delivery_reason: delivery[:reason],
                queue: result.dig(:request, :queue)
              }
            )
          end
        end

        def reopen_artifacts_for(record)
          artifacts = [
            {
              kind: :note,
              label: "Completed Briefing",
              value: record.fetch(:briefing, "").to_s
            },
            {
              kind: :note,
              label: "Original Request",
              value: record.fetch(:request, "").to_s
            }
          ]

          artifacts.concat(Array(record[:artifacts]))
          Companion::Main::Support::AssistantArtifacts.normalize(raw: artifacts)
        end

        def manual_delivery_target
          {
            key: :manual_completion,
            label: "Manual Completion"
          }
        end

        def record_observation(request:, action:, source:, metadata: {})
          Companion::Shared::AssistantEvaluationStore.add(
            request_id: request.fetch(:id),
            action: action,
            requester: request.fetch(:requester, nil),
            scenario_key: request.fetch(:scenario_key, nil),
            scenario_label: request.fetch(:scenario_label, nil) || request.dig(:scenario, :label),
            runtime_model: request.fetch(:runtime_model, nil),
            status: request.fetch(:status, nil),
            source: source,
            metadata: metadata
          )
        end

        def evaluation_overview(limit:)
          all_entries = Companion::Shared::AssistantEvaluationStore.all
          recent_entries = all_entries.first(limit)
          {
            summary: {
              total: Companion::Shared::AssistantEvaluationStore.count,
              by_action: count_many(all_entries) { |entry| entry.fetch("action", nil) },
              by_scenario: count_many(all_entries) { |entry| entry["scenario_key"] },
              by_model: count_many(all_entries) { |entry| entry["runtime_model"] }
            },
            recommendations: evaluation_recommendations(all_entries),
            insights: evaluation_insights(all_entries),
            recent: recent_entries.map { |entry| normalize_prompt_package(entry) }
          }
        end

        def count_many(entries)
          entries.each_with_object(Hash.new(0)) do |entry, memo|
            key = yield(entry)
            next if key.nil? || key.to_s.empty?

            normalized_key =
              begin
                key.to_sym
              rescue StandardError
                key
              end

            memo[normalized_key] += 1
          end
        end

        def evaluation_insights(entries)
          insights = []

          if (entry = top_entry(entries, action: "feedback_useful", field: "scenario_label"))
            insights << "#{entry.fetch("scenario_label")} is getting useful operator feedback."
          end

          if (entry = top_entry(entries, action: "feedback_too_verbose", field: "runtime_model"))
            insights << "#{entry.fetch("runtime_model")} tends to be marked too verbose."
          end

          if (entry = top_entry(entries, action: "feedback_too_slow", field: "runtime_model"))
            insights << "#{entry.fetch("runtime_model")} tends to be marked too slow."
          end

          if (entry = top_entry(entries, action: "feedback_wrong_lane", field: "scenario_label"))
            insights << "#{entry.fetch("scenario_label")} is getting wrong-lane feedback and may need better routing."
          end

          if (entry = top_entry(entries, action: "reopened_manual_action", field: "scenario_label"))
            insights << "#{entry.fetch("scenario_label")} often returns to the manual action lane."
          end

          if count_for(entries, "saved_as_note").positive?
            insights << "Operators are saving assistant outputs as notes, which is a good signal for durable usefulness."
          end

          insights.first(4)
        end

        def evaluation_recommendations(entries)
          scenario_key = recommended_scenario_key(entries)
          model = recommended_model(entries)
          scenario = scenario_key ? Companion::Main::Support::AssistantScenarios.resolve(key: scenario_key) : nil

          {
            scenario_key: scenario&.fetch(:key),
            scenario_label: scenario&.fetch(:label),
            model: model,
            summary: recommendation_summary_for(scenario, model),
            notes: recommendation_notes_for(scenario, model, entries)
          }.compact
        end

        def recommended_scenario_key(entries)
          score_map = Hash.new(0)

          entries.each do |entry|
            scenario_key = entry["scenario_key"]
            next if scenario_key.to_s.empty?

            case entry.fetch("action", nil).to_s
            when "feedback_useful", "saved_as_note"
              score_map[scenario_key] += 2
            when "reopened_manual_action"
              score_map[scenario_key] += 1
            when "feedback_wrong_lane"
              score_map[scenario_key] -= 2
            end
          end

          score_map.max_by { |_key, score| score }&.first
        end

        def recommended_model(entries)
          score_map = Hash.new(0)

          entries.each do |entry|
            model = entry["runtime_model"]
            next if model.to_s.empty?

            case entry.fetch("action", nil).to_s
            when "feedback_useful", "saved_as_note", "completed_local_draft", "completed_external_delivery"
              score_map[model] += 2
            when "feedback_too_verbose", "feedback_too_slow"
              score_map[model] -= 2
            when "reopened_manual_action"
              score_map[model] -= 1
            end
          end

          score_map.max_by { |_key, score| score }&.first
        end

        def recommendation_summary_for(scenario, model)
          parts = []
          parts << "Prefer #{scenario.fetch(:label)} as the next default lane." if scenario
          parts << "Prefer #{model} for local prep." if model
          return "No learned defaults yet." if parts.empty?

          parts.join(" ")
        end

        def recommendation_notes_for(scenario, model, entries)
          notes = []
          notes << "#{scenario.fetch(:label)} has the strongest positive recent signal." if scenario
          notes << "#{model} currently has the best net evaluation score." if model
          notes << "Signals are derived from operator actions and explicit feedback." unless entries.empty?
          notes
        end

        def merge_runtime_recommendation(runtime_recommendation, evaluation_recommendation)
          runtime = runtime_recommendation || {}
          evaluation = evaluation_recommendation || {}
          learned_scenario_label = evaluation[:scenario_label]
          learned_model = evaluation[:model]

          summary_parts = [runtime[:summary]]
          if learned_scenario_label
            summary_parts << "Learned default lane is #{learned_scenario_label}."
          end
          if learned_model
            summary_parts << "Learned default prep model is #{learned_model}."
          end

          notes = Array(runtime[:notes]) + Array(evaluation[:notes])

          runtime.merge(
            learned_scenario_key: evaluation[:scenario_key],
            learned_scenario_label: learned_scenario_label,
            learned_model: learned_model,
            summary: summary_parts.compact.join(" "),
            notes: notes.uniq
          )
        end

        def top_entry(entries, action:, field:)
          filtered = entries.select do |entry|
            entry.fetch("action", nil).to_s == action && !entry[field].to_s.empty?
          end
          return nil if filtered.empty?

          grouped = filtered.group_by { |entry| entry[field] }
          top_key, _entries = grouped.max_by { |_key, group| group.size }
          filtered.find { |entry| entry[field] == top_key }
        end

        def count_for(entries, action)
          entries.count { |entry| entry.fetch("action", nil).to_s == action }
        end

      end
    end
  end
end
