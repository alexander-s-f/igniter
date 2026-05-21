#!/usr/bin/env ruby
# frozen_string_literal: true

# OOF/Fragment Registry Source Envelope Helper Proof
#
# Card: LANG-R111-I1
# Track: oof-fragment-registry-source-envelope-helper-proof-v0
# Authorized by: LANG-R110-A
#
# Proves:
#   - validate_source_envelope is implemented inside IgniterLang::OOFFragmentRegistry
#   - accepted modes (proof_fixture, caller_supplied) pass and validate nested registry
#   - wrong kind rejected internally
#   - missing registry rejected internally
#   - profile_candidate accepted inside internal helper only
#   - pack_descriptor_candidate accepted inside internal helper only
#   - canon status rejected internally
#   - open closed-surface assertion rejected internally
#   - invalid nested registry reports nested registry diagnostics without public surface keys
#   - oof_fragment_registry_data.rb remains absent
#   - lib/igniter_lang.rb is not changed or used as an exposure path
#   - compiler passes do not require or call the helper
#   - no public/report/runtime keys appear in helper results

require "digest"
require "fileutils"
require "json"
require "pathname"

ROOT    = Pathname.new(File.expand_path("../..", __dir__))
OUT_DIR = ROOT / "experiments/oof_fragment_registry_source_envelope_helper_proof/out"
FIXTURE_PATH = ROOT / "experiments/oof_fragment_registry_implementation_boundary_proof/fixtures/forward_shape_valid.json"

require_relative "../../lib/igniter_lang/oof_fragment_registry"

