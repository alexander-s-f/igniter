# frozen_string_literal: true

# examples/dataflow.rb
#
# Demonstrates Igniter's incremental dataflow:
#
# Part 1 — Incremental Collection (mode: :incremental)
#   Only added/changed items have their child contract re-run.
#   Removed items are retracted automatically.
#   window: { last: N } keeps a bounded sliding window in memory.
#
# Part 2 — Maintained Aggregates
#   Aggregate nodes (count, sum, avg, min, max, group_count, custom) update
#   in O(change) time — only the diff contributes, not the full collection.
#
# Typical use-cases:
#   • IoT sensor streams   — thousands of sensors, updates arrive as diffs
#   • Live analytics       — sliding-window aggregates with O(change) compute
#   • Event-driven systems — process only the delta, not the full dataset
#
# Run with: bundle exec ruby examples/dataflow.rb

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "igniter"
require "igniter/extensions/dataflow"

# ═══════════════════════════════════════════════════════════════════════════════
# PART 1 — Incremental Collection + Sliding Window
# ═══════════════════════════════════════════════════════════════════════════════

# ─── Child contract: process a single sensor reading ──────────────────────────
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

# ─── Pipeline with sliding window ─────────────────────────────────────────────
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

puts "═" * 60
puts "PART 1 — Incremental Collection + Sliding Window"
puts "═" * 60

# ── Round 1: initial batch — 4 sensors, all treated as :added ─────────────────

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

# ── Round 2: one sensor crosses critical threshold ────────────────────────────

pipeline.feed_diff(:readings, update: [{ sensor_id: "tmp-2", value: 90, unit: "°C" }])
pipeline.resolve_all

diff = pipeline.collection_diff(:processed)
print_diff("── Round 2: tmp-2 value 45 → 90 ───────────────────", diff)
print_results(pipeline.result.processed)

# ── Round 3: new sensor arrives ───────────────────────────────────────────────

pipeline.feed_diff(:readings, add: [{ sensor_id: "wind-1", value: 15, unit: "m/s" }])
pipeline.resolve_all

diff = pipeline.collection_diff(:processed)
print_diff("── Round 3: wind-1 joins the stream ────────────────", diff)
print_results(pipeline.result.processed)

# ── Round 4: sensor goes offline ──────────────────────────────────────────────

pipeline.feed_diff(:readings, remove: ["hum-1"])
pipeline.resolve_all

diff = pipeline.collection_diff(:processed)
print_diff("── Round 4: hum-1 removed ──────────────────────────", diff)
print_results(pipeline.result.processed)

# ── Round 5: identical update — zero re-runs ──────────────────────────────────

pipeline.update_inputs(readings: pipeline.execution.inputs[:readings].dup)
pipeline.resolve_all

diff = pipeline.collection_diff(:processed)
print_diff("── Round 5: no data changed (zero re-runs) ─────────", diff)

# ── Round 6: sliding window — adding 6th sensor evicts oldest ─────────────────

pipeline.feed_diff(:readings, add: [{ sensor_id: "co2-1", value: 60, unit: "ppm" }])
pipeline.resolve_all

diff = pipeline.collection_diff(:processed)
print_diff("── Round 6: co2-1 added (window: last 5) ───────────", diff)
puts "\n  Active sensors in window: #{pipeline.result.processed.keys.inspect}"

# ─── Summary ──────────────────────────────────────────────────────────────────

puts "\n── Summary ─────────────────────────────────────────────"
puts "  Final window: #{pipeline.result.processed.keys.inspect}"
puts "  Diff explain: #{pipeline.collection_diff(:processed).explain}"

# ═══════════════════════════════════════════════════════════════════════════════
# PART 2 — Maintained Aggregates
#
# Aggregates update in O(change) time — only the diff items are processed.
# The AggregateState stores per-key contributions so that removed/changed items
# can be retracted without rescanning the full collection.
# ═══════════════════════════════════════════════════════════════════════════════

puts "\n"
puts "═" * 60
puts "PART 2 — Maintained Aggregates"
puts "═" * 60

# ─── Child contract: classify sensor with zone info ───────────────────────────

class SensorMetrics < Igniter::Contract
  define do
    input :sensor_id
    input :value, type: :numeric
    input :zone

    compute :status, depends_on: :value do |value:|
      value > 75 ? :critical : :normal
    end

    output :status
    output :value   # exposed for sum/avg/min/max projections
    output :zone    # exposed for group_count
  end
