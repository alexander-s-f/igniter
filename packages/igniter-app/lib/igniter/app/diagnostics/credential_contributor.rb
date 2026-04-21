# frozen_string_literal: true

module Igniter
  class App
    module Diagnostics
      module CredentialContributor
        class << self
          def augment(report:, execution:) # rubocop:disable Lint/UnusedMethodArgument
            context = Igniter::App::RuntimeContext.current
            return report unless context

            app_class = context.fetch(:app_class)
            credential_audit = app_class.send(:credential_audit_overview, limit: 10)
            return report unless credential_audit

            report[:app_credentials] = credential_audit
            report
          end

          def append_text(report:, lines:)
            credentials = report[:app_credentials]
            return unless credentials

            lines << "App Credentials: #{summary(credentials)}"
          end

          def append_markdown_summary(report:, lines:)
            credentials = report[:app_credentials]
            return unless credentials

            lines << "- App Credentials: #{summary(credentials)}"
          end

          def append_markdown_sections(report:, lines:)
            credentials = report[:app_credentials]
            return unless credentials

            lines << ""
            lines << "## App Credentials"
            lines << "- Summary: #{summary(credentials)}"
            Array(credentials[:events]).each do |event|
              lines << "- `#{event[:event]}` credential=`#{event[:credential_key]}` policy=`#{event[:policy_name]}` status=`#{event[:status]}` target=`#{event[:target_node] || "none"}` reason=`#{event[:reason] || "none"}`"
            end
          end

          private

          def summary(credentials)
            parts = []
            parts << "events=#{credentials[:total]}"
            parts << "latest=#{credentials[:latest_type]}" if credentials[:latest_type]
            parts << "status=#{credentials[:latest_status]}" if credentials[:latest_status]
            parts << "by_event=#{inline_counts(credentials[:by_event])}" unless credentials[:by_event].nil? || credentials[:by_event].empty?
            parts << "by_policy=#{inline_counts(credentials[:by_policy])}" unless credentials[:by_policy].nil? || credentials[:by_policy].empty?
            parts << "persisted=#{credentials.dig(:persistence, :enabled)}"
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
