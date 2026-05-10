#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "open3"
require "pathname"
require "rbconfig"

module BootstrapDescriptorKernelProof
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  LANG_ROOT = ROOT / "igniter-lang"
  OUT_DIR = LANG_ROOT / "experiments/bootstrap_descriptor_kernel/out"
  MANIFEST_PATH = OUT_DIR / "bootstrap_compiler_profile_manifest.json"
  SUMMARY_PATH = OUT_DIR / "bootstrap_descriptor_kernel_summary.json"

  SELF_ASSEMBLY_RUNNER = LANG_ROOT / "experiments/igniter_lang_self_assembly_profile_sketch/igniter_lang_self_assembly_profile_sketch.rb"
  SELF_ASSEMBLY_MODEL = LANG_ROOT / "experiments/igniter_lang_self_assembly_profile_sketch/out/igniter_lang_self_assembly_profile_model.json"
  SELF_ASSEMBLY_SUMMARY = LANG_ROOT / "experiments/igniter_lang_self_assembly_profile_sketch/out/igniter_lang_self_assembly_profile_sketch_summary.json"

  FORMAT_VERSION = "0.1.0"
  TRACK = "bootstrap-descriptor-kernel-v0"

  class KernelError < StandardError
    attr_reader :code, :details

    def initialize(code, message, details = {})
      super(message)
      @code = code
      @details = details
    end
  end

  class BootstrapDescriptorKernel
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

    def initialize(profile_spec)
      @profile_spec = profile_spec
    end

    def assemble(profile_source:, pack_descriptors:)
      validate_profile_source(profile_source)
      validate_slots(pack_descriptors)
      validate_dependencies(pack_descriptors)
      validate_capability_ownership(pack_descriptors)
      validate_rule_ownership(pack_descriptors)

      profile = {
        "kind" => "bootstrap_compiler_profile_manifest",
        "format_version" => FORMAT_VERSION,
        "profile_spec" => @profile_spec.fetch("name"),
        "source_digest" => profile_source.fetch("canonical_source_digest"),
        "slot_assignments" => slot_assignments(pack_descriptors),
        "registries" => registries(pack_descriptors),
        "bootstrap_seed" => bootstrap_seed_contract,
        "dispatch_mode" => "descriptor_validated_no_compiler_dispatch",
        "frozen" => true,
        "authority" => {
          "validates_descriptors" => true,
          "parses_full_language" => false,
          "self_hosted_compiler" => false,
          "runtime_execution_authority" => false
        }
      }
      profile.merge("profile_id" => BootstrapDescriptorKernelProof.profile_id(profile))
    end

    private

    def validate_profile_source(profile_source)
      return if profile_source.fetch("parser_status") == "not_implemented_descriptor_only"

      raise KernelError.new(
        "bootstrap.full_language_source_out_of_scope",
        "bootstrap kernel accepts descriptors, not full language source",
        "parser_status" => profile_source.fetch("parser_status")
      )
    end

    def validate_slots(packs)
      seen = {}
      known_slots = allowed_slots
      packs.each do |pack|
        slot = pack.fetch("slot")
        unless known_slots.include?(slot)
          raise KernelError.new("bootstrap.unknown_slot", "unknown slot #{slot}", "slot" => slot)
        end
        if seen.key?(slot)
          raise KernelError.new(
            "bootstrap.duplicate_slot",
            "slot #{slot} filled more than once",
            "slot" => slot,
            "first_pack" => seen.fetch(slot),
            "second_pack" => pack.fetch("name")
          )
        end
        seen[slot] = pack.fetch("name")
      end

      missing = @profile_spec.fetch("required_slots").reject { |slot| seen.key?(slot) }
      return if missing.empty?

      raise KernelError.new("bootstrap.missing_required_slot", "missing required slots", "slots" => missing)
    end

    def validate_dependencies(packs)
      present = packs.map { |pack| pack.fetch("slot") }
      packs.each do |pack|
        missing = pack.fetch("requires_slots", []).reject { |slot| present.include?(slot) }
        next if missing.empty?

        raise KernelError.new(
          "bootstrap.missing_dependency_slot",
          "#{pack.fetch("slot")} has missing dependencies",
          "slot" => pack.fetch("slot"),
          "missing" => missing
        )
      end
    end

    def validate_capability_ownership(packs)
      packs.each do |pack|
        next if pack.fetch("capability_owner") == true && pack.fetch("provides_capabilities", []).any?

        raise KernelError.new(
          "bootstrap.helper_only_pack_rejected",
          "#{pack.fetch("name")} does not own a semantic capability",
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

            raise KernelError.new(
              "bootstrap.rule_owner_mismatch",
              "#{entry} belongs to #{expected_slot}, not #{pack.fetch("slot")}",
              "rule" => entry,
              "pack_slot" => pack.fetch("slot"),
              "expected_slot" => expected_slot
            )
          end
        end
      end
    end

    def allowed_slots
      @profile_spec.fetch("required_slots") + @profile_spec.fetch("optional_slots")
    end

    def slot_assignments(packs)
      @profile_spec.fetch("slot_order").filter_map do |slot|
        pack = packs.find { |descriptor| descriptor.fetch("slot") == slot }
        next unless pack

        [slot, pack.slice("name", "implementation_id", "provides_capabilities", "requires_slots")]
      end.to_h
    end

    def registries(packs)
      @profile_spec.fetch("slot_order").filter_map do |slot|
        pack = packs.find { |descriptor| descriptor.fetch("slot") == slot }
        next unless pack

        [slot, pack.fetch("registries")]
      end.to_h
    end

    def bootstrap_seed_contract
      {
        "trusted_seed" => true,
        "responsibilities" => [
          "descriptor_load",
          "slot_validation",
          "dependency_validation",
          "rule_ownership_validation",
          "profile_freeze",
          "profile_id_digest"
        ],
        "non_responsibilities" => [
          "full_language_parse",
          "user_contract_typecheck",
          "runtime_evaluate",
          "ledger_or_tbackend_access",
          "self_hosting_claim"
        ]
      }
    end
  end

  module_function

  def run
    FileUtils.mkdir_p(OUT_DIR)
    self_assembly_run = run_self_assembly
    self_assembly = read_json(SELF_ASSEMBLY_MODEL)
    self_assembly_summary = read_json(SELF_ASSEMBLY_SUMMARY)

    kernel = BootstrapDescriptorKernel.new(self_assembly.fetch("profile_spec"))
    manifest = kernel.assemble(
      profile_source: self_assembly.fetch("profile_source"),
      pack_descriptors: self_assembly.fetch("pack_descriptors")
    )
    variant = kernel.assemble(
      profile_source: self_assembly.fetch("profile_source"),
      pack_descriptors: reversed_pack_descriptors(self_assembly.fetch("pack_descriptors"))
    )
    negative_results = build_negative_results(kernel, self_assembly)
    checks = build_checks(manifest, variant, negative_results, self_assembly_summary, self_assembly_run)
    summary = {
      "kind" => "bootstrap_descriptor_kernel_summary",
      "format_version" => FORMAT_VERSION,
      "track" => TRACK,
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "manifest_path" => MANIFEST_PATH.relative_path_from(ROOT).to_s,
      "profile_id" => manifest.fetch("profile_id"),
      "negative_results" => negative_results,
      "checks" => checks,
      "non_goals" => [
        "No production BootstrapDescriptorKernel implementation.",
        "No self-hosted compiler implementation.",
        "No parser support for profile syntax.",
        "No CompilerKernel dispatch.",
        "No .igapp or .ilk changes.",
        "No runtime execution authority."
      ]
    }

    write_json(MANIFEST_PATH, manifest)
    write_json(SUMMARY_PATH, summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def run_self_assembly
    stdout, stderr, status = Open3.capture3(RbConfig.ruby, SELF_ASSEMBLY_RUNNER.to_s, chdir: ROOT.to_s)
    {
      "command" => "ruby #{SELF_ASSEMBLY_RUNNER.relative_path_from(ROOT)}",
      "exit_status" => status.exitstatus,
      "stdout_first_line" => stdout.lines.first.to_s.strip,
      "stderr" => stderr.strip
    }
  end

  def build_negative_results(kernel, self_assembly)
    source = self_assembly.fetch("profile_source")
    packs = self_assembly.fetch("pack_descriptors")
    {
      "missing_required_core" => capture_error do
        kernel.assemble(profile_source: source, pack_descriptors: packs.reject { |pack| pack.fetch("slot") == "core" })
      end,
      "duplicate_temporal_slot" => capture_error do
        temporal = packs.find { |pack| pack.fetch("slot") == "temporal" }
        kernel.assemble(profile_source: source, pack_descriptors: packs + [temporal.merge("name" => "TemporalPackCopy")])
      end,
      "helper_only_pack" => capture_error do
        kernel.assemble(profile_source: source, pack_descriptors: packs + [helper_only_pack])
      end,
      "missing_dependency" => capture_error do
        kernel.assemble(profile_source: source, pack_descriptors: packs.reject { |pack| pack.fetch("slot") == "fragment_registry" })
      end,
      "rule_owner_mismatch" => capture_error do
        mutated = packs.map do |pack|
          next pack unless pack.fetch("slot") == "temporal"

          registries = deep_copy(pack.fetch("registries"))
          registries.fetch("parser_rules") << "core.illegal_temporal_rule"
          pack.merge("registries" => registries)
        end
        kernel.assemble(profile_source: source, pack_descriptors: mutated)
      end,
      "full_language_source_rejected" => capture_error do
        kernel.assemble(
          profile_source: source.merge("parser_status" => "full_language_parser_required"),
          pack_descriptors: packs
        )
      end
    }
  end

  def helper_only_pack
    {
      "slot" => "parser_helpers",
      "name" => "ParserHelpersPack",
      "implementation_id" => "parser_helpers.bootstrap_negative.v0",
      "capability_owner" => false,
      "provides_capabilities" => [],
      "requires_slots" => [],
      "registries" => {
        "parser_rules" => ["parser_helpers.normalize_tokens"]
      }
    }
  end

  def build_checks(manifest, variant, negative_results, self_assembly_summary, self_assembly_run)
    {
      "input.self_assembly_passed" => self_assembly_run.fetch("exit_status").zero? &&
        self_assembly_summary.fetch("status") == "PASS",
      "manifest.kind_and_frozen" => manifest.fetch("kind") == "bootstrap_compiler_profile_manifest" &&
        manifest.fetch("frozen") == true,
      "manifest.required_slots_present" => %w[
        core
        oof_registry
        fragment_registry
        escape_boundary
        compiler_accountability
      ].all? { |slot| manifest.fetch("slot_assignments").key?(slot) },
      "manifest.seed_scope_explicit" => manifest.dig("bootstrap_seed", "trusted_seed") == true &&
        manifest.dig("authority", "parses_full_language") == false,
      "manifest.no_runtime_authority" => manifest.dig("authority", "runtime_execution_authority") == false,
      "determinism.input_order_independent_profile_id" => manifest.fetch("profile_id") == variant.fetch("profile_id"),
      "negative.missing_required_core_rejected" => negative_results.dig("missing_required_core", "code") == "bootstrap.missing_required_slot",
      "negative.duplicate_temporal_rejected" => negative_results.dig("duplicate_temporal_slot", "code") == "bootstrap.duplicate_slot",
      "negative.helper_only_pack_rejected" => negative_results.dig("helper_only_pack", "code") == "bootstrap.unknown_slot",
      "negative.missing_dependency_rejected" => negative_results.dig("missing_dependency", "code") == "bootstrap.missing_required_slot",
      "negative.rule_owner_mismatch_rejected" => negative_results.dig("rule_owner_mismatch", "code") == "bootstrap.rule_owner_mismatch",
      "negative.full_language_source_rejected" => negative_results.dig("full_language_source_rejected", "code") == "bootstrap.full_language_source_out_of_scope"
    }
  end

  def reversed_pack_descriptors(packs)
    packs.reverse
  end

  def capture_error
    yield
    { "status" => "accepted_unexpectedly" }
  rescue KernelError => e
    {
      "status" => "rejected",
      "code" => e.code,
      "message" => e.message,
      "details" => e.details
    }
  end

  def read_json(path)
    JSON.parse(File.read(path))
  end

  def write_json(path, value)
    File.write(path, "#{JSON.pretty_generate(value)}\n")
  end

  def deep_copy(value)
    JSON.parse(JSON.generate(value))
  end

  def profile_id(value)
    "bootstrap_compiler_profile/sha256:#{Digest::SHA256.hexdigest(JSON.generate(sort_value(value)))[0, 24]}"
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
    puts "#{summary.fetch("status")} bootstrap_descriptor_kernel"
    summary.fetch("checks").each do |label, ok|
      puts "#{label}: #{ok ? "ok" : "FAIL"}"
    end
    puts "profile_id: #{summary.fetch("profile_id")}"
    puts "manifest: #{summary.fetch("manifest_path")}"
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = BootstrapDescriptorKernelProof.run
exit(success ? 0 : 1)
