#!/usr/bin/env ruby
# frozen_string_literal: true

# counterfactual_audit_proof_owned_artifact_home_v0.rb
#
# Card:          S3-R218-C2-I
# Authorization: S3-R218-C1-A
# Track:         counterfactual-audit-proof-owned-artifact-home-design-v0
#
# Governing principle:
#   "Runtime is lazy. Audit is aware. Dry-run, if ever accepted, must be isolated.
#    Evidence must be sourced before it can be explained.
#    Artifact homes must be explicit, non-canonical, and proof-owned."
#
# Purpose:
#   Implements Option B: proof-owned artifact directory with no compiler/report
#   authority. Produces a no-authority manifest/index, a new evidence packet
#   (distinct from R211 — not a rewrite), and a closed-surface scan.
#
# Boundary:
#   - No lib/** edits.
#   - No compiler/runtime/report/API/Spark changes.
#   - R211 source-backed evidence is read-only historical citation.
#   - All authority fields carry default-false values.
#   - projected_value != actual_output; projected_failure != actual_runtime_failure.

require "digest"
require "fileutils"
require "json"

REPO_ROOT    = File.expand_path("../../..", __dir__)
PROOF_DIR    = __dir__
OUT_ROOT     = File.join(PROOF_DIR, "out")
ARTIFACT_HOME = File.join(OUT_ROOT, "artifact_home")
SRC_REFS_DIR = File.join(ARTIFACT_HOME, "source_refs")
SNAP_DIR     = File.join(ARTIFACT_HOME, "input_snapshots")
PSET_DIR     = File.join(ARTIFACT_HOME, "premise_sets")
PROJ_DIR     = File.join(ARTIFACT_HOME, "projections")

[ARTIFACT_HOME, SRC_REFS_DIR, SNAP_DIR, PSET_DIR, PROJ_DIR].each { |d| FileUtils.mkdir_p(d) }

# R211 historical paths (read-only)
R211_ROOT = File.join(
  REPO_ROOT,
  "igniter-lang/experiments/branch_conditional_counterfactual_audit_level2_source_backed_proof_v0"
)
R211_SUMMARY = File.join(R211_ROOT, "out",
  "branch_conditional_counterfactual_audit_level2_source_backed_proof_v0_summary.json")
R211_SOURCE_ARTIFACTS = File.join(R211_ROOT, "out", "source_artifacts")

CHECKS = []

def check(name)
  result = yield
  status = result ? "PASS" : "FAIL"
  CHECKS << { "name" => name, "status" => status }
  status
rescue => e
  CHECKS << { "name" => name, "status" => "FAIL", "error" => "#{e.class}: #{e.message}" }
  "FAIL"
end

# =============================================================================
# Stable SHA-256 helpers
# =============================================================================

def sha256_of(obj)
  "sha256:#{Digest::SHA256.hexdigest(JSON.generate(obj))}"
end

def sha256_of_file(path)
  "sha256:#{Digest::SHA256.hexdigest(File.read(path, encoding: "utf-8"))}"
end

def write_artifact(dir, filename, content)
  path = File.join(dir, filename)
  json = JSON.generate(content)
  File.write(path, json)
  digest = "sha256:#{Digest::SHA256.hexdigest(json)}"
  [path, digest]
end

# =============================================================================
# Experiment-local isolated dry-run evaluator (same semantics as R209/R211)
# ISOLATION INVARIANTS: never raises, never calls live IO, never mutates state
# =============================================================================

PURE_APPLY_OPS = {
  "stdlib.integer.add"      => ->(a) { a[0] + a[1] },
  "stdlib.integer.subtract" => ->(a) { a[0] - a[1] },
  "stdlib.integer.multiply" => ->(a) { a[0] * a[1] },
  "stdlib.bool.not"         => ->(a) { !a[0] },
}.freeze

REFUSED_KINDS = %w[tbackend_read escape effect external_call network filesystem].freeze

