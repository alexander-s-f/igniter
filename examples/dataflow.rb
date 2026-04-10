# frozen_string_literal: true

# examples/dataflow.rb
#
# Demonstrates Igniter's incremental dataflow: mode: :incremental on a collection
# node means only added/changed items have their child contract re-run.
# Removed items are retracted automatically.
#
# Typical use-cases:
#   • IoT sensor streams   — thousands of sensors, updates arrive as diffs
#   • Live analytics       — sliding-window aggregates with O(change) compute
#   • Event-driven systems — process only the delta, not the full dataset
#
# Run with: bundle exec ruby examples/dataflow.rb

require_relative "../lib/igniter"
require_relative "../lib/igniter/extensions/dataflow"

# ─── Child contract: process a single sensor reading ──────────────────────────
#
# Receives one sensor payload and classifies its value.
#
class SensorAnalysis < Igniter::Contract
  define do
    input :sensor_id
    input :value, type: :numeric
    input :unit

    compute :status, depends_on: :value do |value:|
      case value
      when (..0)    then :error
      when (0..25)  then :normal
      when (26..75) then :warning
      else               :critical
      end
    end

    compute :label, depends_on: %i[sensor_id status] do |sensor_id:, status:|
      "[#{sensor_id}] #{status.upcase}"
    end

    output :status
    output :label
  end
end

# ─── Pipeline contract: fan-out across all sensor readings ────────────────────
#
# readings ──→ processed (incremental collection)
#
# window: { last: 5 } keeps only the 5 most-recent readings in the window so
# memory footprint stays bounded even for long-running streams.
#
class SensorPipeline < Igniter::Contract
  define do
    input :readings, type: :array

    collection :processed,
               with: :readings,
               each: SensorAnalysis,
               key: :sensor_id,
               mode: :incremental,
               window: { last: 5 }

    output :processed
  end
end

# ─── Helpers ──────────────────────────────────────────────────────────────────

def print_diff(label, diff)
  puts "\n#{label}"
  puts "  added:     #{diff.added.inspect}"
  puts "  changed:   #{diff.changed.inspect}"
  puts "  removed:   #{diff.removed.inspect}"
  puts "  unchanged: #{diff.unchanged.inspect}"
  puts "  processed: #{diff.processed_count} child contract(s) re-run"
end

def print_results(processed)
  processed.successes.each_value do |item|
    puts "  #{item.result.label}"
  end
end

# ──────────────────────────────────────────────────────────────────────────────
# 1. Initial batch — 4 sensors, all treated as :added
# ──────────────────────────────────────────────────────────────────────────────

initial_readings = [
  { sensor_id: "tmp-1",  value: 20, unit: "°C" },
  { sensor_id: "tmp-2",  value: 45, unit: "°C" },
  { sensor_id: "hum-1",  value: 80, unit: "%" },
  { sensor_id: "pres-1", value: 5,  unit: "kPa" }
]

pipeline = SensorPipeline.new(readings: initial_readings)
pipeline.resolve_all

diff = pipeline.collection_diff(:processed)
print_diff("── Round 1: initial batch ──────────────────────────", diff)
print_results(pipeline.result.processed)

# ──────────────────────────────────────────────────────────────────────────────
# 2. One sensor value changes — only that contract is re-run
# ──────────────────────────────────────────────────────────────────────────────

# Simulate tmp-2 crossing the critical threshold
pipeline.feed_diff(:readings, update: [{ sensor_id: "tmp-2", value: 90, unit: "°C" }])
pipeline.resolve_all

diff = pipeline.collection_diff(:processed)
print_diff("── Round 2: tmp-2 value 45 → 90 ───────────────────", diff)
print_results(pipeline.result.processed)

# ──────────────────────────────────────────────────────────────────────────────
# 3. New sensor arrives — only it is processed
# ──────────────────────────────────────────────────────────────────────────────

pipeline.feed_diff(:readings, add: [{ sensor_id: "wind-1", value: 15, unit: "m/s" }])
pipeline.resolve_all

diff = pipeline.collection_diff(:processed)
print_diff("── Round 3: wind-1 joins the stream ────────────────", diff)
print_results(pipeline.result.processed)

# ──────────────────────────────────────────────────────────────────────────────
# 4. Sensor goes offline — retracted from the result
# ──────────────────────────────────────────────────────────────────────────────

pipeline.feed_diff(:readings, remove: ["hum-1"])
pipeline.resolve_all

diff = pipeline.collection_diff(:processed)
print_diff("── Round 4: hum-1 removed ──────────────────────────", diff)
print_results(pipeline.result.processed)

# ──────────────────────────────────────────────────────────────────────────────
# 5. Identical update — zero re-runs (pure memoization)
# ──────────────────────────────────────────────────────────────────────────────

pipeline.update_inputs(readings: pipeline.execution.inputs[:readings].dup)
pipeline.resolve_all

diff = pipeline.collection_diff(:processed)
print_diff("── Round 5: no data changed (zero re-runs) ─────────", diff)

# ──────────────────────────────────────────────────────────────────────────────
# 6. Sliding-window demonstration — window: { last: 5 }
#    Adding a 6th sensor evicts the oldest from the window
# ──────────────────────────────────────────────────────────────────────────────

pipeline.feed_diff(:readings, add: [{ sensor_id: "co2-1", value: 60, unit: "ppm" }])
pipeline.resolve_all

diff = pipeline.collection_diff(:processed)
print_diff("── Round 6: co2-1 added (window: last 5) ───────────", diff)
puts "\n  Active sensors in window: #{pipeline.result.processed.keys.inspect}"

# ──────────────────────────────────────────────────────────────────────────────
# 7. Summary
# ──────────────────────────────────────────────────────────────────────────────

puts "\n── Summary ─────────────────────────────────────────────"
puts "  Final window: #{pipeline.result.processed.keys.inspect}"
puts "  Diff explain: #{pipeline.collection_diff(:processed).explain}"
puts "\nDone."
