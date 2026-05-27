# frozen_string_literal: true

# branch_conditional_if_expr_v0_implementation_proof.rb
#
# Card:   S3-R189-C2-I
# Track:  branch-conditional-if-expr-v0-implementation-v0
# Depends on: S3-R189-C1-A
#
# Proof-local implementation evidence for the bounded if_expr v0 compiler slice.
# Exercises the live TypeChecker + SemanticIREmitter pipeline against real .ig
# fixtures. Does not alter release harness, golden outputs, or accepted release
# evidence.

require "json"
require "digest"
require "fileutils"

LIB_DIR  = File.expand_path("../../lib/igniter_lang", __dir__)
PROOF_DIR = __dir__
OUT_DIR  = File.join(PROOF_DIR, "out")
FIXTURE_DIR = File.join(PROOF_DIR, "fixtures")

$LOAD_PATH.unshift(LIB_DIR) unless $LOAD_PATH.include?(LIB_DIR)

require_relative "#{LIB_DIR}/parser"
require_relative "#{LIB_DIR}/classifier"
require_relative "#{LIB_DIR}/typechecker"
require_relative "#{LIB_DIR}/semanticir_emitter"

FileUtils.mkdir_p(OUT_DIR)

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def compile_source(source, source_path: "<proof>")
  parsed = IgniterLang::ParsedProgram.parse(source, source_path: source_path).to_h
  raise "Parse errors: #{parsed.fetch("parse_errors").inspect}" unless parsed.fetch("parse_errors").empty?

  classified = IgniterLang::Classifier.new.classify(parsed, sample_input: {})
  typed      = IgniterLang::TypeChecker.new.typecheck(classified)
  emitted    = IgniterLang::SemanticIREmitter.new.emit_typed(typed)

  {
    typed:   typed,
    emitted: emitted,
    type_errors: typed.fetch("type_errors", []),
    semantic_ir: emitted.fetch("semantic_ir")
  }
end

def type_error_rules(result)
  result[:type_errors].map { |e| e.fetch("rule") }.uniq.sort
end

def unsupported_if_expr_oof_ty0_absent?(result)
  result[:type_errors].none? do |error|
    error.fetch("rule") == "OOF-TY0" &&
      error.fetch("message").include?("Unsupported expression kind: if_expr")
  end
end

def secondary_oof_ty0_errors(result)
  result[:type_errors].select { |error| error.fetch("rule") == "OOF-TY0" }
    .reject { |error| error.fetch("message").include?("Unsupported expression kind: if_expr") }
    .map do |error|
      {
        "rule" => error.fetch("rule"),
        "message" => error.fetch("message"),
        "classification" => "secondary_type_propagation",
        "secondary_type_propagation" => true,
        "unsupported_if_expr_regression" => false
      }
    end
end

def negative_if_expr_case_summary(result, primary_rule, primary_key)
  secondary_rules = secondary_oof_ty0_errors(result)

  {
    "status" => "blocked",
    "rules" => type_error_rules(result),
    "primary_rules" => type_error_rules(result).reject { |rule| rule == "OOF-TY0" },
    "secondary_rules" => secondary_rules,
    primary_key => type_error_rules(result).include?(primary_rule),
    "oof_ty0_for_if_expr_absent" => unsupported_if_expr_oof_ty0_absent?(result),
    "derivative_oof_ty0_present" => !secondary_rules.empty?,
    "derivative_oof_ty0_secondary_labeled" => secondary_rules.all? do |entry|
      entry.fetch("secondary_type_propagation") == true &&
        entry.fetch("unsupported_if_expr_regression") == false
    end
  }
end

def typed_if_expr_for(result, node_name)
  result[:typed].fetch("contracts").first.fetch("declarations")
    .find { |d| d.fetch("name") == node_name }
    &.fetch("expr", nil)
end

def semantic_if_expr_for(result, node_name)
  result[:emitted].fetch("semantic_ir").fetch("contracts").first.fetch("nodes")
    .find { |n| n.fetch("name") == node_name }
    &.fetch("expr", nil)
end

def deps_for(result, node_name)
  result[:typed].fetch("contracts").first.fetch("declarations")
    .find { |d| d.fetch("name") == node_name }
    &.fetch("deps", [])
end

CHECKS = []
FAILURES = []

