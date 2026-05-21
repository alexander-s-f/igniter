#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
OUT_DIR = ROOT / "experiments/oof_fragment_registry_supplied_data_source_proof/out"
FIXTURE_PATH = ROOT / "experiments/oof_fragment_registry_implementation_boundary_proof/fixtures/forward_shape_valid.json"
R103_SUMMARY_PATH = ROOT / "experiments/oof_fragment_registry_implementation_boundary_proof/out/oof_fragment_registry_implementation_boundary_proof_summary.json"

require_relative "../../lib/igniter_lang/oof_fragment_registry"

module OOFFragmentRegistrySuppliedDataSourceProof
  module_function

  TRACK = "oof-fragment-registry-supplied-data-source-proof-v0"
  VALID_SOURCE_MODES = %w[proof_fixture caller_supplied].freeze
  VALID_AUTHORITY_KINDS = %w[proof_only design_accepted].freeze
  VALID_CANON_STATUSES = %w[non_canon accepted_design].freeze
  PUBLIC_RESULT_KEYS = %w[
    igapp_path
    compilation_report_path
    report
    compatibility_report
    runtime_ready
    evaluation_ready
  ].freeze

  def run
    FileUtils.mkdir_p(OUT_DIR)

    registry = JSON.parse(File.read(FIXTURE_PATH))
    r103_summary = JSON.parse(File.read(R103_SUMMARY_PATH))
    valid_envelope = supplied_source_envelope(registry)
    validator = IgniterLang::OOFFragmentRegistry.new

    cases = []
    cases << case_result(
      "valid_proof_fixture_source_validates_nested_registry",
      expected: "accepted"
    ) do
      source_result = validate_source_envelope(valid_envelope)
      registry_result = validator.validate(valid_envelope.fetch("registry"))
      [
        source_result.fetch("valid") && registry_result.fetch("valid"),
        {
          "source_validation" => source_result,
          "nested_registry_validation" => registry_result,
          "nested_registry_validated_through" => "IgniterLang::OOFFragmentRegistry#validate"
        }
      ]
    end

    caller_envelope = supplied_source_envelope(registry).merge(
      "source_mode" => "caller_supplied",
      "authority" => {
        "authority_ref" => "LANG-R107-P1/local-caller",
        "authority_kind" => "proof_only",
        "canon_status" => "non_canon"
      }
    )
    cases << case_result(
      "valid_caller_supplied_source_validates_nested_registry",
      expected: "accepted"
    ) do
      source_result = validate_source_envelope(caller_envelope)
      registry_result = validator.validate(caller_envelope.fetch("registry"))
      [source_result.fetch("valid") && registry_result.fetch("valid"), {
        "source_validation" => source_result,
        "nested_registry_validation" => registry_result
      }]
    end

    malformed_kind = supplied_source_envelope(registry).merge("kind" => "oof_fragment_registry")
    cases << rejected_case("invalid_source_envelope_wrong_kind_internal_only", malformed_kind)

    canon_envelope = supplied_source_envelope(registry)
    canon_envelope["authority"] = canon_envelope.fetch("authority").merge("canon_status" => "canon")
    cases << rejected_case("invalid_source_envelope_canon_status_internal_only", canon_envelope)

    missing_registry = supplied_source_envelope(registry)
    missing_registry.delete("registry")
    cases << rejected_case("invalid_source_envelope_missing_registry_internal_only", missing_registry)

    invalid_source_mode = supplied_source_envelope(registry).merge("source_mode" => "profile_candidate")
    cases << rejected_case("invalid_source_envelope_profile_candidate_internal_only", invalid_source_mode)

    invalid_nested_registry = supplied_source_envelope(registry)
    invalid_nested_registry["registry"] = registry.merge("kind" => "not_oof_fragment_registry")
    cases << case_result(
      "valid_source_envelope_invalid_nested_registry_rejected_internally",
      expected: "rejected"
    ) do
      source_result = validate_source_envelope(invalid_nested_registry)
      registry_result = validator.validate(invalid_nested_registry.fetch("registry"))
      accepted = source_result.fetch("valid") && registry_result.fetch("valid")
      [accepted, {
        "source_validation" => source_result,
        "nested_registry_validation" => registry_result,
        "public_fields_present" => public_result_keys(registry_result)
      }]
    end

    checks = []
    checks << check("r103_validator_proof.pass_evidence") { r103_summary.fetch("status") == "PASS" }
    checks << check("case_matrix.expected_results") { cases.all? { |entry| entry.fetch("status") == "PASS" } }
    checks << check("nested_registry_hash_validated_by_existing_validator") do
      valid_case = cases.find { |entry| entry.fetch("name") == "valid_proof_fixture_source_validates_nested_registry" }
      valid_case.dig("details", "nested_registry_validated_through") == "IgniterLang::OOFFragmentRegistry#validate"
    end
    checks << check("invalid_source_envelopes_internal_only") do
      cases
        .select { |entry| entry.fetch("name").start_with?("invalid_source_envelope") }
        .all? { |entry| internal_only_result?(entry.fetch("details").fetch("source_validation")) }
    end
    checks << check("no_static_data_file") do
      !ROOT.join("lib/igniter_lang/oof_fragment_registry_data.rb").exist?
    end
    checks << check("lib_igniter_lang_rb_does_not_require_registry") do
      content = File.read(ROOT / "lib/igniter_lang.rb")
      !content.include?("oof_fragment_registry")
    end
    checks << check("no_compiler_pass_integration_require") do
      compiler_files = %w[
        parser classifier typechecker semanticir_emitter assembler compiler_orchestrator
        compilation_report compiler_result cli diagnostics
      ].map { |name| ROOT / "lib/igniter_lang/#{name}.rb" }
      compiler_files.all? do |path|
        !path.exist? || !File.read(path).include?("oof_fragment_registry")
      end
    end
    checks << check("validator_result_no_public_surface_keys") do
      cases.all? do |entry|
        details = entry.fetch("details")
        source_keys = public_result_keys(details.fetch("source_validation", {}))
        nested_keys = public_result_keys(details.fetch("nested_registry_validation", {}))
        source_keys.empty? && nested_keys.empty?
      end
    end
    checks << check("no_public_api_cli_report_compatibility_runtime_fields") do
      all_result_hashes = cases.flat_map do |entry|
        details = entry.fetch("details")
        [details.fetch("source_validation", nil), details.fetch("nested_registry_validation", nil)].compact
      end
      all_result_hashes.all? do |result|
        closed = result.fetch("closed_surface_assertions", {})
        closed.values.all?(false)
      end
    end

    failed_cases = cases.select { |entry| entry.fetch("status") != "PASS" }
    failed_checks = checks.select { |entry| entry.fetch("status") != "PASS" }
    status = failed_cases.empty? && failed_checks.empty? ? "PASS" : "FAIL"

    source_model = {
      "kind" => "oof_fragment_registry_source_model",
      "format_version" => "0.1.0",
      "track" => TRACK,
      "source_envelope" => valid_envelope.reject { |key, _| key == "registry" }.merge(
        "registry_ref" => "experiments/oof_fragment_registry_implementation_boundary_proof/fixtures/forward_shape_valid.json"
      ),
      "nested_registry_hash" => {
        "validated_by" => "IgniterLang::OOFFragmentRegistry#validate",
        "static_data_file" => false,
        "public_entrypoint_require" => false,
        "compiler_pass_integration" => false
      },
      "non_authority" => closed_surface_assertions
    }

    summary = {
      "kind" => "oof_fragment_registry_supplied_data_source_proof_summary",
      "format_version" => "0.1.0",
      "track" => TRACK,
      "status" => status,
      "source_model_id" => "oof_fragment_registry_source/sha256:#{Digest::SHA256.hexdigest(JSON.generate(source_model))[0, 24]}",
      "cases" => cases,
      "checks" => checks,
      "failed_cases" => failed_cases,
      "failed_checks" => failed_checks,
      "recommendation" => status == "PASS" ? "PASS_FOR_PROOF_ONLY_SUPPLIED_DATA_SOURCE_HOLD_IMPLEMENTATION" : "HOLD",
      "outputs" => {
        "summary" => "igniter-lang/experiments/oof_fragment_registry_supplied_data_source_proof/out/oof_fragment_registry_supplied_data_source_proof_summary.json",
        "source_model" => "igniter-lang/experiments/oof_fragment_registry_supplied_data_source_proof/out/oof_fragment_registry_source_model.json"
      },
      "closed_surfaces" => closed_surface_assertions,
      "implementation_authorized" => false
    }

    File.write(OUT_DIR / "oof_fragment_registry_source_model.json", "#{JSON.pretty_generate(source_model)}\n")
    File.write(OUT_DIR / "oof_fragment_registry_supplied_data_source_proof_summary.json", "#{JSON.pretty_generate(summary)}\n")

    if status == "PASS"
      puts "PASS #{TRACK}"
      puts "cases: #{cases.count { |entry| entry.fetch("status") == "PASS" }}/#{cases.length}"
      puts "checks: #{checks.count { |entry| entry.fetch("status") == "PASS" }}/#{checks.length}"
      puts "recommendation: #{summary.fetch("recommendation")}"
      true
    else
      warn "FAIL #{TRACK}"
      (failed_cases + failed_checks).each { |entry| warn "- #{entry.fetch("name")}" }
      false
    end
  end

  def supplied_source_envelope(registry)
    {
      "kind" => "oof_fragment_registry_source",
      "format_version" => "0.1.0",
      "source_mode" => "proof_fixture",
      "authority" => {
        "authority_ref" => "LANG-R106-D1",
        "authority_kind" => "proof_only",
        "canon_status" => "non_canon"
      },
      "row_authority_policy" => "whole_registry",
      "historical_source_refs" => [
        "experiments/oof_fragment_registry_shadow_proof/out/oof_descriptors.shadow_registry.json"
      ],
      "closed_surface_assertions" => closed_surface_assertions,
      "registry" => registry
    }
  end

  def validate_source_envelope(envelope)
    diagnostics = []

    unless envelope.is_a?(Hash)
      diagnostics << diag("oof_registry.source.validation.wrong_kind", "source envelope must be a Hash")
      return source_result(false, diagnostics, false)
    end

    diagnostics << diag("oof_registry.source.validation.wrong_kind", "kind must be oof_fragment_registry_source") unless envelope["kind"] == "oof_fragment_registry_source"
    diagnostics << diag("oof_registry.source.validation.unsupported_format_version", "format_version must be 0.1.0") unless envelope["format_version"] == "0.1.0"
    diagnostics << diag("oof_registry.source.validation.unsupported_source_mode", "source_mode must be proof_fixture or caller_supplied") unless VALID_SOURCE_MODES.include?(envelope["source_mode"])

    authority = envelope["authority"]
    if authority.is_a?(Hash)
      diagnostics << diag("oof_registry.source.validation.invalid_authority_kind", "authority_kind must remain proof/design scoped") unless VALID_AUTHORITY_KINDS.include?(authority["authority_kind"])
      diagnostics << diag("oof_registry.source.validation.invalid_canon_status", "canon_status must not be canon in this proof") unless VALID_CANON_STATUSES.include?(authority["canon_status"])
      diagnostics << diag("oof_registry.source.validation.missing_authority_ref", "authority_ref is required") if authority["authority_ref"].to_s.empty?
    else
      diagnostics << diag("oof_registry.source.validation.missing_authority", "authority object is required")
    end

    diagnostics << diag("oof_registry.source.validation.missing_registry", "nested registry hash is required") unless envelope["registry"].is_a?(Hash)
    diagnostics << diag("oof_registry.source.validation.surface_open", "closed_surface_assertions must all be false") unless envelope.fetch("closed_surface_assertions", {}).values.all?(false)

    source_result(diagnostics.empty?, diagnostics, envelope["registry"].is_a?(Hash))
  end

  def source_result(valid, diagnostics, registry_present)
    {
      "kind" => "oof_fragment_registry_source_validation",
      "format_version" => "0.1.0",
      "valid" => valid,
      "registry_present" => registry_present,
      "diagnostics" => diagnostics,
      "closed_surface_assertions" => closed_surface_assertions
    }
  end

  def rejected_case(name, envelope)
    case_result(name, expected: "rejected") do
      source_result = validate_source_envelope(envelope)
      [source_result.fetch("valid"), {
        "source_validation" => source_result,
        "public_fields_present" => public_result_keys(source_result)
      }]
    end
  end

  def case_result(name, expected:)
    accepted, details = yield
    expected_accepted = expected == "accepted"
    {
      "name" => name,
      "expected" => expected,
      "accepted" => accepted,
      "status" => accepted == expected_accepted ? "PASS" : "FAIL",
      "details" => details
    }
  end

  def check(name)
    { "name" => name, "status" => yield ? "PASS" : "FAIL" }
  end

  def diag(code, message)
    { "code" => code, "message" => message }
  end

  def internal_only_result?(result)
    !result.fetch("valid") &&
      result.fetch("diagnostics").any? &&
      public_result_keys(result).empty? &&
      result.fetch("closed_surface_assertions").values.all?(false)
  end

  def public_result_keys(result)
    return [] unless result.is_a?(Hash)

    result.keys & PUBLIC_RESULT_KEYS
  end

  def closed_surface_assertions
    {
      "static_data_file" => false,
      "lib_igniter_lang_rb_require" => false,
      "compiler_pass_integration" => false,
      "public_api_cli" => false,
      "top_level_report_diagnostics" => false,
      "compiler_result_field" => false,
      "loader_report" => false,
      "compatibility_report" => false,
      "runtime_behavior" => false,
      "igapp_mutation" => false,
      "specs_canon_proposals" => false
    }
  end
end

exit(OOFFragmentRegistrySuppliedDataSourceProof.run ? 0 : 1)
