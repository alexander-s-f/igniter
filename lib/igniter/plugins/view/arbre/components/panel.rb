# frozen_string_literal: true

require_relative "../component"

module Igniter
  module Plugins
    module View
      module Arbre
        module Components
          class Panel < Arbre::Component
            builder_method :panel

            def build(*args, &block)
              options = extract_options!(args)
              title = options.delete(:title)
              subtitle = options.delete(:subtitle)
              span = options.delete(:span)
              class_name = options.delete(:class_name)
              span_class = span ? "span-#{span}" : nil
              super(options.merge(class: merge_classes("panel", span_class, class_name)))

              h2(title) if title
              div(subtitle, class: "caption") if subtitle
              render_build_block(block)
            end

            private

            def tag_name
              "article"
            end
          end
        end
      end
    end
  end
end
