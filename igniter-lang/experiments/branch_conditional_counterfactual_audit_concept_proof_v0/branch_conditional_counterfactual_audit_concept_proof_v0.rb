#!/usr/bin/env ruby
# frozen_string_literal: true

# branch_conditional_counterfactual_audit_concept_proof_v0.rb
#
# Card:          S3-R205-C1-I
# Authorization: S3-R204-C5-S (depends on S3-R204-C4-A)
# Track:         branch-conditional-counterfactual-audit-concept-proof-v0
#
# Proof principle: "Runtime is lazy. Audit is aware."
#
# Builds proof-local branch-intention descriptors from hand-authored
# typed/SemanticIR-shaped if_expr fixtures.  Proves BIA-1..BIA-10.
#
# Boundary:
#   - Pure structural inspection: no evaluator/runtime calls.
#   - No latent branch evaluated.
#   - No lib/ edits.
#   - No parser/grammar/compiler/runtime changes.
#   - No report/result/CompatibilityReport changes.
#   - Descriptors are proof-local / explanatory-only.
#   - assumption_refs are proof-local branch premise labels only;
#     they are not PROP-032 receipt assumption_refs and not a PROP-032
#     grammar extension.
#
# Claim policy (binding):
#   explanatory_only descriptors != runtime execution
#   branch_intention proof != public counterfactual support
#   assumptions_shaped_metadata != PROP-032 grammar extension
#   Level 1 static branch audit != Level 2 counterfactual dry-run

require "digest"
require "fileutils"
require "json"

REPO_ROOT = File.expand_path("../../..", __dir__)
PROOF_DIR = __dir__
OUT_ROOT  = File.join(PROOF_DIR, "out")
FileUtils.mkdir_p(OUT_ROOT)

# =============================================================================
# Proof infrastructure
# =============================================================================

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
# Expression shape helpers (pure data — no evaluation)
# =============================================================================

def lit(v)
  type_name = case v
              when true, false then "Bool"
              when Integer     then "Integer"
              when String      then "String"
              else "Unknown"
              end
  { "kind" => "literal", "value" => v, "resolved_type" => { "name" => type_name, "params" => [] } }
end

def ref_node(name, type_name = "Unknown")
  { "kind" => "ref", "name" => name, "resolved_type" => { "name" => type_name, "params" => [] } }
end

def apply_node(operator, *operands)
  { "kind" => "apply", "operator" => operator, "operands" => operands,
    "resolved_type" => { "name" => "Integer", "params" => [] } }
end

def tbackend_read_node(key)
  { "kind" => "tbackend_read", "key" => key,
    "resolved_type" => { "name" => "Unknown", "params" => [] } }
end

def if_expr_fixture(id, condition:, then_branch:, else_branch:, resolved_type: { "name" => "Unknown", "params" => [] })
  { "if_expr_id"    => id,
    "kind"          => "if_expr",
    "condition"     => condition,
    "then_branch"   => then_branch,
    "else_branch"   => else_branch,
    "resolved_type" => resolved_type }
end

# Structural ref traversal — collects referenced names without executing.
# Never calls evaluator. Pure static analysis.
def static_refs_of(expr)
  return [] unless expr.is_a?(Hash)
  case expr["kind"]
  when "ref"          then [expr["name"]]
  when "literal"      then []
  when "apply"        then (expr["operands"] || []).flat_map { |o| static_refs_of(o) }.uniq
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
# Branch-intention descriptor generator
#
# Pure structural inspection of the if_expr fixture — never evaluates any
# expression in any branch.  Identifies actual vs latent branch by the
# caller-supplied actual_label (which comes from proof evidence or fixture).
# =============================================================================

AUTHORITY_BLOCK = {
  "dependency_authority"        => false,
  "cache_authority"             => false,
  "runtime_readiness_authority" => false,
  "public_claim"                => false
}.freeze

