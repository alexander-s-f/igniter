#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
OUT_DIR = ROOT / "experiments/internal_profile_assembly_source_packet_proof/out"
PACKET_PATH = ROOT / "experiments/oof_fragment_registry_compiler_profile_source_input_proof/out/compiler_profile_oof_registry_source_input.packet.json"

require_relative "../../lib/igniter_lang/oof_fragment_registry"
require_relative "../../lib/igniter_lang/internal_profile_assembly_source_packet"

module InternalProfileAssemblySourcePacketProof
  module_function

  TRACK = "internal-profile-assembly-source-packet-implementation-v0"
  PACKET_CLASS = IgniterLang::InternalProfileAssemblySourcePacket
  TOKEN = "InternalProfileAssemblySourcePacket"
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
    packet = build_packet(source_packet_model)
    validator = IgniterLang::OOFFragmentRegistry.new
    cases = []

    cases << case_result("build_creates_internal_profile_assembly_source_packet", expected: true) do
      ok = packet.is_a?(PACKET_CLASS) &&
        packet.lifecycle_state == "implementation_candidate" &&
        packet.to_h.fetch("kind") == "compiler_profile_oof_registry_source_input"
      [ok, { "packet" => packet.to_h }]
    end

    cases << case_result("to_h_preserves_r125_packet_model", expected: true) do
      packet_hash = packet.to_h
      ok = packet_hash.fetch("authority") == source_packet_model.fetch("authority") &&
        packet_hash.fetch("profile_candidate") == source_packet_model.fetch("profile_candidate") &&
        packet_hash.fetch("pack_descriptor_candidates") == source_packet_model.fetch("pack_descriptor_candidates") &&
        packet_hash.fetch("validation_target") == "oof_fragment_registry_source_envelope_helper"
      [ok, { "packet_digest" => digest(packet_hash) }]
    end

    cases << case_result("to_helper_envelopes_is_deterministic", expected: true) do
      first = packet.to_helper_envelopes
      second = build_packet(source_packet_model).to_helper_envelopes
      ok = digest(first) == digest(second) &&
        first.fetch("profile_envelope").fetch("source_mode") == "profile_candidate" &&
        first.fetch("pack_descriptor_envelopes").all? { |env| env.fetch("source_mode") == "pack_descriptor_candidate" }
      [ok, {
        "first_digest" => digest(first),
        "second_digest" => digest(second),
        "envelope_count" => first.fetch("pack_descriptor_envelopes").length + 1
      }]
    end

    cases << case_result("validate_with_oof_fragment_registry_passes", expected: true) do
      result = packet.validate_with(registry_validator: validator)
      ok = result.fetch("valid") &&
        result.fetch("profile_validation").fetch("valid") &&
        result.fetch("pack_descriptor_validations").all? { |validation| validation.fetch("valid") }
      [ok, { "validation" => result }]
    end

    cases << case_result("successful_validation_reports_finalized_internal_only", expected: true) do
      result = packet.validate_with(registry_validator: validator)
      meaning = result.fetch("finalized_internal_meaning")
      ok = result.fetch("result_lifecycle_state") == "finalized_internal" &&
        meaning.include?("internal assembly state only") &&
        meaning.include?("not PROP-036 finalization") &&
        meaning.include?("not compiler_profile_id")
      [ok, { "result_lifecycle_state" => result.fetch("result_lifecycle_state"), "meaning" => meaning }]
    end

    cases << case_result("bad_authority_stays_internal_validation_failure", expected: true) do
      bad_model = deep_copy(source_packet_model)
      bad_model["authority"]["authority_kind"] = "runtime"
      bad_packet = build_packet(bad_model)
      result = bad_packet.validate_with(registry_validator: validator)
      codes = result.fetch("profile_validation").fetch("source_diagnostics").map { |diag| diag.fetch("code") }
      ok = !result.fetch("valid") &&
        result.fetch("result_lifecycle_state") == "implementation_candidate" &&
        codes.include?(IgniterLang::OOFFragmentRegistry::SOURCE_DIAG_INVALID_AUTHORITY_KIND)
      [ok, { "validation" => result }]
    end

    checks = []
    checks << check("new_file_not_required_from_igniter_lang_rb") do
      main_lib = ROOT / "lib/igniter_lang.rb"
      !main_lib.exist? || !File.read(main_lib, encoding: "utf-8").include?("internal_profile_assembly_source_packet")
    end
    checks << check("compiler_pipeline_files_do_not_reference_packet") do
      no_file_mentions?(compiler_pipeline_files, TOKEN) &&
        no_file_mentions?(compiler_pipeline_files, "internal_profile_assembly_source_packet")
    end
    checks << check("public_report_runtime_manifest_prop_surfaces_closed") do
      result = packet.validate_with(registry_validator: validator)
      result.fetch("closed_surface_assertions").values.all?(false) &&
        public_keys_in(result).empty? &&
        no_file_mentions?(closed_surface_files, TOKEN)
    end
    checks << check("lifecycle_states_are_internal_only") do
      PACKET_CLASS::LIFECYCLE_STATES == %w[implementation_candidate finalized_internal] &&
        packet.lifecycle_state == "implementation_candidate"
    end
    checks << check("helper_mapping_uses_oof_fragment_registry_source_envelopes") do
      envelopes = packet.to_helper_envelopes
      envelopes.fetch("profile_envelope").fetch("kind") == "oof_fragment_registry_source" &&
        envelopes.fetch("pack_descriptor_envelopes").all? { |env| env.fetch("kind") == "oof_fragment_registry_source" }
    end

    failed_cases = cases.select { |entry| entry.fetch("status") != "PASS" }
    failed_checks = checks.select { |entry| entry.fetch("status") != "PASS" }
    status = failed_cases.empty? && failed_checks.empty? ? "PASS" : "FAIL"

    validation = packet.validate_with(registry_validator: validator)
    summary = {
      "kind" => "internal_profile_assembly_source_packet_proof_summary",
      "format_version" => "0.1.0",
      "track" => TRACK,
      "status" => status,
      "cases_total" => cases.length,
      "cases_pass" => cases.count { |entry| entry.fetch("status") == "PASS" },
      "checks_total" => checks.length,
      "checks_pass" => checks.count { |entry| entry.fetch("status") == "PASS" },
      "packet_digest" => digest(packet.to_h),
      "helper_envelopes_digest" => digest(packet.to_helper_envelopes),
      "validation_valid" => validation.fetch("valid"),
      "result_lifecycle_state" => validation.fetch("result_lifecycle_state"),
      "cases" => cases,
      "checks" => checks,
      "failed_cases" => failed_cases,
      "failed_checks" => failed_checks,
      "closed_surfaces" => closed_surface_assertions,
      "recommendation" => status == "PASS" ? "INTERNAL_PROFILE_ASSEMBLY_SOURCE_PACKET_ACCEPTED" : "HOLD"
    }

    File.write(OUT_DIR / "internal_profile_assembly_source_packet.to_h.json", "#{JSON.pretty_generate(packet.to_h)}\n")
    File.write(OUT_DIR / "internal_profile_assembly_source_packet.helper_envelopes.json", "#{JSON.pretty_generate(packet.to_helper_envelopes)}\n")
    File.write(OUT_DIR / "internal_profile_assembly_source_packet.validation.json", "#{JSON.pretty_generate(validation)}\n")
    File.write(OUT_DIR / "internal_profile_assembly_source_packet_proof_summary.json", "#{JSON.pretty_generate(summary)}\n")

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
      lib/igniter_lang/compiler_profile_contract_validator.rb
    ].map { |relative| ROOT / relative }
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

exit(InternalProfileAssemblySourcePacketProof.run ? 0 : 1)
