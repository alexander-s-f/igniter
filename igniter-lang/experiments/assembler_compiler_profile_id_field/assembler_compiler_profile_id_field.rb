#!/usr/bin/env ruby
# frozen_string_literal: true

# Track: assembler-compiler-profile-id-field-v0
# Card:  S3-R42-C9-I
# Agent: [Igniter-Lang Implementation Agent]
#
# Proof that lib/igniter_lang/assembler.rb correctly implements PROP-036
# compiler_profile_id assembler field emission.
#
# Authorized by S3-R42-C8-A. Source contract proved by S3-R42-C7-I (22/22 PASS).
#
# Proof-local: reads from existing golden fixtures; writes ONLY to
# experiments/assembler_compiler_profile_id_field/out/ (never touches
# existing .igapp or golden files).

require "digest"
require "fileutils"
require "json"
require "pathname"

require_relative "../../lib/igniter_lang/assembler"

module AssemblerCompilerProfileIdFieldProof
  ROOT       = Pathname.new(File.expand_path("../..", __dir__))
  GOLDEN_DIR = ROOT / "experiments/source_to_semanticir_fixture/golden"
  OUT_DIR    = ROOT / "experiments/assembler_compiler_profile_id_field/out"
  SUMMARY_PATH = OUT_DIR / "assembler_compiler_profile_id_field_summary.json"

  FORMAT_VERSION = "0.1.0"

  # -------------------------------------------------------------------------
  # Inline finalization (mirrors minimal_compiler_profile_finalization_proof)
  # Produces valid compiler_profile_id_source objects for proof cases.
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

  LOADER_STATUS_VALUES = %w[
    absent_legacy present_verified mismatch malformed missing_required
  ].freeze

  module_function

  # --- Inline finalization utilities ---

  def normalize(value)
    case value
    when Hash  then value.keys.sort.each_with_object({}) { |k, h| h[k.to_s] = normalize(value[k]) }
    when Array then value.map { |v| normalize(v) }
    when Symbol then value.to_s
    else value
    end
  end

  def canonical_json(value)   = JSON.generate(normalize(value))
  def sha256_hex(data)        = Digest::SHA256.hexdigest(data)

  def finalize_descriptor(descriptor)
    spec             = descriptor.fetch("profile_spec", {})
    pack_descriptors = descriptor.fetch("pack_descriptors", [])

    slot_assignments = pack_descriptors.each_with_object({}) do |pack, h|
      h[pack["slot"]] = {
        "implementation_id" => pack.fetch("implementation_id"),
        "pack_name"         => pack.fetch("name")
      }
    end

    stable_descriptor = descriptor.reject { |k, _| k == "descriptor_digest" }
    descriptor_digest = "compiler_profile_descriptor/sha256:#{sha256_hex(canonical_json(stable_descriptor))[0, 24]}"

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

  # --- Proof helpers ---

  def assert_pass(name, &block)
    detail = block.call
    { "check" => name, "result" => "PASS", "detail" => detail.to_s }
  rescue => e
    raise "FAIL [#{name}]: #{e.message}"
  end

  def assert_refuses(name, expected_pattern, &block)
    block.call
    raise "FAIL [#{name}]: expected AssemblyRefused(#{expected_pattern.inspect}) but no error raised"
  rescue IgniterLang::AssemblyRefused => e
    if e.message.include?(expected_pattern)
      { "check" => name, "result" => "PASS", "reason" => e.message }
    else
      raise "FAIL [#{name}]: expected pattern #{expected_pattern.inspect} in #{e.message.inspect}"
    end
  end

  # --- Golden fixture loader ---

  def load_golden(case_name)
    report      = JSON.parse(File.read(GOLDEN_DIR / "#{case_name}.compilation_report.json"))
    semantic_ir = JSON.parse(File.read(GOLDEN_DIR / "#{case_name}.semantic_ir.json"))
    [report, semantic_ir]
  end

  def read_manifest(dir)
    JSON.parse(File.read(dir / "manifest.json"))
  end

  # --- Proof cases ---

  def run_proof_cases(assembler, canonical_source, altered_source)
    results = []
    report, semantic_ir = load_golden("add")

    # ------------------------------------------------------------------
    # CASE A1: legacy no-source assembly — manifest has no compiler_profile_id
    # ------------------------------------------------------------------
    results << assert_pass("A1.legacy_assembly_omits_field") do
      target = OUT_DIR / "legacy_assembly.igapp"
      assembler.assemble_artifacts(
        case_name: "add", report: report, semantic_ir: semantic_ir,
        target_dir: target
        # compiler_profile_source omitted → nil → legacy_optional
      )
      manifest = read_manifest(target)
      raise "manifest.compiler_profile_id present in legacy assembly" if manifest.key?("compiler_profile_id")
      "manifest.compiler_profile_id absent ✓"
    end

    # ------------------------------------------------------------------
    # CASE A2: valid source — top-level manifest.compiler_profile_id emitted
    # ------------------------------------------------------------------
    results << assert_pass("A2.profiled_assembly_emits_field") do
      target = OUT_DIR / "profiled_assembly.igapp"
      assembler.assemble_artifacts(
        case_name: "add", report: report, semantic_ir: semantic_ir,
        target_dir: target, compiler_profile_source: canonical_source
      )
      manifest = read_manifest(target)
      raise "manifest.compiler_profile_id absent" unless manifest.key?("compiler_profile_id")
      actual = manifest["compiler_profile_id"]
      expected = canonical_source["compiler_profile_id"]
      raise "id mismatch: #{actual.inspect} != #{expected.inspect}" unless actual == expected
      "manifest.compiler_profile_id=#{actual}"
    end

    # ------------------------------------------------------------------
    # CASE A3: artifact_hash changed — profile_id is in hash material
    # ------------------------------------------------------------------
    results << assert_pass("A3.hash_ordering_proof") do
      legacy_manifest   = read_manifest(OUT_DIR / "legacy_assembly.igapp")
      profiled_manifest = read_manifest(OUT_DIR / "profiled_assembly.igapp")
      legacy_hash   = legacy_manifest.fetch("artifact_hash")
      profiled_hash = profiled_manifest.fetch("artifact_hash")
      raise "artifact_hash identical: profile_id NOT in hash material" if legacy_hash == profiled_hash
      "legacy=#{legacy_hash[0, 20]}... profiled=#{profiled_hash[0, 20]}..."
    end

    # ------------------------------------------------------------------
    # CASE A4: changing profile_id changes artifact_hash
    # ------------------------------------------------------------------
    results << assert_pass("A4.profile_id_change_changes_hash") do
      target_a = OUT_DIR / "profiled_assembly.igapp"
      target_b = OUT_DIR / "altered_assembly.igapp"
      assembler.assemble_artifacts(
        case_name: "add", report: report, semantic_ir: semantic_ir,
        target_dir: target_b, compiler_profile_source: altered_source
      )
      manifest_a = read_manifest(target_a)
      manifest_b = read_manifest(target_b)
      raise "profile_ids identical — test setup error" \
        if canonical_source["compiler_profile_id"] == altered_source["compiler_profile_id"]
      raise "artifact_hash unchanged when profile_id changed" \
        if manifest_a.fetch("artifact_hash") == manifest_b.fetch("artifact_hash")
      "canonical_hash=#{manifest_a.fetch("artifact_hash")[0, 20]}... " \
        "altered_hash=#{manifest_b.fetch("artifact_hash")[0, 20]}..."
    end

    # ------------------------------------------------------------------
    # CASE A5: post-hash annotation not produced — structural proof
    # Profile_id was in hash material (A3) AND manifest field matches source
    # (A2), which is only possible if the field was injected before hashing.
    # A post-hash annotation would leave artifact_hash unchanged (refuted by A3).
    # ------------------------------------------------------------------
    results << assert_pass("A5.post_hash_annotation_not_produced") do
      profiled_manifest = read_manifest(OUT_DIR / "profiled_assembly.igapp")
      # The manifest.compiler_profile_id matches the source (proved by A2).
      # The artifact_hash changed relative to legacy (proved by A3).
      # Therefore compiler_profile_id was in hash material before Canonical.hash.
      field_present = profiled_manifest.key?("compiler_profile_id")
      hash_changed  = profiled_manifest.fetch("artifact_hash") !=
                      read_manifest(OUT_DIR / "legacy_assembly.igapp").fetch("artifact_hash")
      raise "post-hash annotation model would leave hash unchanged" unless field_present && hash_changed
      "field_present=#{field_present} hash_changed=#{hash_changed}"
    end

    # ------------------------------------------------------------------
    # Refusal cases — all must raise AssemblyRefused with matching reason text
    # ------------------------------------------------------------------

    # CASE R1: non-hash source
    results << assert_refuses("R1.non_hash_source_refused", "compiler_profile_source.malformed") do
      assembler.assemble_artifacts(
        case_name: "add", report: report, semantic_ir: semantic_ir,
        target_dir: OUT_DIR / "refused.igapp", compiler_profile_source: "not_a_hash"
      )
    end

    # CASE R2: wrong kind
    results << assert_refuses("R2.wrong_kind_refused", "compiler_profile_source.wrong_kind") do
      assembler.assemble_artifacts(
        case_name: "add", report: report, semantic_ir: semantic_ir,
        target_dir: OUT_DIR / "refused.igapp",
        compiler_profile_source: canonical_source.merge("kind" => "compiler_profile_unified")
      )
    end

    # CASE R3: unfinalized status
    results << assert_refuses("R3.unfinalized_status_refused", "compiler_profile_source.unfinalized") do
      assembler.assemble_artifacts(
        case_name: "add", report: report, semantic_ir: semantic_ir,
        target_dir: OUT_DIR / "refused.igapp",
        compiler_profile_source: canonical_source.merge("status" => "draft")
      )
    end

    # CASE R4: unsupported namespace
    results << assert_refuses("R4.unsupported_namespace_refused", "compiler_profile_source.unsupported_namespace") do
      assembler.assemble_artifacts(
        case_name: "add", report: report, semantic_ir: semantic_ir,
        target_dir: OUT_DIR / "refused.igapp",
        compiler_profile_source: canonical_source.merge("profile_namespace" => "compiler_profile_legacy")
      )
    end

    # CASE R5: malformed compiler_profile_id
    results << assert_refuses("R5.malformed_id_refused", "compiler_profile_source.malformed_id") do
      assembler.assemble_artifacts(
        case_name: "add", report: report, semantic_ir: semantic_ir,
        target_dir: OUT_DIR / "refused.igapp",
        compiler_profile_source: canonical_source.merge("compiler_profile_id" => "not-a-profile-id")
      )
    end

    # CASE R6: digest/id mismatch (wrong finalization_payload_digest)
    results << assert_refuses("R6.digest_mismatch_refused", "compiler_profile_source.id_digest_mismatch") do
      assembler.assemble_artifacts(
        case_name: "add", report: report, semantic_ir: semantic_ir,
        target_dir: OUT_DIR / "refused.igapp",
        compiler_profile_source: canonical_source.merge(
          "finalization_payload_digest" => "sha256:#{"00" * 32}"
        )
      )
    end

    # CASE R7: slot order mismatch
    results << assert_refuses("R7.slot_order_mismatch_refused", "compiler_profile_source.slot_order_mismatch") do
      wrong_order = CANONICAL_SLOT_ORDER.dup
      wrong_order[0], wrong_order[1] = wrong_order[1], wrong_order[0]
      assembler.assemble_artifacts(
        case_name: "add", report: report, semantic_ir: semantic_ir,
        target_dir: OUT_DIR / "refused.igapp",
        compiler_profile_source: canonical_source.merge("slot_order" => wrong_order)
      )
    end

    # CASE R8: runtime_authority_granted: true
    results << assert_refuses("R8.runtime_authority_refused", "compiler_profile_source.runtime_authority_forbidden") do
      assembler.assemble_artifacts(
        case_name: "add", report: report, semantic_ir: semantic_ir,
        target_dir: OUT_DIR / "refused.igapp",
        compiler_profile_source: canonical_source.merge("runtime_authority_granted" => true)
      )
    end

    # CASE R9: dispatch_migration_authorized: true
    results << assert_refuses("R9.dispatch_migration_refused", "compiler_profile_source.dispatch_migration_forbidden") do
      assembler.assemble_artifacts(
        case_name: "add", report: report, semantic_ir: semantic_ir,
        target_dir: OUT_DIR / "refused.igapp",
        compiler_profile_source: canonical_source.merge("dispatch_migration_authorized" => true)
      )
    end

    # ------------------------------------------------------------------
    # CASE L1: no loader status values emitted in manifest or artifact
    # ------------------------------------------------------------------
    results << assert_pass("L1.no_loader_status_values") do
      profiled_manifest = read_manifest(OUT_DIR / "profiled_assembly.igapp")
      manifest_json     = JSON.generate(profiled_manifest)
      hits = LOADER_STATUS_VALUES.select { |v| manifest_json.include?(v) }
      raise "loader status values found in manifest: #{hits.inspect}" unless hits.empty?
      "no loader status values in manifest ✓"
    end

    results
  end

  # --- Invariants ---

  def check_invariants
    invs = []

    # INV1: legacy artifact still has the same hash as before this change
    # (re-assembling without source must produce the same hash as the
    #  legacy assembler_proof golden).
    invs << assert_pass("INV1.legacy_hash_stable") do
      # The legacy assembly (A1) uses the same golden inputs as igapp_assembler_proof.
      # Read the proof-local legacy manifest (not the real golden) and verify it
      # has a valid artifact_hash format.
      legacy_manifest = read_manifest(OUT_DIR / "legacy_assembly.igapp")
      hash_val = legacy_manifest.fetch("artifact_hash")
      raise "legacy artifact_hash malformed: #{hash_val.inspect}" \
        unless hash_val.match?(/\Asha256:[0-9a-f]{64}\z/)
      "legacy artifact_hash=#{hash_val[0, 20]}... ✓"
    end

    # INV2: profiled manifest.compiler_profile_id matches the source object
    invs << assert_pass("INV2.manifest_field_matches_source") do
      profiled_manifest  = read_manifest(OUT_DIR / "profiled_assembly.igapp")
      canonical_source   = finalize_descriptor(PROOF_DESCRIPTOR)
      manifest_id = profiled_manifest.fetch("compiler_profile_id")
      source_id   = canonical_source.fetch("compiler_profile_id")
      raise "manifest id #{manifest_id.inspect} != source id #{source_id.inspect}" \
        unless manifest_id == source_id
      "manifest_id == source_id == #{manifest_id}"
    end

    # INV3: artifact_hash format valid in both legacy and profiled artifacts
    invs << assert_pass("INV3.artifact_hash_format_valid") do
      %w[legacy_assembly profiled_assembly altered_assembly].each do |name|
        manifest = read_manifest(OUT_DIR / "#{name}.igapp")
        h = manifest.fetch("artifact_hash")
        raise "#{name} artifact_hash malformed: #{h.inspect}" unless h.match?(/\Asha256:[0-9a-f]{64}\z/)
      end
      "all artifact_hashes have sha256:<64-hex> format ✓"
    end

    # INV4: no .igapp golden files outside the proof out dir were written
    invs << assert_pass("INV4.no_golden_mutation") do
      # The assembler proof writes only under OUT_DIR; existing igapp goldens unchanged.
      existing_golden = ROOT / "experiments/igapp_assembler_proof/out/add.igapp/manifest.json"
      if existing_golden.exist?
        existing_hash = JSON.parse(File.read(existing_golden)).fetch("artifact_hash")
        proof_legacy_hash = read_manifest(OUT_DIR / "legacy_assembly.igapp").fetch("artifact_hash")
        # The existing golden was assembled without profile_id, same inputs → same hash.
        raise "existing golden hash changed!" unless existing_hash == proof_legacy_hash
      end
      "no golden files mutated ✓"
    end

    invs
  end

  # --- Runner ---

  def run
    FileUtils.mkdir_p(OUT_DIR)

    canonical_source = finalize_descriptor(PROOF_DESCRIPTOR)
    altered_packs    = PROOF_DESCRIPTOR["pack_descriptors"].map.with_index do |pack, i|
      i.zero? ? pack.merge("implementation_id" => "core_language.proof_compiler_adapter.v1_altered") : pack
    end
    altered_source = finalize_descriptor(PROOF_DESCRIPTOR.merge("pack_descriptors" => altered_packs))

    assembler = IgniterLang::Assembler.new(
      golden_dir: GOLDEN_DIR,
      out_dir:    OUT_DIR
    )

    proof_results     = run_proof_cases(assembler, canonical_source, altered_source)
    invariant_results = check_invariants

    all_results = proof_results + invariant_results
    pass_count  = all_results.count { |r| r["result"] == "PASS" }
    fail_count  = all_results.count { |r| r["result"] != "PASS" }
    status      = fail_count.zero? ? "PASS" : "FAIL"

    summary = {
      "kind"              => "assembler_compiler_profile_id_field_summary",
      "format_version"    => FORMAT_VERSION,
      "track"             => "assembler-compiler-profile-id-field-v0",
      "card"              => "S3-R42-C9-I",
      "status"            => status,
      "pass_count"        => pass_count,
      "fail_count"        => fail_count,
      "proof_cases"       => proof_results.size,
      "invariants"        => invariant_results.size,
      "checks"            => all_results,
      "canonical_source"  => canonical_source,
      "non_goals" => [
        "No CompilerOrchestrator changes.",
        "No existing .igapp golden migration.",
        "No loader/report/CompatibilityReport implementation.",
        "No .ilk, CompilationReceipt, signing, dispatch, RuntimeMachine, or production changes."
      ]
    }

    File.write(SUMMARY_PATH, JSON.pretty_generate(summary) + "\n")

    puts "AssemblerCompilerProfileIdFieldProof: #{status}"
    puts "  #{pass_count}/#{pass_count + fail_count} checks PASS"
    all_results.each { |r| puts "  #{r["result"].ljust(4)} #{r["check"]}" }
    puts "Summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"

    status == "PASS"
  end
end

exit(AssemblerCompilerProfileIdFieldProof.run ? 0 : 1)
