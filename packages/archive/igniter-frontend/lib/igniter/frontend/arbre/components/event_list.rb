# frozen_string_literal: true

require_relative "../component"

module Igniter
  module Frontend
    module Arbre
      module Components
        class EventList < Arbre::Component
          builder_method :event_list

          def build(*args, &block)
            options = extract_options!(args)
            class_name = options.delete(:class_name)

            super(options.merge(class: merge_classes("feed event-list", class_name)))
            render_build_block(block)
          end

          def event(title = nil, meta: nil, detail: nil, class_name: nil, &block)
            div(class: merge_classes("feed-item", class_name)) do |item|
              item.strong(title) if title
              if meta
                item.br if title
                item.span(meta, class: "caption")
              end
              if detail
                item.br if title || meta
                item.text_node(detail)
              end
              item.instance_exec(&block) if block
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