module OOFFragmentRegistrySourceEnvelopeHelperProof
  module_function

  TRACK = "oof-fragment-registry-source-envelope-helper-proof-v0"

  # Keys that must never appear in helper results (public/report/runtime surfaces).
  PUBLIC_SURFACE_KEYS = %w[
    igapp_path
    compilation_report_path
    report
    compatibility_report
    runtime_ready
    evaluation_ready
    compiler_result
    loader_report
  ].freeze

  def run
    FileUtils.mkdir_p(OUT_DIR)

    registry    = JSON.parse(File.read(FIXTURE_PATH, encoding: "utf-8"))
    validator   = IgniterLang::OOFFragmentRegistry.new
    cases       = []

    # -------------------------------------------------------------------------
    # Case 1 — valid proof_fixture source validates nested registry
    # -------------------------------------------------------------------------
    cases << run_case("SE1.valid_proof_fixture_source_validates_nested_registry", expected: true) do
      env    = proof_fixture_envelope(registry)
      result = validator.validate_source_envelope(env)
      raise "result not valid" unless result["valid"]
      raise "source_mode mismatch" unless result["source_mode"] == "proof_fixture"
      raise "registry_validation absent" unless result["registry_validation"].is_a?(Hash)
      raise "registry_validation not valid" unless result["registry_validation"]["valid"]
      result
    end

    # -------------------------------------------------------------------------
    # Case 2 — valid caller_supplied source validates nested registry
    # -------------------------------------------------------------------------
    cases << run_case("SE2.valid_caller_supplied_source_validates_nested_registry", expected: true) do
      env = proof_fixture_envelope(registry).merge(
        "source_mode" => "caller_supplied",
        "authority"   => {
          "authority_ref"  => "LANG-R111-I1/local-caller",
          "authority_kind" => "proof_only",
          "canon_status"   => "non_canon"
        }
      )
      result = validator.validate_source_envelope(env)
      raise "result not valid" unless result["valid"]
      raise "source_mode mismatch" unless result["source_mode"] == "caller_supplied"
      raise "registry_validation absent" unless result["registry_validation"].is_a?(Hash)
      result
    end

    # -------------------------------------------------------------------------
    # Case 3 — wrong kind rejected internally
    # -------------------------------------------------------------------------
    cases << run_case("SE3.wrong_kind_rejected_internally", expected: false) do
      env    = proof_fixture_envelope(registry).merge("kind" => "oof_fragment_registry")
      result = validator.validate_source_envelope(env)
      raise "should be invalid" if result["valid"]
      raise "no source_diagnostics" unless result["source_diagnostics"].any?
      raise "registry_validation should be nil" unless result["registry_validation"].nil?
      expected_code = "oof_registry.source.validation.wrong_kind"
      unless result["source_diagnostics"].any? { |d| d["code"] == expected_code }
        raise "expected #{expected_code} diagnostic, got #{result["source_diagnostics"].map { |d| d["code"] }.inspect}"
      end
      result
    end

    # -------------------------------------------------------------------------
    # Case 4 — missing registry rejected internally
    # -------------------------------------------------------------------------
    cases << run_case("SE4.missing_registry_rejected_internally", expected: false) do
      env = proof_fixture_envelope(registry).tap { |e| e.delete("registry") }
      result = validator.validate_source_envelope(env)
      raise "should be invalid" if result["valid"]
      raise "registry_present should be false" if result["registry_present"]
      raise "registry_validation should be nil" unless result["registry_validation"].nil?
      expected_code = "oof_registry.source.validation.missing_registry"
      unless result["source_diagnostics"].any? { |d| d["code"] == expected_code }
        raise "expected #{expected_code} diagnostic"
      end
      result
    end

    pack_candidates = pack_candidates_from_fixture(registry)

    # -------------------------------------------------------------------------
    # Case 5 — profile_candidate accepted inside internal helper only
    # -------------------------------------------------------------------------
    cases << run_case("SE5.profile_candidate_accepted_internally", expected: true) do
      env    = profile_candidate_envelope(pack_candidates, registry)
      result = validator.validate_source_envelope(env)
      raise "should be valid" unless result["valid"]
      raise "source_mode mismatch" unless result["source_mode"] == "profile_candidate"
      raise "source_diagnostics should be empty" unless result["source_diagnostics"].empty?
      raise "registry_validation should be present" unless result["registry_validation"].is_a?(Hash)
      raise "nested registry should be valid" unless result["registry_validation"]["valid"]
      result
    end

    # -------------------------------------------------------------------------
    # Case 6 — pack_descriptor_candidate accepted inside internal helper only
    # -------------------------------------------------------------------------
    cases << run_case("SE6.pack_descriptor_candidate_accepted_internally", expected: true) do
      env    = pack_candidates.first
      result = validator.validate_source_envelope(env)
      raise "should be valid" unless result["valid"]
      raise "source_mode mismatch" unless result["source_mode"] == "pack_descriptor_candidate"
      raise "source_diagnostics should be empty" unless result["source_diagnostics"].empty?
      raise "registry_validation should be nil" unless result["registry_validation"].nil?
      result
    end

    # -------------------------------------------------------------------------
    # Case 7 — canon status rejected internally
    # -------------------------------------------------------------------------
    cases << run_case("SE7.canon_status_rejected_internally", expected: false) do
      auth = {
        "authority_ref"  => "LANG-R111-I1/canon-test",
        "authority_kind" => "proof_only",
        "canon_status"   => "canon"
      }
      env    = proof_fixture_envelope(registry).merge("authority" => auth)
      result = validator.validate_source_envelope(env)
      raise "should be invalid" if result["valid"]
      raise "registry_validation should be nil" unless result["registry_validation"].nil?
      expected_code = "oof_registry.source.validation.canon_status_forbidden"
      unless result["source_diagnostics"].any? { |d| d["code"] == expected_code }
        raise "expected #{expected_code} diagnostic"
      end
      result
    end

    # -------------------------------------------------------------------------
    # Case 8 — open closed-surface assertion rejected internally
    # -------------------------------------------------------------------------
    cases << run_case("SE8.open_closed_surface_assertion_rejected_internally", expected: false) do
      env = proof_fixture_envelope(registry).merge(
        "closed_surface_assertions" => closed_surface_assertions.merge("public_api_cli" => true)
      )
      result = validator.validate_source_envelope(env)
      raise "should be invalid" if result["valid"]
      raise "registry_validation should be nil" unless result["registry_validation"].nil?
      expected_code = "oof_registry.source.validation.surface_open"
      unless result["source_diagnostics"].any? { |d| d["code"] == expected_code }
        raise "expected #{expected_code} diagnostic"
      end
      result
    end

    # -------------------------------------------------------------------------
    # Case 9 — invalid nested registry reports nested diagnostics without public surface keys
    # -------------------------------------------------------------------------
    cases << run_case("SE9.invalid_nested_registry_reports_diagnostics_without_public_surface_keys",
                      expected: false) do
      bad_registry = registry.merge("kind" => "not_oof_fragment_registry")
      env          = proof_fixture_envelope(bad_registry)
      result       = validator.validate_source_envelope(env)
      raise "should be invalid" if result["valid"]
      # Source envelope itself must be valid — source_diagnostics empty
      unless result["source_diagnostics"].empty?
        raise "source_diagnostics should be empty, got: #{result["source_diagnostics"].inspect}"
      end
      # Nested registry must have been called and have diagnostics
      reg_val = result["registry_validation"]
      raise "registry_validation should be present" unless reg_val.is_a?(Hash)
      raise "nested registry should be invalid" if reg_val["valid"]
      raise "nested diagnostics should be non-empty" unless reg_val["diagnostics"].any?
      # No public surface keys in either result
      public_in_result = PUBLIC_SURFACE_KEYS & result.keys
      public_in_reg    = PUBLIC_SURFACE_KEYS & reg_val.keys
      if public_in_result.any? || public_in_reg.any?
        raise "public surface keys found: result=#{public_in_result}, registry=#{public_in_reg}"
      end
      result
    end

    # -------------------------------------------------------------------------
    # Structural / closed-surface checks
    # -------------------------------------------------------------------------
    checks = []

    checks << check("CS1.oof_fragment_registry_data_rb_absent") do
      !ROOT.join("lib/igniter_lang/oof_fragment_registry_data.rb").exist?
    end

    checks << check("CS2.lib_igniter_lang_rb_does_not_require_registry") do
      main_lib = ROOT / "lib/igniter_lang.rb"
      !main_lib.exist? || !File.read(main_lib, encoding: "utf-8").include?("oof_fragment_registry")
    end

    checks << check("CS3.compiler_passes_do_not_require_helper") do
      compiler_names = %w[
        parser classifier typechecker semanticir_emitter assembler
        compiler_orchestrator compilation_report compiler_result cli diagnostics
      ]
      compiler_names.all? do |name|
        path = ROOT / "lib/igniter_lang/#{name}.rb"
        !path.exist? || !File.read(path, encoding: "utf-8").include?("oof_fragment_registry")
      end
    end

    checks << check("CS4.all_case_results_have_no_public_surface_keys") do
      cases.all? do |c|
        result  = c[:result]
        top_pub = PUBLIC_SURFACE_KEYS & result.keys
        reg_pub = if result["registry_validation"].is_a?(Hash)
                    PUBLIC_SURFACE_KEYS & result["registry_validation"].keys
                  else
                    []
                  end
        top_pub.empty? && reg_pub.empty?
      end
    end

    checks << check("CS5.all_helper_results_closed_surface_assertions_false") do
      cases.all? do |c|
        result = c[:result]
        assertions = result["closed_surface_assertions"]
        assertions.is_a?(Hash) && assertions.values.all?(false)
      end
    end

    checks << check("CS6.no_separate_helper_file") do
      !ROOT.join("lib/igniter_lang/oof_fragment_registry_source.rb").exist? &&
        !ROOT.join("lib/igniter_lang/oof_fragment_registry_helper.rb").exist?
    end

    checks << check("CS7.validate_source_envelope_is_instance_method_of_OOFFragmentRegistry") do
      IgniterLang::OOFFragmentRegistry.instance_methods(false).include?(:validate_source_envelope)
    end

    checks << check("CS8.validate_source_envelope_not_in_igniter_lang_rb_public_surface") do
      main_lib = ROOT / "lib/igniter_lang.rb"
      !main_lib.exist? || !File.read(main_lib).include?("validate_source_envelope")
    end

    checks << check("CS9.nested_registry_not_called_when_source_envelope_invalid") do
      # Cases 3, 4, 7, and 8 have invalid source envelopes → registry_validation must be nil.
      # Cases 5 and 6 are now accepted internally by LANG-R121-A/LANG-R122-I1.
      invalid_source_cases = cases.select do |c|
        %w[SE3 SE4 SE7 SE8].any? { |prefix| c[:name].start_with?(prefix) }
      end
      invalid_source_cases.all? { |c| c[:result]["registry_validation"].nil? }
    end

    checks << check("CS10.result_kind_is_oof_fragment_registry_source_validation") do
      cases.all? { |c| c[:result]["kind"] == "oof_fragment_registry_source_validation" }
    end

    # -------------------------------------------------------------------------
    # Final tallying
    # -------------------------------------------------------------------------
    failed_cases  = cases.select  { |c| c[:status] != "PASS" }
    failed_checks = checks.select { |c| c["status"] != "PASS" }
    status        = failed_cases.empty? && failed_checks.empty? ? "PASS" : "FAIL"

    summary = {
      "kind"           => "oof_fragment_registry_source_envelope_helper_proof_summary",
      "format_version" => "0.1.0",
      "track"          => TRACK,
      "status"         => status,
      "cases_total"    => cases.length,
      "cases_pass"     => cases.count { |c| c[:status] == "PASS" },
      "checks_total"   => checks.length,
      "checks_pass"    => checks.count { |c| c["status"] == "PASS" },
      "cases"          => cases.map { |c| c.reject { |k, _| k == :result } },
      "checks"         => checks,
      "failed_cases"   => failed_cases.map { |c| c.reject { |k, _| k == :result } },
      "failed_checks"  => failed_checks,
      "closed_surfaces" => closed_surface_assertions.merge(
        "specs_canon_proposals" => false
      ),
      "implementation_authorized" => true,
      "authorized_by"             => "LANG-R110-A plus LANG-R121-A/LANG-R122-I1",
      "accepted_modes"            => IgniterLang::OOFFragmentRegistry::SOURCE_ACCEPTED_MODES,
      "held_modes"                => IgniterLang::OOFFragmentRegistry::SOURCE_HELD_MODES
    }

    File.write(
      OUT_DIR / "oof_fragment_registry_source_envelope_helper_proof_summary.json",
      "#{JSON.pretty_generate(summary)}\n"
    )

    if status == "PASS"
      puts "PASS #{TRACK}"
      puts "cases:  #{summary["cases_pass"]}/#{summary["cases_total"]}"
      puts "checks: #{summary["checks_pass"]}/#{summary["checks_total"]}"
      true
    else
      warn "FAIL #{TRACK}"
      failed_cases.each  { |c| warn "  FAIL case:  #{c[:name]}" }
      failed_checks.each { |c| warn "  FAIL check: #{c["name"]}" }
      false
    end
  end

  # ---------------------------------------------------------------------------
  # Helpers
  # ---------------------------------------------------------------------------

  def proof_fixture_envelope(registry_hash)
    {
      "kind"           => "oof_fragment_registry_source",
      "format_version" => "0.1.0",
      "source_mode"    => "proof_fixture",
      "authority"      => {
        "authority_ref"  => "LANG-R111-I1",
        "authority_kind" => "proof_only",
        "canon_status"   => "non_canon"
      },
      "row_authority_policy"    => "whole_registry",
      "closed_surface_assertions" => closed_surface_assertions,
      "registry"                => registry_hash
    }
  end

  def pack_candidates_from_fixture(registry)
    owner_names = (
      registry.fetch("oof_descriptors").map { |row| row.fetch("owner_pack_or_boundary") } +
      registry.fetch("fragment_rows").map { |row| row.fetch("owner_pack_or_boundary") } +
      registry.dig("support_markers", "invariant_support_markers").map { |row| row.fetch("owner_pack_or_boundary") }
    ).uniq.sort

    owner_names.map do |owner|
      {
        "kind" => "oof_fragment_registry_source",
        "format_version" => "0.1.0",
        "source_mode" => "pack_descriptor_candidate",
        "authority" => r122_authority,
        "pack_ref" => "pack_descriptor_candidate/proof:#{owner}",
        "slot_name" => owner_to_slot(owner),
        "owner_pack_or_boundary" => owner,
        "row_authority_policy" => "pack_owns_declared_rows",
        "owned_oof_descriptors" => registry.fetch("oof_descriptors").select { |row| row.fetch("owner_pack_or_boundary") == owner },
        "owned_fragment_rows" => registry.fetch("fragment_rows").select { |row| row.fetch("owner_pack_or_boundary") == owner },
        "owned_support_markers" => registry.dig("support_markers", "invariant_support_markers").select { |row| row.fetch("owner_pack_or_boundary") == owner },
        "closed_surface_assertions" => closed_surface_assertions
      }
    end
  end

  def profile_candidate_envelope(pack_candidates, registry)
    selected_refs = pack_candidates.map { |pack| pack.fetch("pack_ref") }
    {
      "kind" => "oof_fragment_registry_source",
      "format_version" => "0.1.0",
      "source_mode" => "profile_candidate",
      "authority" => r122_authority,
      "profile_ref" => "compiler_profile_candidate/proof:LANG-R123-refresh",
      "profile_contract_ref" => "compiler_profile_contract_candidate/proof:LANG-R123-refresh",
      "row_authority_policy" => "pack_descriptor_rows_aggregated_by_profile",
      "selected_pack_refs" => selected_refs,
      "pack_order" => selected_refs,
      "conflict_policy" => {
        "duplicate_oof_descriptor" => "reject",
        "duplicate_fragment_row" => "reject",
        "duplicate_support_marker" => "reject",
        "duplicate_alias_owner" => "reject",
        "missing_selected_pack_ref" => "reject",
        "excluded_namespace" => "reject"
      },
      "pack_descriptor_candidates" => pack_candidates,
      "excluded_namespaces" => registry.fetch("excluded_namespaces"),
      "closed_surface_assertions" => closed_surface_assertions
    }
  end

  def r122_authority
    {
      "authority_ref" => "LANG-R121-A plus LANG-R122-I1",
      "authority_kind" => "proof_only",
      "canon_status" => "non_canon"
    }
  end

  def owner_to_slot(owner)
    owner.gsub(/Pack\z/, "").gsub(/([a-z])([A-Z])/, "\\1_\\2").downcase
  end

  def closed_surface_assertions
    {
      "static_data_file"             => false,
      "lib_igniter_lang_rb_require"  => false,
      "compiler_pass_integration"    => false,
      "public_api_cli"               => false,
      "top_level_report_diagnostics" => false,
      "compiler_result_field"        => false,
      "loader_report"                => false,
      "compatibility_report"         => false,
      "runtime_behavior"             => false,
      "igapp_mutation"               => false,
      "specs_canon_proposals"        => false
    }
  end

  def run_case(name, expected:)
    result = yield
    {
      name:   name,
      status: (result["valid"] == expected) ? "PASS" : "FAIL",
      result: result
    }
  rescue => e
    {
      name:   name,
      status: "FAIL",
      error:  e.message,
      result: {}
    }
  end

  def check(name)
    passed = yield
    { "name" => name, "status" => passed ? "PASS" : "FAIL" }
  rescue => e
    { "name" => name, "status" => "FAIL", "error" => e.message }
  end
end

exit(OOFFragmentRegistrySourceEnvelopeHelperProof.run ? 0 : 1)
