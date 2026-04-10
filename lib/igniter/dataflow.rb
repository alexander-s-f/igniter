# frozen_string_literal: true

require "igniter/dataflow/diff"
require "igniter/dataflow/diff_state"
require "igniter/dataflow/window_filter"
require "igniter/dataflow/incremental_collection_result"
require "igniter/dataflow/aggregate_operators"
require "igniter/dataflow/aggregate_state"
require "igniter/model/aggregate_node"

module Igniter
  # Incremental Dataflow — Phase 1: differential collection processing.
  #
  # Adds `mode: :incremental` to the `collection` DSL node. In this mode the
  # resolver tracks per-item state between `update_inputs` calls and re-runs
  # child contracts only for items that were added or changed. Removed items
  # are retracted automatically. Unchanged items reuse their cached results
  # with zero re-computation cost.
  #
  # Optional `window:` filter limits the active item set before diff computation:
  #
  #   window: { last: 100 }
  #     Keep only the last 100 items (most recent last in the array).
  #
  #   window: { seconds: 300, field: :received_at }
  #     Keep items where item[:received_at] >= Time.now - 300.
  #
  # == Usage
  #
  #   require "igniter/extensions/dataflow"
  #
  #   class SensorPipeline < Igniter::Contract
  #     define do
  #       input :readings, type: :array
  #
  #       collection :processed,
  #                  with: :readings,
  #                  each: SensorContract,
  #                  key: :sensor_id,
  #                  mode: :incremental,
  #                  window: { last: 500 }
  #
  #       output :processed
  #     end
  #   end
  #
  #   contract = SensorPipeline.new(readings: initial_readings)
  #   contract.resolve_all
  #
  #   contract.update_inputs(readings: updated_readings)
  #   contract.resolve_all
  #
  #   result = contract.result.processed
  #   result.diff.added     # => [:sensor_42]   — child contract was re-run
  #   result.diff.changed   # => [:sensor_7]    — child contract was re-run
  #   result.diff.removed   # => [:sensor_3]    — retracted from result
  #   result.diff.unchanged # => [:sensor_1, :sensor_2]  — result reused
  #
  #   # Convenience: push events as a diff instead of replacing the full array
  #   contract.feed_diff(:readings, add: [new_reading], remove: [:sensor_3])
  #
  module Dataflow
    class DataflowError < Igniter::Error; end
  end
end
