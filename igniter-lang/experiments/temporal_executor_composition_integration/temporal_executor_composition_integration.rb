#!/usr/bin/env ruby
# frozen_string_literal: true

# Card: S3-R15-C2-P
# Track: runtime-temporal-executor-composition-integration-v0
#
# Closes AT-2: Phase1TemporalExecutorWithReport composes one CompatibilityReport
# per evaluation and runs RuntimeReportEnforcementPreflight before the kernel.
# No inline partial report; the composed report is the single source of truth.
#
# Key proofs:
#   1. Happy path: composed report present, runtime_enforced=true, kernel runs, result ok
#   2. Split report/enforcement fragments rejected at compatibility_report stage
#      — before any executor, gate, token, cache, or backend path
#   3. Gate closed → blocked at gate_state (through report preflight)
#   4. Missing token → blocked at approval_token (through report preflight, before gate)

require "digest"
require "fileutils"
require "json"
require "pathname"

require_relative "../../lib/igniter_lang/temporal_access_runtime"
require_relative "../temporal_runtime_load_guard/temporal_runtime_load_guard"
require_relative "../runtime_machine_memory_proof/compiled_program"
require_relative "../compatibility_report_composition/compatibility_report_composition"
require_relative "../runtime_report_enforcement_preflight/runtime_report_enforcement_preflight"
require_relative "../temporal_executor_phase1_preflight/temporal_executor_phase1_preflight"

