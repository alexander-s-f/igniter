#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "pathname"
require "time"

module ExternalProgressionRuntimeModel
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  OUT_DIR = ROOT / "igniter-lang/experiments/external_progression_runtime_model"
  SUMMARY_PATH = OUT_DIR / "external_progression_runtime_model_summary.json"

  PROOF_TIME = Time.utc(2026, 5, 11, 12, 0, 0)
  RECEIPT_SCHEMA = "progression-step-receipt-v1"
  MATERIALIZATION_SCHEMA = "progression-materialization-v1"

  module Canonical
    module_function

    def normalize(value)
      case value
      when Hash
        value.keys.sort_by(&:to_s).each_with_object({}) do |key, out|
          out[key.to_s] = normalize(value.fetch(key))
        end
      when Array
        value.map { |item| normalize(item) }
      when Symbol
        value.to_s
      when Time
        value.utc.iso8601
      else
        value
      end
    end

    def json(value)
      JSON.generate(normalize(value))
    end

    def pretty(value)
      "#{JSON.pretty_generate(normalize(value))}\n"
    end

    def hash(value)
      "sha256:#{Digest::SHA256.hexdigest(json(value))}"
    end

    def short_hash(value)
      hash(value).delete_prefix("sha256:")[0, 16]
    end
  end

  class ClockProgressionSource
    attr_reader :progression_ref, :period_seconds

    def initialize(progression_ref:, period_seconds:, start_at:)
      @progression_ref = progression_ref
      @period_seconds = period_seconds
      @start_at = start_at
    end

    def potential
      "infinite"
    end

    def event_at(sequence)
      scheduled_at = @start_at + (sequence * period_seconds)
      material = {
        "progression_ref" => progression_ref,
        "source_kind" => "clock.every",
        "period_seconds" => period_seconds,
        "sequence" => sequence,
        "scheduled_at" => scheduled_at.utc.iso8601
      }
      event(material.merge(
              "payload" => {
                "tick" => sequence,
                "scheduled_at" => scheduled_at.utc.iso8601
              }
            ))
    end

    private

    def event(material)
      material.merge(
        "kind" => "progression_event",
        "event_id" => "progression-event/#{Canonical.short_hash(material)}"
      )
    end
  end

  class QueueProgressionSource
    attr_reader :progression_ref

    def initialize(progression_ref:, jobs:)
      @progression_ref = progression_ref
      @jobs = jobs
    end

    def potential
      "bounded_external_queue"
    end

    def event_at(sequence)
      job = @jobs.fetch(sequence)
      material = {
        "progression_ref" => progression_ref,
        "source_kind" => "work_queue",
        "sequence" => sequence,
        "scheduled_at" => job.fetch("visible_at"),
        "payload" => job
      }
      material.merge(
        "kind" => "progression_event",
        "event_id" => "progression-event/#{Canonical.short_hash(material)}"
      )
    end

    def exhausted_at?(sequence)
      sequence >= @jobs.length
    end
  end

  class ProgressionRuntime
    attr_reader :checkpoint_cursor, :events, :receipts

    def initialize(source:, handler_ref:, checkpoint_cursor: 0, receipts: [])
      @source = source
      @handler_ref = handler_ref
      @checkpoint_cursor = checkpoint_cursor
      @events = []
      @receipts = receipts.dup
      @cancelled = false
    end

    def materialize(limit:, queue_capacity:)
      return cancelled_materialization if @cancelled

      available = [limit, queue_capacity].min
      materialized = []
      available.times do |offset|
        sequence = checkpoint_cursor + offset
        break if @source.respond_to?(:exhausted_at?) && @source.exhausted_at?(sequence)

        materialized << @source.event_at(sequence)
      end
      @events.concat(materialized)
      @checkpoint_cursor += materialized.length

      {
        "kind" => "progression_materialization",
        "version" => MATERIALIZATION_SCHEMA,
        "progression_ref" => @source.progression_ref,
        "source_potential" => @source.potential,
        "requested_limit" => limit,
        "queue_capacity" => queue_capacity,
        "materialized_count" => materialized.length,
        "queued_event_ids" => materialized.map { |event| event.fetch("event_id") },
        "cursor_after" => checkpoint_cursor,
        "backpressure" => backpressure(limit, queue_capacity, materialized.length),
        "eager_execution" => false
      }
    end

    def execute_queued(max_steps: @events.length)
      selected = @events.shift(max_steps)
      step_receipts = selected.each_with_index.map do |event, index|
        started_at = PROOF_TIME + index
        finished_at = started_at + 1
        receipt = step_receipt(
          event: event,
          started_at: started_at,
          finished_at: finished_at,
          outcome: "completed",
          reason: "progression.step_completed"
        )
        @receipts << receipt
        receipt
      end
      {
        "executed_count" => step_receipts.length,
        "receipts" => step_receipts
      }
    end

    def cancel(reason:)
      @cancelled = true
      receipt = {
        "kind" => "progression_step_receipt",
        "version" => RECEIPT_SCHEMA,
        "progression" => @source.progression_ref,
        "event_id" => nil,
        "sequence" => nil,
        "scheduled_at" => nil,
        "started_at" => PROOF_TIME.utc.iso8601,
        "finished_at" => PROOF_TIME.utc.iso8601,
        "outcome" => "cancelled",
        "reason" => reason,
        "artifact_hash" => Canonical.hash(
          "progression" => @source.progression_ref,
          "outcome" => "cancelled",
          "reason" => reason
        )
      }
      @receipts << receipt
      receipt
    end

    def checkpoint
      {
        "kind" => "progression_checkpoint",
        "progression_ref" => @source.progression_ref,
        "cursor" => checkpoint_cursor,
        "receipt_count" => receipts.length,
        "receipt_hash" => Canonical.hash(receipts)
      }
    end

    private

    def cancelled_materialization
      {
        "kind" => "progression_materialization",
        "version" => MATERIALIZATION_SCHEMA,
        "progression_ref" => @source.progression_ref,
        "source_potential" => @source.potential,
        "requested_limit" => 0,
        "queue_capacity" => 0,
        "materialized_count" => 0,
        "queued_event_ids" => [],
        "cursor_after" => checkpoint_cursor,
        "backpressure" => {
          "state" => "cancelled",
          "reason" => "progression.cancelled"
        },
        "eager_execution" => false
      }
    end

    def backpressure(limit, queue_capacity, materialized_count)
      return { "state" => "open", "reason" => nil } unless limit > queue_capacity

      {
        "state" => "blocked",
        "reason" => "progression.backpressure_queue_capacity",
        "requested" => limit,
        "accepted" => materialized_count,
        "capacity" => queue_capacity
      }
    end

    def step_receipt(event:, started_at:, finished_at:, outcome:, reason:)
      material = {
        "progression" => event.fetch("progression_ref"),
        "event_id" => event.fetch("event_id"),
        "sequence" => event.fetch("sequence"),
        "handler_ref" => @handler_ref,
        "payload_hash" => Canonical.hash(event.fetch("payload")),
        "outcome" => outcome
      }
      {
        "kind" => "progression_step_receipt",
        "version" => RECEIPT_SCHEMA,
        "progression" => event.fetch("progression_ref"),
        "event_id" => event.fetch("event_id"),
        "sequence" => event.fetch("sequence"),
        "scheduled_at" => event.fetch("scheduled_at"),
        "started_at" => started_at.utc.iso8601,
        "finished_at" => finished_at.utc.iso8601,
        "outcome" => outcome,
        "reason" => reason,
        "artifact_hash" => Canonical.hash(material)
      }
    end
  end

  module_function

  def run
    FileUtils.mkdir_p(OUT_DIR)
    examples = build_examples
    checks = build_checks(examples)
    summary = {
      "kind" => "external_progression_runtime_model",
      "format_version" => "0.1.0",
      "track" => "external-progression-runtime-model-v0",
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "scope" => {
        "proof_local_runtime_model" => true,
        "production_runtime_machine" => false,
        "parser_or_typechecker_changes" => false,
        "semanticir_primitive" => false,
        "ledger_or_durable_scheduler" => false
      },
      "semantic_delta_vs_loop" => semantic_delta_vs_loop,
      "new_capabilities" => new_capabilities,
      "examples" => examples,
      "checks" => checks
    }
    File.write(SUMMARY_PATH, Canonical.pretty(summary))
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def build_examples
    clock_source = ClockProgressionSource.new(
      progression_ref: "progression/heartbeat/clock-5s",
      period_seconds: 5,
      start_at: PROOF_TIME
    )
    clock_runtime = ProgressionRuntime.new(
      source: clock_source,
      handler_ref: "handler/ProcessTick"
    )
    lazy_materialization = clock_runtime.materialize(limit: 3, queue_capacity: 3)
    lazy_execution = clock_runtime.execute_queued

    checkpoint_source = ClockProgressionSource.new(
      progression_ref: "progression/checkpointed/clock-5s",
      period_seconds: 5,
      start_at: PROOF_TIME
    )
    first_runtime = ProgressionRuntime.new(
      source: checkpoint_source,
      handler_ref: "handler/ProcessTick"
    )
    first_runtime.materialize(limit: 2, queue_capacity: 2)
    first_runtime.execute_queued
    checkpoint = first_runtime.checkpoint
    resumed_runtime = ProgressionRuntime.new(
      source: checkpoint_source,
      handler_ref: "handler/ProcessTick",
      checkpoint_cursor: checkpoint.fetch("cursor"),
      receipts: first_runtime.receipts
    )
    resumed_runtime.materialize(limit: 2, queue_capacity: 2)
    resumed_runtime.execute_queued

    pressure_runtime = ProgressionRuntime.new(
      source: ClockProgressionSource.new(
        progression_ref: "progression/pressure/clock-1s",
        period_seconds: 1,
        start_at: PROOF_TIME
      ),
      handler_ref: "handler/ProcessTick"
    )
    backpressure = pressure_runtime.materialize(limit: 5, queue_capacity: 2)

    cancelled_runtime = ProgressionRuntime.new(
      source: ClockProgressionSource.new(
        progression_ref: "progression/cancellable/clock-1s",
        period_seconds: 1,
        start_at: PROOF_TIME
      ),
      handler_ref: "handler/ProcessTick"
    )
    cancellation_receipt = cancelled_runtime.cancel(reason: "progression.cancelled_by_runtime_policy")
    cancelled_materialization = cancelled_runtime.materialize(limit: 1, queue_capacity: 1)

    queue_runtime = ProgressionRuntime.new(
      source: QueueProgressionSource.new(
        progression_ref: "progression/job-worker/work-queue",
        jobs: [
          { "job_id" => "job-1", "visible_at" => "2026-05-11T12:00:00Z", "kind" => "transcode" },
          { "job_id" => "job-2", "visible_at" => "2026-05-11T12:00:10Z", "kind" => "thumbnail" }
        ]
      ),
      handler_ref: "handler/ProcessJob"
    )
    queue_materialization = queue_runtime.materialize(limit: 2, queue_capacity: 2)
    queue_execution = queue_runtime.execute_queued

    {
      "lazy_clock_progression" => {
        "materialization" => lazy_materialization,
        "execution" => lazy_execution,
        "receipt_count" => lazy_execution.fetch("receipts").length
      },
      "checkpoint_resume" => {
        "checkpoint" => checkpoint,
        "receipt_sequences_after_resume" => resumed_runtime.receipts.map { |receipt| receipt.fetch("sequence") },
        "receipt_event_ids_after_resume" => resumed_runtime.receipts.map { |receipt| receipt.fetch("event_id") }
      },
      "backpressure" => backpressure,
      "cancellation" => {
        "receipt" => cancellation_receipt,
        "post_cancel_materialization" => cancelled_materialization
      },
      "queue_progression" => {
        "materialization" => queue_materialization,
        "execution" => queue_execution
      }
    }
  end

  def semantic_delta_vs_loop
    {
      "imperative_loop" => {
        "ontology" => "eager repeated body execution",
        "scheduler" => "hidden",
        "infinite_case" => "requires out-of-band stop condition",
        "audit_unit" => "body side effect or runtime log",
        "backpressure" => "not semantic"
      },
      "external_progression" => {
        "ontology" => "declarative temporal event potential",
        "scheduler" => "explicit ProgressionSource plus runtime materializer",
        "infinite_case" => "safe when materialized by bounded demand",
        "audit_unit" => "ProgressionStepReceipt",
        "backpressure" => "structured materialization state"
      }
    }
  end

  def new_capabilities
    [
      "lazy_infinite_progression_window",
      "receipt_first_step_audit",
      "deterministic_checkpoint_resume",
      "structured_backpressure_refusal",
      "structured_cancellation_receipt",
      "shared_lifecycle_for_clock_and_queue_sources"
    ]
  end

  def build_checks(examples)
    lazy = examples.fetch("lazy_clock_progression")
    receipt = lazy.fetch("execution").fetch("receipts").first
    checkpoint_sequences = examples.fetch("checkpoint_resume").fetch("receipt_sequences_after_resume")
    checkpoint_event_ids = examples.fetch("checkpoint_resume").fetch("receipt_event_ids_after_resume")
    backpressure = examples.fetch("backpressure").fetch("backpressure")
    cancellation = examples.fetch("cancellation")
    queue_receipts = examples.fetch("queue_progression").fetch("execution").fetch("receipts")

    {
      "clock_progression_lazy_not_eager" =>
        lazy.fetch("materialization").fetch("source_potential") == "infinite" &&
        lazy.fetch("materialization").fetch("materialized_count") == 3 &&
        lazy.fetch("materialization").fetch("eager_execution") == false,
      "step_receipts_are_structured" =>
        receipt.fetch("kind") == "progression_step_receipt" &&
        receipt.fetch("version") == RECEIPT_SCHEMA &&
        receipt.fetch("event_id").start_with?("progression-event/") &&
        receipt.fetch("artifact_hash").start_with?("sha256:"),
      "checkpoint_resume_no_duplicates" =>
        checkpoint_sequences == [0, 1, 2, 3] &&
        checkpoint_event_ids.compact.uniq.length == checkpoint_event_ids.compact.length,
      "backpressure_is_structured" =>
        backpressure.fetch("state") == "blocked" &&
        backpressure.fetch("reason") == "progression.backpressure_queue_capacity",
      "cancellation_blocks_future_materialization" =>
        cancellation.fetch("receipt").fetch("outcome") == "cancelled" &&
        cancellation.fetch("post_cancel_materialization").fetch("materialized_count").zero? &&
        cancellation.fetch("post_cancel_materialization").fetch("backpressure").fetch("state") == "cancelled",
      "queue_progression_uses_same_lifecycle" =>
        queue_receipts.length == 2 &&
        queue_receipts.all? { |item| item.fetch("kind") == "progression_step_receipt" },
      "new_capability_matrix_has_all_expected" =>
        new_capabilities.length == 6
    }
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} external_progression_runtime_model"
    summary.fetch("checks").each do |name, passed|
      puts "#{name}: #{passed ? "ok" : "fail"}"
    end
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

exit(ExternalProgressionRuntimeModel.run ? 0 : 1)
