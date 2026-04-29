# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :MaterializerGateContract,
              outputs: %i[status requested_capabilities approved_capabilities blocked_capabilities reasons summary] do
      input :infrastructure_loop_health
      input :materialization_plan
      input :approved

      compute :requested_capabilities, depends_on: [:materialization_plan] do |materialization_plan:|
        materialization_plan.fetch(:required_capabilities)
      end

      compute :reasons, depends_on: %i[infrastructure_loop_health approved] do |infrastructure_loop_health:, approved:|
        reasons = []
        reasons << :loop_not_self_supporting unless infrastructure_loop_health.fetch(:status) == :self_supporting
        reasons << :human_approval_required unless approved
        reasons
      end

      compute :status, depends_on: [:reasons] do |reasons:|
        reasons.empty? ? :ready_to_request_capabilities : :blocked
      end

      compute :approved_capabilities, depends_on: %i[status requested_capabilities] do |status:, requested_capabilities:|
        status == :ready_to_request_capabilities ? requested_capabilities : []
      end

      compute :blocked_capabilities, depends_on: %i[status requested_capabilities] do |status:, requested_capabilities:|
        status == :ready_to_request_capabilities ? [] : requested_capabilities
      end

      compute :summary, depends_on: %i[status requested_capabilities reasons] do |status:, requested_capabilities:, reasons:|
        if status == :ready_to_request_capabilities
          "Materializer may request #{requested_capabilities.join(",")} capabilities."
        else
          "Materializer blocked from #{requested_capabilities.join(",")} capabilities: #{reasons.join(",")}."
        end
      end

      output :status
      output :requested_capabilities
      output :approved_capabilities
      output :blocked_capabilities
      output :reasons
      output :summary
    end
  end
end
