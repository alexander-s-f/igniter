# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :SetupHandoffNextScopeHealthContract, outputs: %i[status check_count descriptor missing_terms checks summary] do
      input :setup_handoff_next_scope

      compute :descriptor, depends_on: [:setup_handoff_next_scope] do |setup_handoff_next_scope:|
        {
          schema_version: 1,
          kind: :setup_handoff_next_scope_health,
          report_only: true,
          gates_runtime: false,
          grants_capabilities: false,
          validates: setup_handoff_next_scope.fetch(:descriptor).fetch(:kind)
        }
      end

      compute :checks, depends_on: [:setup_handoff_next_scope] do |setup_handoff_next_scope:|
        descriptor = setup_handoff_next_scope.fetch(:descriptor)
        recommended = setup_handoff_next_scope.fetch(:recommended)
        candidate_names = setup_handoff_next_scope.fetch(:candidates).map { |candidate| candidate.fetch(:name) }
        candidate_endpoints = setup_handoff_next_scope.fetch(:candidates).map { |candidate| candidate.fetch(:endpoint) }
        forbidden = setup_handoff_next_scope.fetch(:forbidden)
        acceptance = setup_handoff_next_scope.fetch(:acceptance_criteria)
        mutation_paths = setup_handoff_next_scope.fetch(:mutation_paths)

        [
          Companion::Contracts.check(:schema_version, descriptor.fetch(:schema_version, nil) == 1),
          Companion::Contracts.check(:kind, descriptor.fetch(:kind, nil) == :setup_handoff_next_scope),
          Companion::Contracts.check(:report_only, descriptor.fetch(:report_only, nil) == true),
          Companion::Contracts.check(:no_runtime_gate, descriptor.fetch(:gates_runtime, nil) == false),
          Companion::Contracts.check(:no_capability_grants, descriptor.fetch(:grants_capabilities, nil) == false),
          Companion::Contracts.check(:recommended_candidate, candidate_names.include?(recommended)),
          Companion::Contracts.check(:candidate_endpoints_scoped, candidate_endpoints.all? { |endpoint| endpoint.start_with?("POST /setup/", "/setup/") }),
          Companion::Contracts.check(:forbidden_materializer_execution, forbidden.include?(:materializer_execution)),
          Companion::Contracts.check(:forbidden_approval_grants, forbidden.include?(:approval_capability_grants)),
          Companion::Contracts.check(:forbidden_public_api_promotion, forbidden.include?(:public_api_promotion)),
          Companion::Contracts.check(:forbidden_relation_enforcement, forbidden.include?(:relation_enforcement)),
          Companion::Contracts.check(:explicit_mutation_paths, mutation_paths.all? { |path| path.start_with?("POST /setup/") }),
          Companion::Contracts.check(:acceptance_matches_recommended, acceptance.fetch(:recommended) == recommended),
          Companion::Contracts.check(:non_goals_block_capability_grants, acceptance.fetch(:non_goals).include?(:approval_capability_grants)),
          Companion::Contracts.check(:next_action, %i[record_blocked_attempt record_approval_receipt review_materializer_status].include?(setup_handoff_next_scope.fetch(:next_action)))
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
          "#{check_count} setup handoff next-scope terms stable."
        else
          "Setup handoff next-scope drift: #{missing_terms.join(", ")}."
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
