# frozen_string_literal: true

# Order Pipeline — guard + collection + branch + export
#
# Flow:
#   1. guard      — require in_stock == true before proceeding
#   2. collection — compute subtotal per line item (LineItemContract per item)
#   3. compute    — aggregate item subtotals into order_subtotal
#   4. branch     — choose domestic or international shipping strategy
#   5. export     — pull shipping_cost and eta out of the selected branch
#   6. output     — order_subtotal, shipping_cost, eta, grand_total
#
# Run: ruby examples/order_pipeline.rb

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "igniter"

# ── Line Item ────────────────────────────────────────────────────────────────

class LineItemContract < Igniter::Contract
  define do
    input :sku,        type: :string
    input :quantity,   type: :numeric
    input :unit_price, type: :numeric

    compute :subtotal, depends_on: %i[quantity unit_price] do |quantity:, unit_price:|
      (quantity * unit_price).round(2)
    end

    output :sku
    output :subtotal
  end
end

# ── Shipping Strategies ──────────────────────────────────────────────────────

class DomesticShippingContract < Igniter::Contract
  define do
    input :country,  type: :string
    input :subtotal, type: :numeric

    compute :shipping_cost, depends_on: :subtotal do |subtotal:|
      subtotal >= 100 ? 0.0 : 9.99
    end

    compute :eta, depends_on: :country do |country:|
      country == "US" ? "2-3 business days" : "3-5 business days"
    end

    output :shipping_cost
    output :eta
  end
end

class InternationalShippingContract < Igniter::Contract
  define do
    input :country,  type: :string
    input :subtotal, type: :numeric

    compute :shipping_cost, depends_on: :subtotal do |subtotal:|
      (subtotal * 0.15).round(2)
    end

    compute :eta, depends_on: :country do |**|
      "7-14 business days"
    end

    output :shipping_cost
    output :eta
  end
end

# ── Order Pipeline ────────────────────────────────────────────────────────────

class OrderPipelineContract < Igniter::Contract
  define do # rubocop:disable Metrics/BlockLength
    input :line_items, type: :array
    input :country,    type: :string
    input :in_stock,   type: :boolean

    # Guard fires before anything else is computed
    guard :stock_available,
          with: :in_stock,
          eq: true,
          message: "Order cannot be placed: items are out of stock"

    # Gate node: depends on the guard — if guard fails, this node fails too,
    # which blocks the collection and all downstream nodes from running.
    compute :gated_items, depends_on: %i[line_items stock_available] do |line_items:, **|
      line_items
    end

    # Fan-out: one LineItemContract per item hash
    collection :items,
               with: :gated_items,
               each: LineItemContract,
               key: :sku,
               mode: :collect

    # Sum succeeded item subtotals
    compute :order_subtotal, depends_on: :items do |items:|
      items.successes.values.sum { |item| item.result.subtotal }.round(2)
    end

    # Route to the right shipping strategy based on country
    branch :shipping,
           with: :country,
           inputs: { country: :country, subtotal: :order_subtotal } do
      on "US", contract: DomesticShippingContract
      on "CA", contract: DomesticShippingContract
      default contract: InternationalShippingContract
    end

    # Lift shipping outputs up to the top-level graph
    # export calls output internally, so no separate output declarations needed
    export :shipping_cost, :eta, from: :shipping

    compute :grand_total, depends_on: %i[order_subtotal shipping_cost] do |order_subtotal:, shipping_cost:|
      (order_subtotal + shipping_cost).round(2)
    end

    output :items
    output :order_subtotal
    output :grand_total
  end
end

# ── Run ───────────────────────────────────────────────────────────────────────

line_items = [
  { sku: "ruby-book",    quantity: 2, unit_price: 29.99 },
  { sku: "rails-course", quantity: 1, unit_price: 49.99 },
  { sku: "keyboard",     quantity: 1, unit_price: 89.99 }
]

# US order — free shipping over $100
us_order = OrderPipelineContract.new(line_items: line_items, country: "US", in_stock: true)
us_order.resolve_all

puts "=== US Order ==="
puts "items_summary=#{us_order.result.items.summary.inspect}"
puts "order_subtotal=#{us_order.result.order_subtotal}"
puts "shipping_cost=#{us_order.result.shipping_cost}"
puts "eta=#{us_order.result.eta}"
puts "grand_total=#{us_order.result.grand_total}"

# International order — 15% shipping
intl_order = OrderPipelineContract.new(line_items: line_items, country: "DE", in_stock: true)
intl_order.resolve_all

puts "\n=== International Order (DE) ==="
puts "shipping_cost=#{intl_order.result.shipping_cost}"
puts "eta=#{intl_order.result.eta}"
puts "grand_total=#{intl_order.result.grand_total}"

# Out of stock — guard fires and raises ResolutionError
oos_order = OrderPipelineContract.new(line_items: line_items, country: "US", in_stock: false)
begin
  oos_order.resolve_all
rescue Igniter::ResolutionError => e
  puts "\n=== Out of Stock ==="
  puts "error=#{e.message.split(" [").first}"
end
