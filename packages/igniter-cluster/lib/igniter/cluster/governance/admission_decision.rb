# frozen_string_literal: true

require "time"

module Igniter
  module Cluster
    module Governance
      # Typed result of AdmissionWorkflow#request_admission and related methods.
      #
      # Outcomes:
      #   :admitted         — peer is now in the TrustStore; immediately trusted
      #   :rejected         — request was refused by policy or operator
      #   :pending_approval — enqueued; awaits explicit operator approval
      #   :already_trusted  — peer's node_id was already in the TrustStore
      AdmissionDecision = ::Data.define(:request, :outcome, :rationale, :decided_at) do
        def self.build(request:, outcome:, rationale: nil, decided_at: Time.now.utc.iso8601)
          new(
            request:    request,
            outcome:    outcome.to_sym,
            rationale:  rationale&.to_s,
            decided_at: decided_at.to_s
          )
        end

        def admitted?;        outcome == :admitted;         end
        def rejected?;        outcome == :rejected;         end
        def pending_approval?; outcome == :pending_approval; end
        def already_trusted?; outcome == :already_trusted;  end

        def to_h
          {
            request:    request.to_h,
            outcome:    outcome,
            rationale:  rationale,
            decided_at: decided_at
          }
        end
      end
    end
  end
end
