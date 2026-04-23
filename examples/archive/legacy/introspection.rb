# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "igniter"
require "igniter/extensions/introspection"

class IntrospectionQuoteContract < Igniter::Contract
  define do
    input :order_total, type: :numeric
    input :country, type: :string

    compute :subtotal, with: :order_total do |order_total:|
      order_total.round(2)
    end

    scope :taxes do
      compute :vat_rate, with: :country do |country:|
        country == "UA" ? 0.2 : 0.0
      end
    end

    compute :grand_total, with: %i[subtotal vat_rate] do |subtotal:, vat_rate:|
      (subtotal * (1 + vat_rate)).round(2)
    end

    output :grand_total
  end
end

contract = IntrospectionQuoteContract.new(order_total: 100, country: "UA")

puts "=== Graph Text ==="
puts IntrospectionQuoteContract.graph.to_text

puts "\n=== Graph Mermaid ==="
puts IntrospectionQuoteContract.graph.to_mermaid

puts "\n=== Plan ==="
puts contract.explain_plan(:grand_total)

contract.result.grand_total
explanation = contract.execution.explain_output(:grand_total)

puts "\n=== Output Explain ==="
puts "output=#{explanation[:output]}"
puts "source=#{explanation[:source]}"
puts "value=#{explanation.dig(:dependencies, :value)}"
puts "dependencies=#{explanation.dig(:dependencies, :dependencies)&.map { |dependency| dependency[:name] }.join(",")}"
puts "runtime_state=#{contract.result.states.fetch(:grand_total).slice(:status, :value).inspect}"
