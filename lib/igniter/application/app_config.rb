# frozen_string_literal: true

module Igniter
  class Application
    # Unified configuration object for an Igniter::Application.
    # Captures application-owned hosting settings before a concrete host adapter
    # maps them into a runtime-specific config object.
    class AppConfig
      attr_accessor :store, :metrics_collector,
                    :custom_routes, :before_request_hooks, :after_request_hooks, :around_request_hooks

      attr_reader :server_host

      def initialize
        @server_host       = ServerHostConfig.new
        @store             = nil
        @metrics_collector = nil
        @custom_routes     = []
        @before_request_hooks = []
        @after_request_hooks = []
        @around_request_hooks = []
      end

      # Compatibility shim while examples/apps migrate to `server_host.*`.
      def host = server_host.host

      def host=(value)
        server_host.host = value
      end

      def port = server_host.port

      def port=(value)
        server_host.port = value
      end

      def log_format = server_host.log_format

      def log_format=(value)
        server_host.log_format = value
      end

      def drain_timeout = server_host.drain_timeout

      def drain_timeout=(value)
        server_host.drain_timeout = value
      end

      def to_host_config
        HostConfig.new.tap do |config|
          config.store                = store
          config.metrics_collector    = metrics_collector
          config.custom_routes        = custom_routes.dup
          config.before_request_hooks = before_request_hooks.dup
          config.after_request_hooks  = after_request_hooks.dup
          config.around_request_hooks = around_request_hooks.dup
          config.configure_host(:server, server_host.to_h)
        end
      end
    end
  end
end
