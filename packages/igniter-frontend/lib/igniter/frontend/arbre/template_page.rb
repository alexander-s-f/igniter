# frozen_string_literal: true

require "json"
require_relative "component"

require_relative "components/action_group"
require_relative "components/badge"
require_relative "components/breadcrumbs"
require_relative "components/card"
require_relative "components/conversation_panel"
require_relative "components/event_list"
require_relative "components/json_panel"
require_relative "components/key_value_list"
require_relative "components/metric_grid"
require_relative "components/page_header"
require_relative "components/panel"
require_relative "components/resource_list"
require_relative "components/scenario_card"
require_relative "components/tabs"

module Igniter
  module Frontend
    module Arbre
      class TemplatePage
        UNSET = Object.new

        class << self
          def inherited(subclass)
            super
            subclass.template_root(template_root)
            subclass.template(template)
            subclass.layout(layout)
          end

          def render(**kwargs)
            new(**kwargs).render
          end

          def template_root(path = UNSET)
            return @template_root if path.equal?(UNSET)

            @template_root = path.nil? ? nil : File.expand_path(path)
          end

          def template(name = UNSET)
            return @template_name if name.equal?(UNSET)

            @template_name = name
          end

          def layout(name = UNSET)
            return @layout_name if name.equal?(UNSET)

            @layout_name = name
          end
        end

        def render(template: self.class.template, layout: self.class.layout, locals: nil)
          rendered_template = build_context(resolve_template_path(template), assigns: merged_template_locals(locals))
          return rendered_template.to_s if layout.nil?

          @template_context = rendered_template
          build_context(resolve_template_path(layout), assigns: merged_layout_locals(locals)).to_s
        ensure
          @template_context = nil
        end

        def render_template_content
          raise ArgumentError, "#{self.class} has no template content to render" unless @template_context

          target = current_arbre_context&.current_arbre_element
          raise ArgumentError, "#{self.class} has no active Arbre context" unless target

          @template_context.children.to_a.each do |child|
            if target.respond_to?(:add_child)
              target.add_child(child)
            else
              target << child
            end
          end

          nil
        end

        def template_locals
          {}
        end

        def layout_locals
          template_locals
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

        def frontend_runtime_path(mount: Assets::DEFAULT_MOUNT_PATH)
          frontend_route_for(Assets.runtime_path(mount_path: mount))
        end

        def frontend_javascript_path(logical_path, mount: Assets::DEFAULT_MOUNT_PATH)
          frontend_route_for(Assets.javascript_path(logical_path, mount_path: mount))
        end

        def render_frontend_javascript(*entrypoints, runtime: true, mount: Assets::DEFAULT_MOUNT_PATH, defer: true)
          target = current_arbre_context&.current_arbre_element
          raise ArgumentError, "#{self.class} has no active Arbre context" unless target

          target.script(src: frontend_runtime_path(mount: mount), defer: defer) if runtime

          Array(entrypoints).flatten.compact.each do |entrypoint|
            target.script(src: frontend_javascript_path(entrypoint, mount: mount), defer: defer)
          end

          nil
        end

        private

        def current_arbre_context
          @current_arbre_context
        end

        def merged_template_locals(overrides)
          merge_locals(template_locals, overrides)
        end

        def merged_layout_locals(overrides)
          merge_locals(layout_locals, overrides)
        end

        def merge_locals(base, overrides)
          base.merge(overrides || {})
        end

        def build_context(path, assigns:)
          Arbre.ensure_available!
          Arbre::RawTextNode

          context = Arbre.context_class.new(assigns, self)
          previous_context = @current_arbre_context
          @current_arbre_context = context
          context.instance_eval(File.read(path), path, 1)
          context
        ensure
          @current_arbre_context = previous_context
        end

        def resolve_template_path(name)
          candidate = name.to_s.strip
          raise ArgumentError, "#{self.class} must define a template name" if candidate.empty?

          path = if absolute_template_path?(candidate)
                   candidate
                 else
                   root = self.class.template_root
                   raise ArgumentError, "#{self.class} must define template_root for relative templates" if root.nil?

                   File.expand_path(candidate, root)
                 end

          path = "#{path}.arb" if File.extname(path).empty?
          raise ArgumentError, "missing Arbre template: #{path}" unless File.file?(path)

          path
        end

        def absolute_template_path?(value)
          value.start_with?("/", "./", "../")
        end

        def frontend_route_for(suffix)
          routeable_context = if respond_to?(:context, true)
                              send(:context)
                            elsif instance_variable_defined?(:@context)
                              instance_variable_get(:@context)
                            end

          return suffix unless routeable_context&.respond_to?(:route)

          routeable_context.route(suffix)
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
