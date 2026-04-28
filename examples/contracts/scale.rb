#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))

require "igniter/extensions/contracts"

environment = Igniter::Extensions::Contracts.with(
  Igniter::Extensions::Contracts::Language::ScalePack
)

result = environment.run(inputs: { sleep_hours: 7.5 }) do
  input :sleep_hours

  scale :sleep_score, from: :sleep_hours do
    divide_by 8
    clamp 0, 1
    multiply_by 40
    round
  end

  output :sleep_score
end

trace = result.state.fetch(:sleep_score_trace)

puts "contracts_scale_score=#{result.output(:sleep_score)}"
puts "contracts_scale_steps=#{trace.fetch(:steps).length}"
puts "contracts_scale_last=#{trace.fetch(:steps).last.fetch(:operation)}"
