# frozen_string_literal: true

require "time"

module Dispatch
  module Reports
    class IncidentReceipt
      attr_reader :receipt_id, :payload, :events, :metadata, :generated_at

      def self.build(session_id:, payload:, events:, metadata: {})
        new(
          receipt_id: "dispatch-receipt:#{session_id}",
          payload: payload,
          events: events,
          metadata: metadata
        )
      end

      def initialize(receipt_id:, payload:, events:, metadata: {})
        @receipt_id = receipt_id
        @payload = payload
        @events = events
        @metadata = metadata
        @generated_at = Time.now.utc.iso8601
      end

      def valid?
        payload.fetch(:valid)
      end

      def to_markdown
        lines = [
          "# Dispatch Incident Receipt",
          "",
          "receipt_id: #{receipt_id}",
          "kind: dispatch_incident_receipt",
          "valid: #{valid?}",
          "generated_at: #{generated_at}",
          "",
          "## Incident",
          "- id: #{incident.fetch(:id)}",
          "- title: #{incident.fetch(:title)}",
          "- service: #{incident.fetch(:service)}",
          "- severity: #{payload.fetch(:severity)}",
          "- suspected_cause: #{payload.fetch(:suspected_cause)}",
          "",
          "## Routing",
          "- checkpoint_type: #{checkpoint.fetch(:type, "none")}",
          "- team: #{checkpoint.fetch(:team, "none")}",
          "- reason: #{checkpoint.fetch(:reason, "none")}",
          "",
          "## Evidence"
        ]
        payload.fetch(:evidence_refs).each do |ref|
          lines << "- #{ref.fetch(:event_id)} #{ref.fetch(:citation)} #{ref.fetch(:summary)}"
        end
        lines += [
          "",
          "## Actions"
        ]
        events.each do |event|
          lines << "- #{event.fetch(:kind)} #{event.fetch(:status)}"
        end
        lines += [
          "",
          "## Deferred Scope"
        ]
        payload.fetch(:deferred).each do |entry|
          lines << "- #{entry.fetch(:code)}: #{entry.fetch(:reason)}"
        end
        lines += [
          "",
          "## Provenance",
          "- contract: #{payload.fetch(:provenance).fetch(:contract)}",
          "- source_paths: #{payload.fetch(:provenance).fetch(:source_paths).join(",")}",
          "- metadata: #{metadata}"
        ]
        "#{lines.join("\n")}\n"
      end

      private

      def incident
        payload.fetch(:incident)
      end

      def checkpoint
        payload.fetch(:routing).fetch(:checkpoint)
      end
    end
  end
end
