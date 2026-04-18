# frozen_string_literal: true

module Igniter
  module Plugins
    module View
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
        end
      end
    end
  end
end