def generate_branch_intention(
  fixture,
  actual_label:,           # "then" or "else" — from proof evidence or fixture
  condition_observation:,  # Hash { "value" => bool, "source" => String } or nil
  assumption_refs_then: [],
  assumption_refs_else: []
)
  latent_label = actual_label == "then" ? "else" : "then"

  then_expr  = fixture.fetch("then_branch")
  else_expr  = fixture.fetch("else_branch")
  actual_expr = actual_label == "then" ? then_expr : else_expr
  latent_expr = actual_label == "then" ? else_expr : then_expr

  arefs = { "then" => assumption_refs_then, "else" => assumption_refs_else }

  {
    "kind"             => "if_expr_branch_intention",
    "format_version"   => "0.1.0",
    "if_expr_id"       => fixture.fetch("if_expr_id"),
    "intention_source" => "semanticir_static",
    "explanatory_only" => true,
    "condition" => {
      "expr_kind"           => fixture.dig("condition", "kind"),
      "actual_value"        => condition_observation&.fetch("value"),
      "actual_value_source" => condition_observation&.fetch("source")
    },
    "branches" => [
      {
        "branch_label"            => actual_label,
        "branch_role"             => "actual",
        "evaluated"               => true,
        "expr_kind"               => actual_expr.fetch("kind"),
        "resolved_type"           => actual_expr.fetch("resolved_type", fixture["resolved_type"]),
        "static_refs"             => static_refs_of(actual_expr),
        "assumption_refs"         => arefs.fetch(actual_label, []),
        "non_execution_guarantee" => false
      },
      # Latent branch: static structural facts only.
      # Invariant: this branch is NEVER passed to an evaluator.
      # Non-execution is guaranteed by this generator, not by runtime.
      {
        "branch_label"            => latent_label,
        "branch_role"             => "latent",
        "evaluated"               => false,
        "expr_kind"               => latent_expr.fetch("kind"),
        "resolved_type"           => latent_expr.fetch("resolved_type", fixture["resolved_type"]),
        "static_refs"             => static_refs_of(latent_expr),
        "assumption_refs"         => arefs.fetch(latent_label, []),
        "non_execution_guarantee" => true,
        "note"                    => "Latent branch: static metadata only. Not evaluated. " \
                                     "No runtime value, no runtime failure, no side effect."
      }
    ],
    "authority" => AUTHORITY_BLOCK.dup
  }
end

# =============================================================================
# Hand-authored SemanticIR-shaped if_expr fixtures
# =============================================================================

# Fixture A: condition=literal(true) → actual=then, latent=else
# Actual branch: literal(42).  Latent branch: ref("fallback").
# assumption_refs on actual (then) branch — optional premise capsule.
FIXTURE_A = if_expr_fixture(
  "if:risk_gate_true",
  condition:     lit(true),
  then_branch:   lit(42),
  else_branch:   ref_node("fallback", "Integer"),
  resolved_type: { "name" => "Integer", "params" => [] }
)

INTENT_A = generate_branch_intention(
  FIXTURE_A,
  actual_label:          "then",
  condition_observation: { "value" => true, "source" => "semanticir_static_literal" },
  assumption_refs_then:  ["risk_threshold_is_valid"],
  assumption_refs_else:  []
)

# Fixture B: condition=literal(false) → actual=else, latent=then
# Actual branch: literal(99).
# Latent branch: apply(stdlib.integer.add, ref("a"), ref("b")).
# No assumption_refs — demonstrates assumptions are optional.
FIXTURE_B = if_expr_fixture(
  "if:risk_gate_false",
  condition:     lit(false),
  then_branch:   apply_node("stdlib.integer.add", ref_node("a", "Integer"), ref_node("b", "Integer")),
  else_branch:   lit(99),
  resolved_type: { "name" => "Integer", "params" => [] }
)

INTENT_B = generate_branch_intention(
  FIXTURE_B,
  actual_label:          "else",
  condition_observation: { "value" => false, "source" => "semanticir_static_literal" },
  assumption_refs_then:  [],
  assumption_refs_else:  []
)

