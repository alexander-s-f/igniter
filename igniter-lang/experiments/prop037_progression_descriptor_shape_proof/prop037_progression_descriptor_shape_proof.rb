#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "pathname"

module Prop037ProgressionDescriptorShapeProof
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  OUT_DIR = ROOT / "igniter-lang/experiments/prop037_progression_descriptor_shape_proof"
  SUMMARY_PATH = OUT_DIR / "prop037_progression_descriptor_shape_proof_summary.json"

  DESCRIPTOR_VERSION = "prop037-progression-source-descriptor-v0"
  ALLOWED_SOURCE_KINDS = ["clock.every", "queue", "external_event"].freeze
  ALLOWED_MATERIALIZATION_MODES = ["bounded_demand", "bounded_schedule", "bounded_queue"].freeze
  ALLOWED_BACKPRESSURE = ["block", "drop", "suspend"].freeze
  REQUIRED_FIELDS = [
    "kind",
    "descriptor_version",
    "progression_ref",
    "source_kind",
    "source_ref",
    "payload_type",
    "materialization_policy",
    "handler_ref",
    "receipt_policy",
    "liveness"
  ].freeze
  REQUIRED_CAPS = [
    "progression_materialize",
    "progression_step_execute",
    "progression_step_receipt",
    "progression_cancel",
    "progression_checkpoint_resume"
  ].freeze

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
  end

  module_function

  def run
    FileUtils.mkdir_p(OUT_DIR)
    descriptors = valid_descriptors
    positive_results = descriptors.transform_values { |descriptor| validate_descriptor(descriptor) }
    negative_results = negative_descriptors.transform_values { |descriptor| validate_descriptor(descriptor) }
    checks = build_checks(descriptors, positive_results, negative_results)
    summary = {
      "kind" => "prop037_progression_descriptor_shape_proof",
      "format_version" => "0.1.0",
      "card" => "S3-R38-C2-P1",
      "track" => "prop037-progression-descriptor-shape-proof-v0",
      "proposal" => {
        "id" => "PROP-037",
        "status" => "accepted-proposal-only",
        "source" => "igniter-lang/docs/proposals/PROP-037-external-progression-service-liveness-v0.md",
        "gate" => "igniter-lang/docs/gates/prop037-progression-acceptance-review-v0.md"
      },
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "scope" => scope_boundary,
      "descriptor_contract" => descriptor_contract,
      "descriptors" => descriptors,
      "positive_results" => positive_results,
      "negative_results" => negative_results,
      "checks" => checks,
      "remaining_gaps_before_implementation" => remaining_gaps
    }
    File.write(SUMMARY_PATH, Canonical.pretty(summary))
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def valid_descriptors
    {
      "clock_every_5s" => base_descriptor.merge(
        "progression_ref" => "progression/service/Heartbeat/clock_5s",
        "source_kind" => "clock.every",
        "source_ref" => "clock/every/5s",
        "payload_type" => "Tick",
        "materialization_policy" => {
          "mode" => "bounded_schedule",
          "max_batch_size" => 1,
          "max_in_flight" => 1,
          "backpressure" => "block"
        },
        "handler_ref" => "contract/HandleHeartbeatTick",
        "liveness" => liveness_policy("30s", "2s")
      ),
      "queue_work_items" => base_descriptor.merge(
        "progression_ref" => "progression/service/JobWorker/queue",
        "source_kind" => "queue",
        "source_ref" => "queue/proof_local/work_items",
        "payload_type" => "JobEnvelope",
        "materialization_policy" => {
          "mode" => "bounded_queue",
          "max_batch_size" => 10,
          "max_in_flight" => 20,
          "backpressure" => "suspend"
        },
        "handler_ref" => "contract/ProcessQueuedJob",
        "liveness" => liveness_policy("100_events", "5s")
      ),
      "external_event_http_request" => base_descriptor.merge(
        "progression_ref" => "progression/service/Ingress/external_event",
        "source_kind" => "external_event",
        "source_ref" => "http_listener/on_request",
        "payload_type" => "HttpRequest",
        "authority_ref" => "profile/proof-local/http-listener-readiness-refusal",
        "specialization" => {
          "profile" => "proof-local-http-request",
          "readiness" => "descriptor_only_not_executable"
        },
        "materialization_policy" => {
          "mode" => "bounded_demand",
          "max_batch_size" => 4,
          "max_in_flight" => 8,
          "backpressure" => "block"
        },
        "handler_ref" => "contract/HandleHttpRequest",
        "liveness" => liveness_policy("1m", "3s")
      )
    }.transform_values { |descriptor| stamp_descriptor(descriptor) }
  end

  def base_descriptor
    {
      "kind" => "progression_source",
      "descriptor_version" => DESCRIPTOR_VERSION,
      "receipt_policy" => {
        "required" => true,
        "sink_ref" => "receipt_sink/progression/proof_local",
        "mode" => "per_step"
      },
      "required_caps" => REQUIRED_CAPS,
      "runtime_authority" => "not_authorized",
      "runtime_binding" => {
        "runtime_machine_scheduler" => false,
        "ledger" => false,
        "tbackend" => false,
        "durable_queue" => false,
        "durable_checkpoint" => false,
        "production_execution" => false
      }
    }
  end

  def liveness_policy(checkpoint_every, max_step_latency)
    {
      "cancellation" => "required",
      "checkpoint" => {
        "required" => true,
        "every" => checkpoint_every,
        "resume" => "from_checkpoint"
      },
      "max_step_latency" => max_step_latency
    }
  end

  def stamp_descriptor(descriptor)
    descriptor.merge(
      "descriptor_hash" => descriptor_hash(descriptor)
    )
  end

  def negative_descriptors
    valid = valid_descriptors.fetch("clock_every_5s")
    {
      "unsupported_source_kind" => valid.merge(
        "source_kind" => "http.listener"
      ),
      "unbounded_materialization" => valid.merge(
        "materialization_policy" => valid.fetch("materialization_policy").merge(
          "mode" => "eager_unbounded",
          "max_batch_size" => "unbounded"
        )
      ),
      "missing_cancellation_policy" => remove_liveness_key(valid, "cancellation"),
      "missing_checkpoint_policy" => valid.merge(
        "liveness" => valid.fetch("liveness").merge("checkpoint" => { "required" => false })
      ),
      "missing_receipt_policy" => valid.merge(
        "receipt_policy" => { "required" => false }
      ),
      "missing_bounded_step_policy" => remove_liveness_key(valid, "max_step_latency"),
      "new_progression_fragment_class" => valid.merge(
        "fragment_class" => "PROGRESSION"
      ),
      "runtime_execution_claim" => valid.merge(
        "runtime_authority" => "authorized",
        "runtime_binding" => valid.fetch("runtime_binding").merge(
          "runtime_machine_scheduler" => true,
          "production_execution" => true
        )
      )
    }
  end

  def remove_liveness_key(descriptor, key)
    descriptor.merge(
      "liveness" => descriptor.fetch("liveness").reject { |candidate, _value| candidate == key }
    )
  end

  def validate_descriptor(descriptor)
    errors = []
    REQUIRED_FIELDS.each do |field|
      errors << error("OOF-PR1", "progression.required_field_missing", field) unless descriptor.key?(field)
    end

    errors << error("OOF-PR1", "progression.source_descriptor_invalid_kind", "kind") unless
      descriptor["kind"] == "progression_source"
    errors << error("OOF-PR9", "progression.unsupported_source_kind", "source_kind") unless
      ALLOWED_SOURCE_KINDS.include?(descriptor["source_kind"])
    errors << error("PROP-037-NONAUTH", "progression.fragment_class_not_authorized", "fragment_class") if
      descriptor.key?("fragment_class")

    validate_materialization_policy(descriptor.fetch("materialization_policy", nil), errors)
    validate_receipt_policy(descriptor.fetch("receipt_policy", nil), errors)
    validate_liveness(descriptor.fetch("liveness", nil), errors)
    validate_caps(descriptor.fetch("required_caps", []), errors)
    validate_runtime_boundary(descriptor, errors)

    {
      "valid" => errors.empty?,
      "errors" => errors,
      "descriptor_hash" => descriptor_hash(descriptor)
    }
  end

  def descriptor_hash(descriptor)
    Canonical.hash(descriptor.reject { |key, _value| key == "descriptor_hash" })
  end

  def validate_materialization_policy(policy, errors)
    unless policy.is_a?(Hash)
      errors << error("OOF-PR2", "progression.materialization_policy_missing", "materialization_policy")
      return
    end

    errors << error("OOF-PR2", "progression.materialization_mode_unbounded", "materialization_policy.mode") unless
      ALLOWED_MATERIALIZATION_MODES.include?(policy["mode"])
    errors << error("OOF-PR2", "progression.materialization_batch_unbounded", "materialization_policy.max_batch_size") unless
      positive_integer?(policy["max_batch_size"])
    errors << error("OOF-PR2", "progression.materialization_inflight_unbounded", "materialization_policy.max_in_flight") unless
      positive_integer?(policy["max_in_flight"])
    errors << error("OOF-PR2", "progression.backpressure_policy_invalid", "materialization_policy.backpressure") unless
      ALLOWED_BACKPRESSURE.include?(policy["backpressure"])
  end

  def validate_receipt_policy(policy, errors)
    unless policy.is_a?(Hash) && policy["required"] == true && string_present?(policy["sink_ref"])
      errors << error("OOF-PR7", "progression.receipt_policy_required", "receipt_policy")
    end
  end

  def validate_liveness(liveness, errors)
    unless liveness.is_a?(Hash)
      errors << error("OOF-PR3", "progression.cancellation_required", "liveness.cancellation")
      errors << error("OOF-PR4", "progression.checkpoint_required", "liveness.checkpoint")
      errors << error("OOF-PR5", "progression.max_step_latency_required", "liveness.max_step_latency")
      return
    end

    errors << error("OOF-PR3", "progression.cancellation_required", "liveness.cancellation") unless
      liveness["cancellation"] == "required"
    checkpoint = liveness["checkpoint"]
    unless checkpoint.is_a?(Hash) && checkpoint["required"] == true &&
           string_present?(checkpoint["every"]) && checkpoint["resume"] == "from_checkpoint"
      errors << error("OOF-PR4", "progression.checkpoint_required", "liveness.checkpoint")
    end
    errors << error("OOF-PR5", "progression.max_step_latency_required", "liveness.max_step_latency") unless
      bounded_duration?(liveness["max_step_latency"])
  end

  def validate_caps(caps, errors)
    missing = REQUIRED_CAPS - caps
    return if missing.empty?

    errors << error("OOF-PR9", "progression.required_capability_missing", missing.join(","))
  end

  def validate_runtime_boundary(descriptor, errors)
    if descriptor["runtime_authority"] != "not_authorized"
      errors << error("PROP-037-NONAUTH", "progression.runtime_execution_not_authorized", "runtime_authority")
    end

    binding = descriptor.fetch("runtime_binding", {})
    forbidden_true = binding.select do |key, value|
      ["runtime_machine_scheduler", "ledger", "tbackend", "durable_queue",
       "durable_checkpoint", "production_execution"].include?(key) && value == true
    end
    return if forbidden_true.empty?

    errors << error("PROP-037-NONAUTH", "progression.runtime_binding_not_authorized", forbidden_true.keys.join(","))
  end

  def build_checks(descriptors, positive_results, negative_results)
    negative_errors = negative_results.transform_values do |result|
      result.fetch("errors").map { |item| item.fetch("code") }
    end
    {
      "valid_descriptors_pass" => positive_results.values.all? { |result| result.fetch("valid") },
      "models_exact_required_source_kinds" => descriptors.values.map { |item| item.fetch("source_kind") }.sort == ALLOWED_SOURCE_KINDS.sort,
      "closed_v0_source_kind_rejects_new_top_level" => negative_errors.fetch("unsupported_source_kind").include?("OOF-PR9"),
      "bounded_materialization_required" => negative_errors.fetch("unbounded_materialization").include?("OOF-PR2"),
      "cancellation_policy_required" => negative_errors.fetch("missing_cancellation_policy").include?("OOF-PR3"),
      "checkpoint_policy_required" => negative_errors.fetch("missing_checkpoint_policy").include?("OOF-PR4"),
      "receipt_policy_required" => negative_errors.fetch("missing_receipt_policy").include?("OOF-PR7"),
      "bounded_step_required" => negative_errors.fetch("missing_bounded_step_policy").include?("OOF-PR5"),
      "no_progression_fragment_class" => negative_errors.fetch("new_progression_fragment_class").include?("PROP-037-NONAUTH") &&
        descriptors.values.none? { |descriptor| descriptor.key?("fragment_class") },
      "runtime_authority_remains_closed" => negative_errors.fetch("runtime_execution_claim").include?("PROP-037-NONAUTH") &&
        descriptors.values.all? { |descriptor| descriptor.fetch("runtime_authority") == "not_authorized" }
    }
  end

  def descriptor_contract
    {
      "descriptor_version" => DESCRIPTOR_VERSION,
      "required_fields" => REQUIRED_FIELDS,
      "closed_source_kind_vocabulary" => ALLOWED_SOURCE_KINDS,
      "allowed_materialization_modes" => ALLOWED_MATERIALIZATION_MODES,
      "allowed_backpressure" => ALLOWED_BACKPRESSURE,
      "required_caps" => REQUIRED_CAPS,
      "forbidden" => [
        "new top-level source_kind without future accepted decision",
        "unbounded eager materialization",
        "PROGRESSION fragment class",
        "runtime scheduler binding",
        "Ledger/TBackend binding",
        "durable queue/checkpoint binding",
        "production execution claim"
      ]
    }
  end

  def scope_boundary
    {
      "parser_implementation" => false,
      "typechecker_implementation" => false,
      "semanticir_implementation" => false,
      "runtime_scheduler" => false,
      "new_progression_fragment_class" => false,
      "ledger_binding" => false,
      "tbackend_binding" => false,
      "durable_queues" => false,
      "proof_local_descriptor_validation" => true
    }
  end

  def remaining_gaps
    [
      {
        "layer" => "Parser",
        "gap" => "accepted service-loop/progression syntax proposal and parser implementation authorization"
      },
      {
        "layer" => "Classifier/TypeChecker",
        "gap" => "accepted OOF-PR ownership and typed descriptor proof plan"
      },
      {
        "layer" => "SemanticIR",
        "gap" => "accepted node/artifact shape and golden fixture plan"
      },
      {
        "layer" => "Assembler/.igapp",
        "gap" => "manifest schema authorization for progression_sources"
      },
      {
        "layer" => "RuntimeMachine",
        "gap" => "scheduler/materializer gate and proof-local implementation plan"
      },
      {
        "layer" => "Durability",
        "gap" => "durable queue/checkpoint/receipt sink design and authorization"
      },
      {
        "layer" => "Ledger/TBackend",
        "gap" => "separate binding decision; not implied by descriptor metadata"
      },
      {
        "layer" => "Production execution",
        "gap" => "explicit runtime/production gate"
      }
    ]
  end

  def error(code, reason, path)
    {
      "code" => code,
      "reason" => reason,
      "path" => path,
      "severity" => "error"
    }
  end

  def positive_integer?(value)
    value.is_a?(Integer) && value.positive?
  end

  def string_present?(value)
    value.is_a?(String) && !value.empty?
  end

  def bounded_duration?(value)
    string_present?(value) && value.match?(/\A\d+(ms|s|m)\z/)
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} prop037_progression_descriptor_shape_proof"
    summary.fetch("checks").each do |name, passed|
      puts "#{name}: #{passed ? "ok" : "fail"}"
    end
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

exit(Prop037ProgressionDescriptorShapeProof.run ? 0 : 1)
