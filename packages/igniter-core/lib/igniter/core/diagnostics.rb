# frozen_string_literal: true

require_relative "legacy"
Igniter::Core::Legacy.require!("igniter/core/diagnostics")
require_relative "diagnostics/report"
require_relative "diagnostics/agent_contributor"
require_relative "diagnostics/capability_contributor"
require_relative "diagnostics/orchestration_contributor"

module Igniter
  module Diagnostics
    class << self
      def report_contributors
        @report_contributors ||= {}
      end

      def register_report_contributor(name, contributor)
        report_contributors[name.to_sym] = contributor
      end

      def augment_report(report:, execution:)
        report_contributors.each_value do |contributor|
          next unless contributor.respond_to?(:augment)

          contributor.augment(report: report, execution: execution)
        end

        report
      end

      def append_text(report:, lines:)
        report_contributors.each_value do |contributor|
          next unless contributor.respond_to?(:append_text)

          contributor.append_text(report: report, lines: lines)
        end
      end

      def append_markdown_summary(report:, lines:)
        report_contributors.each_value do |contributor|
          next unless contributor.respond_to?(:append_markdown_summary)

          contributor.append_markdown_summary(report: report, lines: lines)
        end
      end

      def append_markdown_sections(report:, lines:)
        report_contributors.each_value do |contributor|
          next unless contributor.respond_to?(:append_markdown_sections)

          contributor.append_markdown_sections(report: report, lines: lines)
        end
      end
    end

    register_report_contributor(:core_agents, AgentContributor)
    register_report_contributor(:core_capabilities, CapabilityContributor)
    register_report_contributor(:core_orchestration, OrchestrationContributor)
  end
end
