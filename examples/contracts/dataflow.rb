# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))

require "igniter/extensions/contracts"

environment = Igniter::Extensions::Contracts.with(
  Igniter::Extensions::Contracts::DataflowPack,
  Igniter::Extensions::Contracts::IncrementalPack
)

session = Igniter::Extensions::Contracts.build_dataflow_session(
  environment,
  source: :readings,
  key: :sensor_id,
  window: { last: 3 }
) do
  item do
    input :sensor_id
    input :value
    input :zone

    compute :status, depends_on: [:value] do |value:|
      value > 50 ? :critical : :normal
    end

    output :status
    output :value
    output :zone
  end

  count :total
  count :alerts, matching: ->(item) { item.output(:status) == :critical }
  sum :total_value, using: :value
  group_count :by_zone, using: :zone
end

round1 = session.run(inputs: {
                       readings: [
                         { sensor_id: "s1", value: 10, zone: "north" },
                         { sensor_id: "s2", value: 70, zone: "north" },
                         { sensor_id: "s3", value: 90, zone: "south" }
                       ]
                     })

round2 = session.feed_diff(
  update: [{ sensor_id: "s2", value: 40, zone: "north" }],
  add: [{ sensor_id: "s4", value: 95, zone: "east" }]
)

puts "contracts_dataflow_round1=#{round1.diff.explain}"
puts "contracts_dataflow_round2=#{round2.diff.explain}"
puts "contracts_dataflow_total=#{round2.total}"
puts "contracts_dataflow_alerts=#{round2.alerts}"
puts "contracts_dataflow_window_keys=#{round2.processed.keys.join(",")}"
puts "contracts_dataflow_by_zone=#{round2.by_zone.inspect}"
