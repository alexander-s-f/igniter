#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "pathname"

module CompilerPackShadowProfileProof
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  OUT_DIR = ROOT / "igniter-lang/experiments/compiler_pack_shadow_profile_proof/out"
  SUMMARY_PATH = OUT_DIR / "compiler_pack_shadow_profile_proof_summary.json"

  FORMAT_VERSION = "0.1.0"
  TRACK = "compiler-pack-shadow-profile-proof-v0"

  PACKS = [
    {
      "name" => "CoreLanguagePack",
      "implementation_id" => "core_language.proof_compiler_adapter.v0",
      "status" => "current_surface_shadow",
      "requires_packs" => [],
      "provides_capabilities" => %w[core_language core_fragment core_type_refs core_semanticir],
      "parser_rules" => %w[
        module_decl type_decl trait_decl impl_decl contract_shape_decl contract_decl
        input_decl compute_decl output_decl literals refs field_access core_calls core_operators
      ],
      "classifier_rules" => %w[core_symbols dependency_graph unresolved_symbol core_fragment_default],
      "type_rules" => %w[primitive_type_ir expression_inference output_typecheck typed_core_nodes],
      "semanticir_handlers" => %w[contract_ir compute_node output_node compilation_report],
      "assembler_hooks" => %w[base_igapp_layout manifest semantic_ir_program compilation_report requirements core_contract_file],
      "fragment_classes" => ["core"],
      "oof_codes" => %w[OOF-P0 OOF-P1 OOF-P2 OOF-TY0 OOF-DM3]
    },
    {
      "name" => "OOFRegistry",
      "implementation_id" => "oof_registry.shadow_descriptor_registry.v0",
      "status" => "kernel_service_candidate",
      "requires_packs" => [],
      "provides_capabilities" => %w[oof_registry oof_descriptor_lookup oof_stage_ownership],
      "parser_rules" => [],
      "classifier_rules" => %w[oof_descriptor_registration],
      "type_rules" => %w[oof_alias_registration],
      "semanticir_handlers" => %w[oof_report_diagnostics],
      "assembler_hooks" => %w[oof_manifest_metadata_deferred],
      "fragment_classes" => ["oof"],
      "oof_codes" => []
    },
    {
      "name" => "FragmentRegistry",
      "implementation_id" => "fragment_registry.shadow_precedence_registry.v0",
      "status" => "kernel_service_candidate",
      "requires_packs" => [],
      "provides_capabilities" => %w[fragment_registry fragment_precedence],
      "parser_rules" => [],
      "classifier_rules" => %w[contract_fragment_precedence node_value_fragment_split],
      "type_rules" => %w[fragment_validation],
      "semanticir_handlers" => %w[fragment_passthrough],
      "assembler_hooks" => %w[fragment_summary max_fragment_class],
      "fragment_classes" => %w[core escape stream temporal epistemic oof],
      "oof_codes" => []
    },
    {
      "name" => "EscapeBoundaryPack",
      "implementation_id" => "escape_boundary.current_monolith_adapter.v0",
      "status" => "current_surface_shadow",
      "requires_packs" => %w[CoreLanguagePack OOFRegistry FragmentRegistry],
      "provides_capabilities" => %w[escape_boundary read_surface escape_fragment],
      "parser_rules" => %w[escape_decl read_decl lifecycle scoped_by cardinality schema_version tenant_free],
      "classifier_rules" => %w[escape_decl_classification non_temporal_read_classification],
      "type_rules" => %w[read_metadata_passthrough escape_boundary_validation],
      "semanticir_handlers" => %w[escape_boundaries],
      "assembler_hooks" => %w[requirements_from_escape_boundaries capability_effect_summary],
      "fragment_classes" => ["escape"],
      "oof_codes" => []
    },
    {
      "name" => "TemporalPack",
      "implementation_id" => "temporal.metadata_only_guarded.v0",
      "status" => "current_surface_shadow",
      "requires_packs" => %w[CoreLanguagePack EscapeBoundaryPack OOFRegistry FragmentRegistry],
      "provides_capabilities" => %w[temporal history_read bihistory_read temporal_access_node],
      "parser_rules" => %w[History_type_ref BiHistory_type_ref coordinate_syntax_deferred],
      "classifier_rules" => %w[temporal_read_detection temporal_value_core_split temporal_capability_selection],
      "type_rules" => %w[history_at bihistory_at temporal_axis_validation temporal_coordinate_refs],
      "semanticir_handlers" => %w[temporal_input_node temporal_access_node temporal_escape_boundaries],
      "assembler_hooks" => %w[temporal_contract_index temporal_nodes temporal_requirements temporal_guard_metadata],
      "fragment_classes" => ["temporal"],
      "oof_codes" => %w[
        OOF-H1 OOF-H2 OOF-H3 OOF-H4
        OOF-BT1 OOF-BT2 OOF-BT3 OOF-BT4
        OOF-TM1 OOF-TM3 OOF-TM4 OOF-TM5 OOF-TM6
      ]
    },
    {
      "name" => "StreamPack",
      "implementation_id" => "stream.current_monolith_adapter.v0",
      "status" => "current_surface_shadow",
      "requires_packs" => %w[CoreLanguagePack EscapeBoundaryPack OOFRegistry FragmentRegistry],
      "provides_capabilities" => %w[stream stream_input stream_window fold_stream],
      "parser_rules" => %w[stream_decl window_decl fold_stream_decl window_bounded count_bounded],
      "classifier_rules" => %w[stream_ingress fold_stream_tracking direct_stream_use missing_window],
      "type_rules" => %w[fold_stream_core_body fold_stream_result_type],
      "semanticir_handlers" => %w[stream_input_node window_decl_node fold_stream_node],
      "assembler_hooks" => %w[stream_nodes stream_requirements stream_window_requirements],
      "fragment_classes" => ["stream"],
      "oof_codes" => %w[OOF-S1 OOF-S2 OOF-S3 OOF-S4 OOF-S5]
    },
    {
      "name" => "OLAPPack",
      "implementation_id" => "olap.current_monolith_adapter.v0",
      "status" => "current_surface_shadow",
      "requires_packs" => %w[CoreLanguagePack OOFRegistry FragmentRegistry],
      "provides_capabilities" => %w[olap_point olap_type_ref olap_access],
      "parser_rules" => %w[olap_point_decl OLAPPoint_type_ref dims_record slice_record],
      "classifier_rules" => %w[olap_symbol_registration],
      "type_rules" => %w[olap_env olap_declaration_validation olap_slice_type olap_rollup_type],
      "semanticir_handlers" => %w[olap_point_decl olap_access_node],
      "assembler_hooks" => %w[olap_requirements_deferred],
      "fragment_classes" => [],
      "oof_codes" => %w[OOF-O1 OOF-O2 OOF-O3 OOF-O4 OOF-O5]
    },
    {
      "name" => "InvariantPack",
      "implementation_id" => "invariant.current_monolith_adapter.v0",
      "status" => "current_surface_shadow",
      "requires_packs" => %w[CoreLanguagePack OOFRegistry FragmentRegistry],
      "provides_capabilities" => %w[invariant invariant_severity invariant_coverage],
      "parser_rules" => %w[invariant_decl predicate severity label message overridable_with],
      "classifier_rules" => %w[invariant_dependency_refs invariant_author_fields invariant_source_metadata],
      "type_rules" => %w[invariant_predicate_bool invariant_output_effect invariant_output_propagation],
      "semanticir_handlers" => %w[invariant_node invariant_coverage],
      "assembler_hooks" => %w[invariant_report_metadata_deferred],
      "fragment_classes" => [],
      "oof_codes" => %w[OOF-IV1 OOF-IV2 OOF-IV3 OOF-I1 OOF-I2 OOF-I3 OOF-I4 OOF-I5]
    },
    {
      "name" => "ContractModifiersPack",
      "implementation_id" => "contract_modifiers.current_monolith_adapter.v0",
      "status" => "current_surface_shadow",
      "requires_packs" => %w[CoreLanguagePack EscapeBoundaryPack OOFRegistry FragmentRegistry],
      "provides_capabilities" => %w[contract_modifiers modifier_fragment_widening],
      "parser_rules" => %w[pure observed effect privileged irreversible],
      "classifier_rules" => %w[modifier_passthrough modifier_fragment_mapping pure_escape_oof],
      "type_rules" => %w[modifier_oof_propagation modifier_typed_passthrough],
      "semanticir_handlers" => %w[contract_ir_modifier],
      "assembler_hooks" => %w[manifest_modifier_passthrough],
      "fragment_classes" => [],
      "oof_codes" => %w[OOF-M1]
    },
    {
      "name" => "AssumptionsPack",
      "implementation_id" => "assumptions.spec_shadow.v0",
      "status" => "proposed_shadow_only",
      "requires_packs" => %w[CoreLanguagePack ContractModifiersPack OOFRegistry FragmentRegistry],
      "provides_capabilities" => %w[assumptions epistemic_fragment assumption_refs],
      "parser_rules" => %w[assumptions_block assumption_decl uses_assumptions output_evidence_refs_deferred],
      "classifier_rules" => %w[assumption_registry assumption_refs uses_assumptions_epistemic undeclared_assumption_oof],
      "type_rules" => %w[assumption_strength_range oof_a1_propagation],
      "semanticir_handlers" => %w[assumption_registry assumption_refs],
      "assembler_hooks" => %w[assumption_receipt_metadata_deferred],
      "fragment_classes" => ["epistemic"],
      "oof_codes" => %w[OOF-A1]
    },
    {
      "name" => "EvidenceObservationPack",
      "implementation_id" => "evidence_observation.current_monolith_adapter.v0",
      "status" => "current_surface_shadow",
      "requires_packs" => %w[CoreLanguagePack OOFRegistry FragmentRegistry],
      "provides_capabilities" => %w[evidence_observation confidence_label_checks],
      "parser_rules" => [],
      "classifier_rules" => %w[confidence_as_bool_oof evidence_linked_alert_gate],
      "type_rules" => %w[evidence_alert_validation],
      "semanticir_handlers" => %w[evidence_diagnostics],
      "assembler_hooks" => %w[observation_metadata_deferred],
      "fragment_classes" => [],
      "oof_codes" => %w[OOF-CE4 OOF-OS2 OOF-OS4]
    },
    {
      "name" => "PipelinePack",
      "implementation_id" => "pipeline.current_parser_surface_shadow.v0",
      "status" => "current_surface_shadow",
      "requires_packs" => %w[CoreLanguagePack OOFRegistry FragmentRegistry],
      "provides_capabilities" => %w[pipeline_surface],
      "parser_rules" => %w[pipeline_decl step_decl scoped_by_gate tenant_free_gate],
      "classifier_rules" => %w[pipeline_symbol_registration_deferred],
      "type_rules" => %w[pipeline_flow_typecheck_deferred],
      "semanticir_handlers" => %w[pipeline_ir_deferred],
      "assembler_hooks" => %w[pipeline_manifest_deferred],
      "fragment_classes" => [],
      "oof_codes" => %w[OOF-PG1 OOF-PG2 OOF-PG3 OOF-PG5]
    }
  ].freeze

  REQUIRED_OOF_CODES = %w[
    OOF-P0 OOF-P1 OOF-P2 OOF-TY0 OOF-DM3
    OOF-PG1 OOF-PG2 OOF-PG3 OOF-PG5
    OOF-H1 OOF-BT1 OOF-BT2 OOF-BT3 OOF-BT4 OOF-TM1 OOF-TM3 OOF-TM4 OOF-TM5 OOF-TM6
    OOF-S1 OOF-S2 OOF-S3 OOF-S4 OOF-S5
    OOF-O1 OOF-O2 OOF-O3 OOF-O4 OOF-O5
    OOF-IV1 OOF-IV2 OOF-IV3 OOF-I4
    OOF-M1 OOF-A1 OOF-CE4 OOF-OS2 OOF-OS4
  ].freeze

  REQUIRED_FRAGMENT_CLASSES = %w[core escape stream temporal epistemic oof].freeze

  module_function

  def run
    FileUtils.mkdir_p(OUT_DIR)
    profile = build_profile
    checks = build_checks(profile)
    summary = {
      "kind" => "compiler_pack_shadow_profile_proof_summary",
      "format_version" => FORMAT_VERSION,
      "track" => TRACK,
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "profile" => profile,
      "checks" => checks,
      "evidence_summary" => evidence_summary(profile),
      "next_recommended_slice" => "contract-modifiers-pack-native-boundary-v0"
    }
    write_json(SUMMARY_PATH, summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def build_profile
    profile = {
      "kind" => "compiler_profile_shadow",
      "format_version" => FORMAT_VERSION,
      "track" => TRACK,
      "dispatch_mode" => "shadow_no_dispatch",
      "compiler_pipeline" => "current_monolithic_parser_classifier_typechecker_emit_typed_assembler",
      "igapp_manifest_changes" => [],
      "compiler_profile_id_in_igapp" => "deferred_until_manifest_prop",
      "packs" => PACKS,
      "fragment_registry" => fragment_registry,
      "oof_registry" => oof_registry,
      "assembler_contract" => {
        "semantic_ir_shape" => "unchanged",
        "compilation_report_shape" => "unchanged",
        "igapp_shape" => "unchanged",
        "artifact_hooks_are_descriptive_only" => true
      },
      "recommended_first_real_pack" => "ContractModifiersPack",
      "open_questions" => [
        "Resolve canonical fragment precedence when stream, escape, temporal, and epistemic all coexist.",
        "Decide whether OOFRegistry and FragmentRegistry are packs or kernel services.",
        "Define when compiler_profile_id becomes a required .igapp manifest field.",
        "Define implementation-variant identity semantics in profile fingerprints."
      ]
    }
    profile["profile_id"] = profile_id(profile)
    profile
  end

  def fragment_registry
    {
      "candidate_precedence" => %w[oof temporal stream escape epistemic core],
      "status" => "shadow_candidate_not_authoritative",
      "required_classes" => REQUIRED_FRAGMENT_CLASSES,
      "owners" => REQUIRED_FRAGMENT_CLASSES.to_h do |fragment|
        [fragment, PACKS.select { |pack| pack.fetch("fragment_classes").include?(fragment) }.map { |pack| pack.fetch("name") }]
      end
    }
  end

  def oof_registry
    codes = PACKS.each_with_object({}) do |pack, registry|
      pack.fetch("oof_codes").each do |code|
        registry[code] = {
          "owner_pack" => pack.fetch("name"),
          "implementation_id" => pack.fetch("implementation_id")
        }
      end
    end
    {
      "status" => "shadow_descriptor_registry",
      "codes" => codes.sort.to_h,
      "required_codes" => REQUIRED_OOF_CODES
    }
  end

  def build_checks(profile)
    packs = profile.fetch("packs")
    oof_codes = profile.fetch("oof_registry").fetch("codes")
    fragment_owners = profile.fetch("fragment_registry").fetch("owners")
    {
      "profile.kind" => profile.fetch("kind") == "compiler_profile_shadow",
      "profile.dispatch_mode_shadow" => profile.fetch("dispatch_mode") == "shadow_no_dispatch",
      "profile.id_deterministic" => profile.fetch("profile_id") == profile_id(profile.reject { |key, _| key == "profile_id" }),
      "packs.unique_names" => unique?(packs.map { |pack| pack.fetch("name") }),
      "packs.dependencies_satisfied" => dependencies_satisfied?(packs),
      "packs.implementation_ids_present" => packs.all? { |pack| present?(pack.fetch("implementation_id")) },
      "packs.contract_modifiers_recommended_first" => profile.fetch("recommended_first_real_pack") == "ContractModifiersPack",
      "oof.codes_unique" => unique?(packs.flat_map { |pack| pack.fetch("oof_codes") }),
      "oof.required_codes_owned" => (REQUIRED_OOF_CODES - oof_codes.keys).empty?,
      "fragments.required_classes_owned" => REQUIRED_FRAGMENT_CLASSES.all? { |fragment| fragment_owners.fetch(fragment).any? },
      "fragments.precedence_candidate_complete" => profile.fetch("fragment_registry").fetch("candidate_precedence").sort == REQUIRED_FRAGMENT_CLASSES.sort,
      "igapp.no_manifest_changes" => profile.fetch("igapp_manifest_changes").empty? &&
        profile.fetch("assembler_contract").fetch("igapp_shape") == "unchanged",
      "shadow.no_runtime_authorization" => profile.fetch("packs").none? do |pack|
        pack.fetch("implementation_id").include?("live") || pack.fetch("provides_capabilities").include?("runtime_execution_authorized")
      end
    }
  end

  def evidence_summary(profile)
    {
      "pack_count" => profile.fetch("packs").length,
      "capability_count" => profile.fetch("packs").flat_map { |pack| pack.fetch("provides_capabilities") }.uniq.length,
      "oof_code_count" => profile.fetch("oof_registry").fetch("codes").length,
      "fragment_classes" => profile.fetch("fragment_registry").fetch("required_classes"),
      "igapp_manifest_change" => false,
      "compiler_dispatch_change" => false,
      "native_pack_migration_authorized" => false
    }
  end

  def dependencies_satisfied?(packs)
    names = packs.map { |pack| pack.fetch("name") }
    packs.all? { |pack| (pack.fetch("requires_packs") - names).empty? }
  end

  def unique?(values)
    values.uniq.length == values.length
  end

  def present?(value)
    value.to_s.strip != ""
  end

  def profile_id(profile)
    stable = profile.reject { |key, _| key == "profile_id" }
    "compiler_profile_shadow/sha256:#{Digest::SHA256.hexdigest(canonical_json(stable))[0, 24]}"
  end

  def canonical_json(value)
    JSON.generate(sort_value(value))
  end

  def sort_value(value)
    case value
    when Hash
      value.keys.sort.each_with_object({}) { |key, result| result[key] = sort_value(value.fetch(key)) }
    when Array
      value.map { |item| sort_value(item) }
    else
      value
    end
  end

  def write_json(path, value)
    File.write(path, "#{JSON.pretty_generate(value)}\n")
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} compiler_pack_shadow_profile_proof"
    summary.fetch("checks").each do |label, ok|
      puts "#{label}: #{ok ? "ok" : "FAIL"}"
    end
    puts "profile_id: #{summary.fetch("profile").fetch("profile_id")}"
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = CompilerPackShadowProfileProof.run
exit(success ? 0 : 1)
