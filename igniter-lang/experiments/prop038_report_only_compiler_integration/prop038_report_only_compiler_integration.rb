# frozen_string_literal: true

require "fileutils"
require "json"
require "pathname"

require_relative "../../lib/igniter_lang/compiler_orchestrator"

ROOT = Pathname.new(File.expand_path("../../..", __dir__))
OUT_DIR = Pathname.new(__dir__) / "out"
SUMMARY_PATH = OUT_DIR / "prop038_report_only_compiler_integration_summary.json"
SOURCE_PATH = ROOT / "igniter-lang/source/add.ig"
CONTRACT_SUMMARY_PATH = ROOT / "igniter-lang/experiments/compiler_profile_contract_proof/out/compiler_profile_contract_proof_summary.json"

def read_json(path)
  JSON.parse(File.read(path))
end

def deep_copy(value)
  Marshal.load(Marshal.dump(value))
end

def compile_case(name, provider)
  out_path = OUT_DIR / "#{name}.igapp"
  orchestrator = IgniterLang::CompilerOrchestrator.new(
    compiler_profile_contract_provider: provider
  )
  orchestration = orchestrator.compile(
    source_path: SOURCE_PATH,
    out_path: out_path
  )
  report = orchestration.fetch("compilation_report")
  public_result = IgniterLang::CompilerResult.public_result(orchestration.fetch("result"))
  {
    "name" => name,
    "status" => orchestration.fetch("status"),
    "report" => report,
    "public_result" => public_result,
    "public_result_comparable" => comparable_public_result(public_result),
    "manifest" => read_json(out_path / "manifest.json"),
    "refusal_report_path" => out_path.to_s.delete_suffix(".igapp") + ".compilation_report.json",
    "refusal_report_written" => File.exist?(out_path.to_s.delete_suffix(".igapp") + ".compilation_report.json"),
    "igapp_manifest_path" => (out_path / "manifest.json").to_s
  }
end

def comparable_public_result(result)
  result.reject { |key, _value| key == "igapp_path" }
end

def validation_for(result)
  result.fetch("report").fetch("compiler_profile_contract_validation", nil)
end

def assert(name, condition, checks)
  checks << { "name" => name, "pass" => !!condition }
end

FileUtils.rm_rf(OUT_DIR)
FileUtils.mkdir_p(OUT_DIR)

canonical_contract = read_json(CONTRACT_SUMMARY_PATH).fetch("canonical_contract")
invalid_contract = deep_copy(canonical_contract)
invalid_contract["kind"] = "not_a_compiler_profile_contract"

valid_provider = lambda do |source_path:, out_path:, parsed_program:, compiler_profile_source:|
  raise "missing source_path" unless source_path
  raise "missing out_path" unless out_path
  raise "missing parsed_program" unless parsed_program
  raise "unexpected compiler_profile_source" unless compiler_profile_source.nil?

  canonical_contract
end
invalid_provider = ->(**_kwargs) { invalid_contract }
nil_provider = ->(**_kwargs) { nil }
exception_provider = ->(**_kwargs) { raise "synthetic provider failure" }

baseline = compile_case("baseline_no_provider", nil)
valid = compile_case("valid_contract", valid_provider)
invalid = compile_case("invalid_contract", invalid_provider)
nil_case = compile_case("nil_provider", nil_provider)
exception_case = compile_case("exception_provider", exception_provider)

valid_validation = validation_for(valid)
invalid_validation = validation_for(invalid)

