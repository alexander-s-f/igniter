# frozen_string_literal: true

module Igniter
  module Cluster
    class RoutingPlanResult
      attr_reader :applied, :blocked, :skipped, :summary

      def initialize(applied:, blocked:, skipped: [], summary:)
        @applied = Array(applied).map(&:freeze).freeze
        @blocked = Array(blocked).map(&:freeze).freeze
        @skipped = Array(skipped).map(&:freeze).freeze
        @summary = Hash(summary).freeze
        freeze
      end

      def applied?
        applied.any?
      end

      def blocked?
        blocked.any?
      end

      def skipped?
        skipped.any?
      end

      def to_h
        {
          applied: applied,
          blocked: blocked,
          skipped: skipped,
          summary: summary
        }
      end
    end
  end
end
