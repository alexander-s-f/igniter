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
require_relative "web/view_graph_renderer"
require_relative "web/component"
require_relative "web/page"
require_relative "web/record"

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

      def render(graph)
        ViewGraphRenderer.render(graph)
      end
    end
  end
end
