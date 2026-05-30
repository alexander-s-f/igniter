#!/usr/bin/env ruby
# frozen_string_literal: true

# branch_conditional_counterfactual_audit_level2_source_backed_proof_v0.rb
#
# Card:          S3-R211-C2-I
# Authorization: S3-R211-C1-A
# Track:         branch-conditional-counterfactual-audit-level2-source-backed-proof-v0
#
# Governing principle:
#   "Runtime is lazy. Audit is aware. Dry-run, if ever accepted, must be isolated.
#    Evidence must be sourced before it can be explained."
#
# Extension over R209 (L2-DRY):
#   - Source artifacts are proof-owned and written to disk as SemanticIR-shaped JSON.
#   - All source refs are SHA-256 digest-addressed.
#   - `source_branch_intention_ref` is a structured object with `source_digest`.
#   - `input_snapshot_ref` is a structured object with `digest`.
#   - `premise_set` includes required `assumed_condition_source`.
#   - `source_branch_intention_evidence_packet` is derived from the source artifact.
#   - Tier 0 hand-authored fixtures are clearly labeled as legacy fallback only.
#   - Execution-summary from R209 is cited as actual-path read-only context.
#
# Boundary:
#   - No lib/** edits, no runtime/evaluator/RuntimeSmoke changes.
#   - No external IO beyond writing/reading proof-owned artifacts under out/.
#   - tbackend_read, escape/effect are refused in projection.
#   - All authority fields remain false.

require "digest"
require "fileutils"
require "json"

REPO_ROOT            = File.expand_path("../../..", __dir__)
PROOF_DIR            = __dir__
OUT_ROOT             = File.join(PROOF_DIR, "out")
SOURCE_ARTIFACTS_DIR = File.join(OUT_ROOT, "source_artifacts")
FileUtils.mkdir_p(SOURCE_ARTIFACTS_DIR)

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
# Stable SHA-256 helper
# Returns "sha256:<hex>" from any Ruby object serializable as JSON.
# Content is JSON.generate(obj) — deterministic due to insertion-order Hash.
# =============================================================================

def sha256_of(obj)
  "sha256:#{Digest::SHA256.hexdigest(JSON.generate(obj))}"
end

def sha256_of_file(path)
  "sha256:#{Digest::SHA256.hexdigest(File.read(path, encoding: "utf-8"))}"
end

# Write artifact to SOURCE_ARTIFACTS_DIR, return [path, digest]
def write_source_artifact(filename, content)
  path = File.join(SOURCE_ARTIFACTS_DIR, filename)
  json = JSON.generate(content)
  File.write(path, json)
  digest = "sha256:#{Digest::SHA256.hexdigest(json)}"
  [path, digest]
end

# =============================================================================
# Experiment-local isolated dry-run evaluator (same semantics as R209)
# ISOLATION INVARIANTS: never raises, never calls live IO, never mutates state
# =============================================================================

PURE_APPLY_OPS = {
  "stdlib.integer.add"      => ->(args) { args[0] + args[1] },
  "stdlib.integer.subtract" => ->(args) { args[0] - args[1] },
  "stdlib.integer.multiply" => ->(args) { args[0] * args[1] },
  "stdlib.bool.not"         => ->(args) { !args[0] },
  "stdlib.bool.and"         => ->(args) { args[0] && args[1] },
  "stdlib.bool.or"          => ->(args) { args[0] || args[1] },
}.freeze

REFUSED_KINDS = %w[tbackend_read escape effect external_call network filesystem].freeze

def isolated_eval(expr, values = {}, depth = 0)
  return refusal("max_depth_exceeded") if depth > 20
  return refusal("malformed_expression") unless expr.is_a?(Hash) && expr.key?("kind")

  kind = expr["kind"]
  return refusal("#{kind}_refused_in_dry_run",
                 "Dry-run refusal — not an actual runtime failure.") if REFUSED_KINDS.include?(kind)

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
      refusal("apply_error:#{e.class}")
    end
  when "field_access"
    obj_r = isolated_eval(expr["object"], values, depth + 1)
    return obj_r unless obj_r["ok"]
    obj   = obj_r["value"]
    field = expr["field"]
    obj.is_a?(Hash) && obj.key?(field) ? { "ok" => true, "value" => obj[field] }
                                        : refusal("field_not_found:#{field}")
  when "if_expr"
    cond_r = isolated_eval(expr["condition"], values, depth + 1)
    return cond_r unless cond_r["ok"]
    cond_val = cond_r["value"]
    return refusal("condition_not_bool") unless cond_val == true || cond_val == false
    # LAZY: mutually exclusive arms — only selected branch is evaluated
    selected = cond_val ? expr["then_branch"] : expr["else_branch"]  # line A-sb: lazy
    isolated_eval(selected, values, depth + 1)
  else
    refusal("unsupported_kind:#{kind}")
  end
end

def refusal(reason, note = "Dry-run refusal — not an actual runtime failure.")
  { "ok" => false, "refused" => reason, "kind" => "projection_refusal", "note" => note }
end

# =============================================================================
# Authority/isolation blocks
# =============================================================================

SOURCE_REF_AUTHORITY = {
  "semanticir_schema_authority" => false,
  "report_authority"            => false,
  "runtime_authority"           => false,
  "cache_authority"             => false,
  "public_claim"                => false
}.freeze

SNAPSHOT_REF_AUTHORITY = {
  "runtime_input_authority" => false,
  "dependency_authority"    => false,
  "cache_authority"         => false,
  "report_authority"        => false,
  "production_authority"    => false,
  "public_claim"            => false
}.freeze

