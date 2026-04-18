# frozen_string_literal: true

module Igniter
  module Frontend
    class Handler
      class << self
        def call(params:, body:, headers:, env:, raw_body:, config:)
          new(
            params: params,
            body: body,
            headers: headers,
            env: env,
            raw_body: raw_body,
            config: config
          ).call
        end
      end

      attr_reader :params, :body, :headers, :env, :raw_body, :config

      def initialize(params:, body:, headers:, env:, raw_body:, config:)
        @params = params
        @body = body
        @headers = headers
        @env = env
        @raw_body = raw_body
        @config = config
      end

      def call
        raise NotImplementedError, "#{self.class} must implement #call"
      end

      def request
        @request ||= Request.new(
          method: env.fetch("REQUEST_METHOD", "GET"),
          path: env.fetch("PATH_INFO", "/"),
          route_params: params,
          body: body,
          headers: headers,
          env: env,
          raw_body: raw_body
        )
      end

      def response
        @response ||= Response.new
      end

      def app_access
        @app_access ||= AppAccess.new(request: request, config: config)
      end

      def build_context(context_class, **attributes)
        context_class.build(
          request: request,
          app_access: app_access,
          response: response,
          handler: self,
          **attributes
        )
      end

      def render(page_class, context:, **options)
        page_body =
          if page_class.respond_to?(:render)
            page_class.render(context: context, **options)
          else
            page_class.new(context: context, **options).render
          end

        response.html(page_body)
      end

      def html(body, status: 200, headers: {})
        response.html(body, status: status, headers: headers)
      end

      def json(body, status: 200, headers: {})
        response.json(body, status: status, headers: headers)
      end

      def text(body, status: 200, headers: {})
        response.text(body, status: status, headers: headers)
      end

      def redirect_to(location, status: 303, headers: {})
        response.redirect(location, status: status, headers: headers)
      end
    end
  end
end
