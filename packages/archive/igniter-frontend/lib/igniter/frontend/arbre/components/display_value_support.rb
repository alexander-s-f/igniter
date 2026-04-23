# frozen_string_literal: true

module Igniter
  module Frontend
    module Arbre
      module Components
        module DisplayValueSupport
          private

          def render_semantic_scalar(view, value, as:, theme:, badge_options: nil)
            case as
            when :badge
              view.badge(value, **(badge_options || {}))
            when :code
              view.code(value.to_s, class: theme.code_class)
            when :boolean
              view.boolean(value)
            when :datetime
              view.datetime(value)
            when :indicator
              view.indicator(value)
            when :number
              view.number(value)
            when :percentage
              view.percentage(value)
            else
              view.text_node(display_text(value))
            end
          end

          def display_text(value)
            value.is_a?(Symbol) ? humanize_label(value) : value.to_s
          end
        end
      end
    end
  end
end
