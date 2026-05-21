#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
OUT_DIR = ROOT / "experiments/oof_fragment_registry_compiler_profile_source_input_proof/out"
FIXTURE_PATH = ROOT / "experiments/oof_fragment_registry_implementation_boundary_proof/fixtures/forward_shape_valid.json"
R123_SUMMARY_PATH = ROOT / "experiments/oof_fragment_registry_profile_pack_source_mode_proof/out/oof_fragment_registry_profile_pack_source_mode_proof_summary.json"

require_relative "../../lib/igniter_lang/oof_fragment_registry"

module OOFFragmentRegistryCompilerProfileSourceInputProof
  module_function

  TRACK = "oof-fragment-registry-compiler-profile-source-input-proof-v0"
  PACKET_KIND = "compiler_profile_oof_registry_source_input"
  HELPER_KIND = "oof_fragment_registry_source"
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
    r123_summary = JSON.parse(File.read(R123_SUMMARY_PATH, encoding: "utf-8"))
    validator = IgniterLang::OOFFragmentRegistry.new
    pack_candidates = pack_candidates_from_fixture(registry)
    packet = source_input_packet(pack_candidates, registry)
    mapped = map_packet_to_helper_envelopes(packet)

    cases = []

    cases << case_result("valid_source_input_packet_shape", expected: true) do
      result = validate_packet_shape(packet)
      [result.fetch("valid"), { "packet_validation" => result }]
    end

    cases << case_result("deterministic_mapping_to_helper_envelopes", expected: true) do
      first = map_packet_to_helper_envelopes(packet)
      second = map_packet_to_helper_envelopes(deep_copy(packet))
      first_digest = digest(first)
      second_digest = digest(second)
      [first_digest == second_digest, {
        "first_digest" => first_digest,
        "second_digest" => second_digest,
        "mapped_envelope_count" => first.fetch("pack_descriptor_envelopes").length + 1
      }]
    end

    cases << case_result("helper_accepts_valid_profile_source_input", expected: true) do
      result = validator.validate_source_envelope(mapped.fetch("profile_envelope"))
      ok = result.fetch("valid") &&
        result.fetch("source_mode") == "profile_candidate" &&
        result.fetch("source_diagnostics").empty? &&
        result.fetch("registry_validation").is_a?(Hash) &&
        result.fetch("registry_validation").fetch("valid")
      [ok, { "source_validation" => result }]
    end

    cases << case_result("helper_accepts_valid_pack_source_inputs", expected: true) do
      results = mapped.fetch("pack_descriptor_envelopes").map do |envelope|
        validator.validate_source_envelope(envelope)
      end
      ok = results.all? do |result|
        result.fetch("valid") &&
          result.fetch("source_mode") == "pack_descriptor_candidate" &&
          result.fetch("source_diagnostics").empty? &&
          result.fetch("registry_validation").nil?
      end
      [ok, { "source_validations" => results }]
    end

    cases << rejection_case("missing_pack_ref_rejected",
      expected_code: IgniterLang::OOFFragmentRegistry::SOURCE_DIAG_MISSING_SELECTED_PACK_REF) do
      bad = deep_copy(packet)
      bad["profile_candidate"]["selected_pack_refs"] << "pack_descriptor_candidate/proof:MissingPack"
      bad["profile_candidate"]["pack_order"] << "pack_descriptor_candidate/proof:MissingPack"
      map_packet_to_helper_envelopes(bad).fetch("profile_envelope")
    end

    cases << rejection_case("duplicate_row_ownership_rejected",
      expected_code: IgniterLang::OOFFragmentRegistry::SOURCE_DIAG_DUPLICATE_ROW_OWNERSHIP) do
      bad = deep_copy(packet)
      bad["pack_descriptor_candidates"][1]["owned_oof_descriptors"] << deep_copy(
        bad["pack_descriptor_candidates"][0].fetch("owned_oof_descriptors").first
      )
      map_packet_to_helper_envelopes(bad).fetch("profile_envelope")
    end

    cases << rejection_case("bad_authority_rejected",
      expected_code: IgniterLang::OOFFragmentRegistry::SOURCE_DIAG_INVALID_AUTHORITY_KIND) do
      bad = deep_copy(packet)
      bad["authority"]["authority_kind"] = "runtime"
      map_packet_to_helper_envelopes(bad).fetch("profile_envelope")
    end

    cases << rejection_case("forbidden_canon_status_rejected",
      expected_code: IgniterLang::OOFFragmentRegistry::SOURCE_DIAG_CANON_STATUS_FORBIDDEN) do
      bad = deep_copy(packet)
      bad["authority"]["canon_status"] = "canon"
      map_packet_to_helper_envelopes(bad).fetch("profile_envelope")
    end

    cases << rejection_case("excluded_namespace_claim_rejected",
      expected_code: IgniterLang::OOFFragmentRegistry::SOURCE_DIAG_EXCLUDED_NAMESPACE_CLAIM) do
      bad = deep_copy(packet)
      bad["pack_descriptor_candidates"].first.fetch("owned_oof_descriptors").first["code"] =
        "compiler_profile_contract.contract_digest_mismatch"
      map_packet_to_helper_envelopes(bad).fetch("profile_envelope")
    end

    checks = []
    checks << check("r123_refresh_summary_pass_evidence") { r123_summary.fetch("status") == "PASS" }
    checks << check("helper_modes_exact_r121_r122") do
      IgniterLang::OOFFragmentRegistry::SOURCE_ACCEPTED_MODES ==
        %w[proof_fixture caller_supplied profile_candidate pack_descriptor_candidate] &&
        IgniterLang::OOFFragmentRegistry::SOURCE_HELD_MODES.empty?
    end
    checks << check("case_matrix_expected_results") { cases.all? { |entry| entry.fetch("status") == "PASS" } }
    checks << check("failure_diagnostics_internal_only") do
      cases.select { |entry| entry.fetch("expected") == false }.all? do |entry|
        result = entry.dig("details", "source_validation")
        result.is_a?(Hash) &&
          result.fetch("registry_validation").nil? &&
          public_keys_in(result).empty?
      end
    end
    checks << check("no_compiler_pass_uses_source_input") do
      no_file_mentions?(compiler_pass_files, PACKET_KIND)
    end
    checks << check("closed_surfaces_preserved") do
      closed_surface_assertions.values.all?(false) &&
        no_file_mentions?(closed_surface_files, PACKET_KIND)
    end

    failed_cases = cases.select { |entry| entry.fetch("status") != "PASS" }
    failed_checks = checks.select { |entry| entry.fetch("status") != "PASS" }
    status = failed_cases.empty? && failed_checks.empty? ? "PASS" : "FAIL"

    model = {
      "kind" => "compiler_profile_oof_registry_source_input_model",
      "format_version" => "0.1.0",
      "track" => TRACK,
      "packet_ref" => "out/compiler_profile_oof_registry_source_input.packet.json",
      "mapped_helper_envelopes_ref" => "out/mapped_helper_envelopes.json",
      "mapping_policy" => "proof_only_packet_to_oof_fragment_registry_source_envelopes",
      "deterministic_mapping_digest" => digest(mapped),
      "closed_surface_assertions" => closed_surface_assertions
    }

    summary = {
      "kind" => "oof_fragment_registry_compiler_profile_source_input_proof_summary",
      "format_version" => "0.1.0",
      "track" => TRACK,
      "status" => status,
      "model_id" => "compiler_profile_oof_registry_source_input/sha256:#{Digest::SHA256.hexdigest(JSON.generate(model))[0, 24]}",
      "cases_total" => cases.length,
      "cases_pass" => cases.count { |entry| entry.fetch("status") == "PASS" },
      "checks_total" => checks.length,
      "checks_pass" => checks.count { |entry| entry.fetch("status") == "PASS" },
      "cases" => cases,
      "checks" => checks,
      "failed_cases" => failed_cases,
      "failed_checks" => failed_checks,
      "outputs" => {
        "summary" => "igniter-lang/experiments/oof_fragment_registry_compiler_profile_source_input_proof/out/oof_fragment_registry_compiler_profile_source_input_proof_summary.json",
        "model" => "igniter-lang/experiments/oof_fragment_registry_compiler_profile_source_input_proof/out/compiler_profile_source_input_model.json",
        "source_input_packet" => "igniter-lang/experiments/oof_fragment_registry_compiler_profile_source_input_proof/out/compiler_profile_oof_registry_source_input.packet.json",
        "mapped_helper_envelopes" => "igniter-lang/experiments/oof_fragment_registry_compiler_profile_source_input_proof/out/mapped_helper_envelopes.json"
      },
      "accepted_modes" => IgniterLang::OOFFragmentRegistry::SOURCE_ACCEPTED_MODES,
      "held_modes" => IgniterLang::OOFFragmentRegistry::SOURCE_HELD_MODES,
      "closed_surfaces" => closed_surface_assertions,
      "implementation_authorized" => false,
      "compiler_integration_authorized" => false,
      "recommendation" => status == "PASS" ? "SOURCE_INPUT_MODEL_ACCEPTED" : "HOLD"
    }

    File.write(OUT_DIR / "compiler_profile_oof_registry_source_input.packet.json", "#{JSON.pretty_generate(packet)}\n")
    File.write(OUT_DIR / "mapped_helper_envelopes.json", "#{JSON.pretty_generate(mapped)}\n")
    File.write(OUT_DIR / "compiler_profile_source_input_model.json", "#{JSON.pretty_generate(model)}\n")
    File.write(OUT_DIR / "oof_fragment_registry_compiler_profile_source_input_proof_summary.json", "#{JSON.pretty_generate(summary)}\n")

    if status == "PASS"
      puts "PASS #{TRACK}"
      puts "cases: #{summary.fetch("cases_pass")}/#{summary.fetch("cases_total")}"
      puts "checks: #{summary.fetch("checks_pass")}/#{summary.fetch("checks_total")}"
      puts "recommendation: #{summary.fetch("recommendation")}"
      true
    else
      warn "FAIL #{TRACK}"
      (failed_cases + failed_checks).each { |entry| warn "- #{entry.fetch("name")}" }
      false
    end
  end

  def rejection_case(name, expected_code:)
    case_result(name, expected: false) do
      result = IgniterLang::OOFFragmentRegistry.new.validate_source_envelope(yield)
      ok = !result.fetch("valid") &&
        result.fetch("registry_validation").nil? &&
        result.fetch("source_diagnostics").any? { |diag| diag.fetch("code") == expected_code }
      [ok ? false : true, { "source_validation" => result, "expected_code" => expected_code }]
    end
  end

  def source_input_packet(pack_candidates, registry)
    selected_refs = pack_candidates.map { |pack| pack.fetch("pack_ref") }
    {
      "kind" => PACKET_KIND,
      "format_version" => "0.1.0",
      "authority" => proof_authority,
      "profile_candidate" => {
        "profile_ref" => "compiler_profile_candidate/proof:LANG-R125-local",
        "profile_contract_ref" => "compiler_profile_contract_candidate/proof:LANG-R125-local",
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
        }
      },
      "pack_descriptor_candidates" => pack_candidates,
      "excluded_namespaces" => registry.fetch("excluded_namespaces"),
      "validation_target" => "oof_fragment_registry_source_envelope_helper",
      "closed_surface_assertions" => closed_surface_assertions
    }
  end

  def map_packet_to_helper_envelopes(packet)
    profile = packet.fetch("profile_candidate")
    pack_candidates = packet.fetch("pack_descriptor_candidates")
    common = {
      "kind" => HELPER_KIND,
      "format_version" => "0.1.0",
      "authority" => packet.fetch("authority"),
      "closed_surface_assertions" => packet.fetch("closed_surface_assertions")
    }

    profile_envelope = common.merge(
      "source_mode" => "profile_candidate",
      "profile_ref" => profile.fetch("profile_ref"),
      "profile_contract_ref" => profile.fetch("profile_contract_ref"),
      "row_authority_policy" => profile.fetch("row_authority_policy"),
      "selected_pack_refs" => profile.fetch("selected_pack_refs"),
      "pack_order" => profile.fetch("pack_order"),
      "conflict_policy" => profile.fetch("conflict_policy"),
      "pack_descriptor_candidates" => pack_candidates,
      "excluded_namespaces" => packet.fetch("excluded_namespaces")
    )

    pack_envelopes = pack_candidates.map do |pack|
      common.merge(
        "source_mode" => "pack_descriptor_candidate",
        "pack_ref" => pack.fetch("pack_ref"),
        "slot_name" => pack.fetch("slot_name"),
        "owner_pack_or_boundary" => pack.fetch("owner_pack_or_boundary"),
        "row_authority_policy" => pack.fetch("row_authority_policy"),
        "owned_oof_descriptors" => pack.fetch("owned_oof_descriptors"),
        "owned_fragment_rows" => pack.fetch("owned_fragment_rows"),
        "owned_support_markers" => pack.fetch("owned_support_markers")
      )
    end

    {
      "kind" => "mapped_oof_fragment_registry_source_envelopes",
      "format_version" => "0.1.0",
      "source_input_kind" => packet.fetch("kind"),
      "profile_envelope" => profile_envelope,
      "pack_descriptor_envelopes" => pack_envelopes
    }
  end

  def validate_packet_shape(packet)
    diagnostics = []
    diagnostics << diag("source_input.wrong_kind", "kind must be #{PACKET_KIND}") unless packet["kind"] == PACKET_KIND
    diagnostics << diag("source_input.unsupported_format_version", "format_version must be 0.1.0") unless packet["format_version"] == "0.1.0"
    authority = packet["authority"]
    if authority.is_a?(Hash)
      diagnostics << diag("source_input.invalid_authority_kind", "authority_kind must be proof_only") unless authority["authority_kind"] == "proof_only"
      diagnostics << diag("source_input.canon_status_forbidden", "canon_status must be non_canon") unless authority["canon_status"] == "non_canon"
    else
      diagnostics << diag("source_input.missing_authority", "authority is required")
    end
    diagnostics << diag("source_input.missing_profile_candidate", "profile_candidate is required") unless packet["profile_candidate"].is_a?(Hash)
    diagnostics << diag("source_input.missing_pack_descriptor_candidates", "pack_descriptor_candidates is required") unless packet["pack_descriptor_candidates"].is_a?(Array)
    unless packet["closed_surface_assertions"].is_a?(Hash) &&
           packet["closed_surface_assertions"].values.all?(false)
      diagnostics << diag("source_input.surface_open", "closed_surface_assertions must all be false")
    end
    result(diagnostics)
  end

  def pack_candidates_from_fixture(registry)
    owner_names = (
      registry.fetch("oof_descriptors").map { |row| row.fetch("owner_pack_or_boundary") } +
      registry.fetch("fragment_rows").map { |row| row.fetch("owner_pack_or_boundary") } +
      registry.dig("support_markers", "invariant_support_markers").map { |row| row.fetch("owner_pack_or_boundary") }
    ).uniq.sort

    owner_names.map do |owner|
      {
        "pack_ref" => "pack_descriptor_candidate/proof:#{owner}",
        "slot_name" => owner_to_slot(owner),
        "owner_pack_or_boundary" => owner,
        "row_authority_policy" => "pack_owns_declared_rows",
        "owned_oof_descriptors" => registry.fetch("oof_descriptors").select { |row| row.fetch("owner_pack_or_boundary") == owner },
        "owned_fragment_rows" => registry.fetch("fragment_rows").select { |row| row.fetch("owner_pack_or_boundary") == owner },
        "owned_support_markers" => registry.dig("support_markers", "invariant_support_markers").select { |row| row.fetch("owner_pack_or_boundary") == owner }
      }
    end
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
      "status" => "FAIL",
      "error" => "#{e.class}: #{e.message}",
      "details" => {}
    }
  end

  def check(name)
    { "name" => name, "status" => yield ? "PASS" : "FAIL" }
  rescue StandardError => e
    { "name" => name, "status" => "FAIL", "error" => "#{e.class}: #{e.message}" }
  end

  def result(diagnostics)
    { "valid" => diagnostics.empty?, "diagnostics" => diagnostics }
  end

  def diag(code, message)
    { "code" => code, "message" => message }
  end

  def digest(value)
    Digest::SHA256.hexdigest(JSON.generate(canonicalize(value)))[0, 24]
  end

  def canonicalize(value)
    case value
    when Hash
      value.keys.sort.to_h { |key| [key, canonicalize(value[key])] }
    when Array
      value.map { |inner| canonicalize(inner) }
    else
      value
    end
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

  def no_file_mentions?(paths, token)
    paths.all? do |path|
      !path.exist? || !File.read(path, encoding: "utf-8").include?(token)
    end
  end

  def compiler_pass_files
    %w[
      parser
      classifier
      typechecker
      semanticir_emitter
      assembler
      compiler_orchestrator
    ].map { |name| ROOT / "lib/igniter_lang/#{name}.rb" }
  end

  def closed_surface_files
    %w[
      lib/igniter_lang.rb
      lib/igniter_lang/cli.rb
      bin/igc
      lib/igniter_lang/compiler_orchestrator.rb
      lib/igniter_lang/compilation_report.rb
      lib/igniter_lang/compiler_result.rb
      lib/igniter_lang/diagnostics.rb
      lib/igniter_lang/assembler.rb
      lib/igniter_lang/compiler_profile_contract_validator.rb
    ].map { |relative| ROOT / relative }
  end

  def proof_authority
    {
      "authority_ref" => "LANG-R124-D1 plus LANG-R125-P1",
      "authority_kind" => "proof_only",
      "canon_status" => "non_canon"
    }
  end

  def owner_to_slot(owner)
    owner.gsub(/Pack\z/, "").gsub(/([a-z])([A-Z])/, "\\1_\\2").downcase
  end

  def closed_surface_assertions
    {
      "compiler_integration" => false,
      "public_api_cli" => false,
      "loader_report" => false,
      "compatibility_report" => false,
      "igapp_mutation" => false,
      "prop036_manifest_change" => false,
      "prop038_validator_report_change" => false,
      "runtime_behavior" => false,
      "production_behavior" => false,
      "spark_surface" => false
    }
  end

  def deep_copy(value)
    JSON.parse(JSON.generate(value))
  end
end

exit(OOFFragmentRegistryCompilerProfileSourceInputProof.run ? 0 : 1)
