# frozen_string_literal: true

require "json"
require_relative "../component"

module Igniter
  module Plugins
    module View
      module Arbre
        module Components
          class JsonPanel < Arbre::Component
            builder_method :json_panel

            def build(*args)
              options = extract_options!(args)
              title = options.delete(:title)
              payload = options.delete(:payload)
              panel_id = options.delete(:panel_id)
              span = options.delete(:span)
              class_name = options.delete(:class_name)
              span_class = span ? "span-#{span}" : nil

              super(options.merge(class: merge_classes("panel", span_class, class_name)))
              h2(title) if title
              pre(id: panel_id) { |code| code.text_node(JSON.pretty_generate(payload)) }
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
