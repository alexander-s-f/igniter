# frozen_string_literal: true

module Igniter
  class App
    # Neutral hosting config produced by the application layer.
    #
    # It captures the runtime-facing needs of an assembled application without
    # tying them to any specific host implementation such as the built-in HTTP
    # server, Rack, or a future event loop / process model.
    class HostConfig
      attr_accessor :store, :metrics_collector, :custom_routes,
                    :before_request_hooks, :after_request_hooks, :around_request_hooks

      attr_reader :registrations, :host_settings

      def initialize
        @store                = nil
        @metrics_collector    = nil
        @custom_routes        = []
        @before_request_hooks = []
        @after_request_hooks  = []
        @around_request_hooks = []
        @registrations        = {}
        @host_settings        = {}
      end

      def register(name, contract_class)
        @registrations[name.to_s] = contract_class
      end

      def configure_host(name, settings)
        @host_settings[name.to_sym] = settings.dup
      end

      def host_settings_for(name)
        @host_settings.fetch(name.to_sym, {})
      end
    end
  end
end
