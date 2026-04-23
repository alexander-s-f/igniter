# frozen_string_literal: true

module Igniter
  module Cluster
    class PlanExecutionReport
      attr_reader :plan_kind, :status, :plan, :action_results, :metadata, :explanation

      def initialize(plan_kind:, status:, plan:, action_results:, metadata: {}, explanation: nil)
        @plan_kind = plan_kind.to_sym
        @status = status.to_sym
        @plan = plan
        @action_results = Array(action_results).freeze
        @metadata = metadata.dup.freeze
        @explanation = DecisionExplanation.normalize(
          explanation,
          default_code: @status,
          metadata: @metadata
        )
        freeze
      end

      def completed?
        status == :completed
      end

      def failed?
        status == :failed
      end

      def skipped?
        status == :skipped
      end

      def action_types
        action_results.map(&:action_type).uniq
      end

      def to_h
        {
          plan_kind: plan_kind,
          status: status,
          plan: plan.to_h,
          action_types: action_types,
          action_results: action_results.map(&:to_h),
          metadata: metadata.dup,
          explanation: explanation&.to_h
        }
      end
    end
  end
end
