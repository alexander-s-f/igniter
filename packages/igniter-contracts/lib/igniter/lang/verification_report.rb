# frozen_string_literal: true

module Igniter
  module Lang
    class VerificationReport
      attr_reader :profile_fingerprint, :operations, :findings, :descriptors, :metadata, :metadata_manifest

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
        @metadata_manifest = MetadataManifest.from_operations(operations)
        @descriptors = metadata_manifest.descriptors
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
          metadata_manifest: metadata_manifest.to_h,
          findings: findings,
          metadata: metadata
        }
      end
    end
  end
end
