# frozen_string_literal: true

module Igniter
  class App
    module Diagnostics
      module RuntimeContributor
        class << self
          def augment(report:, execution:) # rubocop:disable Lint/UnusedMethodArgument
            context = Igniter::App::RuntimeContext.current
            return report unless context

            report[:app] = context
            report
          end

          def append_text(report:, lines:)
            app = report[:app]
            return unless app

            lines << "App: #{runtime_summary(app)}"
          end

          def append_markdown_summary(report:, lines:)
            app = report[:app]
            return unless app

            lines << "- App: #{runtime_summary(app)}"
          end

          def append_markdown_sections(report:, lines:)
            app = report[:app]
            return unless app

            lines << ""
            lines << "## App"
            lines << "- Runtime: `#{app[:app_name] || "anonymous"}` host=`#{app[:host]}` loader=`#{app[:loader]}` scheduler=`#{app[:scheduler]}`"
            lines << "- Contracts: total=#{app[:registration_count]}, names=#{app[:registrations].join(", ")}"
            lines << "- Routes: total=#{app[:routes]}, hooks(before=#{app.dig(:hooks, :before_request)}, after=#{app.dig(:hooks, :after_request)}, around=#{app.dig(:hooks, :around_request)})"
            lines << "- Metrics: configured=#{app.dig(:metrics, :configured)}"
            lines << "- Store: configured=#{app.dig(:store, :configured)}"
            if app[:stack]
              lines << "- Stack: root_app=#{app[:stack][:root_app] || "n/a"}, node=#{app[:stack][:node] || "n/a"}, env=#{app[:stack][:environment] || "n/a"}"
            end
          end

          private

          def runtime_summary(app)
            parts = []
            parts << "runtime=#{app[:app_name] || "anonymous"}"
            parts << "host=#{app[:host]}"
            parts << "loader=#{app[:loader]}"
            parts << "scheduler=#{app[:scheduler]}"
            parts << "contracts=#{app[:registration_count]}"
            parts << "routes=#{app[:routes]}"
            parts << "metrics=#{app.dig(:metrics, :configured)}"
            parts << "store=#{app.dig(:store, :configured)}"
            if app[:stack]
              parts << "root_app=#{app[:stack][:root_app]}" if app[:stack][:root_app]
              parts << "node=#{app[:stack][:node]}" if app[:stack][:node]
            end
            parts.join(", ")
          end
        end
      end
    end
  end
end
