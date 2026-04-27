# frozen_string_literal: true

require_relative "../contracts/decision_review_contract"

module Chronicle
  module Services
    class DecisionConflictScanner
      def analyze(proposal:, decisions:, signoffs: [], refusals: [], acknowledged_conflicts: [])
        Contracts::DecisionReviewContract.evaluate(
          proposal: proposal,
          decisions: decisions,
          signoffs: signoffs,
          refusals: refusals,
          acknowledged_conflicts: acknowledged_conflicts
        )
      end
    end
  end
end
