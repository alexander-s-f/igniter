# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "igniter"

OUTBOX = []

class MarketingQuoteContract < Igniter::Contract
  define do
    input :service, type: :string
    input :zip_code, type: :string

    const :vendor_id, "eLocal"

    map :trade_name, from: :service do |service:|
      %w[heating cooling ventilation air_conditioning].include?(service.downcase) ? "HVAC" : service
    end

    lookup :trade, depends_on: [:trade_name] do |trade_name:|
      { name: trade_name, base_bid: trade_name == "HVAC" ? 45.0 : 25.0 }
    end

    guard :zip_supported, depends_on: [:zip_code], message: "Unsupported zip" do |zip_code:|
      %w[60601 10001].include?(zip_code)
    end

    compute :quote, depends_on: %i[vendor_id trade zip_supported zip_code] do |vendor_id:, trade:, zip_supported:, zip_code:|
      zip_supported
      {
        vendor_id: vendor_id,
        trade: trade[:name],
        zip_code: zip_code,
        bid: trade[:base_bid]
      }
    end

    output :quote
  end

  effect "quote" do |contract:, **|
    OUTBOX << {
      vendor_id: contract.result.quote[:vendor_id],
      zip_code: contract.result.quote[:zip_code]
    }
  end
end

contract = MarketingQuoteContract.new(service: "heating", zip_code: "60601")

puts contract.explain_plan
puts "---"
puts "quote=#{contract.result.quote.inspect}"
puts "outbox=#{OUTBOX.inspect}"
