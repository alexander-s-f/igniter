# frozen_string_literal: true

require "json"

module Igniter
  module Frontend
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
          Igniter::Frontend::Tailwind::UI::Theme.fetch(theme_name)
        end

        def merge_classes(*values)
          values.flatten.compact.reject(&:empty?).join(" ")
        end

        def humanize_label(label)
          label.to_s.gsub(/[_-]+/, " ").split.map(&:capitalize).join(" ")
        end

        def controller_target(controller, name, **attributes)
          attributes.merge(:"data-ig-#{dashize(controller)}-target" => dashize(name))
        end

        def controller_scope(*controllers, **attributes)
          names = [attributes.delete(:"data-ig-controller"), controllers]
                  .flatten
                  .compact
                  .flat_map { |value| value.to_s.split(/\s+/) }
                  .map { |value| dashize(value) }
                  .reject(&:empty?)
                  .uniq

          attributes.merge(:"data-ig-controller" => names.join(" "))
        end

        def stream_scope(**attributes)
          controller_scope(:stream, **attributes)
        end

        def stream_target(name, **attributes)
          controller_target(:stream, name, **attributes)
        end

        def controller_value(controller, name, value, **attributes)
          serialized = serialize_controller_value(value)
          return attributes if serialized.nil?

          attributes.merge(:"data-ig-#{dashize(controller)}-#{dashize(name)}-value" => serialized)
        end

        def stream_value(name, value, **attributes)
          controller_value(:stream, name, value, **attributes)
        end

        def dashize(value)
          value.to_s
               .gsub(/([a-z0-9])([A-Z])/, '\1-\2')
               .tr("_", "-")
               .downcase
        end

        def serialize_controller_value(value)
          case value
          when nil
            nil
          when String
            value
          when Symbol, Numeric
            value.to_s
          when true
            "true"
          when false
            "false"
          when Array, Hash
            JSON.generate(value)
          else
            value.to_s
          end
        end
      end
    end
  end
end