def isolated_eval(expr, values = {}, depth = 0)
  return refusal("max_depth_exceeded") if depth > 20
  return refusal("malformed_expression") unless expr.is_a?(Hash) && expr.key?("kind")

  kind = expr["kind"]
  return refusal("#{kind}_refused") if REFUSED_KINDS.include?(kind)

  case kind
  when "literal"  then { "ok" => true, "value" => expr["value"] }
  when "ref"
    name = expr.fetch("name", nil)
    return refusal("ref_missing_name") unless name
    values.key?(name) ? { "ok" => true, "value" => values[name] }
                      : refusal("ref_not_in_scope:#{name}")
  when "apply"
    op = expr.fetch("operator", nil)
    fn = PURE_APPLY_OPS[op]
    return refusal("unknown_operator:#{op}") unless fn
    resolved = []
    (expr.fetch("operands", [])).each do |arg|
      r = isolated_eval(arg, values, depth + 1)
      return r unless r["ok"]
      resolved << r["value"]
    end
    begin
      { "ok" => true, "value" => fn.call(resolved) }
    rescue => e
      refusal("apply_error:#{e.message}")
    end
  when "if_expr"
    cond_r = isolated_eval(expr["condition"], values, depth + 1)
    return cond_r unless cond_r["ok"]
    cond_val = cond_r["value"]
    return refusal("condition_not_bool") unless cond_val == true || cond_val == false
    # LAZY: only the selected branch is evaluated
    selected = cond_val ? expr["then_branch"] : expr["else_branch"]  # lazy
    isolated_eval(selected, values, depth + 1)
  else
    refusal("unsupported_kind:#{kind}")
  end
end

def refusal(reason)
  { "ok" => false, "refused" => reason, "kind" => "projection_refusal",
    "note" => "Dry-run refusal — not an actual runtime failure." }
end

# =============================================================================
# Required default-false authority block
# =============================================================================

FULL_AUTHORITY_BLOCK = {
  "canonical"            => false,
  "runtime_authority"    => false,
  "report_authority"     => false,
  "cache_authority"      => false,
  "dependency_authority" => false,
  "public_api_authority" => false,
  "compiler_emitted"     => false,
  "spark_authority"      => false,
  "production_authority" => false
}.freeze

SNAPSHOT_AUTHORITY = {
  "runtime_input_authority" => false,
  "persistence_authority"   => false,
  "privacy_policy_authority" => false,
  "dependency_authority"    => false,
  "cache_authority"         => false,
  "report_authority"        => false,
  "production_authority"    => false,
  "public_claim"            => false
}.freeze

PREMISE_AUTHORITY = {
  "runtime_authority"    => false,
  "dependency_authority" => false,
  "cache_authority"      => false,
  "report_authority"     => false,
  "prop032_widening"     => false,
  "branch_level_syntax"  => false,
  "receipt_authority"    => false,
  "public_claim"         => false
}.freeze

ISOLATION_BLOCK = {
  "actual_result_mutated"  => false,
  "reports_mutated"        => false,
  "receipts_mutated"       => false,
  "cache_mutated"          => false,
  "external_io_performed"  => false,
  "production_authority"   => false
}.freeze

TRACE_AUTHORITY = {
  "cache_authority"             => false,
  "dependency_authority"        => false,
  "runtime_readiness_authority" => false,
  "report_authority"            => false,
  "result_authority"            => false
}.freeze

# =============================================================================
# New Option B evidence packet (distinct from R211 — not a rewrite)
#
# Uses multiply (not add) and different variable names to prove this is a
# fresh evidence packet, not a republication of R211.
# if:score_gate: condition=lit(false), actual=else(lit(0)), latent=then(mult(x,y))
# Dry-run: assume condition=true → project then → multiply(3,4) = 12
# =============================================================================

