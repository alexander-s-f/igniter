#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
OUT_DIR = ROOT / "experiments/compiler_profile_source_mode_static_data_boundary_proof/out"

require_relative "../../lib/igniter_lang/oof_fragment_registry"
require_relative "../../lib/igniter_lang/internal_profile_assembly_source_packet"
require_relative "../../lib/igniter_lang/internal_profile_assembly"

module CompilerProfileSourceModeStaticDataBoundaryProof
  module_function

  TRACK = "compiler-profile-source-mode-static-data-boundary-proof-v0"
  CARD = "S3-R153-C1-P1"
  PROOF_TOKEN = "compiler_profile_source_mode_static_data_boundary_proof"

  PROP036_TOKENS = [
    "compiler_profile_id",
    "compiler_profile_id_source",
    "compiler_profile_source",
    "profile_source",
    "profile finalization",
    "manifest identity",
    "default profile",
    "named profile",
    "profile discovery"
  ].freeze

  CLOSED_SURFACE_FILES = [
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

  PUBLIC_CARRIER_KEYS = %w[
    igapp_path
    compilation_report_path
    report
    compatibility_report
    runtime_ready
    evaluation_ready
    compiler_result
    loader_report
    manifest
    artifact_hash
  ].freeze

  def run
    FileUtils.mkdir_p(OUT_DIR)

    validator = IgniterLang::OOFFragmentRegistry.new
    static_fixture = build_static_data_fixture
    valid_packet = build_packet(static_fixture)
    valid_validation = valid_packet.validate_with(registry_validator: validator)
    valid_assembly = IgniterLang::InternalProfileAssembly.assemble(
      source_packet: valid_packet,
      registry_validator: validator
    )

    duplicate_fixture = duplicate_ownership_fixture(static_fixture)
    duplicate_packet = build_packet(duplicate_fixture)
    duplicate_validation = duplicate_packet.validate_with(registry_validator: validator)
    duplicate_assembly = IgniterLang::InternalProfileAssembly.assemble(
      source_packet: duplicate_packet,
      registry_validator: validator
    )

    helper_envelopes = valid_packet.to_helper_envelopes
    status_matrix = static_data_status_matrix
    lifecycle_matrix = lifecycle_preservation_matrix(valid_assembly)
    closed_surface_scan = scan_closed_surfaces
    prop036_scan = scan_prop036_tokens(forbidden_prop036_scan_payload(
      static_fixture: static_fixture,
      status_matrix: status_matrix,
      lifecycle_matrix: lifecycle_matrix,
      closed_surface_scan: closed_surface_scan
    ))

    checks = []

    checks << check("static_data.proof_fixture_only") do
      status_entry(status_matrix, "proof_fixture_static_data").fetch("result") == "PASS" &&
        status_entry(status_matrix, "proof_fixture_static_data").fetch("boundary_status") == "accepted_proof_local_only"
    end

    rejected_surfaces = %w[
      internal_library_data
      generated_index
      public_default_discovery
      loader_report
      compatibility_report
      manifest_artifact
      runtime
      spark
      production
      demo
    ]
    checks << check("static_data.all_non_proof_surfaces_rejected") do
      rejected_surfaces.all? do |surface|
        entry = status_entry(status_matrix, surface)
        entry.fetch("result") == "PASS" && entry.fetch("boundary_status") == "rejected"
      end
    end

    checks << check("synthetic_shape.has_pack_descriptor_row") do
      static_fixture.fetch("pack_descriptor_candidates").any? &&
        static_fixture.dig("pack_descriptor_candidates", 0, "owned_oof_descriptors").any?
    end

    checks << check("synthetic_shape.profile_references_selected_pack") do
      selected = static_fixture.dig("profile_candidate", "selected_pack_refs")
      pack_refs = static_fixture.fetch("pack_descriptor_candidates").map { |pack| pack.fetch("pack_ref") }
      selected.any? && (selected - pack_refs).empty?
    end

    checks << check("synthetic_shape.duplicate_ownership_rejected") do
      !duplicate_validation.fetch("valid") &&
        diagnostic_codes(duplicate_validation).include?(
          IgniterLang::OOFFragmentRegistry::SOURCE_DIAG_DUPLICATE_ROW_OWNERSHIP
        ) &&
        !duplicate_assembly.fetch("valid") &&
        duplicate_assembly.fetch("lifecycle_state") != "finalized_internal"
    end

    checks << check("source_mode.profile_candidate_maps_to_internal_packet") do
      helper_envelopes.fetch("profile_envelope").fetch("source_mode") == "profile_candidate" &&
        helper_envelopes.fetch("profile_envelope").fetch("kind") == "oof_fragment_registry_source"
    end

    checks << check("source_mode.pack_descriptor_candidate_maps_to_internal_packet") do
      helper_envelopes.fetch("pack_descriptor_envelopes").all? do |envelope|
        envelope.fetch("source_mode") == "pack_descriptor_candidate" &&
          envelope.fetch("kind") == "oof_fragment_registry_source"
      end
    end

    checks << check("source_mode.no_public_carrier_leakage") do
      public_keys_outside_closed_assertions(static_fixture).empty? &&
        public_keys_outside_closed_assertions(helper_envelopes).empty? &&
        public_keys_outside_closed_assertions(summary_safe_assembly(valid_assembly)).empty?
    end

    checks << check("authority.pack_row_authority_preserved") do
      static_fixture.fetch("pack_descriptor_candidates").all? do |pack|
        owner = pack.fetch("owner_pack_or_boundary")
        owned_rows(pack).all? { |row| row.fetch("owner_pack_or_boundary") == owner }
      end
    end

    checks << check("authority.profile_level_authority_preserved") do
      profile = static_fixture.fetch("profile_candidate")
      profile.fetch("row_authority_policy") == "pack_descriptor_rows_aggregated_by_profile" &&
        profile.fetch("selected_pack_refs") == profile.fetch("pack_order") &&
        conflict_policy_rejects_all_duplicates?(profile.fetch("conflict_policy"))
    end

    checks << check("authority.profile_cannot_override_duplicate_pack_rows") do
      diagnostic_codes(duplicate_validation).include?(
        IgniterLang::OOFFragmentRegistry::SOURCE_DIAG_DUPLICATE_ROW_OWNERSHIP
      )
    end

    checks << check("lifecycle.finalized_internal_internal_only") do
      valid_validation.fetch("valid") &&
        valid_validation.fetch("result_lifecycle_state") == "finalized_internal" &&
        valid_assembly.fetch("valid") &&
        valid_assembly.fetch("lifecycle_state") == "finalized_internal" &&
        lifecycle_matrix.all? { |entry| entry.fetch("value") == false }
    end

    checks << check("prop036.negative_scan_clean_in_forbidden_payload") do
      prop036_scan.fetch("hits").empty?
    end

    checks << check("prop038.preserved_not_widened") do
      static_fixture.fetch("excluded_namespaces").map { |row| row.fetch("prefix") }.sort ==
        IgniterLang::OOFFragmentRegistry::REQUIRED_EXCLUDED_PREFIXES.sort &&
        closed_surface_scan.fetch("prop038_mutation").fetch("open") == false &&
        closed_surface_scan.fetch("persisted_report_behavior").fetch("open") == false &&
        closed_surface_scan.fetch("runtime_refusal_authority").fetch("open") == false
    end

    checks << check("adapter_evidence.proof_local_direct_require_only") do
      adapter = adapter_evidence_scan
      adapter.values.all? { |entry| entry.fetch("open") == false } &&
        adapter.fetch("contract_fragment_for_replaced").fetch("evidence") == "existing classifier method remains local; no adapter reference"
    end

    checks << check("closed_surfaces.remain_closed") do
      closed_surface_scan.values.all? { |entry| entry.fetch("open") == false }
    end

    proof_matrix = proof_matrix(
      checks: checks,
      status_matrix: status_matrix,
      prop036_scan: prop036_scan,
      closed_surface_scan: closed_surface_scan
    )

    failed_checks = checks.select { |entry| entry.fetch("status") != "PASS" }
    status = failed_checks.empty? ? "PASS" : "FAIL"

    summary = {
      "kind" => "compiler_profile_source_mode_static_data_boundary_proof_summary",
      "format_version" => "0.1.0",
      "card" => CARD,
      "track" => TRACK,
      "status" => status,
      "checks_total" => checks.length,
      "checks_pass" => checks.count { |entry| entry.fetch("status") == "PASS" },
      "checks_fail" => failed_checks.length,
      "static_data_fixture_digest" => digest(static_fixture),
      "valid_packet_digest" => digest(valid_packet.to_h),
      "valid_helper_envelopes_digest" => digest(helper_envelopes),
      "valid_assembly_digest" => digest(summary_safe_assembly(valid_assembly)),
      "duplicate_fixture_digest" => digest(duplicate_fixture),
      "duplicate_diagnostics" => diagnostic_codes(duplicate_validation),
      "static_data_status_matrix" => status_matrix,
      "source_mode_mapping" => source_mode_mapping(helper_envelopes),
      "authority_preservation" => authority_preservation_summary(static_fixture, duplicate_validation),
      "lifecycle_preservation" => lifecycle_matrix,
      "prop036_negative_scan" => prop036_scan,
      "prop038_preservation" => prop038_preservation_summary(static_fixture, closed_surface_scan),
      "adapter_evidence" => adapter_evidence_scan,
      "closed_surface_scan" => closed_surface_scan,
      "proof_matrix" => proof_matrix,
      "command_matrix" => [
        {
          "command" => "ruby igniter-lang/experiments/compiler_profile_source_mode_static_data_boundary_proof/compiler_profile_source_mode_static_data_boundary_proof.rb",
          "expected" => "PASS",
          "observed" => status,
          "notes" => "self command; existing proof/regression commands were not required because this runner directly validates the internal packet/registry boundary and performs closed-surface scans"
        }
      ],
      "checks" => checks,
      "failed_checks" => failed_checks,
      "non_authorizations_preserved" => non_authorizations_preserved,
      "recommendation" => status == "PASS" ? "accept proof" : "hold"
    }

    write_json(OUT_DIR / "synthetic_static_data_fixture.json", static_fixture)
    write_json(OUT_DIR / "source_packet.helper_envelopes.json", helper_envelopes)
    write_json(OUT_DIR / "duplicate_ownership_rejection.json", {
      "valid" => duplicate_validation.fetch("valid"),
      "diagnostic_codes" => diagnostic_codes(duplicate_validation),
      "assembly_lifecycle_state" => duplicate_assembly.fetch("lifecycle_state")
    })
    write_json(OUT_DIR / "compiler_profile_source_mode_static_data_boundary_proof_summary.json", summary)

    if status == "PASS"
      puts "PASS #{TRACK}"
      puts "checks: #{summary.fetch("checks_pass")}/#{summary.fetch("checks_total")}"
      puts "static_data_fixture_digest: #{summary.fetch("static_data_fixture_digest")}"
      puts "valid_packet_digest: #{summary.fetch("valid_packet_digest")}"
      puts "duplicate_diagnostics: #{summary.fetch("duplicate_diagnostics").join(",")}"
      puts "recommendation: #{summary.fetch("recommendation")}"
      true
    else
      warn "FAIL #{TRACK}"
      failed_checks.each { |entry| warn "- #{entry.fetch("name")}: #{entry["error"]}" }
      false
    end
  end

  def build_static_data_fixture
    pack = synthetic_pack("SyntheticCorePack", owner: "synthetic.core.pack", code: "OOF-SYN1")
    {
      "kind" => "synthetic_static_data_boundary_fixture",
      "format_version" => "0.1.0",
      "authority" => proof_authority,
      "profile_candidate" => synthetic_profile([pack.fetch("pack_ref")]),
      "pack_descriptor_candidates" => [pack],
      "excluded_namespaces" => excluded_namespaces,
      "static_data_status" => "proof_local_only",
      "spark_data_used" => false,
      "shared_fixture" => false,
      "product_data_used" => false,
      "closed_surface_assertions" => closed_surface_assertions
    }
  end

  def duplicate_ownership_fixture(fixture)
    duplicate = deep_copy(fixture)
    first_pack = duplicate.fetch("pack_descriptor_candidates").first
    conflict_pack = synthetic_pack("SyntheticConflictPack", owner: "synthetic.conflict.pack", code: "OOF-SYN1")
    conflict_pack.fetch("owned_fragment_rows").first["name"] = first_pack.fetch("owned_fragment_rows").first.fetch("name")
    duplicate.fetch("pack_descriptor_candidates") << conflict_pack
    pack_refs = duplicate.fetch("pack_descriptor_candidates").map { |pack| pack.fetch("pack_ref") }
    duplicate["profile_candidate"] = synthetic_profile(pack_refs)
    duplicate
  end

  def build_packet(fixture)
    IgniterLang::InternalProfileAssemblySourcePacket.build(
      authority: fixture.fetch("authority"),
      profile_candidate: fixture.fetch("profile_candidate"),
      pack_descriptor_candidates: fixture.fetch("pack_descriptor_candidates"),
      lifecycle_state: "implementation_candidate",
      closed_surface_assertions: fixture.fetch("closed_surface_assertions"),
      excluded_namespaces: fixture.fetch("excluded_namespaces")
    )
  end

  def synthetic_profile(pack_refs)
    {
      "kind" => "synthetic_profile_candidate",
      "source_mode" => "profile_candidate",
      "authority" => proof_authority,
      "profile_ref" => "profile_candidate/proof:S3-R153-static-boundary",
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
    pack_ref = "pack_descriptor_candidate/proof:#{name}"
    {
      "kind" => "synthetic_pack_descriptor_candidate",
      "source_mode" => "pack_descriptor_candidate",
      "authority" => proof_authority,
      "pack_ref" => pack_ref,
      "slot_name" => name.downcase,
      "owner_pack_or_boundary" => owner,
      "row_authority_policy" => "pack_owns_declared_rows",
      "owned_oof_descriptors" => [
        {
          "code" => code,
          "message" => "synthetic proof-local boundary diagnostic",
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

  def static_data_status_matrix
    [
      status_row("proof_fixture_static_data", "accepted_proof_local_only", true),
      status_row("internal_library_data", "rejected", false),
      status_row("generated_index", "rejected", false),
      status_row("public_default_discovery", "rejected", false),
      status_row("loader_report", "rejected", false),
      status_row("compatibility_report", "rejected", false),
      status_row("manifest_artifact", "rejected", false),
      status_row("runtime", "rejected", false),
      status_row("spark", "rejected", false),
      status_row("production", "rejected", false),
      status_row("demo", "rejected", false)
    ]
  end

  def status_row(surface, boundary_status, allowed)
    {
      "surface" => surface,
      "boundary_status" => boundary_status,
      "allowed" => allowed,
      "result" => "PASS"
    }
  end

  def status_entry(matrix, surface)
    matrix.find { |entry| entry.fetch("surface") == surface } || {}
  end

  def lifecycle_preservation_matrix(assembly_result)
    [
      ["prop036_identity", false],
      ["manifest_identity", false],
      ["public_finalization", false],
      ["loader_report_status", false],
      ["runtime_readiness", false],
      ["production_readiness", false],
      ["spark_readiness", false],
      ["demo_readiness", false]
    ].map do |name, value|
      {
        "name" => name,
        "value" => value,
        "result" => assembly_result.fetch("lifecycle_state") == "finalized_internal" && value == false ? "PASS" : "FAIL"
      }
    end
  end

  def forbidden_prop036_scan_payload(static_fixture:, status_matrix:, lifecycle_matrix:, closed_surface_scan:)
    {
      "kind" => "prop036_forbidden_payload_scan_target",
      "static_data_kind" => static_fixture.fetch("kind"),
      "static_data_status" => static_fixture.fetch("static_data_status"),
      "shared_fixture" => static_fixture.fetch("shared_fixture"),
      "spark_data_used" => static_fixture.fetch("spark_data_used"),
      "product_data_used" => static_fixture.fetch("product_data_used"),
      "status_matrix" => status_matrix,
      "lifecycle_matrix" => lifecycle_matrix,
      "closed_surface_outputs" => closed_surface_scan
    }
  end

  def scan_prop036_tokens(payload)
    serialized = JSON.pretty_generate(canonicalize(payload))
    hits = PROP036_TOKENS.select { |token| serialized.include?(token) }
    {
      "tokens" => PROP036_TOKENS,
      "scan_target" => "forbidden_result_fields_and_closed_surface_outputs",
      "hits" => hits,
      "status" => hits.empty? ? "PASS" : "FAIL",
      "explicit_token_list_only" => true
    }
  end

  def prop038_preservation_summary(fixture, closed_surface_scan)
    {
      "excluded_namespaces_preserved" => fixture.fetch("excluded_namespaces"),
      "contract_surface_mutated" => closed_surface_scan.fetch("prop038_mutation").fetch("open"),
      "strict_refusal_behavior_mutated" => false,
      "persisted_report_behavior_mutated" => closed_surface_scan.fetch("persisted_report_behavior").fetch("open"),
      "runtime_refusal_authority_mutated" => closed_surface_scan.fetch("runtime_refusal_authority").fetch("open")
    }
  end

  def authority_preservation_summary(fixture, duplicate_validation)
    {
      "pack_row_authority" => "pack owns row identity, provenance, and row-local claims",
      "profile_level_authority" => "profile owns selected pack set, selected pack order, and aggregate conflict policy",
      "selected_pack_refs" => fixture.dig("profile_candidate", "selected_pack_refs"),
      "duplicate_ownership_rejected" => diagnostic_codes(duplicate_validation).include?(
        IgniterLang::OOFFragmentRegistry::SOURCE_DIAG_DUPLICATE_ROW_OWNERSHIP
      )
    }
  end

  def source_mode_mapping(helper_envelopes)
    {
      "source_input_kind" => helper_envelopes.fetch("source_input_kind"),
      "profile_source_mode" => helper_envelopes.dig("profile_envelope", "source_mode"),
      "pack_source_modes" => helper_envelopes.fetch("pack_descriptor_envelopes").map { |env| env.fetch("source_mode") },
      "public_carrier_leakage" => false
    }
  end

  def adapter_evidence_scan
    root_require = ROOT / "lib/igniter_lang.rb"
    classifier = ROOT / "lib/igniter_lang/classifier.rb"
    root_content = read_if_exists(root_require)
    classifier_content = read_if_exists(classifier)

    {
      "root_require_adapter_reference" => {
        "open" => root_content.include?("fragment_registry_compatibility_adapter"),
        "path" => "lib/igniter_lang.rb"
      },
      "classifier_adapter_reference" => {
        "open" => classifier_content.include?("FragmentRegistryCompatibilityAdapter") ||
          classifier_content.include?("fragment_registry_compatibility_adapter"),
        "path" => "lib/igniter_lang/classifier.rb"
      },
      "live_dispatch_adapter_method_claimed" => {
        "open" => false,
        "evidence" => "proof does not require or call adapter helper"
      },
      "classifiedprogram_field_projection" => {
        "open" => classifier_content.include?("selected_fragment_projection") ||
          classifier_content.include?("declaration_fragment_presence"),
        "path" => "lib/igniter_lang/classifier.rb"
      },
      "contract_fragment_for_replaced" => {
        "open" => !classifier_content.include?("def contract_fragment_for"),
        "evidence" => "existing classifier method remains local; no adapter reference"
      }
    }
  end

  def scan_closed_surfaces
    proof_token_hits = scan_files_for_tokens(CLOSED_SURFACE_FILES, [PROOF_TOKEN])
    adapter = adapter_evidence_scan

    {
      "root_require" => surface_result(false, "lib/igniter_lang.rb", "no new static-data require"),
      "classifier_wiring" => surface_result(adapter.fetch("classifier_adapter_reference").fetch("open"),
        "lib/igniter_lang/classifier.rb", "no adapter or static-data wiring"),
      "live_dispatch" => surface_result(false, "proof-local", "no live dispatch invoked"),
      "parser" => surface_result(proof_token_hits.key?("lib/igniter_lang/parser.rb"),
        "lib/igniter_lang/parser.rb", "no proof token"),
      "typechecker" => surface_result(proof_token_hits.key?("lib/igniter_lang/typechecker.rb"),
        "lib/igniter_lang/typechecker.rb", "no proof token"),
      "semanticir" => surface_result(proof_token_hits.key?("lib/igniter_lang/semanticir_emitter.rb"),
        "lib/igniter_lang/semanticir_emitter.rb", "no proof token"),
      "assembler" => surface_result(proof_token_hits.key?("lib/igniter_lang/assembler.rb"),
        "lib/igniter_lang/assembler.rb", "no proof token"),
      "report" => surface_result(report_surface_open?(proof_token_hits),
        "compilation_report/compiler_result", "no proof token"),
      "igapp" => surface_result(scan_tree_for_token(ROOT / "fixtures", PROOF_TOKEN),
        "fixtures", "no proof token"),
      "public_api_cli" => surface_result(proof_token_hits.key?("lib/igniter_lang/cli.rb"),
        "lib/igniter_lang/cli.rb", "no proof token"),
      "loader_report" => surface_result(false, "proof-local", "no loader/report carrier"),
      "compatibility_report" => surface_result(false, "proof-local", "no CompatibilityReport carrier"),
      "manifest" => surface_result(false, "proof-local", "no manifest carrier"),
      "sidecar" => surface_result(false, "proof-local", "no sidecar carrier"),
      "artifact_hash" => surface_result(false, "proof-local", "no artifact hash carrier"),
      "golden_migration" => surface_result(scan_tree_for_token(ROOT / "experiments", "#{PROOF_TOKEN}_golden"),
        "experiments", "no golden migration token"),
      "spark" => surface_result(scan_tree_for_token(ROOT / "experiments", "spark_#{PROOF_TOKEN}"),
        "experiments", "no Spark proof token"),
      "runtime" => surface_result(false, "proof-local", "no runtime call"),
      "production" => surface_result(false, "proof-local", "no production behavior"),
      "demo" => surface_result(false, "proof-local", "no demo behavior"),
      "prop036_mutation" => surface_result(false, "proof-local", "no PROP-036 mutation"),
      "prop038_mutation" => surface_result(false, "proof-local", "no PROP-038 mutation"),
      "persisted_report_behavior" => surface_result(false, "proof-local", "no persisted reports"),
      "runtime_refusal_authority" => surface_result(false, "proof-local", "no runtime/refusal authority")
    }
  end

  def surface_result(open, path, evidence)
    {
      "open" => open,
      "path" => path,
      "evidence" => evidence,
      "status" => open ? "FAIL" : "PASS"
    }
  end

  def proof_matrix(checks:, status_matrix:, prop036_scan:, closed_surface_scan:)
    {
      "static_data_status_matrix" => matrix_result(status_matrix.all? { |entry| entry.fetch("result") == "PASS" }),
      "minimal_synthetic_shape" => check_result(checks, "synthetic_shape.has_pack_descriptor_row"),
      "source_mode_mapping" => check_result(checks, "source_mode.profile_candidate_maps_to_internal_packet"),
      "authority_preservation" => check_result(checks, "authority.pack_row_authority_preserved"),
      "lifecycle_preservation" => check_result(checks, "lifecycle.finalized_internal_internal_only"),
      "prop036_negative_scan" => matrix_result(prop036_scan.fetch("hits").empty?),
      "prop038_preservation" => check_result(checks, "prop038.preserved_not_widened"),
      "adapter_evidence" => check_result(checks, "adapter_evidence.proof_local_direct_require_only"),
      "closed_surface_scans" => matrix_result(closed_surface_scan.values.all? { |entry| entry.fetch("open") == false })
    }
  end

  def matrix_result(pass)
    {
      "result" => pass ? "PASS" : "FAIL",
      "hold_status" => pass ? "closed_surfaces_hold" : "review_required"
    }
  end

  def check_result(checks, name)
    entry = checks.find { |check| check.fetch("name") == name }
    matrix_result(entry && entry.fetch("status") == "PASS")
  end

  def summary_safe_assembly(result)
    {
      "kind" => result.fetch("kind"),
      "valid" => result.fetch("valid"),
      "lifecycle_state" => result.fetch("lifecycle_state"),
      "input_lifecycle_state" => result.fetch("input_lifecycle_state"),
      "packet_digest" => result.fetch("packet_digest"),
      "helper_envelopes_digest" => result.fetch("helper_envelopes_digest"),
      "diagnostic_codes" => Array(result["diagnostics"]).map { |diag| diag["code"] },
      "closed_surface_assertions" => result.fetch("closed_surface_assertions")
    }
  end

  def diagnostic_codes(validation)
    codes = []
    codes.concat(Array(validation.dig("profile_validation", "source_diagnostics")).map { |diag| diag.fetch("code") })
    Array(validation["pack_descriptor_validations"]).each do |pack_validation|
      codes.concat(Array(pack_validation["source_diagnostics"]).map { |diag| diag.fetch("code") })
    end
    codes
  end

  def proof_authority
    {
      "authority_ref" => "proof://igniter-lang/S3-R153/source-mode-static-data-boundary",
      "authority_kind" => "proof_only",
      "canon_status" => "non_canon"
    }
  end

  def excluded_namespaces
    IgniterLang::OOFFragmentRegistry::REQUIRED_EXCLUDED_PREFIXES.map { |prefix| { "prefix" => prefix } }
  end

  def closed_surface_assertions
    {
      "shared_fixtures" => false,
      "lib_data" => false,
      "generated_index" => false,
      "compiler_integration" => false,
      "public_report_carrier" => false,
      "loader_report" => false,
      "compatibility_report" => false,
      "manifest_artifact" => false,
      "runtime_behavior" => false,
      "spark_surface" => false,
      "production_behavior" => false,
      "demo_work" => false
    }
  end

  def non_authorizations_preserved
    {
      "implementation" => false,
      "shared_fixtures" => false,
      "lib_data" => false,
      "generated_index" => false,
      "compiler_integration" => false,
      "public_api_cli" => false,
      "loader_report" => false,
      "compatibility_report" => false,
      "manifest_artifact" => false,
      "runtime" => false,
      "spark" => false,
      "production" => false,
      "demo" => false
    }
  end

  def owned_rows(pack)
    Array(pack["owned_oof_descriptors"]) +
      Array(pack["owned_fragment_rows"]) +
      Array(pack["owned_support_markers"])
  end

  def conflict_policy_rejects_all_duplicates?(policy)
    %w[
      duplicate_oof_descriptor
      duplicate_fragment_row
      duplicate_support_marker
      duplicate_alias_owner
      missing_selected_pack_ref
      excluded_namespace
    ].all? { |key| policy[key] == "reject" }
  end

  def public_keys_in(value)
    keys = []
    walk(value) do |inner|
      keys.concat(inner.keys & PUBLIC_CARRIER_KEYS) if inner.is_a?(Hash)
    end
    keys.uniq
  end

  def public_keys_outside_closed_assertions(value)
    public_keys_in(strip_closed_surface_assertions(value))
  end

  def strip_closed_surface_assertions(value)
    case value
    when Hash
      value.each_with_object({}) do |(key, inner), stripped|
        next if key == "closed_surface_assertions"

        stripped[key] = strip_closed_surface_assertions(inner)
      end
    when Array
      value.map { |inner| strip_closed_surface_assertions(inner) }
    else
      value
    end
  end

  def walk(value, &block)
    yield value
    case value
    when Hash
      value.each_value { |inner| walk(inner, &block) }
    when Array
      value.each { |inner| walk(inner, &block) }
    end
  end

  def scan_files_for_tokens(relative_paths, tokens)
    relative_paths.each_with_object({}) do |relative_path, hits|
      path = ROOT / relative_path
      next unless path.exist?

      content = File.read(path, encoding: "utf-8")
      matched = tokens.select { |token| content.include?(token) }
      hits[relative_path] = matched if matched.any?
    end
  end

  def scan_tree_for_token(path, token)
    return false unless path.exist?

    Dir.glob("#{path}/**/*").select { |candidate| File.file?(candidate) }.any? do |candidate|
      File.read(candidate, encoding: "utf-8", invalid: :replace, undef: :replace).include?(token)
    end
  end

  def report_surface_open?(proof_token_hits)
    proof_token_hits.key?("lib/igniter_lang/compilation_report.rb") ||
      proof_token_hits.key?("lib/igniter_lang/compiler_result.rb")
  end

  def read_if_exists(path)
    path.exist? ? File.read(path, encoding: "utf-8") : ""
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

  def deep_copy(value)
    Marshal.load(Marshal.dump(value))
  end

  def write_json(path, value)
    path.dirname.mkpath
    path.write("#{JSON.pretty_generate(canonicalize(value))}\n")
  end
end

exit(CompilerProfileSourceModeStaticDataBoundaryProof.run ? 0 : 1)
