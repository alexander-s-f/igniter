# frozen_string_literal: true

require "time"
require_relative "../contracts/briefing_request_contract"
require_relative "../../../lib/companion/shared/assistant_request_store"
require_relative "../../../lib/companion/shared/runtime_profile"

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
            followup_ids: followups.opened.map { |entry| entry[:id] } + followups.existing.map { |entry| entry[:id] }
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
              "completed_briefing" => briefing_text
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
            requests: records,
            followups: operator_records.select { |record| record[:record_kind] == :orchestration }
          }
        end

        def all
          Companion::Shared::AssistantRequestStore.all.map { |record| request_record(record) }
        end

        def count
          Companion::Shared::AssistantRequestStore.count
        end

        def reset!
          Companion::Shared::AssistantRequestStore.reset!
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
      end
    end
  end
end
