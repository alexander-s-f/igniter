#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "pathname"

require_relative "../../lib/igniter_lang/temporal_access_runtime"
require_relative "../../lib/igniter_lang/temporal_executor"

module Gate3FirstPostSignatureFixture
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  LANG_ROOT = ROOT / "igniter-lang"
  ADDENDUM_PATH = LANG_ROOT / "docs/gates/gate3-live-read-decision-addendum-v0.md"
  OUT_DIR = LANG_ROOT / "experiments/gate3_first_post_signature_fixture/out"
  SUMMARY_PATH = OUT_DIR / "gate3_first_post_signature_fixture_summary.json"
  PROOF_AS_OF = "2026-05-09T12:00:00Z"
  SIGNED_STATUS = "signed-approved-restricted-phase1-live-read"

  module_function

  class ExplicitNonLedgerBackend
    attr_reader :read_attempts

    def initialize
      @read_attempts = 0
    end

    def phase1_backend_identity
      {
        "kind" => "proof_local_non_ledger_backend",
        "backend_family" => "proof_local",
        "phase1_allowed" => true,
        "ledger_backed" => false,
        "invokes_ledger_package" => false,
        "package_adapter" => false
      }
    end

    def read_as_of(subject, as_of)
      @read_attempts += 1
      [
        { "kind" => "some", "value" => "non-ledger:#{subject}@#{as_of}" },
        { "observation_id" => "obs/post_signature/non_ledger/#{@read_attempts}" }
      ]
    end
  end

  class LedgerBackedAdapter
    attr_reader :read_attempts

    def initialize
      @read_attempts = 0
    end

    def phase1_backend_identity
      {
        "kind" => "ledger_tbackend_adapter",
        "backend_family" => "ledger",
        "phase1_allowed" => true,
        "ledger_backed" => true,
        "invokes_ledger_package" => true,
        "package_adapter" => true
      }
    end

    def read_as_of(_subject, _as_of)
      @read_attempts += 1
      raise "Ledger-backed adapter must not be called"
    end
  end

  def run
    FileUtils.rm_rf(OUT_DIR)
    FileUtils.mkdir_p(OUT_DIR)

    addendum_status = read_addendum_status
    signed = addendum_status == SIGNED_STATUS
    cases = build_cases(addendum_status)
    checks = build_checks(cases, addendum_status, signed)

    summary = {
      "kind" => "gate3_first_post_signature_fixture_summary",
      "format_version" => "0.1.0",
      "card" => "S3-R20-C2-P",
      "track" => "gate3-first-post-signature-fixture-v0",
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "addendum" => {
        "path" => ADDENDUM_PATH.relative_path_from(ROOT).to_s,
        "status" => addendum_status,
        "signed" => signed
      },
      "policy_claim" => {
        "signing_changes" => "policy/status only",
        "executor_behavior_changed" => false,
        "phase1_authorized_scope" => "History[T] valid_time / explicit as_of / non-Ledger backend",
        "excluded" => [
          "Ledger",
          "BiHistory",
          "stream",
          "OLAP",
          "production_cache",
          "writes",
          "replay",
          "compact",
          "subscribe",
          "durable_audit"
        ]
      },
      "cases" => cases,
      "checks" => checks
    }

    write_json(SUMMARY_PATH, summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def build_cases(addendum_status)
    {
      "before_signed_reference_policy_blocks_true" => before_signed_reference_policy_blocks_true,
      "before_signed_reference_executor_gate_closed" => before_signed_reference_executor_gate_closed,
      "after_signed_reference_policy_allows_true" => after_signed_reference_policy_allows_true(addendum_status),
      "signed_memory_backend_executes" => signed_memory_backend_executes(addendum_status),
      "signed_non_ledger_backend_executes" => signed_non_ledger_backend_executes(addendum_status),
      "guard_order_missing_token" => guard_case(nil, signed: true),
      "guard_order_gate_closed" => guard_case(valid_token, signed: false),
      "guard_order_backend_identity" => dangerous_backend_case(addendum_status),
      "guard_order_scope" => excluded_contract_case(addendum_status, stream_contract),
      "guard_order_cache_key" => guard_case(valid_token, signed: true, requested_cache_key_fragment: "CORE"),
      "excluded_bihistory" => excluded_contract_case(addendum_status, bihistory_contract),
      "excluded_stream" => excluded_contract_case(addendum_status, stream_contract),
      "excluded_olap" => excluded_contract_case(addendum_status, olap_contract),
      "excluded_write" => excluded_contract_case(addendum_status, write_contract)
    }
  end

  def before_signed_reference_policy_blocks_true
    {
      "requested_gate3_authorized" => true,
      "policy_status" => "draft-not-signed",
      "caller_may_pass_gate3_authorized" => caller_may_pass_gate3_authorized?(
        addendum_status: "draft-not-signed",
        invocation_evidence: signed_invocation_evidence
      ),
      "executor_called" => false
    }
  end

  def before_signed_reference_executor_gate_closed
    executor = IgniterLang::TemporalExecutor::Phase1.new(
      backend: memory_backend,
      gate3_authorized: false
    )
    result = executor.evaluate(history_contract, token: valid_token, inputs: { "sku" => "prod-001" }, as_of: PROOF_AS_OF)
    { "evaluate" => result, "observations" => executor.observations }
  end

  def after_signed_reference_policy_allows_true(addendum_status)
    {
      "requested_gate3_authorized" => true,
      "policy_status" => addendum_status,
      "caller_may_pass_gate3_authorized" => caller_may_pass_gate3_authorized?(
        addendum_status: addendum_status,
        invocation_evidence: signed_invocation_evidence
      ),
      "signed_addendum_ref" => signed_invocation_evidence.fetch("signed_addendum_ref")
    }
  end

  def signed_memory_backend_executes(addendum_status)
    executor = IgniterLang::TemporalExecutor::Phase1.new(
      backend: memory_backend,
      gate3_authorized: caller_may_pass_gate3_authorized?(
        addendum_status: addendum_status,
        invocation_evidence: signed_invocation_evidence
      )
    )
    result = executor.evaluate(history_contract, token: valid_token, inputs: { "sku" => "prod-001" }, as_of: PROOF_AS_OF)
    { "evaluate" => result, "observations" => executor.observations }
  end

  def signed_non_ledger_backend_executes(addendum_status)
    backend = ExplicitNonLedgerBackend.new
    executor = IgniterLang::TemporalExecutor::Phase1.new(
      backend: backend,
      gate3_authorized: caller_may_pass_gate3_authorized?(
        addendum_status: addendum_status,
        invocation_evidence: signed_invocation_evidence
      )
    )
    result = executor.evaluate(history_contract, token: valid_token, inputs: { "sku" => "prod-001" }, as_of: PROOF_AS_OF)
    { "evaluate" => result, "observations" => executor.observations, "read_attempts" => backend.read_attempts }
  end

  def dangerous_backend_case(addendum_status)
    backend = LedgerBackedAdapter.new
    executor = IgniterLang::TemporalExecutor::Phase1.new(
      backend: backend,
      gate3_authorized: caller_may_pass_gate3_authorized?(
        addendum_status: addendum_status,
        invocation_evidence: signed_invocation_evidence
      )
    )
    result = executor.evaluate(history_contract, token: valid_token, inputs: { "sku" => "prod-001" }, as_of: PROOF_AS_OF)
    { "evaluate" => result, "read_attempts" => backend.read_attempts, "observations" => executor.observations }
  end

  def excluded_contract_case(addendum_status, contract)
    backend = ExplicitNonLedgerBackend.new
    executor = IgniterLang::TemporalExecutor::Phase1.new(
      backend: backend,
      gate3_authorized: caller_may_pass_gate3_authorized?(
        addendum_status: addendum_status,
        invocation_evidence: signed_invocation_evidence
      )
    )
    result = executor.evaluate(contract, token: valid_token, inputs: { "sku" => "prod-001" }, as_of: PROOF_AS_OF)
    { "evaluate" => result, "read_attempts" => backend.read_attempts, "observations" => executor.observations }
  end

  def guard_case(token, signed:, requested_cache_key_fragment: "TEMPORAL")
    executor = IgniterLang::TemporalExecutor::Phase1.new(backend: memory_backend, gate3_authorized: signed)
    result = executor.evaluate(
      history_contract,
      token: token,
      inputs: { "sku" => "prod-001" },
      as_of: PROOF_AS_OF,
      requested_cache_key_fragment: requested_cache_key_fragment
    )
    { "evaluate" => result, "observations" => executor.observations }
  end

  def caller_may_pass_gate3_authorized?(addendum_status:, invocation_evidence:)
    addendum_status == SIGNED_STATUS &&
      invocation_evidence.is_a?(Hash) &&
      invocation_evidence.fetch("signed_addendum_ref", nil) == ADDENDUM_PATH.relative_path_from(ROOT).to_s
  end

  def read_addendum_status
    line = ADDENDUM_PATH.readlines.find { |candidate| candidate.start_with?("Status:") }
    line.to_s.split(":", 2).last.to_s.strip
  end

  def memory_backend
    backend = IgniterLang::TemporalAccessRuntime::MemoryBackend.new
    backend.seed_append_observations([
      { "subject" => "sku/prod-001/price", "valid_from" => "2026-01-01T00:00:00Z",
        "value" => "99.00", "value_type" => "String" }
    ])
    backend
  end

  def valid_token
    {
      "kind" => "executor_approval_token",
      "version" => "executor-approval-token-v1",
      "token_id" => "approval/post-signature-fixture",
      "authority_ref" => IgniterLang::TemporalExecutor::GATE3_AUTHORITY_REF,
      "gate" => "tbackend_gate3"
    }
  end

  def signed_invocation_evidence
    {
      "kind" => "gate3_invocation_evidence",
      "signed_addendum_ref" => ADDENDUM_PATH.relative_path_from(ROOT).to_s,
      "policy_effect" => "caller_may_pass_gate3_authorized_true"
    }
  end

  def history_contract
    {
      "contract_id" => "HistoryAxesTest",
      "fragment_class" => "temporal",
      "temporal_nodes" => [
        { "kind" => "temporal_input_node", "name" => "price_history",
          "store_ref" => "sku/{sku}/price" },
        { "kind" => "temporal_access_node", "name" => "price_at",
          "source_ref" => "price_history", "axis" => "valid_time",
          "as_of_ref" => "as_of" }
      ]
    }
  end

  def bihistory_contract
    history_contract.merge(
      "contract_id" => "BiHistoryAxesTest",
      "temporal_nodes" => [
        { "kind" => "temporal_input_node", "name" => "price_history",
          "store_ref" => "sku/{sku}/price" },
        { "kind" => "temporal_access_node", "name" => "price_at",
          "source_ref" => "price_history", "axis" => "bitemporal",
          "as_of_ref" => "as_of" }
      ]
    )
  end

  def stream_contract
    { "contract_id" => "StreamFold", "fragment_class" => "stream", "temporal_nodes" => [] }
  end

  def olap_contract
    { "contract_id" => "OlapProjection", "fragment_class" => "olap", "temporal_nodes" => [] }
  end

  def write_contract
    { "contract_id" => "LedgerWrite", "fragment_class" => "ledger_write", "temporal_nodes" => [] }
  end

  def build_checks(cases, addendum_status, signed)
    {
      "addendum.signed_status_detected" => signed && addendum_status == SIGNED_STATUS,
      "before_signed_reference.caller_must_not_pass_true" =>
        cases.dig("before_signed_reference_policy_blocks_true", "caller_may_pass_gate3_authorized") == false,
      "before_signed_reference.executor_blocks_at_gate_state" =>
        blocked_stage?(cases, "before_signed_reference_executor_gate_closed", "gate_state"),
      "after_signed_reference.caller_may_pass_true" =>
        cases.dig("after_signed_reference_policy_allows_true", "caller_may_pass_gate3_authorized") == true,
      "executor.guard_order_unchanged" =>
        blocked_stage?(cases, "guard_order_missing_token", "approval_token") &&
          blocked_stage?(cases, "guard_order_gate_closed", "gate_state") &&
          blocked_stage?(cases, "guard_order_backend_identity", "backend_identity") &&
          blocked_stage?(cases, "guard_order_scope", "scope") &&
          blocked_stage?(cases, "guard_order_cache_key", "cache_key"),
      "memory_backend.executes_when_all_checks_pass" =>
        cases.dig("signed_memory_backend_executes", "evaluate", "status") == "ok" &&
          observation_backend_identity?(cases, "signed_memory_backend_executes", "proof_local_memory_backend"),
      "non_ledger_backend.executes_when_all_checks_pass" =>
        cases.dig("signed_non_ledger_backend_executes", "evaluate", "status") == "ok" &&
          cases.dig("signed_non_ledger_backend_executes", "read_attempts") == 1 &&
          observation_backend_identity?(cases, "signed_non_ledger_backend_executes", "proof_local_non_ledger_backend"),
      "dangerous_backend.blocked_before_read" =>
        blocked_stage?(cases, "guard_order_backend_identity", "backend_identity") &&
          cases.dig("guard_order_backend_identity", "read_attempts") == 0,
      "excluded_surfaces.no_live_paths" =>
        excluded_surfaces_blocked?(cases),
      "cache_key.core_shape_blocked" =>
        blocked_stage?(cases, "guard_order_cache_key", "cache_key")
    }
  end

  def blocked_stage?(cases, name, stage)
    cases.dig(name, "evaluate", "status") == "blocked" &&
      cases.dig(name, "evaluate", "blocked_stage") == stage
  end

  def observation_backend_identity?(cases, name, expected_kind)
    observation = cases.dig(name, "observations", 0)
    observation.is_a?(Hash) &&
      observation.fetch("kind") == "temporal_live_read_observation" &&
      observation.dig("backend_identity", "kind") == expected_kind
  end

  def excluded_surfaces_blocked?(cases)
    {
      "excluded_bihistory" => nil,
      "excluded_stream" => "scope",
      "excluded_olap" => "scope",
      "excluded_write" => "scope"
    }.all? do |name, stage|
      result = cases.fetch(name)
      status_ok = result.dig("evaluate", "status") == "blocked"
      stage_ok = stage.nil? || result.dig("evaluate", "blocked_stage") == stage
      status_ok && stage_ok && result.fetch("read_attempts") == 0
    end
  end

  def write_json(path, value)
    FileUtils.mkdir_p(path.dirname)
    File.write(path, "#{JSON.pretty_generate(value)}\n")
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} gate3_first_post_signature_fixture"
    summary.fetch("checks").each { |name, ok| puts "  #{name}: #{ok ? "ok" : "FAIL"}" }
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

if $PROGRAM_NAME == __FILE__
  success = Gate3FirstPostSignatureFixture.run
  exit(success ? 0 : 1)
end