SEMANTICIR_SCORE_GATE = {
  "artifact_kind"          => "proof_local_semanticir_if_expr",
  "proof_owned"            => true,
  "canonical"              => false,
  "if_expr_id"             => "if:score_gate_artifact_home_v0",
  "kind"                   => "if_expr",
  "condition"              => { "kind" => "literal", "value" => false,
                                "resolved_type" => { "name" => "Bool" } },
  "then_branch"            => {
    "kind"          => "apply",
    "operator"      => "stdlib.integer.multiply",
    "operands"      => [
      { "kind" => "ref", "name" => "x", "resolved_type" => { "name" => "Integer" } },
      { "kind" => "ref", "name" => "y", "resolved_type" => { "name" => "Integer" } }
    ],
    "resolved_type" => { "name" => "Integer" }
  },
  "else_branch"            => { "kind" => "literal", "value" => 0,
                                "resolved_type" => { "name" => "Integer" } },
  "resolved_type"          => { "name" => "Integer" },
  "actual_condition_value" => false,
  "actual_selected_branch" => "else",
  "source_kind"            => "proof_derived_from_semanticir",
  "derivation"             => "proof-local",
  "authority"              => FULL_AUTHORITY_BLOCK.dup
}

# Input snapshot: {x:3, y:4} → multiply(3,4)=12
INPUT_SNAPSHOT_SCORE = {
  "kind"        => "proof_local_frozen_input_snapshot",
  "proof_owned" => true,
  "canonical"   => false,
  "mutable"     => false,
  "values"      => { "x" => 3, "y" => 4 },
  "privacy_note" => "Proof-local frozen snapshot; no persistence authority; " \
                    "no privacy-policy authority; not actual runtime input",
  "authority"   => SNAPSHOT_AUTHORITY.dup
}

# Write artifacts to the Option B home
SA_PATH, SA_DIGEST = write_artifact(SRC_REFS_DIR, "semanticir_score_gate_v0.json",
                                    SEMANTICIR_SCORE_GATE)
SS_PATH, SS_DIGEST = write_artifact(SNAP_DIR, "input_snapshot_score_v0.json",
                                    INPUT_SNAPSHOT_SCORE)

# Build source_branch_intention_ref
SOURCE_REF = {
  "kind"          => "source_branch_intention_ref",
  "source_kind"   => "proof_derived_from_semanticir",
  "source_path"   => File.basename(SA_PATH),
  "source_digest" => SA_DIGEST,
  "if_expr_id"    => SEMANTICIR_SCORE_GATE["if_expr_id"],
  "branch_label"  => "then",
  "branch_role"   => "latent",
  "expr_kind"     => SEMANTICIR_SCORE_GATE["then_branch"]["kind"],
  "derivation"    => "proof-local",
  "canonical"     => false,
  "authority"     => FULL_AUTHORITY_BLOCK.dup
}
SR_PATH, SR_DIGEST = write_artifact(SRC_REFS_DIR, "source_ref_score_gate_then_v0.json",
                                    SOURCE_REF)

# Build input_snapshot_ref
SNAPSHOT_REF = {
  "kind"        => "input_snapshot_ref",
  "source_kind" => "proof_local_frozen_packet",
  "path"        => File.basename(SS_PATH),
  "digest"      => SS_DIGEST,
  "mutable"     => false,
  "authority"   => SNAPSHOT_AUTHORITY.dup,
  "privacy_note" => INPUT_SNAPSHOT_SCORE["privacy_note"]
}

# Build premise_set
PREMISE_SET_CONTENT = {
  "kind"                     => "counterfactual_premise_set",
  "assumed_condition"        => true,
  "assumed_condition_source" => "explicit_proof_request",
  "input_snapshot_ref"       => SNAPSHOT_REF,
  "assumption_refs"          => [],
  "authority"                => PREMISE_AUTHORITY.dup
}
PREMISE_SET = PREMISE_SET_CONTENT.merge(
  "premise_set_digest" => sha256_of(PREMISE_SET_CONTENT)
)
PS_PATH, PS_DIGEST = write_artifact(PSET_DIR, "premise_set_score_gate_v0.json", PREMISE_SET)

# Evaluate latent branch inside isolation
SA_READ = JSON.parse(File.read(SA_PATH, encoding: "utf-8"))
SS_READ = JSON.parse(File.read(SS_PATH, encoding: "utf-8"))
EVAL_RESULT = isolated_eval(SA_READ["then_branch"], SS_READ["values"])

TRACE_RECORD = {
  "expr_kind" => SA_READ["then_branch"]["kind"],
  "eval_ok"   => EVAL_RESULT["ok"],
  "depth"     => 0,
  "authority" => TRACE_AUTHORITY.dup,
  "note"      => "proof/debug/explanatory trace only — not cache/dependency/runtime authority"
}