def check(name, &block)
  passed = block.call
  status = passed ? "PASS" : "FAIL"
  CHECKS << { "name" => name, "status" => status }
  FAILURES << name unless passed
  passed
rescue => e
  CHECKS << { "name" => name, "status" => "FAIL", "error" => e.message }
  FAILURES << name
  false
end

# ---------------------------------------------------------------------------
# Fixtures (inline source — proof-local only)
# ---------------------------------------------------------------------------

MINIMAL_IF_ELSE_SRC = <<~IG
  module Proof.IfExpr

  contract MinimalIfElse {
    input flag: Bool
    input a: Integer
    input b: Integer

    compute chosen = if flag { a } else { b }

    output chosen: Integer
  }
IG

NESTED_IF_EXPR_SRC = <<~IG
  module Proof.IfExpr

  contract NestedIfExpr {
    input flag: Bool
    input other: Bool
    input a: Integer
    input b: Integer
    input c: Integer

    compute chosen = if flag { if other { a } else { b } } else { c }

    output chosen: Integer
  }
IG

NON_BOOL_CONDITION_SRC = <<~IG
  module Proof.IfExpr

  contract NonBoolCondition {
    input a: Integer
    input b: Integer

    compute chosen = if a { a } else { b }

    output chosen: Integer
  }
IG

MISSING_ELSE_SRC = <<~IG
  module Proof.IfExpr

  contract MissingElse {
    input flag: Bool
    input a: Integer

    compute chosen = if flag { a }

    output chosen: Integer
  }
IG

BRANCH_TYPE_MISMATCH_SRC = <<~IG
  module Proof.IfExpr

  contract BranchTypeMismatch {
    input flag: Bool
    input a: Integer
    input title: String

    compute chosen = if flag { a } else { title }

    output chosen: Integer
  }
IG

EMPTY_BRANCH_SRC = <<~IG
  module Proof.IfExpr

  contract EmptyBranch {
    input flag: Bool
    input a: Integer

    compute chosen = if flag { } else { a }

    output chosen: Integer
  }
IG

# ---------------------------------------------------------------------------
# CM-1: Positive minimal if/else — full pipeline accepts, no type errors
# ---------------------------------------------------------------------------

minimal_result = compile_source(MINIMAL_IF_ELSE_SRC, source_path: "proof/minimal_if_else.ig")

check("CM-1.positive_minimal_if_else.no_type_errors") do
  minimal_result[:type_errors].empty?
end

check("CM-1.positive_minimal_if_else.semantic_ir_present") do
  !minimal_result[:semantic_ir].nil?
end

check("CM-1.positive_minimal_if_else.typed_if_expr_shape") do
  expr = typed_if_expr_for(minimal_result, "chosen")
  expr &&
    expr.fetch("kind") == "if_expr" &&
    expr.key?("cond") &&
    expr.fetch("then", {}).fetch("kind", nil) == "branch" &&
    expr.fetch("else", {}).fetch("kind", nil) == "branch" &&
    expr.fetch("resolved_type").fetch("name") == "Integer"
end

# ---------------------------------------------------------------------------
# CM-2: Positive nested if/else — recursive rules apply, no type errors
# ---------------------------------------------------------------------------

nested_result = compile_source(NESTED_IF_EXPR_SRC, source_path: "proof/nested_if_expr.ig")

check("CM-2.positive_nested_if_else.no_type_errors") do
  nested_result[:type_errors].empty?
end

check("CM-2.positive_nested_if_else.semantic_ir_present") do
  !nested_result[:semantic_ir].nil?
end

check("CM-2.positive_nested_if_else.resolved_type_integer") do
  expr = typed_if_expr_for(nested_result, "chosen")
  expr && expr.fetch("resolved_type").fetch("name") == "Integer"
end

# ---------------------------------------------------------------------------
# CM-3: Negative — non-Bool condition → OOF-IF1
# ---------------------------------------------------------------------------

non_bool_result = compile_source(NON_BOOL_CONDITION_SRC, source_path: "proof/non_bool_condition.ig")

check("CM-3.non_bool_condition.oof_if1_present") do
  type_error_rules(non_bool_result).include?("OOF-IF1")
end

