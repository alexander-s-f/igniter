#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "pathname"

require_relative "../../lib/igniter_lang/temporal_access_runtime"
require_relative "../../lib/igniter_lang/temporal_executor"

module Phase1BackendIdentityGuardProof
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  LANG_ROOT = ROOT / "igniter-lang"
  OUT_DIR = LANG_ROOT / "experiments/phase1_backend_identity_guard/out"
  SUMMARY_PATH = OUT_DIR / "phase1_backend_identity_guard_summary.json"
  PROOF_AS_OF = "2026-05-09T12:00:00Z"

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
        { "kind" => "some", "value" => "explicit-non-ledger:#{subject}@#{as_of}" },
        { "observation_id" => "obs/explicit_non_ledger/#{@read_attempts}" }
      ]
    end
  end

  class UnmarkedReadAsOfBackend
    attr_reader :read_attempts

    def initialize
      @read_attempts = 0
    end

    def read_as_of(_subject, _as_of)
      @read_attempts += 1
      raise "unmarked backend must not be called"
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
      raise "Ledger-backed adapter must not be called in Phase 1"
    end
  end

  class LedgerProxyWrapper
    attr_reader :read_attempts

    def initialize
      @read_attempts = 0
    end

    def phase1_backend_identity
      {
        "kind" => "phase1_wrapper",
        "backend_family" => "proof_local",
        "phase1_allowed" => true,
        "ledger_backed" => false,
        "invokes_ledger_package" => true,
        "package_adapter" => false
      }
    end

    def read_as_of(_subject, _as_of)
      @read_attempts += 1
      raise "Ledger proxy wrapper must not be called in Phase 1"
    end
  end

  class MalformedIdentityBackend
    attr_reader :read_attempts

    def initialize
      @read_attempts = 0
    end

    def phase1_backend_identity
      "not-a-hash"
    end

    def read_as_of(_subject, _as_of)
      @read_attempts += 1
      raise "malformed identity backend must not be called"
    end
  end

  def run
    FileUtils.rm_rf(OUT_DIR)
    FileUtils.mkdir_p(OUT_DIR)

    cases = {
      "proof_local_memory_backend_allowed" => run_memory_backend_allowed,
      "explicit_non_ledger_backend_allowed" => run_explicit_non_ledger_allowed,
      "unmarked_read_as_of_backend_blocked" => run_blocked(UnmarkedReadAsOfBackend.new),
      "ledger_backed_adapter_blocked" => run_blocked(LedgerBackedAdapter.new),
      "ledger_proxy_wrapper_blocked" => run_blocked(LedgerProxyWrapper.new),
      "malformed_identity_backend_blocked" => run_blocked(MalformedIdentityBackend.new),
      "missing_token_blocks_before_backend_identity" => run_missing_token_before_identity
    }
    checks = build_checks(cases)
    summary = {
      "kind" => "phase1_backend_identity_guard_summary",
      "format_version" => "0.1.0",
      "card" => "S3-R18-C4-P",
      "track" => "phase1-backend-identity-guard-v0",
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "rule" => {
        "allowed" => [
          "IgniterLang::TemporalAccessRuntime::MemoryBackend",
          "explicit phase1_allowed non-Ledger backend identity"
        ],
        "blocked" => [
          "Igniter-Ledger package adapter",
          "Ledger-backed adapter",
          "wrapper/proxy that invokes Ledger package code",
          "unmarked read_as_of backend"
        ],
        "phase2_addendum_required_for_ledger" => true
      },
      "cases" => cases,
      "checks" => checks,
      "scope" => {
        "ledger_binding" => false,
        "live_reads" => false,
        "proof_local_backend_reads_only" => true
      }
    }

    write_json(SUMMARY_PATH, summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def run_memory_backend_allowed
    backend = IgniterLang::TemporalAccessRuntime::MemoryBackend.new
    backend.seed_append_observations([
      { "subject" => "sku/prod-001/price", "valid_from" => "2026-01-01T00:00:00Z",
        "value" => "99.00", "value_type" => "String" }
    ])
    result = evaluate_with(backend, token: valid_token)
    { "evaluate" => result, "backend_class" => backend.class.name }
  end

  def run_explicit_non_ledger_allowed
    backend = ExplicitNonLedgerBackend.new
    result = evaluate_with(backend, token: valid_token)
    { "evaluate" => result, "backend_class" => backend.class.name, "read_attempts" => backend.read_attempts }
  end

  def run_blocked(backend)
    result = evaluate_with(backend, token: valid_token)
    { "evaluate" => result, "backend_class" => backend.class.name, "read_attempts" => backend.read_attempts }
  end

  def run_missing_token_before_identity
    backend = LedgerBackedAdapter.new
    result = evaluate_with(backend, token: nil)
    { "evaluate" => result, "backend_class" => backend.class.name, "read_attempts" => backend.read_attempts }
  end

  def evaluate_with(backend, token:)
    executor = IgniterLang::TemporalExecutor::Phase1.new(backend: backend, gate3_authorized: true)
    result = executor.evaluate(
      contract,
      token: token,
      inputs: { "sku" => "prod-001" },
      as_of: PROOF_AS_OF
    )
    result.merge("observations" => executor.observations)
  end

  def contract
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

  def valid_token
    {
      "kind" => "executor_approval_token",
      "version" => "executor-approval-token-v1",
      "token_id" => "approval/backend-identity-proof",
      "authority_ref" => IgniterLang::TemporalExecutor::GATE3_AUTHORITY_REF,
      "gate" => "tbackend_gate3"
    }
  end

  def build_checks(cases)
    {
      "memory_backend.allowed" =>
        cases.dig("proof_local_memory_backend_allowed", "evaluate", "status") == "ok",
      "explicit_non_ledger.allowed" =>
        cases.dig("explicit_non_ledger_backend_allowed", "evaluate", "status") == "ok" &&
          cases.dig("explicit_non_ledger_backend_allowed", "read_attempts") == 1,
      "unmarked_backend.blocked" =>
        backend_identity_blocked?(cases, "unmarked_read_as_of_backend_blocked"),
      "ledger_backed_adapter.blocked" =>
        backend_identity_blocked?(cases, "ledger_backed_adapter_blocked"),
      "ledger_proxy_wrapper.blocked" =>
        backend_identity_blocked?(cases, "ledger_proxy_wrapper_blocked"),
      "malformed_identity.blocked" =>
        backend_identity_blocked?(cases, "malformed_identity_backend_blocked"),
      "blocked_backends.no_read_attempts" =>
        %w[
          unmarked_read_as_of_backend_blocked
          ledger_backed_adapter_blocked
          ledger_proxy_wrapper_blocked
          malformed_identity_backend_blocked
        ].all? { |name| cases.dig(name, "read_attempts") == 0 },
      "missing_token.blocks_before_backend_identity" =>
        cases.dig("missing_token_blocks_before_backend_identity", "evaluate", "blocked_stage") == "approval_token" &&
          cases.dig("missing_token_blocks_before_backend_identity", "read_attempts") == 0,
      "observation.backend_identity_emitted" =>
        observation_backend_identity?(cases, "proof_local_memory_backend_allowed", "proof_local_memory_backend") &&
          observation_backend_identity?(cases, "explicit_non_ledger_backend_allowed", "proof_local_non_ledger_backend"),
      "blocked_cases.no_live_operations" =>
        blocked_cases_no_live_operations?(cases)
    }
  end

  def observation_backend_identity?(cases, name, expected_kind)
    observation = cases.dig(name, "evaluate", "observations", 0)
    return false unless observation

    observation.fetch("kind") == "temporal_live_read_observation" &&
      observation.dig("backend_identity", "kind") == expected_kind
  end

  def backend_identity_blocked?(cases, name)
    cases.dig(name, "evaluate", "status") == "blocked" &&
      cases.dig(name, "evaluate", "blocked_stage") == "backend_identity" &&
      cases.dig(name, "evaluate", "reason_code") ==
        IgniterLang::TemporalExecutor::ReasonCode::BACKEND_IDENTITY_BLOCKED
  end

  def blocked_cases_no_live_operations?(cases)
    cases.values.all? do |entry|
      next true unless entry.dig("evaluate", "status") == "blocked"

      op = entry.dig("evaluate", "operation_check") || {}
      op.values.all? { |value| value == false }
    end
  end

  def write_json(path, value)
    FileUtils.mkdir_p(path.dirname)
    File.write(path, "#{JSON.pretty_generate(value)}\n")
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} phase1_backend_identity_guard"
    summary.fetch("checks").each { |name, ok| puts "  #{name}: #{ok ? "ok" : "FAIL"}" }
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

if $PROGRAM_NAME == __FILE__
  success = Phase1BackendIdentityGuardProof.run
  exit(success ? 0 : 1)
end
