#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))

require "igniter/contracts"

environment = Igniter::Contracts.with

compiled = environment.compile do
  input :order_total
  input :country

  compute :vat_rate, depends_on: [:country] do |country:|
    country == "UA" ? 0.2 : 0.0
  end

  compute :gross_total, depends_on: %i[order_total vat_rate] do |order_total:, vat_rate:|
    order_total * (1 + vat_rate)
  end

  output :gross_total
end

first_result = environment.execute(compiled, inputs: { order_total: 100, country: "UA" })
updated_result = environment.execute(compiled, inputs: { order_total: 150, country: "UA" })

puts "contracts_basic_gross_total=#{first_result.output(:gross_total)}"
puts "contracts_basic_updated_gross_total=#{updated_result.output(:gross_total)}"
puts "contracts_basic_profile=#{environment.profile.pack_names.join(',')}"
