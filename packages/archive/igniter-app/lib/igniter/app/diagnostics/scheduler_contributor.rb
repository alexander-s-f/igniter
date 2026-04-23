# frozen_string_literal: true

module Igniter
  class App
    module Diagnostics
      module SchedulerContributor
        class << self
          def augment(report:, execution:) # rubocop:disable Lint/UnusedMethodArgument
            app = report[:app]
            return report unless app

            scheduler_runtime = Hash(app[:scheduler_runtime] || {})
            jobs = Array(scheduler_runtime[:scheduled_jobs]).map do |job|
              {
                name: job[:name]&.to_sym,
                every: job[:every],
                at: job[:at]
              }
            end

            report[:app_scheduler] = {
              mode: app[:scheduler],
              adapter_class: scheduler_runtime[:adapter_class],
              job_count: scheduler_runtime[:job_count].to_i,
              jobs: jobs
            }
            report
          end

          def append_text(report:, lines:)
            scheduler = report[:app_scheduler]
            return unless scheduler

            lines << "Scheduler: #{summary(scheduler)}"
          end

          def append_markdown_summary(report:, lines:)
            scheduler = report[:app_scheduler]
            return unless scheduler

            lines << "- Scheduler: #{summary(scheduler)}"
          end

          def append_markdown_sections(report:, lines:)
            scheduler = report[:app_scheduler]
            return unless scheduler

            lines << ""
            lines << "## Scheduler"
            lines << "- Mode: `#{scheduler[:mode]}` adapter=`#{scheduler[:adapter_class] || "deferred"}`"
            lines << "- Jobs: total=#{scheduler[:job_count]}"
            scheduler[:jobs].each do |job|
              lines << "- `#{job[:name]}` every=#{job[:every]}#{job[:at] ? ", at=#{job[:at]}" : ""}"
            end
          end

          private

          def summary(scheduler)
            names = scheduler[:jobs].map { |job| job[:name] }.compact
            [
              "mode=#{scheduler[:mode]}",
              "jobs=#{scheduler[:job_count]}",
              "names=#{names.join("|")}",
              "adapter=#{scheduler[:adapter_class] || "deferred"}"
            ].join(", ")
          end
        end
      end
    end
  end
end
