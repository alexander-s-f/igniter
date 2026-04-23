# frozen_string_literal: true

module Igniter
  module Web
    class Application
      Route = Struct.new(:verb, :path, :target, :metadata, keyword_init: true)
      Mount = Struct.new(:path, :target, :metadata, keyword_init: true)

      attr_reader :routes, :mounts, :api_surface

      def initialize(api: nil)
        @routes = []
        @mounts = []
        @api_surface = api
      end

      def draw(&block)
        instance_eval(&block) if block
        self
      end

      %i[get post put patch delete].each do |verb|
        define_method(verb) do |path, to:, **metadata|
          @routes << Route.new(
            verb: verb,
            path: path,
            target: to,
            metadata: metadata.freeze
          )
          self
        end
      end

      def mount(path, to:, **metadata)
        @mounts << Mount.new(path: path, target: to, metadata: metadata.freeze)
        self
      end

      def api(&block)
        @api_surface ||= Api.new
        @api_surface.draw(&block)
      end

      def command(...)
        api.command(...)
        self
      end

      def query(...)
        api.query(...)
        self
      end

      def stream(...)
        api.stream(...)
        self
      end

      def webhook(...)
        api.webhook(...)
        self
      end
    end
  end
end