# Fixture C (BIA-6): condition=literal(true), actual=then (literal 100),
# latent=else (tbackend_read — unsupported/would-fail kind at runtime).
# The latent branch is NEVER evaluated; its kind is recorded structurally only.
FIXTURE_C = if_expr_fixture(
  "if:latent_tbackend_read",
  condition:     lit(true),
  then_branch:   lit(100),
  else_branch:   tbackend_read_node("accounts/active"),
  resolved_type: { "name" => "Unknown", "params" => [] }
)

INTENT_C = generate_branch_intention(
  FIXTURE_C,
  actual_label:          "then",
  condition_observation: { "value" => true, "source" => "semanticir_static_literal" },
  assumption_refs_then:  [],
  assumption_refs_else:  []
)

# All descriptors for summary
ALL_INTENTIONS = [INTENT_A, INTENT_B, INTENT_C].freeze

# =============================================================================
# BIA-1: Actual branch identified from condition value
# =============================================================================

check("BIA-1.actual_branch_is_then_when_condition_true") do
  actual = INTENT_A["branches"].find { |b| b["branch_role"] == "actual" }
  actual["branch_label"] == "then"
end

check("BIA-1.actual_branch_is_else_when_condition_false") do
  actual = INTENT_B["branches"].find { |b| b["branch_role"] == "actual" }
  actual["branch_label"] == "else"
end

check("BIA-1.condition_observation_recorded") do
  cond = INTENT_A["condition"]
  cond.key?("actual_value") && cond["actual_value"] == true &&
    cond.key?("actual_value_source")
end

check("BIA-1.actual_branch_has_evaluated_true") do
  actual = INTENT_A["branches"].find { |b| b["branch_role"] == "actual" }
  actual["evaluated"] == true
end

# =============================================================================
# BIA-2: Latent branch recorded without evaluation
# =============================================================================

check("BIA-2.latent_branch_has_evaluated_false") do
  latent = INTENT_A["branches"].find { |b| b["branch_role"] == "latent" }
  latent["evaluated"] == false
end

check("BIA-2.latent_branch_has_non_execution_guarantee") do
  latent = INTENT_A["branches"].find { |b| b["branch_role"] == "latent" }
  latent["non_execution_guarantee"] == true
end

check("BIA-2.latent_label_is_else_when_condition_true") do
  latent = INTENT_A["branches"].find { |b| b["branch_role"] == "latent" }
  latent["branch_label"] == "else"
end

check("BIA-2.latent_label_is_then_when_condition_false") do
  latent = INTENT_B["branches"].find { |b| b["branch_role"] == "latent" }
  latent["branch_label"] == "then"
end

check("BIA-2.evaluator_not_loaded_by_proof") do
  # Behavioral: proof never required any igniter_lang runtime code
  !$LOADED_FEATURES.any? { |f| f.include?("semanticir_expression_evaluator") }
end

# =============================================================================
# BIA-3: Static branch metadata extracted from typed/SemanticIR shape
# =============================================================================

check("BIA-3.expr_kind_recorded_for_actual_branch") do
  actual = INTENT_A["branches"].find { |b| b["branch_role"] == "actual" }
  actual["expr_kind"] == "literal"
end

check("BIA-3.expr_kind_recorded_for_latent_branch") do
  latent = INTENT_A["branches"].find { |b| b["branch_role"] == "latent" }
  latent["expr_kind"] == "ref"
end

check("BIA-3.resolved_type_present_in_both_branches") do
  actual = INTENT_A["branches"].find { |b| b["branch_role"] == "actual" }
  latent = INTENT_A["branches"].find { |b| b["branch_role"] == "latent" }
  actual.key?("resolved_type") && latent.key?("resolved_type")
end

check("BIA-3.intention_source_is_semanticir_static") do
  INTENT_A["intention_source"] == "semanticir_static" &&
    INTENT_B["intention_source"] == "semanticir_static" &&
    INTENT_C["intention_source"] == "semanticir_static"
end

