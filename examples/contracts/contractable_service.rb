#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))

require "igniter/contracts"

class BodyBatteryScorer
  include Igniter::Contracts::Contractable

  contractable :call do
    input :sleep_hours
    input :training_minutes
    output :score
  end

  def call(sleep_hours:, training_minutes:)
    sleep_score = observe(:sleep_score) do
      [[sleep_hours / 8.0, 1.0].min * 40, 0].max
    end
    training_score = observe(:training_score) do
      training_minutes <= 45 ? 10 : 2
    end

    success(score: [[45 + sleep_score + training_score, 100].min, 0].max.round)
  end
end

result = Igniter::Contracts.with.run(inputs: { sleep_hours: 7.5, training_minutes: 30 }) do
  input :sleep_hours
  input :training_minutes
  compute :body_battery, depends_on: %i[sleep_hours training_minutes], using: BodyBatteryScorer
  output :body_battery
end

payload = result.output(:body_battery)

puts "contracts_contractable_service_success=#{payload.fetch(:success)}"
puts "contracts_contractable_service_score=#{payload.fetch(:outputs).fetch(:score)}"
puts "contracts_contractable_service_observations=#{payload.fetch(:observations).map { |entry| entry.fetch(:name) }.join(",")}"
