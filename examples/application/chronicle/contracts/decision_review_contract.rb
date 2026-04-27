# frozen_string_literal: true

require "igniter/contracts"

module Chronicle
  module Contracts
    class DecisionReviewContract
      SENSITIVE_TAGS = %w[pii consistency billing legal].freeze

      def self.evaluate(proposal:, decisions:, signoffs: [], refusals: [], acknowledged_conflicts: [])
        new(
          proposal: proposal,
          decisions: decisions,
          signoffs: signoffs,
          refusals: refusals,
          acknowledged_conflicts: acknowledged_conflicts
        ).evaluate
      end

      def initialize(proposal:, decisions:, signoffs: [], refusals: [], acknowledged_conflicts: [])
        @proposal = proposal
        @decisions = decisions
        @signoffs = signoffs
        @refusals = refusals
        @acknowledged_conflicts = acknowledged_conflicts
      end

      def evaluate
        result = Igniter::Contracts.with.run(inputs: contract_inputs) do
          input :proposal
          input :decisions
          input :signoffs
          input :refusals
          input :acknowledged_conflicts

          compute :conflict_evidence, depends_on: %i[proposal decisions acknowledged_conflicts] do |proposal:, decisions:, acknowledged_conflicts:|
            DecisionReviewContract.conflict_evidence(proposal, decisions, acknowledged_conflicts)
          end

          compute :required_signoffs, depends_on: [:proposal] do |proposal:|
            Array(proposal.fetch(:requires_signoff)).sort
          end

          compute :readiness, depends_on: %i[conflict_evidence required_signoffs signoffs refusals] do |conflict_evidence:, required_signoffs:, signoffs:, refusals:|
            DecisionReviewContract.readiness(conflict_evidence, required_signoffs, signoffs, refusals)
          end

          compute :receipt_payload, depends_on: %i[proposal conflict_evidence required_signoffs signoffs refusals readiness] do |proposal:, conflict_evidence:, required_signoffs:, signoffs:, refusals:, readiness:|
            DecisionReviewContract.receipt_payload(
              proposal,
              conflict_evidence,
              required_signoffs,
              signoffs,
              refusals,
              readiness
            )
          end

          output :conflict_evidence
          output :required_signoffs
          output :readiness
          output :receipt_payload
        end

        {
          proposal: proposal,
          conflicts: result.output(:conflict_evidence),
          required_signoffs: result.output(:required_signoffs),
          readiness: result.output(:readiness),
          receipt_payload: result.output(:receipt_payload)
        }.freeze
      end

      def self.conflict_evidence(proposal, decisions, acknowledged_conflicts)
        acknowledged = Array(acknowledged_conflicts)
        proposal_tags = Array(proposal.fetch(:tags))
        proposal_tokens = tokens_for(proposal)

        conflicts = decisions.filter_map do |decision|
          shared_tags = proposal_tags & Array(decision.fetch(:tags))
          shared_tokens = proposal_tokens & tokens_for(decision)
          policy_tags = shared_tags & SENSITIVE_TAGS
          next if shared_tags.empty? && shared_tokens.empty? && policy_tags.empty?

          {
            decision_id: decision.fetch(:id),
            title: decision.fetch(:title),
            status: decision.fetch(:status),
            evidence_kind: evidence_kind(policy_tags, shared_tags, shared_tokens),
            evidence_ref: evidence_ref(decision),
            evidence_excerpt: evidence_excerpt(decision, shared_tokens),
            shared_tags: shared_tags.sort,
            shared_tokens: shared_tokens.first(8).sort,
            acknowledged: acknowledged.include?(decision.fetch(:id))
          }.freeze
        end
        conflicts.sort_by { |conflict| [conflict.fetch(:acknowledged) ? 1 : 0, conflict.fetch(:decision_id)] }.freeze
      end

      def self.readiness(conflicts, required_signoffs, signoffs, refusals)
        refusal_names = Array(refusals).map { |entry| entry.fetch(:signer) }.uniq.sort
        signed_names = Array(signoffs).uniq.sort
        missing = Array(required_signoffs) - signed_names
        open_conflicts = conflicts.reject { |conflict| conflict.fetch(:acknowledged) }

        state = if refusal_names.any?
                  :blocked
                elsif open_conflicts.any? || missing.any?
                  :needs_review
                else
                  :ready
                end

        {
          state: state,
          missing_signoffs: missing.freeze,
          refused_by: refusal_names.freeze,
          signed_by: signed_names.freeze,
          open_conflict_count: open_conflicts.length
        }.freeze
      end

      def self.receipt_payload(proposal, conflicts, required_signoffs, signoffs, refusals, readiness)
        {
          proposal: {
            id: proposal.fetch(:id),
            title: proposal.fetch(:title),
            author: proposal.fetch(:author),
            source_path: proposal.fetch(:source_path)
          },
          conflicts: conflicts.map(&:dup).freeze,
          signoffs: {
            required: required_signoffs,
            signed: signoffs,
            refused: refusals
          },
          decision_state: readiness.fetch(:state),
          readiness: readiness,
          provenance: {
            contract: "chronicle_decision_review:v1",
            proposal_path: proposal.fetch(:source_path),
            decision_paths: conflicts.map { |conflict| conflict.fetch(:evidence_ref).split("#").first }.uniq.sort
          },
          deferred: [
            { code: :no_llm_provider, reason: "Conflict detection is deterministic and local." },
            { code: :no_external_mutation, reason: "Chronicle writes only to its runtime workdir." },
            { code: :no_notifications, reason: "Sign-off is represented by explicit local commands." }
          ].freeze,
          valid: readiness.fetch(:state) != :needs_review
        }.freeze
      end

      def self.tokens_for(record)
        text = [
          record.fetch(:title, ""),
          record.fetch(:body, ""),
          Array(record.fetch(:tags, [])).join(" ")
        ].join(" ").downcase
        text.scan(/[a-z][a-z0-9_]{3,}/).reject { |token| stopword?(token) }.uniq
      end

      def self.stopword?(token)
        %w[with from this that into must remain because before after their
           should could would current proposal decision context rejected].include?(token)
      end

      def self.evidence_kind(policy_tags, shared_tags, shared_tokens)
        return :policy_tag if policy_tags.any?
        return :tag_overlap if shared_tags.any?

        shared_tokens.any? ? :text_overlap : :related
      end

      def self.evidence_ref(decision)
        "#{decision.fetch(:source_path)}#constraints"
      end

      def self.evidence_excerpt(decision, shared_tokens)
        constraints = decision.fetch(:sections).fetch(:constraints, "")
        rejected = decision.fetch(:sections).fetch(:rejected_options, "")
        source = [constraints, rejected].reject(&:empty?).join(" ")
        return source.lines.first.to_s.strip unless shared_tokens.any?

        source.lines.find { |line| shared_tokens.any? { |token| line.downcase.include?(token) } }.to_s.strip
      end

      private

      attr_reader :proposal, :decisions, :signoffs, :refusals, :acknowledged_conflicts

      def contract_inputs
        {
          proposal: proposal,
          decisions: decisions,
          signoffs: signoffs,
          refusals: refusals,
          acknowledged_conflicts: acknowledged_conflicts
        }
      end
    end
  end
end