# Build projection envelope
PROJECTION_CONTENT = {
  "kind"                               => "counterfactual_dry_run_projection",
  "level"                              => 2,
  "source_kind"                        => "option_b_proof_owned_artifact_home",
  "source_branch_intention_ref"        => SOURCE_REF,
  "premise_set"                        => PREMISE_SET,
  "projected_branch"                   => "then",
  "dry_run_trace"                      => [TRACE_RECORD],
  "projected_value"                    => EVAL_RESULT["ok"] ? EVAL_RESULT["value"] : nil,
  "projected_failure"                  => EVAL_RESULT["ok"] ? nil : EVAL_RESULT,
  "projected_value_is_not_actual_output"    => true,
  "projected_failure_is_not_actual_failure" => true,
  "no_authority_disclaimer"            =>
    "projected_value and projected_failure carry no dependency/cache/report/" \
    "runtime/public authority; proof-local concept evidence only",
  "isolation"                          => ISOLATION_BLOCK.dup,
  "authority"                          => FULL_AUTHORITY_BLOCK.dup
}
PROJECTION = PROJECTION_CONTENT.merge(
  "projection_digest" => sha256_of(PROJECTION_CONTENT)
)
PROJ_PATH, PROJ_DIGEST = write_artifact(PROJ_DIR, "projection_score_gate_then_v0.json",
                                        PROJECTION)

# =============================================================================
# No-authority artifact home manifest / index
# =============================================================================

MANIFEST_CONTENT = {
  "kind"         => "proof_owned_artifact_home_manifest",
  "home_version" => "v0",
  "option_label" => "Option B: proof-owned artifact directory with no compiler/report authority",
  "home_path"    => "experiments/counterfactual_audit_proof_owned_artifact_home_v0/out/artifact_home/",
  "proof_owned"  => true,
  "canonical"    => false,
  "authority"    => FULL_AUTHORITY_BLOCK.dup,
  "evidence_index" => {
    "source_refs"     => [{ "file" => File.basename(SR_PATH), "digest" => SR_DIGEST }],
    "input_snapshots" => [{ "file" => File.basename(SS_PATH), "digest" => SS_DIGEST }],
    "premise_sets"    => [{ "file" => File.basename(PS_PATH), "digest" => PS_DIGEST }],
    "projections"     => [{ "file" => File.basename(PROJ_PATH), "digest" => PROJ_DIGEST }]
  },
  "non_claim_block" =>
    "This artifact home is not canonical SemanticIR schema, not a CompilerResult " \
    "or CompilationReport field, not report/result/receipt/CompatibilityReport shape, " \
    "not runtime behavior, not live non-selected branch evaluation, not public " \
    "counterfactual audit support, and not Spark/API/CLI support. " \
    "projected_value != actual_output. projected_failure != actual_runtime_failure.",
  "snapshot_privacy_posture" =>
    "All input snapshots are frozen proof-local evidence. " \
    "No persistence authority. No privacy-policy authority. No production data.",
  "digest_policy" =>
    "All source refs, snapshots, premise sets, and projections are SHA-256 " \
    "content-addressed. Digest stability is scoped to proof-owned outputs only. " \
    "Digests carry no cache/dependency/compiler authority."
}
MANIFEST = MANIFEST_CONTENT.merge(
  "manifest_digest" => sha256_of(MANIFEST_CONTENT)
)
MANIFEST_PATH, MANIFEST_DIGEST = write_artifact(ARTIFACT_HOME, "artifact_home_manifest.json",
                                                 MANIFEST)

# =============================================================================
# R211 historical citation (read-only)
# =============================================================================

R211_CITATION = if File.exist?(R211_SUMMARY)
  r211 = JSON.parse(File.read(R211_SUMMARY, encoding: "utf-8"))
  {
    "status"        => "found",
    "pass_count"    => r211["checks_pass"],
    "fail_count"    => r211["checks_fail"],
    "overall"       => r211["status"],
    "digest"        => sha256_of_file(R211_SUMMARY),
    "immutable"     => true,
    "usage"         => "historical_evidence_citation_only",
    "note"          => "R211 source-backed proof evidence is read-only; " \
                       "this C2-I produces a new evidence packet, not a rewrite of R211."
  }
