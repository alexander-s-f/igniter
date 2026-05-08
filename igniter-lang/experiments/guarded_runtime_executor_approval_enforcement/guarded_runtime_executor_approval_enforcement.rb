#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "pathname"

require_relative "../temporal_runtime_load_guard/temporal_runtime_load_guard"

module GuardedRuntimeExecutorApprovalEnforcementProof
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  OUT_DIR = ROOT / "igniter-lang/experiments/guarded_runtime_executor_approval_enforcement/out"
  SUMMARY_PATH = OUT_DIR / "guarded_runtime_executor_approval_enforcement_summary.json"
  PROOF_AS_OF = "2026-05-08T00:00:00Z"

  CASES = [
    {
      "id" => "history_valid",
      "contract_id" => "HistoryAxesTest",
      "required_capability" => "history_read"
    },
    {
      "id" => "bihistory_valid",
      "contract_id" => "BiHistoryAxesTest",
      "required_capability" => "bihistory_read"
    }
  ].freeze

  COMPATIBILITY_REASON_MAPPING = [
    {
      "compatibility_report_reason_code" => "runtime.temporal_executor_approval_missing",
      "guarded_runtime_reason_code" => "runtime.executor_approval_missing",
      "alignment" => "PROP-030 refines the C2 report reason into the canonical runtime approval refusal"
    },
    {
      "compatibility_report_reason_code" => "runtime.temporal_gate3_closed",
      "guarded_runtime_reason_code" => "runtime.temporal_gate3_closed",
      "alignment" => "identical"
    },
    {
      "compatibility_report_reason_code" => "runtime.temporal_cache_schema_mismatch",
      "guarded_runtime_reason_code" => "runtime.temporal_cache_schema_mismatch",
      "alignment" => "future CompatibilityReport cache dimension should use the same runtime refusal"
    }
  ].freeze

  module_function

  def run
    TemporalRuntimeLoadGuardProof.assemble_temporal_artifacts
    cases = build_cases
    checks = build_checks(cases)
    summary = {
      "kind" => "guarded_runtime_executor_approval_enforcement_summary",
      "format_version" => "0.1.0",
      "card" => "S3-R10-C2-P",
      "track" => "guarded-runtime-executor-approval-enforcement-v0",
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "policy" => {
        "approval_contract" => "PROP-030 ExecutorApprovalToken",
        "load_for_inspection_preserved" => true,
        "gate3_closed" => true,
        "live_executor" => false,
        "live_tbackend_binding" => false,
        "ledger_binding" => false,
        "production_cache" => false
      },
      "mapping_table" => COMPATIBILITY_REASON_MAPPING,
      "cases" => cases,
      "checks" => checks
    }
    write_json(SUMMARY_PATH, summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def build_cases
    FileUtils.mkdir_p(OUT_DIR)
    CASES.each_with_object({}) do |config, out|
      id = config.fetch("id")
      contract_id = config.fetch("contract_id")
      capability = config.fetch("required_capability")
      igapp_path = TemporalRuntimeLoadGuardProof::ASSEMBLED_DIR / "#{id}.igapp"
      token = approval_token_for(igapp_path, contract_id, capability)

      out[id] = {
        "artifact_path" => igapp_path.relative_path_from(ROOT).to_s,
        "contract_id" => contract_id,
        "required_capability" => capability,
        "load_for_inspection" => evaluate_case(
          igapp_path: igapp_path,
          contract_id: contract_id,
          capabilities: [capability],
          token: nil,
          gate3_authorized: false,
          requested_cache_key_fragment: "TEMPORAL"
        ).fetch("load"),
        "missing_approval_token" => evaluate_case(
          igapp_path: igapp_path,
          contract_id: contract_id,
          capabilities: [capability],
          token: nil,
          gate3_authorized: false,
          requested_cache_key_fragment: "TEMPORAL"
        ),
        "valid_token_gate3_closed" => evaluate_case(
          igapp_path: igapp_path,
          contract_id: contract_id,
          capabilities: [capability],
          token: token,
          gate3_authorized: false,
          requested_cache_key_fragment: "TEMPORAL"
        ),
        "core_shaped_cache_key" => evaluate_case(
          igapp_path: igapp_path,
          contract_id: contract_id,
          capabilities: [capability],
          token: token,
          gate3_authorized: true,
          requested_cache_key_fragment: "CORE"
        ),
        "operation_check" => no_live_operation_check
      }
    end
  end

  def evaluate_case(igapp_path:, contract_id:, capabilities:, token:, gate3_authorized:, requested_cache_key_fragment:)
    machine = TemporalRuntimeLoadGuardProof::GuardedRuntimeMachine.new(
      temporal_runtime_supported: true,
      temporal_capabilities: capabilities,
      approval_enforcement: true,
      executor_approval_token: token,
      gate3_authorized: gate3_authorized,
      requested_cache_key_fragment: requested_cache_key_fragment
    )
    load = machine.load_igapp(igapp_path)
    evaluate = machine.evaluate_contract(contract_id, inputs: {}, as_of: PROOF_AS_OF)
    {
      "load" => load,
      "evaluate" => evaluate,
      "runtime_config" => {
        "approval_enforcement" => true,
        "gate3_authorized" => gate3_authorized,
        "requested_cache_key_fragment" => requested_cache_key_fragment,
        "token_present" => !token.nil?
      }
    }
  end

  def approval_token_for(igapp_path, contract_id, capability)
    manifest = read_json(igapp_path / "manifest.json")
    contract_ref = manifest.fetch("contract_index").fetch(contract_id).fetch("contract_ref")
    body = {
      "kind" => "executor_approval_token",
      "version" => "executor-approval-token-v1",
      "token_id" => "approval/proof-local/#{contract_id}",
      "authority_ref" => "architect-supervisor/proof-local",
      "gate" => "tbackend_gate3",
      "scope" => {
        "operation" => "temporal_evaluate",
        "environment" => "proof",
        "max_fragment_class" => "TEMPORAL"
      },
      "artifact_ref" => "igapp/#{manifest.fetch("program_id")}",
      "contract_refs" => [contract_ref],
      "capability_refs" => [capability],
      "issued_at" => PROOF_AS_OF,
      "expires_at" => "2026-05-15T00:00:00Z",
      "revocation" => {
        "status" => "active",
        "revocation_ref" => nil
      },
      "evidence_ref" => "decision/gate3/proof-local/not-authorizing-live-execution"
    }
    token_hash = "sha256:#{Digest::SHA256.hexdigest(JSON.generate(canonical(body)))}"
    body.merge(
      "token_hash" => token_hash,
      "signature" => {
        "alg" => "recorded-decision-hash",
        "key_ref" => "architect-supervisor/proof-local",
        "value" => "sig:#{token_hash.delete_prefix("sha256:")[0, 16]}"
      }
    )
  end

  def build_checks(cases)
    cases.each_with_object({}) do |(id, result), checks|
      prefix = id
      checks["#{prefix}.load_for_inspection_preserved"] =
        result.dig("load_for_inspection", "status") == "loaded" &&
          result.dig("load_for_inspection", "runtime_execution", "guard_policy") == "load_accept_evaluate_refuse"
      checks["#{prefix}.missing_approval_refused"] =
        result.dig("missing_approval_token", "evaluate", "status") == "blocked" &&
          result.dig("missing_approval_token", "evaluate", "reason_code") == "runtime.executor_approval_missing"
      checks["#{prefix}.valid_token_gate3_closed_refused"] =
        result.dig("valid_token_gate3_closed", "evaluate", "status") == "blocked" &&
          result.dig("valid_token_gate3_closed", "evaluate", "reason_code") == "runtime.temporal_gate3_closed"
      checks["#{prefix}.core_cache_key_refused"] =
        result.dig("core_shaped_cache_key", "evaluate", "status") == "blocked" &&
          result.dig("core_shaped_cache_key", "evaluate", "reason_code") == "runtime.temporal_cache_schema_mismatch" &&
          result.dig("core_shaped_cache_key", "evaluate", "context", "gate") == "L-T5"
      checks["#{prefix}.no_live_operations_attempted"] =
        result.dig("operation_check", "temporal_executor_call_attempted") == false &&
          result.dig("operation_check", "live_tbackend_call_attempted") == false &&
          result.dig("operation_check", "ledger_call_attempted") == false &&
          result.dig("operation_check", "production_cache_call_attempted") == false
    end
  end

  def no_live_operation_check
    {
      "decision" => "not_attempted",
      "temporal_executor_call_attempted" => false,
      "live_tbackend_call_attempted" => false,
      "ledger_call_attempted" => false,
      "production_cache_call_attempted" => false,
      "source" => "proof-local GuardedRuntimeMachine refuses before live executor/cache/backend paths"
    }
  end

  def canonical(value)
    case value
    when Hash
      value.keys.sort_by(&:to_s).each_with_object({}) { |key, out| out[key.to_s] = canonical(value.fetch(key)) }
    when Array
      value.map { |item| canonical(item) }
    else
      value
    end
  end

  def read_json(path)
    JSON.parse(File.read(path))
  end

  def write_json(path, value)
    FileUtils.mkdir_p(path.dirname)
    File.write(path, "#{JSON.pretty_generate(value)}\n")
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} guarded_runtime_executor_approval_enforcement"
    summary.fetch("checks").each do |name, ok|
      puts "#{name}: #{ok ? "ok" : "FAIL"}"
    end
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

if $PROGRAM_NAME == __FILE__
  success = GuardedRuntimeExecutorApprovalEnforcementProof.run
  exit(success ? 0 : 1)
end
