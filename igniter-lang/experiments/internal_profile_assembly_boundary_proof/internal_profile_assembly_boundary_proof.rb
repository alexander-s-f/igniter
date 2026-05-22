#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
OUT_DIR = ROOT / "experiments/internal_profile_assembly_boundary_proof/out"
PACKET_PATH = ROOT / "experiments/oof_fragment_registry_compiler_profile_source_input_proof/out/compiler_profile_oof_registry_source_input.packet.json"

require_relative "../../lib/igniter_lang/oof_fragment_registry"
require_relative "../../lib/igniter_lang/internal_profile_assembly_source_packet"

module InternalProfileAssemblyBoundaryProof
  module_function

  TRACK = "internal-profile-assembly-boundary-proof-v0"
  PACKET_CLASS = IgniterLang::InternalProfileAssemblySourcePacket
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

    source_packet_model = JSON.parse(File.read(PACKET_PATH, encoding: "utf-8"))
    validator = IgniterLang::OOFFragmentRegistry.new
    packet = build_packet(source_packet_model)
    valid_result = assemble(packet, registry_validator: validator)

    cases = []

    cases << case_result("valid_packet_assembles_to_finalized_internal", expected: true) do
      ok = valid_result.fetch("valid") &&
        valid_result.fetch("lifecycle_state") == "finalized_internal" &&
        valid_result.fetch("input_lifecycle_state") == "implementation_candidate" &&
        valid_result.fetch("profile_validation").fetch("valid") &&
        valid_result.fetch("pack_descriptor_validations").all? { |entry| entry.fetch("valid") }
      [ok, { "assembly_result" => valid_result }]
    end

    cases << case_result("deterministic_packet_and_result_digest", expected: true) do
      first_packet = build_packet(source_packet_model)
      second_packet = build_packet(deep_copy(source_packet_model))
      first_result = assemble(first_packet, registry_validator: validator)
      second_result = assemble(second_packet, registry_validator: validator)
      ok = digest(first_packet.to_h) == digest(second_packet.to_h) &&
        digest(first_result) == digest(second_result)
      [ok, {
        "packet_digest" => digest(first_packet.to_h),
        "result_digest" => digest(first_result),
        "second_result_digest" => digest(second_result)
      }]
    end

    cases << invalid_case("bad_authority_remains_invalid_and_does_not_finalize",
      expected_code: IgniterLang::OOFFragmentRegistry::SOURCE_DIAG_INVALID_AUTHORITY_KIND) do
      bad = deep_copy(source_packet_model)
      bad["authority"]["authority_kind"] = "runtime"
      build_packet(bad)
    end

    cases << invalid_case("missing_selected_pack_ref_rejected",
      expected_code: IgniterLang::OOFFragmentRegistry::SOURCE_DIAG_MISSING_SELECTED_PACK_REF) do
      bad = deep_copy(source_packet_model)
      bad["profile_candidate"]["selected_pack_refs"] << "pack_descriptor_candidate/proof:MissingPack"
      bad["profile_candidate"]["pack_order"] << "pack_descriptor_candidate/proof:MissingPack"
      build_packet(bad)
    end

    cases << invalid_case("duplicate_row_ownership_rejected",
      expected_code: IgniterLang::OOFFragmentRegistry::SOURCE_DIAG_DUPLICATE_ROW_OWNERSHIP) do
      bad = deep_copy(source_packet_model)
      bad["pack_descriptor_candidates"][1]["owned_oof_descriptors"] << deep_copy(
        bad["pack_descriptor_candidates"][0].fetch("owned_oof_descriptors").first
      )
      build_packet(bad)
    end

    cases << invalid_case("excluded_namespace_claim_rejected",
      expected_code: IgniterLang::OOFFragmentRegistry::SOURCE_DIAG_EXCLUDED_NAMESPACE_CLAIM) do
      bad = deep_copy(source_packet_model)
      bad["pack_descriptor_candidates"].first.fetch("owned_oof_descriptors").first["code"] =
        "compiler_profile_contract.contract_digest_mismatch"
      build_packet(bad)
    end

    checks = []
    checks << check("packet_does_not_become_compiler_input") do
      no_file_mentions?(compiler_pipeline_files, "InternalProfileAssemblySourcePacket") &&
        no_file_mentions?(compiler_pipeline_files, "internal_profile_assembly_source_packet")
    end
    checks << check("root_require_remains_closed") do
      main_lib = ROOT / "lib/igniter_lang.rb"
      !main_lib.exist? || !File.read(main_lib, encoding: "utf-8").include?("internal_profile_assembly_source_packet")
    end
    checks << check("no_new_lib_assembly_boundary_file") do
      !ROOT.join("lib/igniter_lang/internal_profile_assembly.rb").exist? &&
        !ROOT.join("lib/igniter_lang/internal_profile_assembly_boundary.rb").exist?
    end
    checks << check("public_report_runtime_manifest_prop_surfaces_closed") do
      valid_result.fetch("closed_surface_assertions").values.all?(false) &&
        public_keys_in(valid_result).empty? &&
        no_file_mentions?(closed_surface_files, "internal_profile_assembly_result")
    end
    checks << check("case_matrix_expected_results") do
      cases.all? { |entry| entry.fetch("status") == "PASS" }
    end

    failed_cases = cases.select { |entry| entry.fetch("status") != "PASS" }
    failed_checks = checks.select { |entry| entry.fetch("status") != "PASS" }
    status = failed_cases.empty? && failed_checks.empty? ? "PASS" : "FAIL"

    model = {
      "kind" => "internal_profile_assembly_boundary_model",
      "format_version" => "0.1.0",
      "track" => TRACK,
      "assembly_result_ref" => "out/internal_profile_assembly_result.valid.json",
      "packet_digest" => digest(packet.to_h),
      "helper_envelopes_digest" => digest(packet.to_helper_envelopes),
      "result_digest" => digest(valid_result),
      "closed_surface_assertions" => assembly_closed_surface_assertions
    }

    summary = {
      "kind" => "internal_profile_assembly_boundary_proof_summary",
      "format_version" => "0.1.0",
      "track" => TRACK,
      "status" => status,
      "model_id" => "internal_profile_assembly_boundary/sha256:#{Digest::SHA256.hexdigest(JSON.generate(model))[0, 24]}",
      "cases_total" => cases.length,
      "cases_pass" => cases.count { |entry| entry.fetch("status") == "PASS" },
      "checks_total" => checks.length,
      "checks_pass" => checks.count { |entry| entry.fetch("status") == "PASS" },
      "packet_digest" => digest(packet.to_h),
      "helper_envelopes_digest" => digest(packet.to_helper_envelopes),
      "result_digest" => digest(valid_result),
      "cases" => cases,
      "checks" => checks,
      "failed_cases" => failed_cases,
      "failed_checks" => failed_checks,
      "outputs" => {
        "summary" => "igniter-lang/experiments/internal_profile_assembly_boundary_proof/out/internal_profile_assembly_boundary_proof_summary.json",
        "model" => "igniter-lang/experiments/internal_profile_assembly_boundary_proof/out/internal_profile_assembly_boundary_model.json",
        "valid_result" => "igniter-lang/experiments/internal_profile_assembly_boundary_proof/out/internal_profile_assembly_result.valid.json",
        "negative_results" => "igniter-lang/experiments/internal_profile_assembly_boundary_proof/out/internal_profile_assembly_result.negatives.json"
      },
      "closed_surfaces" => assembly_closed_surface_assertions,
      "implementation_authorized" => false,
      "compiler_integration_authorized" => false,
      "recommendation" => status == "PASS" ? "ACCEPT_PROOF_IMPLEMENTATION_REVIEW_HOLD" : "HOLD"
    }

    negative_results = cases
      .select { |entry| entry.fetch("expected") == false }
      .to_h { |entry| [entry.fetch("name"), entry.dig("details", "assembly_result")] }

    File.write(OUT_DIR / "internal_profile_assembly_result.valid.json", "#{JSON.pretty_generate(valid_result)}\n")
    File.write(OUT_DIR / "internal_profile_assembly_result.negatives.json", "#{JSON.pretty_generate(negative_results)}\n")
    File.write(OUT_DIR / "internal_profile_assembly_boundary_model.json", "#{JSON.pretty_generate(model)}\n")
    File.write(OUT_DIR / "internal_profile_assembly_boundary_proof_summary.json", "#{JSON.pretty_generate(summary)}\n")

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

  def assemble(packet, registry_validator:)
    packet_hash = packet.to_h
    helper_envelopes = packet.to_helper_envelopes
    validation = packet.validate_with(registry_validator: registry_validator)
    valid = validation.fetch("valid")
    diagnostics = internal_diagnostics_from(validation)

    {
      "kind" => "internal_profile_assembly_result",
      "format_version" => "0.1.0",
      "valid" => valid,
      "lifecycle_state" => valid ? "finalized_internal" : packet.lifecycle_state,
      "input_lifecycle_state" => packet.lifecycle_state,
      "packet_kind" => packet_hash.fetch("kind"),
      "packet_digest" => digest(packet_hash),
      "helper_envelopes_digest" => digest(helper_envelopes),
      "profile_validation" => validation.fetch("profile_validation"),
      "pack_descriptor_validations" => validation.fetch("pack_descriptor_validations"),
      "diagnostics" => diagnostics,
      "finalized_internal_meaning" =>
        "internal assembly state only; not PROP-036 finalization, not compiler_profile_id, " \
        "and not manifest/profile identity",
      "closed_surface_assertions" => assembly_closed_surface_assertions
    }
  end

  def internal_diagnostics_from(validation)
    diagnostics = []
    profile_diags = validation.fetch("profile_validation").fetch("source_diagnostics", [])
    diagnostics.concat(profile_diags.map { |diag| proof_diag("profile_validation", diag) })
    validation.fetch("pack_descriptor_validations").each_with_index do |pack_validation, index|
      pack_validation.fetch("source_diagnostics", []).each do |diag|
        diagnostics << proof_diag("pack_descriptor_validations[#{index}]", diag)
      end
    end
    diagnostics
  end

  def proof_diag(path, source_diag)
    {
      "code" => "internal_profile_assembly.source_validation_failed",
      "path" => path,
      "source_code" => source_diag.fetch("code"),
      "message" => source_diag.fetch("message")
    }
  end

  def invalid_case(name, expected_code:)
    case_result(name, expected: false) do
      result = assemble(yield, registry_validator: IgniterLang::OOFFragmentRegistry.new)
      source_codes = result.fetch("diagnostics").map { |diag| diag.fetch("source_code") }
      ok = !result.fetch("valid") &&
        result.fetch("lifecycle_state") == "implementation_candidate" &&
        source_codes.include?(expected_code)
      [ok ? false : true, { "assembly_result" => result, "expected_code" => expected_code }]
    end
  end

  def build_packet(model)
    PACKET_CLASS.build(
      authority: model.fetch("authority"),
      profile_candidate: model.fetch("profile_candidate"),
      pack_descriptor_candidates: model.fetch("pack_descriptor_candidates"),
      lifecycle_state: "implementation_candidate",
      closed_surface_assertions: model.fetch("closed_surface_assertions"),
      excluded_namespaces: model.fetch("excluded_namespaces")
    )
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

  def compiler_pipeline_files
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

  def assembly_closed_surface_assertions
    {
      "root_require" => false,
      "compiler_pipeline_usage" => false,
      "public_api_cli" => false,
      "loader_report" => false,
      "compatibility_report" => false,
      "igapp_mutation" => false,
      "manifest_mutation" => false,
      "prop036_mutation" => false,
      "prop038_mutation" => false,
      "runtime_behavior" => false,
      "production_behavior" => false,
      "spark_surface" => false
    }
  end

  def deep_copy(value)
    JSON.parse(JSON.generate(value))
  end
end

exit(InternalProfileAssemblyBoundaryProof.run ? 0 : 1)