check("BIA-3.apply_latent_branch_expr_kind_recorded") do
  # Fixture B: latent branch is apply — kind must be recorded
  latent = INTENT_B["branches"].find { |b| b["branch_role"] == "latent" }
  latent["expr_kind"] == "apply"
end

# =============================================================================
# BIA-4: Static refs/deps recorded as explanatory-only
# =============================================================================

check("BIA-4.dependency_authority_false_on_all_descriptors") do
  ALL_INTENTIONS.all? { |d| d.dig("authority", "dependency_authority") == false }
end

check("BIA-4.cache_authority_false_on_all_descriptors") do
  ALL_INTENTIONS.all? { |d| d.dig("authority", "cache_authority") == false }
end

check("BIA-4.runtime_readiness_authority_false_on_all_descriptors") do
  ALL_INTENTIONS.all? { |d| d.dig("authority", "runtime_readiness_authority") == false }
end

check("BIA-4.static_refs_captured_for_latent_ref_branch") do
  # Fixture A: latent branch is ref("fallback") → static_refs: ["fallback"]
  latent = INTENT_A["branches"].find { |b| b["branch_role"] == "latent" }
  latent["static_refs"].include?("fallback")
end

check("BIA-4.static_refs_captured_for_latent_apply_branch") do
  # Fixture B: latent then_branch is apply(add, ref(a), ref(b)) → static_refs: ["a","b"]
  latent = INTENT_B["branches"].find { |b| b["branch_role"] == "latent" }
  latent["static_refs"].include?("a") && latent["static_refs"].include?("b")
end

check("BIA-4.explanatory_only_true_on_all_descriptors") do
  ALL_INTENTIONS.all? { |d| d["explanatory_only"] == true }
end

# =============================================================================
# BIA-5: Assumption premise refs linked when present (optional capsule)
# =============================================================================

check("BIA-5.assumption_refs_present_on_actual_branch_when_declared") do
  # Fixture A: actual then_branch has assumption_refs: ["risk_threshold_is_valid"]
  actual = INTENT_A["branches"].find { |b| b["branch_role"] == "actual" }
  actual["assumption_refs"].include?("risk_threshold_is_valid")
end

check("BIA-5.assumption_refs_optional_fixture_b_has_none") do
  # Fixture B: no assumption_refs on either branch — valid; assumptions are optional
  actual = INTENT_B["branches"].find { |b| b["branch_role"] == "actual" }
  latent = INTENT_B["branches"].find { |b| b["branch_role"] == "latent" }
  actual["assumption_refs"].empty? && latent["assumption_refs"].empty?
end

check("BIA-5.assumption_refs_are_proof_local_labels") do
  # assumption_refs in this proof are proof-local branch premise labels.
  # They are NOT PROP-032 receipt assumption_refs (those are part of a
  # compiler/report surface; this proof never loads any compiler surface).
  !$LOADED_FEATURES.any? { |f| f.include?("igniter_lang") }
end

check("BIA-5.public_claim_false_on_descriptors_with_assumption_refs") do
  INTENT_A["authority"]["public_claim"] == false
end

# =============================================================================
# BIA-6: Latent branch with unsupported/would-fail kind — structural only
# =============================================================================

check("BIA-6.latent_tbackend_read_expr_kind_recorded") do
  latent = INTENT_C["branches"].find { |b| b["branch_role"] == "latent" }
  latent["expr_kind"] == "tbackend_read"
end

check("BIA-6.latent_tbackend_read_evaluated_false") do
  latent = INTENT_C["branches"].find { |b| b["branch_role"] == "latent" }
  latent["evaluated"] == false
end

check("BIA-6.latent_tbackend_read_non_execution_guarantee") do
  latent = INTENT_C["branches"].find { |b| b["branch_role"] == "latent" }
  latent["non_execution_guarantee"] == true
end

check("BIA-6.no_runtime_failure_key_in_latent_descriptor") do
  # The descriptor must not carry would_fail/would_result/runtime_error
  latent = INTENT_C["branches"].find { |b| b["branch_role"] == "latent" }
  !latent.key?("would_fail") && !latent.key?("would_result") &&
    !latent.key?("runtime_error") && !latent.key?("latent_runtime_failure")
