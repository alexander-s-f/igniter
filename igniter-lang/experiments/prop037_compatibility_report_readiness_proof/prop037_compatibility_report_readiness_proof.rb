#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "pathname"

module Prop037CompatibilityReportReadinessProof
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  OUT_DIR = ROOT / "igniter-lang/experiments/prop037_compatibility_report_readiness_proof"
  SUMMARY_PATH = OUT_DIR / "prop037_compatibility_report_readiness_proof_summary.json"

  DESCRIPTOR_VERSION = "prop037-progression-source-descriptor-v0"
  READINESS_REFUSAL = "progression.runtime_execution_not_authorized"
  ALLOWED_SOURCE_KINDS = ["clock.every", "queue", "external_event"].freeze
  REQUIRED_CAPS = [
    "progression_materialize",
    "progression_step_execute",
    "progression_step_receipt",
    "progression_cancel",
    "progression_checkpoint_resume"
  ].freeze
  LIVE_CALL_FLAGS = [
    "progression_scheduler_call_attempted",
    "progression_materializer_call_attempted",
    "progression_receipt_sink_call_attempted",
    "durable_queue_call_attempted",
    "durable_checkpoint_call_attempted",
    "ledger_call_attempted",
    "tbackend_call_attempted",
    "production_cache_call_attempted",
    "checkpoint_persistence_call_attempted",
    "progression_pack_dispatch_attempted"
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
    reports = descriptors.transform_values { |descriptor| compatibility_report_for(descriptor) }
    checks = build_checks(descriptors, reports)
    summary = {
      "kind" => "prop037_compatibility_report_readiness_proof",
      "format_version" => "0.1.0",
      "card" => "S3-R41-C1-P1",
      "track" => "prop037-compatibility-report-readiness-proof-v0",
      "proposal" => {
        "id" => "PROP-037",
        "status" => "accepted-proposal-only",
        "source" => "igniter-lang/docs/proposals/PROP-037-external-progression-service-liveness-v0.md"
      },
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "scope" => scope_boundary,
      "runtime_readiness_refusal" => READINESS_REFUSAL,
      "valid_descriptors" => descriptors,
      "compatibility_reports" => reports,
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

  def compatibility_report_for(descriptor)
    descriptor_validation = validate_descriptor(descriptor)
    descriptor_hash = descriptor.fetch("descriptor_hash")
    {
      "kind" => "compatibility_report",
      "format_version" => "0.1.0",
      "report_id" => Canonical.hash(
        "prop037_compatibility_report" => descriptor_hash,
        "readiness_refusal" => READINESS_REFUSAL
      ),
      "proposal_ref" => "PROP-037",
      "artifact_ref" => "proof-local/progression_descriptor/#{descriptor_hash}",
      "report_mode" => "report_only",
      "descriptor_profile" => {
        "progression_profile_status" => "present",
        "descriptor_version" => descriptor.fetch("descriptor_version"),
        "descriptor_ref" => descriptor_hash,
        "progression_ref" => descriptor.fetch("progression_ref"),
        "source_kind" => descriptor.fetch("source_kind"),
        "source_ref" => descriptor.fetch("source_ref"),
        "payload_type" => descriptor.fetch("payload_type"),
        "materialization_policy" => descriptor.fetch("materialization_policy"),
        "liveness" => descriptor.fetch("liveness"),
        "receipt_policy" => descriptor.fetch("receipt_policy"),
        "required_caps" => descriptor.fetch("required_caps")
      },
      "compiler_oof" => {
        "pass_result" => descriptor_validation.empty? ? "ok" : "oof",
        "diagnostics" => descriptor_validation
      },
      "progression_runtime_readiness" => {
        "ready" => false,
        "reason" => READINESS_REFUSAL,
        "guard_at" => "runtime_readiness",
        "separate_from_compiler_oof" => true
      },
      "runtime_invocation_attempts" => live_call_invariant,
      "non_authorization" => non_authorization
    }
  end

  def validate_descriptor(descriptor)
    diagnostics = []
    diagnostics << diagnostic("OOF-PR1", "progression.source_descriptor_invalid_kind", "kind") unless
      descriptor["kind"] == "progression_source"
    diagnostics << diagnostic("OOF-PR9", "progression.source_kind_unsupported", "source_kind") unless
      ALLOWED_SOURCE_KINDS.include?(descriptor["source_kind"])
    diagnostics << diagnostic("OOF-PR9", "progression.capability_missing", "required_caps") unless
      (REQUIRED_CAPS - descriptor.fetch("required_caps", [])).empty?
    diagnostics << diagnostic("PROP-037-NONAUTH", "progression.runtime_execution_claimed", "runtime_authority") unless
      descriptor["runtime_authority"] == "not_authorized"
    diagnostics
  end

  def diagnostic(rule, reason, path)
    {
      "rule" => rule,
      "severity" => "error",
      "category" => "progression_oof",
      "reason" => reason,
      "path" => path
    }
  end

  def live_call_invariant
    LIVE_CALL_FLAGS.each_with_object({}) { |flag, out| out[flag] = false }
  end

  def non_authorization
    {
      "parser_implementation" => false,
      "typechecker_implementation" => false,
      "semanticir_implementation" => false,
      "assembler_igapp_changes" => false,
      "runtime_machine_scheduler" => false,
      "progression_materializer" => false,
      "ledger_tbackend_binding" => false,
      "durable_queue" => false,
      "durable_checkpoint" => false,
      "receipt_sink_implementation" => false,
      "checkpoint_persistence" => false,
      "production_execution" => false,
      "progression_fragment_class" => false
    }
  end

  def build_checks(descriptors, reports)
    source_kinds = descriptors.values.map { |descriptor| descriptor.fetch("source_kind") }.sort
    {
      "valid_descriptors_all_present" => reports.keys.sort == descriptors.keys.sort,
      "descriptor_metadata_present" => reports.values.all? { |report| descriptor_metadata_present?(report) },
      "valid_descriptors_have_no_oof" => reports.values.all? { |report| report.dig("compiler_oof", "diagnostics").empty? },
      "runtime_readiness_false" => reports.values.all? { |report| report.dig("progression_runtime_readiness", "ready") == false },
      "runtime_refusal_code_stable" => reports.values.all? do |report|
        report.dig("progression_runtime_readiness", "reason") == READINESS_REFUSAL
      end,
      "runtime_refusal_separate_from_compiler_oof" => reports.values.all? do |report|
        report.dig("compiler_oof", "pass_result") == "ok" &&
          report.dig("progression_runtime_readiness", "separate_from_compiler_oof") == true
      end,
      "no_scheduler_or_materializer_invocation" => reports.values.all? do |report|
        report.dig("runtime_invocation_attempts", "progression_scheduler_call_attempted") == false &&
          report.dig("runtime_invocation_attempts", "progression_materializer_call_attempted") == false
      end,
      "no_durable_or_external_runtime_invocation" => reports.values.all? do |report|
        [
          "ledger_call_attempted",
          "tbackend_call_attempted",
          "durable_queue_call_attempted",
          "durable_checkpoint_call_attempted",
          "progression_receipt_sink_call_attempted",
          "checkpoint_persistence_call_attempted"
        ].all? { |flag| report.dig("runtime_invocation_attempts", flag) == false }
      end,
      "no_progression_fragment_class_or_runtime_binding" => reports.values.all? do |report|
        report.fetch("non_authorization").values.none? && report.dig("descriptor_profile", "fragment_class").nil?
      end,
      "closed_source_kind_coverage" => source_kinds == ALLOWED_SOURCE_KINDS.sort
    }
  end

  def descriptor_metadata_present?(report)
    profile = report.fetch("descriptor_profile")
    [
      "progression_profile_status",
      "descriptor_ref",
      "progression_ref",
      "source_kind",
      "source_ref",
      "payload_type",
      "materialization_policy",
      "liveness",
      "receipt_policy",
      "required_caps"
    ].all? { |key| profile.key?(key) && !profile[key].nil? }
  end

  def descriptor_hash(descriptor)
    Canonical.hash(descriptor.reject { |key, _value| key == "descriptor_hash" })
  end

  def scope_boundary
    {
      "proof_local_compatibility_report_shape" => true,
      "parser_implementation" => false,
      "typechecker_implementation" => false,
      "semanticir_implementation" => false,
      "assembler_igapp_changes" => false,
      "runtime_machine_scheduler" => false,
      "progression_materializer" => false,
      "ledger_tbackend_binding" => false,
      "durable_queue" => false,
      "durable_checkpoint" => false,
      "receipt_sink_implementation" => false,
      "production_execution" => false,
      "progression_fragment_class" => false
    }
  end

  def remaining_gaps
    [
      {
        "layer" => "Parser",
        "gap" => "service-loop/progression source syntax and parser implementation remain unauthorized"
      },
      {
        "layer" => "Classifier/TypeChecker",
        "gap" => "compiler-owned progression AST/typed descriptor boundary; OOF-PR6 and OOF-PR8 still need fragment context"
      },
      {
        "layer" => "SemanticIR",
        "gap" => "progression node/artifact shape and golden fixture plan remain future work"
      },
      {
        "layer" => "Assembler/.igapp",
        "gap" => "manifest schema authorization for progression_sources remains blocked"
      },
      {
        "layer" => "RuntimeMachine",
        "gap" => "scheduler/materializer authority and proof-local implementation plan remain absent"
      },
      {
        "layer" => "Durability",
        "gap" => "durable queue/checkpoint/receipt sink design and authorization remain absent"
      },
      {
        "layer" => "Ledger/TBackend",
        "gap" => "separate binding decision required; progression metadata does not imply it"
      },
      {
        "layer" => "Production execution",
        "gap" => "explicit runtime/production gate required"
      },
      {
        "layer" => "ProgressionPack",
        "gap" => "compiler profile/pack migration authorization remains absent"
      }
    ]
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} prop037_compatibility_report_readiness_proof"
    summary.fetch("checks").each do |name, passed|
      puts "#{name}: #{passed ? "ok" : "fail"}"
    end
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

exit(Prop037CompatibilityReportReadinessProof.run ? 0 : 1)
