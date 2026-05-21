#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "pathname"
require "set"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
OUT_DIR = ROOT / "experiments/oof_fragment_registry_source_authority_precedence_proof/out"
FIXTURE_PATH = ROOT / "experiments/oof_fragment_registry_implementation_boundary_proof/fixtures/forward_shape_valid.json"
R115_SUMMARY_PATH = ROOT / "experiments/oof_fragment_registry_profile_pack_source_mode_proof/out/oof_fragment_registry_profile_pack_source_mode_proof_summary.json"

require_relative "../../lib/igniter_lang/oof_fragment_registry"

module OOFFragmentRegistrySourceAuthorityPrecedenceProof
  module_function

  TRACK = "oof-fragment-registry-source-authority-precedence-proof-v0"
  HELD_CODE = IgniterLang::OOFFragmentRegistry::SOURCE_DIAG_HELD_SOURCE_MODE
  EXCLUDED_PREFIXES = IgniterLang::OOFFragmentRegistry::REQUIRED_EXCLUDED_PREFIXES

  def run
    FileUtils.mkdir_p(OUT_DIR)

    fixture_registry = JSON.parse(File.read(FIXTURE_PATH))
    r115_summary = JSON.parse(File.read(R115_SUMMARY_PATH))
    validator = IgniterLang::OOFFragmentRegistry.new
    pack_candidates = pack_candidates_from_fixture(fixture_registry)
    selected_refs = pack_candidates.map { |candidate| candidate.fetch("pack_ref") }
    profile = profile_candidate(selected_refs)

    cases = []

    cases << case_result("pack_row_authority_owns_row_provenance", expected: "accepted") do
      result = validate_pack_row_provenance(pack_candidates)
      [result.fetch("valid"), { "pack_row_provenance_validation" => result }]
    end

    cases << case_result("profile_authority_owns_selected_pack_set_order_conflict_policy", expected: "accepted") do
      result = validate_profile_authority(profile, pack_candidates)
      [result.fetch("valid"), { "profile_authority_validation" => result }]
    end

    cases << case_result("derived_registry_validates_after_proof_model_aggregation", expected: "accepted") do
      aggregate = aggregate_registry(profile, pack_candidates, fixture_registry)
      registry_result = aggregate.fetch("valid") ? validator.validate(aggregate.fetch("registry")) : nil
      [aggregate.fetch("valid") && registry_result.fetch("valid"), {
        "aggregate_validation" => aggregate,
        "registry_validation_called" => !registry_result.nil?,
        "nested_registry_validation" => registry_result,
        "validated_by" => "IgniterLang::OOFFragmentRegistry#validate"
      }]
    end

    duplicate_oof_packs = deep_copy(pack_candidates)
    duplicate_oof_packs[1]["owned_oof_descriptors"] << deep_copy(duplicate_oof_packs[0].fetch("owned_oof_descriptors").first)
    cases << case_result("duplicate_row_ownership_rejects_aggregate", expected: "rejected") do
      aggregate = aggregate_registry(profile_candidate(duplicate_oof_packs.map { |candidate| candidate.fetch("pack_ref") }), duplicate_oof_packs, fixture_registry)
      [aggregate.fetch("valid"), {
        "aggregate_validation" => aggregate,
        "registry_validation_called" => false
      }]
    end

    override_packs = deep_copy(duplicate_oof_packs)
    override_profile = profile_candidate(override_packs.map { |candidate| candidate.fetch("pack_ref") }).merge(
      "row_conflict_overrides" => {
        "OOF-P0" => override_packs.first.fetch("pack_ref")
      }
    )
    cases << case_result("profile_cannot_silently_override_pack_row_conflicts", expected: "rejected") do
      aggregate = aggregate_registry(override_profile, override_packs, fixture_registry)
      [aggregate.fetch("valid"), {
        "aggregate_validation" => aggregate,
        "profile_override_present" => true,
        "registry_validation_called" => false
      }]
    end

    missing_pack_profile = profile_candidate(selected_refs + ["pack_descriptor_candidate/proof:MissingPack"])
    cases << case_result("missing_selected_pack_ref_rejects_aggregate", expected: "rejected") do
      aggregate = aggregate_registry(missing_pack_profile, pack_candidates, fixture_registry)
      [aggregate.fetch("valid"), {
        "aggregate_validation" => aggregate,
        "registry_validation_called" => false
      }]
    end

    excluded_packs = deep_copy(pack_candidates)
    excluded_packs.first.fetch("owned_oof_descriptors").first["code"] = "compiler_profile_contract.contract_digest_mismatch"
    cases << case_result("excluded_namespace_rejects_aggregate", expected: "rejected") do
      aggregate = aggregate_registry(profile_candidate(excluded_packs.map { |candidate| candidate.fetch("pack_ref") }), excluded_packs, fixture_registry)
      [aggregate.fetch("valid"), {
        "aggregate_validation" => aggregate,
        "registry_validation_called" => false
      }]
    end

    cases << case_result("live_helper_profile_candidate_still_held", expected: "rejected") do
      envelope = profile_source_envelope(profile, fixture_registry)
      result = validator.validate_source_envelope(envelope)
      [result.fetch("valid"), {
        "source_validation" => result,
        "held_source_mode" => has_diag?(result, HELD_CODE),
        "registry_validation_called" => !result.fetch("registry_validation").nil?
      }]
    end

    cases << case_result("live_helper_pack_descriptor_candidate_still_held", expected: "rejected") do
      envelope = pack_source_envelope(pack_candidates.first, fixture_registry)
      result = validator.validate_source_envelope(envelope)
      [result.fetch("valid"), {
        "source_validation" => result,
        "held_source_mode" => has_diag?(result, HELD_CODE),
        "registry_validation_called" => !result.fetch("registry_validation").nil?
      }]
    end

    checks = []
    checks << check("r115_profile_pack_proof.pass_evidence") { r115_summary.fetch("status") == "PASS" }
    checks << check("case_matrix.expected_results") { cases.all? { |entry| entry.fetch("status") == "PASS" } }
    checks << check("pack_row_authority_primary") do
      cases.find { |entry| entry.fetch("name") == "pack_row_authority_owns_row_provenance" }
        .dig("details", "pack_row_provenance_validation", "valid") == true
    end
    checks << check("profile_authority_owns_selection_order_conflict_policy") do
      cases.find { |entry| entry.fetch("name") == "profile_authority_owns_selected_pack_set_order_conflict_policy" }
        .dig("details", "profile_authority_validation", "valid") == true
    end
    checks << check("conflicts_reject_without_profile_override") do
      %w[
        duplicate_row_ownership_rejects_aggregate
        profile_cannot_silently_override_pack_row_conflicts
        missing_selected_pack_ref_rejects_aggregate
        excluded_namespace_rejects_aggregate
      ].all? { |name| cases.find { |entry| entry.fetch("name") == name }.fetch("accepted") == false }
    end
    checks << check("derived_registry_validates_only_after_aggregation") do
      success = cases.find { |entry| entry.fetch("name") == "derived_registry_validates_after_proof_model_aggregation" }
      invalids = cases.select { |entry| entry.fetch("details", {}).fetch("registry_validation_called", nil) == false }
      success.dig("details", "registry_validation_called") == true &&
        success.dig("details", "nested_registry_validation", "valid") == true &&
        invalids.any?
    end
    checks << check("live_helper_profile_pack_modes_held") do
      %w[
        live_helper_profile_candidate_still_held
        live_helper_pack_descriptor_candidate_still_held
      ].all? do |name|
        entry = cases.find { |candidate| candidate.fetch("name") == name }
        entry.dig("details", "held_source_mode") == true &&
          entry.dig("details", "registry_validation_called") == false
      end
    end
    checks << check("source_accepted_modes_unchanged") do
      IgniterLang::OOFFragmentRegistry::SOURCE_ACCEPTED_MODES == %w[proof_fixture caller_supplied]
    end
    checks << check("closed_surfaces_preserved") do
      closed_surface_assertions.values.all?(false) &&
        no_live_surface_files_refer_to_this_proof?
    end

    failed_cases = cases.select { |entry| entry.fetch("status") != "PASS" }
    failed_checks = checks.select { |entry| entry.fetch("status") != "PASS" }
    status = failed_cases.empty? && failed_checks.empty? ? "PASS" : "FAIL"

    aggregate = aggregate_registry(profile, pack_candidates, fixture_registry)
    derived_registry = aggregate.fetch("registry")
    model = {
      "kind" => "oof_fragment_registry_source_authority_precedence_model",
      "format_version" => "0.1.0",
      "track" => TRACK,
      "authority_precedence" => {
        "row_identity_and_ownership" => "pack_row_authority",
        "selected_pack_set_order_conflict_policy" => "profile_level_authority",
        "pack_row_conflict" => "profile_rejects_aggregate_no_override"
      },
      "profile_candidate" => profile,
      "pack_descriptor_candidates" => pack_candidates.map { |candidate| candidate.slice("pack_ref", "slot_name", "owner_pack_or_boundary") },
      "derived_registry_ref" => "out/derived_registry_authority_precedence.json",
      "live_helper_acceptance" => "held_source_mode_for_profile_and_pack_candidates",
      "closed_surface_assertions" => closed_surface_assertions
    }

    summary = {
      "kind" => "oof_fragment_registry_source_authority_precedence_proof_summary",
      "format_version" => "0.1.0",
      "track" => TRACK,
      "status" => status,
      "model_id" => "oof_fragment_source_authority_precedence/sha256:#{Digest::SHA256.hexdigest(JSON.generate(model))[0, 24]}",
      "cases" => cases,
      "checks" => checks,
      "failed_cases" => failed_cases,
      "failed_checks" => failed_checks,
      "recommendation" => status == "PASS" ? "SOURCE_AUTHORITY_DESIGN_ACCEPTED_FOR_PROOF_HOLD_IMPLEMENTATION" : "HOLD",
      "outputs" => {
        "summary" => "igniter-lang/experiments/oof_fragment_registry_source_authority_precedence_proof/out/oof_fragment_registry_source_authority_precedence_proof_summary.json",
        "model" => "igniter-lang/experiments/oof_fragment_registry_source_authority_precedence_proof/out/oof_fragment_registry_source_authority_precedence_model.json",
        "derived_registry" => "igniter-lang/experiments/oof_fragment_registry_source_authority_precedence_proof/out/derived_registry_authority_precedence.json"
      },
      "closed_surfaces" => closed_surface_assertions,
      "implementation_authorized" => false
    }

    File.write(OUT_DIR / "derived_registry_authority_precedence.json", "#{JSON.pretty_generate(derived_registry)}\n")
    File.write(OUT_DIR / "oof_fragment_registry_source_authority_precedence_model.json", "#{JSON.pretty_generate(model)}\n")
    File.write(OUT_DIR / "oof_fragment_registry_source_authority_precedence_proof_summary.json", "#{JSON.pretty_generate(summary)}\n")

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

  def pack_candidates_from_fixture(registry)
    owner_names = (
      registry.fetch("oof_descriptors").map { |row| row.fetch("owner_pack_or_boundary") } +
      registry.fetch("fragment_rows").map { |row| row.fetch("owner_pack_or_boundary") } +
      registry.dig("support_markers", "invariant_support_markers").map { |row| row.fetch("owner_pack_or_boundary") }
    ).uniq.sort

    owner_names.map do |owner|
      {
        "kind" => "oof_fragment_registry_pack_descriptor_candidate",
        "format_version" => "0.1.0",
        "source_mode" => "pack_descriptor_candidate",
        "authority" => proof_authority,
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

  def profile_candidate(selected_pack_refs)
    {
      "kind" => "oof_fragment_registry_source",
      "format_version" => "0.1.0",
      "source_mode" => "profile_candidate",
      "authority" => proof_authority,
      "profile_ref" => "compiler_profile_candidate/proof:LANG-R117-local",
      "row_authority_policy" => "pack_descriptor_rows_aggregated_by_profile",
      "selected_pack_refs" => selected_pack_refs,
      "pack_order" => selected_pack_refs,
      "conflict_policy" => "reject_duplicate_row_ownership",
      "closed_surface_assertions" => closed_surface_assertions
    }
  end

  def validate_pack_row_provenance(pack_candidates)
    diagnostics = []
    pack_candidates.each do |pack|
      if pack["pack_ref"].to_s.empty?
        diagnostics << diag("authority_precedence.pack_ref_missing", "pack descriptor candidate must have pack_ref")
      end
      expected_owner = pack.fetch("owner_pack_or_boundary")
      rows = pack.fetch("owned_oof_descriptors") + pack.fetch("owned_fragment_rows") + pack.fetch("owned_support_markers")
      rows.each do |row|
        unless row.fetch("owner_pack_or_boundary") == expected_owner
          diagnostics << diag("authority_precedence.row_owner_mismatch", "#{row.fetch("code", row.fetch("name", "row"))} owner does not match pack authority")
        end
      end
    end
    result(diagnostics)
  end

  def validate_profile_authority(profile, pack_candidates)
    diagnostics = []
    pack_refs = pack_candidates.map { |pack| pack.fetch("pack_ref") }
    selected = profile.fetch("selected_pack_refs", [])
    if selected.empty?
      diagnostics << diag("authority_precedence.profile_selected_pack_refs_missing", "profile must select pack refs")
    end
    missing = selected - pack_refs
    unless missing.empty?
      diagnostics << diag("authority_precedence.missing_selected_pack_ref", "profile selected missing pack refs: #{missing.join(", ")}")
    end
    if profile.fetch("pack_order", []) != selected
      diagnostics << diag("authority_precedence.profile_order_mismatch", "profile pack_order must match selected_pack_refs")
    end
    unless profile.fetch("conflict_policy", nil) == "reject_duplicate_row_ownership"
      diagnostics << diag("authority_precedence.conflict_policy_invalid", "profile conflict_policy must reject duplicate row ownership")
    end
    result(diagnostics)
  end

  def aggregate_registry(profile, pack_candidates, fixture_registry)
    diagnostics = []
    diagnostics.concat(validate_profile_authority(profile, pack_candidates).fetch("diagnostics"))
    diagnostics.concat(validate_pack_row_provenance(pack_candidates).fetch("diagnostics"))

    if profile.fetch("row_conflict_overrides", {}).any?
      diagnostics << diag("authority_precedence.profile_override_forbidden", "profile cannot silently override pack-row conflicts")
    end

    selected = profile.fetch("selected_pack_refs", [])
    packs_by_ref = pack_candidates.to_h { |pack| [pack.fetch("pack_ref"), pack] }
    selected_packs = selected.map { |ref| packs_by_ref[ref] }.compact

    diagnostics.concat(row_conflict_diagnostics(selected_packs))
    diagnostics.concat(excluded_namespace_diagnostics(selected_packs))

    return result(diagnostics).merge("registry" => nil) unless diagnostics.empty?

    registry = {
      "kind" => "oof_fragment_registry",
      "format_version" => "0.1.0",
      "source_authority" => {
        "authority_ref" => "LANG-R117-P1/proof-authority-precedence",
        "authority_kind" => "proof_only",
        "canon_status" => "non_canon",
        "profile_ref" => profile.fetch("profile_ref"),
        "profile_authority_scope" => "selected_pack_set_order_conflict_policy",
        "pack_row_authority_scope" => "row_identity_ownership"
      },
      "historical_source_refs" => fixture_registry.fetch("historical_source_refs", []),
      "migration_policy" => "proof_derived_after_authority_precedence_aggregation",
      "forward_shape_authority" => fixture_registry.fetch("forward_shape_authority"),
      "oof_descriptors" => selected_packs.flat_map { |pack| annotate_rows(pack.fetch("owned_oof_descriptors"), pack) },
      "fragment_rows" => selected_packs.flat_map { |pack| annotate_rows(pack.fetch("owned_fragment_rows"), pack) },
      "support_markers" => {
        "invariant_support_markers" => selected_packs.flat_map { |pack| annotate_rows(pack.fetch("owned_support_markers"), pack) }
      },
      "excluded_namespaces" => fixture_registry.fetch("excluded_namespaces")
    }
    result([]).merge("registry" => registry)
  end

  def row_conflict_diagnostics(selected_packs)
    diagnostics = []
    seen = {}
    selected_packs.each do |pack|
      pack.fetch("owned_oof_descriptors").each do |row|
        key = "oof_descriptor:#{row.fetch("code")}"
        diagnostics.concat(row_conflict_for(key, pack, seen))
      end
      pack.fetch("owned_fragment_rows").each do |row|
        key = "fragment_row:#{row.fetch("name")}"
        diagnostics.concat(row_conflict_for(key, pack, seen))
      end
      pack.fetch("owned_support_markers").each do |row|
        key = "support_marker:#{row.fetch("code")}"
        diagnostics.concat(row_conflict_for(key, pack, seen))
      end
    end
    diagnostics
  end

  def row_conflict_for(key, pack, seen)
    if seen.key?(key) && seen.fetch(key) != pack.fetch("pack_ref")
      [diag("authority_precedence.duplicate_row_ownership", "#{key} claimed by #{seen.fetch(key)} and #{pack.fetch("pack_ref")}")]
    else
      seen[key] = pack.fetch("pack_ref")
      []
    end
  end

  def excluded_namespace_diagnostics(selected_packs)
    selected_packs.flat_map do |pack|
      pack.fetch("owned_oof_descriptors").flat_map do |row|
        tokens = [row.fetch("code")] + row.fetch("aliases", [])
        tokens.flat_map do |token|
          EXCLUDED_PREFIXES
            .select { |prefix| token.start_with?(prefix) }
            .map { |prefix| diag("authority_precedence.excluded_oof_namespace", "#{token} is under excluded namespace #{prefix}") }
        end
      end
    end
  end

  def annotate_rows(rows, pack)
    rows.map do |row|
      deep_copy(row).merge(
        "row_authority" => {
          "pack_ref" => pack.fetch("pack_ref"),
          "authority_kind" => "proof_only",
          "canon_status" => "non_canon"
        }
      )
    end
  end

  def profile_source_envelope(profile, registry)
    profile.merge("registry" => registry)
  end

  def pack_source_envelope(pack, registry)
    {
      "kind" => "oof_fragment_registry_source",
      "format_version" => "0.1.0",
      "source_mode" => "pack_descriptor_candidate",
      "authority" => proof_authority,
      "pack_ref" => pack.fetch("pack_ref"),
      "row_authority_policy" => "pack_owns_declared_rows",
      "registry" => registry,
      "closed_surface_assertions" => closed_surface_assertions
    }
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

  def result(diagnostics)
    {
      "valid" => diagnostics.empty?,
      "diagnostics" => diagnostics,
      "closed_surface_assertions" => closed_surface_assertions
    }
  end

  def has_diag?(result, code)
    result.fetch("source_diagnostics", []).any? { |entry| entry.fetch("code") == code }
  end

  def diag(code, message)
    { "code" => code, "message" => message }
  end

  def proof_authority
    {
      "authority_ref" => "LANG-R117-P1 plus LANG-R116-D1",
      "authority_kind" => "proof_only",
      "canon_status" => "non_canon"
    }
  end

  def owner_to_slot(owner)
    owner.gsub(/Pack\z/, "").gsub(/([a-z])([A-Z])/, "\\1_\\2").downcase
  end

  def deep_copy(value)
    JSON.parse(JSON.generate(value))
  end

  def no_live_surface_files_refer_to_this_proof?
    files = [
      ROOT / "lib/igniter_lang.rb",
      ROOT / "lib/igniter_lang/parser.rb",
      ROOT / "lib/igniter_lang/classifier.rb",
      ROOT / "lib/igniter_lang/typechecker.rb",
      ROOT / "lib/igniter_lang/semanticir_emitter.rb",
      ROOT / "lib/igniter_lang/assembler.rb",
      ROOT / "lib/igniter_lang/compiler_orchestrator.rb",
      ROOT / "lib/igniter_lang/compilation_report.rb",
      ROOT / "lib/igniter_lang/compiler_result.rb",
      ROOT / "lib/igniter_lang/cli.rb"
    ]
    files.all? { |path| !path.exist? || !File.read(path).include?("oof_fragment_registry_source_authority_precedence_proof") }
  end

  def closed_surface_assertions
    {
      "source_accepted_modes_changed" => false,
      "compiler_integration" => false,
      "public_api_cli" => false,
      "loader_report" => false,
      "compatibility_report" => false,
      "igapp_mutation" => false,
      "runtime_behavior" => false,
      "specs_canon_proposals" => false,
      "prop036_manifest_change" => false,
      "prop038_validator_report_change" => false,
      "implementation_authorized" => false
    }
  end
end

exit(OOFFragmentRegistrySourceAuthorityPrecedenceProof.run ? 0 : 1)
