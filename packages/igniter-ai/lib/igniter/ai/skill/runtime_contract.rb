# frozen_string_literal: true

module Igniter
  module AI
    class Skill < Executor
      # Canonical runtime-facing contract for AI skills.
      #
      # This gathers the skill semantics that previously lived across separate
      # class-level methods into one immutable object:
      # - structured output contract
      # - feedback/refinement behavior
      # - capability requirements
      # - nested tool/skill affordances
      class RuntimeContract
        attr_reader :output_schema, :feedback_enabled, :feedback_store,
                    :required_capabilities, :tools

        def initialize(output_schema:, feedback_enabled:, feedback_store:, required_capabilities:, tools:)
          @output_schema = output_schema
          @feedback_enabled = !!feedback_enabled
          @feedback_store = feedback_store
          @required_capabilities = Array(required_capabilities).map(&:to_sym).freeze
          @tools = Array(tools).freeze
          @tool_classes = @tools.select do |tool|
            tool.is_a?(Class) && tool.respond_to?(:tool_name) && tool.respond_to?(:to_schema)
          end.freeze
          @tool_names = @tool_classes.map(&:tool_name).freeze
          freeze
        end

        def structured_output?
          output_schema.is_a?(Skill::OutputSchema)
        end

        def feedback?
          feedback_enabled
        end

        def tool_classes
          @tool_classes
        end

        def tool_names
          @tool_names
        end

        def tool_schemas(provider = nil)
          tool_classes.map { |tool| tool.to_schema(provider) }
        end

        def to_h
          {
            structured_output: structured_output?,
            output_schema: serialize_output_schema,
            feedback_enabled: feedback_enabled,
            feedback_store: serialize_feedback_store,
            required_capabilities: required_capabilities,
            tool_names: tool_names,
            tool_count: tool_classes.size,
          }.freeze
        end

        private

        def serialize_output_schema
          if structured_output?
            {
              type: "structured",
              fields: output_schema.fields.map { |field| { name: field.name, type: field.type.name } },
            }
          else
            output_schema
          end
        end

        def serialize_feedback_store
          return nil unless feedback_store

          {
            class_name: feedback_store.class.name,
            size: feedback_store.respond_to?(:size) ? feedback_store.size : nil,
          }.freeze
        end
      end
    end
  end
end
