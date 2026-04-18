# frozen_string_literal: true

module Igniter
  module Plugins
    module View
      class Schema
        class Page
          class << self
            def render(**kwargs)
              new(**kwargs).render
            end
          end

          def render(**overrides)
            render_schema(schema, **schema_render_options.merge(overrides))
          end

          def render_schema(schema_definition, **kwargs)
            SchemaRenderer.render(schema: schema_definition, **kwargs)
          end

          private

          def schema
            raise NotImplementedError, "#{self.class} must implement #schema"
          end

          def schema_render_options
            {}
          end
        end
      end

      SchemaPage = Schema::Page unless const_defined?(:SchemaPage, false)
    end
  end
end
