#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "pathname"

module Prop036ArtifactHashOrderingProof
  ROOT = Pathname.new(File.expand_path("../../..", __dir__))
  EXPERIMENT_DIR = ROOT / "igniter-lang/experiments/prop036_artifact_hash_ordering_proof"
  OUT_DIR = EXPERIMENT_DIR / "out"
  SUMMARY_PATH = OUT_DIR / "prop036_artifact_hash_ordering_summary.json"
  MATRIX_PATH = OUT_DIR / "prop036_artifact_hash_ordering_matrix.json"

  PROFILE_ID = "compiler_profile_unified/sha256:2944e573270aa56fca51cea3"
  OTHER_PROFILE_ID = "compiler_profile_unified/sha256:000000000000000000000000"
  SIGNING_CONTEXT = "synthetic-proof-local-prop036-signing-v0"

  module_function

  def run
    FileUtils.mkdir_p(OUT_DIR)
    matrix = build_matrix
    summary = build_summary(matrix)
    write_json(MATRIX_PATH, matrix)
    write_json(SUMMARY_PATH, summary)
    print_summary(summary)
    summary.fetch("status") == "PASS"
  end

  def build_matrix
    base_material = synthetic_artifact_material
    profiled_material = with_compiler_profile(base_material, PROFILE_ID)
    alternate_profile_material = with_compiler_profile(base_material, OTHER_PROFILE_ID)

    legacy_finalized = finalize_for_signing(base_material)
    profiled_finalized = finalize_for_signing(profiled_material)
    alternate_profile_finalized = finalize_for_signing(alternate_profile_material)

    post_sign_annotation = validate_signed_material(
      material: profiled_material,
      signed_payload: legacy_finalized.fetch("signature_payload"),
      signature: legacy_finalized.fetch("synthetic_signature")
    )

    profile_change_validation = validate_signed_material(
      material: alternate_profile_material,
      signed_payload: profiled_finalized.fetch("signature_payload"),
      signature: profiled_finalized.fetch("synthetic_signature")
    )

    {
      "kind" => "prop036_artifact_hash_ordering_matrix",
      "format_version" => "0.1.0",
      "card" => "S3-R37-C5-P",
      "track" => "prop036-artifact-hash-ordering-proof-v0",
      "proposal_ref" => "docs/proposals/PROP-036-compiler-profile-manifest-identity-v0.md",
      "c3a_authority_ref" => "docs/gates/prop036-compiler-profile-id-acceptance-decision-v0.md",
      "c5p_authority_ref" => "docs/tracks/prop036-loader-status-report-proof-v0.md",
      "synthetic_material_only" => true,
      "real_igapp_mutation" => false,
      "real_loader_implementation" => false,
      "real_assembler_implementation" => false,
      "compiler_dispatch_migration" => false,
      "runtime_machine_binding" => false,
      "production_behavior_change" => false,
      "production_signing" => false,
      "cases" => {
        "profiled_before_hash_and_sign" => case_record(
          finalized: profiled_finalized,
          decision: "accept_profiled_hash_material",
          validation: validate_signed_material(
            material: profiled_material,
            signed_payload: profiled_finalized.fetch("signature_payload"),
            signature: profiled_finalized.fetch("synthetic_signature")
          )
        ),
        "legacy_without_profile" => case_record(
          finalized: legacy_finalized,
          decision: "legacy_optional_hash_material",
          validation: validate_signed_material(
            material: base_material,
            signed_payload: legacy_finalized.fetch("signature_payload"),
            signature: legacy_finalized.fetch("synthetic_signature")
          )
        ),
        "post_sign_annotation_forbidden" => {
          "decision" => "refuse_post_sign_profile_annotation",
          "original_hash" => legacy_finalized.fetch("artifact_hash"),
          "recomputed_profiled_hash" => artifact_hash(profiled_material),
          "signed_profile_id" => legacy_finalized.dig("signature_payload", "compiler_profile_id"),
          "manifest_profile_id" => PROFILE_ID,
          "validation" => post_sign_annotation
        },
        "profile_id_change_changes_hash" => {
          "decision" => "require_rehash_and_resign",
          "profile_id" => PROFILE_ID,
          "profile_hash" => profiled_finalized.fetch("artifact_hash"),
          "other_profile_id" => OTHER_PROFILE_ID,
          "other_profile_hash" => alternate_profile_finalized.fetch("artifact_hash"),
          "hashes_differ" => profiled_finalized.fetch("artifact_hash") !=
            alternate_profile_finalized.fetch("artifact_hash"),
          "signatures_differ" => profiled_finalized.fetch("synthetic_signature") !=
            alternate_profile_finalized.fetch("synthetic_signature")
        },
        "signature_profile_mismatch_refused" => {
          "decision" => "refuse_signature_profile_mismatch",
          "signed_profile_id" => PROFILE_ID,
          "manifest_profile_id" => OTHER_PROFILE_ID,
          "validation" => profile_change_validation
        }
      }
    }
  end

  def case_record(finalized:, decision:, validation:)
    {
      "decision" => decision,
      "artifact_hash" => finalized.fetch("artifact_hash"),
      "signature_payload" => finalized.fetch("signature_payload"),
      "synthetic_signature" => finalized.fetch("synthetic_signature"),
      "validation" => validation
    }
  end

  def synthetic_artifact_material
    {
      "manifest" => {
        "kind" => "igapp_manifest",
        "format_version" => "0.1.0",
        "format" => "igapp_dir",
        "manifest_ref" => "synthetic/prop036/artifact_hash_ordering/manifest",
        "program_id" => "synthetic.prop036.ArtifactHashOrdering",
        "language_version" => "0.1.0",
        "grammar_version" => "0.1.0",
        "semantic_ir_ref" => "semantic_ir_program.json",
        "contracts" => ["synthetic_add_contract"]
      },
      "semantic_ir_program" => {
        "kind" => "semantic_ir_program",
        "format_version" => "0.1.0",
        "nodes" => [
          { "id" => "input.left", "kind" => "input_node", "type" => "Integer" },
          { "id" => "input.right", "kind" => "input_node", "type" => "Integer" },
          {
            "id" => "compute.sum",
            "kind" => "compute_node",
            "op" => "add",
            "inputs" => ["input.left", "input.right"],
            "type" => "Integer"
          }
        ]
      },
      "contracts" => [
        {
          "id" => "synthetic_add_contract",
          "fragment_class" => "CORE",
          "outputs" => [{ "name" => "sum", "node_ref" => "compute.sum", "type" => "Integer" }]
        }
      ]
    }
  end

  def with_compiler_profile(material, profile_id)
    copy = deep_copy(material)
    copy.fetch("manifest")["compiler_profile_id"] = profile_id
    copy
  end

  def finalize_for_signing(material)
    hash = artifact_hash(material)
    payload = {
      "artifact_hash" => hash,
      "compiler_profile_id" => material.dig("manifest", "compiler_profile_id"),
      "signing_context" => SIGNING_CONTEXT,
      "synthetic_signature_only" => true
    }

    {
      "artifact_hash" => hash,
      "signature_payload" => payload,
      "synthetic_signature" => synthetic_signature(payload)
    }
  end

  def validate_signed_material(material:, signed_payload:, signature:)
    recomputed_hash = artifact_hash(material)
    manifest_profile_id = material.dig("manifest", "compiler_profile_id")
    signed_profile_id = signed_payload.fetch("compiler_profile_id")
    signature_valid = synthetic_signature(signed_payload) == signature
    hash_matches_material = signed_payload.fetch("artifact_hash") == recomputed_hash
    profile_matches_material = signed_profile_id == manifest_profile_id

    {
      "signature_valid_for_payload" => signature_valid,
      "hash_matches_material" => hash_matches_material,
      "profile_matches_material" => profile_matches_material,
      "accepted_by_profile_aware_policy" => signature_valid && hash_matches_material && profile_matches_material,
      "signed_profile_id" => signed_profile_id,
      "manifest_profile_id" => manifest_profile_id,
      "signed_hash" => signed_payload.fetch("artifact_hash"),
      "recomputed_hash" => recomputed_hash
    }
  end

  def build_summary(matrix)
    checks = checks_for(matrix)
    {
      "kind" => "prop036_artifact_hash_ordering_summary",
      "format_version" => "0.1.0",
      "card" => matrix.fetch("card"),
      "track" => matrix.fetch("track"),
      "status" => checks.values.all? ? "PASS" : "FAIL",
      "matrix_ref" => MATRIX_PATH.relative_path_from(ROOT).to_s,
      "authority_refs" => {
        "c3a" => matrix.fetch("c3a_authority_ref"),
        "c5p" => matrix.fetch("c5p_authority_ref")
      },
      "implementation_blockers" => implementation_blockers,
      "checks" => checks
    }
  end

  def checks_for(matrix)
    cases = matrix.fetch("cases")
    profiled = cases.fetch("profiled_before_hash_and_sign")
    legacy = cases.fetch("legacy_without_profile")
    post_sign = cases.fetch("post_sign_annotation_forbidden")
    changed = cases.fetch("profile_id_change_changes_hash")
    mismatch = cases.fetch("signature_profile_mismatch_refused")

    {
      "authority.cites_c3a" => matrix.fetch("c3a_authority_ref").include?("acceptance-decision"),
      "authority.cites_c5p" => matrix.fetch("c5p_authority_ref").include?("loader-status-report"),
      "scope.synthetic_material_only" => matrix.fetch("synthetic_material_only") == true,
      "scope.no_real_igapp_mutation" => matrix.fetch("real_igapp_mutation") == false,
      "scope.no_real_loader_implementation" => matrix.fetch("real_loader_implementation") == false,
      "scope.no_real_assembler_implementation" => matrix.fetch("real_assembler_implementation") == false,
      "scope.no_compiler_dispatch_migration" => matrix.fetch("compiler_dispatch_migration") == false,
      "scope.no_runtime_machine_binding" => matrix.fetch("runtime_machine_binding") == false,
      "scope.no_production_behavior_change" => matrix.fetch("production_behavior_change") == false,
      "scope.no_production_signing" => matrix.fetch("production_signing") == false,
      "ordering.profiled_before_hash_accepts" =>
        profiled.dig("validation", "accepted_by_profile_aware_policy") == true,
      "ordering.signature_payload_covers_profile_id" =>
        profiled.dig("signature_payload", "compiler_profile_id") == PROFILE_ID,
      "ordering.legacy_optional_hash_still_valid_for_legacy_material" =>
        legacy.dig("validation", "accepted_by_profile_aware_policy") == true &&
          legacy.dig("signature_payload", "compiler_profile_id").nil?,
      "negative.post_sign_annotation_refused" =>
        post_sign.dig("validation", "accepted_by_profile_aware_policy") == false &&
          post_sign.fetch("original_hash") != post_sign.fetch("recomputed_profiled_hash"),
      "negative.post_sign_annotation_not_signature_covered" =>
        post_sign.fetch("signed_profile_id").nil? &&
          post_sign.fetch("manifest_profile_id") == PROFILE_ID,
      "hash.profile_id_changes_artifact_hash" => changed.fetch("hashes_differ") == true,
      "hash.profile_id_changes_signature_payload" => changed.fetch("signatures_differ") == true,
      "negative.signature_profile_mismatch_refused" =>
        mismatch.dig("validation", "accepted_by_profile_aware_policy") == false &&
          mismatch.dig("validation", "profile_matches_material") == false,
      "blockers.expanded_list_preserved" => implementation_blockers.length >= 10
    }
  end

  def implementation_blockers
    [
      "Cite PROP-036, S3-R35-C3-A acceptance, and S3-R36-C5-P loader proof authority",
      "Receive separate Architect/supervisor authorization before any implementation",
      "Name exactly one implementation surface for the card",
      "Preserve compiler_profile.present_verified != runtime ready",
      "Preserve legacy_optional unless a later Architect decision changes rollout",
      "Do not roll out profile_required without migration evidence",
      "Do not mutate real .igapp manifests or .ilk artifacts unless explicitly authorized",
      "Do not implement real loader, assembler, CompatibilityReport, or artifact golden migration from this proof",
      "Do not migrate compiler dispatch from this proof",
      "Do not bind RuntimeMachine or grant runtime execution authority from this proof",
      "Carry this hash-ordering proof into assembler field design before any artifact_hash migration",
      "Keep proof-local fixture output separate from real goldens"
    ]
  end

  def artifact_hash(material)
    "sha256:#{Digest::SHA256.hexdigest(canonical_json(material))}"
  end

  def synthetic_signature(payload)
    digest = Digest::SHA256.hexdigest(canonical_json(payload))
    "synthetic-signature/sha256:#{digest}"
  end

  def canonical_json(value)
    JSON.generate(canonicalize(value))
  end

  def canonicalize(value)
    case value
    when Hash
      value.keys.sort.each_with_object({}) do |key, sorted|
        sorted[key] = canonicalize(value.fetch(key))
      end
    when Array
      value.map { |item| canonicalize(item) }
    else
      value
    end
  end

  def deep_copy(value)
    Marshal.load(Marshal.dump(value))
  end

  def write_json(path, value)
    FileUtils.mkdir_p(path.dirname)
    File.write(path, "#{JSON.pretty_generate(value)}\n")
  end

  def print_summary(summary)
    puts "#{summary.fetch("status")} prop036_artifact_hash_ordering_proof"
    summary.fetch("checks").each do |name, passed|
      puts "#{name}: #{passed ? "ok" : "FAIL"}"
    end
    puts "summary: #{SUMMARY_PATH.relative_path_from(ROOT)}"
  end
end

success = Prop036ArtifactHashOrderingProof.run
exit(success ? 0 : 1)
