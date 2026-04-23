# frozen_string_literal: true

require "time"
require_relative "../component"

module Igniter
  module Frontend
    module Arbre
      module Components
        class Datetime < Arbre::Component
          builder_method :datetime

          DEFAULT_FORMAT = "%Y-%m-%d %H:%M UTC"

          def build(value, *args)
            options = extract_options!(args)
            format = options.delete(:format) || DEFAULT_FORMAT
            class_name = options.delete(:class_name)
            time = coerce_time(value)

            super(options.merge(class: merge_classes("font-mono text-xs leading-6 text-stone-300", class_name), datetime: time&.iso8601))
            text_node(time ? time.utc.strftime(format) : value.to_s)
          end

          private

          def coerce_time(value)
            return value.utc if value.is_a?(Time)
            return value.to_time.utc if value.respond_to?(:to_time)
            return Time.parse(value.to_s).utc unless value.nil? || value.to_s.empty?
          rescue StandardError
            nil
          end

          def tag_name
            "time"
          end
        end
      end
    end
  end
end
