# frozen_string_literal: true

require_relative "../component"

module Igniter
  module Frontend
    module Arbre
      module Components
        class Boolean < Arbre::Component
          builder_method :boolean

          def build(value, *args)
            options = extract_options!(args)
            size = (options.delete(:size) || :sm).to_sym
            class_name = options.delete(:class_name)
            label = normalize_label(value)
            tone = truthy?(value) ? :healthy : (falsy?(value) ? :danger : :neutral)

            badge_class = merge_classes(
              Badge::TONE_CLASS.fetch(tone, Badge::TONE_CLASS[:neutral]),
              Badge::SIZE_CLASS.fetch(size, Badge::SIZE_CLASS[:sm]),
              class_name
            )

            super(options.merge(class: badge_class))
            text_node(label)
          end

          private

          def normalize_label(value)
            return "Yes" if truthy?(value)
            return "No" if falsy?(value)

            "Unknown"
          end

          def truthy?(value)
            [true, "true", 1, "1", :true, :yes, "yes"].include?(value)
          end

          def falsy?(value)
            [false, "false", 0, "0", :false, :no, "no"].include?(value)
          end

          def tag_name
            "span"
          end
        end
      end
    end
  end
end