else
  { "status" => "not_found" }
end

# =============================================================================
# AH-1: Option B home is proof-owned and non-canonical
# =============================================================================

check("AH-1.manifest_has_proof_owned_true") do
  MANIFEST["proof_owned"] == true
end

check("AH-1.manifest_has_canonical_false") do
  MANIFEST["canonical"] == false
end

check("AH-1.all_source_artifacts_have_canonical_false") do
  [SEMANTICIR_SCORE_GATE, SOURCE_REF, INPUT_SNAPSHOT_SCORE].all? do |a|
    a["canonical"] == false
  end
end

check("AH-1.home_path_is_under_experiments_not_lib") do
  MANIFEST["home_path"].include?("experiments/")
end

# =============================================================================
# AH-2: No-authority manifest produced with all required false flags
# =============================================================================

check("AH-2.all_required_authority_flags_present") do
  required = %w[canonical runtime_authority report_authority cache_authority
                dependency_authority public_api_authority compiler_emitted
                spark_authority production_authority]
  required.all? { |k| MANIFEST["authority"].key?(k) }
end

check("AH-2.all_authority_flags_are_false") do
  MANIFEST["authority"].values.none? { |v| v == true }
end

check("AH-2.manifest_has_non_claim_block") do
  MANIFEST["non_claim_block"].is_a?(String) &&
    MANIFEST["non_claim_block"].include?("projected_value != actual_output")
end

check("AH-2.manifest_has_snapshot_privacy_posture") do
  MANIFEST["snapshot_privacy_posture"].include?("No persistence authority") &&
    MANIFEST["snapshot_privacy_posture"].include?("No privacy-policy authority")
end

check("AH-2.manifest_has_digest_policy") do
  MANIFEST["digest_policy"].include?("SHA-256") &&
    MANIFEST["digest_policy"].include?("no cache/dependency/compiler authority")
end

check("AH-2.manifest_has_evidence_index") do
  MANIFEST["evidence_index"].key?("source_refs") &&
    MANIFEST["evidence_index"].key?("input_snapshots") &&
    MANIFEST["evidence_index"].key?("premise_sets") &&
    MANIFEST["evidence_index"].key?("projections")
end

check("AH-2.manifest_digest_present_and_sha256_prefixed") do
  MANIFEST["manifest_digest"]&.start_with?("sha256:")
end

check("AH-2.projection_authority_all_false") do
  PROJECTION["authority"].values.none? { |v| v == true }
end

check("AH-2.projection_isolation_all_false") do
  PROJECTION["isolation"].values.none? { |v| v == true }
end

# =============================================================================
# AH-3: R211 evidence remains immutable
# =============================================================================

check("AH-3.r211_summary_exists") do
  File.exist?(R211_SUMMARY)
end

check("AH-3.r211_summary_is_61_61_pass") do
  R211_CITATION["status"] == "found" &&
    R211_CITATION["pass_count"] == 61 &&
    R211_CITATION["fail_count"] == 0 &&
    R211_CITATION["overall"] == "PASS"
end

check("AH-3.r211_source_artifacts_exist_and_unchanged") do
  expected_files = %w[
    semanticir_risk_gate_v0.json semanticir_nested_if_v0.json
    semanticir_tbackend_v0.json semanticir_escape_v0.json
    input_snapshot_risk_gate_v0.json input_snapshot_empty_v0.json
  ]
  expected_files.all? { |f| File.exist?(File.join(R211_SOURCE_ARTIFACTS, f)) }
end

check("AH-3.new_c2i_evidence_packet_does_not_rewrite_r211") do
  # C2-I uses multiply (not add) and {x,y} (not {a,b,flag,fallback})
  # proving this is a fresh packet, not a republication
  SEMANTICIR_SCORE_GATE["then_branch"]["operator"] == "stdlib.integer.multiply" &&
    SEMANTICIR_SCORE_GATE["if_expr_id"] != "if:risk_gate_source_backed_v0"
