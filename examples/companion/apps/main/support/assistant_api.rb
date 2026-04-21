# frozen_string_literal: true

require "time"
require_relative "../contracts/briefing_request_contract"
require_relative "../../../lib/companion/shared/assistant_request_store"
require_relative "../../../lib/companion/shared/runtime_profile"
require_relative "assistant_external_delivery"
require_relative "assistant_runtime"
require_relative "assistant_prompt_package"

module Companion
  module Main
    module Support
      module AssistantAPI
        module_function

        def submit_request(requester:, request:)
          requester_text = requester.to_s.strip
          request_text = request.to_s.strip

          raise ArgumentError, "requester is required" if requester_text.empty?
          raise ArgumentError, "request is required" if request_text.empty?

          runtime_attempt = Companion::Main::Support::AssistantRuntime.auto_draft(
            requester: requester_text,
            request: request_text
          )
          runtime = Companion::Main::Support::AssistantRuntime.overview
          runtime_configuration = Companion::Main::Support::AssistantRuntime.configuration
          base_prompt_package = Companion::Main::Support::AssistantPromptPackage.build(
            requester: requester_text,
            request: request_text,
            runtime_config: runtime_configuration,
            profile: runtime_configuration.fetch(:profile),
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
            }
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
            }
          end

          store = Companion::Shared::RuntimeProfile.execution_store(:main)
          contract = Companion::BriefingRequestContract.start(
            { requester: requester_text, request: request_text },
            store: store
          )
          followups = Companion::MainApp.open_orchestration_followups(contract)

          record = Companion::Shared::AssistantRequestStore.add(
            requester: requester_text,
            request: request_text,
            graph: contract.execution.compiled_graph.name,
            execution_id: contract.execution.events.execution_id,
            followup_ids: followups.opened.map { |entry| entry[:id] } + followups.existing.map { |entry| entry[:id] },
            runtime_mode: runtime.dig(:config, :mode),
            runtime_provider: runtime.dig(:config, :provider),
            runtime_model: runtime.dig(:config, :model),
            runtime_profile_key: runtime.dig(:config, :profile, :key),
            runtime_profile_label: runtime.dig(:config, :profile, :label),
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
          }
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

          request_record(updated_record)
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

          request_record(updated_record)
        end

        def overview(limit: 6)
          records = Companion::Shared::AssistantRequestStore.all.first(limit).map { |record| request_record(record) }
          operator_records = Companion::MainApp.operator_query.limit(limit).to_a

          {
            summary: {
              total_requests: Companion::Shared::AssistantRequestStore.count,
              pending_requests: records.count { |record| %i[pending open acknowledged].include?(record[:status]) },
              completed_requests: records.count { |record| record[:status] == :completed },
              actionable_followups: operator_records.count do |record|
                record[:record_kind] == :orchestration && !%i[resolved dismissed].include?(record[:status])
              end
            },
            runtime: Companion::Main::Support::AssistantRuntime.overview,
            requests: records,
            followups: operator_records.select { |record| record[:record_kind] == :orchestration }
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

        def compare_runtime_outputs(requester:, request:, models:)
          Companion::Main::Support::AssistantRuntime.compare_drafts(
            requester: requester,
            request: request,
            models: models
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
            delivery_target: nil,
            local_draft: local_draft,
            final_briefing: final_briefing
          )
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

      end
    end
  end
end
