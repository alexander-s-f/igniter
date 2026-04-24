#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))

require "igniter/contracts"

class ClassPricingContract < Igniter::Contract
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

contract = ClassPricingContract.new(order_total: 100, country: "UA")
puts "contracts_class_gross_total=#{contract.result.gross_total}"
puts "contracts_class_output=#{contract.output(:gross_total)}"

contract.update_inputs(order_total: 150)
puts "contracts_class_updated_gross_total=#{contract.result.gross_total}"
puts "contracts_class_success=#{contract.success?}"
