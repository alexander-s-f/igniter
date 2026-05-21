#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "pathname"
require "set"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
OUT_DIR = ROOT / "experiments/oof_fragment_registry_profile_pack_source_mode_proof/out"
FIXTURE_PATH = ROOT / "experiments/oof_fragment_registry_implementation_boundary_proof/fixtures/forward_shape_valid.json"
SOURCE_HELPER_SUMMARY = ROOT / "experiments/oof_fragment_registry_source_envelope_helper_proof/out/oof_fragment_registry_source_envelope_helper_proof_summary.json"

require_relative "../../lib/igniter_lang/oof_fragment_registry"

module OOFFragmentRegistryProfilePackSourceModeProof
  module_function

  TRACK = "oof-fragment-registry-profile-pack-source-mode-proof-v0"
  EXCLUDED_PREFIXES = IgniterLang::OOFFragmentRegistry::REQUIRED_EXCLUDED_PREFIXES

  def run
    FileUtils.mkdir_p(OUT_DIR)

    fixture_registry = JSON.parse(File.read(FIXTURE_PATH))
    source_helper_summary = JSON.parse(File.read(SOURCE_HELPER_SUMMARY))
    validator = IgniterLang::OOFFragmentRegistry.new

    pack_candidates = pack_candidates_from_fixture(fixture_registry)
    profile_candidate = profile_candidate_envelope(pack_candidates)
    derived_registry = derive_registry_from_pack_candidates(pack_candidates, fixture_registry)
    live_profile_envelope = profile_candidate
    live_pack_envelope = pack_source_envelope(pack_candidates.first)

    cases = []
    cases << case_result("profile_candidate_model_valid_non_canon_proof_only", expected: "accepted") do
      result = validate_profile_model(profile_candidate)
      [result.fetch("valid"), { "profile_model_validation" => result }]
    end

    cases << case_result("pack_descriptor_candidates_model_valid_non_canon_proof_only", expected: "accepted") do
      result = validate_pack_candidates(pack_candidates)
      [result.fetch("valid"), { "pack_model_validation" => result }]
    end

    cases << case_result("derived_registry_from_pack_candidates_validates", expected: "accepted") do
      registry_result = validator.validate(derived_registry)
      [registry_result.fetch("valid"), {
        "nested_registry_validation" => registry_result,
        "validated_by" => "IgniterLang::OOFFragmentRegistry#validate"
      }]
    end

    cases << case_result("live_helper_profile_candidate_accepted_internal_only", expected: "accepted") do
      result = validator.validate_source_envelope(live_profile_envelope)
      [result.fetch("valid"), {
        "source_validation" => result,
        "source_diagnostics_empty" => result.fetch("source_diagnostics").empty?,
        "registry_validation_called" => !result.fetch("registry_validation").nil?
      }]
    end

    cases << case_result("live_helper_pack_descriptor_candidate_accepted_internal_only", expected: "accepted") do
      result = validator.validate_source_envelope(live_pack_envelope)
      [result.fetch("valid"), {
        "source_validation" => result,
        "source_diagnostics_empty" => result.fetch("source_diagnostics").empty?,
        "registry_validation_called" => !result.fetch("registry_validation").nil?
      }]
    end

    duplicate_pack_candidates = deep_copy(pack_candidates)
    duplicate_pack_candidates[1]["owned_oof_descriptors"] << deep_copy(duplicate_pack_candidates[0].fetch("owned_oof_descriptors").first)
    cases << case_result("duplicate_oof_row_ownership_rejected_by_proof_model", expected: "rejected") do
      result = validate_pack_candidates(duplicate_pack_candidates)
      [result.fetch("valid"), { "pack_model_validation" => result }]
    end

    duplicate_fragment_candidates = deep_copy(pack_candidates)
    duplicate_fragment_candidates[1]["owned_fragment_rows"] << deep_copy(
      duplicate_fragment_candidates[0].fetch("owned_fragment_rows").find { |row| row.fetch("name") == "core" }
    )
    cases << case_result("duplicate_fragment_row_ownership_rejected_by_proof_model", expected: "rejected") do
      result = validate_pack_candidates(duplicate_fragment_candidates)
      [result.fetch("valid"), { "pack_model_validation" => result }]
    end

    excluded_oof_descriptor_candidates = deep_copy(pack_candidates)
    excluded_oof_descriptor_candidates[0]["owned_oof_descriptors"].first["code"] = "compiler_profile_contract.contract_digest_mismatch"
    cases << case_result("compiler_profile_contract_descriptor_rejected_by_proof_model", expected: "rejected") do
      result = validate_pack_candidates(excluded_oof_descriptor_candidates)
      [result.fetch("valid"), { "pack_model_validation" => result }]
    end

    excluded_alias_candidates = deep_copy(pack_candidates)
    excluded_alias_candidates[0]["owned_oof_descriptors"].first["aliases"] << "compiler_profile_contract_refusal.contract_digest_mismatch"
    cases << case_result("compiler_profile_contract_refusal_alias_rejected_by_proof_model", expected: "rejected") do
      result = validate_pack_candidates(excluded_alias_candidates)
      [result.fetch("valid"), { "pack_model_validation" => result }]
    end

    checks = []
    checks << check("source_helper_summary.pass_evidence") { source_helper_summary.fetch("status") == "PASS" }
    checks << check("case_matrix.expected_results") { cases.all? { |entry| entry.fetch("status") == "PASS" } }
    checks << check("derived_registry_validated_by_existing_validator") do
      cases.find { |entry| entry.fetch("name") == "derived_registry_from_pack_candidates_validates" }
        .dig("details", "validated_by") == "IgniterLang::OOFFragmentRegistry#validate"
    end
    checks << check("live_helper_profile_pack_modes_accepted_internal_only") do
      %w[
        live_helper_profile_candidate_accepted_internal_only
        live_helper_pack_descriptor_candidate_accepted_internal_only
      ].all? do |name|
        entry = cases.find { |candidate| candidate.fetch("name") == name }
        entry.fetch("accepted") == true &&
          entry.dig("details", "source_diagnostics_empty") == true
      end &&
        cases.find { |candidate| candidate.fetch("name") == "live_helper_profile_candidate_accepted_internal_only" }
          .dig("details", "registry_validation_called") == true &&
        cases.find { |candidate| candidate.fetch("name") == "live_helper_pack_descriptor_candidate_accepted_internal_only" }
          .dig("details", "registry_validation_called") == false
    end
    checks << check("proof_model_rejects_duplicate_row_ownership") do
      %w[
        duplicate_oof_row_ownership_rejected_by_proof_model
        duplicate_fragment_row_ownership_rejected_by_proof_model
      ].all? { |name| cases.find { |entry| entry.fetch("name") == name }.fetch("accepted") == false }
    end
    checks << check("proof_model_excludes_compiler_profile_contract_namespace") do
      %w[
        compiler_profile_contract_descriptor_rejected_by_proof_model
        compiler_profile_contract_refusal_alias_rejected_by_proof_model
      ].all? { |name| cases.find { |entry| entry.fetch("name") == name }.fetch("accepted") == false }
    end
    checks << check("closed_surfaces_preserved") do
      closed_surface_assertions.values.all?(false) &&
        no_live_surface_files_refer_to_profile_pack_proof?
    end

    failed_cases = cases.select { |entry| entry.fetch("status") != "PASS" }
    failed_checks = checks.select { |entry| entry.fetch("status") != "PASS" }
    status = failed_cases.empty? && failed_checks.empty? ? "PASS" : "FAIL"

    model = {
      "kind" => "oof_fragment_registry_profile_pack_source_mode_model",
      "format_version" => "0.1.0",
      "track" => TRACK,
      "profile_candidate" => profile_candidate,
      "pack_descriptor_candidates" => pack_candidates.map { |candidate| pack_source_envelope(candidate) },
      "derived_registry_ref" => "out/derived_registry_from_pack_candidates.json",
      "live_helper_acceptance" => "profile_pack_candidate_modes_accepted_internal_only",
      "closed_surface_assertions" => closed_surface_assertions
    }

    summary = {
      "kind" => "oof_fragment_registry_profile_pack_source_mode_proof_summary",
      "format_version" => "0.1.0",
      "track" => TRACK,
      "status" => status,
      "model_id" => "oof_fragment_profile_pack_source/sha256:#{Digest::SHA256.hexdigest(JSON.generate(model))[0, 24]}",
      "cases" => cases,
      "checks" => checks,
      "failed_cases" => failed_cases,
      "failed_checks" => failed_checks,
      "recommendation" => status == "PASS" ? "R122_CLOSURE_ACCEPTED" : "HOLD",
      "accepted_modes" => IgniterLang::OOFFragmentRegistry::SOURCE_ACCEPTED_MODES,
      "held_modes" => IgniterLang::OOFFragmentRegistry::SOURCE_HELD_MODES,
      "outputs" => {
        "summary" => "igniter-lang/experiments/oof_fragment_registry_profile_pack_source_mode_proof/out/oof_fragment_registry_profile_pack_source_mode_proof_summary.json",
        "model" => "igniter-lang/experiments/oof_fragment_registry_profile_pack_source_mode_proof/out/oof_fragment_registry_profile_pack_source_mode_model.json",
        "derived_registry" => "igniter-lang/experiments/oof_fragment_registry_profile_pack_source_mode_proof/out/derived_registry_from_pack_candidates.json"
      },
      "closed_surfaces" => closed_surface_assertions,
      "implementation_authorized" => false
    }

    File.write(OUT_DIR / "derived_registry_from_pack_candidates.json", "#{JSON.pretty_generate(derived_registry)}\n")
    File.write(OUT_DIR / "oof_fragment_registry_profile_pack_source_mode_model.json", "#{JSON.pretty_generate(model)}\n")
    File.write(OUT_DIR / "oof_fragment_registry_profile_pack_source_mode_proof_summary.json", "#{JSON.pretty_generate(summary)}\n")

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

  def derive_registry_from_pack_candidates(pack_candidates, fixture_registry)
    {
      "kind" => "oof_fragment_registry",
      "format_version" => "0.1.0",
      "source_authority" => {
        "authority_ref" => "LANG-R115-P1/proof-derived-from-pack-candidates",
        "authority_kind" => "proof_only",
        "canon_status" => "non_canon"
      },
      "historical_source_refs" => fixture_registry.fetch("historical_source_refs", []),
      "migration_policy" => "proof_derived_from_pack_descriptor_candidates",
      "forward_shape_authority" => fixture_registry.fetch("forward_shape_authority"),
      "oof_descriptors" => pack_candidates.flat_map { |candidate| candidate.fetch("owned_oof_descriptors") },
      "fragment_rows" => pack_candidates.flat_map { |candidate| candidate.fetch("owned_fragment_rows") },
      "support_markers" => {
        "invariant_support_markers" => pack_candidates.flat_map { |candidate| candidate.fetch("owned_support_markers") }
      },
      "excluded_namespaces" => fixture_registry.fetch("excluded_namespaces")
    }
  end

  def validate_profile_model(profile_candidate)
    diagnostics = []
    diagnostics.concat(validate_source_common(profile_candidate))
    diagnostics << diag("profile_pack_source.profile_ref_missing", "profile_ref is required") if profile_candidate["profile_ref"].to_s.empty?
    unless profile_candidate["row_authority_policy"] == "pack_descriptor_rows_aggregated_by_profile"
      diagnostics << diag("profile_pack_source.row_authority_policy_invalid", "profile candidate must aggregate pack descriptor rows")
    end
    result(diagnostics)
  end

  def validate_pack_candidates(pack_candidates)
    diagnostics = []
    seen_oof_owners = {}
    seen_fragment_owners = {}

    pack_candidates.each_with_index do |candidate, index|
      diagnostics.concat(validate_source_common(pack_source_envelope(candidate), path_prefix: "pack_candidates[#{index}]"))
      diagnostics << diag("profile_pack_source.pack_ref_missing", "pack_ref is required") if candidate["pack_ref"].to_s.empty?

      candidate.fetch("owned_oof_descriptors").each do |row|
        code = row.fetch("code")
        diagnostics.concat(excluded_namespace_diagnostics(code, "pack_candidates[#{index}].owned_oof_descriptors"))
        row.fetch("aliases", []).each do |ali|
          diagnostics.concat(excluded_namespace_diagnostics(ali, "pack_candidates[#{index}].owned_oof_descriptors.aliases"))
        end
        if seen_oof_owners.key?(code) && seen_oof_owners.fetch(code) != candidate.fetch("pack_ref")
          diagnostics << diag("profile_pack_source.duplicate_oof_row_ownership", "#{code} is owned by multiple pack descriptors")
        end
        seen_oof_owners[code] = candidate.fetch("pack_ref")
      end

      candidate.fetch("owned_fragment_rows").each do |row|
        name = row.fetch("name")
        if seen_fragment_owners.key?(name) && seen_fragment_owners.fetch(name) != candidate.fetch("pack_ref")
          diagnostics << diag("profile_pack_source.duplicate_fragment_row_ownership", "#{name} is owned by multiple pack descriptors")
        end
        seen_fragment_owners[name] = candidate.fetch("pack_ref")
      end
    end

    result(diagnostics)
  end

  def validate_source_common(envelope, path_prefix: "source")
    diagnostics = []
    diagnostics << diag("profile_pack_source.source_mode_invalid", "#{path_prefix}.source_mode must be profile_candidate or pack_descriptor_candidate") unless %w[profile_candidate pack_descriptor_candidate].include?(envelope["source_mode"])
    authority = envelope["authority"]
    if authority.is_a?(Hash)
      diagnostics << diag("profile_pack_source.authority_kind_invalid", "#{path_prefix}.authority.authority_kind must be proof_only") unless authority["authority_kind"] == "proof_only"
      diagnostics << diag("profile_pack_source.canon_status_invalid", "#{path_prefix}.authority.canon_status must be non_canon") unless authority["canon_status"] == "non_canon"
    else
      diagnostics << diag("profile_pack_source.authority_missing", "#{path_prefix}.authority is required")
    end
    diagnostics << diag("profile_pack_source.closed_surface_open", "#{path_prefix}.closed_surface_assertions must all be false") unless envelope.fetch("closed_surface_assertions", {}).values.all?(false)
    diagnostics
  end

  def excluded_namespace_diagnostics(token, path)
    EXCLUDED_PREFIXES
      .select { |prefix| token.start_with?(prefix) }
      .map { |prefix| diag("profile_pack_source.excluded_oof_namespace", "#{path}: #{token} is under excluded namespace #{prefix}") }
  end

  def profile_candidate_envelope(pack_candidates)
    {
      "kind" => "oof_fragment_registry_source",
      "format_version" => "0.1.0",
      "source_mode" => "profile_candidate",
      "authority" => proof_authority,
      "profile_ref" => "compiler_profile_candidate/proof:LANG-R115-local",
      "profile_contract_ref" => "compiler_profile_contract_candidate/proof:LANG-R115-local",
      "row_authority_policy" => "pack_descriptor_rows_aggregated_by_profile",
      "selected_pack_refs" => pack_candidates.map { |candidate| candidate.fetch("pack_ref") },
      "pack_order" => pack_candidates.map { |candidate| candidate.fetch("pack_ref") },
      "conflict_policy" => {
        "duplicate_oof_descriptor" => "reject",
        "duplicate_fragment_row" => "reject",
        "duplicate_support_marker" => "reject",
        "duplicate_alias_owner" => "reject",
        "missing_selected_pack_ref" => "reject",
        "excluded_namespace" => "reject"
      },
      "pack_descriptor_candidates" => pack_candidates,
      "closed_surface_assertions" => closed_surface_assertions
    }
  end

  def pack_source_envelope(pack_candidate)
    {
      "kind" => "oof_fragment_registry_source",
      "format_version" => "0.1.0",
      "source_mode" => "pack_descriptor_candidate",
      "authority" => proof_authority,
      "pack_ref" => pack_candidate.fetch("pack_ref"),
      "slot_name" => pack_candidate.fetch("slot_name"),
      "owner_pack_or_boundary" => pack_candidate.fetch("owner_pack_or_boundary"),
      "row_authority_policy" => "pack_owns_declared_rows",
      "owned_oof_descriptors" => pack_candidate.fetch("owned_oof_descriptors"),
      "owned_fragment_rows" => pack_candidate.fetch("owned_fragment_rows"),
      "owned_support_markers" => pack_candidate.fetch("owned_support_markers"),
      "closed_surface_assertions" => closed_surface_assertions
    }
  end

  def proof_authority
    {
      "authority_ref" => "LANG-R115-P1 plus LANG-R114-D1",
      "authority_kind" => "proof_only",
      "canon_status" => "non_canon"
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

  def diag(code, message)
    { "code" => code, "message" => message }
  end

  def owner_to_slot(owner)
    owner.gsub(/Pack\z/, "").gsub(/([a-z])([A-Z])/, "\\1_\\2").downcase
  end

  def deep_copy(value)
    JSON.parse(JSON.generate(value))
  end

  def no_live_surface_files_refer_to_profile_pack_proof?
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
    files.all? { |path| !path.exist? || !File.read(path).include?("oof_fragment_registry_profile_pack_source_mode_proof") }
  end

  def closed_surface_assertions
    {
      "external_surface_acceptance" => false,
      "compiler_integration" => false,
      "public_api_cli" => false,
      "loader_report" => false,
      "compatibility_report" => false,
      "igapp_mutation" => false,
      "runtime_behavior" => false,
      "specs_canon_proposals" => false,
      "prop036_manifest_change" => false,
      "prop038_validator_report_change" => false
    }
  end
end

exit(OOFFragmentRegistryProfilePackSourceModeProof.run ? 0 : 1)
