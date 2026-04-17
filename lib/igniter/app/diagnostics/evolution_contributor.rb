# frozen_string_literal: true

module Igniter
  class App
    module Diagnostics
      module EvolutionContributor
        class << self
          def augment(report:, execution:) # rubocop:disable Lint/UnusedMethodArgument
            context = Igniter::App::RuntimeContext.current
            return report unless context

            report[:app_evolution] = context.fetch(:app_class).evolution_trail.snapshot(limit: 10)
            report
          end

          def append_text(report:, lines:)
            evolution = report[:app_evolution]
            return unless evolution

            lines << "App Evolution: #{summary(evolution)}"
          end

          def append_markdown_summary(report:, lines:)
            evolution = report[:app_evolution]
            return unless evolution

            lines << "- App Evolution: #{summary(evolution)}"
          end

          def append_markdown_sections(report:, lines:)
            evolution = report[:app_evolution]
            return unless evolution

            lines << ""
            lines << "## App Evolution"
            lines << "- Events: total=#{evolution[:total]}, latest=#{evolution[:latest_type] || "none"}"
            lines << "- Persistence: enabled=#{evolution.dig(:persistence, :enabled)} store=#{evolution.dig(:persistence, :store_class) || "none"} path=#{evolution.dig(:persistence, :path) || "none"} retain=#{evolution.dig(:persistence, :max_events) || "all"} archived=#{evolution.dig(:persistence, :archived_events) || 0}"
            unless evolution.dig(:persistence, :retention_policy).nil? || evolution.dig(:persistence, :retention_policy).empty?
              lines << "- Retention Policy: #{inline_counts(evolution.dig(:persistence, :retention_policy))}"
            end
            unless evolution.dig(:persistence, :retained_by_class).nil? || evolution.dig(:persistence, :retained_by_class).empty?
              lines << "- Live Crest: #{inline_counts(evolution.dig(:persistence, :retained_by_class))}"
            end
            evolution[:events].each do |event|
              lines << "- `#{event[:type]}` source=`#{event[:source]}` at=`#{event[:timestamp]}` payload=#{event[:payload].inspect}"
            end
          end

          private

          def summary(evolution)
            parts = []
            parts << "total=#{evolution[:total]}"
            parts << "latest=#{evolution[:latest_type] || "none"}"
            if evolution[:persistence]
              parts << "persisted=#{evolution.dig(:persistence, :enabled)}"
              parts << "retain=#{evolution.dig(:persistence, :max_events) || "all"}"
              parts << "archived=#{evolution.dig(:persistence, :archived_events) || 0}"
              unless evolution.dig(:persistence, :retained_by_class).nil? || evolution.dig(:persistence, :retained_by_class).empty?
                parts << "live=#{inline_counts(evolution.dig(:persistence, :retained_by_class))}"
              end
            end
            parts << "types=#{inline_counts(evolution[:by_type])}" unless evolution[:by_type].empty?
            parts.join(", ")
          end

          def inline_counts(counts)
            counts.sort_by { |key, _count| key.to_s }.map { |key, count| "#{key}=#{count}" }.join(", ")
          end
        end
      end
    end
  end
end
