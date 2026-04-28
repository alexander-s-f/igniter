#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))

require "igniter/extensions/contracts"

environment = Igniter::Extensions::Contracts.with(
  Igniter::Extensions::Contracts::Language::FormulaPack
)

result = environment.run(inputs: { sleep_score: 38, training_score: 10 }) do
  input :sleep_score
  input :training_score

  formula :body_score do
    base 45
    add :sleep_score
    add :training_score
    clamp 0, 100
    round
  end

  output :body_score
end

trace = result.state.fetch(:body_score_trace)

puts "contracts_formula_score=#{result.output(:body_score)}"
puts "contracts_formula_steps=#{trace.fetch(:steps).length}"
puts "contracts_formula_dependencies=#{trace.fetch(:dependencies).join(",")}"
