# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :SetupHandoffNextScopeContract,
              outputs: %i[status descriptor recommended candidates forbidden acceptance_criteria mutation_paths next_action summary] do
      input :setup_handoff
      input :setup_handoff_lifecycle

      compute :descriptor do
        {
          schema_version: 1,
          kind: :setup_handoff_next_scope,
          report_only: true,
          gates_runtime: false,
          grants_capabilities: false,
          role: :supervised_next_scope
        }
      end

      compute :status, depends_on: [:setup_handoff_lifecycle] do |setup_handoff_lifecycle:|
        setup_handoff_lifecycle.fetch(:status) == :complete ? :complete : :pending
      end

      compute :recommended, depends_on: [:setup_handoff] do |setup_handoff:|
        setup_handoff.fetch(:next_scope).fetch(:recommended)
      end

      compute :candidates, depends_on: [:setup_handoff] do |setup_handoff:|
        setup_handoff.fetch(:next_scope).fetch(:candidates)
      end

      compute :forbidden, depends_on: [:setup_handoff] do |setup_handoff:|
        setup_handoff.fetch(:next_scope).fetch(:forbidden)
      end

      compute :acceptance_criteria, depends_on: [:setup_handoff] do |setup_handoff:|
        setup_handoff.fetch(:acceptance_criteria)
      end

      compute :mutation_paths, depends_on: [:acceptance_criteria] do |acceptance_criteria:|
        [
          acceptance_criteria.fetch(:checks).find { |check| check.fetch(:term) == :explicit_post_only }.fetch(:expected),
          acceptance_criteria.fetch(:follow_up).fetch(:endpoint)
        ]
      end

      compute :next_action, depends_on: [:setup_handoff_lifecycle] do |setup_handoff_lifecycle:|
        setup_handoff_lifecycle.fetch(:next_action)
      end

      compute :summary, depends_on: %i[status recommended next_action forbidden] do |status:, recommended:, next_action:, forbidden:|
        "#{status}: recommended=#{recommended}, next=#{next_action}, forbidden=#{forbidden.length}, report-only."
      end

      output :status
      output :descriptor
      output :recommended
      output :candidates
      output :forbidden
      output :acceptance_criteria
      output :mutation_paths
      output :next_action
      output :summary
    end
  end
end
