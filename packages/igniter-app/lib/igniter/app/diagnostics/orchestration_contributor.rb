# frozen_string_literal: true

module Igniter
  class App
    module Diagnostics
      module OrchestrationContributor
        class << self
          def augment(report:, execution:) # rubocop:disable Lint/UnusedMethodArgument
            context = Igniter::App::RuntimeContext.current
            return report unless context
            return report unless report[:orchestration]

            app_class = context.fetch(:app_class)
            plan = app_class.orchestration_plan(report)
            report[:app_orchestration] = plan.to_h.merge(
              inbox: app_class.orchestration_inbox.snapshot(limit: 20)
            )
            report[:app_operator] = app_class.operator_overview(execution, limit: 20)
            report
          end

          def append_text(report:, lines:)
            orchestration = report[:app_orchestration]
            operator = report[:app_operator]
            return unless orchestration || operator

            lines << "App Orchestration: #{summary(orchestration)}" if orchestration
            lines << "App Orchestration Inbox: #{inbox_summary(orchestration[:inbox])}" if orchestration[:inbox]
            lines << "App Operator: #{operator_summary(operator)}" if operator
          end

          def append_markdown_summary(report:, lines:)
            orchestration = report[:app_orchestration]
            operator = report[:app_operator]
            return unless orchestration || operator

            lines << "- App Orchestration: #{summary(orchestration)}" if orchestration
            lines << "- App Orchestration Inbox: #{inbox_summary(orchestration[:inbox])}" if orchestration[:inbox]
            lines << "- App Operator: #{operator_summary(operator)}" if operator
          end

          def append_markdown_sections(report:, lines:)
            orchestration = report[:app_orchestration]
            operator = report[:app_operator]
            return unless orchestration || operator

            followup = orchestration[:followup] if orchestration

            if orchestration
              lines << ""
              lines << "## App Orchestration"
              lines << "- Summary: #{summary(orchestration)}"
              lines << "- Inbox: #{inbox_summary(orchestration[:inbox])}" if orchestration[:inbox]

              unless followup[:actions].empty?
                lines << "- Follow-up: total=#{followup.dig(:summary, :total)}, manual_completion=#{followup.dig(:summary, :manual_completion)}, deferred_replies=#{followup.dig(:summary, :deferred_replies)}, interactive_sessions=#{followup.dig(:summary, :interactive_sessions)}, by_policy=#{inline_counts(followup.dig(:summary, :by_policy) || {})}, by_lane=#{inline_counts(followup.dig(:summary, :by_lane) || {})}, by_queue=#{inline_counts(followup.dig(:summary, :by_queue) || {})}"
                followup[:actions].each do |action|
                  lines << "- `#{action[:node]}` `#{action[:action]}`: #{action[:guidance]} reason=`#{action[:reason]}` policy=`#{action.dig(:policy, :name)}` lane=`#{action.dig(:lane, :name) || "none"}` default=`#{action.dig(:policy, :default_operation)}` queue=`#{action.dig(:routing, :queue) || "none"}` channel=`#{action.dig(:routing, :channel) || "none"}`"
                end
              end
            end

            return unless operator

            lines << ""
            lines << "## App Operator"
            lines << "- Summary: #{operator_summary(operator)}"
            Array(operator[:records]).each do |record|
              lines << "- `#{record[:node]}` state=`#{record[:combined_state]}` status=`#{record[:status] || "none"}` phase=`#{record[:phase] || "none"}` lane=`#{record.dig(:lane, :name) || "none"}` queue=`#{record[:queue] || "none"}` assignee=`#{record[:assignee] || "none"}`"
            end
          end

          private

          def summary(orchestration)
            summary = orchestration[:summary]
            followup = orchestration[:followup]

            parts = []
            parts << "total=#{summary[:total]}"
            parts << "attention_required=#{summary[:attention_required]}"
            parts << "manual_completion=#{summary[:manual_completion]}"
            parts << "deferred_replies=#{summary[:deferred_replies]}"
            parts << "interactive_sessions=#{summary[:interactive_sessions]}"
            parts << "single_turn_sessions=#{summary[:single_turn_sessions]}"
            parts << "followups=#{followup.dig(:summary, :total)}"
            parts << "attention_nodes=#{Array(summary[:attention_nodes]).join(",")}" if Array(summary[:attention_nodes]).any?
            parts << "by_action=#{inline_counts(summary[:by_action])}" unless summary[:by_action].empty?
            parts << "by_policy=#{inline_counts(summary[:by_policy])}" unless summary[:by_policy].empty?
            parts << "by_lane=#{inline_counts(summary[:by_lane])}" unless summary[:by_lane].empty?
            parts << "by_queue=#{inline_counts(summary[:by_queue])}" unless summary[:by_queue].empty?
            parts << "by_channel=#{inline_counts(summary[:by_channel])}" unless summary[:by_channel].empty?
            parts.join(", ")
          end

          def inbox_summary(inbox)
            parts = []
            parts << "total=#{inbox[:total]}"
            parts << "open=#{inbox[:open]}"
            parts << "acknowledged=#{inbox[:acknowledged]}"
            parts << "resolved=#{inbox[:resolved]}"
            parts << "dismissed=#{inbox[:dismissed]}"
            parts << "actionable=#{inbox[:actionable]}"
            parts << "latest_action=#{inbox[:latest_action] || "none"}"
            parts << "latest_node=#{inbox[:latest_node] || "none"}"
            parts << "latest_policy=#{inbox[:latest_policy] || "none"}"
            parts << "latest_lane=#{inbox[:latest_lane] || "none"}"
            parts << "latest_assignee=#{inbox[:latest_assignee] || "none"}"
            parts << "latest_queue=#{inbox[:latest_queue] || "none"}"
            parts << "latest_channel=#{inbox[:latest_channel] || "none"}"
            parts << "latest_status=#{inbox[:latest_status] || "none"}"
            parts << "by_status=#{inline_counts(inbox[:by_status])}" unless inbox[:by_status].empty?
            parts << "by_action=#{inline_counts(inbox[:by_action])}" unless inbox[:by_action].empty?
            parts << "by_policy=#{inline_counts(inbox[:by_policy])}" unless inbox[:by_policy].empty?
            parts << "by_lane=#{inline_counts(inbox[:by_lane])}" unless inbox[:by_lane].empty?
            parts << "by_assignee=#{inline_counts(inbox[:by_assignee])}" unless inbox[:by_assignee].empty?
            parts << "by_queue=#{inline_counts(inbox[:by_queue])}" unless inbox[:by_queue].empty?
            parts << "by_channel=#{inline_counts(inbox[:by_channel])}" unless inbox[:by_channel].empty?
            parts.join(", ")
          end

          def operator_summary(operator)
            summary = operator[:summary]

            parts = []
            parts << "total=#{summary[:total]}"
            parts << "live_sessions=#{summary[:live_sessions]}"
            parts << "inbox_items=#{summary[:inbox_items]}"
            parts << "joined=#{summary[:joined_records]}"
            parts << "session_only=#{summary[:session_only]}"
            parts << "inbox_only=#{summary[:inbox_only]}"
            parts << "handed_off=#{summary[:handed_off]}"
            parts << "attention_required=#{summary[:attention_required]}"
            parts << "resumable=#{summary[:resumable]}"
            parts << "by_state=#{inline_counts(summary[:by_combined_state])}" unless summary[:by_combined_state].empty?
            parts << "by_phase=#{inline_counts(summary[:by_phase])}" unless summary[:by_phase].empty?
            parts << "by_lane=#{inline_counts(summary[:by_lane])}" unless summary[:by_lane].empty?
            parts << "by_queue=#{inline_counts(summary[:by_queue])}" unless summary[:by_queue].empty?
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
