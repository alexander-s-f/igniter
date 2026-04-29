# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :SetupHandoffLifecycleHealthContract, outputs: %i[status check_count descriptor missing_terms checks summary] do
      input :setup_handoff_lifecycle

      compute :descriptor, depends_on: [:setup_handoff_lifecycle] do |setup_handoff_lifecycle:|
        {
          schema_version: 1,
          kind: :setup_handoff_lifecycle_health,
          report_only: true,
          gates_runtime: false,
          grants_capabilities: false,
          validates: setup_handoff_lifecycle.fetch(:descriptor).fetch(:kind)
        }
      end

      compute :checks, depends_on: [:setup_handoff_lifecycle] do |setup_handoff_lifecycle:|
        lifecycle_descriptor = setup_handoff_lifecycle.fetch(:descriptor)
        stages = setup_handoff_lifecycle.fetch(:stages)
        stage_names = stages.map { |stage| stage.fetch(:name) }
        mutations = stages.map { |stage| stage.fetch(:mutation) }.compact

        [
          Companion::Contracts.check(:schema_version, lifecycle_descriptor.fetch(:schema_version, nil) == 1),
          Companion::Contracts.check(:kind, lifecycle_descriptor.fetch(:kind, nil) == :setup_handoff_lifecycle),
          Companion::Contracts.check(:report_only, lifecycle_descriptor.fetch(:report_only, nil) == true),
          Companion::Contracts.check(:no_runtime_gate, lifecycle_descriptor.fetch(:gates_runtime, nil) == false),
          Companion::Contracts.check(:no_capability_grants, lifecycle_descriptor.fetch(:grants_capabilities, nil) == false),
          Companion::Contracts.check(:source_packets, lifecycle_descriptor.fetch(:sources, []).include?(:setup_handoff_acceptance) && lifecycle_descriptor.fetch(:sources, []).include?(:setup_handoff_approval_acceptance)),
          Companion::Contracts.check(:stage_order, stage_names == %i[handoff_ready attempt_receipt approval_receipt]),
          Companion::Contracts.check(:explicit_mutations, mutations.all? { |mutation| mutation.start_with?("POST /setup/handoff/") }),
          Companion::Contracts.check(:read_views, stages.all? { |stage| stage.fetch(:view).start_with?("/setup/handoff") }),
          Companion::Contracts.check(:current_stage, (stage_names + [:complete]).include?(setup_handoff_lifecycle.fetch(:current_stage))),
          Companion::Contracts.check(:next_action, %i[record_blocked_attempt record_approval_receipt review_materializer_status review_setup_health_items].include?(setup_handoff_lifecycle.fetch(:next_action)))
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
          "#{check_count} setup handoff lifecycle terms stable."
        else
          "Setup handoff lifecycle drift: #{missing_terms.join(", ")}."
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
