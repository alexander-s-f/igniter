#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))

require "igniter/extensions/contracts"

environment = Igniter::Extensions::Contracts.with(
  Igniter::Extensions::Contracts::Language::PiecewisePack
)

result = environment.run(inputs: { training_minutes: 50 }) do
  input :training_minutes

  piecewise :training_score, on: :training_minutes do
    eq 0, id: :none, value: 0
    between 1..45, id: :moderate, value: 10
    between 46..90, id: :heavy, value: 2
    default id: :overload, value: -12
  end

  output :training_score
end

decision = result.state.fetch(:training_score_decision)

puts "contracts_piecewise_score=#{result.output(:training_score)}"
puts "contracts_piecewise_case=#{decision.fetch(:case)}"
puts "contracts_piecewise_matcher=#{decision.fetch(:matcher)}"