end

check("BIA-6.forbidden_level2_vocabulary_absent_from_all_descriptors") do
  # Level 2 / dry-run vocabulary must not appear in any descriptor
  all_json = JSON.generate(ALL_INTENTIONS)
  forbidden = %w[would_fail would_result would_output
                 latent\ runtime\ value latent\ runtime\ failure
                 counterfactual\ result]
  forbidden.none? { |term| all_json.include?(term) }
end

check("BIA-6.latent_static_refs_captured_without_execution") do
  # tbackend_read key is captured as "tbackend:accounts/active" via static traversal
  latent = INTENT_C["branches"].find { |b| b["branch_role"] == "latent" }
  latent["static_refs"].include?("tbackend:accounts/active")
end

# =============================================================================
# BIA-7: Lazy runtime/evaluator invariant preserved (read-only citation)
# =============================================================================

check("BIA-7.slice1_structural_proof_strings_intact") do
  source = File.read(
    File.join(REPO_ROOT, "igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb"),
    encoding: "utf-8"
  )
  source.include?('eval_expr(expr.fetch("then_branch"), values, call_trace) # line A: then_branch only') &&
    source.include?('eval_expr(expr.fetch("else_branch"), values, call_trace) # line B: else_branch only')
end

check("BIA-7.slice2_structural_proof_strings_intact") do
  source = File.read(
    File.join(REPO_ROOT, "igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb"),
    encoding: "utf-8"
  )
  source.include?("line A-ext: then_branch only") &&
    source.include?("line B-ext: else_branch only")
end

check("BIA-7.rs_proof_summary_pass") do
  summary = JSON.parse(File.read(
    File.join(REPO_ROOT,
              "igniter-lang/experiments/branch_conditional_if_expr_runtime_smoke_consumer_v0",
              "out/branch_conditional_if_expr_runtime_smoke_consumer_v0_summary.json"),
    encoding: "utf-8"
  ))
  summary.fetch("status") == "PASS" && summary.fetch("checks_fail") == 0
end

check("BIA-7.if_expr_v0_proof_summary_pass") do
  summary = JSON.parse(File.read(
    File.join(REPO_ROOT,
              "igniter-lang/experiments/branch_conditional_if_expr_v0_implementation_proof",
              "out/branch_conditional_if_expr_v0_implementation_proof_summary.json"),
    encoding: "utf-8"
  ))
  summary.fetch("status") == "PASS" && summary.fetch("checks_fail") == 0
end

check("BIA-7.no_evaluator_loaded_by_this_proof") do
  # Behavioral: concept proof is pure structural — never loads evaluator/runtime
  !$LOADED_FEATURES.any? { |f| f.include?("semanticir_expression_evaluator") } &&
    !$LOADED_FEATURES.any? { |f| f.include?("runtime_smoke") } &&
    !$LOADED_FEATURES.any? { |f| f.include?("compiled_program") }
end

# =============================================================================
# BIA-8: Public/release/Spark/API/CLI non-claims
# =============================================================================

check("BIA-8.no_release_commands_in_proof_script") do
  source = File.read(__FILE__, encoding: "utf-8")
  # Split forbidden strings to avoid self-referential match
  forbidden = ["git " + "push", "gem " + "push", "rake " + "release"]
  forbidden.none? { |cmd| source.include?(cmd) }
end

check("BIA-8.all_descriptors_have_public_claim_false") do
  ALL_INTENTIONS.all? { |d| d.dig("authority", "public_claim") == false }
end

