#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "pathname"

module CompilerProfileSlotsModel
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  SHADOW_PROFILE_SUMMARY = ROOT / "igniter-lang/experiments/compiler_pack_shadow_profile_proof/out/compiler_pack_shadow_profile_proof_summary.json"
  OUT_DIR = ROOT / "igniter-lang/experiments/compiler_profile_slots_model/out"
  SUMMARY_PATH = OUT_DIR / "compiler_profile_slots_model_summary.json"

  FORMAT_VERSION = "0.1.0"
  TRACK = "compiler-profile-slots-model-v0"

  class ProfileSpecError < StandardError; end
  class MissingRequiredSlotError < ProfileSpecError; end
  class DuplicateSlotFillError < ProfileSpecError; end
  class UnknownPackSlotError < ProfileSpecError; end
  class MissingSlotDependencyError < ProfileSpecError; end

  PROFILE_SPEC = {
    "kind" => "compiler_profile_spec",
    "name" => "Stage3ProofCompilerProfileSpec",
    "format_version" => FORMAT_VERSION,
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
      pipeline
    ],
    "slots" => {
      "core" => {
        "cardinality" => "exactly_one",
        "accepts_pack_names" => ["CoreLanguagePack"],
        "accepts_capabilities" => ["core_language"]
      },
      "oof_registry" => {
        "cardinality" => "exactly_one",
        "accepts_pack_names" => ["OOFRegistry"],
        "accepts_capabilities" => ["oof_registry"]
      },
      "fragment_registry" => {
        "cardinality" => "exactly_one",
        "accepts_pack_names" => ["FragmentRegistry"],
        "accepts_capabilities" => ["fragment_registry"]
      },
      "escape_boundary" => {
        "cardinality" => "exactly_one",
        "accepts_pack_names" => ["EscapeBoundaryPack"],
        "accepts_capabilities" => ["escape_boundary"]
      },
      "contract_modifiers" => {
        "cardinality" => "zero_or_one",
        "accepts_pack_names" => ["ContractModifiersPack"],
        "accepts_capabilities" => ["contract_modifiers"]
      },
      "temporal" => {
        "cardinality" => "zero_or_one",
        "accepts_pack_names" => ["TemporalPack", "TemporalPackLedgerBacked"],
        "accepts_capabilities" => ["temporal"]
      },
      "stream" => {
        "cardinality" => "zero_or_one",
        "accepts_pack_names" => ["StreamPack"],
        "accepts_capabilities" => ["stream"]
      },
      "olap" => {
        "cardinality" => "zero_or_one",
        "accepts_pack_names" => ["OLAPPack"],
        "accepts_capabilities" => ["olap_point"]
      },
      "invariant" => {
        "cardinality" => "zero_or_one",
        "accepts_pack_names" => ["InvariantPack"],
        "accepts_capabilities" => ["invariant"]
      },
      "assumptions" => {
        "cardinality" => "zero_or_one",
        "accepts_pack_names" => ["AssumptionsPack"],
        "accepts_capabilities" => ["assumptions"],
        "requires_slots" => ["contract_modifiers"]
      },
      "evidence_observation" => {
        "cardinality" => "zero_or_one",
        "accepts_pack_names" => ["EvidenceObservationPack"],
        "accepts_capabilities" => ["evidence_observation"]
      },
      "pipeline" => {
        "cardinality" => "zero_or_one",
        "accepts_pack_names" => ["PipelinePack"],
        "accepts_capabilities" => ["pipeline_surface"]
      }
    }
  }.freeze

  module_function

  def run
    FileUtils.mkdir_p(OUT_DIR)
    shadow_packs = read_json(SHADOW_PROFILE_SUMMARY).fetch("profile").fetch("packs")
    positive_profile = build_profile(shadow_packs)
    reversed_profile = build_profile(shadow_packs.reverse)
    temporal_variant_profile = build_profile(replace_temporal_variant(shadow_packs))
    negative_results = build_negative_results(shadow_packs)
    checks = build_checks(positive_profile, reversed_profile, temporal_variant_profile, negative_results)
    summary = {
      "kind" => "compiler_profile_slots_model_summary",
      "format_version" => FORMAT_VERSION,
      "track" => TRACK,
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "profile_spec" => PROFILE_SPEC,
      "positive_profile" => positive_profile,
      "reversed_input_profile" => {
        "profile_id" => reversed_profile.fetch("profile_id"),
        "slot_assignments" => reversed_profile.fetch("slot_assignments")
      },
      "temporal_variant_profile" => {
        "profile_id" => temporal_variant_profile.fetch("profile_id"),
        "slot_assignments" => temporal_variant_profile.fetch("slot_assignments")
      },
      "negative_results" => negative_results,
      "checks" => checks,
      "design_signal" => {
        "profile_spec_role" => "profile-of-profile; validates allowed slots before CompilerProfile finalization",
        "prevents_over_splitting" => "packs without semantic capability slots are rejected",
        "supports_competing_implementations" => "same slot can accept exactly one variant by implementation_id"
      },
      "non_goals" => [
        "No compiler pass dispatch.",
        "No production CompilerProfileSpec implementation.",
        "No .igapp manifest changes."
      ]
    }
    write_json(SUMMARY_PATH, summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def build_profile(packs)
    assignments = assign_slots(packs)
    validate_required_slots(assignments)
    validate_slot_dependencies(assignments)
    ordered_assignments = PROFILE_SPEC.fetch("slot_order").filter_map do |slot_id|
      pack = assignments[slot_id]
      next unless pack

      [slot_id, pack_summary(pack)]
    end.to_h
    profile = {
      "kind" => "compiler_profile_slots_model",
      "format_version" => FORMAT_VERSION,
      "profile_spec" => PROFILE_SPEC.fetch("name"),
      "slot_assignments" => ordered_assignments,
      "dispatch_mode" => "slot_validation_only_no_compiler_dispatch",
      "igapp_manifest_changes" => []
    }
    profile.merge("profile_id" => profile_id(profile))
  end

  def assign_slots(packs)
    packs.each_with_object({}) do |pack, assignments|
      slot_id = slot_for(pack)
      raise UnknownPackSlotError, "no slot accepts #{pack.fetch("name")}" unless slot_id

      if assignments.key?(slot_id)
        raise DuplicateSlotFillError,
              "slot #{slot_id} already filled by #{assignments.fetch(slot_id).fetch("name")}; cannot add #{pack.fetch("name")}"
      end

      assignments[slot_id] = pack
    end
  end

  def slot_for(pack)
    PROFILE_SPEC.fetch("slots").find do |_slot_id, spec|
      spec.fetch("accepts_pack_names", []).include?(pack.fetch("name")) ||
        !(spec.fetch("accepts_capabilities", []) & pack.fetch("provides_capabilities", [])).empty?
    end&.first
  end

  def validate_required_slots(assignments)
    missing = PROFILE_SPEC.fetch("slots").filter_map do |slot_id, spec|
      slot_id if spec.fetch("cardinality") == "exactly_one" && !assignments.key?(slot_id)
    end
    return if missing.empty?

    raise MissingRequiredSlotError, "missing required slots: #{missing.join(", ")}"
  end

  def validate_slot_dependencies(assignments)
    assignments.each_key do |slot_id|
      requires = PROFILE_SPEC.dig("slots", slot_id, "requires_slots") || []
      missing = requires.reject { |required_slot| assignments.key?(required_slot) }
      next if missing.empty?

      raise MissingSlotDependencyError, "slot #{slot_id} requires missing slots: #{missing.join(", ")}"
    end
  end

  def pack_summary(pack)
    {
      "pack_name" => pack.fetch("name"),
      "implementation_id" => pack.fetch("implementation_id"),
      "status" => pack.fetch("status", "unspecified"),
      "provides_capabilities" => pack.fetch("provides_capabilities", [])
    }
  end

  def replace_temporal_variant(packs)
    packs.map do |pack|
      next pack unless pack.fetch("name") == "TemporalPack"

      pack.merge(
        "name" => "TemporalPackLedgerBacked",
        "implementation_id" => "temporal.ledger_tbackend_profile_slot_variant.v0",
        "status" => "variant_candidate"
      )
    end
  end

  def build_negative_results(packs)
    {
      "missing_required_core" => capture_error do
        build_profile(packs.reject { |pack| pack.fetch("name") == "CoreLanguagePack" })
      end,
      "duplicate_temporal_variants" => capture_error do
        temporal_variant = replace_temporal_variant(packs).find { |pack| pack.fetch("name") == "TemporalPackLedgerBacked" }
        build_profile(packs + [temporal_variant])
      end,
      "helper_pack_rejected" => capture_error do
        build_profile(packs + [helper_pack])
      end,
      "assumptions_without_modifiers" => capture_error do
        build_profile(packs.reject { |pack| pack.fetch("name") == "ContractModifiersPack" })
      end
    }
  end

  def helper_pack
    {
      "name" => "ParserHelpersPack",
      "implementation_id" => "parser_helpers.not_a_semantic_capability.v0",
      "status" => "rejected_test_fixture",
      "provides_capabilities" => ["parser_helpers"]
    }
  end

  def capture_error
    yield
    { "raised" => false, "class" => nil, "message" => nil }
  rescue ProfileSpecError => e
    { "raised" => true, "class" => e.class.name.split("::").last, "message" => e.message }
  end

  def build_checks(positive_profile, reversed_profile, temporal_variant_profile, negative_results)
    {
      "positive.profile_kind" => positive_profile.fetch("kind") == "compiler_profile_slots_model",
      "positive.required_slots_present" => %w[core oof_registry fragment_registry escape_boundary].all? do |slot|
        positive_profile.fetch("slot_assignments").key?(slot)
      end,
      "positive.optional_slots_present" => %w[contract_modifiers temporal assumptions].all? do |slot|
        positive_profile.fetch("slot_assignments").key?(slot)
      end,
      "positive.dispatch_slot_validation_only" => positive_profile.fetch("dispatch_mode") == "slot_validation_only_no_compiler_dispatch",
      "positive.no_igapp_manifest_changes" => positive_profile.fetch("igapp_manifest_changes").empty?,
      "determinism.input_order_independent_assignments" => positive_profile.fetch("slot_assignments") == reversed_profile.fetch("slot_assignments"),
      "determinism.input_order_independent_profile_id" => positive_profile.fetch("profile_id") == reversed_profile.fetch("profile_id"),
      "variants.temporal_variant_changes_profile_id" => positive_profile.fetch("profile_id") != temporal_variant_profile.fetch("profile_id"),
      "variants.temporal_slot_accepts_alternate_implementation" => temporal_variant_profile.dig("slot_assignments", "temporal", "pack_name") == "TemporalPackLedgerBacked",
      "negative.missing_required_core_rejected" => error_class?(negative_results, "missing_required_core", "MissingRequiredSlotError"),
      "negative.duplicate_temporal_variants_rejected" => error_class?(negative_results, "duplicate_temporal_variants", "DuplicateSlotFillError"),
      "negative.helper_pack_rejected" => error_class?(negative_results, "helper_pack_rejected", "UnknownPackSlotError"),
      "negative.assumptions_without_modifiers_rejected" => error_class?(negative_results, "assumptions_without_modifiers", "MissingSlotDependencyError")
    }
  end

  def error_class?(negative_results, key, expected_class)
    result = negative_results.fetch(key)
    result.fetch("raised") == true && result.fetch("class") == expected_class
  end

  def profile_id(profile)
    stable = profile.reject { |key, _value| key == "profile_id" }
    "compiler_profile_slots/sha256:#{Digest::SHA256.hexdigest(canonical_json(stable))[0, 24]}"
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

  def read_json(path)
    JSON.parse(File.read(path))
  end

  def write_json(path, value)
    File.write(path, "#{JSON.pretty_generate(value)}\n")
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} compiler_profile_slots_model"
    summary.fetch("checks").each do |label, ok|
      puts "#{label}: #{ok ? "ok" : "FAIL"}"
    end
    puts "profile_id: #{summary.fetch("positive_profile").fetch("profile_id")}"
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = CompilerProfileSlotsModel.run
exit(success ? 0 : 1)
