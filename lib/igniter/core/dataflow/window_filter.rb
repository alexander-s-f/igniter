# frozen_string_literal: true

module Igniter
  module Dataflow
    # Applies a sliding window filter to an items array before incremental diff computation.
    #
    # Two window modes are supported:
    #
    #   window: { last: 100 }
    #     Keep only the last 100 items (by position in the array — most recent last).
    #
    #   window: { seconds: 300, field: :received_at }
    #     Keep only items where item[field] >= Time.now - seconds.
    #     The field value must respond to `>=` with a Time (e.g., Time, DateTime).
    class WindowFilter
      def initialize(options)
        @options = options
      end

      # @param items [Array<Hash>] normalized item input hashes
      # @return [Array<Hash>] filtered items
      def apply(items)
        return items unless @options

        if @options.key?(:last)
          apply_last_n(items)
        elsif @options.key?(:seconds)
          apply_time_window(items)
        else
          items
        end
      end

      private

      def apply_last_n(items)
        n = @options[:last]
        items.last(n)
      end

      def apply_time_window(items)
        field  = @options[:field].to_sym
        cutoff = Time.now - @options[:seconds]
        items.select { |item| item[field] >= cutoff }
      end
    end
  end
end