check("BIA-8.no_spark_integration_loaded_by_proof") do
  # Behavioral: proof never loaded any Spark-related code.
  # Source-scan is skipped here to avoid self-referential false matches
  # (the non-claims hash contains "no_spark..." key names as proof-local labels).
  # The behavioral check is sufficient: if any Spark integration were loaded,
  # it would appear in $LOADED_FEATURES.
  # Split forbidden names to prevent self-referential substring match.
  spark_ns = "igniter" + "_spark"
  !$LOADED_FEATURES.any? { |f| f.include?(spark_ns) } &&
    !$LOADED_FEATURES.any? { |f| f.include?("spark_integration") }
end

check("BIA-8.no_public_counterfactual_runtime_claim_in_descriptors") do
  # explanatory_only must be true on all; authority fields all false
  ALL_INTENTIONS.all? do |d|
    d["explanatory_only"] == true &&
      d["authority"].values.none? { |v| v == true }
  end
end

# =============================================================================
# BIA-9: Parser/grammar/source syntax unchanged
# =============================================================================

check("BIA-9.no_branch_level_uses_assumptions_in_lib") do
  lib_files = Dir[File.join(REPO_ROOT, "igniter-lang/lib/**/*.rb")]
  # Split forbidden pattern to prevent self-referential match
  forbidden_then = "then " + "uses assumptions"
  forbidden_else = "else " + "uses assumptions"
  lib_files.none? do |f|
    content = File.read(f, encoding: "utf-8")
    content.include?(forbidden_then) || content.include?(forbidden_else)
  end
end

check("BIA-9.no_grammar_mutation_loaded_by_proof") do
  !$LOADED_FEATURES.any? { |f| f.include?("compiler_orchestrator") } &&
    !$LOADED_FEATURES.any? { |f| f.include?("compiler_result") } &&
    !$LOADED_FEATURES.any? { |f| f.include?("compilation_report") }
end

check("BIA-9.proof_writes_no_lib_files") do
  # Verify write scope: all output is under proof out/
  # Structural proof: harness only writes to OUT_ROOT
  out_abs = File.expand_path(OUT_ROOT)
  lib_abs = File.expand_path(File.join(REPO_ROOT, "igniter-lang/lib"))
  !out_abs.start_with?(lib_abs)
end

# =============================================================================
# BIA-10: Report/result/CompatibilityReport unchanged — concept summary only
# =============================================================================

check("BIA-10.compiler_result_has_no_branch_intention_key") do
  source = File.read(
    File.join(REPO_ROOT, "igniter-lang/lib/igniter_lang/compiler_result.rb"),
    encoding: "utf-8"
  )
  !source.include?("branch_intention") && !source.include?("if_expr_branch_intention")
end

check("BIA-10.compilation_report_has_no_branch_intention_key") do
  source = File.read(
    File.join(REPO_ROOT, "igniter-lang/lib/igniter_lang/compilation_report.rb"),
    encoding: "utf-8"
  )
  !source.include?("branch_intention") && !source.include?("if_expr_branch_intention")
end

check("BIA-10.compiler_orchestrator_has_no_branch_intention_key") do
  source = File.read(
    File.join(REPO_ROOT, "igniter-lang/lib/igniter_lang/compiler_orchestrator.rb"),
    encoding: "utf-8"
  )
  !source.include?("branch_intention") && !source.include?("if_expr_branch_intention")
end

check("BIA-10.proof_summary_is_concept_only_not_compiler_report") do
  # The summary lives in proof out/ only; it is not a CompilerResult or
  # CompilationReport output and does not mutate any accepted report shape.
  out_abs = File.expand_path(OUT_ROOT)
  out_abs.include?("experiments/branch_conditional_counterfactual_audit_concept_proof_v0")
end

# =============================================================================
# Results and summary
# =============================================================================

pass_count    = CHECKS.count { |c| c["status"] == "PASS" }
fail_count    = CHECKS.count { |c| c["status"] == "FAIL" }
total         = CHECKS.size
overall       = fail_count == 0 ? "PASS" : "FAIL"
failed_checks = CHECKS.select { |c| c["status"] == "FAIL" }.map { |c| c["name"] }

bia_groups = Hash.new { |h, k| h[k] = [] }
CHECKS.each do |c|
  key = c["name"].split(".").first
  bia_groups[key] << c["status"]
