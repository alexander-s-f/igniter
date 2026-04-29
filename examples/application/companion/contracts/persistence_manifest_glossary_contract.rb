# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :PersistenceManifestGlossaryContract, outputs: %i[status check_count missing_terms checks summary] do
      input :manifest

      compute :checks, depends_on: [:manifest] do |manifest:|
        [
          Companion::Contracts.check(:schema_version, manifest.fetch(:schema_version, nil) == 1),
          Companion::Contracts.check(:record_storage, manifest.fetch(:records, {}).values.all? { |record| record.fetch(:storage, {}).fetch(:shape, nil) == :store }),
          Companion::Contracts.check(:record_aliases, manifest.fetch(:records, {}).values.all? { |record| record.key?(:persist) }),
          Companion::Contracts.check(:history_storage, manifest.fetch(:histories, {}).values.all? { |history| history.fetch(:storage, {}).fetch(:shape, nil) == :history }),
          Companion::Contracts.check(:history_aliases, manifest.fetch(:histories, {}).values.all? { |history| history.key?(:history) }),
          Companion::Contracts.check(:operation_descriptors, Companion::Contracts.operation_descriptors_present?(manifest)),
          Companion::Contracts.check(:relation_descriptors, Companion::Contracts.relation_descriptors_valid?(manifest)),
          Companion::Contracts.check(:projection_reads, manifest.fetch(:projections, {}).values.all? { |projection| projection.key?(:reads) }),
          Companion::Contracts.check(:commands_boundary, Companion::Contracts.command_boundaries_valid?(manifest))
        ]
      end

      compute :missing_terms, depends_on: [:checks] do |checks:|
        checks.reject { |check| check.fetch(:present) }.map { |check| check.fetch(:term) }
      end

      compute :check_count, depends_on: [:checks] do |checks:|
        checks.length
      end

      compute :status, depends_on: [:missing_terms] do |missing_terms:|
        missing_terms.empty? ? :stable : :drift
      end

      compute :summary, depends_on: %i[status check_count missing_terms] do |status:, check_count:, missing_terms:|
        if status == :stable
          "#{check_count} manifest glossary terms stable."
        else
          "Manifest glossary drift: #{missing_terms.join(", ")}."
        end
      end

      output :status
      output :check_count
      output :missing_terms
      output :checks
      output :summary
    end

    def self.check(term, present)
      {
        term: term,
        present: present
      }
    end

    def self.operation_descriptors_present?(manifest)
      record_descriptors = manifest.fetch(:records, {}).values.all? { |record| descriptor_list?(record) }
      history_descriptors = manifest.fetch(:histories, {}).values.all? { |history| descriptor_list?(history) }
      command_descriptors = manifest.fetch(:commands, {}).values.all? { |command| descriptor_list?(command) }

      record_descriptors && history_descriptors && command_descriptors
    end

    def self.descriptor_list?(entry)
      Array(entry.fetch(:operation_descriptors, [])).all? do |descriptor|
        descriptor.key?(:name) &&
          descriptor.key?(:target_shape) &&
          descriptor.key?(:mutates) &&
          descriptor.fetch(:boundary, nil) == :app
      end
    end

    def self.relation_descriptors_valid?(manifest)
      manifest.fetch(:relations, {}).values.all? do |relation|
        descriptor = relation.fetch(:descriptor, {})
        descriptor.fetch(:schema_version, nil) == 1 &&
          descriptor.fetch(:kind, nil) == :relation &&
          descriptor.fetch(:from, {}).key?(:storage_shape) &&
          descriptor.fetch(:to, {}).key?(:storage_shape) &&
          descriptor.fetch(:enforcement, {}).fetch(:mode, nil) == :report_only &&
          descriptor.fetch(:lowering, {}).fetch(:shape, nil) == :relation
      end
    end

    def self.command_boundaries_valid?(manifest)
      manifest.fetch(:commands, {}).values.all? do |command|
        command.fetch(:operation_descriptors, []).all? do |descriptor|
          descriptor.fetch(:boundary, nil) == :app
        end
      end
    end
  end
end