end

# ─── Analytics pipeline with all built-in aggregate operators ─────────────────

class AnalyticsPipeline < Igniter::Contract
  define do # rubocop:disable Metrics/BlockLength
    input :sensors, type: :array

    collection :processed,
               with: :sensors,
               each: SensorMetrics,
               key: :sensor_id,
               mode: :incremental

    # ── Built-in operators ──────────────────────────────────────────────────
    aggregate :total, from: :processed # count all
    aggregate :high_count,
              from: :processed,
              count: ->(item) { item.result.status == :critical }
    aggregate :total_value,
              from: :processed,
              sum: ->(item) { item.result.value.to_f }
    aggregate :avg_value,
              from: :processed,
              avg: ->(item) { item.result.value.to_f }
    aggregate :peak,
              from: :processed,
              max: ->(item) { item.result.value.to_f }
    aggregate :by_zone,
              from: :processed,
              group_count: ->(item) { item.result.zone }

    # ── Custom retractable aggregate ────────────────────────────────────────
    # Maintains a sorted list of unique critical sensor IDs
    critical_add = lambda do |acc, item|
      item.result.status == :critical ? (acc + [item.key]).sort.uniq : acc
    end
    aggregate :critical_ids,
              from: :processed,
              initial: [],
              add: critical_add,
              remove: ->(acc, item) { acc - [item.key] }

    output :processed
    output :total
    output :high_count
    output :total_value
    output :avg_value
    output :peak
    output :by_zone
    output :critical_ids
  end
end

# ─── Helper ───────────────────────────────────────────────────────────────────

def print_aggregates(result) # rubocop:disable Metrics/AbcSize
  r = result
  puts "  total       = #{r.total}"
  puts "  high_count  = #{r.high_count}  (critical sensors)"
  puts "  total_value = #{r.total_value.round(1)}"
  puts "  avg_value   = #{r.avg_value.round(2)}"
  puts "  peak        = #{r.peak.inspect}"
  puts "  by_zone     = #{r.by_zone.inspect}"
  puts "  critical_ids= #{r.critical_ids.inspect}"
end

sensor = ->(id, value, zone) { { sensor_id: id, value: value, zone: zone } }

# ── Round A: initial batch ─────────────────────────────────────────────────────

sensors_a = [
  sensor.call("s1", 20, "north"), # normal
  sensor.call("s2", 80, "north"), # critical
  sensor.call("s3", 90, "south"), # critical
  sensor.call("s4", 30, "south")  # normal
]

ap = AnalyticsPipeline.new(sensors: sensors_a)
ap.resolve_all

puts "\n── Round A: initial batch (4 sensors) ──────────────────"
puts "  diff: #{ap.collection_diff(:processed).processed_count} child contract(s) run"
print_aggregates(ap.result)

# ── Round B: s2 value drops (critical → normal) ───────────────────────────────

ap.feed_diff(:sensors, update: [sensor.call("s2", 40, "north")])
ap.resolve_all

puts "\n── Round B: s2 value 80 → 40  (critical → normal) ──────"
puts "  diff: #{ap.collection_diff(:processed).processed_count} child contract(s) run"
print_aggregates(ap.result)

# ── Round C: new sensor added in a new zone ────────────────────────────────────

ap.feed_diff(:sensors, add: [sensor.call("s5", 95, "east")])
ap.resolve_all

puts "\n── Round C: s5 added in zone 'east' (critical) ─────────"
puts "  diff: #{ap.collection_diff(:processed).processed_count} child contract(s) run"
print_aggregates(ap.result)

# ── Round D: peak sensor removed ──────────────────────────────────────────────

ap.feed_diff(:sensors, remove: ["s5"])
ap.resolve_all

puts "\n── Round D: s5 removed (peak was 95) ───────────────────"
puts "  diff: #{ap.collection_diff(:processed).processed_count} child contract(s) run"
print_aggregates(ap.result)

# ── Round E: no change — zero re-runs, aggregates stable ──────────────────────

ap.update_inputs(sensors: ap.execution.inputs[:sensors].dup)
ap.resolve_all

puts "\n── Round E: no change (zero re-runs, aggregates stable) "
puts "  diff: #{ap.collection_diff(:processed).processed_count} child contract(s) run"
print_aggregates(ap.result)

puts "\nDone."
