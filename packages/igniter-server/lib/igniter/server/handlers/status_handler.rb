# frozen_string_literal: true

module Igniter
  module Server
    module Handlers
      class StatusHandler < Base
        private

        def handle(params:, body:) # rubocop:disable Lint/UnusedMethodArgument,Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
          execution_id = params[:id]
          snapshot     = @store.fetch(execution_id)
          states       = snapshot[:states] || snapshot["states"] || {}

          pending = states.values.any? { |s| (s[:status] || s["status"]).to_s == "pending" }
          failed  = states.values.any? { |s| (s[:status] || s["status"]).to_s == "failed" }

          status = if pending then "pending"
                   elsif failed then "failed"
                   else "succeeded"
                   end

          json_ok({ execution_id: execution_id, status: status })
        end
      end
    end
  end
end
