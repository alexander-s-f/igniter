# frozen_string_literal: true

require_relative "../component"

module Igniter
  module Plugins
    module View
      module Arbre
        module Components
          class PageHeader < Arbre::Component
            builder_method :page_header

            def build(*args, &block)
              options = extract_options!(args)
              title = options.delete(:title)
              eyebrow = options.delete(:eyebrow)
              description = options.delete(:description)
              class_name = options.delete(:class_name)

              super(options.merge(class: merge_classes("hero", class_name)))

              div(eyebrow, class: "eyebrow") if eyebrow
              h1 title
              div(description) if description

              render_build_block(block)
            end

            def meta(&block)
              div(class: "meta", &block)
            end

            def actions(&block)
              div(class: "actions", &block)
            end

            def stats(&block)
              div(class: "stats", &block)
            end

            def notice(message, class_name: "ok")
              div(message, class: class_name)
            end

            private

            def tag_name
              "section"
            end
          end
        end
      end
    end
  end
end
