# frozen_string_literal: true

require_relative "host_config"
require_relative "app_host_config"
require_relative "cluster_app_host_config"

module Igniter
  class Application
    # Unified configuration object for an Igniter::Application.
    # Captures application-owned hosting settings before a concrete host adapter
    # maps them into a runtime-specific config object.
    class AppConfig
      attr_accessor :store, :metrics_collector,
                    :custom_routes, :before_request_hooks, :after_request_hooks, :around_request_hooks

      attr_reader :app_host, :cluster_app_host

      def initialize
        @app_host          = AppHostConfig.new
        @cluster_app_host  = ClusterAppHostConfig.new
        @store             = nil
        @metrics_collector = nil
        @custom_routes     = []
        @before_request_hooks = []
        @after_request_hooks = []
        @around_request_hooks = []
      end

      def to_host_config
        HostConfig.new.tap do |config|
          config.store                = store
          config.metrics_collector    = metrics_collector
          config.custom_routes        = custom_routes.dup
          config.before_request_hooks = before_request_hooks.dup
          config.after_request_hooks  = after_request_hooks.dup
          config.around_request_hooks = around_request_hooks.dup
          config.configure_host(:app, app_host.to_h)
          config.configure_host(:cluster_app, cluster_app_host.to_h)
        end
      end
    end
  end
end
