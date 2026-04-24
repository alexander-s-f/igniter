#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-embed/lib", __dir__))

require "igniter/embed"

module Billing
  class PriceContract < Igniter::Contract
    define do
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
  end
end

contracts = Igniter::Embed.configure(:billing) do |config|
  config.cache = true
  config.contract Billing::PriceContract, as: :price_quote
end

inferred_contracts = Igniter::Embed.configure(:billing)
inferred_contracts.register(Billing::PriceContract)

puts "embed_class_explicit_total=#{contracts.call(:price_quote, order_total: 100, country: "UA").output(:gross_total)}"
puts "embed_class_inferred_total=#{inferred_contracts.call(:price, order_total: 150, country: "UA").output(:gross_total)}"
puts "embed_class_registration_kind=#{contracts.registry.to_h.fetch(:price_quote).fetch(:kind)}"
