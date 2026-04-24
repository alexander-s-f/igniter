# frozen_string_literal: true

require "igniter/application"

require_relative "web/arbre"
require_relative "web/api"
require_relative "web/application"
require_relative "web/composition_finding"
require_relative "web/view_node"
require_relative "web/view_graph"
require_relative "web/screen_spec"
require_relative "web/composition_preset"
require_relative "web/composition_policy"
require_relative "web/composition_result"
require_relative "web/composer"
require_relative "web/component"
require_relative "web/components"
require_relative "web/view_graph_renderer"
require_relative "web/page"
require_relative "web/record"
require_relative "web/mount_context"
require_relative "web/application_web_mount"
require_relative "web/interaction_target"
require_relative "web/surface_structure"

module Igniter
  module Web
    class << self
      def application(&block)
        Application.new.draw(&block)
      end

      def api(&block)
        Api.new.draw(&block)
      end

      def screen(name, intent: nil, **options, &block)
        ScreenSpec.build(name, intent: intent, **options, &block)
      end

      def compose(screen = nil, **options, &block)
        spec = screen || ScreenSpec.build(options.fetch(:name, :anonymous), **options, &block)
        Composer.compose(spec)
      end

      def render(graph, context: nil)
        ViewGraphRenderer.render(graph, context: context)
      end

      def mount(name, path:, application: application(&nil), environment: nil, metadata: {})
        ApplicationWebMount.new(
          name: name,
          path: path,
          web_application: application,
          application_environment: environment,
          metadata: metadata
        )
      end

      def contract(name)
        InteractionTarget.contract(name)
      end

      def service(name)
        InteractionTarget.service(name)
      end

      def projection(name)
        InteractionTarget.projection(name)
      end

      def surface_structure(blueprint = nil, web_root: nil, **options)
        return SurfaceStructure.for(blueprint, **options) unless blueprint.nil?

        SurfaceStructure.new(web_root: web_root || "app/web", **options)
      end
    end
  end
end
