# frozen_string_literal: true

module Igniter
  class App
    module Diagnostics
      module AppHostContributor
        class << self
          def augment(report:, execution:) # rubocop:disable Lint/UnusedMethodArgument
            app = report[:app]
            return report unless app
            return report unless app[:host] == :app

            settings = Hash(app.dig(:host_settings, :app) || {})
            report[:app_host] = {
              adapter: :server,
              host: settings[:host],
              port: settings[:port],
              log_format: settings[:log_format],
              drain_timeout: settings[:drain_timeout],
              routes: app[:routes],
              hooks: app[:hooks],
              metrics: app[:metrics],
              store: app[:store]
            }
            report
          end

          def append_text(report:, lines:)
            app_host = report[:app_host]
            return unless app_host

            lines << "App Host: #{summary(app_host)}"
          end

          def append_markdown_summary(report:, lines:)
            app_host = report[:app_host]
            return unless app_host

            lines << "- App Host: #{summary(app_host)}"
          end

          def append_markdown_sections(report:, lines:)
            app_host = report[:app_host]
            return unless app_host

            lines << ""
            lines << "## App Host"
            lines << "- Listener: host=`#{app_host[:host]}` port=`#{app_host[:port]}` log_format=`#{app_host[:log_format]}`"
            lines << "- Runtime: drain_timeout=#{app_host[:drain_timeout]}, routes=#{app_host[:routes]}"
            lines << "- Hooks: before=#{app_host.dig(:hooks, :before_request)}, after=#{app_host.dig(:hooks, :after_request)}, around=#{app_host.dig(:hooks, :around_request)}"
            lines << "- Metrics: configured=#{app_host.dig(:metrics, :configured)}"
            lines << "- Store: configured=#{app_host.dig(:store, :configured)}"
          end

          private

          def summary(app_host)
            [
              "host=#{app_host[:host]}",
              "port=#{app_host[:port]}",
              "log_format=#{app_host[:log_format]}",
              "routes=#{app_host[:routes]}",
              "metrics=#{app_host.dig(:metrics, :configured)}",
              "store=#{app_host.dig(:store, :configured)}"
            ].join(", ")
          end
        end
      end
    end
  end
end
