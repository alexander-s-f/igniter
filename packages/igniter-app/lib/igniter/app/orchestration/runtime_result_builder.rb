# frozen_string_literal: true

module Igniter
  class App
    module Orchestration
      class RuntimeResultBuilder
        def self.build(summary:, record:)
          {
            orchestration_runtime_summary: summary,
            orchestration_runtime_record: record,
            orchestration_runtime_result: RuntimeOverviewBuilder.result_snapshot(record),
            orchestration_runtime_latest_event: RuntimeOverviewBuilder.latest_event_for(record),
            orchestration_runtime_latest_transition: record[:latest_runtime_transition]&.dup&.freeze,
            orchestration_runtime_status: record[:runtime_status],
            orchestration_runtime_state: record[:runtime_state],
            orchestration_runtime_state_class: record[:runtime_state_class],
            orchestration_runtime_timeline: Array(record[:combined_timeline] || record[:timeline]).map(&:dup).freeze
          }.freeze
        end
      end
    end
  end
end
