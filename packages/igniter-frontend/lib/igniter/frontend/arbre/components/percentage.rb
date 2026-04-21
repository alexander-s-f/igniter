# frozen_string_literal: true

require_relative "../component"

module Igniter
  module Frontend
    module Arbre
      module Components
        class Percentage < Arbre::Component
          builder_method :percentage

          def build(value, *args)
            options = extract_options!(args)
            precision = options.key?(:precision) ? options.delete(:precision).to_i : 1
            fraction = options.key?(:fraction) ? options.delete(:fraction) : infer_fraction(value)
            class_name = options.delete(:class_name)
            normalized = normalize_value(value, fraction: fraction)
            tone = infer_tone(normalized)

            super(options.merge(class: merge_classes("font-mono text-sm leading-6", tone_class(tone), class_name)))
            text_node("#{format_value(normalized, precision: precision)}%")
          end

          private

          def infer_fraction(value)
            numeric = coerce_number(value)
            numeric && numeric >= 0 && numeric <= 1
          end

          def normalize_value(value, fraction:)
            numeric = coerce_number(value)
            return nil unless numeric

            fraction ? numeric * 100.0 : numeric
          end

          def format_value(value, precision:)
            return "--" if value.nil?

            format("%.#{precision}f", value)
          end

          def infer_tone(value)
            return :neutral if value.nil?
            return :healthy if value >= 75
            return :warning if value >= 40

            :danger
          end

          def tone_class(tone)
            case tone
            when :healthy
              "text-emerald-200"
            when :warning
              "text-amber-200"
            when :danger
              "text-rose-200"
            else
              "text-stone-300"
            end
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
