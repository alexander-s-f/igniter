# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :MaterializerRunbookContract, outputs: %i[status steps blocked_capabilities approval_request summary] do
      input :materializer_preflight

      compute :status, depends_on: [:materializer_preflight] do |materializer_preflight:|
        materializer_preflight.fetch(:status)
      end

      compute :blocked_capabilities, depends_on: [:materializer_preflight] do |materializer_preflight:|
        materializer_preflight.fetch(:evidence).fetch(:blocked_capabilities)
      end

      compute :approval_request, depends_on: [:materializer_preflight] do |materializer_preflight:|
        materializer_preflight.fetch(:approval_request)
      end

      compute :steps, depends_on: %i[status blocked_capabilities approval_request] do |status:, blocked_capabilities:, approval_request:|
        [
          {
            name: :write_static_contracts,
            capability: :write,
            intent: :materialize_contract_files
          },
          {
            name: :run_focused_tests,
            capability: :test,
            intent: :verify_materialized_contracts
          },
          {
            name: :record_git_change,
            capability: :git,
            intent: :commit_reviewable_delta
          },
          {
            name: :restart_app,
            capability: :restart,
            intent: :reload_materialized_app
          }
        ].each_with_index.map do |step, index|
          blocked = blocked_capabilities.include?(step.fetch(:capability))
          step.merge(
            position: index + 1,
            status: blocked ? :blocked : status,
            reasons: blocked ? approval_request.fetch(:reasons) : [],
            review_only: true
          )
        end
      end

      compute :summary, depends_on: %i[status steps] do |status:, steps:|
        blocked_count = steps.count { |step| step.fetch(:status) == :blocked }
        "#{status}: #{blocked_count} materializer runbook steps remain review-only."
      end

      output :status
      output :steps
      output :blocked_capabilities
      output :approval_request
      output :summary
    end
  end
end
