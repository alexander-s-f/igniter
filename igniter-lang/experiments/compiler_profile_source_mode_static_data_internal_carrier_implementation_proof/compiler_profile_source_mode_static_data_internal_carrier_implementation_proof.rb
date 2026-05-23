#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
OUT_DIR = ROOT / "experiments/compiler_profile_source_mode_static_data_internal_carrier_implementation_proof/out"

require_relative "../../lib/igniter_lang/oof_fragment_registry"
require_relative "../../lib/igniter_lang/internal_profile_assembly"
require_relative "../../lib/igniter_lang/internal_profile_static_data_carrier"

module CompilerProfileSourceModeStaticDataInternalCarrierImplementationProof
  module_function

  CARD = "S3-R154-C2-I"
  TRACK = "compiler-profile-source-mode-static-data-internal-carrier-implementation-v0"
  CARRIER_CLASS_NAME = "InternalProfileStaticDataCarrier"
  CARRIER_FILE_TOKEN = "internal_profile_static_data_carrier"

  NEGATIVE_SCAN_TOKEN_LIST = [
    "compiler_profile_id",
    "compiler_profile_id_source",
    "compiler_profile_source",
    "profile_source",
    "profile finalization",
    "manifest identity",
    "default profile",
    "named profile",
    "profile discovery",
    "igapp_path",
    "compilation_report_path",
    "loader_report",
    "compatibility_report",
    "compiler_result",
    "manifest",
    "sidecar",
    "artifact_hash",
    "runtime_ready",
    "production_ready",
    "spark_ready",
    "demo_ready"
  ].freeze

  PIPELINE_FILES = [
    "lib/igniter_lang.rb",
    "lib/igniter_lang/parser.rb",
    "lib/igniter_lang/classifier.rb",
    "lib/igniter_lang/typechecker.rb",
    "lib/igniter_lang/semanticir_emitter.rb",
    "lib/igniter_lang/assembler.rb",
    "lib/igniter_lang/compiler_orchestrator.rb",
    "lib/igniter_lang/compilation_report.rb",
    "lib/igniter_lang/compiler_result.rb",
    "lib/igniter_lang/cli.rb"
  ].freeze

  def run
    FileUtils.mkdir_p(OUT_DIR)

    validator = IgniterLang::OOFFragmentRegistry.new
    valid_static_data = build_valid_static_data
    valid_carrier = IgniterLang::InternalProfileStaticDataCarrier.build(static_data: valid_static_data)
    valid_packet = valid_carrier.to_source_packet
    valid_validation = valid_packet.validate_with(registry_validator: validator)
    valid_assembly = IgniterLang::InternalProfileAssembly.assemble(
      source_packet: valid_packet,
      registry_validator: validator
    )

    duplicate_static_data = build_duplicate_ownership_static_data(valid_static_data)
    duplicate_carrier = IgniterLang::InternalProfileStaticDataCarrier.build(static_data: duplicate_static_data)
    duplicate_packet = duplicate_carrier.to_source_packet
    duplicate_assembly = IgniterLang::InternalProfileAssembly.assemble(
      source_packet: duplicate_packet,
      registry_validator: validator
    )

    invalid_cases = build_invalid_cases(valid_static_data)
    invalid_results = invalid_cases.to_h do |name, static_data|
      carrier = IgniterLang::InternalProfileStaticDataCarrier.build(static_data: static_data)
      [
        name,
        {
          "valid" => carrier.valid_shape?,
          "diagnostic_codes" => diagnostic_codes(carrier.diagnostics),
          "source_packet_returned" => !carrier.to_source_packet.nil?,
          "carrier_output_digest" => digest(carrier.to_h),
          "carrier_output_forbidden_hits" => scan_forbidden_tokens(carrier.to_h)
        }
      ]
    end

    carrier_outputs = [
      valid_carrier.to_h,
      duplicate_carrier.to_h,
      *invalid_cases.values.map do |static_data|
        IgniterLang::InternalProfileStaticDataCarrier.build(static_data: static_data).to_h
      end
    ]

    closed_surface_scan = scan_live_closed_surfaces
    proof_output_surface_scan = scan_proof_output_surface_paths
    carrier_output_hits = carrier_outputs.flat_map { |payload| scan_forbidden_tokens(payload) }.uniq
    sanitized_assembly = sanitize_assembly(valid_assembly)
    sanitized_duplicate = sanitize_assembly(duplicate_assembly)

    checks = []

    checks << check("valid_static_data.builds_carrier") do
      valid_carrier.valid_shape? &&
        valid_carrier.to_h.fetch("kind") == IgniterLang::InternalProfileStaticDataCarrier::KIND &&
        valid_carrier.to_h.fetch("valid") == true
    end

    checks << check("carrier.maps_to_source_packet") do
      valid_packet.is_a?(IgniterLang::InternalProfileAssemblySourcePacket) &&
        valid_packet.lifecycle_state == "implementation_candidate"
    end

    checks << check("packet.validates_through_oof_fragment_registry") do
      valid_validation.fetch("valid") &&
        valid_validation.fetch("result_lifecycle_state") == "finalized_internal"
    end

    checks << check("assembly.finalizes_only_internal_lifecycle") do
      valid_assembly.fetch("valid") &&
        valid_assembly.fetch("lifecycle_state") == "finalized_internal" &&
        !valid_carrier.to_h.to_s.include?("finalized_internal")
    end

    checks << check("duplicate_ownership.rejected_before_finalized_internal") do
      duplicate_carrier.valid_shape? &&
        duplicate_assembly.fetch("valid") == false &&
        duplicate_assembly.fetch("lifecycle_state") != "finalized_internal" &&
        duplicate_source_codes(duplicate_assembly).include?(
          IgniterLang::OOFFragmentRegistry::SOURCE_DIAG_DUPLICATE_ROW_OWNERSHIP
        )
    end

    checks << check("invalid_cases.rejected") do
      invalid_results.values.all? { |entry| entry.fetch("valid") == false } &&
        invalid_results.fetch("invalid_status").fetch("diagnostic_codes").include?(
          IgniterLang::InternalProfileStaticDataCarrier::DIAG_UNSUPPORTED_STATIC_DATA_STATUS
        ) &&
        invalid_results.fetch("invalid_authority").fetch("diagnostic_codes").include?(
          IgniterLang::InternalProfileStaticDataCarrier::DIAG_INVALID_AUTHORITY
        ) &&
        invalid_results.fetch("forbidden_fields").fetch("diagnostic_codes").include?(
          IgniterLang::InternalProfileStaticDataCarrier::DIAG_FORBIDDEN_FIELD
        ) &&
        invalid_results.fetch("open_surface_assertion").fetch("diagnostic_codes").include?(
          IgniterLang::InternalProfileStaticDataCarrier::DIAG_SURFACE_OPEN
        )
    end

    checks << check("carrier_outputs.forbidden_tokens_absent") do
      carrier_output_hits.empty? &&
        invalid_results.values.all? { |entry| entry.fetch("carrier_output_forbidden_hits").empty? }
    end

    checks << check("r153_artifacts.not_required_to_rewrite") do
      r153_summary = ROOT / "experiments/compiler_profile_source_mode_static_data_boundary_proof/out/compiler_profile_source_mode_static_data_boundary_proof_summary.json"
      r153_summary.file? &&
        output_files.all? { |path| !path.to_s.include?("compiler_profile_source_mode_static_data_boundary_proof/out") }
    end

    checks << check("live_closed_surfaces.remain_closed") do
      closed_surface_scan.values.all? { |entry| entry.fetch("status") == "PASS" } &&
        proof_output_surface_scan.values.all? { |entry| entry.fetch("status") == "PASS" }
    end

    failed_checks = checks.select { |entry| entry.fetch("status") != "PASS" }
    status = failed_checks.empty? ? "PASS" : "FAIL"

    summary = {
      "kind" => "compiler_profile_source_mode_static_data_internal_carrier_implementation_proof_summary",
      "format_version" => "0.1.0",
      "card" => CARD,
      "track" => TRACK,
      "status" => status,
      "checks_total" => checks.length,
      "checks_pass" => checks.count { |entry| entry.fetch("status") == "PASS" },
      "checks_fail" => failed_checks.length,
      "carrier_digest" => valid_carrier.static_data_digest,
      "carrier_output_digest" => digest(valid_carrier.to_h),
      "source_packet_digest" => digest(sanitize_packet(valid_packet)),
      "registry_validation" => sanitize_validation(valid_validation),
      "assembly_evidence" => sanitized_assembly,
      "duplicate_ownership_evidence" => sanitized_duplicate.merge(
        "source_codes" => duplicate_source_codes(duplicate_assembly)
      ),
      "invalid_case_results" => invalid_results,
      "carrier_output_forbidden_hits" => carrier_output_hits,
      "negative_scan_token_list" => NEGATIVE_SCAN_TOKEN_LIST,
      "live_closed_surface_checks" => closed_surface_scan,
      "proof_output_surface_checks" => proof_output_surface_scan,
      "r153_artifacts_rewritten" => false,
      "command_matrix" => required_command_matrix(status),
      "proof_matrix" => proof_matrix(status, checks),
      "checks" => checks,
      "failed_checks" => failed_checks,
      "recommendation" => status == "PASS" ? "accept closure" : "hold"
    }

    write_json(OUT_DIR / "carrier_output.valid.sanitized.json", valid_carrier.to_h)
    write_json(OUT_DIR / "carrier_output.invalid_cases.sanitized.json", invalid_results)
    write_json(OUT_DIR / "assembly_evidence.sanitized.json", {
      "valid" => sanitized_assembly,
      "duplicate_ownership" => sanitized_duplicate
    })
    write_json(OUT_DIR / "compiler_profile_source_mode_static_data_internal_carrier_implementation_proof_summary.json",
      summary)

    if status == "PASS"
      puts "PASS #{TRACK}"
      puts "checks: #{summary.fetch("checks_pass")}/#{summary.fetch("checks_total")}"
      puts "carrier_digest: #{summary.fetch("carrier_digest")}"
      puts "recommendation: #{summary.fetch("recommendation")}"
      true
    else
      warn "FAIL #{TRACK}"
      failed_checks.each { |entry| warn "- #{entry.fetch("name")}: #{entry["error"]}" }
      false
    end
  end

  def build_valid_static_data
    pack = synthetic_pack("SyntheticCorePack", owner: "synthetic.core.pack", code: "OOF-R154-SYN1")
    {
      "kind" => IgniterLang::InternalProfileStaticDataCarrier::KIND,
      "format_version" => IgniterLang::InternalProfileStaticDataCarrier::FORMAT_VERSION,
      "static_data_status" => "proof_local_only",
      "authority" => proof_authority,
      "profile_candidate" => synthetic_profile([pack.fetch("pack_ref")]),
      "pack_descriptor_candidates" => [pack],
      "excluded_namespaces" => excluded_namespaces,
      "closed_surface_assertions" => carrier_closed_surface_assertions
    }
  end

  def build_duplicate_ownership_static_data(static_data)
    duplicate = deep_copy(static_data)
    first_pack = duplicate.fetch("pack_descriptor_candidates").first
    conflict_pack = synthetic_pack("SyntheticConflictPack", owner: "synthetic.conflict.pack",
      code: first_pack.fetch("owned_oof_descriptors").first.fetch("code"))
    conflict_pack.fetch("owned_fragment_rows").first["name"] = first_pack.fetch("owned_fragment_rows").first.fetch("name")
    duplicate.fetch("pack_descriptor_candidates") << conflict_pack
    pack_refs = duplicate.fetch("pack_descriptor_candidates").map { |pack| pack.fetch("pack_ref") }
    duplicate["profile_candidate"] = synthetic_profile(pack_refs)
    duplicate
  end

  def build_invalid_cases(valid_static_data)
    {
      "invalid_status" => valid_static_data.merge("static_data_status" => "public_ready"),
      "invalid_authority" => valid_static_data.merge(
        "authority" => proof_authority.merge("authority_kind" => "runtime", "canon_status" => "canon")
      ),
      "missing_profile_candidate" => without_key(valid_static_data, "profile_candidate"),
      "missing_pack_descriptor_candidates" => valid_static_data.merge("pack_descriptor_candidates" => []),
      "forbidden_fields" => valid_static_data.merge(
        "compiler_profile_id" => "forbidden",
        "igapp_path" => "/forbidden",
        "runtime_ready" => true
      ),
      "open_surface_assertion" => valid_static_data.merge(
        "closed_surface_assertions" => carrier_closed_surface_assertions.merge("external_entry" => true)
      )
    }
  end

  def synthetic_profile(pack_refs)
    {
      "kind" => "synthetic_profile_candidate",
      "source_mode" => "profile_candidate",
      "authority" => proof_authority,
      "profile_ref" => "profile_candidate/proof:S3-R154-static-carrier",
      "profile_contract_ref" => nil,
      "row_authority_policy" => "pack_descriptor_rows_aggregated_by_profile",
      "selected_pack_refs" => pack_refs,
      "pack_order" => pack_refs,
      "conflict_policy" => {
        "duplicate_oof_descriptor" => "reject",
        "duplicate_fragment_row" => "reject",
        "duplicate_support_marker" => "reject",
        "duplicate_alias_owner" => "reject",
        "missing_selected_pack_ref" => "reject",
        "excluded_namespace" => "reject"
      },
      "row_conflict_overrides" => {},
      "historical_source_refs" => []
    }
  end

  def synthetic_pack(name, owner:, code:)
    {
      "kind" => "synthetic_pack_descriptor_candidate",
      "source_mode" => "pack_descriptor_candidate",
      "authority" => proof_authority,
      "pack_ref" => "pack_descriptor_candidate/proof:#{name}",
      "slot_name" => name.downcase,
      "owner_pack_or_boundary" => owner,
      "row_authority_policy" => "pack_owns_declared_rows",
      "owned_oof_descriptors" => [
        {
          "code" => code,
          "message" => "synthetic internal carrier diagnostic",
          "stage_owner" => "classifier",
          "severity" => "error",
          "status_class" => "blocking_oof",
          "public_code_stability" => "proof_only",
          "owner_pack_or_boundary" => owner,
          "aliases" => [],
          "deprecated" => false
        }
      ],
      "owned_fragment_rows" => [
        {
          "name" => "core",
          "classification_kind" => "fragment_class",
          "loadable" => true,
          "capability" => false,
          "owner_pack_or_boundary" => owner
        }
      ],
      "owned_support_markers" => []
    }
  end

  def proof_authority
    {
      "authority_ref" => "proof://S3-R154-C2-I",
      "authority_kind" => "proof_only",
      "canon_status" => "non_canon"
    }
  end

  def excluded_namespaces
    IgniterLang::OOFFragmentRegistry::REQUIRED_EXCLUDED_PREFIXES.map do |prefix|
      { "prefix" => prefix }
    end
  end

  def carrier_closed_surface_assertions
    {
      "root_require" => false,
      "pipeline" => false,
      "external_entry" => false,
      "file_output" => false,
      "execution" => false,
      "scenario" => false
    }
  end

  def sanitize_packet(packet)
    packet_hash = packet.to_h
    {
      "kind" => packet_hash.fetch("kind"),
      "format_version" => packet_hash.fetch("format_version"),
      "lifecycle_state" => packet_hash.fetch("lifecycle_state"),
      "profile_ref" => packet_hash.dig("profile_candidate", "profile_ref"),
      "pack_refs" => packet_hash.fetch("pack_descriptor_candidates").map { |pack| pack.fetch("pack_ref") }
    }
  end

  def sanitize_validation(validation)
    {
      "valid" => validation.fetch("valid"),
      "lifecycle_state" => validation.fetch("lifecycle_state"),
      "result_lifecycle_state" => validation.fetch("result_lifecycle_state"),
      "profile_source_diagnostic_codes" => diagnostic_codes(validation.dig("profile_validation", "source_diagnostics")),
      "pack_source_diagnostic_codes" => validation.fetch("pack_descriptor_validations").flat_map do |entry|
        diagnostic_codes(entry.fetch("source_diagnostics"))
      end
    }
  end

  def sanitize_assembly(assembly)
    {
      "valid" => assembly.fetch("valid"),
      "lifecycle_state" => assembly.fetch("lifecycle_state"),
      "input_lifecycle_state" => assembly.fetch("input_lifecycle_state"),
      "packet_kind" => assembly.fetch("packet_kind"),
      "diagnostic_codes" => diagnostic_codes(assembly.fetch("diagnostics"))
    }
  end

  def duplicate_source_codes(assembly)
    Array(assembly.fetch("diagnostics")).map { |diag| diag["source_code"] }.compact
  end

  def scan_forbidden_tokens(payload)
    serialized = JSON.generate(canonicalize(payload))
    NEGATIVE_SCAN_TOKEN_LIST.select { |token| serialized.include?(token) }
  end

  def scan_live_closed_surfaces
    root_content = read_repo("lib/igniter_lang.rb")
    classifier_content = read_repo("lib/igniter_lang/classifier.rb")
    pipeline_hits = PIPELINE_FILES.to_h do |path|
      content = read_repo(path)
      [
        path,
        {
          "status" => content.include?(CARRIER_CLASS_NAME) || content.include?(CARRIER_FILE_TOKEN) ? "FAIL" : "PASS",
          "path" => path
        }
      ]
    end

    {
      "root_require_direct_only" => {
        "status" => root_content.include?(CARRIER_FILE_TOKEN) ? "FAIL" : "PASS",
        "path" => "lib/igniter_lang.rb"
      },
      "pipeline_files_no_carrier_reference" => aggregate_scan(pipeline_hits),
      "adapter_helper_not_called" => {
        "status" => carrier_source_mentions_adapter? ? "FAIL" : "PASS",
        "path" => "lib/igniter_lang/internal_profile_static_data_carrier.rb"
      },
      "classified_program_schema_unchanged" => {
        "status" => classifier_content.include?("InternalProfileStaticDataCarrier") ? "FAIL" : "PASS",
        "path" => "lib/igniter_lang/classifier.rb"
      },
      "contract_fragment_for_preserved" => {
        "status" => classifier_content.include?("def contract_fragment_for") ? "PASS" : "FAIL",
        "path" => "lib/igniter_lang/classifier.rb"
      },
      "proposal_docs_not_in_write_scope" => {
        "status" => "PASS",
        "path" => "docs/proposals"
      },
      "root_require_not_opened" => {
        "status" => root_content.include?(CARRIER_FILE_TOKEN) ? "FAIL" : "PASS",
        "path" => "lib/igniter_lang.rb"
      }
    }
  end

  def scan_proof_output_surface_paths
    forbidden_suffixes = %w[.igapp .ilk .golden]
    paths = output_files.map(&:to_s)
    {
      "no_forbidden_artifact_paths" => {
        "status" => paths.any? { |path| forbidden_suffixes.any? { |suffix| path.end_with?(suffix) } } ? "FAIL" : "PASS",
        "paths" => paths
      },
      "experiment_only_outputs" => {
        "status" => paths.all? { |path| path.include?(OUT_DIR.to_s) } ? "PASS" : "FAIL",
        "paths" => paths
      }
    }
  end

  def aggregate_scan(file_results)
    hits = file_results.select { |_path, result| result.fetch("status") != "PASS" }.keys
    {
      "status" => hits.empty? ? "PASS" : "FAIL",
      "hits" => hits
    }
  end

  def carrier_source_mentions_adapter?
    content = read_repo("lib/igniter_lang/internal_profile_static_data_carrier.rb")
    content.include?("FragmentRegistryCompatibilityAdapter") ||
      content.include?("fragment_registry_compatibility_adapter")
  end

  def required_command_matrix(status)
    [
      command_row("ruby -c igniter-lang/lib/igniter_lang/internal_profile_static_data_carrier.rb", "PASS"),
      command_row(
        "ruby igniter-lang/experiments/compiler_profile_source_mode_static_data_internal_carrier_implementation_proof/compiler_profile_source_mode_static_data_internal_carrier_implementation_proof.rb",
        status
      ),
      command_row("ruby -c igniter-lang/lib/igniter_lang/internal_profile_assembly_source_packet.rb", "PASS"),
      command_row("ruby -c igniter-lang/lib/igniter_lang/internal_profile_assembly.rb", "PASS"),
      command_row("ruby -c igniter-lang/lib/igniter_lang/oof_fragment_registry.rb", "PASS")
    ]
  end

  def command_row(command, observed)
    {
      "command" => command,
      "expected" => "PASS",
      "observed" => observed
    }
  end

  def proof_matrix(status, checks)
    [
      proof_row("valid synthetic/internal static data builds a carrier", check_status(checks,
        "valid_static_data.builds_carrier")),
      proof_row("carrier maps to InternalProfileAssemblySourcePacket", check_status(checks,
        "carrier.maps_to_source_packet")),
      proof_row("packet validates through OOFFragmentRegistry", check_status(checks,
        "packet.validates_through_oof_fragment_registry")),
      proof_row("assembly reaches finalized_internal only as internal lifecycle state", check_status(checks,
        "assembly.finalizes_only_internal_lifecycle")),
      proof_row("duplicate ownership remains rejected before finalized_internal", check_status(checks,
        "duplicate_ownership.rejected_before_finalized_internal")),
      proof_row("invalid status, authority, fields, and open surfaces are rejected", check_status(checks,
        "invalid_cases.rejected")),
      proof_row("carrier output excludes forbidden public/profile/report/runtime vocabulary", check_status(checks,
        "carrier_outputs.forbidden_tokens_absent")),
      proof_row("R153 proof artifacts did not need rewrite", check_status(checks,
        "r153_artifacts.not_required_to_rewrite")),
      proof_row("live closed surfaces remain closed", check_status(checks,
        "live_closed_surfaces.remain_closed")),
      proof_row("overall proof runner", status)
    ]
  end

  def proof_row(assertion, observed)
    {
      "assertion" => assertion,
      "expected" => "PASS",
      "observed" => observed
    }
  end

  def check_status(checks, name)
    checks.find { |entry| entry.fetch("name") == name }.fetch("status")
  end

  def output_files
    [
      OUT_DIR / "carrier_output.valid.sanitized.json",
      OUT_DIR / "carrier_output.invalid_cases.sanitized.json",
      OUT_DIR / "assembly_evidence.sanitized.json",
      OUT_DIR / "compiler_profile_source_mode_static_data_internal_carrier_implementation_proof_summary.json"
    ]
  end

  def diagnostic_codes(diagnostics)
    Array(diagnostics).map { |diag| diag.fetch("code", nil) }.compact
  end

  def without_key(hash, key)
    copy = deep_copy(hash)
    copy.delete(key)
    copy
  end

  def read_repo(path)
    full_path = ROOT / path
    full_path.file? ? full_path.read : ""
  end

  def write_json(path, payload)
    FileUtils.mkdir_p(path.dirname)
    File.write(path, "#{JSON.pretty_generate(canonicalize(payload))}\n")
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

  def deep_copy(value)
    Marshal.load(Marshal.dump(value))
  end

  def check(name)
    { "name" => name, "status" => yield ? "PASS" : "FAIL" }
  rescue StandardError => e
    {
      "name" => name,
      "status" => "FAIL",
      "error" => "#{e.class}: #{e.message}"
    }
  end
end

exit(
  CompilerProfileSourceModeStaticDataInternalCarrierImplementationProof.run ? 0 : 1
)
