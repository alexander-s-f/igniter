# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))

require "igniter/extensions/contracts"

produced = []
changed = []
exits = []

environment = Igniter::Contracts.with(
  Igniter::Extensions::Contracts::ReactivePack,
  Igniter::Extensions::Contracts::IncrementalPack
)

reactions = Igniter::Extensions::Contracts.build_reactions do
  effect :gross_total do |value:, **|
    produced << value
  end

  react_to :output_changed, path: :gross_total do |event:, **|
    changed << event.payload.slice(:previous_value, :current_value)
  end

  on_exit do |status:, **|
    exits << status
  end
end

session = Igniter::Extensions::Contracts.build_incremental_session(environment) do
  input :order_total
  input :country

  compute :vat_rate, depends_on: [:country] do |country:|
    country == "UA" ? 0.2 : 0.0
  end

  compute :gross_total, depends_on: %i[order_total vat_rate] do |order_total:, vat_rate:|
    (order_total * (1 + vat_rate)).round(2)
  end

  output :gross_total
end

Igniter::Extensions::Contracts.run_incremental_reactive(
  session,
  inputs: { order_total: 100, country: "UA" },
  reactions: reactions
)

dispatch = Igniter::Extensions::Contracts.run_incremental_reactive(
  session,
  inputs: { order_total: 150, country: "UA" },
  reactions: reactions
)

puts "contracts_reactive_status=#{dispatch.status}"
puts "contracts_reactive_produced=#{produced.inspect}"
puts "contracts_reactive_changed=#{changed.inspect}"
puts "contracts_reactive_event_types=#{dispatch.events.map(&:type).uniq.inspect}"
puts "contracts_reactive_exits=#{exits.inspect}"