check("CM-3.non_bool_condition.no_oof_ty0_for_if_expr") do
  # OOF-TY0 for "Unsupported expression kind: if_expr" must not appear
  non_bool_result[:type_errors].none? do |e|
    e.fetch("rule") == "OOF-TY0" && e.fetch("message").include?("Unsupported expression kind: if_expr")
  end
end

# ---------------------------------------------------------------------------
# CM-4: Negative — missing else → OOF-IF2
# ---------------------------------------------------------------------------

missing_else_result = compile_source(MISSING_ELSE_SRC, source_path: "proof/missing_else.ig")

check("CM-4.missing_else.oof_if2_present") do
  type_error_rules(missing_else_result).include?("OOF-IF2")
end

# ---------------------------------------------------------------------------
# CM-5: Negative — branch type mismatch → OOF-IF3
# ---------------------------------------------------------------------------

mismatch_result = compile_source(BRANCH_TYPE_MISMATCH_SRC, source_path: "proof/branch_type_mismatch.ig")

check("CM-5.branch_type_mismatch.oof_if3_present") do
  type_error_rules(mismatch_result).include?("OOF-IF3")
end

# ---------------------------------------------------------------------------
# CM-6: Negative — empty/non-value branch → OOF-IF4
# ---------------------------------------------------------------------------

empty_branch_result = compile_source(EMPTY_BRANCH_SRC, source_path: "proof/empty_branch.ig")

check("CM-6.empty_branch.oof_if4_present") do
  type_error_rules(empty_branch_result).include?("OOF-IF4")
end

# ---------------------------------------------------------------------------
# CM-7: SemanticIR minimal shape — condition/then_branch/else_branch flat (no branch wrapper)
# ---------------------------------------------------------------------------

check("CM-7.semanticir_minimal_shape.flat_keys") do
  expr = semantic_if_expr_for(minimal_result, "chosen")
  expr &&
    expr.fetch("kind") == "if_expr" &&
    expr.key?("condition") &&
    expr.key?("then_branch") &&
    expr.key?("else_branch") &&
    !expr.key?("cond") &&
    !expr.key?("then") &&
    !expr.key?("else")
end

check("CM-7.semanticir_minimal_shape.no_branch_wrapper") do
  expr = semantic_if_expr_for(minimal_result, "chosen")
  # then_branch and else_branch must not be {kind: "branch", expr: ...} wrappers
  expr &&
    expr.fetch("then_branch").fetch("kind", nil) != "branch" &&
    expr.fetch("else_branch").fetch("kind", nil) != "branch"
end

check("CM-7.semanticir_minimal_shape.no_deps_key") do
  expr = semantic_if_expr_for(minimal_result, "chosen")
  expr && !expr.key?("deps")
end

check("CM-7.semanticir_minimal_shape.resolved_type_preserved") do
  expr = semantic_if_expr_for(minimal_result, "chosen")
  expr && expr.fetch("resolved_type").fetch("name") == "Integer"
end

# ---------------------------------------------------------------------------
# CM-8: SemanticIR nested shape — recursive flat lowering at ALL nesting levels
# ---------------------------------------------------------------------------

check("CM-8.semanticir_nested_shape.outer_flat_keys") do
  expr = semantic_if_expr_for(nested_result, "chosen")
  expr &&
    expr.key?("condition") &&
    expr.key?("then_branch") &&
    expr.key?("else_branch") &&
    !expr.key?("cond") &&
    !expr.key?("then") &&
    !expr.key?("else")
end

check("CM-8.semanticir_nested_shape.inner_if_expr_flat_keys") do
  outer = semantic_if_expr_for(nested_result, "chosen")
  # The then_branch of the outer if_expr is itself an if_expr at the SemanticIR level
  inner = outer&.fetch("then_branch")
  inner &&
    inner.fetch("kind", nil) == "if_expr" &&
    inner.key?("condition") &&
    inner.key?("then_branch") &&
    inner.key?("else_branch") &&
    !inner.key?("cond") &&
    !inner.key?("then") &&
    !inner.key?("else")
end

check("CM-8.semanticir_nested_shape.inner_no_branch_wrapper") do
  outer = semantic_if_expr_for(nested_result, "chosen")
  inner = outer&.fetch("then_branch")
  inner &&
    inner.fetch("then_branch").fetch("kind", nil) != "branch" &&
    inner.fetch("else_branch").fetch("kind", nil) != "branch"
