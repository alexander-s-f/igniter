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

              build_heading(title, subtitle)
              @body = div(class: "panel-body")
              render_build_block(block)
            end

            def add_child(child)
              return super if @body.nil? || child.equal?(@body) || child.equal?(@header) || child.equal?(@heading)

              @body << child
            end

            def meta(value = nil, &block)
              container = ensure_header_container!
              value.nil? ? container.div(class: "meta", &block) : container.div(value, class: "meta", &block)
            end

            def actions(class_name: nil, &block)
              ensure_header_container!.action_group(class_name: class_name, &block)
            end

            private

            def build_heading(title, subtitle)
              return if title.nil? && subtitle.nil?

              ensure_heading_container!
              @heading.h2(title) if title
              @heading.div(subtitle, class: "caption") if subtitle
            end

            def ensure_header_container!
              @header ||= div(class: "panel-header")
            end

            def ensure_heading_container!
              ensure_header_container!
              @heading ||= @header.div(class: "panel-heading")
            end

            def tag_name
              "article"
            end
          end
        end
      end
    end
  end
end
