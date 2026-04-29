# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :PersistenceRelationHealthContract, outputs: %i[status relation_count warning_count warnings relation_reports summary] do
      input :relation_manifest
      input :relation_warnings

      compute :relation_count, depends_on: [:relation_manifest] do |relation_manifest:|
        relation_manifest.length
      end

      compute :relation_reports, depends_on: %i[relation_manifest relation_warnings] do |relation_manifest:, relation_warnings:|
        relation_manifest.keys.to_h do |name|
          warnings = Array(relation_warnings.fetch(name, []))
          [
            name,
            {
              status: warnings.empty? ? :clear : :warning,
              warning_count: warnings.length,
              warnings: warnings
            }
          ]
        end
      end

      compute :warnings, depends_on: [:relation_reports] do |relation_reports:|
        relation_reports.flat_map do |name, report|
          report.fetch(:warnings).map { |warning| "#{name}: #{warning}" }
        end
      end

      compute :warning_count, depends_on: [:warnings] do |warnings:|
        warnings.length
      end

      compute :status, depends_on: [:warning_count] do |warning_count:|
        warning_count.zero? ? :clear : :warning
      end

      compute :summary, depends_on: %i[status relation_count warning_count] do |status:, relation_count:, warning_count:|
        if status == :clear
          "#{relation_count} relations clear."
        else
          "#{relation_count} relations with #{warning_count} warnings."
        end
      end

      output :status
      output :relation_count
      output :warning_count
      output :warnings
      output :relation_reports
      output :summary
    end
  end
end