module TemporalExecutorCompositionIntegration
  ROOT         = Pathname.new(File.expand_path("../../..", __dir__))
  LANG_ROOT    = ROOT / "igniter-lang"
  OUT_DIR      = LANG_ROOT / "experiments/temporal_executor_composition_integration/out"
  SUMMARY_PATH = OUT_DIR  / "temporal_executor_composition_integration_summary.json"

  ASSEMBLED_DIR = LANG_ROOT / "experiments/temporal_runtime_load_guard/out/assembled"
  GOLDEN_DIR    = LANG_ROOT / "experiments/temporal_semanticir_access_node/golden"

  PROOF_AS_OF = "2026-05-09T12:00:00Z"

  # Authority ref recorded in gate3-decision-record-v0.md §Authority Registry
  GATE3_AUTHORITY_REF =
    "architect-supervisor://igniter-lang/gates/gate3/" \
    "runtime-temporal-executor/restricted-history-valid-time-v0/2026-05-09"

  # Phase1TemporalExecutorWithReport
  #
  # AT-2 integration: composes exactly one CompatibilityReport per evaluation,
  # then runs RuntimeReportEnforcementPreflight guard chain before the kernel.
  #
  # Guard order (preflight-enforced, not inline):
  #   compatibility_report → approval_token → gate_state → scope →
  #   cache_key → executor_backend → [kernel: AT-12, AT-7, AT-10]
  class Phase1TemporalExecutorWithReport
    attr_reader :observations, :last_compatibility_report

    def initialize(backend:, approval_token:, gate3_authorized:,
                   requested_cache_key_fragment: "TEMPORAL")
      @backend = backend
      @approval_token = approval_token
      @gate3_authorized = gate3_authorized
      @requested_cache_key_fragment = requested_cache_key_fragment
      @observations = []
      @loaded_program = nil
      @loaded_artifact_ref = nil
      @last_compatibility_report = nil
    end

    # AT-1: sets runtime_enforced=true on load. Uses GuardedRuntimeMachine for
    # L-T1..L-T6 artifact validation only.
    def load(igapp_path)
      path = Pathname.new(igapp_path)
      loader = TemporalRuntimeLoadGuardProof::GuardedRuntimeMachine.new(
        temporal_runtime_supported: true,
        temporal_capabilities: infer_capabilities(@backend),
        approval_enforcement: false,
        gate3_authorized: false
      )
      load_result = loader.load_igapp(path)
      return load_result unless load_result["status"] == "loaded"

      @loaded_program = RuntimeMachineMemoryProof::CompiledProgram.load_igapp(path)
      @loaded_artifact_ref = "igapp/#{@loaded_program.program_id}"
      load_result.merge("runtime_enforced" => true, "phase1_scope" => "History[T] valid_time")
    end

    # AT-2: composes one CompatibilityReport; preflight guards before kernel.
    # composition_mode keyword is exposed for split-report rejection tests.
    def evaluate(contract_id, inputs:, as_of:, composition_mode: "single_report")
      raise ArgumentError, "call load first" unless @loaded_program

      contract = @loaded_program.contracts.fetch(contract_id)

      # Compose one CompatibilityReport (AT-2)
      report_inputs = build_report_inputs(contract_id, contract, composition_mode)
      report = CompatibilityReportComposition.compose(report_inputs)
      @last_compatibility_report = report

      # Run preflight guard chain — replaces inline AT-4/AT-5/AT-6 checks
      preflight = RuntimeReportEnforcementPreflight.preflight(report)

      unless preflight.fetch("status") == "ready"
        return {
          "kind"                    => "evaluation_refusal",
          "status"                  => "blocked",
          "guard_at"                => "compatibility_report_preflight",
          "reason_code"             => preflight.fetch("reason_code"),
          "blocked_stage"           => preflight.fetch("blocked_stage"),
          "stage_trace"             => preflight.fetch("stage_trace"),
          "contract_id"             => contract_id,
          "as_of"                   => as_of,
          "compatibility_report_id" => report.fetch("report_id"),
          "operation_check"         => preflight.fetch("operation_check")
        }
      end

      # Preflight passed — enter execution kernel (AT-12, AT-7, AT-10)
      run_execution_kernel(contract, inputs: inputs, as_of: as_of)
        .merge("compatibility_report_id" => report.fetch("report_id"))
    end

    private

    def run_execution_kernel(contract, inputs:, as_of:)
      contract_id = contract.fetch("contract_id")

      # AT-12: defense-in-depth — executor refuses non-TEMPORAL fragment
      unless contract.fetch("fragment_class") == "temporal"
        return { "kind" => "evaluation_refusal", "status" => "blocked",
                 "guard_at" => "temporal_executor",
                 "reason_code" => "runtime.temporal_executor_core_refusal",
                 "contract_id" => contract_id, "gate" => "AT-12" }
      end

      temporal_nodes = contract.fetch("temporal_nodes", [])
      access_nodes   = temporal_nodes.select { |n| n["kind"] == "temporal_access_node" }

      # AT-7: Phase 1 = valid_time only; BiHistory explicitly refused
      bihistory = access_nodes.select { |n| n["axis"] == "bitemporal" }
      if bihistory.any?
        return { "kind" => "evaluation_refusal", "status" => "blocked",
                 "guard_at" => "temporal_executor",
                 "reason_code" => "runtime.temporal_executor_bihistory_excluded",
                 "contract_id" => contract_id, "gate" => "AT-7" }
      end

      temporal_inputs = temporal_nodes
        .select { |n| n["kind"] == "temporal_input_node" }
        .to_h { |n| [n.fetch("name"), n] }
      all_inputs = inputs.merge("as_of" => as_of)

      results = access_nodes.map do |node|
        evaluate_valid_time_node(node, temporal_inputs, all_inputs, contract_id)
      end

      { "status"               => "ok",
        "kind"                 => "temporal_evaluation_result",
        "contract_id"          => contract_id,
        "results"              => results,
        "observations_emitted" => @observations.length,
        "runtime_enforced"     => true,
        "scope"                => "History[T].valid_time / MemoryBackend / proof-local",
        "excluded"             => "Ledger, BiHistory, stream, OLAP, writes, production_cache" }
    end

    def evaluate_valid_time_node(access_node, temporal_inputs, inputs, contract_id)
      source    = access_node.fetch("source_ref")
      template  = temporal_inputs.fetch(source).fetch("store_ref")
      as_of_ref = access_node["as_of_ref"] ||
                  access_node.dig("coordinate_refs", "as_of") ||
                  "as_of"
      subject = render_ref(template, inputs)
      as_of   = inputs.fetch(as_of_ref)

      result, backend_obs = @backend.read_as_of(subject, as_of)

      # AT-10: unconditional live-read observation per read
      @observations << {
        "kind"                    => "temporal_live_read_observation",
        "contract_id"             => contract_id,
        "node"                    => access_node.fetch("name"),
        "axis"                    => "valid_time",
        "subject"                 => subject,
        "as_of"                   => as_of,
        "result_present"          => result.is_a?(Hash) && result["kind"] == "some",
        "backend_observation_ref" => backend_obs.fetch("observation_id"),
        "persistence"             => "proof_local"
      }

      { "node" => access_node.fetch("name"), "axis" => "valid_time",
        "result" => result, "backend_observation" => backend_obs }
    end

    def build_report_inputs(contract_id, contract, composition_mode)
      {
        "artifact_ref"            => @loaded_artifact_ref,
        "contract_ref"            => manifest_contract_index_entry(contract_id).fetch("contract_ref"),
        "fragment_class"          => contract.fetch("fragment_class").upcase,
        "composition_mode"        => composition_mode,
        "requested_report_mode"   => "runtime_enforced",
        "backend_check"           => CompatibilityReportComposition.backend_check("trusted_metadata"),
        "runtime_gate_check"      => build_runtime_gate_check,
        "executor_approval_check" => build_executor_approval_check(contract_id),
        "executor_readiness"      => CompatibilityReportComposition.executor_readiness("ok"),
        "cache_key_check"         => build_cache_key_check
      }
    end

    def build_runtime_gate_check
      CompatibilityReportComposition.runtime_gate_check(open: @gate3_authorized)
        .merge("authority_ref" => @gate3_authorized ? GATE3_AUTHORITY_REF : nil)
    end

    def build_executor_approval_check(contract_id)
      token = @approval_token
      return CompatibilityReportComposition.approval_check("blocked") unless token.is_a?(Hash)
      return CompatibilityReportComposition.approval_check("blocked") unless token_valid?(token, contract_id)

      CompatibilityReportComposition.approval_check("ok").merge(
        "token_ref"     => token.fetch("token_id"),
        "authority_ref" => token.fetch("authority_ref")
      )
    end

    def build_cache_key_check
      if @requested_cache_key_fragment == "TEMPORAL"
        CompatibilityReportComposition.cache_key_check("ok")
      else
        CompatibilityReportComposition.cache_key_check("blocked")
      end
    end

    def token_valid?(token, contract_id)
      return false unless token.fetch("kind", nil) == "executor_approval_token"
      return false unless token.fetch("version", nil) == "executor-approval-token-v1"
      return false unless token.fetch("gate", nil) == "tbackend_gate3"
      return false unless token.fetch("artifact_ref", nil) == @loaded_artifact_ref

      contract_ref = manifest_contract_index_entry(contract_id).fetch("contract_ref")
      Array(token.fetch("contract_refs", [])).include?(contract_ref)
    end

    def manifest_contract_index_entry(contract_id)
      @loaded_program.manifest.fetch("contract_index").fetch(contract_id)
    end

    def infer_capabilities(backend)
      caps = []
      caps << "history_read"   if backend.respond_to?(:read_as_of)
      caps << "bihistory_read" if backend.respond_to?(:bihistory_at)
      caps
    end

    def render_ref(template, inputs)
      template.gsub(/\{([^}]+)\}/) { inputs.fetch(Regexp.last_match(1)) }
    end
  end

  module_function

  def run
    FileUtils.rm_rf(OUT_DIR)
    FileUtils.mkdir_p(OUT_DIR)
    ensure_assembled_artifacts!

    backend     = build_seeded_backend
    igapp_path  = ASSEMBLED_DIR / "history_valid.igapp"
    manifest    = read_json(igapp_path / "manifest.json")
    contract_id = "HistoryAxesTest"
    token       = TemporalExecutorPhase1PreflightProof.build_approval_token(manifest, contract_id)

    cases = {
      "happy_path"            => run_happy_path(igapp_path, contract_id, backend, token),
      "split_report_rejected" => run_split_report(igapp_path, contract_id, backend, token),
      "gate_closed"           => run_gate_closed(igapp_path, contract_id, token),
      "missing_token"         => run_missing_token(igapp_path, contract_id)
    }

    checks          = build_checks(cases)
    at_coverage     = build_at_coverage(checks)
    blockers        = remaining_blockers_list

    summary = {
      "kind"               => "temporal_executor_composition_integration_summary",
      "format_version"     => "0.1.0",
      "card"               => "S3-R15-C2-P",
      "track"              => "runtime-temporal-executor-composition-integration-v0",
      "status"             => checks.values.all? ? "PASS" : "FAIL",
      "at_coverage"        => at_coverage,
      "cases"              => cases,
      "checks"             => checks,
      "remaining_blockers" => blockers,
      "scope" => {
        "authorized"         => "History[T] valid_time / proof-local MemoryBackend",
        "excluded"           => "Ledger, BiHistory, stream, OLAP, writes, production_cache",
        "live_tbackend"      => false,
        "production_cache"   => false,
        "gate3_production_open" => false
      }
    }

    write_json(SUMMARY_PATH, summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def run_happy_path(igapp_path, contract_id, backend, token)
    executor = Phase1TemporalExecutorWithReport.new(
      backend: backend, approval_token: token, gate3_authorized: true
    )
    load_result = executor.load(igapp_path)
    eval_result = executor.evaluate(
      contract_id, inputs: { "sku" => "prod-001" }, as_of: PROOF_AS_OF
    )
    { "load"                 => load_result,
      "evaluate"             => eval_result,
      "observations"         => executor.observations,
      "compatibility_report" => executor.last_compatibility_report }
  end

  def run_split_report(igapp_path, contract_id, backend, token)
    executor = Phase1TemporalExecutorWithReport.new(
      backend: backend, approval_token: token, gate3_authorized: true
    )
    executor.load(igapp_path)
    eval_result = executor.evaluate(
      contract_id, inputs: { "sku" => "prod-001" }, as_of: PROOF_AS_OF,
      composition_mode: "split_report_and_enforcement"
    )
    { "evaluate"             => eval_result,
      "compatibility_report" => executor.last_compatibility_report }
  end

  def run_gate_closed(igapp_path, contract_id, token)
    executor = Phase1TemporalExecutorWithReport.new(
      backend: IgniterLang::TemporalAccessRuntime::MemoryBackend.new,
      approval_token: token, gate3_authorized: false
    )
    executor.load(igapp_path)
    { "evaluate" => executor.evaluate(contract_id, inputs: {}, as_of: PROOF_AS_OF) }
  end

  def run_missing_token(igapp_path, contract_id)
    executor = Phase1TemporalExecutorWithReport.new(
      backend: IgniterLang::TemporalAccessRuntime::MemoryBackend.new,
      approval_token: nil, gate3_authorized: true
    )
    executor.load(igapp_path)
    { "evaluate" => executor.evaluate(contract_id, inputs: {}, as_of: PROOF_AS_OF) }
  end

  def build_checks(cases)
    {
      # AT-2: composed report is present, single_report mode, runtime_enforced
      "at2.happy_path.report_composed" =>
        cases.dig("happy_path", "compatibility_report", "kind") == "compatibility_report",
      "at2.happy_path.report_single_mode" =>
        cases.dig("happy_path", "compatibility_report", "composition", "mode") == "single_report",
      "at2.happy_path.report_runtime_enforced" =>
        cases.dig("happy_path", "compatibility_report", "runtime_enforced") == true,
      "at2.happy_path.evaluate_ok" =>
        cases.dig("happy_path", "evaluate", "status") == "ok",
      "at2.happy_path.observation_emitted" =>
        (cases.dig("happy_path", "observations") || []).length >= 1,

      # Split report/enforcement fragments rejected before executor (AT-2 + preflight)
      "at2.split_report.blocked_at_compatibility_report" =>
        cases.dig("split_report_rejected", "evaluate", "status") == "blocked" &&
          cases.dig("split_report_rejected", "evaluate", "blocked_stage") == "compatibility_report",
      "at2.split_report.no_executor_call" =>
        cases.dig("split_report_rejected", "evaluate",
                  "operation_check", "temporal_executor_call_attempted") == false,

      # Gate closed → blocked at gate_state via report preflight
      "report_preflight.gate_closed.blocked_at_gate_state" =>
        cases.dig("gate_closed", "evaluate", "status") == "blocked" &&
          cases.dig("gate_closed", "evaluate", "blocked_stage") == "gate_state",

      # Missing token → blocked at approval_token (before gate stage)
      "report_preflight.no_token.blocked_at_approval_token" =>
        cases.dig("missing_token", "evaluate", "status") == "blocked" &&
          cases.dig("missing_token", "evaluate", "blocked_stage") == "approval_token"
    }
  end

  def build_at_coverage(checks)
    all_pass = checks.values.all?
    {
      "AT-2_compatibility_report_composed" => {
        "covered"  => all_pass,
        "evidence" => [
          "Phase1TemporalExecutorWithReport composes CompatibilityReport before execution kernel",
          "happy path: kind=compatibility_report, composition.mode=single_report, split_fragments_allowed=false",
          "runtime_enforced=true only when all checks pass and gate is open",
          "split_report_and_enforcement → blocked at compatibility_report " \
            "before any executor/gate/token/cache/backend path"
        ]
      }
    }
  end

  def remaining_blockers_list
    [
      { "blocker"        => "AT-9: production token authority / signature verification",
        "current_state"  => "proof-local recorded-decision hash; no external registry or key infrastructure",
        "gate3_ref"      => "gate3-decision-record-v0.md §Authority Registry",
        "required_for"   => "Phase 2 Ledger adapter or production deployment" },
      { "blocker"        => "AT-10: observation persistence",
        "current_state"  => "observations emitted to in-memory array only",
        "required_for"   => "invariant_persistence gap closure (Stage 2 deferred gap)" },
      { "blocker"        => "TBackend adapter production binding (Phase 2)",
        "current_state"  => "MemoryBackend proof-local only; no real Ledger or external TBackend",
        "required_for"   => "Phase 2 Architect addendum (gate3-decision-record-v0.md §Q3 Option C)" },
      { "blocker"        => "BiHistory evaluation excluded (AT-7)",
        "current_state"  => "BiHistory refused at executor; Phase 1 = valid_time only",
        "required_for"   => "separate gate request after at(vt:,tt:) serving proof" },
      { "blocker"        => "Runtime authority registry",
        "current_state"  => "not yet defined; active revocation paths: " \
                            "superseding gate decision, revocation doc, token expiry",
        "required_for"   => "Phase 2 / production authority-revocation work" }
    ]
  end

  def build_seeded_backend
    backend = IgniterLang::TemporalAccessRuntime::MemoryBackend.new
    backend.seed_append_observations([
      { "subject" => "sku/prod-001/price", "valid_from" => "2026-01-01T00:00:00Z",
        "value" => "99.00", "value_type" => "String" },
      { "subject" => "sku/prod-001/price", "valid_from" => "2026-03-01T00:00:00Z",
        "value" => "89.00", "value_type" => "String" }
    ])
    backend
  end

  def ensure_assembled_artifacts!
    return if (ASSEMBLED_DIR / "history_valid.igapp/manifest.json").exist?

    assembler = IgniterLang::Assembler.new(golden_dir: GOLDEN_DIR, out_dir: ASSEMBLED_DIR)
    assembler.assemble_case("history_valid")
  end

  def read_json(path)
    JSON.parse(File.read(path))
  end

  def write_json(path, value)
    FileUtils.mkdir_p(path.dirname)
    File.write(path, "#{JSON.pretty_generate(value)}\n")
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} temporal_executor_composition_integration"
    summary.fetch("checks").each { |name, ok| puts "  #{name}: #{ok ? "ok" : "FAIL"}" }
    puts "AT coverage:"
    summary.fetch("at_coverage").each { |name, v| puts "  #{name}: #{v.fetch("covered")}" }
    puts "Remaining blockers: #{summary.fetch("remaining_blockers").length}"
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

if $PROGRAM_NAME == __FILE__
  success = TemporalExecutorCompositionIntegration.run
  exit(success ? 0 : 1)
end
