# frozen_string_literal: true

require_relative "../component"

module Igniter
  module Plugins
    module View
      module Arbre
        module Components
          class Badge < Arbre::Component
            builder_method :badge

            TONE_CLASS = {
              neutral: "pill",
              healthy: "pill",
              warning: "pill warn",
              danger: "pill danger"
            }.freeze

            def build(label, *args)
              options = extract_options!(args)
              tone = options.delete(:tone) || :neutral
              class_name = options.delete(:class_name)
              badge_class = merge_classes(TONE_CLASS.fetch(tone.to_sym, TONE_CLASS[:neutral]), class_name)
              super(options.merge(class: badge_class))
              text_node(label.to_s)
            end

            private

            def tag_name
              "span"
            end
          end
        end
      end
    end
  end
end
