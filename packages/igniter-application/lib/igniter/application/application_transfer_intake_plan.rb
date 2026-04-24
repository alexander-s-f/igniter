# frozen_string_literal: true

require "json"

module Igniter
  module Application
    class ApplicationTransferIntakePlan
      METADATA_ENTRY = ApplicationTransferBundleArtifact::METADATA_ENTRY
      FILES_ROOT = ApplicationTransferBundleArtifact::FILES_ROOT

      attr_reader :verification, :destination_root, :metadata, :artifact_path,
                  :verification_payload, :bundle_manifest, :planned_files

      def self.build(verification_or_path, destination_root:, metadata: {})
        verification = verification_or_path.respond_to?(:to_h) ? verification_or_path : ApplicationTransferBundleVerification.verify(verification_or_path)
        new(verification: verification, destination_root: destination_root, metadata: metadata)
      end

      def initialize(verification:, destination_root:, metadata: {})
        @verification = verification
        @verification_payload = verification.to_h
        @artifact_path = verification_payload.fetch(:artifact_path)
        @destination_root = File.expand_path(destination_root.to_s)
        @metadata = metadata.dup.freeze
        @bundle_manifest = read_bundle_manifest
        @planned_files = included_files.map { |entry| planned_file(entry) }.freeze
        freeze
      end

      def ready?
        verification_payload.fetch(:valid) && conflicts.empty? && blockers.empty?
      end

      def to_h
        {
          ready: ready?,
          destination_root: destination_root,
          artifact_path: artifact_path,
          verification_valid: verification_payload.fetch(:valid),
          planned_files: planned_files,
          conflicts: conflicts,
          blockers: blockers,
          warnings: warnings,
          required_host_wiring: required_host_wiring,
          surface_count: surfaces.length,
          metadata: metadata.dup
        }
      end

      private

      def read_bundle_manifest
        path = File.join(artifact_path, METADATA_ENTRY)
        return {} unless File.file?(path)

        JSON.parse(File.read(path), symbolize_names: true)
      rescue JSON::ParserError
        {}
      end

      def bundle_plan
        bundle_manifest.fetch(:plan, {})
      end

      def included_files
        Array(bundle_plan.fetch(:included_files, []))
      end

      def planned_file(entry)
        capsule = entry.fetch(:capsule).to_sym
        artifact_relative_path = File.join(FILES_ROOT, capsule.to_s, entry.fetch(:relative_path).to_s)
        destination_relative_path = File.join(capsule.to_s, entry.fetch(:relative_path).to_s)
        destination_path = File.expand_path(destination_relative_path, destination_root)
        safe = safe_destination?(destination_path, destination_relative_path)
        exists = safe && File.exist?(destination_path)

        {
          capsule: capsule,
          artifact_path: artifact_relative_path,
          destination_relative_path: destination_relative_path,
          destination_path: destination_path,
          bytes: entry[:bytes],
          status: exists ? :conflict : :planned,
          safe: safe
        }
      end

      def conflicts
        planned_files.select { |entry| entry.fetch(:status) == :conflict }.map do |entry|
          entry.merge(code: :destination_exists, message: "Destination file already exists.")
        end
      end

      def blockers
        [].tap do |items|
          items << blocker(:verification_invalid, "Bundle verification is not valid.", verification_payload) unless
            verification_payload.fetch(:valid)
          planned_files.reject { |entry| entry.fetch(:safe) }.each do |entry|
            items << blocker(:unsafe_destination_path, "Planned destination path is unsafe.", entry)
          end
          conflicts.each do |entry|
            items << blocker(:destination_conflict, "Destination file already exists.", entry)
          end
          required_host_wiring.each do |entry|
            items << blocker(:required_host_wiring, "Required host wiring remains unresolved.", entry)
          end
        end
      end

      def warnings
        readiness_warnings
      end

      def readiness_warnings
        bundle_plan.fetch(:warnings, []).map(&:dup)
      end

      def required_host_wiring
        manifest = bundle_plan.fetch(:readiness, {}).fetch(:manifest, {})
        manifest.fetch(:suggested_host_wiring, []).map(&:dup)
      end

      def surfaces
        bundle_plan.fetch(:surfaces, [])
      end

      def safe_destination?(destination_path, destination_relative_path)
        return false if destination_relative_path.empty?
        return false if destination_relative_path.start_with?("/", "\\")
        return false if destination_relative_path.split(%r{[\\/]}).include?("..")

        destination_path == destination_root || destination_path.start_with?("#{destination_root}#{File::SEPARATOR}")
      end

      def blocker(code, message, entry)
        {
          code: code,
          message: message,
          entry: entry
        }
      end
    end
  end
end
