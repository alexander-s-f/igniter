#!/usr/bin/env ruby
# frozen_string_literal: true

# Card: S3-R23-C3-P
# Track: phase1-reason-code-legacy-aliases-deprecation-signal-v0
#
# Proves the deprecation signal surface for LEGACY_ALIASES is correctly wired:
#
#   - All three scope-exclusion constant aliases resolve to SCOPE_EXCLUSION
#   - LEGACY_ALIASES maps all three old string literals to SCOPE_EXCLUSION
#   - Executor emits SCOPE_EXCLUSION (not legacy codes) for each blocked scenario
#   - LEGACY_ALIASES is frozen and contains exactly the three deprecated strings
#
# The old string literals are frozen proof artifacts in S3-R14-C2-P and S3-R15-C2-P
# experiments. Those fixtures are NOT updated here; they are sealed evidence.

require "fileutils"
require "json"
require "pathname"

require_relative "../../lib/igniter_lang/temporal_executor"
require_relative "../../lib/igniter_lang/temporal_access_runtime"

module Phase1ReasonCodeLegacyAliasesDeprecationSignalProof
  ROOT      = Pathname.new(File.expand_path("../../..", __dir__))
  LANG_ROOT = ROOT / "igniter-lang"
  OUT_DIR   = LANG_ROOT / "experiments/phase1_reason_code_legacy_aliases_deprecation_signal/out"
  SUMMARY_PATH = OUT_DIR / "phase1_reason_code_legacy_aliases_deprecation_signal_summary.json"

  RC             = IgniterLang::TemporalExecutor::ReasonCode
  CANONICAL      = "runtime.temporal_scope_exclusion"
  AUTHORITY_REF  = IgniterLang::TemporalExecutor::GATE3_AUTHORITY_REF

  module_function

  def run
    FileUtils.rm_rf(OUT_DIR)
    FileUtils.mkdir_p(OUT_DIR)

    checks = {}
    checks.merge!(unit_constant_checks)
    checks.merge!(legacy_aliases_checks)
    checks.merge!(executor_emission_checks)

    status = checks.values.all? ? "PASS" : "FAIL"

    summary = {
      "kind"          => "phase1_reason_code_legacy_aliases_deprecation_signal_summary",
      "format_version" => "0.1.0",
      "card"          => "S3-R23-C3-P",
      "track"         => "phase1-reason-code-legacy-aliases-deprecation-signal-v0",
      "status"        => status,
      "checks"        => checks,
      "migration_recommendation" => migration_recommendation,
      "sealed_fixtures" => [
        "experiments/temporal_executor_phase1_preflight — S3-R14-C2-P (uses old codes; do not update)",
        "experiments/temporal_executor_composition_integration — S3-R15-C2-P (uses old codes; do not update)"
      ]
    }

    write_json(SUMMARY_PATH, summary)
    print_summary(summary)
    status == "PASS"
  end

  # Unit: constant alias values
  def unit_constant_checks
    {
      "unit.scope_exclusion_is_canonical" =>
        RC::SCOPE_EXCLUSION == CANONICAL,
      "unit.non_temporal_alias" =>
        RC::NON_TEMPORAL == CANONICAL,
      "unit.bihistory_excluded_alias" =>
        RC::BIHISTORY_EXCLUDED == CANONICAL,
      "unit.core_refusal_alias" =>
        RC::CORE_REFUSAL == CANONICAL,
      "unit.all_three_identical" =>
        [RC::NON_TEMPORAL, RC::BIHISTORY_EXCLUDED, RC::CORE_REFUSAL].uniq == [CANONICAL]
    }
  end

  # Unit: LEGACY_ALIASES map integrity
  def legacy_aliases_checks
    la = RC::LEGACY_ALIASES
    {
      "legacy.frozen"                 => la.frozen?,
      "legacy.size"                   => la.size == 3,
      "legacy.non_temporal_mapped"    =>
        la["runtime.non_temporal_not_covered"] == CANONICAL,
      "legacy.bihistory_mapped"       =>
        la["runtime.temporal_executor_bihistory_excluded"] == CANONICAL,
      "legacy.core_refusal_mapped"    =>
        la["runtime.temporal_executor_core_refusal"] == CANONICAL,
      "legacy.no_stray_keys"          =>
        la.keys.sort == %w[
          runtime.non_temporal_not_covered
          runtime.temporal_executor_bihistory_excluded
          runtime.temporal_executor_core_refusal
        ].sort
    }
  end

  # Executor: verify SCOPE_EXCLUSION is emitted (not legacy strings) for each scenario
  def executor_emission_checks
    token   = build_token
    backend = IgniterLang::TemporalAccessRuntime::MemoryBackend.new

    checks = {}

    # Scenario 1: NON_TEMPORAL — non-temporal fragment caught at scope stage (step 3)
    ex1 = IgniterLang::TemporalExecutor::Phase1.new(backend: backend, gate3_authorized: true)
    r1  = ex1.evaluate(non_temporal_contract, token: token, inputs: {}, as_of: "2026-05-09T00:00:00Z")
    checks["executor.non_temporal.blocked"]          = r1["status"] == "blocked"
    checks["executor.non_temporal.scope_exclusion"]  = r1["reason_code"] == CANONICAL
    checks["executor.non_temporal.blocked_at_scope"] = r1["blocked_stage"] == "scope"
    checks["executor.non_temporal.no_legacy_string"] = r1["reason_code"] != "runtime.non_temporal_not_covered"

    # Scenario 2: BIHISTORY — bitemporal access node refused at AT-7 kernel
    ex2 = IgniterLang::TemporalExecutor::Phase1.new(backend: backend, gate3_authorized: true)
    r2  = ex2.evaluate(bihistory_contract, token: token, inputs: {}, as_of: "2026-05-09T00:00:00Z")
    checks["executor.bihistory.blocked"]           = r2["status"] == "blocked"
    checks["executor.bihistory.scope_exclusion"]   = r2["reason_code"] == CANONICAL
    checks["executor.bihistory.no_legacy_string"]  = r2["reason_code"] != "runtime.temporal_executor_bihistory_excluded"

    # Scenario 3: CORE_REFUSAL (AT-12 kernel defense-in-depth) — caught at scope stage first.
    # The AT-12 kernel guard also uses CORE_REFUSAL = SCOPE_EXCLUSION. We verify this via unit
    # check above. At runtime, the scope stage intercepts CORE before the kernel — correct behavior.
    ex3 = IgniterLang::TemporalExecutor::Phase1.new(backend: backend, gate3_authorized: true)
    r3  = ex3.evaluate(core_fragment_contract, token: token, inputs: {}, as_of: "2026-05-09T00:00:00Z")
    checks["executor.core_scope.blocked"]           = r3["status"] == "blocked"
    checks["executor.core_scope.scope_exclusion"]   = r3["reason_code"] == CANONICAL
    checks["executor.core_scope.no_legacy_string"]  = r3["reason_code"] != "runtime.temporal_executor_core_refusal"

    checks
  end

  def build_token
    { "kind"          => "executor_approval_token",
      "version"       => "executor-approval-token-v1",
      "token_id"      => "approval/legacy-alias-proof",
      "authority_ref" => AUTHORITY_REF,
      "gate"          => "tbackend_gate3" }
  end

  def non_temporal_contract
    { "contract_id"    => "NonTemporalProof",
      "fragment_class" => "core",
      "temporal_nodes" => [] }
  end

  def bihistory_contract
    { "contract_id"    => "BiHistoryProof",
      "fragment_class" => "temporal",
      "temporal_nodes" => [
        { "kind" => "temporal_input_node", "name" => "emp_history",
          "store_ref" => "employees/{employee_id}" },
        { "kind" => "temporal_access_node", "name" => "emp_bih",
          "axis" => "bitemporal",
          "source_ref" => "emp_history",
          "as_of_ref"  => "as_of" }
      ] }
  end

  def core_fragment_contract
    { "contract_id"    => "CoreFragmentProof",
      "fragment_class" => "core",
      "temporal_nodes" => [] }
  end

  def migration_recommendation
    {
      "phase2_action"  => "remove LEGACY_ALIASES constant from ReasonCode module",
      "pre_condition"  => "all callers verified to use ReasonCode::SCOPE_EXCLUSION or the canonical string directly",
      "sealed_fixtures" => "do not update S3-R14-C2-P / S3-R15-C2-P experiment files — they are proof artifacts, not live callers",
      "search_command" => 'grep -r "runtime\\.non_temporal_not_covered\\|runtime\\.temporal_executor_bihistory_excluded\\|runtime\\.temporal_executor_core_refusal" igniter-lang/',
      "migration_path" => [
        "1. Audit all callers outside igniter-lang/experiments/ for legacy string usage",
        "2. Replace legacy string literals with ReasonCode::SCOPE_EXCLUSION or \"runtime.temporal_scope_exclusion\"",
        "3. Remove LEGACY_ALIASES from ReasonCode module (one-line deletion)",
        "4. Confirm no callers remain by running search_command above (expecting only sealed fixtures)"
      ]
    }
  end

  def write_json(path, data)
    File.write(path, JSON.pretty_generate(data))
  end

  def print_summary(summary)
    status = summary.fetch("status")
    checks = summary.fetch("checks")
    total  = checks.size
    passed = checks.values.count { |v| v }

    puts "#{status} phase1_reason_code_legacy_aliases_deprecation_signal"
    checks.each do |name, result|
      puts "  #{name}: #{result ? 'ok' : 'FAIL'}"
    end
    puts "#{passed}/#{total} #{status}"
  end
end

exit Phase1ReasonCodeLegacyAliasesDeprecationSignalProof.run ? 0 : 1 if $PROGRAM_NAME == __FILE__
