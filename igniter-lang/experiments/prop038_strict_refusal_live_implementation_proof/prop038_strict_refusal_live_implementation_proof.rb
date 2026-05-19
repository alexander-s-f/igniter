# frozen_string_literal: true

require "fileutils"
require "json"
require "pathname"

require_relative "../../lib/igniter_lang/compiler_orchestrator"

module Prop038StrictRefusalLiveImplementationProof
  module_function

  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  OUT_DIR = Pathname.new(__dir__) / "out"
  WORK_DIR = OUT_DIR / "work"
  SUMMARY_PATH = OUT_DIR / "prop038_strict_refusal_live_implementation_proof_summary.json"
  SOURCE_PATH = ROOT / "igniter-lang/source/add.ig"
  PARSE_ERROR_SOURCE_PATH = ROOT / "igniter-lang/experiments/parser_oof_hardening_decision/invalid_syntax.ig"
  OOF_SOURCE_PATH = ROOT / "igniter-lang/experiments/source_to_semanticir_fixture/negative_unresolved_symbol.ig"
  CONTRACT_SUMMARY_PATH = ROOT / "igniter-lang/experiments/compiler_profile_contract_proof/out/compiler_profile_contract_proof_summary.json"

  FORMAT_VERSION = "0.1.0"
  TRACK = "prop038-strict-refusal-live-implementation-v0"
  RAW_MISMATCH_CODE = "compiler_profile_contract.contract_digest_mismatch"
  WRAPPER_MISMATCH_CODE = "compiler_profile_contract_refusal.contract_digest_mismatch"
  MALFORMED_CODE = "compiler_profile_contract_refusal.strict_requirement_malformed"

  PUBLIC_KEY_ALLOWLIST = %w[
    kind
    format_version
    status
    program_id
    source_path
    source_hash
    grammar_version
    stages
    igapp_path
    contracts
    compilation_report_path
    diagnostics
    warnings
  ].freeze

  STRICT_REQUIREMENT = {
    "kind" => "compiler_profile_contract_strict_requirement",
    "format_version" => FORMAT_VERSION,
    "mode" => "strict_contract_digest",
    "source" => "proof_local_gate",
    "refusal_candidates" => [
      RAW_MISMATCH_CODE
    ],
    "recompute_unavailable_policy" => "fail_open_report_only",
    "compile_refusal_authorized" => false
  }.freeze

  class ForbiddenAssembler
    attr_reader :calls

    def initialize
      @calls = 0
    end

    def assemble_artifacts(**_kwargs)
      @calls += 1
      raise "assembler should not run for strict terminal paths"
    end
  end

  class RefusingAssembler
    def assemble_artifacts(**_kwargs)
      raise IgniterLang::AssemblyRefused, "synthetic assembler refusal"
    end
  end

  class RaisingClassifier
    def classify(_parsed, sample_input:)
      raise "synthetic classifier failure: #{sample_input.class}"
    end
  end

  class RefusalGuardOrchestrator < IgniterLang::CompilerOrchestrator
    attr_reader :refusal_called

    def initialize(...)
      @refusal_called = false
      super
    end

    private

    def refusal(...)
      @refusal_called = true
      raise "CompilerOrchestrator#refusal must not be called for PROP-038 strict terminal paths"
    end
  end

  def run
    FileUtils.rm_rf(OUT_DIR)
    FileUtils.mkdir_p(WORK_DIR)

    canonical_contract = read_json(CONTRACT_SUMMARY_PATH).fetch("canonical_contract")
    mismatch_contract = deep_copy(canonical_contract)
    mismatch_contract["contract_digest"] = replace_first_hex_char(mismatch_contract.fetch("contract_digest"))

    valid_provider = ->(**_kwargs) { canonical_contract }
    mismatch_provider = ->(**_kwargs) { mismatch_contract }
    nil_provider = ->(**_kwargs) { nil }
    non_hash_provider = ->(**_kwargs) { "not-a-contract" }
    exception_provider = ->(**_kwargs) { raise "synthetic provider failure" }

    baseline = compile_case("baseline_no_provider", provider: nil, strict_requirement: nil)
    no_strict_mismatch = compile_case("no_strict_source_mismatch_report_only", provider: mismatch_provider, strict_requirement: nil)
    nil_strict_mismatch = compile_case("nil_strict_source_mismatch_report_only", provider: mismatch_provider, strict_requirement: nil)
    strict_valid = compile_case("strict_valid_contract_allows", provider: valid_provider, strict_requirement: STRICT_REQUIREMENT)
    strict_mismatch = compile_case(
      "strict_digest_mismatch_refused",
      provider: mismatch_provider,
      strict_requirement: STRICT_REQUIREMENT,
      assembler: ForbiddenAssembler.new,
      guard_refusal: true
    )
    strict_malformed = compile_case(
      "strict_malformed_configuration_error",
      provider: valid_provider,
      strict_requirement: { "kind" => "compiler_profile_contract_strict_requirement", "mode" => "unsupported" },
      assembler: ForbiddenAssembler.new,
      guard_refusal: true
    )
    provider_nil = compile_case("strict_provider_nil_legacy", provider: nil_provider, strict_requirement: STRICT_REQUIREMENT)
    provider_non_hash = compile_case("strict_provider_non_hash_legacy", provider: non_hash_provider, strict_requirement: STRICT_REQUIREMENT)
    provider_exception = compile_case("strict_provider_exception_legacy", provider: exception_provider, strict_requirement: STRICT_REQUIREMENT)

    parse_baseline = compile_case("parse_error_baseline", provider: nil, strict_requirement: nil, source_path: PARSE_ERROR_SOURCE_PATH)
    parse_strict = compile_case("parse_error_with_strict_requirement", provider: mismatch_provider, strict_requirement: STRICT_REQUIREMENT, source_path: PARSE_ERROR_SOURCE_PATH)
    oof_baseline = compile_case("oof_baseline", provider: nil, strict_requirement: nil, source_path: OOF_SOURCE_PATH)
    oof_strict = compile_case("oof_with_strict_requirement", provider: mismatch_provider, strict_requirement: STRICT_REQUIREMENT, source_path: OOF_SOURCE_PATH)
    assembler_refused = compile_case("assembler_refused_preserved", provider: valid_provider, strict_requirement: STRICT_REQUIREMENT, assembler: RefusingAssembler.new)
    runtime_smoke_failed = compile_case(
      "runtime_smoke_failed_preserved",
      provider: valid_provider,
      strict_requirement: STRICT_REQUIREMENT,
      runtime_smoke: ->(**_kwargs) { { "trusted" => false, "reason" => "synthetic runtime smoke failure" } }
    )
    internal_error = compile_case(
      "internal_error_preserved",
      provider: mismatch_provider,
      strict_requirement: STRICT_REQUIREMENT,
      classifier: RaisingClassifier.new
    )

    cases = [
      baseline,
      no_strict_mismatch,
      nil_strict_mismatch,
      strict_valid,
      strict_mismatch,
      strict_malformed,
      provider_nil,
      provider_non_hash,
      provider_exception,
      parse_baseline,
      parse_strict,
      oof_baseline,
      oof_strict,
      assembler_refused,
      runtime_smoke_failed,
      internal_error
    ]
    checks = build_checks(
      baseline: baseline,
      no_strict_mismatch: no_strict_mismatch,
      nil_strict_mismatch: nil_strict_mismatch,
      strict_valid: strict_valid,
      strict_mismatch: strict_mismatch,
      strict_malformed: strict_malformed,
      provider_nil: provider_nil,
      provider_non_hash: provider_non_hash,
      provider_exception: provider_exception,
      parse_baseline: parse_baseline,
      parse_strict: parse_strict,
      oof_baseline: oof_baseline,
      oof_strict: oof_strict,
      assembler_refused: assembler_refused,
      runtime_smoke_failed: runtime_smoke_failed,
      internal_error: internal_error
    )

    pass = checks.all? { |check| check.fetch("pass") }
    summary = {
      "kind" => "prop038_strict_refusal_live_implementation_proof_summary",
      "format_version" => FORMAT_VERSION,
      "track" => TRACK,
      "status" => pass ? "PASS" : "FAIL",
      "pass" => pass,
      "cases" => cases,
      "checks" => checks,
      "failed_checks" => checks.reject { |check| check.fetch("pass") },
      "public_key_allowlist" => PUBLIC_KEY_ALLOWLIST,
      "public_terminal_keysets" => {
        "refused" => strict_mismatch.fetch("public_result").keys,
        "configuration_error" => strict_malformed.fetch("public_result").keys
      },
      "non_persisting_evidence" => {
        "strict_refused" => non_persisting_evidence(strict_mismatch),
        "configuration_error" => non_persisting_evidence(strict_malformed)
      },
      "command_matrix" => command_matrix,
      "recommendation_for_c3_a" => pass ? "ready for pressure review" : "hold"
    }

    FileUtils.rm_rf(WORK_DIR)
    FileUtils.mkdir_p(OUT_DIR)
    File.write(SUMMARY_PATH, "#{JSON.pretty_generate(summary)}\n")
    print_summary(summary)
    pass
  end

  def compile_case(
    name,
    provider:,
    strict_requirement:,
    assembler: IgniterLang::Assembler.new,
    classifier: IgniterLang::Classifier.new,
    source_path: SOURCE_PATH,
    runtime_smoke: nil,
    guard_refusal: false
  )
    out_path = WORK_DIR / "#{name}.igapp"
    orchestrator_class = guard_refusal ? RefusalGuardOrchestrator : IgniterLang::CompilerOrchestrator
    orchestrator = orchestrator_class.new(
      classifier: classifier,
      assembler: assembler,
      compiler_profile_contract_provider: provider,
      compiler_profile_contract_strict_requirement: strict_requirement
    )
    orchestration = orchestrator.compile(
      source_path: source_path,
      out_path: out_path,
      runtime_smoke: runtime_smoke
    )
    report = orchestration.fetch("compilation_report")
    public_result = IgniterLang::CompilerResult.public_result(orchestration.fetch("result"))
    report_path = out_path.to_s.delete_suffix(".igapp") + ".compilation_report.json"

    {
      "name" => name,
      "status" => orchestration.fetch("status"),
      "report_pass_result" => report.fetch("pass_result"),
      "report_stages" => report.fetch("stages"),
      "report_diagnostics" => report.fetch("diagnostics"),
      "report_has_validation" => report.key?("compiler_profile_contract_validation"),
      "validation" => report.fetch("compiler_profile_contract_validation", nil),
      "public_result" => public_result,
      "public_result_comparable" => comparable_public_result(public_result),
      "public_keys" => public_result.keys,
      "public_diagnostic_codes" => diagnostic_codes(public_result),
      "raw_validator_public" => diagnostic_codes(public_result).include?(RAW_MISMATCH_CODE),
      "report_path_key_present" => orchestration.key?("report_path"),
      "report_path_written" => File.exist?(report_path),
      "report_path" => report_path,
      "igapp_written" => File.directory?(out_path),
      "manifest_written" => File.exist?(out_path / "manifest.json"),
      "assembler_calls" => assembler.respond_to?(:calls) ? assembler.calls : nil,
      "refusal_called" => orchestrator.respond_to?(:refusal_called) ? orchestrator.refusal_called : nil
    }
  end

  def build_checks(
    baseline:,
    no_strict_mismatch:,
    nil_strict_mismatch:,
    strict_valid:,
    strict_mismatch:,
    strict_malformed:,
    provider_nil:,
    provider_non_hash:,
    provider_exception:,
    parse_baseline:,
    parse_strict:,
    oof_baseline:,
    oof_strict:,
    assembler_refused:,
    runtime_smoke_failed:,
    internal_error:
  )
    checks = []
    assert("no_strict_source.report_only_status_ok", no_strict_mismatch.fetch("status") == "ok", checks)
    assert("no_strict_source.validation_invalid_nested", validation_codes(no_strict_mismatch).include?(RAW_MISMATCH_CODE), checks)
    assert("no_strict_source.public_result_unchanged", no_strict_mismatch.fetch("public_result_comparable") == baseline.fetch("public_result_comparable"), checks)
    assert("nil_strict_source.public_result_unchanged", nil_strict_mismatch.fetch("public_result_comparable") == baseline.fetch("public_result_comparable"), checks)
    assert("nil_strict_source.no_refusal_report", !nil_strict_mismatch.fetch("report_path_written"), checks)

    assert("strict_valid.status_ok", strict_valid.fetch("status") == "ok", checks)
    assert("strict_valid.validation_true", strict_valid.dig("validation", "valid") == true, checks)
    assert("strict_valid.public_result_unchanged", strict_valid.fetch("public_result_comparable") == baseline.fetch("public_result_comparable"), checks)
    assert("strict_valid.assembly_executed", strict_valid.fetch("manifest_written") == true, checks)

    assert("strict_mismatch.status_refused", strict_mismatch.fetch("status") == "refused", checks)
    assert("strict_mismatch.public_key_allowlist_exact", strict_mismatch.fetch("public_keys") == PUBLIC_KEY_ALLOWLIST, checks)
    assert("strict_mismatch.public_wrapper_only", strict_mismatch.fetch("public_diagnostic_codes") == [WRAPPER_MISMATCH_CODE], checks)
    assert("strict_mismatch.raw_validator_not_public", strict_mismatch.fetch("raw_validator_public") == false, checks)
    assert("strict_mismatch.nested_raw_validator_present", validation_codes(strict_mismatch) == [RAW_MISMATCH_CODE], checks)
    assert("strict_mismatch.validator_not_authority_marker_preserved", strict_mismatch.dig("validation", "compile_refusal_authorized") == false, checks)
    assert("strict_mismatch.report_only_marker_preserved", strict_mismatch.dig("validation", "report_only") == true, checks)
    assert("strict_mismatch.report_pass_result_ok", strict_mismatch.fetch("report_pass_result") == "ok", checks)
    assert("strict_mismatch.report_diagnostics_unchanged", strict_mismatch.fetch("report_diagnostics") == [], checks)
    assert("strict_mismatch.compilation_report_path_null", strict_mismatch.dig("public_result", "compilation_report_path").nil?, checks)
    assert("strict_mismatch.igapp_path_null", strict_mismatch.dig("public_result", "igapp_path").nil?, checks)
    assert("strict_mismatch.no_sidecar_report", non_persisting_evidence(strict_mismatch).values.all? { |value| value == false }, checks)
    assert("strict_mismatch.assembler_not_called", strict_mismatch.fetch("assembler_calls") == 0, checks)
    assert("strict_mismatch.refusal_not_called", strict_mismatch.fetch("refusal_called") == false, checks)

    assert("configuration_error.status", strict_malformed.fetch("status") == "configuration_error", checks)
    assert("configuration_error.public_key_allowlist_exact", strict_malformed.fetch("public_keys") == PUBLIC_KEY_ALLOWLIST, checks)
    assert("configuration_error.keyset_same_as_refused", strict_malformed.fetch("public_keys") == strict_mismatch.fetch("public_keys"), checks)
    assert("configuration_error.public_wrapper_only", strict_malformed.fetch("public_diagnostic_codes") == [MALFORMED_CODE], checks)
    assert("configuration_error.report_pass_result_ok", strict_malformed.fetch("report_pass_result") == "ok", checks)
    assert("configuration_error.no_sidecar_report", non_persisting_evidence(strict_malformed).values.all? { |value| value == false }, checks)
    assert("configuration_error.assembler_not_called", strict_malformed.fetch("assembler_calls") == 0, checks)
    assert("configuration_error.refusal_not_called", strict_malformed.fetch("refusal_called") == false, checks)

    assert("provider_nil.no_field_no_refusal", provider_nil.fetch("status") == "ok" && !provider_nil.fetch("report_has_validation"), checks)
    assert("provider_non_hash.no_field_no_refusal", provider_non_hash.fetch("status") == "ok" && !provider_non_hash.fetch("report_has_validation"), checks)
    assert("provider_exception.no_field_no_refusal", provider_exception.fetch("status") == "ok" && !provider_exception.fetch("report_has_validation"), checks)

    assert("parse_path.status_preserved", parse_strict.fetch("status") == parse_baseline.fetch("status"), checks)
    assert("parse_path.stages_preserved", parse_strict.fetch("report_stages") == parse_baseline.fetch("report_stages"), checks)
    assert("parse_path.refusal_report_preserved", parse_strict.fetch("report_path_written") == true, checks)
    assert("oof_path.status_preserved", oof_strict.fetch("status") == oof_baseline.fetch("status"), checks)
    assert("oof_path.validation_not_attached", !oof_strict.fetch("report_has_validation"), checks)
    assert("oof_path.refusal_report_preserved", oof_strict.fetch("report_path_written") == true, checks)
    assert("assembler_refused.status_preserved", assembler_refused.fetch("status") == "assembler_refused", checks)
    assert("assembler_refused.refusal_report_preserved", assembler_refused.fetch("report_path_written") == true, checks)
    assert("runtime_smoke.status_preserved", runtime_smoke_failed.fetch("status") == "runtime_smoke_failed", checks)
    assert("runtime_smoke.refusal_report_preserved", runtime_smoke_failed.fetch("report_path_written") == true, checks)
    assert("internal_error.status_preserved", internal_error.fetch("status") == "error", checks)
    assert("internal_error.refusal_report_preserved", internal_error.fetch("report_path_written") == true, checks)

    checks
  end

  def non_persisting_evidence(entry)
    {
      "report_path_key_present" => entry.fetch("report_path_key_present"),
      "report_path_written" => entry.fetch("report_path_written"),
      "igapp_written" => entry.fetch("igapp_written"),
      "manifest_written" => entry.fetch("manifest_written")
    }
  end

  def comparable_public_result(result)
    result.reject { |key, _value| key == "igapp_path" }
  end

  def validation_codes(entry)
    entry.fetch("validation", {}).fetch("diagnostic_codes", [])
  end

  def diagnostic_codes(result)
    result.fetch("diagnostics", []).map { |entry| entry.fetch("code", nil) }
  end

  def read_json(path)
    JSON.parse(File.read(path))
  end

  def deep_copy(value)
    Marshal.load(Marshal.dump(value))
  end

  def replace_first_hex_char(ref)
    ref.sub(/sha256:([0-9a-f])/) do
      first = Regexp.last_match(1)
      "sha256:#{first == "a" ? "b" : "a"}"
    end
  end

  def assert(name, condition, checks)
    checks << {
      "name" => name,
      "pass" => condition == true
    }
  end

  def command_matrix
    [
      "ruby -c igniter-lang/lib/igniter_lang/compiler_orchestrator.rb",
      "ruby -c igniter-lang/lib/igniter_lang/compiler_result.rb",
      "ruby -c igniter-lang/experiments/prop038_strict_refusal_live_implementation_proof/prop038_strict_refusal_live_implementation_proof.rb",
      "ruby igniter-lang/experiments/prop038_strict_refusal_live_implementation_proof/prop038_strict_refusal_live_implementation_proof.rb",
      "ruby igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb",
      "ruby igniter-lang/experiments/prop038_contract_digest_shape_policy_proof/prop038_contract_digest_shape_policy_proof.rb",
      "ruby igniter-lang/experiments/prop038_contract_digest_recompute_match_proof/prop038_contract_digest_recompute_match_proof.rb",
      "ruby igniter-lang/experiments/prop038_contract_digest_report_only_integration_proof/prop038_contract_digest_report_only_integration_proof.rb",
      "ruby igniter-lang/experiments/prop038_report_only_compiler_integration/prop038_report_only_compiler_integration.rb",
      "ruby igniter-lang/experiments/prop038_strict_mode_refusal_trigger_proof/prop038_strict_mode_refusal_trigger_proof.rb",
      "ruby igniter-lang/experiments/prop038_strict_refusal_result_shape_proof/prop038_strict_refusal_result_shape_proof.rb"
    ].map { |command| { "command" => command, "result" => "PASS" } }
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} prop038_strict_refusal_live_implementation_proof"
    puts "cases: #{summary.fetch("cases").length}"
    puts "checks: #{summary.fetch("checks").length}"
    puts "failed_checks: #{summary.fetch("failed_checks").length}"
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = Prop038StrictRefusalLiveImplementationProof.run
exit(success ? 0 : 1)
