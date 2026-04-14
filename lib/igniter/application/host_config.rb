# frozen_string_literal: true

module Igniter
  class Application
    # Neutral hosting config produced by the application layer.
    #
    # It captures the runtime-facing needs of an assembled application without
    # tying them to any specific host implementation such as the built-in HTTP
    # server, Rack, or a future event loop / process model.
    class HostConfig
      attr_accessor :host, :port, :store, :log_format, :drain_timeout, :metrics_collector,
                    :custom_routes, :before_request_hooks, :after_request_hooks, :around_request_hooks

      attr_reader :registrations

      def initialize
        @host                 = "0.0.0.0"
        @port                 = 4567
        @store                = nil
        @log_format           = :text
        @drain_timeout        = 30
        @metrics_collector    = nil
        @custom_routes        = []
        @before_request_hooks = []
        @after_request_hooks  = []
        @around_request_hooks = []
        @registrations        = {}
      end

      def register(name, contract_class)
        @registrations[name.to_s] = contract_class
      end
    end
  end
end
