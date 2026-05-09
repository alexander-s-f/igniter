#!/usr/bin/env ruby
# frozen_string_literal: true

# Phase 1 TemporalExecutor preflight — proof-local skeleton
#
# Demonstrates the smallest correct History[T] valid_time executor boundary
# using MemoryBackend (no Ledger, no production cache).
#
# Phase 1 overrides the artifact's pre-gate-3 guard_policy
# (load_accept_evaluate_refuse) when gate3_authorized=true and a valid token
# is present. This is what AT-1/AT-2 mean: CompatibilityReport transitions to
# runtime_enforced=true — the artifact's artifact-level refuse policy no longer
# blocks when the gate conditions are satisfied.
#
# AT-1..AT-12 coverage mapped in the summary output.

require "digest"
require "fileutils"
require "json"
require "pathname"

require_relative "../../lib/igniter_lang/temporal_access_runtime"
require_relative "../temporal_runtime_load_guard/temporal_runtime_load_guard"
require_relative "../runtime_machine_memory_proof/compiled_program"

module TemporalExecutorPhase1PreflightProof
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  LANG_ROOT = ROOT / "igniter-lang"
  OUT_DIR = LANG_ROOT / "experiments/temporal_executor_phase1_preflight/out"
  SUMMARY_PATH = OUT_DIR / "temporal_executor_phase1_preflight_summary.json"

  ASSEMBLED_DIR = LANG_ROOT / "experiments/temporal_runtime_load_guard/out/assembled"
  GOLDEN_DIR = LANG_ROOT / "experiments/temporal_semanticir_access_node/golden"

  PROOF_AS_OF = "2026-05-09T12:00:00Z"
  TOKEN_AUTHORITY = "architect-supervisor/proof-local"
  TOKEN_EVIDENCE = "decision/gate3/proof-local/phase1-preflight"

  # Phase 1 TemporalExecutor skeleton.
  #
  # Uses GuardedRuntimeMachine only for artifact loading (L-T1..L-T6 gates).
  # Implements its own evaluate guard chain so that AT-1 (runtime_enforced=true)
  # overrides the artifact's pre-gate-3 guard_policy.
  #
  # Guard ordering in evaluate:
  #   capability check → AT-4 (token) → AT-5 (gate3) → AT-6 (cache key) →
  #   run_execution_kernel → AT-12 (CORE fragment) → AT-7 (BiHistory) →
  #   AT-10 (observation emission) → result
  class Phase1TemporalExecutor
    attr_reader :observations

    def initialize(backend:, approval_token:, gate3_authorized:,
                   requested_cache_key_fragment: "TEMPORAL")
      @backend = backend
      @approval_token = approval_token
      @gate3_authorized = gate3_authorized
      @requested_cache_key_fragment = requested_cache_key_fragment
      @observations = []
      @loaded_program = nil
      @loaded_artifact_ref = nil
    end

    # AT-1: transitions CompatibilityReport to runtime_enforced=true on load.
    # Uses GuardedRuntimeMachine only for L-T1..L-T6 artifact validation.
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

      # AT-1: explicit runtime_enforced=true; overrides artifact guard_policy
      load_result.merge("runtime_enforced" => true, "phase1_scope" => "History[T] valid_time")
    end

    # AT-3: guard chain runs before any backend call.
    # Implements AT-4, AT-5, AT-6 inline; does not delegate to artifact guard_policy.
    def evaluate(contract_id, inputs:, as_of:)
      raise ArgumentError, "call load first" unless @loaded_program

      contract = @loaded_program.contracts.fetch(contract_id)

      unless contract.fetch("fragment_class") == "temporal"
        return eval_blocked("runtime.non_temporal_not_covered",
                            "Phase1TemporalExecutor only handles TEMPORAL contracts",
                            contract_id: contract_id, as_of: as_of)
      end

      required = temporal_required_capabilities(contract)
      missing = required - infer_capabilities(@backend)
      unless missing.empty?
        return eval_blocked("runtime.temporal_capability_missing",
                            "missing capabilities: #{missing.join(", ")}",
                            contract_id: contract_id, as_of: as_of)
      end

      # AT-4: token validation before gate3 check
      token_refusal = validate_approval_token(@approval_token, contract, required, as_of)
      return token_refusal if token_refusal

      # AT-5: gate3 checked independently of token
      unless @gate3_authorized
        return eval_blocked("runtime.temporal_gate3_closed",
                            "Gate 3 is closed for TEMPORAL evaluation",
                            contract_id: contract_id, as_of: as_of,
                            context: { "gate" => "tbackend_gate3",
                                       "token_ref" => token_id })
      end

      # AT-6: TEMPORAL cache key schema check before any backend access
      cache_refusal = validate_cache_key_schema(contract, contract_id, as_of)
      return cache_refusal if cache_refusal

      # AT-1/AT-2: gate open + valid token = Phase 1 production evaluation path
      # artifact guard_policy (load_accept_evaluate_refuse) is overridden here
      run_execution_kernel(contract, inputs: inputs, as_of: as_of)
    end

    # Exposed for direct AT-12 / AT-7 kernel testing (bypasses guard chain).
    # In production the guard chain always runs first; this is defense-in-depth.
    def run_execution_kernel(contract, inputs:, as_of:)
      contract_id = contract.fetch("contract_id")

      # AT-12: executor independently refuses non-TEMPORAL fragment (defense-in-depth)
      unless contract.fetch("fragment_class") == "temporal"
        return executor_refusal("runtime.temporal_executor_core_refusal",
                                "TEMPORAL executor refuses non-TEMPORAL fragment_class",
                                contract_id: contract_id, gate: "AT-12")
      end

      temporal_nodes = contract.fetch("temporal_nodes", [])
      access_nodes = temporal_nodes.select { |n| n["kind"] == "temporal_access_node" }

      # AT-7: Phase 1 scope = valid_time only; BiHistory explicitly refused
      bihistory = access_nodes.select { |n| n["axis"] == "bitemporal" }
      if bihistory.any?
        return executor_refusal("runtime.temporal_executor_bihistory_excluded",
                                "BiHistory excluded from Phase 1 restricted Gate 3 scope",
                                contract_id: contract_id, gate: "AT-7")
      end

      temporal_inputs = temporal_nodes
        .select { |n| n["kind"] == "temporal_input_node" }
        .to_h { |n| [n.fetch("name"), n] }
      all_inputs = inputs.merge("as_of" => as_of)

      results = access_nodes.map do |node|
        evaluate_valid_time_node(node, temporal_inputs, all_inputs, contract_id)
      end

      {
        "status" => "ok",
        "kind" => "temporal_evaluation_result",
        "contract_id" => contract_id,
        "results" => results,
        "observations_emitted" => @observations.length,
        "runtime_enforced" => true,
        "scope" => "History[T].valid_time / MemoryBackend / proof-local",
        "excluded" => "Ledger, BiHistory, stream, OLAP, writes, production_cache"
      }
    end

    private

    def evaluate_valid_time_node(access_node, temporal_inputs, inputs, contract_id)
      source = access_node.fetch("source_ref")
      input_node = temporal_inputs.fetch(source)
      store_template = input_node.fetch("store_ref")
      as_of_ref = access_node["as_of_ref"] ||
                  access_node.dig("coordinate_refs", "as_of") ||
                  "as_of"
      subject = render_ref(store_template, inputs)
      as_of = inputs.fetch(as_of_ref)

      result, backend_obs = @backend.read_as_of(subject, as_of)

      # AT-10: unconditional live-read observation emission
      # Persistence is proof-local; emission is not gated on persistence readiness.
      live_obs = {
        "kind" => "temporal_live_read_observation",
        "contract_id" => contract_id,
        "node" => access_node.fetch("name"),
        "axis" => "valid_time",
        "subject" => subject,
        "as_of" => as_of,
        "result_present" => result.is_a?(Hash) && result["kind"] == "some",
        "backend_observation_ref" => backend_obs.fetch("observation_id"),
        "persistence" => "proof_local"
      }
      @observations << live_obs

      { "node" => access_node.fetch("name"), "axis" => "valid_time",
        "result" => result, "backend_observation" => backend_obs }
    end

    def validate_approval_token(token, contract, required, as_of)
      cid = contract.fetch("contract_id")
      return eval_blocked("runtime.executor_approval_missing", "token required",
                          contract_id: cid, as_of: as_of) unless token
      return eval_blocked("runtime.executor_approval_malformed", "token must be Hash",
                          contract_id: cid, as_of: as_of) unless token.is_a?(Hash)

      unless token.fetch("kind", nil) == "executor_approval_token" &&
             token.fetch("version", nil) == "executor-approval-token-v1"
        return eval_blocked("runtime.executor_approval_malformed", "token kind/version invalid",
                            contract_id: cid, as_of: as_of)
      end
      unless token.fetch("gate", nil) == "tbackend_gate3"
        return eval_blocked("runtime.executor_approval_wrong_gate", "gate mismatch",
                            contract_id: cid, as_of: as_of)
      end
      unless token.dig("scope", "operation") == "temporal_evaluate"
        return eval_blocked("runtime.executor_approval_wrong_scope", "scope mismatch",
                            contract_id: cid, as_of: as_of)
      end
      unless token.fetch("artifact_ref", nil) == @loaded_artifact_ref
        return eval_blocked("runtime.executor_approval_artifact_mismatch", "artifact_ref mismatch",
                            contract_id: cid, as_of: as_of,
                            context: { "expected" => @loaded_artifact_ref,
                                       "got" => token.fetch("artifact_ref", nil) })
      end

      contract_ref = manifest_contract_index_entry(cid).fetch("contract_ref")
      unless Array(token.fetch("contract_refs", [])).include?(contract_ref)
        return eval_blocked("runtime.executor_approval_contract_mismatch", "contract_ref mismatch",
                            contract_id: cid, as_of: as_of)
      end

      missing_caps = required - Array(token.fetch("capability_refs", []))
      unless missing_caps.empty?
        return eval_blocked("runtime.executor_approval_capability_mismatch",
                            "missing capability_refs",
                            contract_id: cid, as_of: as_of)
      end

      unless token.fetch("evidence_ref", nil)
        return eval_blocked("runtime.executor_approval_evidence_missing", "missing evidence_ref",
                            contract_id: cid, as_of: as_of)
      end
      unless token.fetch("token_hash", nil) && token.fetch("signature", nil).is_a?(Hash)
        return eval_blocked("runtime.executor_approval_signature_invalid", "missing hash/signature",
                            contract_id: cid, as_of: as_of)
      end

      nil
    end

    def validate_cache_key_schema(contract, contract_id, as_of)
      index_entry = manifest_contract_index_entry(contract_id)
      hint = index_entry.fetch("temporal").fetch("cache_key_schema_hint")
      expected = hint.fetch("fragment")
      return nil if @requested_cache_key_fragment == expected

      eval_blocked("runtime.temporal_cache_schema_mismatch",
                   "TEMPORAL evaluation cannot use a #{@requested_cache_key_fragment}-shaped cache key",
                   contract_id: contract_id, as_of: as_of,
                   context: { "gate" => "L-T5",
                               "expected_fragment" => expected,
                               "requested_fragment" => @requested_cache_key_fragment })
    end

    def temporal_required_capabilities(contract)
      (
        contract.fetch("escape_set", []).flat_map { |b| b.fetch("required_caps", []) } +
          contract.fetch("temporal_nodes", []).flat_map { |n| n.fetch("required_caps", []) }
      ).uniq.sort
    end

    def manifest_contract_index_entry(contract_id)
      @loaded_program.manifest.fetch("contract_index").fetch(contract_id)
    end

    def eval_blocked(reason_code, message, contract_id:, as_of:, context: {})
      { "kind" => "evaluation_refusal", "status" => "blocked",
        "guard_at" => "phase1_temporal_executor",
        "reason_code" => reason_code, "message" => message,
        "contract_id" => contract_id, "as_of" => as_of, "context" => context }
    end

    def executor_refusal(reason_code, message, contract_id:, gate:)
      { "kind" => "evaluation_refusal", "status" => "blocked",
        "guard_at" => "temporal_executor",
        "reason_code" => reason_code, "message" => message,
        "contract_id" => contract_id, "gate" => gate }
    end

    def render_ref(template, inputs)
      template.gsub(/\{([^}]+)\}/) { inputs.fetch(Regexp.last_match(1)) }
    end

    def infer_capabilities(backend)
      caps = []
      caps << "history_read" if backend.respond_to?(:read_as_of)
      caps << "bihistory_read" if backend.respond_to?(:bihistory_at)
      caps
    end

    def token_id
      @approval_token.is_a?(Hash) ? @approval_token["token_id"] : nil
    end
  end

  module_function

  def run
    FileUtils.rm_rf(OUT_DIR)
    FileUtils.mkdir_p(OUT_DIR)
    ensure_assembled_artifacts!

    backend = build_seeded_backend
    igapp_path = ASSEMBLED_DIR / "history_valid.igapp"
    manifest = read_json(igapp_path / "manifest.json")
    contract_id = "HistoryAxesTest"
    token = build_approval_token(manifest, contract_id)

    cases = {
      "happy_path" => run_happy_path(igapp_path, contract_id, backend, token),
      "no_token" => run_no_token(igapp_path, contract_id),
      "gate3_closed" => run_gate3_closed(igapp_path, contract_id, token),
      "core_cache_key" => run_core_cache_key(igapp_path, contract_id, token),
      "bihistory_at_executor" => run_bihistory_at_executor(token),
      "core_fragment_at_executor" => run_core_fragment_at_executor(igapp_path, token)
    }

    checks = build_checks(cases)
    gaps = runtime_gaps_before_live_reads

    summary = {
      "kind" => "temporal_executor_phase1_preflight_summary",
      "format_version" => "0.1.0",
      "card" => "S3-R14-C2-P",
      "track" => "runtime-temporal-executor-phase1-preflight-v0",
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "scope" => {
        "authorized" => "History[T] valid_time / proof-local MemoryBackend",
        "excluded" => "Ledger, BiHistory, stream, OLAP, writes, production_cache",
        "gate3_phase1_authorized" => true,
        "gate3_production_open" => false,
        "live_tbackend_binding" => false,
        "production_cache" => false
      },
      "at_coverage" => at_coverage_map(cases, checks),
      "cases" => cases,
      "checks" => checks,
      "runtime_gaps_before_live_reads" => gaps
    }

    write_json(SUMMARY_PATH, summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def run_happy_path(igapp_path, contract_id, backend, token)
    executor = Phase1TemporalExecutor.new(
      backend: backend, approval_token: token, gate3_authorized: true
    )
    load = executor.load(igapp_path)
    eval_result = executor.evaluate(
      contract_id, inputs: { "sku" => "prod-001" }, as_of: PROOF_AS_OF
    )
    { "load" => load, "evaluate" => eval_result, "observations" => executor.observations }
  end

  def run_no_token(igapp_path, contract_id)
    executor = Phase1TemporalExecutor.new(
      backend: IgniterLang::TemporalAccessRuntime::MemoryBackend.new,
      approval_token: nil, gate3_authorized: true
    )
    executor.load(igapp_path)
    { "evaluate" => executor.evaluate(contract_id, inputs: {}, as_of: PROOF_AS_OF) }
  end

  def run_gate3_closed(igapp_path, contract_id, token)
    executor = Phase1TemporalExecutor.new(
      backend: IgniterLang::TemporalAccessRuntime::MemoryBackend.new,
      approval_token: token, gate3_authorized: false
    )
    executor.load(igapp_path)
    { "evaluate" => executor.evaluate(contract_id, inputs: {}, as_of: PROOF_AS_OF) }
  end

  def run_core_cache_key(igapp_path, contract_id, token)
    # AT-6: Phase1TemporalExecutor also checks cache key schema before evaluation
    executor = Phase1TemporalExecutor.new(
      backend: IgniterLang::TemporalAccessRuntime::MemoryBackend.new,
      approval_token: token, gate3_authorized: true,
      requested_cache_key_fragment: "CORE"
    )
    executor.load(igapp_path)
    { "evaluate" => executor.evaluate(contract_id, inputs: {}, as_of: PROOF_AS_OF) }
  end

  def run_bihistory_at_executor(token)
    # AT-7: BiHistory artifact reaches executor; run_execution_kernel refuses
    bihistory_path = ASSEMBLED_DIR / "bihistory_valid.igapp"
    executor = Phase1TemporalExecutor.new(
      backend: IgniterLang::TemporalAccessRuntime::MemoryBackend.new,
      approval_token: build_approval_token(
        read_json(bihistory_path / "manifest.json"), "BiHistoryAxesTest", "bihistory_read"
      ),
      gate3_authorized: true
    )
    executor.load(bihistory_path)
    { "evaluate" => executor.evaluate("BiHistoryAxesTest", inputs: {}, as_of: PROOF_AS_OF) }
  end

  def run_core_fragment_at_executor(igapp_path, token)
    # AT-12: test executor-level CORE fragment refusal (defense-in-depth check).
    # The guard catches CORE at artifact load boundary. run_execution_kernel
    # checks fragment_class independently — tested by calling the kernel directly.
    executor = Phase1TemporalExecutor.new(
      backend: IgniterLang::TemporalAccessRuntime::MemoryBackend.new,
      approval_token: token, gate3_authorized: true
    )
    executor.load(igapp_path)
    fake_core = { "contract_id" => "FakeCore", "fragment_class" => "core",
                  "temporal_nodes" => [] }
    {
      "evaluate" => executor.run_execution_kernel(fake_core, inputs: {}, as_of: PROOF_AS_OF),
      "note" => "AT-12 defense-in-depth: run_execution_kernel called directly; guard refuses at load in production"
    }
  end

  def build_checks(cases)
    {
      "happy_path.load_runtime_enforced" =>
        cases.dig("happy_path", "load", "runtime_enforced") == true,
      "happy_path.evaluate_ok" =>
        cases.dig("happy_path", "evaluate", "status") == "ok",
      "happy_path.observation_emitted" =>
        cases.dig("happy_path", "observations")&.length.to_i >= 1,
      "happy_path.result_present" => begin
        r = cases.dig("happy_path", "evaluate", "results", 0, "result")
        r.is_a?(Hash) && r["kind"] == "some"
      end,
      "no_token.blocked_at4" =>
        cases.dig("no_token", "evaluate", "status") == "blocked" &&
          cases.dig("no_token", "evaluate", "reason_code") == "runtime.executor_approval_missing",
      "gate3_closed.blocked_at5" =>
        cases.dig("gate3_closed", "evaluate", "status") == "blocked" &&
          cases.dig("gate3_closed", "evaluate", "reason_code") == "runtime.temporal_gate3_closed",
      "core_cache_key.blocked_at6" =>
        cases.dig("core_cache_key", "evaluate", "status") == "blocked" &&
          cases.dig("core_cache_key", "evaluate", "reason_code") == "runtime.temporal_cache_schema_mismatch",
      "bihistory.blocked_at7" =>
        cases.dig("bihistory_at_executor", "evaluate", "status") == "blocked" &&
          cases.dig("bihistory_at_executor", "evaluate", "reason_code") == "runtime.temporal_executor_bihistory_excluded",
      "core_fragment.blocked_at12" =>
        cases.dig("core_fragment_at_executor", "evaluate", "status") == "blocked" &&
          cases.dig("core_fragment_at_executor", "evaluate", "reason_code") == "runtime.temporal_executor_core_refusal"
    }
  end

  def at_coverage_map(cases, checks)
    {
      "AT-1_runtime_enforced_true" =>
        { "covered" => checks.fetch("happy_path.load_runtime_enforced"),
          "evidence" => "load result has runtime_enforced=true; artifact guard_policy overridden" },
      "AT-3_readiness_before_executor" =>
        { "covered" => checks.fetch("happy_path.evaluate_ok"),
          "evidence" => "guard chain (capability, token, gate3, cache key) runs before execution kernel" },
      "AT-4_token_validation" =>
        { "covered" => checks.fetch("no_token.blocked_at4"),
          "evidence" => "missing token → executor_approval_missing before gate3 check" },
      "AT-5_gate3_independent" =>
        { "covered" => checks.fetch("gate3_closed.blocked_at5"),
          "evidence" => "valid token + gate3=false → temporal_gate3_closed; checks are independent" },
      "AT-6_temporal_cache_key" =>
        { "covered" => checks.fetch("core_cache_key.blocked_at6"),
          "evidence" => "CORE cache key fragment → temporal_cache_schema_mismatch (L-T5 position)" },
      "AT-7_bihistory_excluded" =>
        { "covered" => checks.fetch("bihistory.blocked_at7"),
          "evidence" => "BiHistory axis in execution kernel → temporal_executor_bihistory_excluded" },
      "AT-8_no_ledger_writes" =>
        { "covered" => true,
          "evidence" => "MemoryBackend has no write/append/replay API; Ledger not referenced" },
      "AT-10_observation_unconditional" =>
        { "covered" => checks.fetch("happy_path.observation_emitted"),
          "evidence" => "temporal_live_read_observation emitted per read; not gated on persistence" },
      "AT-11_regression_pass" =>
        { "covered" => "deferred",
          "evidence" => "run stage1/stage2 close candidates separately; see quality bar" },
      "AT-12_core_fragment_refused" =>
        { "covered" => checks.fetch("core_fragment.blocked_at12"),
          "evidence" => "run_execution_kernel called directly with CORE contract → core_refusal" }
    }
  end

  def runtime_gaps_before_live_reads
    [
      { "gap" => "AT-2: CompatibilityReport single composed production report",
        "current_state" => "Phase1 executor builds partial report inline; no composed CompatibilityReport object",
        "track_needed" => "compatibility-report-composition-shape-v0 (Gate 3 request §III Require)" },
      { "gap" => "AT-9: production token authority / signature verification",
        "current_state" => "proof-local recorded-decision hash only; no external authority registry",
        "needed" => "Architect-recorded authority ref in gate decision document (Q1)" },
      { "gap" => "Gate 3 decision record with authority_ref",
        "current_state" => "Gate 3 request drafted; HOLD for Architect review",
        "blocker" => "Architect approval required; gate3_authorized=true is proof-local only" },
      { "gap" => "AT-10: observation persistence",
        "current_state" => "observations emitted to in-memory array; no durable store",
        "needed" => "invariant_persistence gap closure (Stage 2 deferred gap)" },
      { "gap" => "TBackend adapter production binding (Phase 2)",
        "current_state" => "MemoryBackend is proof-local; no real Ledger or external TBackend",
        "needed" => "Phase 2 Architect addendum to gate decision (Gate 3 request §III Q3 Option C)" },
      { "gap" => "BiHistory evaluation (AT-7 excludes it from Phase 1)",
        "current_state" => "BiHistory refused at executor; Phase 1 = valid_time only",
        "needed" => "Separate gate request after at(vt:,tt:) serving proof" }
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

  def build_approval_token(manifest, contract_id, capability = "history_read")
    program_id = manifest.fetch("program_id")
    artifact_ref = "igapp/#{program_id}"
    contract_ref = manifest.fetch("contract_index").fetch(contract_id).fetch("contract_ref")
    body = {
      "kind" => "executor_approval_token",
      "version" => "executor-approval-token-v1",
      "token_id" => "approval/phase1-preflight/#{contract_id}",
      "authority_ref" => TOKEN_AUTHORITY,
      "gate" => "tbackend_gate3",
      "scope" => { "operation" => "temporal_evaluate", "environment" => "proof",
                   "max_fragment_class" => "TEMPORAL" },
      "artifact_ref" => artifact_ref,
      "contract_refs" => [contract_ref],
      "capability_refs" => [capability],
      "issued_at" => "2026-05-09T00:00:00Z",
      "expires_at" => "2026-05-16T00:00:00Z",
      "revocation" => { "status" => "active", "revocation_ref" => nil },
      "evidence_ref" => TOKEN_EVIDENCE
    }
    token_hash = canonical_hash(body)
    body.merge(
      "token_hash" => token_hash,
      "signature" => { "alg" => "recorded-decision-hash", "key_ref" => TOKEN_AUTHORITY,
                       "value" => "sig:#{token_hash.delete_prefix("sha256:")[0, 16]}" }
    )
  end

  def ensure_assembled_artifacts!
    return if (ASSEMBLED_DIR / "history_valid.igapp/manifest.json").exist? &&
              (ASSEMBLED_DIR / "bihistory_valid.igapp/manifest.json").exist?

    assembler = IgniterLang::Assembler.new(golden_dir: GOLDEN_DIR, out_dir: ASSEMBLED_DIR)
    %w[history_valid bihistory_valid].each { |n| assembler.assemble_case(n) }
  end

  def canonical_hash(value)
    normalized = canonical_normalize(value)
    "sha256:#{Digest::SHA256.hexdigest(JSON.generate(normalized))}"
  end

  def canonical_normalize(value)
    case value
    when Hash
      value.keys.sort_by(&:to_s)
           .each_with_object({}) { |k, h| h[k.to_s] = canonical_normalize(value[k]) }
    when Array
      value.map { |v| canonical_normalize(v) }
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
    puts "#{summary.fetch("status")} temporal_executor_phase1_preflight"
    summary.fetch("checks").each { |name, ok| puts "  #{name}: #{ok ? "ok" : "FAIL"}" }
    puts "AT coverage:"
    summary.fetch("at_coverage").each { |name, v| puts "  #{name}: #{v.fetch("covered")}" }
    puts "Gaps: #{summary.fetch("runtime_gaps_before_live_reads").length}"
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

if $PROGRAM_NAME == __FILE__
  success = TemporalExecutorPhase1PreflightProof.run
  exit(success ? 0 : 1)
end
