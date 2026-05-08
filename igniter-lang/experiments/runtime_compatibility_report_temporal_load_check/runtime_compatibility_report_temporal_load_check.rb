#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "digest"
require "json"
require "pathname"

require_relative "../../lib/igniter_lang/assembler"
require_relative "../runtime_machine_memory_proof/compiled_program"

module RuntimeCompatibilityReportTemporalLoadCheckProof
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  GOLDEN_DIR = ROOT / "igniter-lang/experiments/temporal_semanticir_access_node/golden"
  OUT_DIR = ROOT / "igniter-lang/experiments/runtime_compatibility_report_temporal_load_check/out"
  ASSEMBLED_DIR = OUT_DIR / "assembled"
  SUMMARY_PATH = OUT_DIR / "runtime_compatibility_report_temporal_load_check_summary.json"
  PROOF_AS_OF = "2026-05-08T00:00:00Z"

  CASES = [
    {
      "id" => "history_valid",
      "contract_id" => "HistoryAxesTest",
      "expected_capability" => "history_read",
      "expected_axes" => ["valid_time"]
    },
    {
      "id" => "bihistory_valid",
      "contract_id" => "BiHistoryAxesTest",
      "expected_capability" => "bihistory_read",
      "expected_axes" => %w[valid_time transaction_time]
    }
  ].freeze

  RUNTIME_PROFILES = {
    "missing_tbackend_capability" => {
      "profile_id" => "runtime-profile/missing-tbackend-capability",
      "tbackend_capabilities" => [],
      "live_tbackend_binding" => false,
      "temporal_executor" => false,
      "executor_approval" => "none",
      "gate3_authorized" => false
    },
    "metadata_capability_no_executor" => {
      "profile_id" => "runtime-profile/metadata-capability-no-executor",
      "tbackend_capabilities" => %w[history_read bihistory_read],
      "live_tbackend_binding" => false,
      "temporal_executor" => false,
      "executor_approval" => "none",
      "gate3_authorized" => false
    },
    "claimed_executor_live_binding" => {
      "profile_id" => "runtime-profile/claimed-executor-live-binding",
      "tbackend_capabilities" => %w[history_read bihistory_read],
      "live_tbackend_binding" => true,
      "temporal_executor" => true,
      "executor_approval" => "none",
      "gate3_authorized" => false
    },
    "approved_executor_placeholder" => {
      "profile_id" => "runtime-profile/approved-executor-placeholder",
      "tbackend_capabilities" => %w[history_read bihistory_read],
      "live_tbackend_binding" => true,
      "temporal_executor" => true,
      "executor_approval" => "approved_placeholder",
      "gate3_authorized" => false
    }
  }.freeze

  class CompatibilityReporter
    def initialize(runtime_profile:)
      @runtime_profile = runtime_profile
    end

    def report_for(igapp_path)
      program = RuntimeMachineMemoryProof::CompiledProgram.load_igapp(igapp_path)
      program.validate!
      compatibility_metadata = read_json(Pathname.new(igapp_path) / "compatibility_metadata.json")
      evidence = temporal_evidence(program, compatibility_metadata)
      bundle_load = bundle_load_check(evidence)
      evaluation_readiness = evaluation_readiness_check(evidence)
      checks = checks_for(evidence, bundle_load, evaluation_readiness)

      report = {
        "kind" => "compatibility_report",
        "format_version" => "0.1.0",
        "report_id" => report_id(program.program_id, @runtime_profile.fetch("profile_id")),
        "track" => "runtime-compatibility-report-temporal-load-check-v0",
        "as_of" => PROOF_AS_OF,
        "program_id" => program.program_id,
        "runtime_profile" => @runtime_profile,
        "report_only" => true,
        "runtime_enforced" => false,
        "overall" => evaluation_readiness.fetch("decision"),
        "bundle_load" => bundle_load,
        "runtime_check" => {
          "decision" => "trusted",
          "reason_code" => "runtime.artifact_shape_verified"
        },
        "backend_check" => {
          "decision" => evaluation_readiness.fetch("decision"),
          "reason_code" => evaluation_readiness.fetch("reason_code"),
          "report_only" => true,
          "runtime_enforced" => false,
          "required_capabilities" => evidence.fetch("required_capabilities"),
          "available_capabilities" => @runtime_profile.fetch("tbackend_capabilities"),
          "missing_capabilities" => evidence.fetch("required_capabilities") -
            @runtime_profile.fetch("tbackend_capabilities"),
          "live_tbackend_binding" => @runtime_profile.fetch("live_tbackend_binding"),
          "temporal_executor" => @runtime_profile.fetch("temporal_executor")
        },
        "schema_check" => {
          "decision" => "not_evaluated_here",
          "independent_from_temporal_backend_check" => true
        },
        "cache_check" => {
          "decision" => evidence.fetch("cache_key_schema_hint_fragments").all?("TEMPORAL") ? "trusted" : "blocked",
          "cache_enabled" => false,
          "runtime_cache_binding" => false
        },
        "operation_check" => {
          "decision" => "not_attempted",
          "temporal_executor_call_attempted" => false,
          "live_tbackend_call_attempted" => false,
          "ledger_call_attempted" => false,
          "gate3_authorized" => @runtime_profile.fetch("gate3_authorized")
        },
        "observation_check" => {
          "decision" => "trusted",
          "source" => "assembled temporal ContractIR inspection"
        },
        "evaluation_readiness" => evaluation_readiness,
        "evidence" => evidence,
        "checks" => checks
      }
      report.merge("report_hash" => canonical_hash(report))
    rescue RuntimeMachineMemoryProof::ValidationError, ArgumentError, KeyError, JSON::ParserError => e
      load_blocked_report(igapp_path, e)
    end

    private

    def temporal_evidence(program, compatibility_metadata)
      manifest = program.manifest
      fragment_summary = manifest.fetch("fragment_summary")
      contract_index = manifest.fetch("contract_index")
      guard_policy = compatibility_metadata.fetch("runtime_execution")
      temporal_contracts = contract_index.select { |_contract_id, entry| entry.fetch("fragment_class") == "temporal" }
      temporal_entries = temporal_contracts.values.map { |entry| entry.fetch("temporal") }

      {
        "manifest_fragment_summary" => fragment_summary,
        "contract_index_contracts" => temporal_contracts.keys.sort,
        "contract_index_temporal_entries" => temporal_contracts,
        "guard_policy" => guard_policy,
        "required_capabilities" => temporal_entries.flat_map { |entry| entry.fetch("required_capabilities", []) }.uniq.sort,
        "axes" => temporal_entries.flat_map { |entry| entry.fetch("axes", []) }.uniq.sort,
        "coordinates" => temporal_entries.flat_map { |entry| entry.fetch("coordinates", []) },
        "cache_key_schema_hint_fragments" => temporal_entries.map do |entry|
          entry.fetch("cache_key_schema_hint", {}).fetch("fragment", nil)
        end.compact.uniq.sort,
        "max_fragment_class" => fragment_summary.fetch("max_fragment_class")
      }
    end

    def bundle_load_check(evidence)
      guard = evidence.fetch("guard_policy")
      {
        "decision" => guard.dig("load", "decision") || "accepted_for_inspection",
        "blocked" => false,
        "requires_contract_index" => guard.dig("load", "requires_contract_index"),
        "guard_policy" => guard.fetch("guard_policy"),
        "guard_at" => guard.fetch("guard_at"),
        "reason_code" => "runtime.temporal_bundle_load_accepted_for_inspection"
      }
    end

    def evaluation_readiness_check(evidence)
      required = evidence.fetch("required_capabilities")
      available = @runtime_profile.fetch("tbackend_capabilities")
      missing = required - available
      if missing.any?
        return {
          "decision" => "blocked",
          "blocked" => true,
          "blocks_bundle_load" => false,
          "reason_code" => "runtime.temporal_capability_missing",
          "missing_capabilities" => missing,
          "guard_at" => "evaluate"
        }
      end

      unless @runtime_profile.fetch("live_tbackend_binding") && @runtime_profile.fetch("temporal_executor")
        return {
          "decision" => "blocked",
          "blocked" => true,
          "blocks_bundle_load" => false,
          "reason_code" => evidence.dig("guard_policy", "evaluate", "reason_code") ||
            "runtime.temporal_execution_unsupported",
          "missing_capabilities" => [],
          "guard_at" => "evaluate"
        }
      end

      unless @runtime_profile.fetch("executor_approval") == "approved_placeholder"
        return {
          "decision" => "blocked",
          "blocked" => true,
          "blocks_bundle_load" => false,
          "reason_code" => "runtime.temporal_executor_approval_missing",
          "missing_capabilities" => [],
          "guard_at" => "evaluate",
          "approval_state" => @runtime_profile.fetch("executor_approval"),
          "gate3_authorized" => @runtime_profile.fetch("gate3_authorized")
        }
      end

      unless @runtime_profile.fetch("gate3_authorized") == true
        return {
          "decision" => "blocked",
          "blocked" => true,
          "blocks_bundle_load" => false,
          "reason_code" => "runtime.temporal_gate3_closed",
          "missing_capabilities" => [],
          "guard_at" => "evaluate",
          "approval_state" => @runtime_profile.fetch("executor_approval"),
          "gate3_authorized" => @runtime_profile.fetch("gate3_authorized"),
          "guard_policy" => evidence.dig("guard_policy", "guard_policy")
        }
      end

      if evidence.dig("guard_policy", "evaluate", "decision") == "refuse_temporal_contract"
        return {
          "decision" => "blocked",
          "blocked" => true,
          "blocks_bundle_load" => false,
          "reason_code" => evidence.dig("guard_policy", "evaluate", "reason_code") ||
            "runtime.temporal_execution_unsupported",
          "missing_capabilities" => [],
          "guard_at" => "evaluate",
          "approval_state" => @runtime_profile.fetch("executor_approval"),
          "gate3_authorized" => @runtime_profile.fetch("gate3_authorized"),
          "blocked_by" => "artifact_guard_policy"
        }
      end

      {
        "decision" => "trusted",
        "blocked" => false,
        "blocks_bundle_load" => false,
        "reason_code" => "runtime.temporal_evaluation_ready",
        "missing_capabilities" => [],
        "guard_at" => "evaluate"
      }
    end

    def checks_for(evidence, bundle_load, evaluation_readiness)
      {
        "manifest.fragment_summary_consumed" => evidence.fetch("max_fragment_class") == "temporal",
        "manifest.contract_index_consumed" => !evidence.fetch("contract_index_contracts").empty?,
        "guard_policy.consumed" => evidence.dig("guard_policy", "guard_policy") == "load_accept_evaluate_refuse",
        "temporal.requires_tbackend_capability" => !evidence.fetch("required_capabilities").empty?,
        "bundle_load.accepted_for_inspection" => bundle_load.fetch("decision") == "accept_for_inspection" &&
          bundle_load.fetch("blocked") == false,
        "evaluation_readiness.blocks_without_blocking_load" => evaluation_readiness.fetch("blocked") == true &&
          evaluation_readiness.fetch("blocks_bundle_load") == false,
        "report_only.no_runtime_operation" => true
      }
    end

    def load_blocked_report(igapp_path, error)
      {
        "kind" => "compatibility_report",
        "format_version" => "0.1.0",
        "track" => "runtime-compatibility-report-temporal-load-check-v0",
        "as_of" => PROOF_AS_OF,
        "report_only" => true,
        "runtime_enforced" => false,
        "overall" => "blocked",
        "bundle_load" => {
          "decision" => "blocked",
          "blocked" => true,
          "reason_code" => "runtime.artifact_load_blocked",
          "path" => Pathname.new(igapp_path).relative_path_from(ROOT).to_s,
          "error" => "#{error.class}: #{error.message}"
        },
        "evaluation_readiness" => {
          "decision" => "blocked",
          "blocked" => true,
          "blocks_bundle_load" => true,
          "reason_code" => "runtime.artifact_load_blocked"
        },
        "checks" => {
          "bundle_load.accepted_for_inspection" => false
        }
      }
    end

    def report_id(program_id, profile_id)
      "compatibility_report/#{short_hash("#{program_id}/#{profile_id}")}"
    end

    def canonical_hash(value)
      "sha256:#{Digest::SHA256.hexdigest(JSON.generate(canonical(value)))}"
    end

    def short_hash(value)
      Digest::SHA256.hexdigest(value)[0, 24]
    end

    def canonical(value)
      case value
      when Hash
        value.keys.sort_by(&:to_s).each_with_object({}) { |key, out| out[key.to_s] = canonical(value[key]) }
      when Array
        value.map { |item| canonical(item) }
      else
        value
      end
    end

    def read_json(path)
      JSON.parse(File.read(path))
    end
  end

  module_function

  def run
    assemble_temporal_artifacts
    cases = build_cases
    checks = build_checks(cases)
    summary = {
      "kind" => "runtime_compatibility_report_temporal_load_check_summary",
      "format_version" => "0.1.0",
      "card" => "S3-R7-C1-P",
      "track" => "runtime-compatibility-report-temporal-load-check-v0",
      "extension_card" => "S3-R8-C2-P",
      "extension_track" => "runtime-compatibility-report-executor-boundary-v0",
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "report_boundary" => {
        "bundle_loading" => "accepted_for_inspection",
        "evaluation_readiness" => "blocked when capability, executor/live binding, approval, Gate 3, or artifact guard_policy is absent/refusing",
        "report_only" => true,
        "runtime_enforced" => false,
        "ledger_binding" => false,
        "temporal_execution" => false
      },
      "decision_table" => {
        "missing_caps" => "blocked: runtime.temporal_capability_missing",
        "metadata_caps" => "blocked: runtime.temporal_execution_unsupported",
        "claimed_executor" => "blocked: runtime.temporal_executor_approval_missing",
        "approved_executor_placeholder" => "blocked: runtime.temporal_gate3_closed"
      },
      "cases" => cases,
      "checks" => checks
    }
    write_json(SUMMARY_PATH, summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def assemble_temporal_artifacts
    FileUtils.rm_rf(ASSEMBLED_DIR)
    assembler = IgniterLang::Assembler.new(golden_dir: GOLDEN_DIR, out_dir: ASSEMBLED_DIR)
    CASES.each { |config| assembler.assemble_case(config.fetch("id")) }
  end

  def build_cases
    CASES.to_h do |config|
      igapp_path = ASSEMBLED_DIR / "#{config.fetch("id")}.igapp"
      reports = RUNTIME_PROFILES.transform_values do |profile|
        CompatibilityReporter.new(runtime_profile: profile).report_for(igapp_path)
      end
      [config.fetch("id"), {
        "artifact_path" => igapp_path.relative_path_from(ROOT).to_s,
        "contract_id" => config.fetch("contract_id"),
        "expected_capability" => config.fetch("expected_capability"),
        "expected_axes" => config.fetch("expected_axes"),
        "reports" => reports
      }]
    end
  end

  def build_checks(cases)
    CASES.each_with_object({}) do |config, checks|
      id = config.fetch("id")
      result = cases.fetch(id)
      missing_report = result.dig("reports", "missing_tbackend_capability")
      metadata_report = result.dig("reports", "metadata_capability_no_executor")
      claimed_executor_report = result.dig("reports", "claimed_executor_live_binding")
      approved_placeholder_report = result.dig("reports", "approved_executor_placeholder")
      all_reports = result.fetch("reports").values

      checks["#{id}.report_consumes_fragment_summary"] =
        missing_report.dig("checks", "manifest.fragment_summary_consumed") == true
      checks["#{id}.report_consumes_contract_index"] =
        missing_report.dig("checks", "manifest.contract_index_consumed") == true
      checks["#{id}.report_consumes_guard_policy"] =
        missing_report.dig("checks", "guard_policy.consumed") == true
      checks["#{id}.detects_required_tbackend_capability"] =
        missing_report.dig("backend_check", "required_capabilities").include?(config.fetch("expected_capability"))
      checks["#{id}.detects_temporal_axes"] =
        missing_report.dig("evidence", "axes").sort == config.fetch("expected_axes").sort
      checks["#{id}.missing_capability_blocks_evaluation_not_load"] =
        missing_report.dig("bundle_load", "decision") == "accept_for_inspection" &&
          missing_report.dig("evaluation_readiness", "reason_code") == "runtime.temporal_capability_missing" &&
          missing_report.dig("evaluation_readiness", "blocks_bundle_load") == false
      checks["#{id}.capability_metadata_still_blocks_without_executor"] =
        metadata_report.dig("bundle_load", "decision") == "accept_for_inspection" &&
          metadata_report.dig("backend_check", "missing_capabilities").empty? &&
          metadata_report.dig("evaluation_readiness", "reason_code") == "runtime.temporal_execution_unsupported"
      checks["#{id}.claimed_executor_still_needs_approval"] =
        claimed_executor_report.dig("bundle_load", "decision") == "accept_for_inspection" &&
          claimed_executor_report.dig("backend_check", "missing_capabilities").empty? &&
          claimed_executor_report.dig("backend_check", "live_tbackend_binding") == true &&
          claimed_executor_report.dig("backend_check", "temporal_executor") == true &&
          claimed_executor_report.dig("evaluation_readiness", "reason_code") == "runtime.temporal_executor_approval_missing"
      checks["#{id}.approved_placeholder_still_blocks_gate3_closed"] =
        approved_placeholder_report.dig("bundle_load", "decision") == "accept_for_inspection" &&
          approved_placeholder_report.dig("backend_check", "missing_capabilities").empty? &&
          approved_placeholder_report.dig("evaluation_readiness", "reason_code") == "runtime.temporal_gate3_closed" &&
          approved_placeholder_report.dig("operation_check", "gate3_authorized") == false
      checks["#{id}.capability_flags_alone_do_not_bypass_guard_policy"] =
        all_reports.all? do |report|
          report.fetch("overall") == "blocked" &&
            report.dig("checks", "guard_policy.consumed") == true &&
            report.dig("evaluation_readiness", "blocks_bundle_load") == false
        end
      checks["#{id}.no_profile_attempts_live_operation"] =
        all_reports.all? do |report|
          report.dig("operation_check", "temporal_executor_call_attempted") == false &&
            report.dig("operation_check", "live_tbackend_call_attempted") == false &&
            report.dig("operation_check", "ledger_call_attempted") == false
        end
      checks["#{id}.report_only_no_runtime_enforcement"] =
        all_reports.all? do |report|
          report.fetch("report_only") == true &&
            report.fetch("runtime_enforced") == false
        end
    end
  end

  def write_json(path, value)
    FileUtils.mkdir_p(path.dirname)
    File.write(path, "#{JSON.pretty_generate(value)}\n")
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} runtime_compatibility_report_temporal_load_check"
    summary.fetch("checks").each do |name, ok|
      puts "#{name}: #{ok ? "ok" : "FAIL"}"
    end
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = RuntimeCompatibilityReportTemporalLoadCheckProof.run
exit(success ? 0 : 1)
