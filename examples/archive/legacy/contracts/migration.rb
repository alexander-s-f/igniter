#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))

require "igniter"
require "igniter/extensions/contracts"

class LegacyPriceContract < Igniter::Contract
  define do
    input :order_total, type: :numeric
    input :country, type: :string

    compute :vat_rate, depends_on: [:country] do |country:|
      country == "UA" ? 0.2 : 0.0
    end

    compute :gross_total, depends_on: %i[order_total vat_rate] do |order_total:, vat_rate:|
      order_total * (1 + vat_rate)
    end

    output :gross_total
  end
end

contracts_environment = Igniter::Contracts.with

compiled = contracts_environment.compile do
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

legacy = LegacyPriceContract.new(order_total: 100, country: "UA")
contracts = contracts_environment.execute(compiled, inputs: { order_total: 100, country: "UA" })
updated_legacy = LegacyPriceContract.new(order_total: 150, country: "UA")
updated_contracts = contracts_environment.execute(compiled, inputs: { order_total: 150, country: "UA" })

puts "legacy_gross_total=#{legacy.result.gross_total}"
puts "contracts_gross_total=#{contracts.output(:gross_total)}"
puts "migration_match=#{legacy.result.gross_total == contracts.output(:gross_total)}"
puts "updated_legacy_gross_total=#{updated_legacy.result.gross_total}"
puts "updated_contracts_gross_total=#{updated_contracts.output(:gross_total)}"
puts "updated_match=#{updated_legacy.result.gross_total == updated_contracts.output(:gross_total)}"
