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
          def build(attributes = {})
            super(attributes)
          rescue NoMethodError => error
            raise unless error.name == :build

            attributes.each do |name, value|
              next if value.nil?

              set_attribute(name, value) if respond_to?(:set_attribute)
            end

            self
          end

          private

          def extract_options!(args)
            args.last.is_a?(Hash) ? args.pop.dup : {}
          end

          def render_build_block(block)
            return unless block

            if block.arity.zero?
              instance_exec(&block)
            else
              block.call(self)
            end
          end

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
