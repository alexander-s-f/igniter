#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))

require "igniter/extensions/contracts"

environment = Igniter::Contracts.with(
  Igniter::Contracts::ProjectPack,
  Igniter::Extensions::Contracts::BranchPack
)

result = environment.run(inputs: { country: "DE", vip: true }) do
  input :country
  input :vip

  branch :delivery_strategy, on: :country, depends_on: [:vip] do
    on "UA", id: :local, value: :local
    on in: %w[CA MX], id: :regional, value: :regional
    on matches: /\A[A-Z]{2}\z/, id: :international do |vip:|
      vip ? :priority_international : :international
    end
    default value: :fallback
  end

  project :delivery_mode, from: :delivery_strategy, key: :value
  project :selected_case, from: :delivery_strategy, key: :case

  output :delivery_mode
  output :selected_case
end

puts "contracts_branch_case=#{result.output(:selected_case)}"
puts "contracts_branch_value=#{result.output(:delivery_mode)}"
puts "contracts_branch_matcher=#{result.state.fetch(:delivery_strategy).fetch(:matcher)}"
