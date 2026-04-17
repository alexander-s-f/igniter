# frozen_string_literal: true

module Igniter
  class App
    module RuntimeContext
      class << self
        def current
          Thread.current[:igniter_app_runtime_context]
        end

        def current=(value)
          Thread.current[:igniter_app_runtime_context] = value
        end

        def capture(app_class:, host_config:, host_name:, loader_name:, scheduler_name:, sdk_capabilities:)
          self.current = {
            app_class: app_class,
            app_name: app_class.name,
            root_dir: app_class.root_dir,
            host: host_name,
            loader: loader_name,
            scheduler: scheduler_name,
            sdk_capabilities: Array(sdk_capabilities).map(&:to_sym).sort,
            registrations: host_config.registrations.keys.sort,
            registration_count: host_config.registrations.size,
            routes: host_config.custom_routes.size,
            hooks: {
              before_request: host_config.before_request_hooks.size,
              after_request: host_config.after_request_hooks.size,
              around_request: host_config.around_request_hooks.size
            },
            metrics: {
              configured: !host_config.metrics_collector.nil?,
              collector_class: host_config.metrics_collector&.class&.name
            },
            store: {
              configured: !host_config.store.nil?,
              store_class: host_config.store&.class&.name
            },
            host_settings: deep_dup(host_config.host_settings),
            stack: stack_snapshot
          }.freeze
        end

        private

        def deep_dup(value)
          case value
          when Hash
            value.each_with_object({}) do |(key, nested), memo|
              memo[key] = deep_dup(nested)
            end
          when Array
            value.map { |item| deep_dup(item) }
          else
            value
          end
        end

        def stack_snapshot
          app = ENV["IGNITER_APP"]
          profile = ENV["IGNITER_TOPOLOGY_PROFILE"]
          environment = ENV["IGNITER_ENV"]
          return nil if [app, profile, environment].all? { |value| value.nil? || value.empty? }

          {
            app: presence(app),
            topology_profile: presence(profile),
            environment: presence(environment)
          }.compact
        end

        def presence(value)
          return nil if value.nil? || value.empty?

          value
        end
      end
    end
  end
end
