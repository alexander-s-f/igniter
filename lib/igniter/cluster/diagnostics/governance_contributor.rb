# frozen_string_literal: true

module Igniter
  module Cluster
    module Diagnostics
      module GovernanceContributor
        class << self
          def augment(report:, execution:) # rubocop:disable Lint/UnusedMethodArgument
            return report unless defined?(Igniter::Cluster::Mesh)

            config = Igniter::Cluster::Mesh.config
            summary = config.governance_trail&.snapshot(limit: 10)
            return report unless summary

            checkpoint = config.governance_checkpoint(limit: 10)
            assessment = Igniter::Cluster::Trust::Verifier.assess_governance_checkpoint(
              checkpoint,
              trust_store: config.trust_store
            )

            summary[:checkpoint] = {
              peer_name: checkpoint.peer_name,
              node_id: checkpoint.node_id,
              fingerprint: checkpoint.fingerprint,
              crest_digest: checkpoint.crest_digest,
              checkpointed_at: checkpoint.checkpointed_at,
              trust: assessment.to_h
            }
            report[:cluster_governance] = summary
            report
          end

          def append_text(report:, lines:)
            summary = report[:cluster_governance]
            return unless summary

            lines << "Cluster Governance: #{summary_line(summary)}"
          end

          def append_markdown_summary(report:, lines:)
            summary = report[:cluster_governance]
            return unless summary

            lines << "- Cluster Governance: #{summary_line(summary)}"
          end

          def append_markdown_sections(report:, lines:)
            summary = report[:cluster_governance]
            return unless summary

            lines << ""
            lines << "## Cluster Governance"
            lines << "- Events: total=#{summary[:total]}, latest=#{summary[:latest_type] || "none"}"
            if summary[:persistence]
              lines << "- Persistence: enabled=#{summary.dig(:persistence, :enabled)} path=#{summary.dig(:persistence, :path) || "none"} retain=#{summary.dig(:persistence, :max_events) || "all"} archived=#{summary.dig(:persistence, :archived_events) || 0}"
            end
            if summary[:checkpoint]
              lines << "- Checkpoint: node_id=`#{summary.dig(:checkpoint, :node_id)}` trust=`#{summary.dig(:checkpoint, :trust, :status)}` digest=`#{summary.dig(:checkpoint, :crest_digest)}` at=`#{summary.dig(:checkpoint, :checkpointed_at)}`"
            end
            lines << "- Types: #{inline_counts(summary[:by_type])}" unless summary[:by_type].empty?
            summary[:events].each do |event|
              lines << "- `#{event[:type]}` source=`#{event[:source]}` at=`#{event[:timestamp]}` payload=#{event[:payload].inspect}"
            end
          end

          private

          def summary_line(summary)
            parts = []
            parts << "total=#{summary[:total]}"
            parts << "latest=#{summary[:latest_type] || "none"}"
            if summary[:persistence]
              parts << "persisted=#{summary.dig(:persistence, :enabled)}"
              parts << "retain=#{summary.dig(:persistence, :max_events) || "all"}"
              parts << "archived=#{summary.dig(:persistence, :archived_events) || 0}"
            end
            if summary[:checkpoint]
              parts << "checkpoint=#{summary.dig(:checkpoint, :trust, :status) || "unknown"}"
            end
            parts.join(" ")
          end

          def inline_counts(counts)
            counts.sort_by { |key, _count| key.to_s }.map { |key, count| "#{key}=#{count}" }.join(", ")
          end
        end
      end
    end
  end
end
