#!/usr/bin/env ruby
# frozen_string_literal: true

# Track: prop036-ruby-facade-profile-source-exposure-v0
# Card:  S3-R44-C3-I
# Agent: [Igniter-Lang Implementation Agent]
#
# Proof that the public Ruby facade IgniterLang.compile exposes a transport-only
# compiler_profile_source: keyword and forwards it unchanged to
# CompilerOrchestrator#compile.

require "digest"
require "fileutils"
require "json"
require "open3"
require "pathname"
require "rbconfig"

require_relative "../../lib/igniter_lang"

module Prop036RubyFacadeProfileSourceExposure
  ROOT = Pathname.new(File.expand_path("../..", __dir__))
  SOURCE_PATH = ROOT / "experiments/source_to_semanticir_fixture/add.ig"
  OUT_DIR = ROOT / "experiments/prop036_ruby_facade_profile_source_exposure/out"
  SUMMARY_PATH = OUT_DIR / "prop036_ruby_facade_profile_source_exposure_summary.json"

  FORMAT_VERSION = "0.1.0"
  PROFILE_NAMESPACE = "compiler_profile_unified"
  STAGE3_SPEC_NAME = "Stage3ProofCompilerProfileSpec"
  DESCRIPTOR_KIND = "compiler_profile_descriptor"
  SOURCE_KIND = "compiler_profile_id_source"

  CANONICAL_SLOT_ORDER = %w[
    core oof_registry fragment_registry escape_boundary contract_modifiers
    temporal stream olap invariant assumptions evidence_observation pipeline
  ].freeze

  PROOF_IMPL_IDS = {
    "core" => "core_language.proof_compiler_adapter.v0",
    "oof_registry" => "oof_registry.shadow_descriptor_registry.v0",
    "fragment_registry" => "fragment_registry.shadow_precedence_registry.v0",
    "escape_boundary" => "escape_boundary.current_monolith_adapter.v0",
    "contract_modifiers" => "contract_modifiers.current_monolith_adapter.v0",
    "temporal" => "temporal.metadata_only_guarded.v0",
    "stream" => "stream.current_monolith_adapter.v0",
    "olap" => "olap.current_monolith_adapter.v0",
    "invariant" => "invariant.current_monolith_adapter.v0",
    "assumptions" => "assumptions.spec_shadow.v0",
    "evidence_observation" => "evidence_observation.current_monolith_adapter.v0",
    "pipeline" => "pipeline.current_parser_surface_shadow.v0"
  }.freeze

  PROOF_PACK_NAMES = {
    "core" => "CoreLanguagePack",
    "oof_registry" => "OOFRegistry",
    "fragment_registry" => "FragmentRegistry",
    "escape_boundary" => "EscapeBoundaryPack",
    "contract_modifiers" => "ContractModifiersPack",
    "temporal" => "TemporalPack",
    "stream" => "StreamPack",
    "olap" => "OLAPPack",
    "invariant" => "InvariantPack",
    "assumptions" => "AssumptionsPack",
    "evidence_observation" => "EvidenceObservationPack",
    "pipeline" => "PipelinePack"
  }.freeze

  PROOF_DESCRIPTOR = {
    "kind" => DESCRIPTOR_KIND,
    "format_version" => FORMAT_VERSION,
    "profile_spec" => {
      "kind" => "compiler_profile_spec_candidate",
      "name" => STAGE3_SPEC_NAME,
      "slot_order" => CANONICAL_SLOT_ORDER
    },
    "pack_descriptors" => CANONICAL_SLOT_ORDER.map do |slot|
      {
        "slot" => slot,
        "name" => PROOF_PACK_NAMES.fetch(slot),
        "implementation_id" => PROOF_IMPL_IDS.fetch(slot)
      }
    end
  }.freeze

  FORBIDDEN_EXACT_JSON_TOKENS = %w[
    absent_legacy present_verified mismatch malformed missing_required
    runtime_ready evaluation_ready gate3_authorized runtime_authority
    production_ready
  ].freeze

  module_function

  def normalize(value)
    case value
    when Hash
      value.keys.sort.each_with_object({}) { |k, h| h[k.to_s] = normalize(value[k]) }
    when Array then value.map { |v| normalize(v) }
    when Symbol then value.to_s
    else value
    end
  end

  def canonical_json(value)
    JSON.generate(normalize(value))
  end

  def sha256_hex(data)
    Digest::SHA256.hexdigest(data)
  end

  def finalize_descriptor(descriptor)
    pack_descriptors = descriptor.fetch("pack_descriptors")
    slot_assignments = pack_descriptors.each_with_object({}) do |pack, h|
      h[pack.fetch("slot")] = {
        "implementation_id" => pack.fetch("implementation_id"),
        "pack_name" => pack.fetch("name")
      }
    end

    stable_descriptor = descriptor.reject { |k, _| k == "descriptor_digest" }
    descriptor_digest =
      "compiler_profile_descriptor/sha256:#{sha256_hex(canonical_json(stable_descriptor))[0, 24]}"
    payload = {
      "profile_namespace" => PROFILE_NAMESPACE,
      "format_version" => FORMAT_VERSION,
      "descriptor_digest" => descriptor_digest,
      "profile_kind" => STAGE3_SPEC_NAME,
      "slot_order" => CANONICAL_SLOT_ORDER,
      "slot_assignments" => slot_assignments
    }
    payload_hex = sha256_hex(canonical_json(payload))

    {
      "kind" => SOURCE_KIND,
      "format_version" => FORMAT_VERSION,
      "status" => "finalized",
      "profile_namespace" => PROFILE_NAMESPACE,
      "compiler_profile_id" => "#{PROFILE_NAMESPACE}/sha256:#{payload_hex[0, 24]}",
      "descriptor_digest" => descriptor_digest,
      "finalization_payload_digest" => "sha256:#{payload_hex}",
      "profile_kind" => STAGE3_SPEC_NAME,
      "slot_order" => CANONICAL_SLOT_ORDER,
      "slot_assignments" => slot_assignments,
      "dispatch_migration_authorized" => false,
      "runtime_authority_granted" => false
    }
  end

  def assert_pass(name)
    detail = yield
    { "check" => name, "result" => "PASS", "detail" => detail.to_s }
  rescue => e
    raise "FAIL [#{name}]: #{e.message}"
  end

  def assert_property(name, condition, detail)
    raise "FAIL [#{name}]: #{detail}" unless condition

    { "check" => name, "result" => "PASS", "detail" => detail.to_s }
  end

  def read_manifest(igapp_dir)
    JSON.parse(File.read(Pathname.new(igapp_dir) / "manifest.json"))
  end

  def run_facade_cases(canonical_source)
    results = []
    legacy_out = OUT_DIR / "legacy_facade.igapp"
    profiled_out = OUT_DIR / "profiled_facade.igapp"
    refused_out = OUT_DIR / "refused_facade.igapp"

    results << assert_pass("F1.facade_signature_has_optional_keyword") do
      params = IgniterLang.method(:compile).parameters
      param = params.find { |type, name| name == :compiler_profile_source && type == :key }
      raise "compiler_profile_source keyword not found" unless param

      "optional keyword present"
    end

    results << assert_pass("F2.nil_source_preserves_legacy_manifest") do
      result = IgniterLang.compile(
        source_path: SOURCE_PATH,
        out_path: legacy_out,
        compiler_profile_source: nil
      )
      raise "status=#{result.fetch("status").inspect}" unless result.fetch("status") == "ok"

      manifest = read_manifest(legacy_out)
      raise "compiler_profile_id present for nil source" if manifest.key?("compiler_profile_id")

      "status=ok and compiler_profile_id absent"
    end

    results << assert_pass("F3.valid_source_emits_profile_id") do
      result = IgniterLang.compile(
        source_path: SOURCE_PATH,
        out_path: profiled_out,
        compiler_profile_source: canonical_source
      )
      raise "status=#{result.fetch("status").inspect}" unless result.fetch("status") == "ok"

      manifest = read_manifest(profiled_out)
      actual = manifest.fetch("compiler_profile_id")
      expected = canonical_source.fetch("compiler_profile_id")
      raise "id mismatch #{actual.inspect} != #{expected.inspect}" unless actual == expected

      "status=ok and compiler_profile_id emitted"
    end

    invalid_source = canonical_source.merge("status" => "draft")
    refused_result = IgniterLang.compile(
      source_path: SOURCE_PATH,
      out_path: refused_out,
      compiler_profile_source: invalid_source
    )
    results << assert_property(
      "F4.invalid_source_refuses_before_artifact_output",
      refused_result.fetch("status") == "assembler_refused" &&
        !refused_out.exist? &&
        File.file?(refused_result.fetch("report_path")),
      "status=#{refused_result.fetch("status").inspect}"
    )

    results << assert_pass("F5.invalid_source_uses_existing_refusal_path") do
      combined = JSON.generate(refused_result.fetch("result")) +
                 JSON.generate(refused_result.fetch("compilation_report"))
      raise "compiler_profile_source refusal not found" unless combined.include?("compiler_profile_source.unfinalized")

      "assembler_refused via compiler_profile_source.unfinalized"
    end

    results << assert_pass("F6.facade_forwards_source_object_unchanged") do
      sentinel = Object.new
      sample_input = { "x" => 1 }
      sample_input_resolver = proc { {} }
      runtime_smoke = proc { { "trusted" => true } }
      spy = SpyOrchestrator.new
      returned = IgniterLang.compile(
        source_path: SOURCE_PATH,
        out_path: OUT_DIR / "spy_facade.igapp",
        sample_input: sample_input,
        sample_input_resolver: sample_input_resolver,
        runtime_smoke: runtime_smoke,
        compiler_profile_source: sentinel,
        orchestrator: spy
      )
      received = spy.received.fetch(:compiler_profile_source)
      raise "source object was not forwarded unchanged" unless received.equal?(sentinel)
      raise "sample_input not preserved" unless spy.received.fetch(:sample_input).equal?(sample_input)
      raise "sample_input_resolver not preserved" unless spy.received.fetch(:sample_input_resolver).equal?(sample_input_resolver)
      raise "runtime_smoke not preserved" unless spy.received.fetch(:runtime_smoke).equal?(runtime_smoke)
      raise "unexpected spy return" unless returned.fetch("status") == "spy_ok"

      "facade forwarded exact object and existing keywords"
    end

    results << assert_pass("F7.existing_cli_compile_remains_legacy") do
      cli_out = OUT_DIR / "cli_facade.igapp"
      code = 'require "igniter_lang/cli"; exit(IgniterLang::CLI.run(ARGV) ? 0 : 1)'
      stdout, stderr, status = Open3.capture3(
        RbConfig.ruby,
        "-I", (ROOT / "lib").to_s,
        "-e", code,
        "compile", SOURCE_PATH.to_s, "--out", cli_out.to_s
      )
      raise "cli exit=#{status.exitstatus} stderr=#{stderr.inspect} stdout=#{stdout.inspect}" unless status.success?

      manifest = read_manifest(cli_out)
      raise "CLI manifest unexpectedly has compiler_profile_id" if manifest.key?("compiler_profile_id")

      "CLI compile succeeded without profile field"
    end

    results
  end

  class SpyOrchestrator
    attr_reader :received

    def compile(**keywords)
      @received = keywords
      { "status" => "spy_ok" }
    end
  end

  def scan_json_value(value, file_label, path = [], hits = [])
    case value
    when Hash
      value.each do |key, nested|
        hits << { "file" => file_label, "kind" => "key", "path" => (path + [key]).join(".") } \
          if FORBIDDEN_EXACT_JSON_TOKENS.include?(key)
        scan_json_value(nested, file_label, path + [key], hits)
      end
    when Array
      value.each_with_index { |nested, index| scan_json_value(nested, file_label, path + [index], hits) }
    else
      hits << { "file" => file_label, "kind" => "value", "path" => path.join(".") } \
        if FORBIDDEN_EXACT_JSON_TOKENS.include?(value)
    end
    hits
  end

  def scan_json_files(files)
    files.flat_map do |file|
      scan_json_value(JSON.parse(File.read(file)), file.relative_path_from(ROOT).to_s)
    end
  end

  def run
    FileUtils.rm_rf(OUT_DIR)
    FileUtils.mkdir_p(OUT_DIR)

    canonical_source = finalize_descriptor(PROOF_DESCRIPTOR)
    case_results = run_facade_cases(canonical_source)

    artifact_files = Dir.glob((OUT_DIR / "**/*.json").to_s).map { |path| Pathname.new(path) }.sort
    artifact_hits = scan_json_files(artifact_files)

    summary = {
      "kind" => "prop036_ruby_facade_profile_source_exposure_summary",
      "format_version" => FORMAT_VERSION,
      "track" => "prop036-ruby-facade-profile-source-exposure-v0",
      "card" => "S3-R44-C3-I",
      "status" => "PASS",
      "pass_count" => case_results.length,
      "fail_count" => 0,
      "checks" => case_results,
      "canonical_source" => canonical_source,
      "negative_vocabulary_scan" => {
        "scanned_json_files" => artifact_files.map { |path| path.relative_path_from(ROOT).to_s } + ["summary"],
        "exact_token_hits" => 0
      },
      "non_authorizations" => {
        "cli_profile_flags" => false,
        "path_source_loading" => false,
        "inline_json_parsing" => false,
        "profile_finalization_in_facade" => false,
        "profile_discovery_or_defaulting" => false,
        "compatibility_report_profile_section" => false,
        "runtime_machine_binding" => false,
        "dispatch_migration" => false,
        "ledger_tbackend" => false,
        "production_behavior" => false
      }
    }

    summary_hits = scan_json_value(summary, "summary")
    all_hits = artifact_hits + summary_hits
    summary.fetch("negative_vocabulary_scan")["exact_token_hits"] = all_hits.length
    summary["status"] = all_hits.empty? ? "PASS" : "FAIL"
    summary["fail_count"] = all_hits.length
    summary["pass_count"] = case_results.length

    File.write(SUMMARY_PATH, "#{JSON.pretty_generate(summary)}\n")

    status = summary.fetch("status")
    puts "Prop036RubyFacadeProfileSourceExposure: #{status}"
    puts "  #{case_results.length}/#{case_results.length} checks PASS"
    puts "  exact forbidden-token hits: #{all_hits.length}"
    case_results.each { |result| puts "  #{result.fetch("result").ljust(4)} #{result.fetch("check")}" }
    puts "Summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"

    all_hits.empty?
  rescue => e
    warn e.message
    false
  end
end

exit(Prop036RubyFacadeProfileSourceExposure.run ? 0 : 1)