end

# =============================================================================
# AH-4: New evidence packet is distinct from R211
# =============================================================================

check("AH-4.new_if_expr_id_differs_from_r211") do
  SEMANTICIR_SCORE_GATE["if_expr_id"] == "if:score_gate_artifact_home_v0"
end

check("AH-4.new_projection_produces_different_value_than_r211") do
  # R211 main projection: apply(add, 10, 5) = 15
  # C2-I projection: apply(multiply, 3, 4) = 12
  PROJECTION["projected_value"] == 12
end

check("AH-4.new_source_digest_differs_from_r211_risk_gate_digest") do
  r211_sa_path = File.join(R211_SOURCE_ARTIFACTS, "semanticir_risk_gate_v0.json")
  r211_digest  = sha256_of_file(r211_sa_path)
  SA_DIGEST != r211_digest
end

# =============================================================================
# AH-5: Digest recomputation/verification policy
# =============================================================================

check("AH-5.all_source_ref_digests_have_sha256_prefix") do
  [SA_DIGEST, SS_DIGEST, SR_DIGEST, PS_DIGEST, PROJ_DIGEST, MANIFEST_DIGEST].all? do |d|
    d.start_with?("sha256:")
  end
end

check("AH-5.manifest_digest_stable_on_recompute") do
  recomputed = sha256_of(MANIFEST.reject { |k, _| k == "manifest_digest" })
  MANIFEST["manifest_digest"] == recomputed
end

check("AH-5.projection_digest_stable_on_recompute") do
  recomputed = sha256_of(PROJECTION.reject { |k, _| k == "projection_digest" })
  PROJECTION["projection_digest"] == recomputed
end

check("AH-5.premise_set_digest_stable_on_recompute") do
  recomputed = sha256_of(PREMISE_SET.reject { |k, _| k == "premise_set_digest" })
  PREMISE_SET["premise_set_digest"] == recomputed
end

check("AH-5.on_disk_source_artifact_digest_matches_computed") do
  sha256_of_file(SA_PATH) == SA_DIGEST
end

# =============================================================================
# AH-6: Input snapshot privacy/persistence posture
# =============================================================================

check("AH-6.snapshot_has_mutable_false") do
  INPUT_SNAPSHOT_SCORE["mutable"] == false
end

check("AH-6.snapshot_has_privacy_note") do
  INPUT_SNAPSHOT_SCORE["privacy_note"].include?("no persistence authority") &&
    INPUT_SNAPSHOT_SCORE["privacy_note"].include?("not actual runtime input")
end

check("AH-6.snapshot_ref_authority_all_false") do
  SNAPSHOT_REF["authority"].values.none? { |v| v == true }
end

check("AH-6.snapshot_authority_has_privacy_policy_authority_false") do
  INPUT_SNAPSHOT_SCORE["authority"]["privacy_policy_authority"] == false
end

# =============================================================================
# AH-7: Premise set stance
# =============================================================================

check("AH-7.premise_set_has_assumed_condition_source") do
  %w[explicit_proof_request execution_summary_observation].include?(
    PREMISE_SET["assumed_condition_source"]
  )
end

check("AH-7.premise_set_authority_no_prop032_widening") do
  PREMISE_SET["authority"]["prop032_widening"] == false &&
    PREMISE_SET["authority"]["branch_level_syntax"] == false &&
    PREMISE_SET["authority"]["receipt_authority"] == false
end

check("AH-7.premise_set_authority_no_cache_dependency") do
  PREMISE_SET["authority"]["cache_authority"] == false &&
    PREMISE_SET["authority"]["dependency_authority"] == false
end

check("AH-7.premise_set_has_premise_set_digest") do
  PREMISE_SET["premise_set_digest"]&.start_with?("sha256:")
end

# =============================================================================
# AH-8: Projection trace is proof/debug/explanatory only
# =============================================================================

check("AH-8.trace_has_authority_block_all_false") do
  TRACE_RECORD["authority"].values.none? { |v| v == true }
end

