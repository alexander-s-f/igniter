# frozen_string_literal: true

module Igniter
  class Application
    # Unified configuration object for an Igniter::Application.
    # Captures application-owned hosting settings before a concrete host adapter
    # maps them into a runtime-specific config object.
    class AppConfig
      attr_accessor :host, :port, :store, :log_format, :drain_timeout, :metrics_collector,
                    :custom_routes, :before_request_hooks, :after_request_hooks, :around_request_hooks

      def initialize
        @host              = "0.0.0.0"
        @port              = 4567
        @store             = nil
        @log_format        = :text
        @drain_timeout     = 30
        @metrics_collector = nil
        @custom_routes     = []
        @before_request_hooks = []
        @after_request_hooks = []
        @around_request_hooks = []
      end

      def to_host_config
        HostConfig.new.tap do |config|
          config.host                 = host
          config.port                 = port
          config.store                = store
          config.log_format           = log_format
          config.drain_timeout        = drain_timeout
          config.metrics_collector    = metrics_collector
          config.custom_routes        = custom_routes.dup
          config.before_request_hooks = before_request_hooks.dup
          config.after_request_hooks  = after_request_hooks.dup
          config.around_request_hooks = around_request_hooks.dup
        end
      end
    end
  end
end
