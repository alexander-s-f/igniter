#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "open3"
require "pathname"
require "rbconfig"

module IgniterLangSelfAssemblyProfileSketch
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  LANG_ROOT = ROOT / "igniter-lang"
  OUT_DIR = LANG_ROOT / "experiments/igniter_lang_self_assembly_profile_sketch/out"
  MODEL_PATH = OUT_DIR / "igniter_lang_self_assembly_profile_model.json"
  SUMMARY_PATH = OUT_DIR / "igniter_lang_self_assembly_profile_sketch_summary.json"

  PREFLIGHT_RUNNER = LANG_ROOT / "experiments/compiler_profile_preflight_chain_index/compiler_profile_preflight_chain_index.rb"
  PREFLIGHT_SUMMARY = LANG_ROOT / "experiments/compiler_profile_preflight_chain_index/out/compiler_profile_preflight_chain_index_summary.json"
  RECEIPT_STORAGE_RUNNER = LANG_ROOT / "experiments/compilation_receipt_authority_and_storage/compilation_receipt_authority_and_storage.rb"
  RECEIPT_STORAGE_SUMMARY = LANG_ROOT / "experiments/compilation_receipt_authority_and_storage/out/compilation_receipt_authority_and_storage_summary.json"

  FORMAT_VERSION = "0.1.0"
  TRACK = "igniter-lang-self-assembly-profile-sketch-v0"

  module_function

  def run
    FileUtils.mkdir_p(OUT_DIR)
    preflight_run = run_command(PREFLIGHT_RUNNER)
    storage_run = run_command(RECEIPT_STORAGE_RUNNER)
    preflight = read_json(PREFLIGHT_SUMMARY)
    storage = read_json(RECEIPT_STORAGE_SUMMARY)

    model = build_model(preflight, storage)
    variant = build_model(preflight, storage, temporal_impl: "temporal.ledger_backed.future_variant.v0")
    checks = build_checks(model, variant, preflight, storage, preflight_run, storage_run)
    summary = {
      "kind" => "igniter_lang_self_assembly_profile_sketch_summary",
      "format_version" => FORMAT_VERSION,
      "track" => TRACK,
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "model_path" => MODEL_PATH.relative_path_from(ROOT).to_s,
      "self_assembly_profile_id" => model.fetch("self_assembly_profile_id"),
      "checks" => checks,
      "non_goals" => [
        "No self-hosted compiler implementation.",
        "No parser support for profile source syntax.",
        "No CompilerKernel production code.",
        "No .igapp or .ilk format changes.",
        "No runtime execution authority."
      ]
    }

    write_json(MODEL_PATH, model)
    write_json(SUMMARY_PATH, summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def run_command(path)
    stdout, stderr, status = Open3.capture3(RbConfig.ruby, path.to_s, chdir: ROOT.to_s)
    {
      "command" => "ruby #{path.relative_path_from(ROOT)}",
      "exit_status" => status.exitstatus,
      "stdout_first_line" => stdout.lines.first.to_s.strip,
      "stderr" => stderr.strip
    }
  end

  def build_model(preflight, storage, temporal_impl: "temporal.metadata_only.self_assembly.v0")
    profile_source = profile_source_contracts(temporal_impl)
    packs = pack_descriptors(temporal_impl)
    model = {
      "kind" => "igniter_lang_self_assembly_profile_sketch",
      "format_version" => FORMAT_VERSION,
      "track" => TRACK,
      "claim" => "Igniter-Lang can describe the future compiler that understands Igniter-Lang as profile data assembled from capability-owned packs.",
      "bootstrap_trust_boundary" => bootstrap_trust_boundary,
      "profile_source" => profile_source,
      "profile_spec" => profile_spec,
      "pack_descriptors" => packs,
      "assembly_pipeline" => assembly_pipeline(preflight, storage),
      "assembled_profile" => assembled_profile(profile_source, packs),
      "receipt_policy_ref" => storage.fetch("policy_path"),
      "authority" => {
        "self_describing_language_profile" => true,
        "self_hosted_compiler_implementation" => false,
        "bootstrap_seed_eliminated" => false,
        "runtime_execution_authority" => false
      },
      "migration_path" => migration_path
    }
    model.merge("self_assembly_profile_id" => profile_id(model))
  end

  def bootstrap_trust_boundary
    {
      "name" => "BootstrapDescriptorKernel",
      "trusted_seed" => true,
      "responsibilities" => [
        "load profile source descriptors",
        "validate required slots",
        "validate pack dependency graph",
        "validate ordered registries",
        "freeze profile",
        "compute deterministic profile id",
        "emit proof-local receipt"
      ],
      "explicit_non_responsibilities" => [
        "parse the full Igniter-Lang source language",
        "typecheck arbitrary user contracts",
        "execute runtime contracts",
        "authorize Temporal or Ledger reads",
        "erase its own trust base"
      ],
      "why_needed" => "Self-assembly needs an explicit seed; otherwise the profile has no first validator."
    }
  end

  def profile_source_contracts(temporal_impl)
    {
      "kind" => "hypothetical_igniter_lang_profile_source",
      "format_version" => FORMAT_VERSION,
      "pseudo_source" => [
        "profile IgniterLang.Stage3SelfAssemblyProfile {",
        "  slot core: CoreLanguagePack",
        "  slot oof_registry: OOFRegistry",
        "  slot fragment_registry: FragmentRegistry",
        "  slot escape_boundary: EscapeBoundaryPack",
        "  slot contract_modifiers: ContractModifiersPack",
        "  slot temporal: TemporalPack implementation #{temporal_impl}",
        "  slot stream: StreamPack",
        "  slot olap: OLAPPack",
        "  slot invariant: InvariantPack",
        "  slot assumptions: AssumptionsPack",
        "  slot evidence_observation: EvidenceObservationPack",
        "  slot compiler_accountability: CompilationReceiptPack",
        "}"
      ],
      "parser_status" => "not_implemented_descriptor_only",
      "canonical_source_digest" => digest({ "temporal_impl" => temporal_impl })
    }
  end

  def profile_spec
    {
      "kind" => "compiler_profile_spec_candidate",
      "name" => "IgniterLangSelfAssemblyProfileSpec",
      "slot_order" => %w[
        core
        oof_registry
        fragment_registry
        escape_boundary
        contract_modifiers
        temporal
        stream
        olap
        invariant
        assumptions
        evidence_observation
        compiler_accountability
      ],
      "required_slots" => %w[
        core
        oof_registry
        fragment_registry
        escape_boundary
        compiler_accountability
      ],
      "optional_slots" => %w[
        contract_modifiers
        temporal
        stream
        olap
        invariant
        assumptions
        evidence_observation
      ]
    }
  end

  def pack_descriptors(temporal_impl)
    [
      pack("core", "CoreLanguagePack", "core_language.self_assembly.v0", %w[core_language], [], {
        "parser_rules" => %w[core.contract core.input core.output core.compute],
        "classifier_rules" => %w[core.core_fragment_default],
        "typechecker_rules" => %w[core.value_types core.contract_io],
        "semanticir_handlers" => %w[core.contract_node core.compute_node],
        "assembler_hooks" => %w[core.contract_index],
        "fragment_classes" => %w[core]
      }),
      pack("oof_registry", "OOFRegistry", "oof_registry.self_assembly.v0", %w[oof_registry], [], {
        "oof_descriptors" => %w[parser_oof classifier_oof typechecker_oof assembler_oof runtime_oof]
      }),
      pack("fragment_registry", "FragmentRegistry", "fragment_registry.self_assembly.v0", %w[fragment_registry], [], {
        "fragment_classes" => %w[core escape temporal stream oof epistemic]
      }),
      pack("escape_boundary", "EscapeBoundaryPack", "escape_boundary.self_assembly.v0", %w[escape_boundary], %w[core oof_registry fragment_registry], {
        "classifier_rules" => %w[escape.detect_escape_boundary],
        "semanticir_handlers" => %w[escape.escape_boundary_node],
        "assembler_hooks" => %w[escape.requirements_from_boundaries]
      }),
      pack("contract_modifiers", "ContractModifiersPack", "contract_modifiers.self_assembly.v0", %w[contract_modifiers], %w[core], {
        "parser_rules" => %w[contract_modifiers.observe contract_modifiers.assume],
        "classifier_rules" => %w[contract_modifiers.modifier_precedence],
        "typechecker_rules" => %w[contract_modifiers.modifier_allowed_shapes],
        "semanticir_handlers" => %w[contract_modifiers.modifier_metadata]
      }),
      pack("temporal", "TemporalPack", temporal_impl, %w[temporal], %w[core fragment_registry escape_boundary], {
        "parser_rules" => %w[temporal.history_type temporal.bihistory_type],
        "classifier_rules" => %w[temporal.temporal_fragment_precedence],
        "typechecker_rules" => %w[temporal.valid_time_access temporal.bitemporal_access],
        "semanticir_handlers" => %w[temporal.temporal_access_node],
        "assembler_hooks" => %w[temporal.requirements temporal.compatibility_guard]
      }),
      pack("stream", "StreamPack", "stream.metadata_only.self_assembly.v0", %w[stream], %w[core fragment_registry], {
        "parser_rules" => %w[stream.stream_input stream.fold_stream],
        "semanticir_handlers" => %w[stream.stream_node],
        "assembler_hooks" => %w[stream.stream_nodes_metadata]
      }),
      pack("olap", "OLAPPack", "olap.metadata_only.self_assembly.v0", %w[olap_point], %w[core fragment_registry], {
        "parser_rules" => %w[olap.olap_point olap.dims_record],
        "typechecker_rules" => %w[olap.dims_shape],
        "semanticir_handlers" => %w[olap.olap_point_node]
      }),
      pack("invariant", "InvariantPack", "invariant.self_assembly.v0", %w[invariant], %w[core], {
        "parser_rules" => %w[invariant.invariant],
        "classifier_rules" => %w[invariant.invariant_fragment],
        "semanticir_handlers" => %w[invariant.invariant_node]
      }),
      pack("assumptions", "AssumptionsPack", "assumptions.self_assembly.v0", %w[assumptions], %w[contract_modifiers], {
        "parser_rules" => %w[assumptions.assume],
        "semanticir_handlers" => %w[assumptions.assumption_metadata]
      }),
      pack("evidence_observation", "EvidenceObservationPack", "evidence_observation.self_assembly.v0", %w[evidence_observation], %w[core], {
        "parser_rules" => %w[evidence.observe],
        "semanticir_handlers" => %w[evidence.observation_node]
      }),
      pack("compiler_accountability", "CompilationReceiptPack", "compilation_receipt.self_assembly.v0", %w[compiler_accountability compilation_receipt], %w[core], {
        "assembler_hooks" => %w[receipt.emit receipt.redact receipt.link_compatibility_report],
        "receipt_surfaces" => %w[embedded_igapp_receipt external_signed_receipt_bundle ilk_metadata_index]
      })
    ]
  end

  def pack(slot, name, implementation_id, capabilities, requires_slots, registries)
    {
      "slot" => slot,
      "name" => name,
      "implementation_id" => implementation_id,
      "capability_owner" => true,
      "provides_capabilities" => capabilities,
      "requires_slots" => requires_slots,
      "registries" => registries
    }
  end

  def assembly_pipeline(preflight, storage)
    [
      {
        "stage" => "seed_bootstrap_kernel",
        "status" => "trusted_seed_required",
        "output" => "descriptor_validator"
      },
      {
        "stage" => "load_profile_source",
        "status" => "descriptor_only",
        "output" => "profile_source_ast_candidate"
      },
      {
        "stage" => "install_packs",
        "status" => preflight.fetch("status"),
        "output" => "frozen_pack_registry"
      },
      {
        "stage" => "validate_slots_and_ordering",
        "status" => preflight.fetch("status"),
        "output" => "compiler_profile"
      },
      {
        "stage" => "emit_compilation_receipt_policy",
        "status" => storage.fetch("status"),
        "output" => "compilation_receipt_storage_policy"
      }
    ]
  end

  def assembled_profile(profile_source, packs)
    ordered = profile_spec.fetch("slot_order").to_h do |slot|
      descriptor = packs.find { |pack| pack.fetch("slot") == slot }
      [slot, descriptor&.slice("name", "implementation_id", "provides_capabilities", "requires_slots")]
    end
    payload = {
      "kind" => "hypothetical_self_assembled_compiler_profile",
      "format_version" => FORMAT_VERSION,
      "source_digest" => profile_source.fetch("canonical_source_digest"),
      "slot_assignments" => ordered,
      "ordered_rule_sources" => packs.to_h do |pack|
        [pack.fetch("slot"), pack.fetch("registries").keys]
      end,
      "dispatch_mode" => "hypothetical_profile_assembled_no_production_dispatch"
    }
    payload.merge("profile_id" => profile_id(payload))
  end

  def migration_path
    [
      "Keep current Ruby compiler as proof compiler.",
      "Define profile source descriptors as data first, not syntax.",
      "Make BootstrapDescriptorKernel validate descriptors without owning language semantics.",
      "Compile a profile descriptor into a frozen CompilerProfile manifest.",
      "Use CompilationReceiptPack to explain the build.",
      "Only after POC closure, replace monolithic dispatch one pack at a time."
    ]
  end

  def build_checks(model, variant, preflight, storage, preflight_run, storage_run)
    {
      "input.preflight_passed" => preflight_run.fetch("exit_status").zero? && preflight.fetch("status") == "PASS",
      "input.receipt_storage_passed" => storage_run.fetch("exit_status").zero? && storage.fetch("status") == "PASS",
      "bootstrap.seed_is_explicit" => model.dig("bootstrap_trust_boundary", "trusted_seed") == true &&
        model.dig("authority", "bootstrap_seed_eliminated") == false,
      "profile.required_slots_present" => model.fetch("profile_spec").fetch("required_slots").all? do |slot|
        model.dig("assembled_profile", "slot_assignments", slot)
      end,
      "profile.all_packs_are_capability_owners" => model.fetch("pack_descriptors").all? do |pack|
        pack.fetch("capability_owner") == true && pack.fetch("provides_capabilities").any?
      end,
      "profile.includes_compiler_accountability_pack" => model.fetch("pack_descriptors").any? do |pack|
        pack.fetch("slot") == "compiler_accountability" &&
          pack.fetch("provides_capabilities").include?("compilation_receipt")
      end,
      "profile.temporal_variant_changes_profile_id" => model.fetch("self_assembly_profile_id") != variant.fetch("self_assembly_profile_id"),
      "pipeline.bootstrap_before_profile_before_receipt" => model.fetch("assembly_pipeline").map { |stage| stage.fetch("stage") } == %w[
        seed_bootstrap_kernel
        load_profile_source
        install_packs
        validate_slots_and_ordering
        emit_compilation_receipt_policy
      ],
      "authority.not_claiming_self_hosted_implementation" => model.dig("authority", "self_hosted_compiler_implementation") == false,
      "authority.no_runtime_execution_authority" => model.dig("authority", "runtime_execution_authority") == false
    }
  end

  def read_json(path)
    JSON.parse(File.read(path))
  end

  def write_json(path, value)
    File.write(path, "#{JSON.pretty_generate(value)}\n")
  end

  def profile_id(value)
    "igniter_lang_self_assembly_profile/sha256:#{Digest::SHA256.hexdigest(JSON.generate(sort_value(value)))[0, 24]}"
  end

  def digest(value)
    "sha256:#{Digest::SHA256.hexdigest(JSON.generate(sort_value(value)))}"
  end

  def sort_value(value)
    case value
    when Hash
      value.keys.sort.to_h { |key| [key, sort_value(value.fetch(key))] }
    when Array
      value.map { |entry| sort_value(entry) }
    else
      value
    end
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} igniter_lang_self_assembly_profile_sketch"
    summary.fetch("checks").each do |label, ok|
      puts "#{label}: #{ok ? "ok" : "FAIL"}"
    end
    puts "profile_id: #{summary.fetch("self_assembly_profile_id")}"
    puts "model: #{summary.fetch("model_path")}"
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = IgniterLangSelfAssemblyProfileSketch.run
exit(success ? 0 : 1)