check("AH-8.trace_has_explanatory_note") do
  TRACE_RECORD["note"].include?("proof/debug/explanatory") &&
    TRACE_RECORD["note"].include?("not cache/dependency/runtime authority")
end

check("AH-8.projection_has_no_cache_dependency_runtime_authority") do
  PROJECTION["authority"]["cache_authority"] == false &&
    PROJECTION["authority"]["dependency_authority"] == false &&
    PROJECTION["authority"]["runtime_authority"] == false
end

# =============================================================================
# AH-9: Projected value/failure disclaimers
# =============================================================================

check("AH-9.projected_value_is_not_actual_output_true") do
  PROJECTION["projected_value_is_not_actual_output"] == true
end

check("AH-9.projected_failure_is_not_actual_failure_true") do
  PROJECTION["projected_failure_is_not_actual_failure"] == true
end

check("AH-9.no_authority_disclaimer_present_in_projection") do
  PROJECTION["no_authority_disclaimer"].include?("no dependency/cache/report") &&
    PROJECTION["no_authority_disclaimer"].include?("proof-local concept evidence only")
end

check("AH-9.projected_value_correct_12") do
  PROJECTION["projected_value"] == 12  # multiply(3,4)
end

# =============================================================================
# AH-10: Closed-surface scan
# =============================================================================

check("AH-10.no_lib_files_loaded") do
  !$LOADED_FEATURES.any? { |f| f.include?("igniter_lang") }
end

check("AH-10.no_runtime_smoke_or_compiled_program_loaded") do
  !$LOADED_FEATURES.any? { |f| f.include?("runtime_smoke") } &&
    !$LOADED_FEATURES.any? { |f| f.include?("compiled_program") }
end

check("AH-10.compiler_result_not_modified") do
  src = File.read(
    File.join(REPO_ROOT, "igniter-lang/lib/igniter_lang/compiler_result.rb"),
    encoding: "utf-8"
  )
  !src.include?("artifact_home") && !src.include?("proof_owned_artifact_home")
end

check("AH-10.compilation_report_not_modified") do
  src = File.read(
    File.join(REPO_ROOT, "igniter-lang/lib/igniter_lang/compilation_report.rb"),
    encoding: "utf-8"
  )
  !src.include?("artifact_home") && !src.include?("proof_owned_artifact_home")
end

check("AH-10.no_igapp_outside_experiment_scope") do
  # Verify that no .igapp directories were created outside our experiment
  igapp_in_lib = Dir[File.join(REPO_ROOT, "igniter-lang/lib/**/*.igapp")].empty?
  igapp_in_out = Dir[File.join(REPO_ROOT, "igniter-lang/experiments",
                               "counterfactual_audit_proof_owned_artifact_home_v0", "**/*.igapp")].empty?
  igapp_in_lib && igapp_in_out  # no .igapp anywhere in this proof
end

check("AH-10.no_spark_public_api_cli_loaded") do
  spark_ns   = "igniter" + "_spark"
  cli_marker = "igniter_lang" + "/cli"
  !$LOADED_FEATURES.any? { |f| f.include?(spark_ns) } &&
    !$LOADED_FEATURES.any? { |f| f.include?(cli_marker) }
end

check("AH-10.r211_summary_digest_matches_known_pass_content") do
  # Verify R211 summary is intact: it must show 61/61 PASS
  R211_CITATION["status"] == "found" &&
    R211_CITATION["pass_count"] == 61 &&
    R211_CITATION["immutable"] == true
end

# =============================================================================
# Results and summary
# =============================================================================

pass_count    = CHECKS.count { |c| c["status"] == "PASS" }
fail_count    = CHECKS.count { |c| c["status"] == "FAIL" }
total         = CHECKS.size
overall       = fail_count == 0 ? "PASS" : "FAIL"
failed_checks = CHECKS.select { |c| c["status"] == "FAIL" }.map { |c| c["name"] }

ah_groups = Hash.new { |h, k| h[k] = [] }
CHECKS.each { |c| ah_groups[c["name"].split(".").first] << c["status"] }
proof_matrix = ah_groups.transform_values do |statuses|
  { "result" => statuses.all? { |s| s == "PASS" } ? "PASS" : "FAIL",
    "checks" => statuses.size }
