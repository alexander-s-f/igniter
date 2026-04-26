# frozen_string_literal: true

require "time"

module Lense
  module Reports
    class LenseAnalysisReceipt
      attr_reader :analysis, :snapshot, :events, :metadata

      def self.build(analysis:, snapshot:, events:, metadata: {})
        new(analysis: analysis, snapshot: snapshot, events: events, metadata: metadata)
      end

      def initialize(analysis:, snapshot:, events:, metadata: {})
        @analysis = analysis
        @snapshot = snapshot.respond_to?(:to_h) ? snapshot.to_h : snapshot
        @events = events.map(&:dup)
        @metadata = metadata.dup.freeze
        freeze
      end

      def valid?
        !scan_id.to_s.empty? && counts.fetch(:ruby_files, 0).positive?
      end

      def to_h
        {
          receipt_id: receipt_id,
          kind: :lense_analysis_receipt,
          valid: valid?,
          scan_id: scan_id,
          project_label: snapshot.fetch(:project_label),
          counts: counts,
          health_score: analysis.fetch(:health_score),
          findings: findings,
          evidence_refs: evidence_refs,
          actions: events,
          skipped: skipped_items,
          generated_at: Time.now.utc.iso8601,
          metadata: metadata.dup
        }
      end

      private

      def receipt_id
        "lense-receipt:#{scan_id}"
      end

      def scan_id
        snapshot.fetch(:scan_id)
      end

      def counts
        analysis.fetch(:counts)
      end

      def findings
        analysis.fetch(:findings).map(&:dup)
      end

      def evidence_refs
        findings.flat_map { |finding| Array(finding.fetch(:evidence_refs)) }.uniq.sort
      end

      def skipped_items
        [].tap do |items|
          items << { code: :no_llm_provider, reason: "Narrative analysis is deterministic template output." }
          items << { code: :no_code_mutation, reason: "Lense POC suggests review steps but never edits scanned files." }
          items << { code: :no_background_scheduler, reason: "Weekly report is represented by explicit one-process scan." }
        end
      end
    end
  end
end
