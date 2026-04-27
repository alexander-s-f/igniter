# frozen_string_literal: true

module Igniter
  module Lang
    class VerificationReport
      attr_reader :profile_fingerprint, :operations, :findings, :descriptors, :metadata

      def self.from_compilation_report(report)
        new(
          profile_fingerprint: report.profile_fingerprint,
          operations: report.operations,
          findings: report.findings.map(&:to_h),
          metadata: { source: :compilation_report }
        )
      end

      def self.from_artifact(artifact, profile_fingerprint:)
        operations = artifact ? artifact.operations : []
        new(
          profile_fingerprint: profile_fingerprint,
          operations: operations,
          findings: [],
          metadata: { source: :compiled_artifact }
        )
      end

      def initialize(profile_fingerprint:, operations:, findings: [], metadata: {})
        @profile_fingerprint = profile_fingerprint
        @operations = operations.freeze
        @findings = findings.freeze
        @metadata = metadata.transform_keys(&:to_sym).freeze
        @descriptors = extract_descriptors(operations).freeze
        freeze
      end

      def ok?
        findings.empty?
      end

      def invalid?
        !ok?
      end

      def to_h
        {
          ok: ok?,
          profile_fingerprint: profile_fingerprint,
          descriptors: descriptors,
          findings: findings,
          metadata: metadata
        }
      end

      private

      def extract_descriptors(operations)
        operations.filter_map do |operation|
          type = operation.attributes[:type]
          next unless type.is_a?(Types::Descriptor)

          {
            node: operation.name,
            kind: operation.kind,
            type: type.to_h
          }
        end
      end
    end
  end
end
