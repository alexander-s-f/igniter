# frozen_string_literal: true

require_relative "../component"

module Igniter
  module Frontend
    module Arbre
      module Components
        class Number < Arbre::Component
          builder_method :number

          def build(value, *args)
            options = extract_options!(args)
            precision = options.key?(:precision) ? options.delete(:precision).to_i : default_precision(value)
            class_name = options.delete(:class_name)

            super(options.merge(class: merge_classes("font-mono text-sm leading-6 text-stone-100", class_name)))
            text_node(format_number(value, precision: precision))
          end

          private

          def default_precision(value)
            numeric = coerce_number(value)
            return 0 unless numeric

            numeric.to_f == numeric.to_i ? 0 : 2
          end

          def format_number(value, precision:)
            numeric = coerce_number(value)
            return value.to_s unless numeric

            whole, fractional = format("%.#{precision}f", numeric).split(".")
            whole = whole.reverse.scan(/\d{1,3}/).join(",").reverse
            precision.zero? ? whole : "#{whole}.#{fractional}"
          end

          def coerce_number(value)
            return value if value.is_a?(Numeric)
            return Float(value.to_s) unless value.nil? || value.to_s.empty?
          rescue ArgumentError, TypeError
            nil
          end

          def tag_name
            "span"
          end
        end
      end
    end
  end
end
