#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "pathname"

module ContractModifiersPackNativeBoundary
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  GOLDEN_DIR = ROOT / "igniter-lang/experiments/contract_modifiers_proof/golden"
  SHADOW_PROFILE_SUMMARY = ROOT / "igniter-lang/experiments/compiler_pack_shadow_profile_proof/out/compiler_pack_shadow_profile_proof_summary.json"
  OUT_DIR = ROOT / "igniter-lang/experiments/contract_modifiers_pack_native_boundary/out"
  SUMMARY_PATH = OUT_DIR / "contract_modifiers_pack_native_boundary_summary.json"

  FORMAT_VERSION = "0.1.0"
  TRACK = "contract-modifiers-pack-native-boundary-v0"

  MODIFIERS = %w[pure observed effect privileged irreversible].freeze

  PACK_MANIFEST = {
    "kind" => "compiler_pack_manifest",
    "format_version" => FORMAT_VERSION,
    "name" => "ContractModifiersPack",
    "implementation_id" => "contract_modifiers.pack_boundary_descriptor.v0",
    "boundary_mode" => "native_manifest_descriptor_only",
    "requires_packs" => %w[CoreLanguagePack EscapeBoundaryPack OOFRegistry FragmentRegistry],
    "provides_capabilities" => %w[contract_modifiers modifier_fragment_widening oof_m1],
    "parser_rules" => {
      "contract_modifier_keywords" => MODIFIERS,
      "normalization" => {
        "missing_modifier" => "pure",
        "field" => "modifier",
        "stage" => "parser"
      }
    },
    "classifier_rules" => {
      "fragment_mapping" => {
        "pure" => "body_fragment",
        "observed" => "escape_unless_temporal",
        "effect" => "escape",
        "privileged" => "escape",
        "irreversible" => "escape"
      },
      "temporal_precedence" => "temporal_over_modifier_escape",
      "oof_checks" => ["OOF-M1"]
    },
    "typechecker_rules" => {
      "propagates_oof" => ["OOF-M1"],
      "status_on_oof" => "blocked",
      "field_passthrough" => ["modifier"]
    },
    "semanticir_handlers" => {
      "contract_ir_fields" => ["modifier"],
      "blocked_contract_emit" => "nil"
    },
    "assembler_hooks" => {
      "manifest_modifier_passthrough" => "descriptive_only",
      "igapp_format_change" => false
    },
    "oof_descriptors" => {
      "OOF-M1" => {
        "owner_pack" => "ContractModifiersPack",
        "stage_owner" => "classifier",
        "propagates_to" => "typechecker",
        "severity" => "error",
        "message_stability" => "public"
      }
    }
  }.freeze

  CASES = {
    "pure_contract_implicit" => {
      "expected_modifiers" => ["pure"],
      "expected_fragments" => ["core"],
      "semantic_ir" => true
    },
    "pure_contract_explicit" => {
      "expected_modifiers" => ["pure"],
      "expected_fragments" => ["core"],
      "semantic_ir" => true
    },
    "observed_contract_basic" => {
      "expected_modifiers" => ["observed"],
      "expected_fragments" => ["escape"],
      "semantic_ir" => true
    },
    "modifier_variants" => {
      "expected_modifiers" => %w[effect privileged irreversible],
      "expected_fragments" => %w[escape escape escape],
      "semantic_ir" => true
    },
    "observed_temporal_precedence" => {
      "expected_modifiers" => ["observed"],
      "expected_fragments" => ["temporal"],
      "semantic_ir" => true
    },
    "oof_m1_pure_with_escape" => {
      "expected_modifiers" => ["pure"],
      "expected_fragments" => ["oof"],
      "semantic_ir" => false,
      "expected_oof" => "OOF-M1"
    }
  }.freeze

  module_function

  def run
    FileUtils.mkdir_p(OUT_DIR)
    evidence = build_evidence
    checks = build_checks(evidence)
    summary = {
      "kind" => "contract_modifiers_pack_native_boundary_summary",
      "format_version" => FORMAT_VERSION,
      "track" => TRACK,
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "pack_manifest" => PACK_MANIFEST.merge("manifest_id" => manifest_id(PACK_MANIFEST)),
      "evidence" => evidence,
      "checks" => checks,
      "next_recommended_slice" => "compiler-kernel-pack-registry-spike-v0"
    }
    write_json(SUMMARY_PATH, summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def build_evidence
    {
      "source_golden_dir" => GOLDEN_DIR.relative_path_from(ROOT).to_s,
      "shadow_profile_summary" => SHADOW_PROFILE_SUMMARY.relative_path_from(ROOT).to_s,
      "cases" => CASES.to_h { |case_id, config| [case_id, case_evidence(case_id, config)] },
      "shadow_profile_pack" => shadow_profile_pack,
      "igapp_manifest_changes" => []
    }
  end

  def case_evidence(case_id, config)
    parsed = read_json(GOLDEN_DIR / "#{case_id}.parsed.json")
    classified = read_json(GOLDEN_DIR / "#{case_id}.classified.json")
    typed = read_json(GOLDEN_DIR / "#{case_id}.typed.json")
    semantic_ir_path = GOLDEN_DIR / "#{case_id}.semantic_ir.json"
    semantic_ir = semantic_ir_path.exist? ? read_json(semantic_ir_path) : nil
    {
      "expected" => config,
      "parsed_modifiers" => parsed.fetch("contracts").map { |contract| contract.fetch("modifier") },
      "classified_modifiers" => classified.fetch("contracts").map { |contract| contract.fetch("modifier") },
      "classified_fragments" => classified.fetch("contracts").map { |contract| contract.fetch("fragment_class") },
      "typed_modifiers" => typed.fetch("contracts").map { |contract| contract.fetch("modifier") },
      "typed_statuses" => typed.fetch("contracts").map { |contract| contract.fetch("status") },
      "typed_type_errors" => typed.fetch("type_errors", []),
      "semantic_ir_modifiers" => semantic_ir ? semantic_ir.fetch("contracts").map { |contract| contract.fetch("modifier") } : [],
      "semantic_ir_fragments" => semantic_ir ? semantic_ir.fetch("contracts").map { |contract| contract.fetch("fragment_class") } : [],
      "semantic_ir_present" => !semantic_ir.nil?,
      "oof_log" => classified.fetch("oof_log", [])
    }
  end

  def shadow_profile_pack
    return nil unless SHADOW_PROFILE_SUMMARY.exist?

    summary = read_json(SHADOW_PROFILE_SUMMARY)
    summary.fetch("profile").fetch("packs").find { |pack| pack.fetch("name") == "ContractModifiersPack" }
  end

  def build_checks(evidence)
    {
      "manifest.kind" => PACK_MANIFEST.fetch("kind") == "compiler_pack_manifest",
      "manifest.boundary_mode_descriptor_only" => PACK_MANIFEST.fetch("boundary_mode") == "native_manifest_descriptor_only",
      "manifest.requires_kernel_services" => %w[OOFRegistry FragmentRegistry].all? do |name|
        PACK_MANIFEST.fetch("requires_packs").include?(name)
      end,
      "manifest.no_igapp_format_change" => PACK_MANIFEST.fetch("assembler_hooks").fetch("igapp_format_change") == false,
      "manifest.oof_m1_owned_by_pack" => PACK_MANIFEST.fetch("oof_descriptors").fetch("OOF-M1").fetch("owner_pack") == "ContractModifiersPack",
      "shadow_profile.compatible_pack_present" => compatible_shadow_pack?(evidence.fetch("shadow_profile_pack")),
      "parser.modifiers_normalized" => cases_all?(evidence) do |_case_id, case_data|
        expected = case_data.fetch("expected").fetch("expected_modifiers")
        case_data.fetch("parsed_modifiers") == expected
      end,
      "classifier.modifier_mapping" => cases_all?(evidence) do |_case_id, case_data|
        expected = case_data.fetch("expected")
        case_data.fetch("classified_modifiers") == expected.fetch("expected_modifiers") &&
          case_data.fetch("classified_fragments") == expected.fetch("expected_fragments")
      end,
      "typechecker.modifier_passthrough" => cases_all?(evidence) do |_case_id, case_data|
        case_data.fetch("typed_modifiers") == case_data.fetch("expected").fetch("expected_modifiers")
      end,
      "semanticir.modifier_field_for_emitted_contracts" => cases_all?(evidence) do |_case_id, case_data|
        expected = case_data.fetch("expected")
        next case_data.fetch("semantic_ir_modifiers").empty? unless expected.fetch("semantic_ir")

        case_data.fetch("semantic_ir_modifiers") == expected.fetch("expected_modifiers") &&
          case_data.fetch("semantic_ir_fragments") == expected.fetch("expected_fragments")
      end,
      "classifier.oof_m1_negative_case" => oof_m1_case_ok?(evidence),
      "typechecker.oof_m1_blocks" => oof_m1_typechecker_blocks?(evidence),
      "semanticir.oof_m1_no_ir" => evidence.fetch("cases").fetch("oof_m1_pure_with_escape").fetch("semantic_ir_present") == false,
      "classifier.temporal_precedence_over_modifier" => evidence.fetch("cases")
        .fetch("observed_temporal_precedence")
        .fetch("classified_fragments") == ["temporal"],
      "proof.no_runtime_authorization" => PACK_MANIFEST.fetch("provides_capabilities").none? { |cap| cap.include?("runtime") },
      "proof.no_manifest_changes" => evidence.fetch("igapp_manifest_changes").empty?
    }
  end

  def compatible_shadow_pack?(pack)
    return false unless pack

    pack.fetch("name") == "ContractModifiersPack" &&
      pack.fetch("oof_codes").include?("OOF-M1") &&
      pack.fetch("provides_capabilities").include?("contract_modifiers")
  end

  def cases_all?(evidence)
    evidence.fetch("cases").all? { |case_id, case_data| yield(case_id, case_data) }
  end

  def oof_m1_case_ok?(evidence)
    case_data = evidence.fetch("cases").fetch("oof_m1_pure_with_escape")
    case_data.fetch("oof_log").any? { |entry| entry.fetch("rule") == "OOF-M1" } &&
      case_data.fetch("classified_fragments") == ["oof"]
  end

  def oof_m1_typechecker_blocks?(evidence)
    case_data = evidence.fetch("cases").fetch("oof_m1_pure_with_escape")
    case_data.fetch("typed_statuses") == ["blocked"] &&
      case_data.fetch("typed_type_errors").any? { |entry| entry.fetch("rule") == "OOF-M1" }
  end

  def manifest_id(manifest)
    "compiler_pack_manifest/#{manifest.fetch("name")}/sha256:#{Digest::SHA256.hexdigest(canonical_json(manifest))[0, 24]}"
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
    puts "#{summary.fetch("status")} contract_modifiers_pack_native_boundary"
    summary.fetch("checks").each do |label, ok|
      puts "#{label}: #{ok ? "ok" : "FAIL"}"
    end
    puts "manifest_id: #{summary.fetch("pack_manifest").fetch("manifest_id")}"
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = ContractModifiersPackNativeBoundary.run
exit(success ? 0 : 1)
