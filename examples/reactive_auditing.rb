# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "igniter"
require "igniter/extensions/auditing"
require "igniter/extensions/reactive"

EFFECT_VALUES = []
INVALIDATIONS = []

class ReactiveAuditQuoteContract < Igniter::Contract
  define do
    input :order_total, type: :numeric
    input :country, type: :string

    compute :vat_rate, with: :country do |country:|
      country == "UA" ? 0.2 : 0.0
    end

    compute :gross_total, with: %i[order_total vat_rate] do |order_total:, vat_rate:|
      (order_total * (1 + vat_rate)).round(2)
    end

    expose :gross_total, as: :response
  end

  react_to :node_invalidated, path: "gross_total" do |event:, **|
    INVALIDATIONS << event.payload[:cause]
  end

  effect "gross_total" do |value:, **|
    EFFECT_VALUES << value
  end
end

contract = ReactiveAuditQuoteContract.new(order_total: 100, country: "UA")

puts "first_response=#{contract.result.response}"

contract.update_inputs(order_total: 150)
puts "second_response=#{contract.result.response}"

snapshot = contract.audit_snapshot
event_types = snapshot[:events].map { |event| event[:type] }.uniq

puts "effect_values=#{EFFECT_VALUES.inspect}"
puts "invalidations=#{INVALIDATIONS.inspect}"
puts "event_types=#{event_types.inspect}"
puts "gross_total_state=#{snapshot[:states][:gross_total].slice(:status, :value).inspect}"
puts "event_count=#{snapshot[:event_count]}"
