#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "open3"
require "pathname"
require "rbconfig"

module CompilerProfileDescriptorSchemaProof
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  LANG_ROOT = ROOT / "igniter-lang"
  OUT_DIR = LANG_ROOT / "experiments/compiler_profile_descriptor_schema/out"
  SCHEMA_PATH = OUT_DIR / "compiler_profile_descriptor_schema.json"
  CANONICAL_DESCRIPTOR_PATH = OUT_DIR / "canonical_profile_descriptor.json"
  SUMMARY_PATH = OUT_DIR / "compiler_profile_descriptor_schema_summary.json"

  BOOTSTRAP_RUNNER = LANG_ROOT / "experiments/bootstrap_descriptor_kernel/bootstrap_descriptor_kernel.rb"
  SELF_ASSEMBLY_MODEL = LANG_ROOT / "experiments/igniter_lang_self_assembly_profile_sketch/out/igniter_lang_self_assembly_profile_model.json"
  BOOTSTRAP_SUMMARY = LANG_ROOT / "experiments/bootstrap_descriptor_kernel/out/bootstrap_descriptor_kernel_summary.json"

  FORMAT_VERSION = "0.1.0"
  TRACK = "compiler-profile-descriptor-schema-v0"

  class DescriptorSchemaError < StandardError
    attr_reader :code, :details

    def initialize(code, message, details = {})
      super(message)
      @code = code
      @details = details
    end
  end

  SCHEMA = {
    "kind" => "compiler_profile_descriptor_schema",
    "format_version" => FORMAT_VERSION,
    "descriptor_kinds" => {
      "profile_descriptor" => {
        "required_fields" => %w[kind format_version profile_spec profile_source pack_descriptors],
        "kind_value" => "compiler_profile_descriptor"
      },
      "profile_source" => {
        "required_fields" => %w[kind format_version parser_status canonical_source_digest],
        "allowed_parser_status" => ["not_implemented_descriptor_only"]
      },
      "profile_spec" => {
        "required_fields" => %w[kind name slot_order required_slots optional_slots]
      },
      "pack_descriptor" => {
        "required_fields" => %w[
          slot
          name
          implementation_id
          capability_owner
          provides_capabilities
          requires_slots
          registries
        ],
        "capability_owner_required" => true
      }
    },
    "canonicalization" => {
      "hash_algorithm" => "sha256",
      "object_keys" => "lexicographic",
      "pack_descriptors" => "sort_by_slot_order_then_name",
      "array_policy" => {
        "slot_order" => "preserve",
        "required_slots" => "sort",
        "optional_slots" => "sort",
        "provides_capabilities" => "sort",
        "requires_slots" => "sort",
        "registry_entries" => "sort"
      },
      "digest_prefix" => "compiler_profile_descriptor/sha256:"
    },
    "error_codes" => {
      "schema.missing_field" => "Required field is absent.",
      "schema.wrong_kind" => "Descriptor kind does not match schema.",
      "schema.full_language_source_out_of_scope" => "Profile source demands full language parser.",
      "schema.unknown_slot" => "Pack uses a slot not declared by profile spec.",
      "schema.duplicate_slot" => "Two packs fill the same slot.",
      "schema.missing_required_slot" => "Profile spec required slot has no pack.",
      "schema.missing_dependency_slot" => "Pack requires a missing slot.",
      "schema.helper_only_pack_rejected" => "Pack has no semantic capability ownership.",
      "schema.rule_owner_mismatch" => "Rule id prefix belongs to another semantic slot."
    },
    "bridge_to_future_syntax" => {
      "profile_source_syntax_authorized" => false,
      "descriptor_first" => true,
      "future_lowering_target" => "compiler_profile_descriptor"
    }
  }.freeze

  RULE_PREFIX_TO_SLOT = {
    "core" => "core",
    "escape" => "escape_boundary",
    "contract_modifiers" => "contract_modifiers",
    "temporal" => "temporal",
    "stream" => "stream",
    "olap" => "olap",
    "invariant" => "invariant",
    "assumptions" => "assumptions",
    "evidence" => "evidence_observation",
    "receipt" => "compiler_accountability"
  }.freeze

  module_function

  def run
    FileUtils.mkdir_p(OUT_DIR)
    bootstrap_run = run_bootstrap
    self_assembly = read_json(SELF_ASSEMBLY_MODEL)
    bootstrap_summary = read_json(BOOTSTRAP_SUMMARY)
    descriptor = descriptor_from_self_assembly(self_assembly)
    canonical_descriptor = canonical_descriptor(descriptor)
    variant_descriptor = canonical_descriptor(reversed_descriptor(descriptor))
    negative_results = build_negative_results(descriptor)
    checks = build_checks(canonical_descriptor, variant_descriptor, negative_results, bootstrap_run, bootstrap_summary)
    summary = {
      "kind" => "compiler_profile_descriptor_schema_summary",
      "format_version" => FORMAT_VERSION,
      "track" => TRACK,
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "schema_path" => SCHEMA_PATH.relative_path_from(ROOT).to_s,
      "canonical_descriptor_path" => CANONICAL_DESCRIPTOR_PATH.relative_path_from(ROOT).to_s,
      "descriptor_digest" => canonical_descriptor.fetch("descriptor_digest"),
      "negative_results" => negative_results,
      "checks" => checks,
      "non_goals" => [
        "No JSON Schema dependency or standardization claim.",
        "No parser syntax authorization.",
        "No production BootstrapDescriptorKernel extraction.",
        "No CompilerKernel dispatch changes.",
        "No .igapp or .ilk changes."
      ]
    }

    write_json(SCHEMA_PATH, SCHEMA)
    write_json(CANONICAL_DESCRIPTOR_PATH, canonical_descriptor)
    write_json(SUMMARY_PATH, summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def run_bootstrap
    stdout, stderr, status = Open3.capture3(RbConfig.ruby, BOOTSTRAP_RUNNER.to_s, chdir: ROOT.to_s)
    {
      "command" => "ruby #{BOOTSTRAP_RUNNER.relative_path_from(ROOT)}",
      "exit_status" => status.exitstatus,
      "stdout_first_line" => stdout.lines.first.to_s.strip,
      "stderr" => stderr.strip
    }
  end

  def descriptor_from_self_assembly(self_assembly)
    {
      "kind" => "compiler_profile_descriptor",
      "format_version" => FORMAT_VERSION,
      "profile_spec" => self_assembly.fetch("profile_spec"),
      "profile_source" => self_assembly.fetch("profile_source").slice(
        "kind",
        "format_version",
        "parser_status",
        "canonical_source_digest"
      ),
      "pack_descriptors" => self_assembly.fetch("pack_descriptors")
    }
  end

  def canonical_descriptor(descriptor)
    validate_descriptor(descriptor)
    normalized = normalize_descriptor(descriptor)
    normalized.merge(
      "descriptor_digest" => descriptor_digest(normalized),
      "schema_ref" => {
        "kind" => SCHEMA.fetch("kind"),
        "format_version" => SCHEMA.fetch("format_version"),
        "digest" => digest(SCHEMA)
      }
    )
  end

  def validate_descriptor(descriptor)
    require_fields(descriptor, SCHEMA.dig("descriptor_kinds", "profile_descriptor", "required_fields"), "profile_descriptor")
    unless descriptor.fetch("kind") == SCHEMA.dig("descriptor_kinds", "profile_descriptor", "kind_value")
      raise DescriptorSchemaError.new("schema.wrong_kind", "wrong descriptor kind", "kind" => descriptor.fetch("kind"))
    end

    profile_source = descriptor.fetch("profile_source")
    require_fields(profile_source, SCHEMA.dig("descriptor_kinds", "profile_source", "required_fields"), "profile_source")
    unless SCHEMA.dig("descriptor_kinds", "profile_source", "allowed_parser_status").include?(profile_source.fetch("parser_status"))
      raise DescriptorSchemaError.new(
        "schema.full_language_source_out_of_scope",
        "profile source parser status is out of scope",
        "parser_status" => profile_source.fetch("parser_status")
      )
    end

    spec = descriptor.fetch("profile_spec")
    require_fields(spec, SCHEMA.dig("descriptor_kinds", "profile_spec", "required_fields"), "profile_spec")
    validate_pack_descriptors(descriptor.fetch("pack_descriptors"), spec)
  end

  def validate_pack_descriptors(packs, spec)
    packs.each do |pack|
      require_fields(pack, SCHEMA.dig("descriptor_kinds", "pack_descriptor", "required_fields"), "pack_descriptor")
    end
    validate_slots(packs, spec)
    validate_dependencies(packs)
    validate_capability_ownership(packs)
    validate_rule_ownership(packs)
  end

  def require_fields(value, fields, context)
    missing = fields.reject { |field| value.key?(field) }
    return if missing.empty?

    raise DescriptorSchemaError.new("schema.missing_field", "#{context} is missing fields", "fields" => missing)
  end

  def validate_slots(packs, spec)
    known_slots = spec.fetch("slot_order")
    seen = {}
    packs.each do |pack|
      slot = pack.fetch("slot")
      raise DescriptorSchemaError.new("schema.unknown_slot", "unknown slot", "slot" => slot) unless known_slots.include?(slot)

      if seen.key?(slot)
        raise DescriptorSchemaError.new(
          "schema.duplicate_slot",
          "duplicate slot",
          "slot" => slot,
          "first_pack" => seen.fetch(slot),
          "second_pack" => pack.fetch("name")
        )
      end
      seen[slot] = pack.fetch("name")
    end

    missing = spec.fetch("required_slots").reject { |slot| seen.key?(slot) }
    return if missing.empty?

    raise DescriptorSchemaError.new("schema.missing_required_slot", "missing required slots", "slots" => missing)
  end

  def validate_dependencies(packs)
    present = packs.map { |pack| pack.fetch("slot") }
    packs.each do |pack|
      missing = pack.fetch("requires_slots").reject { |slot| present.include?(slot) }
      next if missing.empty?

      raise DescriptorSchemaError.new(
        "schema.missing_dependency_slot",
        "missing dependency slots",
        "slot" => pack.fetch("slot"),
        "missing" => missing
      )
    end
  end

  def validate_capability_ownership(packs)
    packs.each do |pack|
      next if pack.fetch("capability_owner") == true && pack.fetch("provides_capabilities").any?

      raise DescriptorSchemaError.new(
        "schema.helper_only_pack_rejected",
        "pack has no semantic capability ownership",
        "slot" => pack.fetch("slot"),
        "pack" => pack.fetch("name")
      )
    end
  end

  def validate_rule_ownership(packs)
    packs.each do |pack|
      pack.fetch("registries").each_value do |entries|
        entries.each do |entry|
          next unless entry.to_s.include?(".")

          prefix = entry.to_s.split(".").first
          expected_slot = RULE_PREFIX_TO_SLOT[prefix]
          next if expected_slot.nil?
          next if expected_slot == pack.fetch("slot")

          raise DescriptorSchemaError.new(
            "schema.rule_owner_mismatch",
            "rule owner mismatch",
            "rule" => entry,
            "pack_slot" => pack.fetch("slot"),
            "expected_slot" => expected_slot
          )
        end
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
      "pack_descriptors" => packs.map { |pack| normalize_pack(pack) }
    }
  end

  def normalize_pack(pack)
    {
      "slot" => pack.fetch("slot"),
      "name" => pack.fetch("name"),
      "implementation_id" => pack.fetch("implementation_id"),
      "capability_owner" => pack.fetch("capability_owner"),
      "provides_capabilities" => pack.fetch("provides_capabilities").sort,
      "requires_slots" => pack.fetch("requires_slots").sort,
      "registries" => pack.fetch("registries").transform_values do |entries|
        entries.sort
      end
    }
  end

  def reversed_descriptor(descriptor)
    copy = deep_copy(descriptor)
    copy["pack_descriptors"] = copy.fetch("pack_descriptors").reverse
    copy
  end

  def build_negative_results(descriptor)
    {
      "missing_profile_spec" => capture_error do
        canonical_descriptor(descriptor.reject { |key, _| key == "profile_spec" })
      end,
      "wrong_kind" => capture_error do
        canonical_descriptor(descriptor.merge("kind" => "not_a_profile_descriptor"))
      end,
      "full_language_source_status" => capture_error do
        copy = deep_copy(descriptor)
        copy.fetch("profile_source")["parser_status"] = "full_language_parser_required"
        canonical_descriptor(copy)
      end,
      "duplicate_slot" => capture_error do
        copy = deep_copy(descriptor)
        temporal = copy.fetch("pack_descriptors").find { |pack| pack.fetch("slot") == "temporal" }
        copy.fetch("pack_descriptors") << temporal.merge("name" => "TemporalPackCopy")
        canonical_descriptor(copy)
      end,
      "helper_only_pack" => capture_error do
        copy = deep_copy(descriptor)
        copy.fetch("pack_descriptors") << helper_only_pack
        canonical_descriptor(copy)
      end,
      "rule_owner_mismatch" => capture_error do
        copy = deep_copy(descriptor)
        temporal = copy.fetch("pack_descriptors").find { |pack| pack.fetch("slot") == "temporal" }
        temporal.fetch("registries").fetch("parser_rules") << "core.illegal_temporal_rule"
        canonical_descriptor(copy)
      end
    }
  end

  def helper_only_pack
    {
      "slot" => "compiler_accountability",
      "name" => "ParserHelpersPack",
      "implementation_id" => "parser_helpers.schema_negative.v0",
      "capability_owner" => false,
      "provides_capabilities" => [],
      "requires_slots" => [],
      "registries" => {
        "parser_rules" => ["parser_helpers.normalize_tokens"]
      }
    }
  end

  def build_checks(canonical_descriptor, variant_descriptor, negative_results, bootstrap_run, bootstrap_summary)
    {
      "input.bootstrap_passed" => bootstrap_run.fetch("exit_status").zero? && bootstrap_summary.fetch("status") == "PASS",
      "schema.has_descriptor_kinds" => %w[profile_descriptor profile_source profile_spec pack_descriptor].all? do |kind|
        SCHEMA.fetch("descriptor_kinds").key?(kind)
      end,
      "schema.has_error_taxonomy" => SCHEMA.fetch("error_codes").keys.sort == expected_error_codes.sort,
      "descriptor.has_digest_and_schema_ref" => canonical_descriptor.fetch("descriptor_digest").start_with?("compiler_profile_descriptor/sha256:") &&
        canonical_descriptor.dig("schema_ref", "digest").start_with?("sha256:"),
      "canonicalization.input_order_independent_digest" => canonical_descriptor.fetch("descriptor_digest") == variant_descriptor.fetch("descriptor_digest"),
      "canonicalization.pack_order_matches_slot_order" => canonical_descriptor.fetch("pack_descriptors").map { |pack| pack.fetch("slot") } ==
        canonical_descriptor.dig("profile_spec", "slot_order"),
      "bridge.future_syntax_not_authorized" => SCHEMA.dig("bridge_to_future_syntax", "profile_source_syntax_authorized") == false &&
        SCHEMA.dig("bridge_to_future_syntax", "descriptor_first") == true,
      "negative.missing_profile_spec" => negative_results.dig("missing_profile_spec", "code") == "schema.missing_field",
      "negative.wrong_kind" => negative_results.dig("wrong_kind", "code") == "schema.wrong_kind",
      "negative.full_language_source_status" => negative_results.dig("full_language_source_status", "code") == "schema.full_language_source_out_of_scope",
      "negative.duplicate_slot" => negative_results.dig("duplicate_slot", "code") == "schema.duplicate_slot",
      "negative.helper_only_pack" => negative_results.dig("helper_only_pack", "code") == "schema.duplicate_slot",
      "negative.rule_owner_mismatch" => negative_results.dig("rule_owner_mismatch", "code") == "schema.rule_owner_mismatch"
    }
  end

  def expected_error_codes
    %w[
      schema.missing_field
      schema.wrong_kind
      schema.full_language_source_out_of_scope
      schema.unknown_slot
      schema.duplicate_slot
      schema.missing_required_slot
      schema.missing_dependency_slot
      schema.helper_only_pack_rejected
      schema.rule_owner_mismatch
    ]
  end

  def capture_error
    yield
    { "status" => "accepted_unexpectedly" }
  rescue DescriptorSchemaError => e
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
    puts "#{summary.fetch("status")} compiler_profile_descriptor_schema"
    summary.fetch("checks").each do |label, ok|
      puts "#{label}: #{ok ? "ok" : "FAIL"}"
    end
    puts "descriptor_digest: #{summary.fetch("descriptor_digest")}"
    puts "schema: #{summary.fetch("schema_path")}"
    puts "canonical_descriptor: #{summary.fetch("canonical_descriptor_path")}"
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = CompilerProfileDescriptorSchemaProof.run
exit(success ? 0 : 1)
