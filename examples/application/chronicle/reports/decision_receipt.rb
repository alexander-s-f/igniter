# frozen_string_literal: true

require "time"

module Chronicle
  module Reports
    class DecisionReceipt
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
        "chronicle-receipt:#{session_id}"
      end

      def valid?
        payload.fetch(:valid)
      end

      def to_h
        {
          receipt_id: receipt_id,
          kind: :chronicle_decision_receipt,
          valid: valid?,
          generated_at: generated_at,
          proposal: payload.fetch(:proposal),
          conflicts: payload.fetch(:conflicts),
          signoffs: payload.fetch(:signoffs),
          decision_state: payload.fetch(:decision_state),
          provenance: payload.fetch(:provenance),
          actions: events,
          deferred: payload.fetch(:deferred),
          metadata: metadata
        }.freeze
      end

      def to_markdown
        data = to_h
        lines = [
          "# Chronicle Decision Receipt",
          "",
          "receipt_id: #{data.fetch(:receipt_id)}",
          "valid: #{data.fetch(:valid)}",
          "decision_state: #{data.fetch(:decision_state)}",
          "generated_at: #{data.fetch(:generated_at)}",
          "",
          "## Proposal",
          "",
          "- id: #{data.fetch(:proposal).fetch(:id)}",
          "- title: #{data.fetch(:proposal).fetch(:title)}",
          "- author: #{data.fetch(:proposal).fetch(:author)}",
          "- source: #{data.fetch(:proposal).fetch(:source_path)}",
          "",
          "## Conflicts"
        ]
        data.fetch(:conflicts).each do |conflict|
          lines << "- #{conflict.fetch(:decision_id)}: #{conflict.fetch(:title)}"
          lines << "  - kind: #{conflict.fetch(:evidence_kind)}"
          lines << "  - acknowledged: #{conflict.fetch(:acknowledged)}"
          lines << "  - evidence: #{conflict.fetch(:evidence_excerpt)}"
        end
        lines += [
          "",
          "## Signoffs",
          "",
          "- required: #{data.fetch(:signoffs).fetch(:required).join(",")}",
          "- signed: #{data.fetch(:signoffs).fetch(:signed).join(",")}",
          "- refused: #{data.fetch(:signoffs).fetch(:refused).map { |entry| entry.fetch(:signer) }.join(",")}",
          "",
          "## Deferred",
          ""
        ]
        data.fetch(:deferred).each do |entry|
          lines << "- #{entry.fetch(:code)}: #{entry.fetch(:reason)}"
        end
        lines.join("\n")
      end
    end
  end
end