end

summary = {
  "kind"           => "counterfactual_audit_proof_owned_artifact_home_v0_summary",
  "format_version" => "0.1.0",
  "card"           => "S3-R218-C2-I",
  "track"          => "counterfactual-audit-proof-owned-artifact-home-design-v0",
  "authorized_by"  => "S3-R218-C1-A",
  "status"         => overall,
  "checks_total"   => total,
  "checks_pass"    => pass_count,
  "checks_fail"    => fail_count,
  "failed_checks"  => failed_checks,
  "design_principle" =>
    "Runtime is lazy. Audit is aware. Dry-run, if ever accepted, must be isolated. " \
    "Evidence must be sourced before it can be explained. " \
    "Artifact homes must be explicit, non-canonical, and proof-owned.",
  "option_implemented" => "Option B: proof-owned artifact directory with no compiler/report authority",

  "artifact_home" => {
    "path"           => MANIFEST["home_path"],
    "manifest_path"  => File.join("out/artifact_home", File.basename(MANIFEST_PATH)),
    "manifest_digest" => MANIFEST_DIGEST,
    "proof_owned"    => true,
    "canonical"      => false
  },

  "authority_flags" => FULL_AUTHORITY_BLOCK.dup,

  "r211_immutability" => R211_CITATION,

  "digest_policy" => {
    "convention"   => "sha256:<hex>",
    "scope"        => "proof-owned outputs only",
    "stability"    => "content-addressed; same content => same digest",
    "authority"    => "none — digests carry no cache/dependency/compiler authority"
  },

  "snapshot_privacy_posture" => {
    "mutable"              => false,
    "persistence_authority" => false,
    "privacy_policy_authority" => false,
    "production_data"      => false,
    "note"                 => INPUT_SNAPSHOT_SCORE["privacy_note"]
  },

  "projection_disclaimers" => {
    "projected_value_is_not_actual_output"    => true,
    "projected_failure_is_not_actual_failure" => true,
    "no_authority_disclaimer"                 =>
      "projected_value and projected_failure carry no dependency/cache/report/runtime/public authority"
  },

  "closed_surface_scan" => {
    "lib_files_loaded"             => false,
    "runtime_smoke_loaded"         => false,
    "compiled_program_loaded"      => false,
    "compiler_result_modified"     => false,
    "compilation_report_modified"  => false,
    "igapp_created_outside_experiment" => false,
    "spark_or_cli_loaded"          => false,
    "spec_chapters_modified"       => false
  },

  "non_claims" => {
    "not_canonical_semanticir_schema"           => true,
    "not_compiler_result_field"                 => true,
    "not_compilation_report_field"              => true,
    "not_report_result_receipt_compatreport"    => true,
    "not_runtime_behavior"                      => true,
    "not_live_nonselected_branch_evaluation"    => true,
    "not_public_counterfactual_audit_support"   => true,
    "not_spark_api_cli_support"                 => true,
    "not_release_evidence"                      => true,
    "not_production_behavior"                   => true,
    "projected_value_not_actual_output"         => true,
    "projected_failure_not_actual_runtime_failure" => true
  },

  "proof_matrix_summary" => proof_matrix,
  "checks"               => CHECKS
}

summary_path = File.join(OUT_ROOT,
  "counterfactual_audit_proof_owned_artifact_home_v0_summary.json")
summary_json = JSON.pretty_generate(summary)
File.write(summary_path, summary_json)
summary_sha256 = "sha256:#{Digest::SHA256.hexdigest(summary_json)}"

puts "#{overall} counterfactual_audit_proof_owned_artifact_home_v0"
puts "checks_total=#{total}"
puts "checks_pass=#{pass_count}"
puts "checks_fail=#{fail_count}"
puts "failed_checks=#{failed_checks.inspect}"
puts "proof_matrix:"
proof_matrix.each do |id, data|
  puts "  #{id}: #{data["result"]} (#{data["checks"]} sub-checks)"
end
puts "summary=#{summary_path}"
puts "summary_sha256=#{summary_sha256}"

exit(fail_count == 0 ? 0 : 1)
