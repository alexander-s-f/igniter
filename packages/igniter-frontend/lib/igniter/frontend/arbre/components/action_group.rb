# frozen_string_literal: true

require_relative "../component"

module Igniter
  module Frontend
    module Arbre
      module Components
        class ActionGroup < Arbre::Component
          builder_method :action_group

          def build(*args, &block)
            options = extract_options!(args)
            class_name = options.delete(:class_name)
            stacked = options.delete(:stacked)

            super(options.merge(class: merge_classes("actions action-group", stacked ? "stacked" : nil, class_name)))
            render_build_block(block)
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
