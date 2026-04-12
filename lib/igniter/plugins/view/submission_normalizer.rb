# frozen_string_literal: true

module Igniter
  module Plugins
    module View
      class SubmissionNormalizer
        Error = Class.new(ArgumentError)

        def initialize(schema)
          @schema = schema.is_a?(Schema) ? schema : Schema.load(schema)
        end

        def normalize(payload, action_id:)
          form = schema.form_for_action(action_id)
          raise Error, "no form found for action #{action_id}" unless form

          source = stringify_keys(payload)
          normalized = {}

          Array(form["children"]).each do |field|
            next unless field_node?(field)

            name = field.fetch("name")
            normalized[name] = normalize_field(field, source[name])
          end

          normalized
        end

        private

        attr_reader :schema

        def field_node?(node)
          %w[input textarea select checkbox].include?(node["type"])
        end

        def normalize_field(field, raw_value)
          value =
            case field["type"]
            when "checkbox"
              truthy?(raw_value)
            else
              normalize_scalar(raw_value)
            end

          case field["value_type"]
          when "integer"
            value.nil? ? nil : Integer(value, 10)
          when "float"
            value.nil? ? nil : Float(value)
          when "boolean"
            truthy?(value)
          else
            value
          end
        rescue ArgumentError
          raise Error, "invalid value for #{field.fetch("name")}: #{raw_value.inspect}"
        end

        def normalize_scalar(value)
          return nil if value.nil?

          normalized = value.is_a?(Array) ? value.last : value
          normalized = normalized.to_s.strip
          normalized.empty? ? nil : normalized
        end

        def truthy?(value)
          case value
          when true, 1 then true
          when false, nil, 0 then false
          else
            %w[1 true on yes].include?(value.to_s.strip.downcase)
          end
        end

        def stringify_keys(value)
          case value
          when Hash
            value.each_with_object({}) do |(key, entry), memo|
              memo[key.to_s] = stringify_keys(entry)
            end
          when Array
            value.map { |entry| stringify_keys(entry) }
          else
            value
          end
        end
      end
    end
  end
end
