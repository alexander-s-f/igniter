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

          def link(label, href:, class_name: nil, **attributes, &block)
            attributes[:class] = merge_classes(class_name, attributes[:class])
            render_element(:a, label, href: href, **attributes, &block)
          end

          def button(label, type: "button", class_name: nil, **attributes, &block)
            attributes[:class] = merge_classes(class_name, attributes[:class])
            attributes[:type] = type
            render_element(:button, label, **attributes, &block)
          end

          private

          def current_builder
            respond_to?(:current_arbre_element) ? current_arbre_element : self
          end

          def render_element(name, content = nil, **attributes, &block)
            if current_builder.respond_to?(:tag)
              current_builder.tag(name, content, **attributes, &block)
            else
              current_builder.public_send(name, content, **attributes, &block)
            end
          end

          def tag_name
            "div"
          end
        end
      end
    end
  end
end
