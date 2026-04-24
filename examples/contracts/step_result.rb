#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))

require "igniter/contracts"

StepResultProfile = Igniter::Contracts.build_profile(Igniter::Contracts::StepResultPack)

class ValidateQuoteParams
  def self.call(params:)
    return params if params[:market_id]

    Igniter::Contracts::StepResult.failure(
      code: :invalid_params,
      message: "market_id is required",
      details: { missing: [:market_id] }
    )
  end
end

class ResolveQuoteMarket
  def self.call(validated_params:)
    Igniter::Contracts::StepResult.failure(
      code: :market_not_found,
      message: "market was not found",
      details: { market_id: validated_params.fetch(:market_id) }
    )
  end
end

class StepResultQuoteContract < Igniter::Contract
  self.profile = StepResultProfile

  define do
    input :params
    input :clock

    step :validated_params, depends_on: [:params], call: ValidateQuoteParams
    step :market, depends_on: [:validated_params], call: ResolveQuoteMarket

    step :business_window, depends_on: %i[market clock] do |market:, clock:|
      { market: market, checked_at: clock }
    end

    output :business_window
  end
end

contract = StepResultQuoteContract.new(params: { market_id: "north" }, clock: "09:00")
business_window = contract.output(:business_window)
trace = Igniter::Contracts.diagnose(contract.execution_result, profile: StepResultProfile).section(:step_trace)

puts "contracts_step_result_success=#{business_window.success?}"
puts "contracts_step_result_failure_code=#{business_window.failure.fetch(:code)}"
puts "contracts_step_result_halted_dependency=#{business_window.failure.dig(:details, :dependency)}"
puts "contracts_step_result_trace=#{trace.map { |entry| "#{entry.fetch(:name)}:#{entry.fetch(:status)}" }.join(",")}"
