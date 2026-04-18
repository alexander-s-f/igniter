# frozen_string_literal: true

require "igniter/core/errors"
require "igniter/core/tool"
require_relative "executor"

module Igniter
  module AI
    # Base class for AI-callable skills — composable units of agent capability.
    class Skill < Executor
      CapabilityError = Igniter::Tool::CapabilityError

      include Igniter::Tool::Discoverable

      class << self
        def inherited(subclass)
          super
          subclass.instance_variable_set(:@output_schema, @output_schema)
          subclass.instance_variable_set(:@feedback_enabled, @feedback_enabled)
          copy_discoverable_state_to(subclass)
        end

        def output_schema(value = nil, &block)
          if block
            @output_schema = Skill::OutputSchema.new(&block)
          elsif value
            super(value)
          else
            @output_schema || super
          end
        end

        def feedback_enabled(val = nil)
          val.nil? ? (@feedback_enabled || false) : (@feedback_enabled = val)
        end

        def feedback_store(val = nil)
          return @feedback_store if val.nil?

          @feedback_store = val == :memory ? Skill::FeedbackStore::Memory.new : val
        end
      end

      protected

      def complete(prompt, context: nil)
        schema = self.class.output_schema

        adjusted = if schema.is_a?(Skill::OutputSchema)
                     "#{prompt}\n\nRespond ONLY with valid JSON matching this schema: #{schema.to_json_description}"
                   else
                     prompt
                   end

        result = super(adjusted, context: context)
        schema.is_a?(Skill::OutputSchema) ? schema.parse(result) : result
      end

      public

      def feedback(output, rating:, notes: nil) # rubocop:disable Metrics/MethodLength
        return self unless self.class.feedback_enabled

        store = self.class.feedback_store
        return self unless store

        output_str = output.to_s
        matched    = (call_history || []).reverse.find { |h| h[:output] == output_str }

        store.store(FeedbackEntry.new(
                      input: matched&.dig(:input),
                      output: output_str,
                      rating: rating.to_sym,
                      notes: notes,
                      timestamp: Time.now
                    ))
        self
      end

      def refine_system_prompt
        store = self.class.feedback_store
        raise Igniter::Error, "No feedback_store configured on #{self.class.name}" unless store

        FeedbackRefiner.new(provider_instance, current_model).refine(
          self.class.system_prompt.to_s,
          store.all
        )
      end
    end
  end
end

require_relative "skill/output_schema"
require_relative "skill/feedback"
