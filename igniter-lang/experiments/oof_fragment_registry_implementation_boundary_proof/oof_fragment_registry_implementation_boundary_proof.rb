#!/usr/bin/env ruby
# frozen_string_literal: true

# Track: oof-fragment-registry-implementation-boundary-proof-v0
# Card:  LANG-R103-I
# Agent: [Igniter-Lang Implementation Agent]
#
# Proof for the first bounded OOF/Fragment Registry implementation slice.
#
# This proof covers:
#   - valid forward-shape registry (R98 bucket placement)
#   - duplicate OOF descriptor code rejection
#   - alias collision / missing replacement rejection
#   - PINV-*/TINV-* support marker separation (must not appear in oof_descriptors)
#   - support marker public/emitted rejection
#   - excluded namespace descriptor/alias rejection
#   - oof projection loadable/capability guard
#   - olap/progression guarded non-fragment rejection
#   - absent-owner inactive-row proof (OOF descriptors, fragment rows, support markers)
#   - closed-surface assertions
#
# Authorized write scope: proof-local out/ directory only.
# No compiler, report, public API/CLI, .igapp, or golden mutation.

require "fileutils"
require "json"
require "pathname"

require_relative "../../lib/igniter_lang/oof_fragment_registry"

module OOFFragmentRegistryBoundaryProof
  ROOT         = Pathname.new(File.expand_path("../..", __dir__))
  FIXTURE_DIR  = ROOT / "experiments/oof_fragment_registry_implementation_boundary_proof/fixtures"
  OUT_DIR      = ROOT / "experiments/oof_fragment_registry_implementation_boundary_proof/out"
  SUMMARY_PATH = OUT_DIR / "oof_fragment_registry_implementation_boundary_proof_summary.json"

  FORMAT_VERSION = "0.1.0".freeze

  module_function

  # ---------------------------------------------------------------------------
  # Helpers
  # ---------------------------------------------------------------------------

  def assert_pass(name, &block)
    detail = block.call
    { "check" => name, "result" => "PASS", "detail" => detail.to_s }
  rescue => e
    raise "FAIL [#{name}]: #{e.message}"
  end

  def assert_property(name, cond, msg = "assertion failed")
    raise "FAIL [#{name}]: #{msg}" unless cond
    { "check" => name, "result" => "PASS" }
  end

  def v
    @validator ||= IgniterLang::OOFFragmentRegistry.new
  end

  def load_fixture(filename)
    JSON.parse(File.read(FIXTURE_DIR / filename, encoding: "utf-8"))
  end

  def diag_codes(result)
    result.fetch("diagnostics", []).map { |d| d["code"] }
  end

  def has_diag?(result, code)
    diag_codes(result).include?(code)
  end

  # Minimal valid base registry builder for mutation tests.
  def base_registry
    load_fixture("forward_shape_valid.json")
  end

  # Deep-clone a hash via JSON round-trip (avoids shared mutation).
  def clone(hash)
    JSON.parse(JSON.generate(hash))
  end

  # ---------------------------------------------------------------------------
  # Forward-shape valid fixture
  # ---------------------------------------------------------------------------

  def run_valid_fixture_checks
    results = []

    # V1: Valid forward-shape registry passes validation
    results << assert_pass("V1.valid_forward_shape_passes") do
      reg = base_registry
      result = v.validate(reg)
      raise "valid=#{result["valid"].inspect}, diags=#{diag_codes(result).inspect}" \
        unless result["valid"] == true
      raise "unexpected inactive_rows" unless result["inactive_rows"].empty?
      "valid=true, inactive_rows=0 [ok]"
    end

    # V2: Result has required internal shape fields
    results << assert_pass("V2.result_shape_fields_present") do
      result = v.validate(base_registry)
      required = %w[kind format_version valid registry_service_present
                    checked_sections diagnostics inactive_rows closed_surface_assertions]
      missing = required.reject { |k| result.key?(k) }
      raise "missing result fields: #{missing.inspect}" unless missing.empty?
      raise "registry_service_present must be true" unless result["registry_service_present"]
      "all required result fields present [ok]"
    end

    # V3: Closed-surface assertions all false
    results << assert_pass("V3.closed_surface_assertions_all_false") do
      result = v.validate(base_registry)
      csa = result.fetch("closed_surface_assertions")
      failures = csa.select { |_k, v| v != false }
      raise "unexpected closed surface assertions: #{failures.inspect}" unless failures.empty?
      "all closed_surface_assertions: false [ok]"
    end

    # V4: PINV/TINV are NOT in oof_descriptors (R98 forward shape)
    results << assert_pass("V4.pinv_tinv_not_in_oof_descriptors") do
      reg = base_registry
      oof_codes = reg.fetch("oof_descriptors").map { |d| d["code"] }
      pinv_tinv_in_oof = oof_codes.select { |c| c&.match?(/\A(PINV|TINV)-/) }
      raise "found PINV/TINV codes in oof_descriptors: #{pinv_tinv_in_oof.inspect}" \
        unless pinv_tinv_in_oof.empty?
      "PINV/TINV absent from oof_descriptors [ok]"
    end

    # V5: PINV/TINV are in support_markers.invariant_support_markers
    results << assert_pass("V5.pinv_tinv_in_support_markers_bucket") do
      reg = base_registry
      sm_codes = reg.dig("support_markers", "invariant_support_markers").map { |m| m["code"] }
      pinv_tinv = sm_codes.select { |c| c&.match?(/\A(PINV|TINV)-/) }
      raise "no PINV/TINV codes in invariant_support_markers" if pinv_tinv.empty?
      "PINV/TINV found in invariant_support_markers: #{pinv_tinv.inspect} [ok]"
    end

    results
  end

  # ---------------------------------------------------------------------------
  # Rejection cases
  # ---------------------------------------------------------------------------

  def run_rejection_cases
    results = []

    # R1: Duplicate OOF descriptor code
    results << assert_pass("R1.duplicate_oof_descriptor_code_rejected") do
      reg = clone(base_registry)
      reg["oof_descriptors"] << reg["oof_descriptors"].first.dup
      result = v.validate(reg)
      raise "expected valid=false, got #{result["valid"]}" if result["valid"]
      raise "expected duplicate_code diag" \
        unless has_diag?(result, IgniterLang::OOFFragmentRegistry::DIAG_DUPLICATE_CODE)
      "duplicate code rejected with #{IgniterLang::OOFFragmentRegistry::DIAG_DUPLICATE_CODE} [ok]"
    end

    # R2: Alias collision — two descriptors share the same alias
    results << assert_pass("R2.alias_collision_rejected") do
      reg = clone(base_registry)
      # Add two descriptors that both claim "OOF-SHARED-ALIAS" — must be rejected
      reg["oof_descriptors"] << {
        "code" => "OOF-ALIAS-A",
        "family" => "test",
        "owner_pack_or_boundary" => "CoreLanguagePack",
        "source_stage" => "parser",
        "compiler_layer" => "parser",
        "severity" => "error",
        "status_class" => "blocking_oof",
        "public_code_stability" => "stable_current",
        "message_stability" => "stable_family_message",
        "aliases" => ["OOF-SHARED-ALIAS"],
        "deprecated" => false,
        "deprecated_by" => nil,
        "replacement_code" => nil,
        "source_refs" => [],
        "current_status" => "current",
        "non_authority_notes" => ""
      }
      reg["oof_descriptors"] << {
        "code" => "OOF-ALIAS-B",
        "family" => "test",
        "owner_pack_or_boundary" => "CoreLanguagePack",
        "source_stage" => "parser",
        "compiler_layer" => "parser",
        "severity" => "error",
        "status_class" => "blocking_oof",
        "public_code_stability" => "stable_current",
        "message_stability" => "stable_family_message",
        "aliases" => ["OOF-SHARED-ALIAS"],  # same alias — collision
        "deprecated" => false,
        "deprecated_by" => nil,
        "replacement_code" => nil,
        "source_refs" => [],
        "current_status" => "current",
        "non_authority_notes" => ""
      }
      result = v.validate(reg)
      raise "expected valid=false, got #{result["valid"]}" if result["valid"]
      raise "expected alias_collision diag" \
        unless has_diag?(result, IgniterLang::OOFFragmentRegistry::DIAG_ALIAS_COLLISION)
      "alias cross-collision rejected with #{IgniterLang::OOFFragmentRegistry::DIAG_ALIAS_COLLISION} [ok]"
    end

    # R3: Deprecated descriptor without replacement
    results << assert_pass("R3.deprecated_without_replacement_rejected") do
      reg = clone(base_registry)
      reg["oof_descriptors"] << {
        "code" => "OOF-DEP-TEST",
        "family" => "test",
        "owner_pack_or_boundary" => "CoreLanguagePack",
        "source_stage" => "parser",
        "compiler_layer" => "parser",
        "severity" => "error",
        "status_class" => "compatibility_alias",
        "public_code_stability" => "stable_compatibility_alias",
        "message_stability" => "stable_family_message",
        "aliases" => [],
        "deprecated" => true,
        "deprecated_by" => nil,
        "replacement_code" => nil,
        "source_refs" => [],
        "current_status" => "compatibility_alias",
        "non_authority_notes" => ""
      }
      result = v.validate(reg)
      raise "expected valid=false" if result["valid"]
      raise "expected alias_missing_replacement diag" \
        unless has_diag?(result, IgniterLang::OOFFragmentRegistry::DIAG_ALIAS_MISSING_REPLACEMENT)
      "deprecated without replacement rejected [ok]"
    end

    # R4: PINV in oof_descriptors is rejected
    results << assert_pass("R4.pinv_in_oof_descriptors_rejected") do
      reg = clone(base_registry)
      reg["oof_descriptors"] << {
        "code" => "PINV-99",
        "family" => "invariant_parser_proof",
        "owner_pack_or_boundary" => "InvariantPack",
        "source_stage" => "parser",
        "compiler_layer" => "parser",
        "severity" => "proof_marker",
        "status_class" => "proof_marker",
        "public_code_stability" => "proof_only",
        "message_stability" => "stable_family_message",
        "aliases" => [],
        "deprecated" => false,
        "deprecated_by" => nil,
        "replacement_code" => nil,
        "source_refs" => [],
        "current_status" => "candidate",
        "non_authority_notes" => "PINV placed in oof_descriptors — must be rejected"
      }
      result = v.validate(reg)
      raise "expected valid=false, got #{result["valid"]}" if result["valid"]
      raise "expected support_marker_in_oof_descriptors diag" \
        unless has_diag?(result, IgniterLang::OOFFragmentRegistry::DIAG_SUPPORT_MARKER_IN_DESCRIPTORS)
      "PINV in oof_descriptors rejected with #{IgniterLang::OOFFragmentRegistry::DIAG_SUPPORT_MARKER_IN_DESCRIPTORS} [ok]"
    end

    # R5: TINV in oof_descriptors is rejected
    results << assert_pass("R5.tinv_in_oof_descriptors_rejected") do
      reg = clone(base_registry)
      reg["oof_descriptors"] << {
        "code" => "TINV-99",
        "family" => "invariant_type_proof",
        "owner_pack_or_boundary" => "InvariantPack",
        "source_stage" => "typechecker",
        "compiler_layer" => "typechecker",
        "severity" => "proof_marker",
        "status_class" => "proof_marker",
        "public_code_stability" => "proof_only",
        "message_stability" => "stable_family_message",
        "aliases" => [],
        "deprecated" => false,
        "deprecated_by" => nil,
        "replacement_code" => nil,
        "source_refs" => [],
        "current_status" => "candidate",
        "non_authority_notes" => "TINV in oof_descriptors — must be rejected"
      }
      result = v.validate(reg)
      raise "expected valid=false" if result["valid"]
      raise "expected support_marker_in_oof_descriptors diag" \
        unless has_diag?(result, IgniterLang::OOFFragmentRegistry::DIAG_SUPPORT_MARKER_IN_DESCRIPTORS)
      "TINV in oof_descriptors rejected [ok]"
    end

    # R6: Support marker with public stability rejected
    results << assert_pass("R6.support_marker_public_stability_rejected") do
      reg = clone(base_registry)
      reg["support_markers"]["invariant_support_markers"] << {
        "code" => "PINV-PUBLIC-TEST",
        "family" => "invariant_parser_support",
        "owner_pack_or_boundary" => "InvariantPack",
        "source_stage" => "parser",
        "compiler_layer" => "parser",
        "lifecycle_state" => "support_metadata_current",
        "public_code_stability" => "stable_current",  # must be rejected — public stability
        "related_oof_descriptors" => [],
        "source_refs" => [],
        "non_authority_notes" => "invalid public stability on support marker"
      }
      result = v.validate(reg)
      raise "expected valid=false" if result["valid"]
      raise "expected support_marker_public diag" \
        unless has_diag?(result, IgniterLang::OOFFragmentRegistry::DIAG_SUPPORT_MARKER_PUBLIC)
      "support marker with public stability rejected [ok]"
    end

    # R7: Support marker code collision with OOF code rejected
    results << assert_pass("R7.support_marker_code_collision_rejected") do
      reg = clone(base_registry)
      reg["support_markers"]["invariant_support_markers"] << {
        "code" => "OOF-IV1",  # collides with canonical OOF descriptor code
        "family" => "invariant_parser_support",
        "owner_pack_or_boundary" => "InvariantPack",
        "source_stage" => "parser",
        "compiler_layer" => "parser",
        "lifecycle_state" => "support_metadata_current",
        "public_code_stability" => "non_public_support_marker",
        "related_oof_descriptors" => [],
        "source_refs" => [],
        "non_authority_notes" => "code collision test"
      }
      result = v.validate(reg)
      raise "expected valid=false" if result["valid"]
      raise "expected support_marker_code_collision diag" \
        unless has_diag?(result, IgniterLang::OOFFragmentRegistry::DIAG_SUPPORT_MARKER_CODE_COLLISION)
      "support marker code collision rejected [ok]"
    end

    # R8: Excluded namespace descriptor rejected
    results << assert_pass("R8.excluded_namespace_descriptor_rejected") do
      reg = clone(base_registry)
      reg["oof_descriptors"] << {
        "code" => "compiler_profile_contract.validation.missing_field",
        "family" => "contract_profile",
        "owner_pack_or_boundary" => "CompilerProfileContractPack",
        "source_stage" => "proof_only",
        "compiler_layer" => "proof_only",
        "severity" => "error",
        "status_class" => "candidate_oof",
        "public_code_stability" => "candidate_proof_only",
        "message_stability" => "stable_family_message",
        "aliases" => [],
        "deprecated" => false,
        "deprecated_by" => nil,
        "replacement_code" => nil,
        "source_refs" => [],
        "current_status" => "candidate",
        "non_authority_notes" => "excluded namespace test"
      }
      result = v.validate(reg)
      raise "expected valid=false" if result["valid"]
      raise "expected excluded_namespace_collision diag" \
        unless has_diag?(result, IgniterLang::OOFFragmentRegistry::DIAG_EXCLUDED_NAMESPACE_COLLISION)
      "excluded namespace descriptor rejected [ok]"
    end

    # R9: oof fragment row with loadable:true rejected
    results << assert_pass("R9.oof_fragment_loadable_rejected") do
      reg = clone(base_registry)
      oof_row = reg["fragment_rows"].find { |r| r["name"] == "oof" }
      oof_row["loadable"] = true
      result = v.validate(reg)
      raise "expected valid=false" if result["valid"]
      raise "expected oof_projection_loadable diag" \
        unless has_diag?(result, IgniterLang::OOFFragmentRegistry::DIAG_OOF_PROJECTION_LOADABLE)
      "oof loadable=true rejected [ok]"
    end

    # R10: oof fragment row with capability:true rejected
    results << assert_pass("R10.oof_fragment_capability_rejected") do
      reg = clone(base_registry)
      oof_row = reg["fragment_rows"].find { |r| r["name"] == "oof" }
      oof_row["capability"] = true
      result = v.validate(reg)
      raise "expected valid=false" if result["valid"]
      raise "expected oof_projection_capability diag" \
        unless has_diag?(result, IgniterLang::OOFFragmentRegistry::DIAG_OOF_PROJECTION_CAPABILITY)
      "oof capability=true rejected [ok]"
    end

    # R11: olap as fragment class rejected
    results << assert_pass("R11.olap_fragment_class_rejected") do
      reg = clone(base_registry)
      olap_row = reg["fragment_rows"].find { |r| r["name"] == "olap" }
      olap_row["classification_kind"] = "language_fragment"  # must be rejected
      result = v.validate(reg)
      raise "expected valid=false" if result["valid"]
      raise "expected guarded_non_fragment_violation diag" \
        unless has_diag?(result, IgniterLang::OOFFragmentRegistry::DIAG_GUARDED_NON_FRAGMENT)
      "olap as language_fragment rejected [ok]"
    end

    # R12: progression as fragment class rejected
    results << assert_pass("R12.progression_fragment_class_rejected") do
      reg = clone(base_registry)
      prog_row = reg["fragment_rows"].find { |r| r["name"] == "progression" }
      prog_row["classification_kind"] = "language_fragment"  # must be rejected
      result = v.validate(reg)
      raise "expected valid=false" if result["valid"]
      raise "expected guarded_non_fragment_violation diag" \
        unless has_diag?(result, IgniterLang::OOFFragmentRegistry::DIAG_GUARDED_NON_FRAGMENT)
      "progression as language_fragment rejected [ok]"
    end

    # R13: Missing required excluded namespace rejected
    results << assert_pass("R13.missing_required_excluded_namespace_rejected") do
      reg = clone(base_registry)
      reg["excluded_namespaces"] = []  # remove all — required prefixes now absent
      result = v.validate(reg)
      raise "expected valid=false" if result["valid"]
      raise "expected missing_section diag for excluded namespace" \
        unless has_diag?(result, IgniterLang::OOFFragmentRegistry::DIAG_MISSING_SECTION)
      "missing required excluded namespace rejected [ok]"
    end

    results
  end

  # ---------------------------------------------------------------------------
  # Absent-owner inactive-row proof
  # ---------------------------------------------------------------------------

  def run_inactive_row_cases
    results = []

    # INV-ABS1: Absent-owner rows recorded as inactive (not silently skipped)
    results << assert_pass("INV-ABS1.absent_owner_rows_recorded_as_inactive") do
      installed = ["CoreLanguagePack", "InvariantPack"]
      reg = {
        "kind"           => "oof_fragment_registry",
        "format_version" => "0.1.0",
        "source_authority" => {},
        "oof_descriptors" => [
          {
            "code" => "OOF-SYN1",
            "family" => "synthetic",
            "owner_pack_or_boundary" => "SyntheticAbsentPack",  # NOT in installed_boundaries
            "source_stage" => "parser",
            "compiler_layer" => "parser",
            "severity" => "error",
            "status_class" => "blocking_oof",
            "public_code_stability" => "stable_current",
            "message_stability" => "stable_family_message",
            "aliases" => [],
            "deprecated" => false,
            "deprecated_by" => nil,
            "replacement_code" => nil,
            "source_refs" => [],
            "current_status" => "current",
            "non_authority_notes" => ""
          }
        ],
        "fragment_rows" => [
          {
            "name" => "synthetic_absent_fragment",
            "owner_pack_or_boundary" => "SyntheticAbsentPack",
            "current_or_candidate" => "current",
            "applies_to" => ["contract"],
            "classification_kind" => "language_fragment",
            "value_flow_notes" => "",
            "precedence_candidate" => 50,
            "canonical_status" => "non_canon_candidate",
            "loadable" => true,
            "capability" => true,
            "non_authority_notes" => ""
          },
          {
            "name" => "oof",
            "owner_pack_or_boundary" => "CoreLanguagePack",  # INSTALLED
            "current_or_candidate" => "current",
            "applies_to" => ["contract", "node", "report_status"],
            "classification_kind" => "status_fragment_both_candidate",
            "value_flow_notes" => "",
            "precedence_candidate" => 100,
            "canonical_status" => "non_canon_candidate",
            "loadable" => false,
            "capability" => false,
            "non_authority_notes" => ""
          }
        ],
        "support_markers" => {
          "invariant_support_markers" => [
            {
              "code" => "PINV-SYN",
              "family" => "invariant_parser_support",
              "owner_pack_or_boundary" => "SyntheticAbsentPack",  # NOT installed
              "source_stage" => "parser",
              "compiler_layer" => "parser",
              "lifecycle_state" => "support_metadata_current",
              "public_code_stability" => "non_public_support_marker",
              "related_oof_descriptors" => [],
              "source_refs" => [],
              "non_authority_notes" => "absent owner inactive test"
            }
          ]
        },
        "excluded_namespaces" => [
          { "prefix" => "compiler_profile_contract.", "reason" => "excluded", "forbidden_as" => ["oof_descriptor"], "owner_boundary" => "CompilerProfileContractPack" },
          { "prefix" => "compiler_profile_contract_refusal.", "reason" => "excluded", "forbidden_as" => ["oof_descriptor"], "owner_boundary" => "CompilerProfileContractPack" }
        ]
      }

      result = v.validate(reg, installed_boundaries: installed)

      inactive = result.fetch("inactive_rows")
      raise "expected 3 inactive rows (OOF-SYN1, synthetic_absent_fragment, PINV-SYN), got #{inactive.size}" \
        unless inactive.size == 3

      # All inactive rows reference SyntheticAbsentPack
      bad = inactive.reject { |r| r["owner"] == "SyntheticAbsentPack" }
      raise "some inactive rows have wrong owner: #{bad.inspect}" unless bad.empty?

      # Inactive rows are NOT silently skipped — they are present with correct reason
      reasons = inactive.map { |r| r["reason"] }.uniq
      raise "expected owner_boundary_absent reason" \
        unless reasons == ["owner_pack_or_boundary_absent_from_installed_boundaries"]

      # valid should still be true (structural shape is valid, just some rows inactive)
      raise "expected valid=true for absent-owner (shape is valid)" unless result["valid"]

      sections = inactive.map { |r| r["section"] }.sort
      raise "expected sections oof_descriptor, fragment_row, support_marker" \
        unless sections == %w[fragment_row oof_descriptor support_marker]

      "3 inactive rows recorded for SyntheticAbsentPack (oof_descriptor, fragment_row, support_marker) [ok]"
    end

    # INV-ABS2: Inactive rows are NOT emitted (closed_surface_assertions remain false)
    results << assert_pass("INV-ABS2.inactive_rows_not_emitted") do
      installed = ["CoreLanguagePack"]
      reg = clone(base_registry)
      result = v.validate(reg, installed_boundaries: installed)
      csa = result.fetch("closed_surface_assertions")
      failures = csa.select { |_k, v| v != false }
      raise "closed_surface_assertions flipped: #{failures.inspect}" unless failures.empty?
      inactive = result.fetch("inactive_rows")
      "inactive_rows=#{inactive.size}, closed_surface_assertions all false [ok]"
    end

    # INV-ABS3: No installed_boundaries → all rows active (no inactive rows reported)
    results << assert_pass("INV-ABS3.no_boundary_check_without_installed_boundaries") do
      result = v.validate(base_registry)  # no installed_boundaries
      raise "expected empty inactive_rows" unless result.fetch("inactive_rows").empty?
      "inactive_rows empty when installed_boundaries not supplied [ok]"
    end

    results
  end

  # ---------------------------------------------------------------------------
  # Closed-surface assertions
  # ---------------------------------------------------------------------------

  def run_closed_surface_assertions
    results = []

    # CS1: Validator does not require lib/igniter_lang.rb
    results << assert_pass("CS1.validator_not_in_igniter_lang_rb") do
      main_lib = ROOT / "lib/igniter_lang.rb"
      if main_lib.exist?
        content = File.read(main_lib, encoding: "utf-8")
        if content.include?("oof_fragment_registry")
          raise "lib/igniter_lang.rb requires oof_fragment_registry — must not be required from public entrypoint"
        end
      end
      "lib/igniter_lang.rb does not require oof_fragment_registry [ok]"
    end

    # CS2: Validator class does not define compiler pass methods
    results << assert_pass("CS2.validator_no_compiler_pass_methods") do
      forbidden = %i[classify typecheck emit parse assemble compile orchestrate]
      found = forbidden.select do |m|
        IgniterLang::OOFFragmentRegistry.method_defined?(m) ||
          IgniterLang::OOFFragmentRegistry.private_method_defined?(m)
      end
      raise "compiler pass methods found in validator: #{found.inspect}" unless found.empty?
      "no compiler pass methods in OOFFragmentRegistry [ok]"
    end

    # CS3: Validation result has no report/CompilerResult/public fields
    results << assert_pass("CS3.result_has_no_public_fields") do
      result = v.validate(base_registry)
      forbidden_keys = %w[
        report compilation_report compiler_result diagnostics_path
        igapp_path public_diagnostics compat_report loader_status
      ]
      found = forbidden_keys.select { |k| result.key?(k) }
      raise "public/report fields found in result: #{found.inspect}" unless found.empty?
      "result contains no public/report/CompilerResult fields [ok]"
    end

    # CS4: oof_fragment_registry_data.rb does not exist (explicitly out of first slice)
    results << assert_pass("CS4.data_file_does_not_exist") do
      data_file = ROOT / "lib/igniter_lang/oof_fragment_registry_data.rb"
      if data_file.exist?
        raise "lib/igniter_lang/oof_fragment_registry_data.rb exists — explicitly out of first slice"
      end
      "lib/igniter_lang/oof_fragment_registry_data.rb does not exist [ok]"
    end

    # CS5: R92 historical JSON is present and unchanged (non-migration policy)
    results << assert_pass("CS5.r92_historical_json_not_migrated") do
      r92_json = ROOT / "experiments/oof_fragment_registry_shadow_proof/out/oof_descriptors.shadow_registry.json"
      unless r92_json.exist?
        raise "R92 historical JSON not found at #{r92_json.relative_path_from(ROOT)}"
      end
      r92_data = JSON.parse(File.read(r92_json, encoding: "utf-8"))
      # R92 has PINV/TINV in descriptors (historical placement)
      r92_pinv = r92_data.fetch("descriptors", []).map { |d| d["code"] }.select { |c| c&.match?(/\A(PINV|TINV)-/) }
      raise "R92 historical JSON lost its PINV/TINV descriptors — was it mutated?" if r92_pinv.empty?
      # Our forward fixture has PINV/TINV in support_markers, not oof_descriptors
      fwd = JSON.parse(File.read(FIXTURE_DIR / "forward_shape_valid.json", encoding: "utf-8"))
      fwd_oof_pinv = fwd.fetch("oof_descriptors").map { |d| d["code"] }.select { |c| c&.match?(/\A(PINV|TINV)-/) }
      raise "forward fixture still has PINV/TINV in oof_descriptors" unless fwd_oof_pinv.empty?
      "R92 historical JSON retained unchanged (#{r92_pinv.size} PINV/TINV in oof_descriptors); " \
        "forward fixture has 0 PINV/TINV in oof_descriptors [ok]"
    end

    # CS6: Validator exposes no public diagnostic API/CLI output method
    results << assert_pass("CS6.validator_no_public_cli_methods") do
      forbidden = %i[emit_diagnostics report write_report cli run_cli main]
      found = forbidden.select do |m|
        IgniterLang::OOFFragmentRegistry.method_defined?(m)
      end
      raise "public CLI/diagnostic methods found: #{found.inspect}" unless found.empty?
      "no public CLI/diagnostic output methods in OOFFragmentRegistry [ok]"
    end

    results
  end

  # ---------------------------------------------------------------------------
  # Runner
  # ---------------------------------------------------------------------------

  def run
    FileUtils.mkdir_p(OUT_DIR)

    valid_results    = run_valid_fixture_checks
    reject_results   = run_rejection_cases
    inactive_results = run_inactive_row_cases
    closed_results   = run_closed_surface_assertions

    all_results = valid_results + reject_results + inactive_results + closed_results

    pass_count = all_results.count { |r| r["result"] == "PASS" }
    fail_count = all_results.count { |r| r["result"] != "PASS" }
    status     = fail_count.zero? ? "PASS" : "FAIL"

    summary = {
      "kind"           => "oof_fragment_registry_implementation_boundary_proof_summary",
      "format_version" => FORMAT_VERSION,
      "track"          => "oof-fragment-registry-implementation-boundary-proof-v0",
      "card"           => "LANG-R103-I",
      "status"         => status,
      "pass_count"     => pass_count,
      "fail_count"     => fail_count,
      "checks"         => all_results,
      "closed_surface_assertions" => {
        "compiler_integration"          => false,
        "public_api_cli"                => false,
        "top_level_report_diagnostics"  => false,
        "compiler_result_field"         => false,
        "loader_report"                 => false,
        "compatibility_report"          => false,
        "runtime_behavior"              => false,
        "igapp_mutation"                => false
      },
      "r92_non_migration_note" => (
        "R92 historical JSON (experiments/oof_fragment_registry_shadow_proof/out/" \
        "oof_descriptors.shadow_registry.json) placed PINV-*/TINV-* in oof_descriptors " \
        "as historical proof evidence. That placement is NON-FORWARD. " \
        "This proof does not migrate it. The forward shape (LANG-R98-A + LANG-R101-D1) " \
        "places PINV-*/TINV-* exclusively under support_markers.invariant_support_markers."
      )
    }

    File.write(SUMMARY_PATH, JSON.pretty_generate(summary) + "\n")

    puts "OOFFragmentRegistryBoundaryProof: #{status}"
    puts "  #{pass_count}/#{pass_count + fail_count} checks PASS"
    all_results.each { |r| puts "  #{r["result"].ljust(4)} #{r["check"]}" }
    puts "Summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"

    status == "PASS"
  end
end

exit(OOFFragmentRegistryBoundaryProof.run ? 0 : 1)
