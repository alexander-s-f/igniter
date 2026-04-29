# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :PersistenceManifestContract, outputs: %i[records histories projections commands relations summary] do
      input :capability_manifest
      input :operation_manifest

      compute :records, depends_on: [:operation_manifest] do |operation_manifest:|
        operation_manifest.fetch(:records)
      end

      compute :histories, depends_on: [:operation_manifest] do |operation_manifest:|
        operation_manifest.fetch(:histories)
      end

      compute :projections, depends_on: [:operation_manifest] do |operation_manifest:|
        operation_manifest.fetch(:projections)
      end

      compute :commands, depends_on: [:operation_manifest] do |operation_manifest:|
        operation_manifest.fetch(:commands)
      end

      compute :relations, depends_on: [:operation_manifest] do |operation_manifest:|
        operation_manifest.fetch(:relations)
      end

      compute :summary, depends_on: %i[capability_manifest records histories projections commands relations] do |capability_manifest:, records:, histories:, projections:, commands:, relations:|
        {
          capability_count: capability_manifest.length,
          record_count: records.length,
          history_count: histories.length,
          projection_count: projections.length,
          command_count: commands.length,
          relation_count: relations.length
        }
      end

      output :records
      output :histories
      output :projections
      output :commands
      output :relations
      output :summary
    end
  end
end
