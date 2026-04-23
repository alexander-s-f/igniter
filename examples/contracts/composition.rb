#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))

require "igniter/extensions/contracts"

environment = Igniter::Contracts.with(Igniter::Extensions::Contracts::ComposePack)

pricing_contract = environment.compile do
  input :amount
  input :tax_rate

  compute :tax, depends_on: %i[amount tax_rate] do |amount:, tax_rate:|
    amount * tax_rate
  end

  compute :total, depends_on: %i[amount tax] do |amount:, tax:|
    amount + tax
  end

  output :tax
  output :total
end

result = environment.run(inputs: { subtotal: 100, rate: 0.2 }) do
  input :subtotal
  input :rate

  compose :pricing, contract: pricing_contract, inputs: {
    amount: :subtotal,
    tax_rate: :rate
  }

  compose :pricing_total, inputs: {
    amount: :subtotal,
    tax_rate: :rate
  }, output: :total do
    input :amount
    input :tax_rate

    compute :tax, depends_on: %i[amount tax_rate] do |amount:, tax_rate:|
      amount * tax_rate
    end

    compute :total, depends_on: %i[amount tax] do |amount:, tax:|
      amount + tax
    end

    output :total
  end

  output :pricing
  output :pricing_total
end

puts "contracts_compose_tax=#{result.output(:pricing).output(:tax)}"
puts "contracts_compose_total=#{result.output(:pricing_total)}"
puts "contracts_compose_nested_outputs=#{result.output(:pricing).outputs.keys.sort.join(",")}"
