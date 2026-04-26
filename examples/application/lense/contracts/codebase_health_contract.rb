# frozen_string_literal: true

require "igniter/contracts"

module Lense
  module Contracts
    class CodebaseHealthContract
      DEFAULT_THRESHOLDS = {
        large_file_lines: 24,
        complex_file_score: 7,
        todo_hotspot_count: 1
      }.freeze

      FINDING_WEIGHTS = {
        duplicate_lines: 18,
        complex_file: 14,
        large_file: 10,
        todo_hotspot: 8
      }.freeze

      def self.evaluate(scan:, thresholds: {})
        new(scan: scan, thresholds: thresholds).evaluate
      end

      def initialize(scan:, thresholds: {})
        @scan = scan
        @thresholds = DEFAULT_THRESHOLDS.merge(thresholds)
      end

      def evaluate
        result = Igniter::Contracts.with.run(inputs: { scan: scan, thresholds: thresholds }) do
          input :scan
          input :thresholds

          compute :counts, depends_on: [:scan] do |scan:|
            scan.fetch(:counts)
          end

          compute :prioritized_findings, depends_on: %i[scan thresholds] do |scan:, thresholds:|
            CodebaseHealthContract.prioritized_findings(scan, thresholds)
          end

          compute :health_score, depends_on: %i[prioritized_findings] do |prioritized_findings:|
            CodebaseHealthContract.health_score(prioritized_findings)
          end

          compute :report_metadata, depends_on: %i[scan health_score prioritized_findings] do |scan:, health_score:, prioritized_findings:|
            {
              scan_id: scan.fetch(:scan_id),
              project_label: scan.fetch(:project_label),
              health_score: health_score,
              finding_count: prioritized_findings.length
            }
          end

          output :counts
          output :prioritized_findings
          output :health_score
          output :report_metadata
        end

        {
          scan: scan,
          counts: result.output(:counts),
          findings: result.output(:prioritized_findings),
          health_score: result.output(:health_score),
          report_metadata: result.output(:report_metadata)
        }
      end

      def self.prioritized_findings(scan, thresholds)
        findings = file_findings(scan.fetch(:ruby_files), thresholds) + duplicate_findings(scan.fetch(:duplicate_groups))
        findings.sort_by { |finding| [-finding.fetch(:severity_score), finding.fetch(:id)] }
      end

      def self.health_score(findings)
        penalty = findings.sum { |finding| FINDING_WEIGHTS.fetch(finding.fetch(:type), 5) }
        [[100 - penalty, 0].max, 100].min
      end

      def self.file_findings(files, thresholds)
        files.flat_map do |file|
          complexity = file.fetch(:method_count) + file.fetch(:branch_count)
          [
            large_file_finding(file, thresholds),
            complex_file_finding(file, complexity, thresholds),
            todo_finding(file, thresholds)
          ].compact
        end
      end

      def self.duplicate_findings(groups)
        groups.map do |group|
          finding(
            :duplicate_lines,
            "duplicate:#{group.fetch(:fingerprint)}",
            "Repeated implementation line appears in #{group.fetch(:file_count)} files.",
            severity_score: 80,
            evidence_refs: group.fetch(:paths).map { |path| "file:#{path}" }
          )
        end
      end

      def self.large_file_finding(file, thresholds)
        return nil if file.fetch(:line_count) < thresholds.fetch(:large_file_lines)

        finding(
          :large_file,
          file.fetch(:relative_path),
          "#{file.fetch(:relative_path)} has #{file.fetch(:line_count)} lines.",
          severity_score: 60,
          evidence_refs: ["file:#{file.fetch(:relative_path)}"]
        )
      end

      def self.complex_file_finding(file, complexity, thresholds)
        return nil if complexity < thresholds.fetch(:complex_file_score)

        finding(
          :complex_file,
          file.fetch(:relative_path),
          "#{file.fetch(:relative_path)} has complexity signal #{complexity}.",
          severity_score: 70,
          evidence_refs: ["file:#{file.fetch(:relative_path)}"]
        )
      end

      def self.todo_finding(file, thresholds)
        return nil if file.fetch(:todo_count) < thresholds.fetch(:todo_hotspot_count)

        finding(
          :todo_hotspot,
          file.fetch(:relative_path),
          "#{file.fetch(:relative_path)} contains #{file.fetch(:todo_count)} TODO/FIXME markers.",
          severity_score: 50,
          evidence_refs: ["file:#{file.fetch(:relative_path)}"]
        )
      end

      def self.finding(type, subject, summary, severity_score:, evidence_refs:)
        {
          id: "#{type}:#{subject}".gsub(/[^a-zA-Z0-9_.:-]/, "_"),
          type: type,
          subject: subject,
          summary: summary,
          severity_score: severity_score,
          evidence_refs: evidence_refs
        }
      end

      private

      attr_reader :scan, :thresholds
    end
  end
end