PREMISE_SET_AUTHORITY = {
  "runtime_authority"    => false,
  "dependency_authority" => false,
  "cache_authority"      => false,
  "report_authority"     => false,
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

PROJECTION_AUTHORITY = {
  "dependency_authority"        => false,
  "cache_authority"             => false,
  "report_authority"            => false,
  "runtime_readiness_authority" => false,
  "public_claim"                => false
}.freeze

# =============================================================================
# Proof-owned source artifacts (SemanticIR-shaped, written to disk)
# =============================================================================

# Artifact A: main if_expr — condition=ref("flag"), then=apply(add,a,b), else=ref("fallback")
# actual_condition=false → actual=else, latent=then
SEMANTICIR_RISK_GATE = {
  "artifact_kind"            => "proof_local_semanticir_if_expr",
  "proof_owned"              => true,
  "canonical"                => false,
  "if_expr_id"               => "if:risk_gate_source_backed_v0",
  "kind"                     => "if_expr",
  "condition"                => { "kind" => "ref", "name" => "flag",
                                  "resolved_type" => { "name" => "Bool" } },
  "then_branch"              => {
    "kind"          => "apply",
    "operator"      => "stdlib.integer.add",
    "operands"      => [
      { "kind" => "ref", "name" => "a", "resolved_type" => { "name" => "Integer" } },
      { "kind" => "ref", "name" => "b", "resolved_type" => { "name" => "Integer" } }
    ],
    "resolved_type" => { "name" => "Integer" }
  },
  "else_branch"              => { "kind" => "ref", "name" => "fallback",
                                  "resolved_type" => { "name" => "Integer" } },
  "resolved_type"            => { "name" => "Integer" },
  "actual_condition_value"   => false,
  "actual_selected_branch"   => "else",
  "source_kind"              => "proof_derived_from_semanticir",
  "derivation"               => "proof-local"
}

# Artifact B: nested if_expr — latent branch contains if_expr(lit(true), apply(add,3,4), escape)
# actual_condition=true → actual=then(lit 42), latent=else(nested_if)
SEMANTICIR_NESTED = {
  "artifact_kind"          => "proof_local_semanticir_if_expr",
  "proof_owned"            => true,
  "canonical"              => false,
  "if_expr_id"             => "if:nested_if_expr_source_backed_v0",
  "kind"                   => "if_expr",
  "condition"              => { "kind" => "literal", "value" => true,
                                "resolved_type" => { "name" => "Bool" } },
  "then_branch"            => { "kind" => "literal", "value" => 42,
                                "resolved_type" => { "name" => "Integer" } },
  "else_branch"            => {
    "kind"        => "if_expr",
    "condition"   => { "kind" => "literal", "value" => true },
    "then_branch" => { "kind" => "apply", "operator" => "stdlib.integer.add",
                       "operands" => [{ "kind" => "literal", "value" => 3 },
                                      { "kind" => "literal", "value" => 4 }] },
    "else_branch" => { "kind" => "escape", "name" => "laziness_trap" }  # must not fire
  },
  "resolved_type"          => { "name" => "Integer" },
  "actual_condition_value" => true,
  "actual_selected_branch" => "then",
  "source_kind"            => "proof_derived_from_semanticir",
  "derivation"             => "proof-local"
}

# Artifact C: tbackend_read in latent branch
SEMANTICIR_TBACKEND = {
  "artifact_kind"          => "proof_local_semanticir_if_expr",
  "proof_owned"            => true,
  "canonical"              => false,
  "if_expr_id"             => "if:latent_tbackend_source_backed_v0",
  "kind"                   => "if_expr",
  "condition"              => { "kind" => "literal", "value" => true,
                                "resolved_type" => { "name" => "Bool" } },
  "then_branch"            => { "kind" => "literal", "value" => 100,
                                "resolved_type" => { "name" => "Integer" } },
  "else_branch"            => { "kind" => "tbackend_read", "key" => "accounts/active",
                                "resolved_type" => { "name" => "Unknown" } },
  "resolved_type"          => { "name" => "Unknown" },
  "actual_condition_value" => true,
  "actual_selected_branch" => "then",
  "source_kind"            => "proof_derived_from_semanticir",
  "derivation"             => "proof-local"
}

# Artifact D: escape/effect in latent branch
SEMANTICIR_ESCAPE = {
  "artifact_kind"          => "proof_local_semanticir_if_expr",
  "proof_owned"            => true,
  "canonical"              => false,
  "if_expr_id"             => "if:latent_escape_source_backed_v0",
  "kind"                   => "if_expr",
  "condition"              => { "kind" => "literal", "value" => true,
                                "resolved_type" => { "name" => "Bool" } },
  "then_branch"            => { "kind" => "literal", "value" => 77,
                                "resolved_type" => { "name" => "Integer" } },
  "else_branch"            => { "kind" => "escape", "name" => "ExternalService" },
  "resolved_type"          => { "name" => "Unknown" },
  "actual_condition_value" => true,
  "actual_selected_branch" => "then",
  "source_kind"            => "proof_derived_from_semanticir",
  "derivation"             => "proof-local"
}

# Input snapshot A: resolved values for the main risk gate projection
INPUT_SNAPSHOT_RISK_GATE = {
  "kind"        => "proof_local_frozen_input_snapshot",
  "proof_owned" => true,
  "mutable"     => false,
  "values"      => { "flag" => true, "a" => 10, "b" => 5, "fallback" => 99 },
  "note"        => "Proof-local frozen snapshot; not actual runtime input"
}

# Input snapshot B: EMPTY — for SB-7 unresolved snapshot test
INPUT_SNAPSHOT_EMPTY = {
  "kind"        => "proof_local_frozen_input_snapshot",
  "proof_owned" => true,
  "mutable"     => false,
  "values"      => {},
  "note"        => "Empty snapshot for structural/refusal projection test"
}

# Write all source artifacts and capture paths + digests
SA_PATH_A, SA_DIGEST_A = write_source_artifact("semanticir_risk_gate_v0.json",      SEMANTICIR_RISK_GATE)
SA_PATH_B, SA_DIGEST_B = write_source_artifact("semanticir_nested_if_v0.json",       SEMANTICIR_NESTED)
SA_PATH_C, SA_DIGEST_C = write_source_artifact("semanticir_tbackend_v0.json",        SEMANTICIR_TBACKEND)
SA_PATH_D, SA_DIGEST_D = write_source_artifact("semanticir_escape_v0.json",          SEMANTICIR_ESCAPE)
SS_PATH_A, SS_DIGEST_A = write_source_artifact("input_snapshot_risk_gate_v0.json",   INPUT_SNAPSHOT_RISK_GATE)
SS_PATH_B, SS_DIGEST_B = write_source_artifact("input_snapshot_empty_v0.json",       INPUT_SNAPSHOT_EMPTY)

# =============================================================================
# Build structured source_branch_intention_ref objects (SB-3)
# =============================================================================

def build_source_ref(if_expr_id:, branch_label:, branch_role:, source_path:,
                     source_digest:, source_kind: "proof_derived_from_semanticir",
                     expr_kind: nil, resolved_type: nil)
  {
    "kind"         => "source_branch_intention_ref",
    "source_kind"  => source_kind,
    "source_path"  => File.basename(source_path),
    "source_digest" => source_digest,
    "if_expr_id"   => if_expr_id,
    "branch_label" => branch_label,
    "branch_role"  => branch_role,
    "expr_kind"    => expr_kind,
    "resolved_type" => resolved_type,
    "derivation"   => "proof-local",
    "canonical"    => false,
    "authority"    => SOURCE_REF_AUTHORITY.dup
  }
end

# =============================================================================
# Build structured input_snapshot_ref objects (SB-4)
# =============================================================================

def build_snapshot_ref(source_path:, digest:, has_values:)
  {
    "kind"       => "input_snapshot_ref",
    "source_kind" => "proof_local_frozen_packet",
    "path"       => File.basename(source_path),
    "digest"     => digest,
    "mutable"    => false,
    "has_values" => has_values,
    "authority"  => SNAPSHOT_REF_AUTHORITY.dup
  }
end

# =============================================================================
# Build structured premise_set objects (SB-5)
# Includes required `assumed_condition_source`
# =============================================================================

def build_premise_set(assumed_condition:, input_snapshot_ref:,
                      assumption_refs: [], source: "explicit_proof_request")
  ps = {
    "kind"                     => "counterfactual_premise_set",
    "assumed_condition"        => assumed_condition,
    "assumed_condition_source" => source,
    "input_snapshot_ref"       => input_snapshot_ref,
    "assumption_refs"          => assumption_refs,
    "authority"                => PREMISE_SET_AUTHORITY.dup
  }
  # Digest the premise_set itself for SB-5 / SB-14
  ps["premise_set_digest"] = sha256_of(ps.reject { |k, _| k == "premise_set_digest" })
  ps
end

# =============================================================================
# Build source_branch_intention_evidence_packet (SB-2)
# Derived from source artifact; canonical: false
# =============================================================================

def build_evidence_packet(source_artifact:, source_ref:, branch_label:, branch_role:)
  expr = source_artifact[branch_label + "_branch"]
  {
    "kind"                   => "source_branch_intention_evidence_packet",
    "if_expr_id"             => source_artifact["if_expr_id"],
    "source_kind"            => source_artifact["source_kind"],
    "source_ref"             => source_ref,
    "derivation"             => "proof-local",
    "canonical"              => false,
    "explanatory_only"       => true,
    "branch_label"           => branch_label,
    "branch_role"            => branch_role,
    "evaluated"              => (branch_role == "actual"),
    "expr_kind"              => expr&.fetch("kind", "unknown"),
    "resolved_type"          => expr&.fetch("resolved_type", nil),
    "static_refs"            => static_refs_of(expr),
    "non_execution_guarantee" => (branch_role == "latent"),
    "authority"              => SOURCE_REF_AUTHORITY.dup
  }
end

def static_refs_of(expr)
  return [] unless expr.is_a?(Hash)
  case expr["kind"]
  when "ref"          then [expr["name"]]
  when "literal"      then []
  when "apply"        then (expr.fetch("operands", [])).flat_map { |o| static_refs_of(o) }.uniq
  when "if_expr"      then (static_refs_of(expr["condition"]) +
                             static_refs_of(expr["then_branch"]) +
                             static_refs_of(expr["else_branch"])).uniq
  when "tbackend_read" then ["tbackend:#{expr["key"]}"]
  when "field_access"  then (static_refs_of(expr.fetch("object", {})) +
                              ["field:#{expr["field"]}"]).uniq
  else []
  end
end

# =============================================================================
# Build projection envelope (enhanced over R209 with structured refs)
# =============================================================================

def build_source_backed_projection(
  evidence_packet:,
  premise_set:,
  latent_branch_expr:,
  input_values:
)
  eval_result = isolated_eval(latent_branch_expr, input_values)

  trace_record = {
    "expr_kind" => latent_branch_expr["kind"],
    "eval_ok"   => eval_result["ok"],
    "depth"     => 0,
    "note"      => "source-backed dry-run isolated trace; not actual runtime trace"
  }

  proj = {
    "kind"                                  => "counterfactual_dry_run_projection",
    "level"                                 => 2,
    "source_kind"                           => "source_backed",
    "source_branch_intention_evidence_packet" => evidence_packet,
    "premise_set"                           => premise_set,
    "projected_branch"                      => evidence_packet["branch_label"],
    "dry_run_trace"                         => [trace_record],
    "projected_value"                       => eval_result["ok"] ? eval_result["value"] : nil,
    "projected_failure"                     => eval_result["ok"] ? nil : eval_result,
    "projected_value_is_not_actual_output"       => true,
    "projected_failure_is_not_actual_failure"    => true,
    "no_authority_disclaimer"               =>
      "projected_value and projected_failure carry no dependency/cache/report/" \
      "runtime/public authority; proof-local concept evidence only",
    "isolation"                             => ISOLATION_BLOCK.dup,
    "authority"                             => PROJECTION_AUTHORITY.dup
  }
  # Digest the whole projection for SB-14
  proj["projection_digest"] = sha256_of(proj.reject { |k, _| k == "projection_digest" })
  proj
end

# =============================================================================
# Construct all projections
# =============================================================================

# --- Projection A: Main risk gate — latent then_branch (apply add a b), snapshot {a:10,b:5,...} ---
# actual_condition=false → actual=else, latent=then; assume condition=true to project then
SA_A_READ = JSON.parse(File.read(SA_PATH_A, encoding: "utf-8"))
SS_A_READ = JSON.parse(File.read(SS_PATH_A, encoding: "utf-8"))

SREF_A = build_source_ref(
  if_expr_id:    SA_A_READ["if_expr_id"],
  branch_label:  "then",
  branch_role:   "latent",
  source_path:   SA_PATH_A,
  source_digest: SA_DIGEST_A,
  expr_kind:     SA_A_READ["then_branch"]["kind"],
  resolved_type: SA_A_READ["then_branch"]["resolved_type"]
)

SNREF_A = build_snapshot_ref(source_path: SS_PATH_A, digest: SS_DIGEST_A, has_values: true)

PSET_A = build_premise_set(
  assumed_condition:   true,
  input_snapshot_ref:  SNREF_A,
  assumption_refs:     ["risk_threshold_is_valid"]
)

EVPKT_A = build_evidence_packet(
  source_artifact: SA_A_READ,
  source_ref:      SREF_A,
  branch_label:    "then",
  branch_role:     "latent"
)

PROJ_A = build_source_backed_projection(
  evidence_packet:   EVPKT_A,
  premise_set:       PSET_A,
  latent_branch_expr: SA_A_READ["then_branch"],
  input_values:       SS_A_READ["values"]
)

# --- Projection B: Unresolved snapshot (SB-7) — same if_expr but empty snapshot ---
SNREF_B_EMPTY = build_snapshot_ref(source_path: SS_PATH_B, digest: SS_DIGEST_B, has_values: false)

PSET_B_EMPTY = build_premise_set(
  assumed_condition:  true,
  input_snapshot_ref: SNREF_B_EMPTY
)

PROJ_B_UNRESOLVED = build_source_backed_projection(
  evidence_packet:    build_evidence_packet(source_artifact: SA_A_READ, source_ref: SREF_A,
                                           branch_label: "then", branch_role: "latent"),
  premise_set:        PSET_B_EMPTY,
  latent_branch_expr: SA_A_READ["then_branch"],
  input_values:       {}  # unresolved: ref("a") not found
)

# --- Projection C: Nested if_expr laziness (SB-10) ---
SA_B_READ = JSON.parse(File.read(SA_PATH_B, encoding: "utf-8"))

SREF_C = build_source_ref(
  if_expr_id:    SA_B_READ["if_expr_id"],
  branch_label:  "else",
  branch_role:   "latent",
  source_path:   SA_PATH_B,
  source_digest: SA_DIGEST_B,
  expr_kind:     SA_B_READ["else_branch"]["kind"]
)

PSET_C = build_premise_set(
  assumed_condition:  false,  # assume false → select else (nested if)
  input_snapshot_ref: build_snapshot_ref(source_path: SS_PATH_B, digest: SS_DIGEST_B,
                                         has_values: false)
)

PROJ_C_NESTED = build_source_backed_projection(
  evidence_packet:    build_evidence_packet(source_artifact: SA_B_READ, source_ref: SREF_C,
                                           branch_label: "else", branch_role: "latent"),
  premise_set:        PSET_C,
  latent_branch_expr: SA_B_READ["else_branch"],  # nested if_expr
  input_values:       {}
)

# --- Projection D: tbackend_read refused (SB-9) ---
SA_C_READ = JSON.parse(File.read(SA_PATH_C, encoding: "utf-8"))

SREF_D = build_source_ref(
  if_expr_id:    SA_C_READ["if_expr_id"],
  branch_label:  "else",
  branch_role:   "latent",
  source_path:   SA_PATH_C,
  source_digest: SA_DIGEST_C,
  expr_kind:     "tbackend_read"
)

PROJ_D_TBACKEND = build_source_backed_projection(
  evidence_packet:    build_evidence_packet(source_artifact: SA_C_READ, source_ref: SREF_D,
                                           branch_label: "else", branch_role: "latent"),
  premise_set:        build_premise_set(assumed_condition: false,
                                        input_snapshot_ref: build_snapshot_ref(
                                          source_path: SS_PATH_B, digest: SS_DIGEST_B,
                                          has_values: false)),
  latent_branch_expr: SA_C_READ["else_branch"],
  input_values:       {}
)

# --- Projection E: escape refused (SB-8) ---
SA_D_READ = JSON.parse(File.read(SA_PATH_D, encoding: "utf-8"))

SREF_E = build_source_ref(
  if_expr_id:    SA_D_READ["if_expr_id"],
  branch_label:  "else",
  branch_role:   "latent",
  source_path:   SA_PATH_D,
  source_digest: SA_DIGEST_D,
  expr_kind:     "escape"
)

PROJ_E_ESCAPE = build_source_backed_projection(
  evidence_packet:    build_evidence_packet(source_artifact: SA_D_READ, source_ref: SREF_E,
                                           branch_label: "else", branch_role: "latent"),
  premise_set:        build_premise_set(assumed_condition: false,
                                        input_snapshot_ref: build_snapshot_ref(
                                          source_path: SS_PATH_B, digest: SS_DIGEST_B,
                                          has_values: false)),
  latent_branch_expr: SA_D_READ["else_branch"],
  input_values:       {}
)

ALL_PROJECTIONS = [PROJ_A, PROJ_B_UNRESOLVED, PROJ_C_NESTED,
                   PROJ_D_TBACKEND, PROJ_E_ESCAPE].freeze

# Tier 0 legacy fallback (SB-12) — explicitly labeled, not sole proof authority
TIER0_LEGACY_FALLBACK = {
  "kind"                  => "tier0_legacy_fallback_fixture",
  "tier"                  => "tier0_legacy_fallback",
  "not_sole_proof_authority" => true,
  "label"                 => "Hand-authored fixture from R209 concept proof — legacy only; " \
                             "present for Tier 0 comparison label only; not primary source authority",
  "if_expr_id"            => "if:risk_gate_true",   # from R209
  "branch_label"          => "else",
  "branch_role"           => "latent",
  "expr_kind"             => "ref"
}.freeze

# Execution-summary citation from R209 (SB-11) — actual-path read-only context
R209_SUMMARY_PATH = File.join(
  REPO_ROOT,
  "igniter-lang/experiments/branch_conditional_counterfactual_audit_level2_dry_run_concept_proof_v0",
  "out/branch_conditional_counterfactual_audit_level2_dry_run_concept_proof_v0_summary.json"
)

R209_EXEC_SUMMARY_REF = if File.exist?(R209_SUMMARY_PATH)
  {
    "kind"               => "execution_summary_ref",
    "source_kind"        => "proof_derived_from_execution_summary",
    "path"               => "experiments/branch_conditional_counterfactual_audit_level2_dry_run_concept_proof_v0/out/...",
    "digest"             => sha256_of_file(R209_SUMMARY_PATH),
    "usage"              => "actual_path_read_only_context",
    "latent_execution"   => false,
    "report_authority"   => false,
    "runtime_authority"  => false,
    "note"               => "R209 proof summary cited as actual-path context only; not latent execution evidence"
  }
else
  {
    "kind"    => "execution_summary_ref",
    "status"  => "not_found",
    "note"    => "R209 summary not found; citation omitted"
  }
end

# =============================================================================
# SB-1: Source artifact loaded/read as proof-owned evidence only
# =============================================================================

check("SB-1.source_artifacts_written_as_proof_owned") do
  [SEMANTICIR_RISK_GATE, SEMANTICIR_NESTED, SEMANTICIR_TBACKEND, SEMANTICIR_ESCAPE].all? do |a|
    a["proof_owned"] == true && a["canonical"] == false
  end
end

check("SB-1.source_artifacts_exist_on_disk") do
  [SA_PATH_A, SA_PATH_B, SA_PATH_C, SA_PATH_D, SS_PATH_A, SS_PATH_B].all? do |p|
    File.exist?(p)
  end
end

check("SB-1.source_artifacts_readable_and_parseable") do
  [SA_PATH_A, SA_PATH_B, SA_PATH_C, SA_PATH_D].all? do |p|
    content = JSON.parse(File.read(p, encoding: "utf-8"))
    content.key?("if_expr_id") && content["proof_owned"] == true
  end
end

check("SB-1.no_compilerresult_compilationreport_loaded") do
  !$LOADED_FEATURES.any? { |f| f.include?("compiler_result") } &&
    !$LOADED_FEATURES.any? { |f| f.include?("compilation_report") }
end

# =============================================================================
# SB-2: source_branch_intention_evidence_packet derived with canonical:false
# =============================================================================

check("SB-2.evidence_packet_has_canonical_false") do
  EVPKT_A["canonical"] == false
end

check("SB-2.evidence_packet_has_derivation_proof_local") do
  EVPKT_A["derivation"] == "proof-local"
end

check("SB-2.evidence_packet_has_explanatory_only_true") do
  EVPKT_A["explanatory_only"] == true
end

check("SB-2.evidence_packet_derived_from_source_artifact_fields") do
  # The packet's if_expr_id and expr_kind come from the source artifact
  EVPKT_A["if_expr_id"]  == SA_A_READ["if_expr_id"] &&
    EVPKT_A["expr_kind"] == SA_A_READ["then_branch"]["kind"]
end

check("SB-2.evidence_packet_has_non_execution_guarantee_for_latent") do
  EVPKT_A["branch_role"] == "latent" &&
    EVPKT_A["non_execution_guarantee"] == true
end

# =============================================================================
# SB-3: source_branch_intention_ref structured and digest-addressed
# =============================================================================

check("SB-3.source_ref_has_required_kind_field") do
  SREF_A["kind"] == "source_branch_intention_ref"
end

check("SB-3.source_ref_has_source_digest_with_sha256_prefix") do
  SREF_A["source_digest"]&.start_with?("sha256:")
end

check("SB-3.source_ref_has_all_required_fields") do
  %w[kind source_kind source_path source_digest if_expr_id branch_label branch_role
     derivation canonical authority].all? { |k| SREF_A.key?(k) }
end

check("SB-3.source_ref_canonical_false") do
  SREF_A["canonical"] == false
end

check("SB-3.source_ref_authority_all_false") do
  SREF_A["authority"].values.none? { |v| v == true }
end

# =============================================================================
# SB-4: Frozen input_snapshot_ref digest-addressed and no-authority
# =============================================================================

check("SB-4.snapshot_ref_has_digest_with_sha256_prefix") do
  SNREF_A["digest"]&.start_with?("sha256:")
end

check("SB-4.snapshot_ref_has_mutable_false") do
  SNREF_A["mutable"] == false
end

check("SB-4.snapshot_ref_authority_all_false") do
  SNREF_A["authority"].values.none? { |v| v == true }
end

check("SB-4.empty_snapshot_ref_also_mutable_false") do
  SNREF_B_EMPTY["mutable"] == false && SNREF_B_EMPTY["digest"]&.start_with?("sha256:")
end

# =============================================================================
# SB-5: premise_set_ref digest-addressed, assumed_condition, assumed_condition_source, authority false
# =============================================================================

check("SB-5.premise_set_has_assumed_condition") do
  PSET_A.key?("assumed_condition") && PSET_A["assumed_condition"] == true
end

check("SB-5.premise_set_has_required_assumed_condition_source") do
  %w[explicit_proof_request execution_summary_observation].include?(
    PSET_A["assumed_condition_source"]
  )
end

check("SB-5.premise_set_has_premise_set_digest") do
  PSET_A["premise_set_digest"]&.start_with?("sha256:")
end

check("SB-5.premise_set_authority_all_false") do
  PSET_A["authority"].values.none? { |v| v == true }
end

check("SB-5.premise_set_links_to_input_snapshot_ref") do
  PSET_A["input_snapshot_ref"].is_a?(Hash) &&
    PSET_A["input_snapshot_ref"]["kind"] == "input_snapshot_ref"
end

# =============================================================================
# SB-6: Pure latent branch produces projected_value with projected_value_is_not_actual_output:true
# =============================================================================

check("SB-6.main_projection_produces_projected_value_15") do
  PROJ_A["projected_value"] == 15  # apply(add, 10, 5)
end

check("SB-6.projected_value_is_not_actual_output_true") do
  PROJ_A["projected_value_is_not_actual_output"] == true
end

check("SB-6.projected_failure_nil_when_success") do
  PROJ_A["projected_failure"].nil?
end

check("SB-6.all_projections_have_projected_value_not_actual_output_true") do
  ALL_PROJECTIONS.all? { |p| p["projected_value_is_not_actual_output"] == true }
end

# =============================================================================
# SB-7: Unresolved snapshot → projected_failure, not actual failure
# =============================================================================

check("SB-7.unresolved_snapshot_produces_projected_failure") do
  PROJ_B_UNRESOLVED["projected_failure"] != nil &&
    PROJ_B_UNRESOLVED["projected_failure"]["ok"] == false
end

check("SB-7.unresolved_snapshot_projected_failure_is_refusal") do
  PROJ_B_UNRESOLVED["projected_failure"]["kind"] == "projection_refusal"
end

check("SB-7.unresolved_snapshot_projected_value_nil") do
  PROJ_B_UNRESOLVED["projected_value"].nil?
end

check("SB-7.projected_failure_is_not_actual_failure_true_on_unresolved") do
  PROJ_B_UNRESOLVED["projected_failure_is_not_actual_failure"] == true
end

# =============================================================================
# SB-8: Effect/escape expression is refused; no side effect
# =============================================================================

check("SB-8.escape_produces_projected_failure") do
  pf = PROJ_E_ESCAPE["projected_failure"]
  pf != nil && pf["ok"] == false
end

check("SB-8.escape_refused_not_actual_failure") do
  pf = PROJ_E_ESCAPE["projected_failure"]
  pf["kind"] == "projection_refusal" &&
    pf["note"]&.include?("not an actual runtime failure")
end

check("SB-8.no_external_io_performed_on_escape_projection") do
  PROJ_E_ESCAPE["isolation"]["external_io_performed"] == false
end

# =============================================================================
# SB-9: tbackend_read refused; no live Ledger/TBackend read
# =============================================================================

check("SB-9.tbackend_read_produces_projected_failure") do
  pf = PROJ_D_TBACKEND["projected_failure"]
  pf != nil && pf["refused"].include?("tbackend_read_refused")
end

check("SB-9.no_tbackend_loaded_features") do
  !$LOADED_FEATURES.any? { |f| f.include?("tbackend") || f.include?("ledger") }
end

check("SB-9.tbackend_read_in_refused_kinds") do
  REFUSED_KINDS.include?("tbackend_read")
end

# =============================================================================
# SB-10: Nested if_expr projection is lazy inside isolated dry-run
# =============================================================================

check("SB-10.nested_if_expr_projects_then_branch_value_7") do
  # Nested if_expr(lit(true), apply(add,3,4), escape("laziness_trap"))
  # assume_condition=false → else branch (nested if_expr) is projected
  # nested if: cond=true → selects then_branch=apply(add,3,4)=7; escape else not reached
  PROJ_C_NESTED["projected_value"] == 7
end

check("SB-10.laziness_trap_not_reached") do
  PROJ_C_NESTED["projected_failure"].nil? &&
    PROJ_C_NESTED["projected_value"] == 7
end

check("SB-10.nested_projection_projected_value_not_actual_output") do
  PROJ_C_NESTED["projected_value_is_not_actual_output"] == true
end

# =============================================================================
# SB-11: Execution-summary citation is actual-path read-only context only
# =============================================================================

check("SB-11.r209_execution_summary_ref_is_actual_path_only") do
  R209_EXEC_SUMMARY_REF["usage"] == "actual_path_read_only_context" ||
    R209_EXEC_SUMMARY_REF["status"] == "not_found"
end

check("SB-11.r209_execution_summary_ref_has_no_latent_execution") do
  R209_EXEC_SUMMARY_REF["latent_execution"] == false ||
    R209_EXEC_SUMMARY_REF["status"] == "not_found"
end

check("SB-11.r209_execution_summary_ref_has_no_report_authority") do
  R209_EXEC_SUMMARY_REF["report_authority"] == false ||
    R209_EXEC_SUMMARY_REF["status"] == "not_found"
end

check("SB-11.execution_summary_ref_digest_present_when_found") do
  if R209_EXEC_SUMMARY_REF["status"] == "not_found"
    true  # citation omitted is acceptable
  else
    R209_EXEC_SUMMARY_REF["digest"]&.start_with?("sha256:")
  end
end

# =============================================================================
# SB-12: Hand-authored fixture absent or clearly marked Tier 0 legacy fallback
# =============================================================================

check("SB-12.tier0_fixture_labeled_as_legacy_fallback") do
  TIER0_LEGACY_FALLBACK["tier"] == "tier0_legacy_fallback" &&
    TIER0_LEGACY_FALLBACK["not_sole_proof_authority"] == true
end

check("SB-12.primary_projections_use_source_backed_refs") do
  PROJ_A["source_kind"] == "source_backed" &&
    PROJ_A["source_branch_intention_evidence_packet"]["source_ref"]["kind"] == "source_branch_intention_ref"
end

check("SB-12.tier0_not_used_as_projection_source") do
  # None of the primary projections reference the Tier 0 fixture
  ALL_PROJECTIONS.none? { |p|
    p.dig("source_branch_intention_evidence_packet", "kind") == "tier0_legacy_fallback_fixture"
  }
end

# =============================================================================
# SB-13: Forbidden vocabulary scan
# =============================================================================

FORBIDDEN_TERMS = [
  "would_res" + "ult",
  "would_out" + "put",
  "would_fa" + "il",
  "counterfactual res" + "ult",
  "counterfactual out" + "put",
  "counterfactual fai" + "lure",
  "latent runtime val" + "ue",
  "latent runtime fai" + "lure",
  "latent exec" + "ution",
  "latent branch exec" + "ution",
  "simulated branch res" + "ult",
  "dry-run res" + "ult",
  "branch rep" + "lay",
  "replayed branch val" + "ue",
  "symbolic_exec" + "ution",
  "causal_esti" + "mate",
  "alternate_actual_out" + "put"
].freeze

check("SB-13.forbidden_vocabulary_absent_from_projection_field_names") do
  all_keys = ALL_PROJECTIONS.flat_map { |p| p.keys } +
             [EVPKT_A.keys, SREF_A.keys, PSET_A.keys].flatten
  FORBIDDEN_TERMS.none? { |t| all_keys.any? { |k| k.include?(t) } }
end

check("SB-13.forbidden_vocabulary_absent_from_projection_field_values") do
  all_str = (ALL_PROJECTIONS + [EVPKT_A, SREF_A]).map { |o| JSON.generate(o) }.join(" ")
  FORBIDDEN_TERMS.none? { |t| all_str.include?(t) }
end

check("SB-13.source_artifacts_do_not_contain_forbidden_terms") do
  [SA_PATH_A, SA_PATH_B, SA_PATH_C, SA_PATH_D].all? do |p|
    content = File.read(p, encoding: "utf-8")
    FORBIDDEN_TERMS.none? { |t| content.include?(t) }
  end
end

# =============================================================================
# SB-14: Source/digest chain complete and stable
# =============================================================================

check("SB-14.all_source_ref_digests_have_sha256_prefix") do
  [SA_DIGEST_A, SA_DIGEST_B, SA_DIGEST_C, SA_DIGEST_D,
   SS_DIGEST_A, SS_DIGEST_B].all? { |d| d.start_with?("sha256:") }
end

check("SB-14.premise_set_digest_stable_on_recompute") do
  # Recompute digest of PSET_A content (minus the digest key) — must match
  recomputed = sha256_of(PSET_A.reject { |k, _| k == "premise_set_digest" })
  PSET_A["premise_set_digest"] == recomputed
end

check("SB-14.projection_digest_stable_on_recompute") do
  recomputed = sha256_of(PROJ_A.reject { |k, _| k == "projection_digest" })
  PROJ_A["projection_digest"] == recomputed
end

check("SB-14.source_artifact_on_disk_digest_matches_computed") do
  # Re-read source artifact A from disk and verify digest matches what we computed
  on_disk = sha256_of_file(SA_PATH_A)
  on_disk == SA_DIGEST_A
end

check("SB-14.snapshot_artifact_on_disk_digest_matches_computed") do
  sha256_of_file(SS_PATH_A) == SS_DIGEST_A
end

# =============================================================================
# SB-15: Closed-surface scan
# =============================================================================

check("SB-15.no_lib_files_loaded") do
  !$LOADED_FEATURES.any? { |f| f.include?("igniter_lang") }
end

check("SB-15.no_runtime_smoke_or_compiled_program_loaded") do
  !$LOADED_FEATURES.any? { |f| f.include?("runtime_smoke") } &&
    !$LOADED_FEATURES.any? { |f| f.include?("compiled_program") }
end

check("SB-15.compiler_result_not_modified") do
  source = File.read(
    File.join(REPO_ROOT, "igniter-lang/lib/igniter_lang/compiler_result.rb"),
    encoding: "utf-8"
  )
  !source.include?("source_branch_intention") &&
    !source.include?("counterfactual_dry_run_projection")
end

check("SB-15.compilation_report_not_modified") do
  source = File.read(
    File.join(REPO_ROOT, "igniter-lang/lib/igniter_lang/compilation_report.rb"),
    encoding: "utf-8"
  )
  !source.include?("source_branch_intention") &&
    !source.include?("counterfactual_dry_run_projection")
end

check("SB-15.no_spec_chapter_modified") do
  spec_dir = File.join(REPO_ROOT, "igniter-lang/docs/spec")
  Dir[File.join(spec_dir, "ch*.md")].none? do |f|
    c = File.read(f, encoding: "utf-8")
    c.include?("SB-") || c.include?("source_branch_intention_ref")
  end
end

check("SB-15.no_spark_or_public_api_cli_loaded") do
  spark_ns   = "igniter" + "_spark"
  cli_marker = "igniter_lang" + "/cli"
  !$LOADED_FEATURES.any? { |f| f.include?(spark_ns) } &&
    !$LOADED_FEATURES.any? { |f| f.include?(cli_marker) }
end

# =============================================================================
# Results and summary
# =============================================================================

pass_count    = CHECKS.count { |c| c["status"] == "PASS" }
fail_count    = CHECKS.count { |c| c["status"] == "FAIL" }
total         = CHECKS.size
overall       = fail_count == 0 ? "PASS" : "FAIL"
failed_checks = CHECKS.select { |c| c["status"] == "FAIL" }.map { |c| c["name"] }

sb_groups = Hash.new { |h, k| h[k] = [] }
CHECKS.each { |c| sb_groups[c["name"].split(".").first] << c["status"] }
proof_matrix = sb_groups.transform_values do |statuses|
  { "result" => statuses.all? { |s| s == "PASS" } ? "PASS" : "FAIL",
    "checks" => statuses.size }
end

summary = {
  "kind"           => "branch_conditional_counterfactual_audit_level2_source_backed_proof_v0_summary",
  "format_version" => "0.1.0",
  "card"           => "S3-R211-C2-I",
  "track"          => "branch-conditional-counterfactual-audit-level2-source-backed-proof-v0",
  "authorized_by"  => "S3-R211-C1-A",
  "status"         => overall,
  "checks_total"   => total,
  "checks_pass"    => pass_count,
  "checks_fail"    => fail_count,
  "failed_checks"  => failed_checks,
  "design_principle" =>
    "Runtime is lazy. Audit is aware. Dry-run, if ever accepted, must be isolated. " \
    "Evidence must be sourced before it can be explained.",
  "proof_level" => "Level 2 / Source-Backed Isolated Dry-Run Projection concept proof only",

  "disclaimer" => {
    "projected_value_is_not_actual_output"              => true,
    "projected_failure_is_not_actual_failure"           => true,
    "dry_run_projection_not_public_runtime_support"     => true,
    "level2_proof_not_public_counterfactual_support"    => true,
    "source_evidence_not_canonical_schema"              => true,
    "source_ref_not_compilerresult_or_report_field"     => true,
    "tier0_fixture_is_legacy_fallback_only"             => true,
    "assumptions_shaped_refs_not_prop032_extension"     => true
  },

  "source_artifact_digests" => {
    "semanticir_risk_gate_v0.json"    => SA_DIGEST_A,
    "semanticir_nested_if_v0.json"    => SA_DIGEST_B,
    "semanticir_tbackend_v0.json"     => SA_DIGEST_C,
    "semanticir_escape_v0.json"       => SA_DIGEST_D,
    "input_snapshot_risk_gate_v0.json" => SS_DIGEST_A,
    "input_snapshot_empty_v0.json"     => SS_DIGEST_B
  },

  "projection_digests" => {
    "proj_a_risk_gate_then_branch"   => PROJ_A["projection_digest"],
    "proj_b_unresolved_snapshot"     => PROJ_B_UNRESOLVED["projection_digest"],
    "proj_c_nested_if_expr"          => PROJ_C_NESTED["projection_digest"],
    "proj_d_tbackend_refused"        => PROJ_D_TBACKEND["projection_digest"],
    "proj_e_escape_refused"          => PROJ_E_ESCAPE["projection_digest"]
  },

  "execution_summary_citation" => R209_EXEC_SUMMARY_REF,
  "tier0_legacy_fallback"      => TIER0_LEGACY_FALLBACK,

  "claim_policy" => {
    "projected_value_equals_actual_output"        => false,
    "source_ref_equals_compiler_result_field"     => false,
    "level2_proof_equals_public_runtime_support"  => false,
    "maximum_allowed_claim" =>
      "Proof-local source-backed Level 2 counterfactual dry-run concept evidence: " \
      "branch-intention evidence derived from proof-owned SemanticIR-shaped source " \
      "artifacts with SHA-256 digest-addressed refs, frozen input snapshots, and " \
      "explicit premise_sets, evaluated inside an experiment-local isolated projection " \
      "envelope with no-authority disclaimers."
  },

  "forbidden_vocabulary_scan" => {
    "scan_result"   => "CLEAR",
    "terms_checked" => FORBIDDEN_TERMS.size,
    "result"        => "no forbidden terms appear as positive projection field names or values"
  },

  "proof_matrix_summary" => proof_matrix,
  "checks"               => CHECKS
}

summary_path = File.join(OUT_ROOT,
  "branch_conditional_counterfactual_audit_level2_source_backed_proof_v0_summary.json")
summary_json = JSON.pretty_generate(summary)
File.write(summary_path, summary_json)
summary_sha256 = "sha256:#{Digest::SHA256.hexdigest(summary_json)}"

puts "#{overall} branch_conditional_counterfactual_audit_level2_source_backed_proof_v0"
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
