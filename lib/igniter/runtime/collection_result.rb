# frozen_string_literal: true

module Igniter
  module Runtime
    class CollectionResult
      Item = Struct.new(:key, :status, :result, :error, keyword_init: true) do
        def succeeded?
          status == :succeeded
        end

        def failed?
          status == :failed
        end

        def to_h
          {
            key: key,
            status: status,
            result: serialize_result(result),
            error: serialize_error(error)
          }.compact
        end

        private

        def serialize_result(value)
          case value
          when Runtime::Result
            value.to_h
          else
            value
          end
        end

        def serialize_error(value)
          return nil unless value

          {
            type: value.class.name,
            message: value.message,
            context: value.respond_to?(:context) ? value.context : {}
          }
        end
      end

      attr_reader :items, :mode

      def initialize(items:, mode:)
        @items = items.freeze
        @mode = mode.to_sym
      end

      def [](key)
        items.fetch(key)
      end

      def keys
        items.keys
      end

      def successes
        items.select { |_key, item| item.succeeded? }
      end

      def failures
        items.select { |_key, item| item.failed? }
      end

      def items_summary
        items.transform_values do |item|
          {
            status: item.status,
            error: item.error&.message
          }.compact
        end
      end

      def failed_items
        failures.transform_values do |item|
          {
            type: item.error.class.name,
            message: item.error.message,
            context: item.error.respond_to?(:context) ? item.error.context : {}
          }
        end
      end

      def to_h
        items.transform_values(&:to_h)
      end

      def summary
        {
          mode: mode,
          total: items.size,
          succeeded: successes.size,
          failed: failures.size,
          status: failures.empty? ? :succeeded : :partial_failure
        }
      end

      def as_json(*)
        {
          mode: mode,
          summary: summary,
          items: to_h
        }
      end
    end
  end
end
