# frozen_string_literal: true

module Igniter
  module Server
    class ApplicationConfigProjection
      attr_reader :host, :port, :store, :metrics_collector, :log_format, :drain_timeout,
                  :custom_routes, :before_request_hooks, :after_request_hooks,
                  :around_request_hooks, :after_start_hooks, :contracts

      def self.from_environment(environment)
        server_settings = environment.config.fetch(:server, default: {})

        new(
          host: server_settings.fetch(:host, "0.0.0.0"),
          port: server_settings.fetch(:port, 4567),
          store: server_settings[:store],
          metrics_collector: server_settings[:metrics_collector],
          log_format: server_settings.fetch(:log_format, :text),
          drain_timeout: server_settings.fetch(:drain_timeout, 30),
          custom_routes: Array(server_settings[:custom_routes]),
          before_request_hooks: Array(server_settings[:before_request_hooks]),
          after_request_hooks: Array(server_settings[:after_request_hooks]),
          around_request_hooks: Array(server_settings[:around_request_hooks]),
          after_start_hooks: Array(server_settings[:after_start_hooks]),
          contracts: environment.profile.contract_registry.to_h
        )
      end

      def initialize(host:, port:, store:, metrics_collector:, log_format:, drain_timeout:,
                     custom_routes:, before_request_hooks:, after_request_hooks:,
                     around_request_hooks:, after_start_hooks:, contracts:)
        @host = host
        @port = port
        @store = store
        @metrics_collector = metrics_collector
        @log_format = log_format
        @drain_timeout = drain_timeout
        @custom_routes = custom_routes.dup.freeze
        @before_request_hooks = before_request_hooks.dup.freeze
        @after_request_hooks = after_request_hooks.dup.freeze
        @around_request_hooks = around_request_hooks.dup.freeze
        @after_start_hooks = after_start_hooks.dup.freeze
        @contracts = contracts.dup.freeze
        freeze
      end

      def to_server_config
        Config.new.tap do |config|
          config.host = host
          config.port = port
          config.log_format = log_format
          config.drain_timeout = drain_timeout
          config.store = store unless store.nil?
          config.metrics_collector = metrics_collector unless metrics_collector.nil?
          config.custom_routes = custom_routes.dup
          config.before_request_hooks = before_request_hooks.dup
          config.after_request_hooks = after_request_hooks.dup
          config.around_request_hooks = around_request_hooks.dup
          config.after_start_hooks = after_start_hooks.dup
          contracts.each do |name, contract_class|
            config.register(name, contract_class)
          end
        end
      end

      def to_h
        {
          host: host,
          port: port,
          log_format: log_format,
          drain_timeout: drain_timeout,
          custom_routes: custom_routes.dup,
          before_request_hooks: before_request_hooks.dup,
          after_request_hooks: after_request_hooks.dup,
          around_request_hooks: around_request_hooks.dup,
          after_start_hooks: after_start_hooks.dup,
          contracts: contracts.keys.sort
        }
      end
    end
  end
end
