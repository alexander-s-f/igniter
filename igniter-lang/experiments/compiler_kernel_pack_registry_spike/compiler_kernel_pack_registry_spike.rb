#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "pathname"

module CompilerKernelPackRegistrySpike
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  CONTRACT_MODIFIERS_SUMMARY = ROOT / "igniter-lang/experiments/contract_modifiers_pack_native_boundary/out/contract_modifiers_pack_native_boundary_summary.json"
  OUT_DIR = ROOT / "igniter-lang/experiments/compiler_kernel_pack_registry_spike/out"
  SUMMARY_PATH = OUT_DIR / "compiler_kernel_pack_registry_spike_summary.json"

  FORMAT_VERSION = "0.1.0"
  TRACK = "compiler-kernel-pack-registry-spike-v0"

  class KernelError < StandardError; end
  class DuplicatePackError < KernelError; end
  class MissingDependencyError < KernelError; end
  class DuplicateRegistryKeyError < KernelError; end
  class FrozenKernelError < KernelError; end

  class Registry
    def initialize(name)
      @name = name
      @entries = {}
      @frozen = false
    end

    def register(key, value)
      raise FrozenKernelError, "#{@name} is frozen" if @frozen

      normalized = key.to_s
      raise DuplicateRegistryKeyError, "#{@name} already has #{normalized}" if @entries.key?(normalized)

      @entries[normalized] = value
    end

    def to_h
      @entries.dup
    end

    def freeze!
      @frozen = true
      @entries.freeze
      self
    end

    def frozen?
      @frozen
    end
  end

  class CompilerKernel
    attr_reader :pack_manifests, :registries

    def initialize
      @pack_manifests = []
      @registries = {
        "parser_rules" => Registry.new("parser_rules"),
        "classifier_rules" => Registry.new("classifier_rules"),
        "typechecker_rules" => Registry.new("typechecker_rules"),
        "semanticir_handlers" => Registry.new("semanticir_handlers"),
        "assembler_hooks" => Registry.new("assembler_hooks"),
        "oof_descriptors" => Registry.new("oof_descriptors"),
        "fragment_classes" => Registry.new("fragment_classes")
      }
      @finalized = false
    end

    def install(manifest)
      raise FrozenKernelError, "kernel already finalized" if finalized?

      name = manifest.fetch("name")
      raise DuplicatePackError, "pack already installed: #{name}" if pack_installed?(name)

      missing = manifest.fetch("requires_packs", []).reject { |dep| pack_installed?(dep) }
      raise MissingDependencyError, "#{name} missing dependencies: #{missing.join(", ")}" unless missing.empty?

      register_manifest_entries(manifest)
      @pack_manifests << manifest
      self
    end

    def finalize
      registries.each_value(&:freeze!)
      @finalized = true
      profile
    end

    def finalized?
      @finalized
    end

    private

    def pack_installed?(name)
      @pack_manifests.any? { |manifest| manifest.fetch("name") == name }
    end

    def register_manifest_entries(manifest)
      register_list("parser_rules", manifest.dig("parser_rules", "contract_modifier_keywords") || [])
      register_list("classifier_rules", manifest.dig("classifier_rules", "oof_checks") || [])
      register_list("typechecker_rules", manifest.dig("typechecker_rules", "propagates_oof") || [])
      register_list("semanticir_handlers", manifest.dig("semanticir_handlers", "contract_ir_fields") || [])
      register_list("assembler_hooks", manifest.fetch("assembler_hooks", {}).keys)
      register_list("oof_descriptors", manifest.fetch("oof_descriptors", {}).keys)
      register_list("fragment_classes", manifest.fetch("fragment_classes", []))
    end

    def register_list(registry_name, values)
      values.each { |value| registries.fetch(registry_name).register(value, true) }
    end

    def profile
      payload = {
        "kind" => "compiler_kernel_profile_spike",
        "format_version" => FORMAT_VERSION,
        "pack_names" => pack_manifests.map { |manifest| manifest.fetch("name") },
        "implementation_ids" => pack_manifests.to_h { |manifest| [manifest.fetch("name"), manifest.fetch("implementation_id")] },
        "provided_capabilities" => pack_manifests.flat_map { |manifest| manifest.fetch("provides_capabilities", []) }.uniq.sort,
        "registries" => registries.transform_values(&:to_h),
        "dispatch_mode" => "registry_only_no_compiler_dispatch",
        "igapp_manifest_changes" => []
      }
      payload.merge("profile_id" => CompilerKernelPackRegistrySpike.profile_id(payload))
    end
  end

  SUPPORT_MANIFESTS = [
    {
      "kind" => "compiler_pack_manifest",
      "format_version" => FORMAT_VERSION,
      "name" => "CoreLanguagePack",
      "implementation_id" => "core_language.registry_spike_stub.v0",
      "requires_packs" => [],
      "provides_capabilities" => %w[core_language],
      "parser_rules" => { "contract_modifier_keywords" => [] },
      "classifier_rules" => { "oof_checks" => [] },
      "typechecker_rules" => { "propagates_oof" => [] },
      "semanticir_handlers" => { "contract_ir_fields" => [] },
      "assembler_hooks" => {},
      "oof_descriptors" => {},
      "fragment_classes" => ["core"]
    },
    {
      "kind" => "compiler_pack_manifest",
      "format_version" => FORMAT_VERSION,
      "name" => "OOFRegistry",
      "implementation_id" => "oof_registry.registry_spike_stub.v0",
      "requires_packs" => [],
      "provides_capabilities" => %w[oof_registry],
      "parser_rules" => { "contract_modifier_keywords" => [] },
      "classifier_rules" => { "oof_checks" => [] },
      "typechecker_rules" => { "propagates_oof" => [] },
      "semanticir_handlers" => { "contract_ir_fields" => [] },
      "assembler_hooks" => {},
      "oof_descriptors" => {},
      "fragment_classes" => ["oof"]
    },
    {
      "kind" => "compiler_pack_manifest",
      "format_version" => FORMAT_VERSION,
      "name" => "FragmentRegistry",
      "implementation_id" => "fragment_registry.registry_spike_stub.v0",
      "requires_packs" => [],
      "provides_capabilities" => %w[fragment_registry],
      "parser_rules" => { "contract_modifier_keywords" => [] },
      "classifier_rules" => { "oof_checks" => [] },
      "typechecker_rules" => { "propagates_oof" => [] },
      "semanticir_handlers" => { "contract_ir_fields" => [] },
      "assembler_hooks" => {},
      "oof_descriptors" => {},
      "fragment_classes" => %w[escape temporal stream epistemic]
    },
    {
      "kind" => "compiler_pack_manifest",
      "format_version" => FORMAT_VERSION,
      "name" => "EscapeBoundaryPack",
      "implementation_id" => "escape_boundary.registry_spike_stub.v0",
      "requires_packs" => %w[CoreLanguagePack OOFRegistry FragmentRegistry],
      "provides_capabilities" => %w[escape_boundary],
      "parser_rules" => { "contract_modifier_keywords" => [] },
      "classifier_rules" => { "oof_checks" => [] },
      "typechecker_rules" => { "propagates_oof" => [] },
      "semanticir_handlers" => { "contract_ir_fields" => [] },
      "assembler_hooks" => {},
      "oof_descriptors" => {},
      "fragment_classes" => []
    }
  ].freeze

  module_function

  def run
    FileUtils.mkdir_p(OUT_DIR)
    contract_modifiers_manifest = read_contract_modifiers_manifest
    positive_profile = build_positive_profile(contract_modifiers_manifest)
    variant_profile = build_positive_profile(
      contract_modifiers_manifest.merge("implementation_id" => "contract_modifiers.pack_boundary_descriptor.v1")
    )
    negative_results = build_negative_results(contract_modifiers_manifest)
    checks = build_checks(positive_profile, variant_profile, negative_results)
    summary = {
      "kind" => "compiler_kernel_pack_registry_spike_summary",
      "format_version" => FORMAT_VERSION,
      "track" => TRACK,
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "positive_profile" => positive_profile,
      "variant_profile" => {
        "profile_id" => variant_profile.fetch("profile_id"),
        "changed_implementation" => "ContractModifiersPack"
      },
      "negative_results" => negative_results,
      "checks" => checks,
      "non_goals" => [
        "No compiler pass dispatch.",
        "No CompilerOrchestrator changes.",
        "No .igapp manifest changes.",
        "No production package extraction."
      ]
    }
    write_json(SUMMARY_PATH, summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def read_contract_modifiers_manifest
    summary = read_json(CONTRACT_MODIFIERS_SUMMARY)
    manifest = summary.fetch("pack_manifest")
    manifest.reject { |key, _value| key == "manifest_id" }
  end

  def build_positive_profile(contract_modifiers_manifest)
    kernel = CompilerKernel.new
    SUPPORT_MANIFESTS.each { |manifest| kernel.install(manifest) }
    kernel.install(contract_modifiers_manifest)
    kernel.finalize
  end

  def build_negative_results(contract_modifiers_manifest)
    {
      "duplicate_pack_name" => capture_error do
        kernel = CompilerKernel.new
        kernel.install(SUPPORT_MANIFESTS.first)
        kernel.install(SUPPORT_MANIFESTS.first)
      end,
      "missing_dependency" => capture_error do
        CompilerKernel.new.install(contract_modifiers_manifest)
      end,
      "duplicate_registry_key" => capture_error do
        manifest = contract_modifiers_manifest.merge("name" => "ContractModifiersPackCopy")
        kernel = CompilerKernel.new
        SUPPORT_MANIFESTS.each { |support| kernel.install(support) }
        kernel.install(contract_modifiers_manifest)
        kernel.install(manifest)
      end,
      "frozen_after_finalize" => capture_error do
        kernel = CompilerKernel.new
        SUPPORT_MANIFESTS.each { |support| kernel.install(support) }
        kernel.install(contract_modifiers_manifest)
        kernel.finalize
        kernel.install(contract_modifiers_manifest.merge("name" => "LatePack"))
      end
    }
  end

  def capture_error
    yield
    { "raised" => false, "class" => nil, "message" => nil }
  rescue KernelError => e
    { "raised" => true, "class" => e.class.name.split("::").last, "message" => e.message }
  end

  def build_checks(positive_profile, variant_profile, negative_results)
    registries = positive_profile.fetch("registries")
    {
      "positive.profile_kind" => positive_profile.fetch("kind") == "compiler_kernel_profile_spike",
      "positive.dispatch_registry_only" => positive_profile.fetch("dispatch_mode") == "registry_only_no_compiler_dispatch",
      "positive.pack_order" => positive_profile.fetch("pack_names") == %w[
        CoreLanguagePack OOFRegistry FragmentRegistry EscapeBoundaryPack ContractModifiersPack
      ],
      "positive.contract_modifier_rules_registered" => registries.fetch("parser_rules").keys.sort == %w[
        effect irreversible observed privileged pure
      ],
      "positive.oof_m1_registered" => registries.fetch("oof_descriptors").key?("OOF-M1") &&
        registries.fetch("classifier_rules").key?("OOF-M1") &&
        registries.fetch("typechecker_rules").key?("OOF-M1"),
      "positive.fragment_classes_registered" => %w[core escape temporal stream epistemic oof].all? do |fragment|
        registries.fetch("fragment_classes").key?(fragment)
      end,
      "positive.no_igapp_manifest_changes" => positive_profile.fetch("igapp_manifest_changes").empty?,
      "fingerprint.implementation_id_changes_profile" => positive_profile.fetch("profile_id") != variant_profile.fetch("profile_id"),
      "negative.duplicate_pack_rejected" => error_class?(negative_results, "duplicate_pack_name", "DuplicatePackError"),
      "negative.missing_dependency_rejected" => error_class?(negative_results, "missing_dependency", "MissingDependencyError"),
      "negative.duplicate_registry_key_rejected" => error_class?(negative_results, "duplicate_registry_key", "DuplicateRegistryKeyError"),
      "negative.frozen_kernel_rejects_install" => error_class?(negative_results, "frozen_after_finalize", "FrozenKernelError")
    }
  end

  def error_class?(negative_results, key, expected_class)
    result = negative_results.fetch(key)
    result.fetch("raised") == true && result.fetch("class") == expected_class
  end

  def profile_id(payload)
    "compiler_kernel_profile_spike/sha256:#{Digest::SHA256.hexdigest(canonical_json(payload))[0, 24]}"
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
    puts "#{summary.fetch("status")} compiler_kernel_pack_registry_spike"
    summary.fetch("checks").each do |label, ok|
      puts "#{label}: #{ok ? "ok" : "FAIL"}"
    end
    puts "profile_id: #{summary.fetch("positive_profile").fetch("profile_id")}"
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = CompilerKernelPackRegistrySpike.run
exit(success ? 0 : 1)
