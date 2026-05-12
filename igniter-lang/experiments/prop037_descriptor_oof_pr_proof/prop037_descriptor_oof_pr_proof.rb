#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "pathname"

module Prop037DescriptorOofPrProof
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  OUT_DIR = ROOT / "igniter-lang/experiments/prop037_descriptor_oof_pr_proof"
  SUMMARY_PATH = OUT_DIR / "prop037_descriptor_oof_pr_proof_summary.json"

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
  READINESS_REFUSAL = "progression.runtime_execution_not_authorized"

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

    positives = valid_descriptors.transform_values do |descriptor|
      validate_case(descriptor)
    end
    negatives = invalid_descriptor_cases.transform_values do |descriptor|
      validate_case(descriptor)
    end
    readiness_case = validate_case(valid_descriptors.fetch("clock_every_valid_descriptor"))
    checks = build_checks(positives, negatives, readiness_case)
    summary = {
      "kind" => "prop037_descriptor_oof_pr_proof",
      "format_version" => "0.1.0",
      "card" => "S3-R40-C1-P1",
      "track" => "prop037-descriptor-oof-pr-proof-v0",
      "proposal" => {
        "id" => "PROP-037",
        "status" => "accepted-proposal-only",
        "source" => "igniter-lang/docs/proposals/PROP-037-external-progression-service-liveness-v0.md",
        "diagnostic_design" => "igniter-lang/docs/tracks/prop037-oof-pr-diagnostic-design-v0.md",
        "namespace_prerequisite" => "igniter-lang/docs/tracks/ch11-profile-oof-namespace-sync-v0.md"
      },
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "scope" => scope_boundary,
      "descriptor_contract" => descriptor_contract,
      "valid_descriptors" => valid_descriptors,
      "positive_results" => positives,
      "negative_results" => negatives,
      "runtime_readiness_separation" => readiness_summary(readiness_case),
      "checks" => checks,
      "remaining_gaps_before_implementation" => remaining_gaps
    }

    File.write(SUMMARY_PATH, Canonical.pretty(summary))
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def valid_descriptors
    {
      "clock_every_valid_descriptor" => base_descriptor.merge(
        "progression_ref" => "progression/service/Heartbeat/clock_5s",
        "source_kind" => "clock.every",
        "source_ref" => "clock/every/5s",
        "payload_type" => "Tick",
        "materialization_policy" => materialization_policy("bounded_schedule", 1, 1, "block"),
        "handler_ref" => "contract/HandleHeartbeatTick",
        "liveness" => liveness_policy("30s", "2s")
      ),
      "queue_valid_descriptor" => base_descriptor.merge(
        "progression_ref" => "progression/service/JobWorker/queue",
        "source_kind" => "queue",
        "source_ref" => "queue/proof_local/work_items",
        "payload_type" => "JobEnvelope",
        "materialization_policy" => materialization_policy("bounded_queue", 10, 20, "suspend"),
        "handler_ref" => "contract/ProcessQueuedJob",
        "liveness" => liveness_policy("100_events", "5s")
      ),
      "external_event_valid_descriptor" => base_descriptor.merge(
        "progression_ref" => "progression/service/Ingress/external_event",
        "source_kind" => "external_event",
        "source_ref" => "proof_local/external_event/http_shape_only",
        "payload_type" => "HttpRequest",
        "authority_ref" => "profile/proof-local/external-event-readiness-refusal",
        "specialization" => {
          "profile" => "proof-local-http-shape-only",
          "readiness" => "descriptor_only_not_executable"
        },
        "materialization_policy" => materialization_policy("bounded_demand", 4, 8, "block"),
        "handler_ref" => "contract/HandleExternalEventShape",
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
        "receipt_sink_implementation" => false,
        "production_cache" => false,
        "production_execution" => false,
        "progression_pack_dispatch" => false
      }
    }
  end

  def materialization_policy(mode, max_batch_size, max_in_flight, backpressure)
    {
      "mode" => mode,
      "max_batch_size" => max_batch_size,
      "max_in_flight" => max_in_flight,
      "backpressure" => backpressure
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
    descriptor.merge("descriptor_hash" => descriptor_hash(descriptor))
  end

  def invalid_descriptor_cases
    valid = valid_descriptors.fetch("clock_every_valid_descriptor")
    {
      "missing_source_descriptor" => nil,
      "unbounded_materialization" => valid.merge(
        "materialization_policy" => materialization_policy("eager_unbounded", "unbounded", nil, "none")
      ),
      "missing_cancellation" => with_liveness_removed(valid, "cancellation"),
      "missing_checkpoint_for_resumable" => valid.merge(
        "liveness" => valid.fetch("liveness").merge(
          "checkpoint" => {
            "required" => false,
            "resume" => "none"
          }
        )
      ),
      "missing_max_step_latency" => with_liveness_removed(valid, "max_step_latency"),
      "missing_receipt_policy" => valid.merge(
        "receipt_policy" => {
          "required" => false
        }
      ),
      "unsupported_source_kind" => valid.merge(
        "source_kind" => "http.listener"
      )
    }
  end

  def with_liveness_removed(descriptor, key)
    descriptor.merge(
      "liveness" => descriptor.fetch("liveness").reject { |candidate, _value| candidate == key }
    )
  end

  def validate_case(descriptor)
    diagnostics = validate_descriptor(descriptor)
    descriptor_hash = descriptor_hash(descriptor) if descriptor
    {
      "descriptor_hash" => descriptor_hash,
      "compiler_report" => compiler_report(diagnostics, descriptor_hash),
      "runtime_readiness" => runtime_readiness(descriptor, diagnostics),
      "no_live_call_invariant" => no_live_call_invariant,
      "valid_descriptor" => descriptor && diagnostics.empty?
    }
  end

  def validate_descriptor(descriptor)
    return [diagnostic("OOF-PR1", "progression.descriptor_missing", "progression_source")] unless descriptor.is_a?(Hash)

    diagnostics = []
    REQUIRED_FIELDS.each do |field|
      diagnostics << diagnostic("OOF-PR1", "progression.required_field_missing", field) unless descriptor.key?(field)
    end

    diagnostics << diagnostic("OOF-PR1", "progression.source_descriptor_invalid_kind", "kind") unless
      descriptor["kind"] == "progression_source"
    diagnostics << diagnostic("OOF-PR9", "progression.source_kind_unsupported", "source_kind") unless
      ALLOWED_SOURCE_KINDS.include?(descriptor["source_kind"])

    validate_materialization_policy(descriptor["materialization_policy"], diagnostics)
    validate_liveness(descriptor["liveness"], diagnostics)
    validate_receipt_policy(descriptor["receipt_policy"], diagnostics)
    validate_caps(descriptor.fetch("required_caps", []), diagnostics)
    validate_runtime_boundary(descriptor, diagnostics)
    diagnostics
  end

  def validate_materialization_policy(policy, diagnostics)
    unless policy.is_a?(Hash)
      diagnostics << diagnostic("OOF-PR2", "progression.materialization_policy_missing", "materialization_policy")
      return
    end

    diagnostics << diagnostic("OOF-PR2", "progression.materialization_unbounded", "materialization_policy.mode") unless
      ALLOWED_MATERIALIZATION_MODES.include?(policy["mode"])
    diagnostics << diagnostic("OOF-PR2", "progression.materialization_batch_unbounded", "materialization_policy.max_batch_size") unless
      positive_integer?(policy["max_batch_size"])
    diagnostics << diagnostic("OOF-PR2", "progression.materialization_inflight_unbounded", "materialization_policy.max_in_flight") unless
      positive_integer?(policy["max_in_flight"])
    diagnostics << diagnostic("OOF-PR2", "progression.backpressure_policy_invalid", "materialization_policy.backpressure") unless
      ALLOWED_BACKPRESSURE.include?(policy["backpressure"])
  end

  def validate_liveness(liveness, diagnostics)
    unless liveness.is_a?(Hash)
      diagnostics << diagnostic("OOF-PR3", "progression.cancellation_missing", "liveness.cancellation")
      diagnostics << diagnostic("OOF-PR4", "progression.checkpoint_missing", "liveness.checkpoint")
      diagnostics << diagnostic("OOF-PR5", "progression.bounded_step_missing", "liveness.max_step_latency")
      return
    end

    diagnostics << diagnostic("OOF-PR3", "progression.cancellation_missing", "liveness.cancellation") unless
      liveness["cancellation"] == "required"
    checkpoint = liveness["checkpoint"]
    unless checkpoint.is_a?(Hash) && checkpoint["required"] == true &&
           string_present?(checkpoint["every"]) && checkpoint["resume"] == "from_checkpoint"
      diagnostics << diagnostic("OOF-PR4", "progression.checkpoint_missing", "liveness.checkpoint")
    end
    diagnostics << diagnostic("OOF-PR5", "progression.bounded_step_missing", "liveness.max_step_latency") unless
      bounded_step?(liveness["max_step_latency"])
  end

  def validate_receipt_policy(policy, diagnostics)
    return if policy.is_a?(Hash) && policy["required"] == true && string_present?(policy["sink_ref"])

    diagnostics << diagnostic("OOF-PR7", "progression.receipt_policy_missing", "receipt_policy")
  end

  def validate_caps(caps, diagnostics)
    missing = REQUIRED_CAPS - caps
    return if missing.empty?

    diagnostics << diagnostic("OOF-PR9", "progression.capability_missing", missing.join(","))
  end

  def validate_runtime_boundary(descriptor, diagnostics)
    diagnostics << diagnostic("PROP-037-NONAUTH", "progression.runtime_execution_not_authorized", "runtime_authority") unless
      descriptor["runtime_authority"] == "not_authorized"

    forbidden = descriptor.fetch("runtime_binding", {}).select do |key, value|
      [
        "runtime_machine_scheduler",
        "ledger",
        "tbackend",
        "durable_queue",
        "durable_checkpoint",
        "receipt_sink_implementation",
        "production_cache",
        "production_execution",
        "progression_pack_dispatch"
      ].include?(key) && value == true
    end
    return if forbidden.empty?

    diagnostics << diagnostic("PROP-037-NONAUTH", "progression.runtime_binding_not_authorized", forbidden.keys.join(","))
  end

  def compiler_report(diagnostics, descriptor_hash)
    pass_result = diagnostics.empty? ? "ok" : "oof"
    {
      "kind" => "compilation_report",
      "format_version" => "0.1.0",
      "pass_result" => pass_result,
      "semantic_ir_ref" => nil,
      "semantic_ir_emitted" => false,
      "descriptor_ref" => descriptor_hash,
      "diagnostics" => diagnostics
    }
  end

  def runtime_readiness(descriptor, diagnostics)
    return nil unless descriptor.is_a?(Hash) && diagnostics.empty?

    {
      "progression_profile_status" => "present",
      "progression_runtime_readiness" => {
        "ready" => false,
        "reason" => READINESS_REFUSAL
      }
    }
  end

  def readiness_summary(result)
    readiness = result.fetch("runtime_readiness")
    {
      "valid_descriptor_has_no_oof" => result.dig("compiler_report", "diagnostics").empty?,
      "runtime_readiness_ready" => readiness.dig("progression_runtime_readiness", "ready"),
      "runtime_readiness_reason" => readiness.dig("progression_runtime_readiness", "reason"),
      "no_live_call_invariant" => result.fetch("no_live_call_invariant")
    }
  end

  def no_live_call_invariant
    {
      "progression_scheduler_call_attempted" => false,
      "progression_materializer_call_attempted" => false,
      "progression_receipt_sink_call_attempted" => false,
      "durable_checkpoint_call_attempted" => false,
      "ledger_call_attempted" => false,
      "tbackend_call_attempted" => false,
      "production_cache_call_attempted" => false,
      "progression_pack_dispatch_attempted" => false
    }
  end

  def build_checks(positives, negatives, readiness_case)
    positive_source_kinds = positives.keys.map do |name|
      valid_descriptors.fetch(name).fetch("source_kind")
    end
    negative_codes = negatives.transform_values { |result| diagnostic_codes(result) }
    readiness = readiness_case.fetch("runtime_readiness")
    {
      "valid_descriptors_pass_without_oof" => positives.values.all? { |result| diagnostic_codes(result).empty? },
      "valid_descriptors_cover_source_kinds" => positive_source_kinds.sort == ALLOWED_SOURCE_KINDS.sort,
      "valid_descriptors_runtime_readiness_refuses_separately" => positives.values.all? do |result|
        result.fetch("runtime_readiness").dig("progression_runtime_readiness", "reason") == READINESS_REFUSAL
      end,
      "oof_pr1_missing_source_descriptor" => negative_codes.fetch("missing_source_descriptor") == ["OOF-PR1"],
      "oof_pr2_unbounded_materialization" => negative_codes.fetch("unbounded_materialization").include?("OOF-PR2"),
      "oof_pr3_missing_cancellation" => negative_codes.fetch("missing_cancellation") == ["OOF-PR3"],
      "oof_pr4_missing_checkpoint_for_resumable" => negative_codes.fetch("missing_checkpoint_for_resumable") == ["OOF-PR4"],
      "oof_pr5_missing_max_step_latency_error" => negative_rule_has_error?(negatives.fetch("missing_max_step_latency"), "OOF-PR5"),
      "oof_pr7_missing_receipt_policy" => negative_codes.fetch("missing_receipt_policy") == ["OOF-PR7"],
      "oof_pr9_unsupported_source_kind" => negative_codes.fetch("unsupported_source_kind") == ["OOF-PR9"],
      "runtime_readiness_refusal_is_not_oof" => diagnostic_codes(readiness_case).empty? &&
        readiness.dig("progression_runtime_readiness", "ready") == false &&
        readiness.dig("progression_runtime_readiness", "reason") == READINESS_REFUSAL,
      "no_live_calls_attempted" => (positives.values + negatives.values).all? do |result|
        result.fetch("no_live_call_invariant").values.none?
      end,
      "no_progression_fragment_class_or_runtime_binding" => positives.values.all? do |result|
        descriptor_hash = result.fetch("descriptor_hash")
        valid_descriptors.values.any? do |descriptor|
          descriptor.fetch("descriptor_hash") == descriptor_hash &&
            !descriptor.key?("fragment_class") &&
            descriptor.fetch("runtime_binding").values.none?
        end
      end
    }
  end

  def diagnostic_codes(result)
    result.dig("compiler_report", "diagnostics").map { |diagnostic| diagnostic.fetch("rule") }
  end

  def negative_rule_has_error?(result, rule)
    result.dig("compiler_report", "diagnostics").any? do |diagnostic|
      diagnostic.fetch("rule") == rule && diagnostic.fetch("severity") == "error"
    end
  end

  def diagnostic(rule, reason, path)
    {
      "rule" => rule,
      "severity" => "error",
      "message" => diagnostic_message(rule),
      "node" => "progression_source",
      "path" => path,
      "category" => "progression_oof",
      "reason" => reason
    }
  end

  def diagnostic_message(rule)
    {
      "OOF-PR1" => "Progression requires an explicit source descriptor.",
      "OOF-PR2" => "Progression materialization must be bounded.",
      "OOF-PR3" => "Service progression requires cancellation semantics.",
      "OOF-PR4" => "Resumable progression requires checkpoint semantics.",
      "OOF-PR5" => "Service progression requires bounded-step policy such as max_step_latency.",
      "OOF-PR7" => "Progression requires step receipt policy.",
      "OOF-PR9" => "Progression source kind or capability is not supported.",
      "PROP-037-NONAUTH" => "PROP-037 does not authorize this runtime or fragment-class claim."
    }.fetch(rule)
  end

  def descriptor_hash(descriptor)
    Canonical.hash(descriptor.reject { |key, _value| key == "descriptor_hash" })
  end

  def positive_integer?(value)
    value.is_a?(Integer) && value.positive?
  end

  def string_present?(value)
    value.is_a?(String) && !value.empty?
  end

  def bounded_step?(value)
    string_present?(value) && value.match?(/\A\d+(ms|s|m)\z/)
  end

  def descriptor_contract
    {
      "descriptor_version" => DESCRIPTOR_VERSION,
      "closed_source_kind_vocabulary" => ALLOWED_SOURCE_KINDS,
      "allowed_materialization_modes" => ALLOWED_MATERIALIZATION_MODES,
      "allowed_backpressure" => ALLOWED_BACKPRESSURE,
      "required_fields" => REQUIRED_FIELDS,
      "required_caps" => REQUIRED_CAPS,
      "oof_rules_proven" => ["OOF-PR1", "OOF-PR2", "OOF-PR3", "OOF-PR4", "OOF-PR5", "OOF-PR7", "OOF-PR9"],
      "deferred_rules" => ["OOF-PR6", "OOF-PR8"]
    }
  end

  def scope_boundary
    {
      "proof_local_descriptor_validation" => true,
      "parser_implementation" => false,
      "typechecker_implementation" => false,
      "semanticir_implementation" => false,
      "assembler_igapp_changes" => false,
      "runtime_machine_scheduler" => false,
      "ledger_tbackend_binding" => false,
      "durable_queues" => false,
      "durable_checkpoints" => false,
      "receipt_sink_implementation" => false,
      "production_cache" => false,
      "production_execution" => false,
      "progression_pack_migration" => false,
      "progression_fragment_class" => false
    }
  end

  def remaining_gaps
    [
      {
        "layer" => "Parser",
        "gap" => "accepted service-loop/progression source syntax and parser implementation authorization"
      },
      {
        "layer" => "Classifier/TypeChecker",
        "gap" => "compiler-owned progression AST/typed descriptor boundary; OOF-PR6 and OOF-PR8 need fragment context"
      },
      {
        "layer" => "SemanticIR",
        "gap" => "accepted progression node/artifact shape and golden fixture plan"
      },
      {
        "layer" => "Assembler/.igapp",
        "gap" => "manifest schema authorization for progression_sources; no real .igapp mutation yet"
      },
      {
        "layer" => "CompatibilityReport",
        "gap" => "readiness proof may consume valid descriptors while keeping runtime readiness false"
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
        "gap" => "separate binding decision; not implied by progression"
      },
      {
        "layer" => "Production execution",
        "gap" => "explicit runtime/production gate"
      },
      {
        "layer" => "ProgressionPack",
        "gap" => "compiler profile/pack migration authorization"
      }
    ]
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} prop037_descriptor_oof_pr_proof"
    summary.fetch("checks").each do |name, passed|
      puts "#{name}: #{passed ? "ok" : "fail"}"
    end
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

exit(Prop037DescriptorOofPrProof.run ? 0 : 1)
