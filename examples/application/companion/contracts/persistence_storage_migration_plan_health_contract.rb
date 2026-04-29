# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :PersistenceStorageMigrationPlanHealthContract, outputs: %i[status check_count descriptor missing_terms checks summary] do
      input :storage_migration_plan

      compute :descriptor, depends_on: [:storage_migration_plan] do |storage_migration_plan:|
        {
          schema_version: 1,
          kind: :persistence_storage_migration_plan_health,
          report_only: true,
          gates_runtime: false,
          grants_capabilities: false,
          validates: storage_migration_plan.fetch(:descriptor).fetch(:kind)
        }
      end

      compute :checks, depends_on: [:storage_migration_plan] do |storage_migration_plan:|
        descriptor = storage_migration_plan.fetch(:descriptor)
        reports = storage_migration_plan.fetch(:reports)
        candidates = reports.flat_map { |report| report.fetch(:candidates) }

        [
          Companion::Contracts.check(:schema_version, storage_migration_plan.fetch(:schema_version, nil) == 1),
          Companion::Contracts.check(:kind, descriptor.fetch(:kind, nil) == :persistence_storage_migration_plan),
          Companion::Contracts.check(:report_only, descriptor.fetch(:report_only, nil) == true),
          Companion::Contracts.check(:no_runtime_gate, descriptor.fetch(:gates_runtime, nil) == false),
          Companion::Contracts.check(:no_capability_grants, descriptor.fetch(:grants_capabilities, nil) == false),
          Companion::Contracts.check(:no_migration_execution, descriptor.fetch(:migration_execution_allowed, nil) == false),
          Companion::Contracts.check(:no_sql_generation, descriptor.fetch(:sql_generation_allowed, nil) == false),
          Companion::Contracts.check(:source_storage_plan, descriptor.fetch(:source, nil) == :persistence_storage_plan_sketch),
          Companion::Contracts.check(:report_status_vocab, reports.all? { |report| %i[stable additive destructive ambiguous].include?(report.fetch(:status)) }),
          Companion::Contracts.check(:report_shapes, reports.all? { |report| %i[record history].include?(report.fetch(:shape)) }),
          Companion::Contracts.check(:candidate_count, storage_migration_plan.fetch(:candidate_count) == candidates.length),
          Companion::Contracts.check(:review_only_candidates, candidates.all? { |candidate| candidate.fetch(:review_only) == true }),
          Companion::Contracts.check(:candidate_no_execution, candidates.all? { |candidate| candidate.fetch(:migration_execution_allowed) == false }),
          Companion::Contracts.check(:candidate_no_sql_generation, candidates.all? { |candidate| candidate.fetch(:sql_generation_allowed) == false }),
          Companion::Contracts.check(:candidate_kind_vocab, candidates.all? { |candidate| %i[additive destructive ambiguous].include?(candidate.fetch(:kind)) })
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
          "#{check_count} persistence storage migration plan terms stable."
        else
          "Persistence storage migration plan drift: #{missing_terms.join(", ")}."
        end
      end

      output :status
      output :check_count
      output :descriptor
      output :missing_terms
      output :checks
      output :summary
    end
  end
end
