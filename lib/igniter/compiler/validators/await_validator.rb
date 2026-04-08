# frozen_string_literal: true

module Igniter
  module Compiler
    module Validators
      class AwaitValidator
        def self.call(context)
          new(context).call
        end

        def initialize(context)
          @context = context
        end

        def call
          await_nodes = @context.runtime_nodes.select { |n| n.kind == :await }
          return if await_nodes.empty?

          validate_correlation_keys_as_inputs!(await_nodes)
          validate_unique_event_names!(await_nodes)
        end

        private

        def validate_correlation_keys_as_inputs!(await_nodes) # rubocop:disable Metrics/AbcSize
          correlation_keys = @context.graph.metadata[:correlation_keys] || []
          return if correlation_keys.empty?

          input_names = @context.runtime_nodes.select { |n| n.kind == :input }.map(&:name)
          missing = correlation_keys.reject { |key| input_names.include?(key.to_sym) }
          return if missing.empty?

          raise @context.validation_error(
            await_nodes.first,
            "Correlation keys #{missing.inspect} must be declared as inputs"
          )
        end

        def validate_unique_event_names!(await_nodes)
          event_names = await_nodes.map(&:event_name)
          duplicates = event_names.select { |e| event_names.count(e) > 1 }.uniq
          return if duplicates.empty?

          node = await_nodes.find { |n| duplicates.include?(n.event_name) }
          raise @context.validation_error(
            node,
            "Duplicate await event names: #{duplicates.inspect}"
          )
        end
      end
    end
  end
end
