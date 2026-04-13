# frozen_string_literal: true

module Igniter
  class Application
    # Unified configuration object for an Igniter::Application.
    # Wraps server-level settings in a single place.
    # Call #to_server_config to get a Server::Config for HttpServer / RackApp.
    class AppConfig
      attr_accessor :host, :port, :store, :log_format, :drain_timeout, :metrics_collector,
                    :custom_routes, :before_request_hooks, :after_request_hooks, :around_request_hooks

      def initialize
        @host              = "0.0.0.0"
        @port              = 4567
        @store             = nil # nil → MemoryStore default inside Server::Config
        @log_format        = :text
        @drain_timeout     = 30
        @metrics_collector = nil
        @custom_routes     = []
        @before_request_hooks = []
        @after_request_hooks = []
        @around_request_hooks = []
      end

      def to_server_config
        Igniter::Server::Config.new.tap do |sc|
          sc.host              = host
          sc.port              = port
          sc.store             = store if store
          sc.log_format        = log_format
          sc.drain_timeout     = drain_timeout
          sc.metrics_collector = metrics_collector
          sc.custom_routes     = custom_routes
          sc.before_request_hooks = before_request_hooks
          sc.after_request_hooks = after_request_hooks
          sc.around_request_hooks = around_request_hooks
        end
      end
    end
  end
end
