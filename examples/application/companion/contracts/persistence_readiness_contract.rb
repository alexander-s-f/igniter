# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :PersistenceReadinessContract, outputs: %i[ready status capability_count record_count history_count projection_count relation_count warning_count warnings summary] do
      input :capability_manifest
      input :relation_manifest
      input :relation_health
      input :validation_errors

      compute :ready, depends_on: [:validation_errors] do |validation_errors:|
        Array(validation_errors).empty?
      end

      compute :status, depends_on: [:ready] do |ready:|
        ready ? :ready : :blocked
      end

      compute :capability_count, depends_on: [:capability_manifest] do |capability_manifest:|
        capability_manifest.length
      end

      compute :record_count, depends_on: [:capability_manifest] do |capability_manifest:|
        capability_manifest.values.count { |entry| entry.fetch(:kind) == :record }
      end

      compute :history_count, depends_on: [:capability_manifest] do |capability_manifest:|
        capability_manifest.values.count { |entry| entry.fetch(:kind) == :history }
      end

      compute :projection_count, depends_on: [:capability_manifest] do |capability_manifest:|
        capability_manifest.values.count { |entry| entry.fetch(:kind) == :projection }
      end

      compute :relation_count, depends_on: [:relation_manifest] do |relation_manifest:|
        relation_manifest.length
      end

      compute :warnings, depends_on: [:relation_health] do |relation_health:|
        relation_health.fetch(:warnings)
      end

      compute :warning_count, depends_on: [:relation_health] do |relation_health:|
        relation_health.fetch(:warning_count)
      end

      compute :summary, depends_on: %i[status capability_count record_count history_count projection_count relation_count warning_count validation_errors] do |status:, capability_count:, record_count:, history_count:, projection_count:, relation_count:, warning_count:, validation_errors:|
        if status == :ready
          "#{capability_count} capabilities, #{relation_count} relations, #{warning_count} warnings: #{record_count} records, #{history_count} histories, #{projection_count} projections."
        else
          "Persistence blocked: #{Array(validation_errors).join("; ")}"
        end
      end

      output :ready
      output :status
      output :capability_count
      output :record_count
      output :history_count
      output :projection_count
      output :relation_count
      output :warning_count
      output :warnings
      output :summary
    end
  end
end