checks = []
assert("valid_contract.attaches_validation_true", valid_validation && valid_validation.fetch("valid") == true, checks)
assert("invalid_contract.attaches_validation_false", invalid_validation && invalid_validation.fetch("valid") == false && !invalid_validation.fetch("diagnostics").empty?, checks)
assert("invalid_contract.compile_status_ok", invalid.fetch("status") == "ok", checks)
assert("invalid_contract.public_result_unchanged", invalid.fetch("public_result_comparable") == baseline.fetch("public_result_comparable"), checks)
assert("invalid_contract.igapp_manifest_unchanged", invalid.fetch("manifest") == baseline.fetch("manifest"), checks)
assert("invalid_contract.no_refusal_report_written", invalid.fetch("refusal_report_written") == false, checks)
assert("nil_provider.legacy_no_validation_field", validation_for(nil_case).nil? && nil_case.fetch("public_result_comparable") == baseline.fetch("public_result_comparable"), checks)
assert("exception_provider.legacy_no_validation_field", validation_for(exception_case).nil? && exception_case.fetch("public_result_comparable") == baseline.fetch("public_result_comparable"), checks)
assert("valid_contract.report_only_true", valid_validation && valid_validation.fetch("report_only") == true, checks)
assert("invalid_contract.report_only_true", invalid_validation && invalid_validation.fetch("report_only") == true, checks)
assert("invalid_contract.pass_result_unchanged", invalid.fetch("report").fetch("pass_result") == baseline.fetch("report").fetch("pass_result"), checks)
assert("invalid_contract.stages_unchanged", invalid.fetch("report").fetch("stages") == baseline.fetch("report").fetch("stages"), checks)
assert("invalid_contract.diagnostics_unchanged", invalid.fetch("report").fetch("diagnostics") == baseline.fetch("report").fetch("diagnostics"), checks)
assert("invalid_contract.assembler_executed", File.exist?(invalid.fetch("igapp_manifest_path")), checks)
assert("invalid_contract.compiler_integrated_false", invalid_validation && invalid_validation.fetch("compiler_integrated") == false, checks)
assert("invalid_contract.compile_refusal_authorized_false", invalid_validation && invalid_validation.fetch("compile_refusal_authorized") == false, checks)
assert("valid_contract.public_result_unchanged", valid.fetch("public_result_comparable") == baseline.fetch("public_result_comparable"), checks)
assert("provider_nil.status_ok", nil_case.fetch("status") == "ok", checks)
assert("provider_exception.status_ok", exception_case.fetch("status") == "ok", checks)
assert("provider_exception.no_refusal_report_written", exception_case.fetch("refusal_report_written") == false, checks)

summary = {
  "kind" => "prop038_report_only_compiler_integration_summary",
  "format_version" => "0.1.0",
  "track" => "prop038-report-only-compiler-integration-implementation-v0",
  "status" => checks.all? { |check| check.fetch("pass") } ? "PASS" : "FAIL",
  "source_path" => SOURCE_PATH.to_s,
  "cases" => [
    {
      "name" => "baseline_no_provider",
      "status" => baseline.fetch("status"),
      "has_contract_validation" => !validation_for(baseline).nil?,
      "refusal_report_written" => baseline.fetch("refusal_report_written")
    },
    {
      "name" => "valid_contract",
      "status" => valid.fetch("status"),
      "validation" => valid_validation
    },
    {
      "name" => "invalid_contract",
      "status" => invalid.fetch("status"),
      "validation" => invalid_validation,
      "refusal_report_written" => invalid.fetch("refusal_report_written")
    },
    {
      "name" => "nil_provider",
      "status" => nil_case.fetch("status"),
      "has_contract_validation" => !validation_for(nil_case).nil?
    },
    {
      "name" => "exception_provider",
      "status" => exception_case.fetch("status"),
      "has_contract_validation" => !validation_for(exception_case).nil?,
      "refusal_report_written" => exception_case.fetch("refusal_report_written")
    }
  ],
  "public_result_unchanged" => {
    "valid_contract" => valid.fetch("public_result_comparable") == baseline.fetch("public_result_comparable"),
    "invalid_contract" => invalid.fetch("public_result_comparable") == baseline.fetch("public_result_comparable"),
    "nil_provider" => nil_case.fetch("public_result_comparable") == baseline.fetch("public_result_comparable"),
    "exception_provider" => exception_case.fetch("public_result_comparable") == baseline.fetch("public_result_comparable")
  },
  "igapp_manifest_unchanged" => {
    "valid_contract" => valid.fetch("manifest") == baseline.fetch("manifest"),
    "invalid_contract" => invalid.fetch("manifest") == baseline.fetch("manifest"),
    "nil_provider" => nil_case.fetch("manifest") == baseline.fetch("manifest"),
    "exception_provider" => exception_case.fetch("manifest") == baseline.fetch("manifest")
  },
  "non_authorizations_preserved" => {
    "compile_refusal" => false,
    "public_api_cli_widening" => false,
    "persisted_success_report" => false,
    "sidecar" => false,
    "igapp_manifest_mutation" => false,
    "loader_report" => false,
    "compatibility_report" => false,
    "diagnostics_centralization" => false,
    "compiler_result_change" => false,
    "runtime_machine" => false,
    "gate3" => false,
    "ledger_tbackend" => false,
    "bihistory" => false,
    "stream_olap" => false,
    "cache" => false,
    "production_behavior" => false
  },
  "checks" => checks
}

File.write(SUMMARY_PATH, JSON.pretty_generate(summary) + "\n")

if summary.fetch("status") == "PASS"
  puts "PASS prop038_report_only_compiler_integration"
else
  warn JSON.pretty_generate(checks.reject { |check| check.fetch("pass") })
  exit 1
end
