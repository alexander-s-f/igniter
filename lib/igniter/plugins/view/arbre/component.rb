# frozen_string_literal: true

require_relative "../tailwind"

module Igniter
  module Plugins
    module View
      module Arbre
        FallbackComponent = Class.new do
          def self.builder_method(*)
            nil
          end
        end

        class Component < (Arbre.available? ? Arbre.component_class : FallbackComponent)
          private

          def ui_theme(theme_name = :companion)
            View::Tailwind::UI::Theme.fetch(theme_name)
          end

          def merge_classes(*values)
            values.flatten.compact.reject(&:empty?).join(" ")
          end

          def humanize_label(label)
            label.to_s.gsub(/[_-]+/, " ").split.map(&:capitalize).join(" ")
          end
        end
      end
    end
  end
end
