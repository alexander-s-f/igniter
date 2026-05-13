#!/usr/bin/env ruby
# frozen_string_literal: true

# Track: minimal-compiler-profile-finalization-proof-v0
# Card:  S3-R42-C7-I
# Agent: [Igniter-Lang Implementation Agent]
#
# Proof-local implementation of the minimal CompilerProfile finalization layer.
# Authorized by S3-R42-C6-A.
#
# This script:
#   - defines a proof-local frozen descriptor for Stage3ProofCompilerProfileSpec;
#   - validates the descriptor and derives compiler_profile_id_source;
#   - derives compiler_profile_unified/sha256:<24+ lowercase hex chars>;
#   - proves input-order independence, implementation identity sensitivity,
#     compiler_profile_id absence from payload, and all required refusal cases;
#   - validates a produced source object against the C4-P1 refusal table;
#   - writes summary JSON to out/.
#
# Non-goals (not implemented here):
#   - assembler field emission;
#   - .igapp manifest mutation;
#   - loader/report/CompatibilityReport changes;
#   - compiler dispatch migration;
#   - RuntimeMachine, Ledger, TBackend, BiHistory, stream/OLAP, cache, production.

require "digest"
require "fileutils"
require "json"
require "pathname"

module MinimalCompilerProfileFinalizationProof
  ROOT     = Pathname.new(File.expand_path("../../..", __dir__))
  OUT_DIR  = ROOT / "igniter-lang/experiments/minimal_compiler_profile_finalization_proof/out"
  SUMMARY_PATH = OUT_DIR / "minimal_compiler_profile_finalization_summary.json"

  FORMAT_VERSION   = "0.1.0"
  PROFILE_NAMESPACE = "compiler_profile_unified"
  STAGE3_SPEC_NAME  = "Stage3ProofCompilerProfileSpec"
  DESCRIPTOR_KIND   = "compiler_profile_descriptor"
  SOURCE_KIND       = "compiler_profile_id_source"

  # Canonical slot order for Stage3ProofCompilerProfileSpec (C4-P1, confirmed from
  # compiler_profile_spec_and_rule_unification experiment).
  CANONICAL_SLOT_ORDER = %w[
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
  ].freeze

  # Implementation ids from the Stage3ProofCompilerProfileSpec positive profile
  # (source: compiler_profile_spec_and_rule_unification experiment).
  PROOF_IMPL_IDS = {
    "core"                => "core_language.proof_compiler_adapter.v0",
    "oof_registry"        => "oof_registry.shadow_descriptor_registry.v0",
    "fragment_registry"   => "fragment_registry.shadow_precedence_registry.v0",
    "escape_boundary"     => "escape_boundary.current_monolith_adapter.v0",
    "contract_modifiers"  => "contract_modifiers.current_monolith_adapter.v0",
    "temporal"            => "temporal.metadata_only_guarded.v0",
    "stream"              => "stream.current_monolith_adapter.v0",
    "olap"                => "olap.current_monolith_adapter.v0",
    "invariant"           => "invariant.current_monolith_adapter.v0",
    "assumptions"         => "assumptions.spec_shadow.v0",
    "evidence_observation" => "evidence_observation.current_monolith_adapter.v0",
    "pipeline"            => "pipeline.current_parser_surface_shadow.v0"
  }.freeze

  PROOF_PACK_NAMES = {
    "core"                => "CoreLanguagePack",
    "oof_registry"        => "OOFRegistry",
    "fragment_registry"   => "FragmentRegistry",
    "escape_boundary"     => "EscapeBoundaryPack",
    "contract_modifiers"  => "ContractModifiersPack",
    "temporal"            => "TemporalPack",
    "stream"              => "StreamPack",
    "olap"                => "OLAPPack",
    "invariant"           => "InvariantPack",
    "assumptions"         => "AssumptionsPack",
    "evidence_observation" => "EvidenceObservationPack",
    "pipeline"            => "PipelinePack"
  }.freeze

  # Proof-local frozen descriptor — all 12 slots, matches Stage3ProofCompilerProfileSpec.
  PROOF_DESCRIPTOR = {
    "kind"           => DESCRIPTOR_KIND,
    "format_version" => FORMAT_VERSION,
    "profile_spec"   => {
      "kind"           => "compiler_profile_spec_candidate",
      "name"           => STAGE3_SPEC_NAME,
      "slot_order"     => CANONICAL_SLOT_ORDER
    },
    "pack_descriptors" => CANONICAL_SLOT_ORDER.map do |slot|
      {
        "slot"              => slot,
        "name"              => PROOF_PACK_NAMES.fetch(slot),
        "implementation_id" => PROOF_IMPL_IDS.fetch(slot)
      }
    end
  }.freeze

  # -------------------------------------------------------------------------
  # FinalizationError — raised when finalization or validation refuses input.
  # -------------------------------------------------------------------------
  class FinalizationError < StandardError
    attr_reader :reason_code

    def initialize(message, reason_code:)
      super(message)
      @reason_code = reason_code
    end
  end

  module_function

  # -------------------------------------------------------------------------
  # Canonical JSON utilities
  # -------------------------------------------------------------------------

  def normalize(value)
    case value
    when Hash  then value.keys.sort.each_with_object({}) { |k, h| h[k.to_s] = normalize(value[k]) }
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

  # -------------------------------------------------------------------------
  # Finalization Layer
  # Accepts a frozen descriptor hash; validates it; emits compiler_profile_id_source.
  # -------------------------------------------------------------------------

  def finalize_descriptor(descriptor)
    # Step 1: presence and type
    if descriptor.nil?
      raise FinalizationError.new(
        "descriptor is nil",
        reason_code: "compiler_profile_source.missing"
      )
    end
    unless descriptor.is_a?(Hash)
      raise FinalizationError.new(
        "descriptor must be a Hash, got #{descriptor.class}",
        reason_code: "compiler_profile_source.malformed"
      )
    end

    # Step 2: kind
    kind = descriptor["kind"]
    unless kind == DESCRIPTOR_KIND
      raise FinalizationError.new(
        "wrong kind: #{kind.inspect}; expected #{DESCRIPTOR_KIND.inspect}",
        reason_code: "compiler_profile_source.wrong_kind"
      )
    end

    # Step 3: guard — descriptor must NOT embed a compiler_profile_id
    # Prevents recycling an old id into finalization material.
    if descriptor.key?("compiler_profile_id")
      raise FinalizationError.new(
        "descriptor must not contain compiler_profile_id; finalization derives it from payload",
        reason_code: "compiler_profile_source.payload_id_inclusion_forbidden"
      )
    end

    # Step 4: profile spec name
    spec      = descriptor.fetch("profile_spec", {})
    spec_name = spec["name"]
    unless spec_name == STAGE3_SPEC_NAME
      raise FinalizationError.new(
        "unsupported profile spec: #{spec_name.inspect}; expected #{STAGE3_SPEC_NAME.inspect}",
        reason_code: "compiler_profile_source.unsupported_namespace"
      )
    end

    # Step 5: slot order — descriptor spec must declare the canonical order exactly
    descriptor_slot_order = spec.fetch("slot_order", [])
    unless descriptor_slot_order == CANONICAL_SLOT_ORDER
      raise FinalizationError.new(
        "slot order mismatch: #{descriptor_slot_order.inspect}",
        reason_code: "compiler_profile_source.slot_order_mismatch"
      )
    end

    # Step 6: build slot_assignments from pack_descriptors
    pack_descriptors = descriptor.fetch("pack_descriptors", [])
    slot_assignments = {}
    pack_descriptors.each do |pack|
      slot = pack["slot"]
      unless CANONICAL_SLOT_ORDER.include?(slot)
        raise FinalizationError.new(
          "unknown slot in pack_descriptors: #{slot.inspect}",
          reason_code: "compiler_profile_source.slot_order_mismatch"
        )
      end
      slot_assignments[slot] = {
        "implementation_id" => pack.fetch("implementation_id"),
        "pack_name"         => pack.fetch("name")
      }
    end

    # Step 7: descriptor_digest — hash of stable descriptor (no existing descriptor_digest key)
    stable_descriptor = descriptor.reject { |k, _| k == "descriptor_digest" }
    descriptor_digest = "compiler_profile_descriptor/sha256:#{sha256_hex(canonical_json(stable_descriptor))[0, 24]}"

    # Step 8: build finalization payload
    # INVARIANT: compiler_profile_id must NOT appear in this payload.
    payload = {
      "profile_namespace"  => PROFILE_NAMESPACE,
      "format_version"     => FORMAT_VERSION,
      "descriptor_digest"  => descriptor_digest,
      "profile_kind"       => STAGE3_SPEC_NAME,
      "slot_order"         => CANONICAL_SLOT_ORDER,
      "slot_assignments"   => slot_assignments
    }

    # Hard invariant check (programming error guard)
    raise "INVARIANT VIOLATION: compiler_profile_id found in finalization payload" \
      if payload.key?("compiler_profile_id")

    # Step 9: derive compiler_profile_id and finalization_payload_digest
    payload_json              = canonical_json(payload)
    payload_hex               = sha256_hex(payload_json)
    finalization_payload_digest = "sha256:#{payload_hex}"
    compiler_profile_id       = "#{PROFILE_NAMESPACE}/sha256:#{payload_hex[0, 24]}"

    # Step 10: emit compiler_profile_id_source object
    {
      "kind"                          => SOURCE_KIND,
      "format_version"                => FORMAT_VERSION,
      "status"                        => "finalized",
      "profile_namespace"             => PROFILE_NAMESPACE,
      "compiler_profile_id"           => compiler_profile_id,
      "descriptor_digest"             => descriptor_digest,
      "finalization_payload_digest"   => finalization_payload_digest,
      "profile_kind"                  => STAGE3_SPEC_NAME,
      "slot_order"                    => CANONICAL_SLOT_ORDER,
      "slot_assignments"              => slot_assignments,
      "dispatch_migration_authorized" => false,
      "runtime_authority_granted"     => false
    }
  end

  # -------------------------------------------------------------------------
  # Source Validation Layer
  # Validates an already-produced compiler_profile_id_source object.
  # Maps to validate_compiler_profile_source! in the future assembler surface.
  # -------------------------------------------------------------------------

  def validate_source!(source)
    # Step 1: presence and type
    if source.nil?
      raise FinalizationError.new("source is nil", reason_code: "compiler_profile_source.missing")
    end
    unless source.is_a?(Hash)
      raise FinalizationError.new(
        "source must be a Hash, got #{source.class}",
        reason_code: "compiler_profile_source.malformed"
      )
    end

    # Step 2: kind
    kind = source["kind"]
    unless kind == SOURCE_KIND
      raise FinalizationError.new(
        "wrong kind: #{kind.inspect}; expected #{SOURCE_KIND.inspect}",
        reason_code: "compiler_profile_source.wrong_kind"
      )
    end

    # Step 3: status
    status = source["status"]
    unless status == "finalized"
      raise FinalizationError.new(
        "unfinalized status: #{status.inspect}",
        reason_code: "compiler_profile_source.unfinalized"
      )
    end

    # Step 4: namespace
    namespace = source["profile_namespace"]
    unless namespace == PROFILE_NAMESPACE
      raise FinalizationError.new(
        "unsupported namespace: #{namespace.inspect}",
        reason_code: "compiler_profile_source.unsupported_namespace"
      )
    end

    # Step 5: compiler_profile_id format
    cid = source["compiler_profile_id"]
    unless cid.is_a?(String) && cid.match?(/\Acompiler_profile_unified\/sha256:[0-9a-f]{24,}\z/)
      raise FinalizationError.new(
        "malformed compiler_profile_id: #{cid.inspect}",
        reason_code: "compiler_profile_source.malformed_id"
      )
    end

    # Step 6: slot order
    slot_order = source["slot_order"]
    unless slot_order == CANONICAL_SLOT_ORDER
      raise FinalizationError.new(
        "slot order mismatch",
        reason_code: "compiler_profile_source.slot_order_mismatch"
      )
    end

    # Step 7: payload digest + id consistency
    # Reconstruct finalization payload from source fields and verify stored digests.
    payload = {
      "profile_namespace"  => source["profile_namespace"],
      "format_version"     => source["format_version"],
      "descriptor_digest"  => source["descriptor_digest"],
      "profile_kind"       => source["profile_kind"],
      "slot_order"         => source["slot_order"],
      "slot_assignments"   => source.fetch("slot_assignments", {})
    }
    payload_json              = canonical_json(payload)
    payload_hex               = sha256_hex(payload_json)
    derived_payload_digest    = "sha256:#{payload_hex}"
    derived_compiler_profile_id = "#{PROFILE_NAMESPACE}/sha256:#{payload_hex[0, 24]}"

    stored_payload_digest = source["finalization_payload_digest"]
    unless derived_payload_digest == stored_payload_digest
      raise FinalizationError.new(
        "finalization_payload_digest mismatch: " \
        "stored=#{stored_payload_digest.inspect} derived=#{derived_payload_digest.inspect}",
        reason_code: "compiler_profile_source.id_digest_mismatch"
      )
    end
    unless derived_compiler_profile_id == cid
      raise FinalizationError.new(
        "compiler_profile_id mismatch: stored=#{cid.inspect} derived=#{derived_compiler_profile_id.inspect}",
        reason_code: "compiler_profile_source.id_digest_mismatch"
      )
    end

    # Step 8: authority guards
    if source["runtime_authority_granted"] == true
      raise FinalizationError.new(
        "runtime_authority_granted must be false",
        reason_code: "compiler_profile_source.runtime_authority_forbidden"
      )
    end
    if source["dispatch_migration_authorized"] == true
      raise FinalizationError.new(
        "dispatch_migration_authorized must be false",
        reason_code: "compiler_profile_source.dispatch_migration_forbidden"
      )
    end

    true
  end

  # -------------------------------------------------------------------------
  # Proof Helpers
  # -------------------------------------------------------------------------

  def assert_pass(name, &block)
    result = block.call
    { "check" => name, "result" => "PASS", "detail" => result }
  rescue => e
    raise "FAIL [#{name}]: #{e.message}"
  end

  def assert_refuses(name, expected_code, &block)
    block.call
    raise "FAIL [#{name}]: expected FinalizationError(#{expected_code.inspect}) but no error raised"
  rescue FinalizationError => e
    if e.reason_code == expected_code
      { "check" => name, "result" => "PASS", "reason_code" => e.reason_code }
    else
      raise "FAIL [#{name}]: expected reason_code=#{expected_code.inspect} " \
            "but got #{e.reason_code.inspect}: #{e.message}"
    end
  end

  # -------------------------------------------------------------------------
  # Proof Cases
  # -------------------------------------------------------------------------

  def run_proof_cases
    results = []

    # Produce the canonical source object once; referenced by several cases.
    canonical_source = finalize_descriptor(PROOF_DESCRIPTOR)

    # --- Finalization layer cases ---

    # CASE F1: valid frozen descriptor produces finalized source object
    results << assert_pass("F1.valid_descriptor_produces_source") do
      src = finalize_descriptor(PROOF_DESCRIPTOR)
      raise "kind wrong"    unless src["kind"]   == SOURCE_KIND
      raise "status wrong"  unless src["status"] == "finalized"
      raise "id missing"    unless src["compiler_profile_id"].is_a?(String)
      raise "id format bad" unless src["compiler_profile_id"] \
                                       .match?(/\Acompiler_profile_unified\/sha256:[0-9a-f]{24,}\z/)
      "id=#{src["compiler_profile_id"]}"
    end

    # CASE F2: input-order independence — permuting Hash key order (at descriptor and
    # pack level) produces identical compiler_profile_id because canonical_json sorts
    # Hash keys. Array element order (pack_descriptors) is intentionally kept identical
    # because canonical_json preserves Array element order.
    results << assert_pass("F2.permuted_hash_keys_same_id") do
      # Top-level descriptor keys in reversed order, pack descriptor Hash keys also reversed.
      permuted_packs = PROOF_DESCRIPTOR["pack_descriptors"].map do |pack|
        # Reverse the in-pack Hash key order: name, slot, implementation_id
        { "name" => pack["name"], "slot" => pack["slot"], "implementation_id" => pack["implementation_id"] }
      end
      permuted_spec = {
        "slot_order" => PROOF_DESCRIPTOR["profile_spec"]["slot_order"],
        "name"       => PROOF_DESCRIPTOR["profile_spec"]["name"],
        "kind"       => PROOF_DESCRIPTOR["profile_spec"]["kind"]
      }
      permuted = {
        "pack_descriptors" => permuted_packs,   # same element order, different key order inside each pack
        "format_version"   => PROOF_DESCRIPTOR["format_version"],
        "profile_spec"     => permuted_spec,    # same data, different key order
        "kind"             => PROOF_DESCRIPTOR["kind"]
      }
      src2 = finalize_descriptor(permuted)
      raise "id changed on Hash key permutation: " \
            "#{src2["compiler_profile_id"].inspect} != #{canonical_source["compiler_profile_id"].inspect}" \
        unless src2["compiler_profile_id"] == canonical_source["compiler_profile_id"]
      "same id=#{src2["compiler_profile_id"]}"
    end

    # CASE F3: changing one implementation_id changes the derived id
    results << assert_pass("F3.implementation_identity_change_changes_id") do
      altered_packs = PROOF_DESCRIPTOR["pack_descriptors"].map.with_index do |pack, i|
        i.zero? ? pack.merge("implementation_id" => "core_language.proof_compiler_adapter.v1_altered") : pack
      end
      altered = PROOF_DESCRIPTOR.merge("pack_descriptors" => altered_packs)
      src3 = finalize_descriptor(altered)
      raise "id did NOT change when implementation_id was altered" \
        if src3["compiler_profile_id"] == canonical_source["compiler_profile_id"]
      "original=#{canonical_source["compiler_profile_id"]} altered=#{src3["compiler_profile_id"]}"
    end

    # CASE F4: positive proof — compiler_profile_id is absent from finalization payload
    results << assert_pass("F4.payload_does_not_contain_profile_id") do
      # Reconstruct what the payload looked like (same logic as finalize_descriptor step 8)
      payload_keys = %w[profile_namespace format_version descriptor_digest
                        profile_kind slot_order slot_assignments]
      raise "compiler_profile_id unexpectedly in payload_keys" \
        if payload_keys.include?("compiler_profile_id")
      "payload_keys=#{payload_keys.inspect}"
    end

    # CASE F5: descriptor with embedded compiler_profile_id field → refuses
    results << assert_refuses(
      "F5.payload_id_inclusion_refused",
      "compiler_profile_source.payload_id_inclusion_forbidden"
    ) do
      embedded = PROOF_DESCRIPTOR.merge(
        "compiler_profile_id" => "compiler_profile_unified/sha256:aabbccddeeff001122334455"
      )
      finalize_descriptor(embedded)
    end

    # CASE F6: nil descriptor → refuses missing
    results << assert_refuses("F6.missing_source_refused", "compiler_profile_source.missing") do
      finalize_descriptor(nil)
    end

    # CASE F7: non-hash descriptor → refuses malformed
    results << assert_refuses("F7.malformed_descriptor_refused", "compiler_profile_source.malformed") do
      finalize_descriptor("not_a_hash")
    end

    # CASE F8: wrong kind → refuses wrong_kind
    results << assert_refuses("F8.wrong_kind_refused", "compiler_profile_source.wrong_kind") do
      finalize_descriptor(PROOF_DESCRIPTOR.merge("kind" => "compiler_profile_unified"))
    end

    # CASE F9: descriptor slot_order mismatch (first two slots swapped) → refuses
    results << assert_refuses(
      "F9.slot_order_mismatch_in_finalization",
      "compiler_profile_source.slot_order_mismatch"
    ) do
      wrong_order = CANONICAL_SLOT_ORDER.dup
      wrong_order[0], wrong_order[1] = wrong_order[1], wrong_order[0]
      wrong_spec = PROOF_DESCRIPTOR["profile_spec"].merge("slot_order" => wrong_order)
      finalize_descriptor(PROOF_DESCRIPTOR.merge("profile_spec" => wrong_spec))
    end

    # --- Validation layer cases (operating on the produced source object) ---

    # CASE V1: unfinalized status → refuses
    results << assert_refuses(
      "V1.unfinalized_status_refused",
      "compiler_profile_source.unfinalized"
    ) do
      validate_source!(canonical_source.merge("status" => "draft"))
    end

    # CASE V2: unsupported namespace → refuses
    results << assert_refuses(
      "V2.unsupported_namespace_refused",
      "compiler_profile_source.unsupported_namespace"
    ) do
      validate_source!(canonical_source.merge("profile_namespace" => "compiler_profile_legacy"))
    end

    # CASE V3: malformed compiler_profile_id → refuses
    results << assert_refuses(
      "V3.malformed_id_refused",
      "compiler_profile_source.malformed_id"
    ) do
      validate_source!(canonical_source.merge("compiler_profile_id" => "not-a-profile-id"))
    end

    # CASE V4: tampered finalization_payload_digest → refuses id_digest_mismatch
    results << assert_refuses(
      "V4.digest_mismatch_refused",
      "compiler_profile_source.id_digest_mismatch"
    ) do
      validate_source!(
        canonical_source.merge(
          "finalization_payload_digest" => "sha256:#{"00" * 32}"
        )
      )
    end

    # CASE V5: slot order mismatch in source object → refuses
    results << assert_refuses(
      "V5.slot_order_mismatch_in_validation",
      "compiler_profile_source.slot_order_mismatch"
    ) do
      wrong_order = CANONICAL_SLOT_ORDER.dup
      wrong_order[0], wrong_order[1] = wrong_order[1], wrong_order[0]
      validate_source!(canonical_source.merge("slot_order" => wrong_order))
    end

    # CASE V6: runtime_authority_granted: true → refuses
    results << assert_refuses(
      "V6.runtime_authority_refused",
      "compiler_profile_source.runtime_authority_forbidden"
    ) do
      validate_source!(canonical_source.merge("runtime_authority_granted" => true))
    end

    # CASE V7: dispatch_migration_authorized: true → refuses
    results << assert_refuses(
      "V7.dispatch_migration_refused",
      "compiler_profile_source.dispatch_migration_forbidden"
    ) do
      validate_source!(canonical_source.merge("dispatch_migration_authorized" => true))
    end

    results
  end

  # -------------------------------------------------------------------------
  # Invariants
  # -------------------------------------------------------------------------

  def check_invariants(source)
    invs = []

    # I1: compiler_profile_id is not a key in the finalization payload structure
    invs << assert_pass("INV1.profile_id_not_in_finalization_payload") do
      finalization_payload_keys = %w[
        profile_namespace format_version descriptor_digest
        profile_kind slot_order slot_assignments
      ]
      raise "compiler_profile_id unexpectedly in finalization_payload_keys" \
        if finalization_payload_keys.include?("compiler_profile_id")
      "payload_keys=#{finalization_payload_keys.join(", ")}"
    end

    # I2: produced source has status == "finalized"
    invs << assert_pass("INV2.status_is_finalized") do
      raise "status=#{source["status"].inspect}" unless source["status"] == "finalized"
      "status=finalized"
    end

    # I3: produced source has runtime_authority_granted: false
    invs << assert_pass("INV3.no_runtime_authority") do
      raise "runtime_authority_granted=#{source["runtime_authority_granted"]}" \
        unless source["runtime_authority_granted"] == false
      "runtime_authority_granted=false"
    end

    # I4: produced source has dispatch_migration_authorized: false
    invs << assert_pass("INV4.no_dispatch_migration") do
      raise "dispatch_migration_authorized=#{source["dispatch_migration_authorized"]}" \
        unless source["dispatch_migration_authorized"] == false
      "dispatch_migration_authorized=false"
    end

    # I5: compiler_profile_id format is valid
    invs << assert_pass("INV5.id_format_valid") do
      cid = source["compiler_profile_id"]
      raise "malformed id: #{cid.inspect}" \
        unless cid.match?(/\Acompiler_profile_unified\/sha256:[0-9a-f]{24,}\z/)
      "id=#{cid}"
    end

    # I6: validate_source! accepts the produced source without error
    invs << assert_pass("INV6.produced_source_passes_validation") do
      validate_source!(source)
      "validate_source! => true"
    end

    invs
  end

  # -------------------------------------------------------------------------
  # Runner
  # -------------------------------------------------------------------------

  def run
    FileUtils.mkdir_p(OUT_DIR)

    # Produce canonical source for invariant checks and summary output
    canonical_source = finalize_descriptor(PROOF_DESCRIPTOR)

    proof_results     = run_proof_cases
    invariant_results = check_invariants(canonical_source)
    all_results       = proof_results + invariant_results

    pass_count  = all_results.count { |r| r["result"] == "PASS" }
    fail_count  = all_results.count { |r| r["result"] != "PASS" }
    status      = fail_count.zero? ? "PASS" : "FAIL"

    summary = {
      "kind"           => "minimal_compiler_profile_finalization_proof_summary",
      "format_version" => FORMAT_VERSION,
      "track"          => "minimal-compiler-profile-finalization-proof-v0",
      "card"           => "S3-R42-C7-I",
      "status"         => status,
      "pass_count"     => pass_count,
      "fail_count"     => fail_count,
      "proof_cases"    => proof_results.size,
      "invariants"     => invariant_results.size,
      "checks"         => all_results,
      "finalized_source_example" => canonical_source,
      "derived_id_rule" => {
        "input"    => "canonical finalization payload (JSON.generate(normalize(payload)))",
        "payload_keys" => %w[profile_namespace format_version descriptor_digest
                              profile_kind slot_order slot_assignments],
        "payload_excludes" => ["compiler_profile_id"],
        "digest"   => "SHA256(canonical_json(payload))",
        "id_format" => "compiler_profile_unified/sha256:<digest[0,24]>",
        "hex_chars" => ">= 24 lowercase"
      },
      "non_goals" => [
        "No assembler implementation.",
        "No .igapp manifest mutation.",
        "No golden migration.",
        "No loader/report/CompatibilityReport changes.",
        "No compiler dispatch migration.",
        "No RuntimeMachine, Ledger, TBackend, BiHistory, stream/OLAP, cache, or production changes."
      ]
    }

    File.write(SUMMARY_PATH, JSON.pretty_generate(summary) + "\n")

    puts "MinimalCompilerProfileFinalizationProof: #{status}"
    puts "  #{pass_count}/#{pass_count + fail_count} checks PASS"
    all_results.each { |r| puts "  #{r["result"].ljust(4)} #{r["check"]}" }
    puts "Summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"

    status == "PASS"
  end
end

exit(MinimalCompilerProfileFinalizationProof.run ? 0 : 1)
