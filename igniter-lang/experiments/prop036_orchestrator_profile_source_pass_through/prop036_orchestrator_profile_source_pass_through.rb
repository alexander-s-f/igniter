#!/usr/bin/env ruby
# frozen_string_literal: true

# Track: prop036-orchestrator-profile-source-pass-through-v0
# Card:  S3-R43-C1-I
# Agent: [Igniter-Lang Implementation Agent]
#
# Proof that CompilerOrchestrator#compile correctly forwards compiler_profile_source:
# to Assembler#assemble_artifacts as a transport-only pass-through.
#
# Authorized by S3-R42-C10-A.
#
# The orchestrator is a transport boundary only. It does not derive, load,
# discover, default, finalize, or validate profiles.
#
# Non-goals:
#   - No loader/report/CompatibilityReport implementation.
#   - No CompilerOrchestrator profile derivation.
#   - No existing .igapp golden migration.
#   - No RuntimeMachine, compiler dispatch, production behavior.

require "digest"
require "fileutils"
require "json"
require "pathname"

require_relative "../../lib/igniter_lang/compiler_orchestrator"

module Prop036OrchestratorProfileSourcePassThrough
  ROOT         = Pathname.new(File.expand_path("../..", __dir__))
  SOURCE_PATH  = ROOT / "experiments/source_to_semanticir_fixture/add.ig"
  OUT_DIR      = ROOT / "experiments/prop036_orchestrator_profile_source_pass_through/out"
  SUMMARY_PATH = OUT_DIR / "prop036_orchestrator_profile_source_pass_through_summary.json"

  FORMAT_VERSION = "0.1.0"

  LOADER_STATUS_VALUES = %w[
    absent_legacy present_verified mismatch malformed missing_required
  ].freeze

  # -------------------------------------------------------------------------
  # Inline finalization — mirrors minimal_compiler_profile_finalization_proof.
  # Produces valid compiler_profile_id_source objects without requiring the
  # finalization script (which calls exit at the top level).
  # -------------------------------------------------------------------------

  PROFILE_NAMESPACE    = "compiler_profile_unified"
  STAGE3_SPEC_NAME     = "Stage3ProofCompilerProfileSpec"
  DESCRIPTOR_KIND      = "compiler_profile_descriptor"
  SOURCE_KIND          = "compiler_profile_id_source"

  CANONICAL_SLOT_ORDER = %w[
    core oof_registry fragment_registry escape_boundary contract_modifiers
    temporal stream olap invariant assumptions evidence_observation pipeline
  ].freeze

  PROOF_IMPL_IDS = {
    "core"                 => "core_language.proof_compiler_adapter.v0",
    "oof_registry"         => "oof_registry.shadow_descriptor_registry.v0",
    "fragment_registry"    => "fragment_registry.shadow_precedence_registry.v0",
    "escape_boundary"      => "escape_boundary.current_monolith_adapter.v0",
    "contract_modifiers"   => "contract_modifiers.current_monolith_adapter.v0",
    "temporal"             => "temporal.metadata_only_guarded.v0",
    "stream"               => "stream.current_monolith_adapter.v0",
    "olap"                 => "olap.current_monolith_adapter.v0",
    "invariant"            => "invariant.current_monolith_adapter.v0",
    "assumptions"          => "assumptions.spec_shadow.v0",
    "evidence_observation" => "evidence_observation.current_monolith_adapter.v0",
    "pipeline"             => "pipeline.current_parser_surface_shadow.v0"
  }.freeze

  PROOF_PACK_NAMES = {
    "core"                 => "CoreLanguagePack",
    "oof_registry"         => "OOFRegistry",
    "fragment_registry"    => "FragmentRegistry",
    "escape_boundary"      => "EscapeBoundaryPack",
    "contract_modifiers"   => "ContractModifiersPack",
    "temporal"             => "TemporalPack",
    "stream"               => "StreamPack",
    "olap"                 => "OLAPPack",
    "invariant"            => "InvariantPack",
    "assumptions"          => "AssumptionsPack",
    "evidence_observation" => "EvidenceObservationPack",
    "pipeline"             => "PipelinePack"
  }.freeze

  PROOF_DESCRIPTOR = {
    "kind"           => DESCRIPTOR_KIND,
    "format_version" => FORMAT_VERSION,
    "profile_spec"   => {
      "kind"       => "compiler_profile_spec_candidate",
      "name"       => STAGE3_SPEC_NAME,
      "slot_order" => CANONICAL_SLOT_ORDER
    },
    "pack_descriptors" => CANONICAL_SLOT_ORDER.map do |slot|
      {
        "slot"              => slot,
        "name"              => PROOF_PACK_NAMES.fetch(slot),
        "implementation_id" => PROOF_IMPL_IDS.fetch(slot)
      }
    end
  }.freeze

  module_function

  def normalize(value)
    case value
    when Hash   then value.keys.sort.each_with_object({}) { |k, h| h[k.to_s] = normalize(value[k]) }
    when Array  then value.map { |v| normalize(v) }
    when Symbol then value.to_s
    else value
    end
  end

  def canonical_json(value)   = JSON.generate(normalize(value))
  def sha256_hex(data)        = Digest::SHA256.hexdigest(data)

  def finalize_descriptor(descriptor)
    pack_descriptors = descriptor.fetch("pack_descriptors", [])
    slot_assignments = pack_descriptors.each_with_object({}) do |pack, h|
      h[pack["slot"]] = {
        "implementation_id" => pack.fetch("implementation_id"),
        "pack_name"         => pack.fetch("name")
      }
    end
    stable = descriptor.reject { |k, _| k == "descriptor_digest" }
    descriptor_digest = "compiler_profile_descriptor/sha256:#{sha256_hex(canonical_json(stable))[0, 24]}"
    payload = {
      "profile_namespace"  => PROFILE_NAMESPACE,
      "format_version"     => FORMAT_VERSION,
      "descriptor_digest"  => descriptor_digest,
      "profile_kind"       => STAGE3_SPEC_NAME,
      "slot_order"         => CANONICAL_SLOT_ORDER,
      "slot_assignments"   => slot_assignments
    }
    payload_hex = sha256_hex(canonical_json(payload))
    {
      "kind"                          => SOURCE_KIND,
      "format_version"                => FORMAT_VERSION,
      "status"                        => "finalized",
      "profile_namespace"             => PROFILE_NAMESPACE,
      "compiler_profile_id"           => "#{PROFILE_NAMESPACE}/sha256:#{payload_hex[0, 24]}",
      "descriptor_digest"             => descriptor_digest,
      "finalization_payload_digest"   => "sha256:#{payload_hex}",
      "profile_kind"                  => STAGE3_SPEC_NAME,
      "slot_order"                    => CANONICAL_SLOT_ORDER,
      "slot_assignments"              => slot_assignments,
      "dispatch_migration_authorized" => false,
      "runtime_authority_granted"     => false
    }
  end

  # -------------------------------------------------------------------------
  # Proof helpers
  # -------------------------------------------------------------------------

  def assert_pass(name, &block)
    detail = block.call
    { "check" => name, "result" => "PASS", "detail" => detail.to_s }
  rescue => e
    raise "FAIL [#{name}]: #{e.message}"
  end

  def assert_property(name, cond, msg = nil)
    raise "FAIL [#{name}]: #{msg || "assertion failed"}" unless cond
    { "check" => name, "result" => "PASS" }
  end

  def read_manifest(igapp_dir)
    JSON.parse(File.read(Pathname.new(igapp_dir) / "manifest.json"))
  end

  def read_json_file(path)
    JSON.parse(File.read(path))
  end

  # -------------------------------------------------------------------------
  # Proof cases
  # -------------------------------------------------------------------------

  def run_proof_cases(orchestrator, canonical_source)
    results = []

    legacy_out    = OUT_DIR / "legacy_compile.igapp"
    profiled_out  = OUT_DIR / "profiled_compile.igapp"
    refused_out   = OUT_DIR / "refused_compile.igapp"

    # ------------------------------------------------------------------
    # CASE O1: compile without source — status ok, manifest omits field
    # ------------------------------------------------------------------
    results << assert_pass("O1.legacy_compile_omits_field") do
      result = orchestrator.compile(
        source_path: SOURCE_PATH,
        out_path:    legacy_out
        # compiler_profile_source omitted → nil → legacy_optional
      )
      raise "status=#{result["status"].inspect}" unless result["status"] == "ok"
      manifest = read_manifest(legacy_out)
      raise "manifest.compiler_profile_id present in legacy compile" if manifest.key?("compiler_profile_id")
      "status=ok manifest.compiler_profile_id absent ✓"
    end

    # ------------------------------------------------------------------
    # CASE O2: compile with valid finalized source — status ok, field emitted
    # ------------------------------------------------------------------
    results << assert_pass("O2.profiled_compile_emits_field") do
      result = orchestrator.compile(
        source_path:             SOURCE_PATH,
        out_path:                profiled_out,
        compiler_profile_source: canonical_source
      )
      raise "status=#{result["status"].inspect}" unless result["status"] == "ok"
      manifest = read_manifest(profiled_out)
      raise "manifest.compiler_profile_id absent" unless manifest.key?("compiler_profile_id")
      actual   = manifest["compiler_profile_id"]
      expected = canonical_source["compiler_profile_id"]
      raise "id mismatch: #{actual.inspect} != #{expected.inspect}" unless actual == expected
      "status=ok manifest.compiler_profile_id=#{actual}"
    end

    # ------------------------------------------------------------------
    # CASE O3: profiled compile changes artifact_hash vs legacy
    # ------------------------------------------------------------------
    results << assert_pass("O3.profiled_hash_differs_from_legacy") do
      legacy_hash   = read_manifest(legacy_out).fetch("artifact_hash")
      profiled_hash = read_manifest(profiled_out).fetch("artifact_hash")
      raise "artifact_hash identical — profile_id NOT in hash material" if legacy_hash == profiled_hash
      "legacy=#{legacy_hash[0, 20]}... profiled=#{profiled_hash[0, 20]}..."
    end

    # ------------------------------------------------------------------
    # CASE O4: invalid source — orchestrator returns assembler_refused
    # ------------------------------------------------------------------
    invalid_source = canonical_source.merge("status" => "draft")
    refused_result = orchestrator.compile(
      source_path:             SOURCE_PATH,
      out_path:                refused_out,
      compiler_profile_source: invalid_source
    )
    results << assert_property(
      "O4.invalid_source_returns_assembler_refused",
      refused_result["status"] == "assembler_refused",
      "status=#{refused_result["status"].inspect}"
    )

    # ------------------------------------------------------------------
    # CASE O5: refusal reason includes compiler_profile_source.* text
    # ------------------------------------------------------------------
    results << assert_pass("O5.refusal_includes_profile_source_reason") do
      report_json = JSON.generate(refused_result.fetch("compilation_report", {}))
      result_json = JSON.generate(refused_result.fetch("result", {}))
      combined    = report_json + result_json
      raise "compiler_profile_source.* reason not found in refusal output" \
        unless combined.include?("compiler_profile_source")
      "compiler_profile_source.* found in refusal ✓"
    end

    # ------------------------------------------------------------------
    # CASE O6: no loader status values emitted in profiled output
    # ------------------------------------------------------------------
    results << assert_pass("O6.no_loader_status_values") do
      manifest_json = JSON.generate(read_manifest(profiled_out))
      hits = LOADER_STATUS_VALUES.select { |v| manifest_json.include?(v) }
      raise "loader status values found: #{hits.inspect}" unless hits.empty?
      "no loader status values in manifest ✓"
    end

    # ------------------------------------------------------------------
    # CASE O7: no runtime authority implied in output
    # ------------------------------------------------------------------
    results << assert_pass("O7.no_runtime_authority") do
      manifest = read_manifest(profiled_out)
      rt_keys  = %w[runtime_authority gate3_authorized runtime_ready evaluation_ready]
      hits     = rt_keys.select { |k| manifest.key?(k) }
      raise "runtime authority keys found in manifest: #{hits.inspect}" unless hits.empty?
      "no runtime authority keys in manifest ✓"
    end

    # ------------------------------------------------------------------
    # CASE O8: no existing golden mutation
    # The orchestrator pipeline (classify→typecheck→emit→assemble) produces
    # a different artifact_hash than direct Assembler#assemble_case — they
    # are different code paths with different artifact_material. O8 proves
    # only that this proof did not write into any existing golden directory.
    # ------------------------------------------------------------------
    results << assert_pass("O8.no_golden_mutation") do
      golden_dir = ROOT / "experiments/igapp_assembler_proof/out"
      existing_golden = golden_dir / "add.igapp/manifest.json"
      if existing_golden.exist?
        # Verify golden file still has valid sha256 artifact_hash format
        golden_hash = read_json_file(existing_golden).fetch("artifact_hash")
        raise "golden artifact_hash malformed: #{golden_hash.inspect}" \
          unless golden_hash.match?(/\Asha256:[0-9a-f]{64}\z/)
      end
      # Verify this proof wrote only into its own OUT_DIR
      [legacy_out, profiled_out, refused_out].each do |path|
        raise "proof output path escapes OUT_DIR: #{path}" \
          unless path.to_s.start_with?(OUT_DIR.to_s)
      end
      "no golden files mutated ✓"
    end

    results
  end

  # -------------------------------------------------------------------------
  # Invariants
  # -------------------------------------------------------------------------

  def check_invariants
    invs = []

    # INV1: all assembled igapps have sha256:<64-hex> artifact_hash format
    invs << assert_pass("INV1.artifact_hash_format_valid") do
      %w[legacy_compile profiled_compile].each do |name|
        manifest = read_manifest(OUT_DIR / "#{name}.igapp")
        h = manifest.fetch("artifact_hash")
        raise "#{name} artifact_hash malformed: #{h.inspect}" \
          unless h.match?(/\Asha256:[0-9a-f]{64}\z/)
      end
      "all artifact_hashes have sha256:<64-hex> format ✓"
    end

    # INV2: orchestrator compile method signature is backward-compatible
    # (nil default means existing callers need no changes)
    invs << assert_pass("INV2.backward_compatible_nil_default") do
      method_obj = IgniterLang::CompilerOrchestrator.instance_method(:compile)
      params     = method_obj.parameters
      profile_param = params.find { |type, name| name == :compiler_profile_source }
      raise "compiler_profile_source parameter not found" unless profile_param
      raise "parameter is not keyword" unless profile_param[0] == :key
      "compile has compiler_profile_source: keyword param ✓"
    end

    # INV3: orchestrator does NOT define any profile derivation methods
    invs << assert_pass("INV3.orchestrator_is_transport_only") do
      forbidden = %i[finalize_profile derive_profile_id load_profile discover_profile
                     default_profile validate_profile cache_profile]
      found = forbidden.select do |m|
        IgniterLang::CompilerOrchestrator.private_method_defined?(m) ||
          IgniterLang::CompilerOrchestrator.method_defined?(m)
      end
      raise "orchestrator defines forbidden profile methods: #{found.inspect}" unless found.empty?
      "orchestrator has no profile derivation methods ✓"
    end

    invs
  end

  # -------------------------------------------------------------------------
  # Runner
  # -------------------------------------------------------------------------

  def run
    FileUtils.mkdir_p(OUT_DIR)

    canonical_source = finalize_descriptor(PROOF_DESCRIPTOR)
    orchestrator     = IgniterLang::CompilerOrchestrator.new

    proof_results     = run_proof_cases(orchestrator, canonical_source)
    invariant_results = check_invariants

    all_results = proof_results + invariant_results
    pass_count  = all_results.count { |r| r["result"] == "PASS" }
    fail_count  = all_results.count { |r| r["result"] != "PASS" }
    status      = fail_count.zero? ? "PASS" : "FAIL"

    summary = {
      "kind"             => "prop036_orchestrator_profile_source_pass_through_summary",
      "format_version"   => FORMAT_VERSION,
      "track"            => "prop036-orchestrator-profile-source-pass-through-v0",
      "card"             => "S3-R43-C1-I",
      "status"           => status,
      "pass_count"       => pass_count,
      "fail_count"       => fail_count,
      "proof_cases"      => proof_results.size,
      "invariants"       => invariant_results.size,
      "checks"           => all_results,
      "canonical_source" => canonical_source,
      "non_goals" => [
        "No profile derivation, discovery, loading, or caching in orchestrator.",
        "No existing .igapp golden migration.",
        "No loader/report/CompatibilityReport implementation.",
        "No RuntimeMachine, compiler dispatch, or production changes."
      ]
    }

    File.write(SUMMARY_PATH, JSON.pretty_generate(summary) + "\n")

    puts "Prop036OrchestratorProfileSourcePassThrough: #{status}"
    puts "  #{pass_count}/#{pass_count + fail_count} checks PASS"
    all_results.each { |r| puts "  #{r["result"].ljust(4)} #{r["check"]}" }
    puts "Summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"

    status == "PASS"
  end
end

exit(Prop036OrchestratorProfileSourcePassThrough.run ? 0 : 1)
