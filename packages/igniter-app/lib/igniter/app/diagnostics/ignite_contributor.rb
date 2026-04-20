# frozen_string_literal: true

module Igniter
  class App
    module Diagnostics
      module IgniteContributor
        class << self
          def augment(report:, execution:) # rubocop:disable Lint/UnusedMethodArgument
            context = Igniter::App::RuntimeContext.current
            return report unless context

            app_class = context.fetch(:app_class)
            stack_class = app_class.stack_class
            return report unless stack_class

            ignition_plan = stack_class.ignition_plan
            return report if ignition_plan.empty?

            report[:app_ignite] = stack_class.ignition_report.to_h.merge(
              app: app_class.name,
              stack: stack_class.name || "anonymous"
            )
            report
          rescue ArgumentError
            report
          end

          def append_text(report:, lines:)
            ignite = report[:app_ignite]
            return unless ignite

            lines << "App Ignite: #{summary(ignite)}"
          end

          def append_markdown_summary(report:, lines:)
            ignite = report[:app_ignite]
            return unless ignite

            lines << "- App Ignite: #{summary(ignite)}"
          end

          def append_markdown_sections(report:, lines:)
            ignite = report[:app_ignite]
            return unless ignite

            lines << ""
            lines << "## App Ignite"
            lines << "- Summary: #{summary(ignite)}"

            Array(ignite[:entries]).each do |entry|
              lines << "- `#{entry[:target_id]}` `#{entry[:action]}`: status=`#{entry[:status]}` kind=`#{entry[:kind]}` admission=`#{entry.dig(:admission, :status)}` join=`#{entry.dig(:join, :status)}`"
            end
          end

          private

          def summary(ignite)
            summary = ignite[:summary]

            parts = []
            parts << "status=#{ignite[:status]}"
            parts << "total=#{summary[:total]}"
            parts << "actionable=#{summary[:actionable]}"
            parts << "local_replicas=#{summary[:local_replicas]}"
            parts << "remote_targets=#{summary[:remote_targets]}"
            parts << "admission_required=#{summary[:admission_required]}"
            parts << "join_required=#{summary[:join_required]}"
            parts << "by_status=#{inline_counts(summary[:by_status])}" unless summary[:by_status].empty?
            parts << "by_admission=#{inline_counts(summary[:by_admission_status])}" unless summary[:by_admission_status].empty?
            parts << "by_join=#{inline_counts(summary[:by_join_status])}" unless summary[:by_join_status].empty?
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
