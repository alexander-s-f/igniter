# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "igniter"

class PriceContract < Igniter::Contract
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

class CheckoutContract < Igniter::Contract
  define do
    input :order_total, type: :numeric
    input :country, type: :string

    compose :pricing, contract: PriceContract, inputs: {
      order_total: :order_total,
      country: :country
    }

    output :pricing
  end
end

contract = CheckoutContract.new(order_total: 100, country: "UA")

puts "pricing=#{contract.result.to_h.inspect}"
