# frozen_string_literal: true

module Igniter
  module Plugins
    module View
      class SubmissionValidator
        def initialize(schema)
          @schema = schema.is_a?(Schema) ? schema : Schema.load(schema)
        end

        def validate(payload, action_id:)
          form = schema.form_for_action(action_id)
          return { "_form" => "form not found for action #{action_id}" } unless form

          each_form_field(form).each_with_object({}) do |field, errors|
            name = field.fetch("name")
            value = payload[name]

            if field["required"] && blank?(value)
              errors[name] = "is required"
              next
            end

            validate_options(field, value, errors) if field["type"] == "select"
          end
        end

        private

        attr_reader :schema

        def field_node?(node)
          %w[input textarea select checkbox].include?(node["type"])
        end

        def each_form_field(node, result = [])
          return result unless node.is_a?(Hash)

          if field_node?(node)
            result << node
            return result
          end

          Array(node["children"]).each do |child|
            each_form_field(child, result)
          end

          result
        end

        def blank?(value)
          value.nil? || (value.respond_to?(:empty?) && value.empty?)
        end

        def validate_options(field, value, errors)
          return if blank?(value)

          values = Array(field["options"]).map { |option| option.fetch("value") }
          errors[field.fetch("name")] = "must be one of the allowed options" unless values.include?(value)
        end
      end
    end
  end
end
