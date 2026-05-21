#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "json"
require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
OUT_DIR = ROOT / "experiments/oof_fragment_registry_profile_pack_source_acceptance_proof/out"
FIXTURE_PATH = ROOT / "experiments/oof_fragment_registry_implementation_boundary_proof/fixtures/forward_shape_valid.json"

require_relative "../../lib/igniter_lang/oof_fragment_registry"

module OOFFragmentRegistryProfilePackSourceAcceptanceProof
  module_function

  TRACK = "oof-fragment-registry-profile-pack-source-acceptance-proof-v0"
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

    registry = JSON.parse(File.read(FIXTURE_PATH, encoding: "utf-8"))
    validator = IgniterLang::OOFFragmentRegistry.new
    pack_candidates = pack_candidates_from_fixture(registry)
    profile = profile_candidate(pack_candidates, registry)
    cases = []

    cases << case_result("accepted_modes_changed_only_for_authorized_modes", expected: true) do
      accepted = IgniterLang::OOFFragmentRegistry::SOURCE_ACCEPTED_MODES
      held = IgniterLang::OOFFragmentRegistry::SOURCE_HELD_MODES
      ok = accepted == %w[proof_fixture caller_supplied profile_candidate pack_descriptor_candidate] &&
        held.empty?
      [ok, { "accepted_modes" => accepted, "held_modes" => held }]
    end

    cases << case_result("valid_pack_descriptor_candidate_accepted_without_registry", expected: true) do
      envelope = pack_candidates.first
      result = validator.validate_source_envelope(envelope)
      ok = result.fetch("valid") &&
        result.fetch("source_mode") == "pack_descriptor_candidate" &&
        result.fetch("registry_validation").nil? &&
        result.fetch("source_diagnostics").empty?
      [ok, { "source_validation" => result }]
    end

    cases << case_result("valid_profile_candidate_derives_and_validates_registry", expected: true) do
      result = validator.validate_source_envelope(profile)
      ok = result.fetch("valid") &&
        result.fetch("source_mode") == "profile_candidate" &&
        result.fetch("registry_validation").is_a?(Hash) &&
        result.fetch("registry_validation").fetch("valid") &&
        result.fetch("source_diagnostics").empty?
      [ok, { "source_validation" => result }]
    end

    cases << rejection_case("duplicate_oof_descriptor_ownership_rejected",
      expected_code: "oof_registry.source.validation.duplicate_row_ownership") do
      dup = deep_copy(pack_candidates)
      dup[1]["owned_oof_descriptors"] << deep_copy(dup[0].fetch("owned_oof_descriptors").first)
      profile_candidate(dup, registry)
    end

    cases << rejection_case("duplicate_fragment_row_ownership_rejected",
      expected_code: "oof_registry.source.validation.duplicate_row_ownership") do
      dup = deep_copy(pack_candidates)
      dup[1]["owned_fragment_rows"] << deep_copy(dup[0].fetch("owned_fragment_rows").first)
      profile_candidate(dup, registry)
    end

    cases << rejection_case("duplicate_support_marker_ownership_rejected",
      expected_code: "oof_registry.source.validation.duplicate_row_ownership") do
      dup = deep_copy(pack_candidates)
      marker_pack_index = dup.index { |pack| pack.fetch("owned_support_markers").any? }
      target_index = marker_pack_index.zero? ? 1 : 0
      dup[target_index]["owned_support_markers"] << deep_copy(dup[marker_pack_index].fetch("owned_support_markers").first)
      profile_candidate(dup, registry)
    end

    cases << rejection_case("duplicate_alias_ownership_rejected",
      expected_code: "oof_registry.source.validation.duplicate_alias_ownership") do
      dup = deep_copy(pack_candidates)
      source_alias_row = dup.find { |pack| pack.fetch("owned_oof_descriptors").any? { |row| Array(row["aliases"]).any? } }
        .fetch("owned_oof_descriptors")
        .find { |row| Array(row["aliases"]).any? }
      dup[0]["owned_oof_descriptors"].first["aliases"] = [source_alias_row.fetch("aliases").first]
      profile_candidate(dup, registry)
    end

    cases << rejection_case("missing_selected_pack_ref_rejected",
      expected_code: "oof_registry.source.validation.missing_selected_pack_ref") do
      profile.merge(
        "selected_pack_refs" => profile.fetch("selected_pack_refs") + ["pack_descriptor_candidate/proof:MissingPack"],
        "pack_order" => profile.fetch("pack_order") + ["pack_descriptor_candidate/proof:MissingPack"]
      )
    end

    cases << rejection_case("excluded_namespace_claim_rejected",
      expected_code: "oof_registry.source.validation.excluded_namespace_claim") do
      dup = deep_copy(pack_candidates)
      dup.first.fetch("owned_oof_descriptors").first["code"] = "compiler_profile_contract.contract_digest_mismatch"
      profile_candidate(dup, registry)
    end

    cases << rejection_case("profile_override_of_pack_conflict_rejected",
      expected_code: "oof_registry.source.validation.profile_override_forbidden") do
      profile.merge("row_conflict_overrides" => { "OOF-P0" => pack_candidates.first.fetch("pack_ref") })
    end

    cases << rejection_case("invalid_authority_kind_rejected_before_nested_validation",
      expected_code: "oof_registry.source.validation.invalid_authority_kind") do
      profile.merge("authority" => authority.merge("authority_kind" => "runtime"))
    end

    cases << rejection_case("canon_status_rejected_before_nested_validation",
      expected_code: "oof_registry.source.validation.canon_status_forbidden") do
      profile.merge("authority" => authority.merge("canon_status" => "canon"))
    end

    cases << case_result("proof_fixture_and_caller_supplied_still_accepted", expected: true) do
      proof_fixture = validator.validate_source_envelope(direct_registry_source("proof_fixture", registry))
      caller = validator.validate_source_envelope(direct_registry_source("caller_supplied", registry))
      ok = proof_fixture.fetch("valid") && caller.fetch("valid")
      [ok, { "proof_fixture" => proof_fixture, "caller_supplied" => caller }]
    end

    checks = []
    checks << check("helper_result_family_internal_only") do
      cases.all? do |entry|
        result = entry.dig("details", "source_validation")
        result.nil? || result["kind"] == "oof_fragment_registry_source_validation"
      end
    end

    checks << check("no_public_surface_keys_in_results") do
      cases.all? do |entry|
        result = entry.dig("details", "source_validation")
        result.nil? || public_keys_in(result).empty?
      end
    end

    checks << check("closed_surface_assertions_false") do
      cases.all? do |entry|
        result = entry.dig("details", "source_validation")
        result.nil? || result.fetch("closed_surface_assertions").values.all?(false)
      end
    end

    checks << check("surface_files_not_opened") do
      surface_files_closed?
    end

    checks << check("prop036_prop038_surfaces_not_mutated") do
      no_file_mentions_this_proof?(%w[
        docs/proposals/PROP-036-compiler-profile-manifest-identity-v0.md
        docs/proposals/PROP-038-compiler-profile-contract-v0.md
        lib/igniter_lang/compiler_profile_contract_validator.rb
        lib/igniter_lang/assembler.rb
        lib/igniter_lang/compiler_orchestrator.rb
        lib/igniter_lang/compilation_report.rb
      ])
    end

    failed_cases = cases.select { |entry| entry.fetch("status") != "PASS" }
    failed_checks = checks.select { |entry| entry.fetch("status") != "PASS" }
    status = failed_cases.empty? && failed_checks.empty? ? "PASS" : "FAIL"

    summary = {
      "kind" => "oof_fragment_registry_profile_pack_source_acceptance_proof_summary",
      "format_version" => "0.1.0",
      "track" => TRACK,
      "status" => status,
      "cases_total" => cases.length,
      "cases_pass" => cases.count { |entry| entry.fetch("status") == "PASS" },
      "checks_total" => checks.length,
      "checks_pass" => checks.count { |entry| entry.fetch("status") == "PASS" },
      "cases" => cases,
      "checks" => checks,
      "failed_cases" => failed_cases,
      "failed_checks" => failed_checks,
      "accepted_modes" => IgniterLang::OOFFragmentRegistry::SOURCE_ACCEPTED_MODES,
      "held_modes" => IgniterLang::OOFFragmentRegistry::SOURCE_HELD_MODES,
      "closed_surfaces" => closed_surface_assertions,
      "recommendation" => status == "PASS" ? "PROFILE_PACK_SOURCE_ACCEPTANCE_PROOF_PASS" : "HOLD"
    }

    File.write(
      OUT_DIR / "oof_fragment_registry_profile_pack_source_acceptance_proof_summary.json",
      "#{JSON.pretty_generate(summary)}\n"
    )

    if status == "PASS"
      puts "PASS #{TRACK}"
      puts "cases: #{summary.fetch("cases_pass")}/#{summary.fetch("cases_total")}"
      puts "checks: #{summary.fetch("checks_pass")}/#{summary.fetch("checks_total")}"
      true
    else
      warn "FAIL #{TRACK}"
      (failed_cases + failed_checks).each { |entry| warn "- #{entry.fetch("name")}" }
      false
    end
  end

  def rejection_case(name, expected_code:)
    case_result(name, expected: true) do
      result = IgniterLang::OOFFragmentRegistry.new.validate_source_envelope(yield)
      ok = !result.fetch("valid") &&
        result.fetch("registry_validation").nil? &&
        result.fetch("source_diagnostics").any? { |diag| diag.fetch("code") == expected_code }
      [ok, { "source_validation" => result, "expected_code" => expected_code }]
    end
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
        "authority" => authority,
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

  def profile_candidate(pack_candidates, registry)
    selected_refs = pack_candidates.map { |pack| pack.fetch("pack_ref") }
    {
      "kind" => "oof_fragment_registry_source",
      "format_version" => "0.1.0",
      "source_mode" => "profile_candidate",
      "authority" => authority,
      "profile_ref" => "compiler_profile_candidate/proof:LANG-R122-local",
      "profile_contract_ref" => "compiler_profile_contract_candidate/proof:LANG-R122-local",
      "row_authority_policy" => "pack_descriptor_rows_aggregated_by_profile",
      "authority_precedence" => {
        "row_identity_and_ownership" => "pack_row_authority",
        "selected_pack_set_order_conflict_policy" => "profile_level_authority",
        "pack_row_conflict" => "profile_rejects_aggregate_no_override"
      },
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

  def direct_registry_source(source_mode, registry)
    {
      "kind" => "oof_fragment_registry_source",
      "format_version" => "0.1.0",
      "source_mode" => source_mode,
      "authority" => authority,
      "registry" => registry,
      "closed_surface_assertions" => closed_surface_assertions
    }
  end

  def case_result(name, expected:)
    accepted, details = yield
    {
      "name" => name,
      "expected" => expected,
      "accepted" => accepted,
      "status" => accepted == expected ? "PASS" : "FAIL",
      "details" => details
    }
  rescue StandardError => e
    {
      "name" => name,
      "expected" => expected,
      "accepted" => false,
      "status" => expected == false ? "PASS" : "FAIL",
      "error" => "#{e.class}: #{e.message}",
      "details" => {}
    }
  end

  def check(name)
    { "name" => name, "status" => yield ? "PASS" : "FAIL" }
  rescue StandardError => e
    { "name" => name, "status" => "FAIL", "error" => "#{e.class}: #{e.message}" }
  end

  def public_keys_in(value)
    keys = []
    case value
    when Hash
      keys.concat(PUBLIC_SURFACE_KEYS & value.keys)
      value.each do |key, inner|
        next if key == "closed_surface_assertions"

        keys.concat(public_keys_in(inner))
      end
    when Array
      value.each { |inner| keys.concat(public_keys_in(inner)) }
    end
    keys.uniq
  end

  def surface_files_closed?
    !ROOT.join("lib/igniter_lang/oof_fragment_registry_data.rb").exist? &&
      !ROOT.join("lib/igniter_lang/oof_fragment_registry_source.rb").exist? &&
      !ROOT.join("lib/igniter_lang/oof_fragment_registry_helper.rb").exist? &&
      no_file_mentions_this_proof?(%w[
        lib/igniter_lang.rb
        lib/igniter_lang/parser.rb
        lib/igniter_lang/classifier.rb
        lib/igniter_lang/typechecker.rb
        lib/igniter_lang/semanticir_emitter.rb
        lib/igniter_lang/assembler.rb
        lib/igniter_lang/compiler_orchestrator.rb
        lib/igniter_lang/compilation_report.rb
        lib/igniter_lang/compiler_result.rb
        lib/igniter_lang/cli.rb
        lib/igniter_lang/diagnostics.rb
      ])
  end

  def no_file_mentions_this_proof?(paths)
    paths.all? do |relative|
      path = ROOT / relative
      !path.exist? || !File.read(path, encoding: "utf-8").include?(TRACK)
    end
  end

  def owner_to_slot(owner)
    owner.gsub(/Pack\z/, "").gsub(/([a-z])([A-Z])/, "\\1_\\2").downcase
  end

  def authority
    {
      "authority_ref" => "LANG-R121-A plus LANG-R122-I1",
      "authority_kind" => "proof_only",
      "canon_status" => "non_canon"
    }
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
      "specs_canon_proposals" => false,
      "prop036_manifest_change" => false,
      "prop038_validator_report_change" => false
    }
  end

  def deep_copy(value)
    JSON.parse(JSON.generate(value))
  end
end

exit(OOFFragmentRegistryProfilePackSourceAcceptanceProof.run ? 0 : 1)
