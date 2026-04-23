# frozen_string_literal: true

require "igniter/app/diagnostics"

module Igniter
  module Frontend
    class AppAccess
      attr_reader :request, :config

      def initialize(request:, config:)
        @request = request
        @config = config
      end

      def runtime_context
        Igniter::App::RuntimeContext.current || {}
      end

      def stack
        runtime_context[:stack] || {}
      end

      def stack?
        !stack.empty?
      end

      def app_name
        runtime_context[:app_name]
      end

      def mount_path
        request.script_name
      end
    end
  end
end
