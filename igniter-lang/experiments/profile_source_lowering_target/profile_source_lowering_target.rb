#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "open3"
require "pathname"
require "rbconfig"

module ProfileSourceLoweringTargetProof
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  LANG_ROOT = ROOT / "igniter-lang"
  OUT_DIR = LANG_ROOT / "experiments/profile_source_lowering_target/out"
  LOWERING_MODEL_PATH = OUT_DIR / "profile_source_lowering_model.json"
  LOWERED_DESCRIPTOR_PATH = OUT_DIR / "lowered_profile_descriptor.json"
  SUMMARY_PATH = OUT_DIR / "profile_source_lowering_target_summary.json"

  SCHEMA_RUNNER = LANG_ROOT / "experiments/compiler_profile_descriptor_schema/compiler_profile_descriptor_schema.rb"
  SCHEMA_SUMMARY = LANG_ROOT / "experiments/compiler_profile_descriptor_schema/out/compiler_profile_descriptor_schema_summary.json"
  CANONICAL_DESCRIPTOR = LANG_ROOT / "experiments/compiler_profile_descriptor_schema/out/canonical_profile_descriptor.json"

  FORMAT_VERSION = "0.1.0"
  TRACK = "profile-source-lowering-target-v0"

  class LoweringError < StandardError
    attr_reader :code, :details

    def initialize(code, message, details = {})
      super(message)
      @code = code
      @details = details
    end
  end

  module_function

  def run
    FileUtils.mkdir_p(OUT_DIR)
    schema_run = run_schema
    schema_summary = read_json(SCHEMA_SUMMARY)
    expected_descriptor = read_json(CANONICAL_DESCRIPTOR)
    source_ast = source_ast_from_descriptor(expected_descriptor)
    lowering_model = build_lowering_model(source_ast)
    lowered_descriptor = lower_and_canonicalize(source_ast, expected_descriptor)
    negative_results = build_negative_results(source_ast, expected_descriptor)
    checks = build_checks(lowering_model, lowered_descriptor, expected_descriptor, negative_results, schema_run, schema_summary)
    summary = {
      "kind" => "profile_source_lowering_target_summary",
      "format_version" => FORMAT_VERSION,
      "track" => TRACK,
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "lowering_model_path" => LOWERING_MODEL_PATH.relative_path_from(ROOT).to_s,
      "lowered_descriptor_path" => LOWERED_DESCRIPTOR_PATH.relative_path_from(ROOT).to_s,
      "descriptor_digest" => lowered_descriptor.fetch("descriptor_digest"),
      "negative_results" => negative_results,
      "checks" => checks,
      "non_goals" => [
        "No parser implementation.",
        "No profile source syntax authorization.",
        "No production lowering code.",
        "No CompilerKernel dispatch changes.",
        "No .igapp or .ilk changes."
      ]
    }

    write_json(LOWERING_MODEL_PATH, lowering_model)
    write_json(LOWERED_DESCRIPTOR_PATH, lowered_descriptor)
    write_json(SUMMARY_PATH, summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def run_schema
    stdout, stderr, status = Open3.capture3(RbConfig.ruby, SCHEMA_RUNNER.to_s, chdir: ROOT.to_s)
    {
      "command" => "ruby #{SCHEMA_RUNNER.relative_path_from(ROOT)}",
      "exit_status" => status.exitstatus,
      "stdout_first_line" => stdout.lines.first.to_s.strip,
      "stderr" => stderr.strip
    }
  end

  def source_ast_from_descriptor(descriptor)
    {
      "kind" => "profile_source_ast_candidate",
      "format_version" => FORMAT_VERSION,
      "profile_name" => "IgniterLang.Stage3SelfAssemblyProfile",
      "parser_implemented" => false,
      "syntax_authorized" => false,
      "lowering_target" => "compiler_profile_descriptor",
      "profile_spec" => descriptor.fetch("profile_spec"),
      "slots" => descriptor.fetch("pack_descriptors").map do |pack|
        {
          "slot" => pack.fetch("slot"),
          "pack" => pack.fetch("name"),
          "implementation" => pack.fetch("implementation_id"),
          "owns_capabilities" => pack.fetch("provides_capabilities"),
          "requires" => pack.fetch("requires_slots"),
          "registries" => pack.fetch("registries")
        }
      end
    }
  end

  def build_lowering_model(source_ast)
    {
      "kind" => "profile_source_lowering_model",
      "format_version" => FORMAT_VERSION,
      "track" => TRACK,
      "source_status" => {
        "parser_implemented" => source_ast.fetch("parser_implemented"),
        "syntax_authorized" => source_ast.fetch("syntax_authorized"),
        "descriptor_first" => true
      },
      "lowering_rules" => {
        "profile_header" => "profile_descriptor.kind + profile_source",
        "profile_name" => "profile_source.kind and future source metadata",
        "slot_declaration" => "pack_descriptor.slot + pack_descriptor.name",
        "implementation_clause" => "pack_descriptor.implementation_id",
        "owns_capabilities_clause" => "pack_descriptor.provides_capabilities",
        "requires_clause" => "pack_descriptor.requires_slots",
        "registry_block" => "pack_descriptor.registries",
        "profile_spec_reference" => "profile_descriptor.profile_spec"
      },
      "forbidden_constructs" => {
        "implementation_body" => "lowering.implementation_body_out_of_scope",
        "runtime_authority_claim" => "lowering.runtime_authority_claim_rejected",
        "full_language_parser_requirement" => "lowering.parser_implementation_out_of_scope"
      },
      "target_descriptor_kind" => "compiler_profile_descriptor"
    }
  end

  def lower_and_canonicalize(source_ast, expected_descriptor)
    validate_source_ast(source_ast)
    descriptor = {
      "kind" => "compiler_profile_descriptor",
      "format_version" => FORMAT_VERSION,
      "profile_spec" => source_ast.fetch("profile_spec"),
      "profile_source" => {
        "kind" => "hypothetical_igniter_lang_profile_source",
        "format_version" => FORMAT_VERSION,
        "parser_status" => "not_implemented_descriptor_only",
        "canonical_source_digest" => digest(source_ast.reject { |key, _| key == "parser_implemented" })
      },
      "pack_descriptors" => source_ast.fetch("slots").map do |slot|
        {
          "slot" => slot.fetch("slot"),
          "name" => slot.fetch("pack"),
          "implementation_id" => slot.fetch("implementation"),
          "capability_owner" => true,
          "provides_capabilities" => slot.fetch("owns_capabilities"),
          "requires_slots" => slot.fetch("requires"),
          "registries" => slot.fetch("registries")
        }
      end
    }
    normalized = normalize_descriptor(descriptor)
    normalized.merge(
      "descriptor_digest" => descriptor_digest(normalized),
      "schema_ref" => expected_descriptor.fetch("schema_ref")
    )
  end

  def validate_source_ast(source_ast)
    if source_ast.fetch("parser_implemented")
      raise LoweringError.new("lowering.parser_implementation_out_of_scope", "parser implementation is out of scope")
    end
    if source_ast.fetch("syntax_authorized")
      raise LoweringError.new("lowering.syntax_authority_out_of_scope", "syntax authorization is out of scope")
    end

    known_slots = source_ast.dig("profile_spec", "slot_order")
    seen = {}
    source_ast.fetch("slots").each do |slot|
      if slot.key?("implementation_body")
        raise LoweringError.new(
          "lowering.implementation_body_out_of_scope",
          "profile source may select implementations, not define them inline",
          "slot" => slot.fetch("slot")
        )
      end
      if slot.fetch("runtime_authority_claim", false)
        raise LoweringError.new(
          "lowering.runtime_authority_claim_rejected",
          "profile source cannot grant runtime authority",
          "slot" => slot.fetch("slot")
        )
      end
      unless known_slots.include?(slot.fetch("slot"))
        raise LoweringError.new("lowering.unknown_slot", "unknown slot", "slot" => slot.fetch("slot"))
      end
      if seen.key?(slot.fetch("slot"))
        raise LoweringError.new("lowering.duplicate_slot", "duplicate slot", "slot" => slot.fetch("slot"))
      end
      seen[slot.fetch("slot")] = true
      unless slot.fetch("implementation", nil)
        raise LoweringError.new("lowering.missing_implementation_id", "missing implementation", "slot" => slot.fetch("slot"))
      end
      if slot.fetch("owns_capabilities", []).empty?
        raise LoweringError.new("lowering.helper_only_pack_rejected", "pack owns no capability", "slot" => slot.fetch("slot"))
      end
    end
  end

  def normalize_descriptor(descriptor)
    spec = descriptor.fetch("profile_spec")
    slot_order = spec.fetch("slot_order")
    packs = descriptor.fetch("pack_descriptors").sort_by do |pack|
      [slot_order.index(pack.fetch("slot")) || slot_order.length, pack.fetch("name")]
    end
    {
      "kind" => descriptor.fetch("kind"),
      "format_version" => descriptor.fetch("format_version"),
      "profile_spec" => {
        "kind" => spec.fetch("kind"),
        "name" => spec.fetch("name"),
        "slot_order" => slot_order,
        "required_slots" => spec.fetch("required_slots").sort,
        "optional_slots" => spec.fetch("optional_slots").sort
      },
      "profile_source" => descriptor.fetch("profile_source"),
      "pack_descriptors" => packs.map do |pack|
        {
          "slot" => pack.fetch("slot"),
          "name" => pack.fetch("name"),
          "implementation_id" => pack.fetch("implementation_id"),
          "capability_owner" => pack.fetch("capability_owner"),
          "provides_capabilities" => pack.fetch("provides_capabilities").sort,
          "requires_slots" => pack.fetch("requires_slots").sort,
          "registries" => pack.fetch("registries").transform_values(&:sort)
        }
      end
    }
  end

  def build_negative_results(source_ast, expected_descriptor)
    {
      "parser_implementation_out_of_scope" => capture_error do
        lower_and_canonicalize(source_ast.merge("parser_implemented" => true), expected_descriptor)
      end,
      "syntax_authority_out_of_scope" => capture_error do
        lower_and_canonicalize(source_ast.merge("syntax_authorized" => true), expected_descriptor)
      end,
      "implementation_body_out_of_scope" => capture_error do
        mutated = deep_copy(source_ast)
        mutated.fetch("slots").first["implementation_body"] = "class CoreLanguagePack; end"
        lower_and_canonicalize(mutated, expected_descriptor)
      end,
      "runtime_authority_claim_rejected" => capture_error do
        mutated = deep_copy(source_ast)
        temporal = mutated.fetch("slots").find { |slot| slot.fetch("slot") == "temporal" }
        temporal["runtime_authority_claim"] = true
        lower_and_canonicalize(mutated, expected_descriptor)
      end,
      "missing_implementation_id" => capture_error do
        mutated = deep_copy(source_ast)
        mutated.fetch("slots").first.delete("implementation")
        lower_and_canonicalize(mutated, expected_descriptor)
      end,
      "duplicate_slot" => capture_error do
        mutated = deep_copy(source_ast)
        mutated.fetch("slots") << mutated.fetch("slots").first.merge("pack" => "CoreLanguagePackCopy")
        lower_and_canonicalize(mutated, expected_descriptor)
      end,
      "helper_only_pack_rejected" => capture_error do
        mutated = deep_copy(source_ast)
        mutated.fetch("slots").first["owns_capabilities"] = []
        lower_and_canonicalize(mutated, expected_descriptor)
      end
    }
  end

  def build_checks(lowering_model, lowered_descriptor, expected_descriptor, negative_results, schema_run, schema_summary)
    {
      "input.schema_passed" => schema_run.fetch("exit_status").zero? && schema_summary.fetch("status") == "PASS",
      "model.syntax_not_authorized" => lowering_model.dig("source_status", "syntax_authorized") == false &&
        lowering_model.dig("source_status", "parser_implemented") == false,
      "model.every_lowering_rule_targets_descriptor" => lowering_model.fetch("lowering_rules").values.all? do |target|
        target.include?("profile_descriptor") || target.include?("pack_descriptor") || target.include?("profile_source")
      end,
      "lowering.produces_descriptor_kind" => lowered_descriptor.fetch("kind") == "compiler_profile_descriptor",
      "lowering.matches_expected_pack_slots" => lowered_descriptor.fetch("pack_descriptors").map { |pack| pack.fetch("slot") } ==
        expected_descriptor.fetch("pack_descriptors").map { |pack| pack.fetch("slot") },
      "lowering.schema_ref_preserved" => lowered_descriptor.fetch("schema_ref") == expected_descriptor.fetch("schema_ref"),
      "lowering.digest_is_descriptor_digest" => lowered_descriptor.fetch("descriptor_digest").start_with?("compiler_profile_descriptor/sha256:"),
      "negative.parser_implementation_out_of_scope" => negative_results.dig("parser_implementation_out_of_scope", "code") == "lowering.parser_implementation_out_of_scope",
      "negative.syntax_authority_out_of_scope" => negative_results.dig("syntax_authority_out_of_scope", "code") == "lowering.syntax_authority_out_of_scope",
      "negative.implementation_body_out_of_scope" => negative_results.dig("implementation_body_out_of_scope", "code") == "lowering.implementation_body_out_of_scope",
      "negative.runtime_authority_claim_rejected" => negative_results.dig("runtime_authority_claim_rejected", "code") == "lowering.runtime_authority_claim_rejected",
      "negative.missing_implementation_id" => negative_results.dig("missing_implementation_id", "code") == "lowering.missing_implementation_id",
      "negative.duplicate_slot" => negative_results.dig("duplicate_slot", "code") == "lowering.duplicate_slot",
      "negative.helper_only_pack_rejected" => negative_results.dig("helper_only_pack_rejected", "code") == "lowering.helper_only_pack_rejected"
    }
  end

  def capture_error
    yield
    { "status" => "accepted_unexpectedly" }
  rescue LoweringError => e
    {
      "status" => "rejected",
      "code" => e.code,
      "message" => e.message,
      "details" => e.details
    }
  end

  def descriptor_digest(value)
    "compiler_profile_descriptor/sha256:#{Digest::SHA256.hexdigest(JSON.generate(sort_value(value)))[0, 24]}"
  end

  def digest(value)
    "sha256:#{Digest::SHA256.hexdigest(JSON.generate(sort_value(value)))}"
  end

  def deep_copy(value)
    JSON.parse(JSON.generate(value))
  end

  def read_json(path)
    JSON.parse(File.read(path))
  end

  def write_json(path, value)
    File.write(path, "#{JSON.pretty_generate(value)}\n")
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
    puts "#{summary.fetch("status")} profile_source_lowering_target"
    summary.fetch("checks").each do |label, ok|
      puts "#{label}: #{ok ? "ok" : "FAIL"}"
    end
    puts "descriptor_digest: #{summary.fetch("descriptor_digest")}"
    puts "lowering_model: #{summary.fetch("lowering_model_path")}"
    puts "lowered_descriptor: #{summary.fetch("lowered_descriptor_path")}"
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = ProfileSourceLoweringTargetProof.run
exit(success ? 0 : 1)
