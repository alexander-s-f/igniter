# frozen_string_literal: true

module Igniter
  module Ignite
    class IgnitionReport
      attr_reader :plan_id, :status, :strategy, :approval_mode, :entries, :events, :summary

      def initialize(plan_id:, status:, strategy:, approval_mode:, entries:, events:, summary:)
        @plan_id = plan_id.to_s
        @status = status.to_sym
        @strategy = strategy.to_sym
        @approval_mode = approval_mode.to_sym
        @entries = Array(entries).map { |entry| immutable(entry) }.freeze
        @events = Array(events).map { |event| immutable(event) }.freeze
        @summary = immutable(summary)
        freeze
      end

      def awaiting_approval?
        status == :awaiting_approval
      end

      def prepared?
        status == :prepared
      end

      def pending_remote?
        status == :pending_remote
      end

      def joined?
        status == :joined
      end

      def blocked?
        status == :blocked
      end

      def by_status
        summary.fetch(:by_status, {})
      end

      def by_join_status
        summary.fetch(:by_join_status, {})
      end

      def to_h
        {
          plan_id: plan_id,
          status: status,
          strategy: strategy,
          approval_mode: approval_mode,
          entries: entries,
          events: events,
          summary: summary
        }
      end

      private

      def immutable(value)
        case value
        when Hash
          value.each_with_object({}) do |(key, nested), result|
            result[key.to_sym] = immutable(nested)
          end.freeze
        when Array
          value.map { |item| immutable(item) }.freeze
        else
          value
        end
      end
    end
  end
end