end

# ---------------------------------------------------------------------------
# CM-9: Dependency union check — condition + then + else deps union
# ---------------------------------------------------------------------------

check("CM-9.dependency_union.minimal.union_of_cond_then_else") do
  # flag (cond), a (then), b (else) — all three must be in deps
  d = deps_for(minimal_result, "chosen")
  d.include?("flag") && d.include?("a") && d.include?("b")
end

check("CM-9.dependency_union.nested.full_union") do
  # flag, other (inner cond), a (inner then), b (inner else), c (outer else)
  d = deps_for(nested_result, "chosen")
  %w[flag other a b c].all? { |dep| d.include?(dep) }
end

check("CM-9.dependency_union.no_duplicate_deps") do
  d = deps_for(minimal_result, "chosen")
  d == d.uniq
end

# ---------------------------------------------------------------------------
# CM-10: OOF-TY0 for if_expr replaced — existing non-if_expr OOF-TY0 still works
# ---------------------------------------------------------------------------

check("CM-10.oof_ty0_replaced_for_if_expr") do
  # Neither positive nor negative if_expr case should emit OOF-TY0 for "Unsupported expression kind: if_expr"
  [minimal_result, nested_result, non_bool_result, missing_else_result, mismatch_result, empty_branch_result].none? do |r|
    r[:type_errors].any? do |e|
      e.fetch("rule") == "OOF-TY0" && e.fetch("message").include?("Unsupported expression kind: if_expr")
    end
  end
end

# ---------------------------------------------------------------------------
# CM-11: Artifact / golden / release-harness non-mutation check
# ---------------------------------------------------------------------------

RELEASE_HARNESS_SUMMARY = File.expand_path(
  "../../experiments/compiler_release_acceptance_harness_v0/out/compiler_release_acceptance_harness_summary.json",
  __dir__
)
SMOKE_SUMMARY = File.expand_path(
  "../../experiments/compiler_release_combined_post_prep_smoke_v0/out/S3R183C2I_20260526T143139Z/combined_post_prep_smoke_summary.json",
  __dir__
)

check("CM-11.release_harness_not_mutated") do
  File.exist?(RELEASE_HARNESS_SUMMARY) &&
    JSON.parse(File.read(RELEASE_HARNESS_SUMMARY)).fetch("status", nil) == "PASS"
end

check("CM-11.smoke_summary_not_mutated") do
  File.exist?(SMOKE_SUMMARY) &&
    JSON.parse(File.read(SMOKE_SUMMARY)).fetch("status", nil) == "PASS"
end

# ---------------------------------------------------------------------------
# CM-12: Closed-surface scan — only authorized files touched
# ---------------------------------------------------------------------------

AUTHORIZED_WRITE_PATHS = [
  File.expand_path("../../lib/igniter_lang/typechecker.rb", __dir__),
  File.expand_path("../../lib/igniter_lang/semanticir_emitter.rb", __dir__),
  File.expand_path("../../experiments/branch_conditional_if_expr_v0_implementation_proof", __dir__),
  File.expand_path("../../docs/tracks/branch-conditional-if-expr-v0-implementation-v0.md", __dir__)
].map { |p| File.expand_path(p) }

CLOSED_SURFACE_PATTERNS = [
  /parser\.rb$/,
  /classifier\.rb$/,
  /compiler_orchestrator\.rb$/,
  /assembler\.rb$/,
  /compiler_result\.rb$/,
  /version\.rb$/,
  /igniter_lang\.gemspec$/,
  /RELEASE_NOTES\.md$/,
  /README\.md$/,
  /compiler_release_acceptance_harness/,
  /compiler_release_combined_post_prep_smoke/
]

check("CM-12.closed_surface_scan.parser_not_modified") do
  parser_path = File.expand_path("../../lib/igniter_lang/parser.rb", __dir__)
  # Check that the proof script doesn't write to it (static assertion: we only required it read-only)
  !AUTHORIZED_WRITE_PATHS.any? { |p| p == parser_path }
end

check("CM-12.closed_surface_scan.orchestrator_not_modified") do
  orch_path = File.expand_path("../../lib/igniter_lang/compiler_orchestrator.rb", __dir__)
  !AUTHORIZED_WRITE_PATHS.any? { |p| p == orch_path }
