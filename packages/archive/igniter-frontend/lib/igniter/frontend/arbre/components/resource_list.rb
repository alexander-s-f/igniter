# frozen_string_literal: true

require_relative "../component"

module Igniter
  module Frontend
    module Arbre
      module Components
        class ResourceList < Arbre::Component
          builder_method :resource_list

          def build(*args, &block)
            options = extract_options!(args)
            class_name = options.delete(:class_name)

            super(options.merge(class: merge_classes("list resource-list", class_name)))
            render_build_block(block)
          end

          def item(title = nil, detail: nil, meta: nil, class_name: nil, &block)
            li(class: class_name) do |entry|
              entry.strong(title) if title
              entry.text_node(" · #{detail}") if detail
              entry.span(" (#{meta})", class: "caption") if meta
              entry.instance_exec(&block) if block
            end
          end

          private

          def tag_name
            "ul"
          end
        end
      end
    end
  end
end
