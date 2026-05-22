#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
OUT_DIR = ROOT / "experiments/internal_profile_assembly_boundary_implementation_proof/out"
PACKET_PATH = ROOT / "experiments/oof_fragment_registry_compiler_profile_source_input_proof/out/compiler_profile_oof_registry_source_input.packet.json"

require_relative "../../lib/igniter_lang/oof_fragment_registry"
require_relative "../../lib/igniter_lang/internal_profile_assembly_source_packet"
require_relative "../../lib/igniter_lang/internal_profile_assembly"

module InternalProfileAssemblyBoundaryImplementationProof
  module_function

  TRACK = "internal-profile-assembly-boundary-implementation-v0"
  ASSEMBLY_CLASS = IgniterLang::InternalProfileAssembly
  PACKET_CLASS = IgniterLang::InternalProfileAssemblySourcePacket
  TOKEN = "InternalProfileAssembly"
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
    valid_result = ASSEMBLY_CLASS.assemble(source_packet: packet, registry_validator: validator)

    cases = []
    cases << case_result("valid_packet_assembles_to_finalized_internal") do
      valid_result.fetch("kind") == "internal_profile_assembly_result" &&
        valid_result.fetch("valid") &&
        valid_result.fetch("lifecycle_state") == "finalized_internal" &&
        valid_result.fetch("input_lifecycle_state") == "implementation_candidate" &&
        valid_result.fetch("profile_validation").fetch("valid") &&
        valid_result.fetch("pack_descriptor_validations").all? { |entry| entry.fetch("valid") }
    end

    cases << case_result("deterministic_result_and_digests") do
      first = ASSEMBLY_CLASS.assemble(source_packet: build_packet(source_packet_model), registry_validator: validator)
      second = ASSEMBLY_CLASS.assemble(source_packet: build_packet(deep_copy(source_packet_model)), registry_validator: validator)
      first.fetch("packet_digest") == second.fetch("packet_digest") &&
        first.fetch("helper_envelopes_digest") == second.fetch("helper_envelopes_digest") &&
        digest(first) == digest(second)
    end

    cases << case_result("invalid_packet_object_does_not_finalize") do
      result = ASSEMBLY_CLASS.assemble(source_packet: Object.new, registry_validator: validator)
      !result.fetch("valid") &&
        result.fetch("lifecycle_state") == "invalid" &&
        result.fetch("diagnostics").any? { |diag| diag.fetch("code") == ASSEMBLY_CLASS::DIAG_INVALID_SOURCE_PACKET }
    end

    cases << invalid_model_case("bad_authority_remains_invalid_and_does_not_finalize",
      expected_code: IgniterLang::OOFFragmentRegistry::SOURCE_DIAG_INVALID_AUTHORITY_KIND) do |model|
      model["authority"]["authority_kind"] = "runtime"
    end

    cases << invalid_model_case("duplicate_row_ownership_does_not_finalize",
      expected_code: IgniterLang::OOFFragmentRegistry::SOURCE_DIAG_DUPLICATE_ROW_OWNERSHIP) do |model|
      model["pack_descriptor_candidates"][1]["owned_oof_descriptors"] << deep_copy(
        model["pack_descriptor_candidates"][0].fetch("owned_oof_descriptors").first
      )
    end

    cases << invalid_model_case("excluded_namespace_claim_does_not_finalize",
      expected_code: IgniterLang::OOFFragmentRegistry::SOURCE_DIAG_EXCLUDED_NAMESPACE_CLAIM) do |model|
      model["pack_descriptor_candidates"].first.fetch("owned_oof_descriptors").first["code"] =
        "compiler_profile_contract.contract_digest_mismatch"
    end

    cases << case_result("invalid_input_lifecycle_state_does_not_finalize") do
      finalized_input_packet = build_packet(source_packet_model, lifecycle_state: "finalized_internal")
      result = ASSEMBLY_CLASS.assemble(source_packet: finalized_input_packet, registry_validator: validator)
      !result.fetch("valid") &&
        result.fetch("input_lifecycle_state") == "finalized_internal" &&
        result.fetch("lifecycle_state") == "invalid" &&
        result.fetch("diagnostics").any? { |diag| diag.fetch("code") == ASSEMBLY_CLASS::DIAG_INVALID_LIFECYCLE_STATE }
    end

    checks = []
    checks << check("root_require_remains_closed") do
      main_lib = ROOT / "lib/igniter_lang.rb"
      !main_lib.exist? || !File.read(main_lib, encoding: "utf-8").include?("internal_profile_assembly")
    end
    checks << check("compiler_pipeline_files_do_not_reference_assembly") do
      no_file_mentions?(compiler_pipeline_files, TOKEN) &&
        no_file_mentions?(compiler_pipeline_files, "internal_profile_assembly")
    end
    checks << check("public_report_runtime_manifest_prop_surfaces_closed") do
      valid_result.fetch("closed_surface_assertions").values.all?(false) &&
        public_keys_in(valid_result).empty? &&
        no_file_mentions?(closed_surface_files, "internal_profile_assembly_result")
    end
    checks << check("assembly_file_is_direct_require_only") do
      assembly_file = ROOT / "lib/igniter_lang/internal_profile_assembly.rb"
      assembly_file.exist? &&
        !File.read(assembly_file, encoding: "utf-8").include?("require_relative")
    end
    checks << check("case_matrix_expected_results") do
      cases.all? { |entry| entry.fetch("status") == "PASS" }
    end

    failed_cases = cases.select { |entry| entry.fetch("status") != "PASS" }
    failed_checks = checks.select { |entry| entry.fetch("status") != "PASS" }
    status = failed_cases.empty? && failed_checks.empty? ? "PASS" : "FAIL"

    summary = {
      "kind" => "internal_profile_assembly_boundary_implementation_proof_summary",
      "format_version" => "0.1.0",
      "track" => TRACK,
      "status" => status,
      "cases_total" => cases.length,
      "cases_pass" => cases.count { |entry| entry.fetch("status") == "PASS" },
      "checks_total" => checks.length,
      "checks_pass" => checks.count { |entry| entry.fetch("status") == "PASS" },
      "packet_digest" => valid_result.fetch("packet_digest"),
      "helper_envelopes_digest" => valid_result.fetch("helper_envelopes_digest"),
      "result_digest" => digest(valid_result),
      "cases" => cases,
      "checks" => checks,
      "failed_cases" => failed_cases,
      "failed_checks" => failed_checks,
      "outputs" => {
        "summary" => "igniter-lang/experiments/internal_profile_assembly_boundary_implementation_proof/out/internal_profile_assembly_boundary_implementation_proof_summary.json",
        "valid_result" => "igniter-lang/experiments/internal_profile_assembly_boundary_implementation_proof/out/internal_profile_assembly_result.valid.json",
        "negative_results" => "igniter-lang/experiments/internal_profile_assembly_boundary_implementation_proof/out/internal_profile_assembly_result.negatives.json"
      },
      "closed_surfaces" => ASSEMBLY_CLASS::CLOSED_SURFACE_ASSERTIONS,
      "root_require_authorized" => false,
      "compiler_integration_authorized" => false,
      "recommendation" => status == "PASS" ? "ACCEPT_CLOSURE" : "HOLD"
    }

    negative_results = cases
      .select { |entry| entry.key?("assembly_result") }
      .to_h { |entry| [entry.fetch("name"), entry.fetch("assembly_result")] }

    File.write(OUT_DIR / "internal_profile_assembly_result.valid.json", "#{JSON.pretty_generate(valid_result)}\n")
    File.write(OUT_DIR / "internal_profile_assembly_result.negatives.json", "#{JSON.pretty_generate(negative_results)}\n")
    File.write(OUT_DIR / "internal_profile_assembly_boundary_implementation_proof_summary.json", "#{JSON.pretty_generate(summary)}\n")

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

  def invalid_model_case(name, expected_code:)
    case_result(name) do
      model = JSON.parse(File.read(PACKET_PATH, encoding: "utf-8"))
      yield(model)
      result = ASSEMBLY_CLASS.assemble(source_packet: build_packet(model),
        registry_validator: IgniterLang::OOFFragmentRegistry.new)
      source_codes = result.fetch("diagnostics").map { |diag| diag["source_code"] }.compact
      ok = !result.fetch("valid") &&
        result.fetch("lifecycle_state") == "implementation_candidate" &&
        source_codes.include?(expected_code)
      [ok, result]
    end
  end

  def build_packet(model, lifecycle_state: "implementation_candidate")
    PACKET_CLASS.build(
      authority: model.fetch("authority"),
      profile_candidate: model.fetch("profile_candidate"),
      pack_descriptor_candidates: model.fetch("pack_descriptor_candidates"),
      lifecycle_state: lifecycle_state,
      closed_surface_assertions: model.fetch("closed_surface_assertions"),
      excluded_namespaces: model.fetch("excluded_namespaces")
    )
  end

  def case_result(name)
    raw = yield
    accepted, assembly_result = raw.is_a?(Array) ? raw : [raw, nil]
    result = {
      "name" => name,
      "accepted" => accepted,
      "status" => accepted ? "PASS" : "FAIL"
    }
    result["assembly_result"] = assembly_result if assembly_result
    result
  rescue StandardError => e
    {
      "name" => name,
      "accepted" => false,
      "status" => "FAIL",
      "error" => "#{e.class}: #{e.message}"
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

  def deep_copy(value)
    JSON.parse(JSON.generate(value))
  end
end

exit(InternalProfileAssemblyBoundaryImplementationProof.run ? 0 : 1)