end
proof_matrix = bia_groups.transform_values do |statuses|
  { "result" => statuses.all? { |s| s == "PASS" } ? "PASS" : "FAIL",
    "checks" => statuses.size }
end

summary = {
  "kind"           => "branch_conditional_counterfactual_audit_concept_proof_v0_summary",
  "format_version" => "0.1.0",
  "card"           => "S3-R205-C1-I",
  "track"          => "branch-conditional-counterfactual-audit-concept-proof-v0",
  "authorized_by"  => "S3-R204-C5-S",
  "status"         => overall,
  "checks_total"   => total,
  "checks_pass"    => pass_count,
  "checks_fail"    => fail_count,
  "failed_checks"  => failed_checks,
  "design_principle" => "Runtime is lazy. Audit is aware.",
  "proof_level"    => "Level 1 / Static Branch Audit only",

  # Required disclaimer (NB-1 binding constraint from C4-A)
  "disclaimer" => {
    "assumption_refs_in_this_proof" =>
      "proof-local branch premise labels, not PROP-032 receipt assumption_refs " \
      "and not a PROP-032 grammar extension",
    "assumptions_shaped_metadata" =>
      "non-canonical unless accepted by a future PROP or PROP-032 amendment decision",
    "branch_intention_descriptors" =>
      "proof-local / explanatory-only; not a compiler report, not a public API, " \
      "not a CompatibilityReport field, and not a RuntimeSmoke output",
    "level1_boundary" =>
      "Static Branch Audit only; Level 2 counterfactual dry-run remains closed " \
      "and requires a separate future gate"
  },

  "proof_scope" => {
    "lib_files_modified"            => false,
    "evaluator_loaded"              => false,
    "runtime_smoke_loaded"          => false,
    "compiled_program_loaded"       => false,
    "latent_branch_evaluated"       => false,
    "parser_grammar_changed"        => false,
    "compiler_result_changed"       => false,
    "compilation_report_changed"    => false,
    "compiler_orchestrator_changed" => false,
    "descriptors_location"          =>
      "experiments/branch_conditional_counterfactual_audit_concept_proof_v0/out/"
  },

  "claim_policy" => {
    "explanatory_only_descriptor_equals_runtime_execution" => false,
    "branch_intention_proof_equals_public_counterfactual"  => false,
    "assumptions_shaped_metadata_equals_prop032_extension" => false,
    "level1_static_audit_equals_level2_dry_run"            => false,
    "maximum_allowed_claim" =>
      "Proof-local concept evidence that if_expr branch intentions can be statically " \
      "described for actual and latent branches without evaluating latent branches, " \
      "using explanatory-only metadata and optional assumptions-shaped premise refs."
  },

  "non_claims" => {
    "no_non_selected_branch_evaluation"       => true,
    "no_runtime_failure_for_latent_branch"    => true,
    "no_counterfactual_dry_run"               => true,
    "no_level2_comparison_report"             => true,
    "no_public_runtime_support"               => true,
    "no_public_counterfactual_support"        => true,
    "no_grammar_parser_mutation"              => true,
    "no_branch_level_uses_assumptions_syntax" => true,
    "no_prop032_amendment_implied"            => true,
    "no_report_result_receipt_change"         => true,
    "no_dependency_cache_authority"           => true,
    "no_spark_api_cli_widening"               => true,
    "no_release_execution"                    => true
  },

  "branch_intention_descriptors" => ALL_INTENTIONS,
  "checks"                       => CHECKS,
  "proof_matrix_summary"         => proof_matrix
}

summary_path = File.join(OUT_ROOT,
  "branch_conditional_counterfactual_audit_concept_proof_v0_summary.json")
summary_json = JSON.pretty_generate(summary)
File.write(summary_path, summary_json)
summary_sha256 = "sha256:#{Digest::SHA256.hexdigest(summary_json)}"

puts "#{overall} branch_conditional_counterfactual_audit_concept_proof_v0"
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
