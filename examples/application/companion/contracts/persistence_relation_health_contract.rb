# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :PersistenceRelationHealthContract, outputs: %i[status relation_count warning_count warnings summary] do
      input :relation_manifest
      input :relation_warnings

      compute :relation_count, depends_on: [:relation_manifest] do |relation_manifest:|
        relation_manifest.length
      end

      compute :warnings, depends_on: [:relation_warnings] do |relation_warnings:|
        Array(relation_warnings)
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
      output :summary
    end
  end
end
