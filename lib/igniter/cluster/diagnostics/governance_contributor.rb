# frozen_string_literal: true

module Igniter
  module Cluster
    module Diagnostics
      module GovernanceContributor
        class << self
          def augment(report:, execution:) # rubocop:disable Lint/UnusedMethodArgument
            return report unless defined?(Igniter::Cluster::Mesh)

            summary = Igniter::Cluster::Mesh.config.governance_trail&.snapshot(limit: 10)
            return report unless summary

            report[:cluster_governance] = summary
            report
          end

          def append_text(report:, lines:)
            summary = report[:cluster_governance]
            return unless summary

            lines << "Cluster Governance: total=#{summary[:total]} latest=#{summary[:latest_type] || "none"}"
          end

          def append_markdown_summary(report:, lines:)
            summary = report[:cluster_governance]
            return unless summary

            lines << "- Cluster Governance: total=#{summary[:total]} latest=#{summary[:latest_type] || "none"}"
          end

          def append_markdown_sections(report:, lines:)
            summary = report[:cluster_governance]
            return unless summary

            lines << ""
            lines << "## Cluster Governance"
            lines << "- Events: total=#{summary[:total]}, latest=#{summary[:latest_type] || "none"}"
            lines << "- Types: #{inline_counts(summary[:by_type])}" unless summary[:by_type].empty?
            summary[:events].each do |event|
              lines << "- `#{event[:type]}` source=`#{event[:source]}` at=`#{event[:timestamp]}` payload=#{event[:payload].inspect}"
            end
          end

          private

          def inline_counts(counts)
            counts.sort_by { |key, _count| key.to_s }.map { |key, count| "#{key}=#{count}" }.join(", ")
          end
        end
      end
    end
  end
end