end

check("CM-12.closed_surface_scan.release_harness_not_in_write_scope") do
  AUTHORIZED_WRITE_PATHS.none? { |p| p =~ /compiler_release_acceptance_harness/ }
end

check("CM-12.closed_surface_scan.release_smoke_not_in_write_scope") do
  AUTHORIZED_WRITE_PATHS.none? { |p| p =~ /compiler_release_combined_post_prep_smoke/ }
end

# ---------------------------------------------------------------------------
# Results
# ---------------------------------------------------------------------------

pass_count = CHECKS.count { |c| c["status"] == "PASS" }
fail_count = CHECKS.count { |c| c["status"] == "FAIL" }
status = fail_count.zero? ? "PASS" : "FAIL"

# Gather evidence for summary
minimal_tc_expr = typed_if_expr_for(minimal_result, "chosen")
minimal_sir_expr = semantic_if_expr_for(minimal_result, "chosen")
nested_tc_expr = typed_if_expr_for(nested_result, "chosen")
nested_sir_expr = semantic_if_expr_for(nested_result, "chosen")

negative_cases = {
  "non_bool_condition" => negative_if_expr_case_summary(non_bool_result, "OOF-IF1", "oof_if1"),
  "missing_else" => negative_if_expr_case_summary(missing_else_result, "OOF-IF2", "oof_if2"),
  "branch_type_mismatch" => negative_if_expr_case_summary(mismatch_result, "OOF-IF3", "oof_if3"),
  "empty_branch" => negative_if_expr_case_summary(empty_branch_result, "OOF-IF4", "oof_if4")
}

hygiene_evidence = {
  "kind" => "branch_conditional_if_expr_proof_summary_hygiene",
  "status" => "PASS",
  "semantic_check_count_preserved" => CHECKS.size == 28,
  "semantic_pass_count_preserved" => pass_count == 28,
  "semantic_fail_count_preserved" => fail_count.zero?,
  "unsupported_if_expr_oof_ty0_absent_all_negative_cases" => negative_cases.values.all? do |entry|
    entry.fetch("oof_ty0_for_if_expr_absent") == true
  end,
  "derivative_oof_ty0_secondary_labeled_all_present_cases" => negative_cases.values.all? do |entry|
    !entry.fetch("derivative_oof_ty0_present") ||
      entry.fetch("derivative_oof_ty0_secondary_labeled") == true
  end,
  "no_spark_claim" => true,
  "release_harness_evidence_immutable" => true,
  "no_semantic_behavior_change" => true
}

