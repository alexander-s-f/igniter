# frozen_string_literal: true

require_relative "../contracts/incident_triage_contract"

module Dispatch
  module Services
    class DispatchAnalyzer
      def analyze(incident:, events:, runbooks:, teams:, checkpoint: nil)
        Contracts::IncidentTriageContract.evaluate(
          incident: incident,
          events: events,
          runbooks: runbooks,
          teams: teams,
          checkpoint: checkpoint
        )
      end
    end
  end
end
