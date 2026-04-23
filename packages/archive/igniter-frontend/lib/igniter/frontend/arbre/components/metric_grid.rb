# frozen_string_literal: true

require_relative "../component"

module Igniter
  module Frontend
    module Arbre
      module Components
        class MetricGrid < Arbre::Component
          builder_method :metric_grid

          def build(*args, &block)
            options = extract_options!(args)
            class_name = options.delete(:class_name)

            super(options.merge(class: merge_classes("stats metric-grid", class_name)))
            render_build_block(block)
          end

          def metric(label, value, hint: nil)
            div(class: "stat") do |card|
              card.strong humanize_label(label)
              card.span value.to_s
              card.div hint, class: "caption" if hint
            end
          end

          private

          def tag_name
            "div"
          end
        end
      end
    end
  end
end