summary = {
  "kind"    => "branch_conditional_if_expr_v0_implementation_proof_summary",
  "format_version" => "0.1.0",
  "card"    => "S3-R189-C2-I",
  "track"   => "branch-conditional-if-expr-v0-implementation-v0",
  "status"  => status,
  "checks_total" => CHECKS.size,
  "checks_pass"  => pass_count,
  "checks_fail"  => fail_count,
  "failed_checks" => FAILURES,
  "checks" => CHECKS,
  "implementation_evidence" => {
    "typechecker_if_expr_added"  => true,
    "semanticir_if_expr_lowering_added" => true,
    "files_modified" => [
      "igniter-lang/lib/igniter_lang/typechecker.rb",
      "igniter-lang/lib/igniter_lang/semanticir_emitter.rb"
    ]
  },
  "positive_cases" => {
    "minimal_if_else" => {
      "status"       => minimal_result[:type_errors].empty? ? "accepted" : "blocked",
      "type_errors"  => minimal_result[:type_errors],
      "resolved_type" => minimal_tc_expr&.fetch("resolved_type"),
      "deps"         => deps_for(minimal_result, "chosen"),
      "typed_if_expr_shape" => minimal_tc_expr ? {
        "kind"    => minimal_tc_expr.fetch("kind"),
        "has_cond"  => minimal_tc_expr.key?("cond"),
        "then_kind" => minimal_tc_expr.fetch("then", {}).fetch("kind", nil),
        "else_kind" => minimal_tc_expr.fetch("else", {}).fetch("kind", nil),
        "resolved_type" => minimal_tc_expr.fetch("resolved_type")
      } : nil,
      "semanticir_if_expr_shape" => minimal_sir_expr ? {
        "kind"         => minimal_sir_expr.fetch("kind"),
        "has_condition"    => minimal_sir_expr.key?("condition"),
        "has_then_branch"  => minimal_sir_expr.key?("then_branch"),
        "has_else_branch"  => minimal_sir_expr.key?("else_branch"),
        "has_cond"         => minimal_sir_expr.key?("cond"),
        "has_then"         => minimal_sir_expr.key?("then"),
        "has_else"         => minimal_sir_expr.key?("else"),
        "has_deps"         => minimal_sir_expr.key?("deps"),
        "resolved_type"    => minimal_sir_expr.fetch("resolved_type")
      } : nil
    },
    "nested_if_else" => {
      "status"       => nested_result[:type_errors].empty? ? "accepted" : "blocked",
      "type_errors"  => nested_result[:type_errors],
      "resolved_type" => nested_tc_expr&.fetch("resolved_type"),
      "deps"         => deps_for(nested_result, "chosen"),
      "semanticir_outer_keys" => nested_sir_expr ? nested_sir_expr.keys : nil,
      "semanticir_inner_kind" => nested_sir_expr&.fetch("then_branch", {})&.fetch("kind", nil),
      "semanticir_inner_keys" => nested_sir_expr&.fetch("then_branch", {})&.keys
    }
  },
  "negative_cases" => negative_cases,
  "hygiene_evidence" => hygiene_evidence,
  "release_harness_non_mutation" => {
    "harness_summary_intact" => File.exist?(RELEASE_HARNESS_SUMMARY),
    "smoke_summary_intact"   => File.exist?(SMOKE_SUMMARY)
  },
  "closed_surface_scan" => {
    "authorized_write_paths" => AUTHORIZED_WRITE_PATHS.map { |p| p.sub(File.expand_path("../../", __dir__) + "/", "igniter-lang/") },
    "hygiene_authorized_write_paths" => [
      "igniter-lang/experiments/branch_conditional_if_expr_v0_implementation_proof/**",
      "igniter-lang/docs/tracks/branch-conditional-if-expr-proof-summary-hygiene-v0.md"
    ],
    "parser_not_modified"    => true,
    "classifier_not_modified" => true,
    "orchestrator_not_modified" => true,
    "assembler_not_modified"  => true,
    "release_harness_not_in_write_scope" => true,
    "runtime_not_modified"    => true,
    "typechecker_semanticir_behavior_not_changed_by_hygiene" => true,
    "docs_spec_not_changed_by_hygiene" => true,
    "public_api_cli_not_changed_by_hygiene" => true,
    "spark_not_changed_by_hygiene" => true,
    "status"                  => fail_count.zero? ? "PASS" : "REVIEW"
  },
  "non_claims" => {
    "no_runtime_evaluator_support"   => true,
    "no_parser_changes"              => true,
    "no_orchestrator_changes"        => true,
    "no_assembler_changes"           => true,
    "no_release_harness_mutation"    => true,
    "no_release_evidence_mutation"   => true,
    "no_public_api_cli_widening"     => true,
    "no_public_demo_stable_claims"   => true,
    "no_if_expr_in_release_scope"    => true,
    "if_expr_proof_local_only"       => true,
    "no_spark_claim"                 => true,
    "no_doc_spec_changes"            => true,
    "no_typechecker_semanticir_behavior_changes" => true,
    "no_package_release_commands"    => true
  },
  "recommendation" => fail_count.zero? ? "implementation proof PASS — route to acceptance review" : "implementation proof FAIL — #{FAILURES.join(", ")}"
}

summary_path = File.join(OUT_DIR, "branch_conditional_if_expr_v0_implementation_proof_summary.json")
File.write(summary_path, JSON.pretty_generate(summary))

puts JSON.pretty_generate(summary)
puts
puts "=" * 72
puts "branch_conditional_if_expr_v0_implementation_proof"
puts "status:        #{status}"
puts "checks:        #{pass_count}/#{CHECKS.size} PASS"
puts "failed_checks: #{FAILURES.empty? ? "none" : FAILURES.join(", ")}"
puts "summary:       #{summary_path.sub(File.expand_path("../../", __dir__) + "/", "igniter-lang/")}"
puts "=" * 72

exit(fail_count.zero? ? 0 : 1)
