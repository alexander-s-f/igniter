# frozen_string_literal: true

require "time"

module Scout
  module Reports
    class ResearchReceipt
      attr_reader :session_id, :payload, :events, :metadata, :generated_at

      def self.build(session_id:, payload:, events:, metadata: {})
        new(session_id: session_id, payload: payload, events: events, metadata: metadata)
      end

      def initialize(session_id:, payload:, events:, metadata: {})
        @session_id = session_id
        @payload = payload
        @events = events.map(&:dup).freeze
        @metadata = metadata.dup.freeze
        @generated_at = Time.now.utc.iso8601
        freeze
      end

      def receipt_id
        "scout-receipt:#{session_id}"
      end

      def valid?
        payload.fetch(:valid)
      end

      def to_h
        {
          receipt_id: receipt_id,
          kind: :scout_research_receipt,
          valid: valid?,
          generated_at: generated_at,
          topic: payload.fetch(:topic),
          sources: payload.fetch(:sources),
          findings: payload.fetch(:findings),
          contradictions: payload.fetch(:contradictions),
          checkpoint: payload.fetch(:checkpoint),
          synthesis: payload.fetch(:synthesis),
          provenance: payload.fetch(:provenance),
          actions: events,
          deferred: payload.fetch(:deferred),
          metadata: metadata
        }.freeze
      end

      def to_markdown
        data = to_h
        lines = [
          "# Scout Research Receipt",
          "",
          "receipt_id: #{data.fetch(:receipt_id)}",
          "valid: #{data.fetch(:valid)}",
          "generated_at: #{data.fetch(:generated_at)}",
          "",
          "## Topic",
          "",
          data.fetch(:topic).fetch(:original),
          "",
          "## Synthesis",
          "",
          data.fetch(:synthesis),
          "",
          "## Findings"
        ]
        data.fetch(:findings).each do |finding|
          lines << "- #{finding.fetch(:id)} [#{finding.fetch(:direction)}]: #{finding.fetch(:statement)}"
          finding.fetch(:source_refs).each do |ref|
            lines << "  - source: #{ref.fetch(:citation_id)}"
          end
        end
        lines += ["", "## Contradictions"]
        data.fetch(:contradictions).each do |contradiction|
          lines << "- #{contradiction.fetch(:id)}: #{contradiction.fetch(:summary)}"
        end
        lines += [
          "",
          "## Checkpoint",
          "",
          "- choice: #{data.fetch(:checkpoint).fetch(:choice)}",
          "- options: #{data.fetch(:checkpoint).fetch(:options).join(",")}",
          "",
          "## Deferred"
        ]
        data.fetch(:deferred).each do |entry|
          lines << "- #{entry.fetch(:code)}: #{entry.fetch(:reason)}"
        end
        lines.join("\n")
      end
    end
  end
end
