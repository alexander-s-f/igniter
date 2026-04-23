# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "igniter"

OUTBOX = []

class MarketingQuoteContract < Igniter::Contract
  define do
    input :service, type: :string
    input :zip_code, type: :string

    const :vendor_id, "eLocal"

    scope :routing do
      map :trade_name, from: :service do |service:|
        %w[heating cooling ventilation air_conditioning].include?(service.downcase) ? "HVAC" : service
      end
    end

    scope :pricing do
      lookup :trade, with: :trade_name do |trade_name:|
        { name: trade_name, base_bid: trade_name == "HVAC" ? 45.0 : 25.0 }
      end
    end

    namespace :validation do
      guard :zip_supported, with: :zip_code, in: %w[60601 10001], message: "Unsupported zip"
    end

    compute :quote, with: %i[vendor_id trade zip_supported zip_code] do |vendor_id:, trade:, zip_supported:, zip_code:|
      zip_supported
      {
        vendor_id: vendor_id,
        trade: trade[:name],
        zip_code: zip_code,
        bid: trade[:base_bid]
      }
    end

    expose :quote, as: :response
  end

  on_success :response do |value:, **|
    OUTBOX << {
      vendor_id: value[:vendor_id],
      zip_code: value[:zip_code]
    }
  end
end

contract = MarketingQuoteContract.new(service: "heating", zip_code: "60601")

puts contract.explain_plan
puts "---"
puts "response=#{contract.result.response.inspect}"
puts "outbox=#{OUTBOX.inspect}"
