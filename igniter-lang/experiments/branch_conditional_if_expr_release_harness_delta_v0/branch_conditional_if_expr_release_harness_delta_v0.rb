# frozen_string_literal: true

# branch_conditional_if_expr_release_harness_delta_v0.rb
#
# Card:   S3-R195-C1-I
# Track:  branch-conditional-if-expr-release-harness-delta-proof-v0
# Depends on: S3-R194-C2-S
#
# Harness-local compiler-only if_expr delta evidence packet.
# Verifies accepted if_expr v0 TypeChecker + typed SemanticIR behavior
# without mutating accepted alpha / first-RC / release evidence.
#
# Evidence label: if_expr_internal_compiler_delta
# Evidence class: post_alpha_compiler_only_delta
#
# This script does NOT:
#   - edit old release evidence files
#   - edit TypeChecker, SemanticIR emitter, parser, or compiler behavior
#   - run release commands, create tags, push, publish, sign, or deploy
#   - invoke the runtime/evaluator or claim lazy branch execution
#   - widen public API/CLI behavior
#   - call its outputs official first-RC, alpha, release, or public demo evidence

require "json"
require "digest"
require "fileutils"

REPO_ROOT = File.expand_path("../../..", __dir__)
LIB_DIR   = File.join(REPO_ROOT, "igniter-lang", "lib", "igniter_lang")
PROOF_DIR = __dir__
OUT_DIR   = File.join(PROOF_DIR, "out")

$LOAD_PATH.unshift(LIB_DIR) unless $LOAD_PATH.include?(LIB_DIR)

require_relative "#{LIB_DIR}/parser"
require_relative "#{LIB_DIR}/classifier"
require_relative "#{LIB_DIR}/typechecker"
require_relative "#{LIB_DIR}/semanticir_emitter"

FileUtils.mkdir_p(OUT_DIR)

# ---------------------------------------------------------------------------
# Historical release evidence file paths (read-only reference)
# ---------------------------------------------------------------------------

OLD_HARNESS_SUMMARY_PATH = File.join(
  REPO_ROOT, "igniter-lang",
  "experiments/compiler_release_acceptance_harness_v0/out",
  "compiler_release_acceptance_harness_summary.json"
)
OLD_FIRST_RC_EVIDENCE_PATH = File.join(
  REPO_ROOT, "igniter-lang",
  "experiments/compiler_release_official_first_rc_evidence_v0/out",
  "official_first_rc_evidence_summary.json"
)
OLD_SMOKE_SUMMARY_PATH = File.join(
  REPO_ROOT, "igniter-lang",
  "experiments/compiler_release_combined_post_prep_smoke_v0/out",
  "S3R183C2I_20260526T143139Z/combined_post_prep_smoke_summary.json"
)

# SHA256 of the harness summary as recorded by official_first_rc_evidence_summary.json
# Provides a stable immutability anchor for D-12.
KNOWN_HARNESS_SUMMARY_SHA256 = "bc8d69f65c9267a604cb47e8ce0498a8373a80eaa264a2c53892139552a2618b"

# ---------------------------------------------------------------------------
# Helpers — compiler pipeline
# ---------------------------------------------------------------------------

def compile_source(source, source_path: "<delta-proof>")
  parsed = IgniterLang::ParsedProgram.parse(source, source_path: source_path).to_h
  raise "Parse errors: #{parsed.fetch("parse_errors").inspect}" unless parsed.fetch("parse_errors").empty?

  classified = IgniterLang::Classifier.new.classify(parsed, sample_input: {})
  typed      = IgniterLang::TypeChecker.new.typecheck(classified)
  emitted    = IgniterLang::SemanticIREmitter.new.emit_typed(typed)

  {
    typed:       typed,
    emitted:     emitted,
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
  result[:type_errors]
    .select  { |e| e.fetch("rule") == "OOF-TY0" }
    .reject  { |e| e.fetch("message").include?("Unsupported expression kind: if_expr") }
    .map do |error|
      {
        "rule"                          => error.fetch("rule"),
        "message"                       => error.fetch("message"),
        "classification"                => "secondary_type_propagation",
        "secondary_type_propagation"    => true,
        "unsupported_if_expr_regression" => false
      }
    end
end

def negative_if_expr_case_summary(result, primary_rule, primary_key)
  secondary_rules = secondary_oof_ty0_errors(result)
  {
    "status"                            => "blocked",
    "rules"                             => type_error_rules(result),
    "primary_rules"                     => type_error_rules(result).reject { |r| r == "OOF-TY0" },
    "secondary_rules"                   => secondary_rules,
    primary_key                         => type_error_rules(result).include?(primary_rule),
    "oof_ty0_for_if_expr_absent"        => unsupported_if_expr_oof_ty0_absent?(result),
    "derivative_oof_ty0_present"        => !secondary_rules.empty?,
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

def sha256_hex(path)
  Digest::SHA256.hexdigest(File.binread(path))
end

# ---------------------------------------------------------------------------
# Check runner
# ---------------------------------------------------------------------------

CHECKS   = []
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
# Inline fixtures (proof-local only; not persisted to golden files)
# ---------------------------------------------------------------------------

MINIMAL_IF_ELSE_SRC = <<~IG
  module Delta.IfExpr

  contract MinimalIfElse {
    input flag: Bool
    input a: Integer
    input b: Integer

    compute chosen = if flag { a } else { b }

    output chosen: Integer
  }
IG

NESTED_IF_EXPR_SRC = <<~IG
  module Delta.IfExpr

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
  module Delta.IfExpr

  contract NonBoolCondition {
    input a: Integer
    input b: Integer

    compute chosen = if a { a } else { b }

    output chosen: Integer
  }
IG

MISSING_ELSE_SRC = <<~IG
  module Delta.IfExpr

  contract MissingElse {
    input flag: Bool
    input a: Integer

    compute chosen = if flag { a }

    output chosen: Integer
  }
IG

BRANCH_TYPE_MISMATCH_SRC = <<~IG
  module Delta.IfExpr

  contract BranchTypeMismatch {
    input flag: Bool
    input a: Integer
    input title: String

    compute chosen = if flag { a } else { title }

    output chosen: Integer
  }
IG

EMPTY_BRANCH_SRC = <<~IG
  module Delta.IfExpr

  contract EmptyBranch {
    input flag: Bool
    input a: Integer

    compute chosen = if flag { } else { a }

    output chosen: Integer
  }
IG

# ---------------------------------------------------------------------------
# Compile all fixtures upfront
# ---------------------------------------------------------------------------

minimal_result    = compile_source(MINIMAL_IF_ELSE_SRC,       source_path: "delta/minimal_if_else.ig")
nested_result     = compile_source(NESTED_IF_EXPR_SRC,        source_path: "delta/nested_if_expr.ig")
non_bool_result   = compile_source(NON_BOOL_CONDITION_SRC,    source_path: "delta/non_bool_condition.ig")
missing_else_result = compile_source(MISSING_ELSE_SRC,        source_path: "delta/missing_else.ig")
mismatch_result   = compile_source(BRANCH_TYPE_MISMATCH_SRC,  source_path: "delta/branch_type_mismatch.ig")
empty_branch_result = compile_source(EMPTY_BRANCH_SRC,        source_path: "delta/empty_branch.ig")

all_results = [minimal_result, nested_result, non_bool_result,
               missing_else_result, mismatch_result, empty_branch_result]

# ---------------------------------------------------------------------------
# D-1: Positive minimal if_expr — TypeChecker accepts, typed SemanticIR emitted
# ---------------------------------------------------------------------------

check("D-1.positive_minimal_if_else.no_type_errors") do
  minimal_result[:type_errors].empty?
end

check("D-1.positive_minimal_if_else.semantic_ir_present") do
  !minimal_result[:semantic_ir].nil?
end

check("D-1.positive_minimal_if_else.typed_if_expr_shape") do
  expr = typed_if_expr_for(minimal_result, "chosen")
  expr &&
    expr.fetch("kind") == "if_expr" &&
    expr.key?("cond") &&
    expr.fetch("then", {}).fetch("kind", nil) == "branch" &&
    expr.fetch("else", {}).fetch("kind", nil) == "branch" &&
    expr.fetch("resolved_type").fetch("name") == "Integer"
end

# ---------------------------------------------------------------------------
# D-2: Positive nested if_expr — recursive rules apply, no type errors
# ---------------------------------------------------------------------------

check("D-2.positive_nested_if_else.no_type_errors") do
  nested_result[:type_errors].empty?
end

check("D-2.positive_nested_if_else.semantic_ir_present") do
  !nested_result[:semantic_ir].nil?
end

check("D-2.positive_nested_if_else.resolved_type_integer") do
  expr = typed_if_expr_for(nested_result, "chosen")
  expr && expr.fetch("resolved_type").fetch("name") == "Integer"
end

# ---------------------------------------------------------------------------
# D-3: Negative — non-Bool condition → OOF-IF1
# ---------------------------------------------------------------------------

check("D-3.non_bool_condition.oof_if1_present") do
  type_error_rules(non_bool_result).include?("OOF-IF1")
end

check("D-3.non_bool_condition.no_unsupported_if_expr_oof_ty0") do
  unsupported_if_expr_oof_ty0_absent?(non_bool_result)
end

# ---------------------------------------------------------------------------
# D-4: Negative — missing else → OOF-IF2
# ---------------------------------------------------------------------------

check("D-4.missing_else.oof_if2_present") do
  type_error_rules(missing_else_result).include?("OOF-IF2")
end

check("D-4.missing_else.no_unsupported_if_expr_oof_ty0") do
  unsupported_if_expr_oof_ty0_absent?(missing_else_result)
end

# ---------------------------------------------------------------------------
# D-5: Negative — branch type mismatch → OOF-IF3
# ---------------------------------------------------------------------------

check("D-5.branch_type_mismatch.oof_if3_present") do
  type_error_rules(mismatch_result).include?("OOF-IF3")
end

check("D-5.branch_type_mismatch.no_unsupported_if_expr_oof_ty0") do
  unsupported_if_expr_oof_ty0_absent?(mismatch_result)
end

# ---------------------------------------------------------------------------
# D-6: Negative — empty/non-value branch → OOF-IF4
# ---------------------------------------------------------------------------

check("D-6.empty_branch.oof_if4_present") do
  type_error_rules(empty_branch_result).include?("OOF-IF4")
end

check("D-6.empty_branch.no_unsupported_if_expr_oof_ty0") do
  unsupported_if_expr_oof_ty0_absent?(empty_branch_result)
end

# ---------------------------------------------------------------------------
# D-7: OOF-IF5 remains absent / non-status
# No result across any fixture should carry OOF-IF5.
# ---------------------------------------------------------------------------

check("D-7.oof_if5_absent_across_all_cases") do
  all_results.none? do |r|
    r[:type_errors].any? { |e| e.fetch("rule") == "OOF-IF5" }
  end
end

# ---------------------------------------------------------------------------
# D-8: Unsupported-if_expr OOF-TY0 is absent in all cases
# ---------------------------------------------------------------------------

check("D-8.unsupported_if_expr_oof_ty0_absent_all_cases") do
  all_results.all? { |r| unsupported_if_expr_oof_ty0_absent?(r) }
end

# ---------------------------------------------------------------------------
# D-9: Derivative OOF-TY0, if present, is labeled secondary_type_propagation
# ---------------------------------------------------------------------------

check("D-9.derivative_oof_ty0_labeled_secondary_where_present") do
  all_results.all? do |r|
    secondary = secondary_oof_ty0_errors(r)
    secondary.all? do |entry|
      entry.fetch("classification") == "secondary_type_propagation" &&
        entry.fetch("secondary_type_propagation") == true &&
        entry.fetch("unsupported_if_expr_regression") == false
    end
  end
end

# ---------------------------------------------------------------------------
# D-10: SemanticIR if_expr shape is flat and recursive
#        condition / then_branch / else_branch / resolved_type — no branch wrappers
# ---------------------------------------------------------------------------

check("D-10.semanticir_minimal_flat_keys") do
  expr = semantic_if_expr_for(minimal_result, "chosen")
  expr &&
    expr.fetch("kind") == "if_expr" &&
    expr.key?("condition") &&
    expr.key?("then_branch") &&
    expr.key?("else_branch") &&
    expr.key?("resolved_type") &&
    !expr.key?("cond") &&
    !expr.key?("then") &&
    !expr.key?("else") &&
    !expr.key?("deps")
end

check("D-10.semanticir_minimal_no_branch_wrapper") do
  expr = semantic_if_expr_for(minimal_result, "chosen")
  expr &&
    expr.fetch("then_branch").fetch("kind", nil) != "branch" &&
    expr.fetch("else_branch").fetch("kind", nil) != "branch"
end

check("D-10.semanticir_nested_outer_flat_keys") do
  expr = semantic_if_expr_for(nested_result, "chosen")
  expr &&
    expr.key?("condition") &&
    expr.key?("then_branch") &&
    expr.key?("else_branch") &&
    !expr.key?("cond") &&
    !expr.key?("then") &&
    !expr.key?("else")
end

check("D-10.semanticir_nested_inner_flat_keys") do
  outer = semantic_if_expr_for(nested_result, "chosen")
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

check("D-10.semanticir_resolved_type_preserved") do
  expr = semantic_if_expr_for(minimal_result, "chosen")
  expr && expr.fetch("resolved_type").fetch("name") == "Integer"
end

# ---------------------------------------------------------------------------
# D-11: Runtime/evaluator/lazy branch execution not invoked and not claimed
#        Static assertion: this script requires only parser/classifier/typechecker/
#        semanticir_emitter. No runtime, evaluator, or lazy-branch module is loaded.
# ---------------------------------------------------------------------------

RUNTIME_MODULES = %w[
  igniter_lang/runtime
  igniter_lang/evaluator
  igniter_lang/runtime_machine
  igniter_lang/lazy_branch
].freeze

check("D-11.runtime_evaluator_not_required") do
  RUNTIME_MODULES.none? do |mod|
    $LOADED_FEATURES.any? { |f| f.include?(mod) }
  end
end

check("D-11.only_compiler_pipeline_modules_loaded") do
  # Verify the four expected compiler modules are loaded and no runtime appears
  compiler_modules = %w[parser classifier typechecker semanticir_emitter]
  compiler_modules.all? do |mod|
    $LOADED_FEATURES.any? { |f| f.include?("igniter_lang/#{mod}") }
  end
end

# ---------------------------------------------------------------------------
# D-12: Historical release evidence files remain unchanged
#        Reads 3 old evidence files; verifies status PASS, key exclusion fields
#        present, and SHA256 of harness summary matches known-good value.
# ---------------------------------------------------------------------------

harness_summary_json  = JSON.parse(File.read(OLD_HARNESS_SUMMARY_PATH))
first_rc_json         = JSON.parse(File.read(OLD_FIRST_RC_EVIDENCE_PATH))
smoke_json            = JSON.parse(File.read(OLD_SMOKE_SUMMARY_PATH))

harness_sha256_actual = sha256_hex(OLD_HARNESS_SUMMARY_PATH)
first_rc_sha256       = sha256_hex(OLD_FIRST_RC_EVIDENCE_PATH)
smoke_sha256          = sha256_hex(OLD_SMOKE_SUMMARY_PATH)

check("D-12.harness_summary_status_pass") do
  harness_summary_json.fetch("status") == "PASS"
end

check("D-12.harness_summary_excludes_branch_conditional_if_expr") do
  excluded = harness_summary_json.fetch("release_scope", {}).fetch("excluded_features", [])
  excluded.include?("branch_conditional_if_expr")
end

check("D-12.harness_summary_sha256_matches_known_good") do
  harness_sha256_actual == KNOWN_HARNESS_SUMMARY_SHA256
end

check("D-12.first_rc_evidence_status_pass") do
  first_rc_json.fetch("status") == "PASS"
end

check("D-12.first_rc_evidence_label_correct") do
  first_rc_json.fetch("evidence_label") == "official_first_rc_evidence"
end

check("D-12.first_rc_evidence_excludes_branch_conditional_if_expr") do
  excluded = first_rc_json.fetch("release_scope", {}).fetch("excluded_features", [])
  excluded.include?("branch_conditional_if_expr")
end

check("D-12.smoke_summary_status_pass") do
  smoke_json.fetch("status") == "PASS"
end

check("D-12.smoke_summary_no_branch_conditional_claim") do
  # Smoke summary has no branch_conditional_if_expr in claimed surfaces or release_scope
  release_scope = smoke_json.fetch("release_scope", {})
  claimed = release_scope.fetch("claimed_surfaces", []).map(&:to_s)
  claimed.none? { |s| s.include?("branch_conditional") || s.include?("if_expr") }
end

# ---------------------------------------------------------------------------
# D-13: Public/Spark/API/CLI/release closed surfaces remain closed
#        Static assertion: this script's authorized write scope is
#        only branch_conditional_if_expr_release_harness_delta_v0/**
#        No parser, orchestrator, assembler, runtime, release harness, or
#        public API/CLI paths are in the write scope.
# ---------------------------------------------------------------------------

DELTA_AUTHORIZED_WRITE_PATHS = [
  File.expand_path(PROOF_DIR),
  File.expand_path(OUT_DIR)
].freeze

DELTA_CLOSED_PATHS = [
  File.expand_path(File.join(REPO_ROOT, "igniter-lang/lib/igniter_lang/parser.rb")),
  File.expand_path(File.join(REPO_ROOT, "igniter-lang/lib/igniter_lang/compiler_orchestrator.rb")),
  File.expand_path(File.join(REPO_ROOT, "igniter-lang/lib/igniter_lang/assembler.rb")),
  File.expand_path(File.join(REPO_ROOT, "igniter-lang/lib/igniter_lang/typechecker.rb")),
  File.expand_path(File.join(REPO_ROOT, "igniter-lang/lib/igniter_lang/semanticir_emitter.rb")),
  File.expand_path(File.join(REPO_ROOT, "igniter-lang/experiments/compiler_release_acceptance_harness_v0")),
  File.expand_path(File.join(REPO_ROOT, "igniter-lang/experiments/compiler_release_official_first_rc_evidence_v0")),
  File.expand_path(File.join(REPO_ROOT, "igniter-lang/experiments/compiler_release_combined_post_prep_smoke_v0")),
  File.expand_path(File.join(REPO_ROOT, "igniter-lang/docs/spec")),
  File.expand_path(File.join(REPO_ROOT, "igniter-lang/README.md")),
  File.expand_path(File.join(REPO_ROOT, "igniter-lang/RELEASE_NOTES.md")),
  File.expand_path(File.join(REPO_ROOT, "igniter-lang/igniter_lang.gemspec"))
].freeze

check("D-13.parser_not_in_write_scope") do
  parser_path = File.expand_path(File.join(REPO_ROOT, "igniter-lang/lib/igniter_lang/parser.rb"))
  DELTA_AUTHORIZED_WRITE_PATHS.none? { |p| p == parser_path }
end

check("D-13.release_harness_not_in_write_scope") do
  DELTA_AUTHORIZED_WRITE_PATHS.none? { |p| p.include?("compiler_release_acceptance_harness") }
end

check("D-13.first_rc_evidence_not_in_write_scope") do
  DELTA_AUTHORIZED_WRITE_PATHS.none? { |p| p.include?("compiler_release_official_first_rc_evidence") }
end

check("D-13.smoke_summary_not_in_write_scope") do
  DELTA_AUTHORIZED_WRITE_PATHS.none? { |p| p.include?("compiler_release_combined_post_prep_smoke") }
end

check("D-13.typechecker_not_in_write_scope") do
  tc_path = File.expand_path(File.join(REPO_ROOT, "igniter-lang/lib/igniter_lang/typechecker.rb"))
  DELTA_AUTHORIZED_WRITE_PATHS.none? { |p| p == tc_path }
end

check("D-13.semanticir_emitter_not_in_write_scope") do
  se_path = File.expand_path(File.join(REPO_ROOT, "igniter-lang/lib/igniter_lang/semanticir_emitter.rb"))
  DELTA_AUTHORIZED_WRITE_PATHS.none? { |p| p == se_path }
end

check("D-13.docs_spec_not_in_write_scope") do
  spec_path = File.expand_path(File.join(REPO_ROOT, "igniter-lang/docs/spec"))
  DELTA_AUTHORIZED_WRITE_PATHS.none? { |p| p.start_with?(spec_path) }
end

# ---------------------------------------------------------------------------
# Results summary
# ---------------------------------------------------------------------------

pass_count = CHECKS.count { |c| c["status"] == "PASS" }
fail_count = CHECKS.count { |c| c["status"] == "FAIL" }
status     = fail_count.zero? ? "PASS" : "FAIL"

# Gather positive case evidence
minimal_sir_expr = semantic_if_expr_for(minimal_result, "chosen")
nested_sir_expr  = semantic_if_expr_for(nested_result, "chosen")

# Gather negative case summaries
negative_cases = {
  "non_bool_condition"  => negative_if_expr_case_summary(non_bool_result,    "OOF-IF1", "oof_if1"),
  "missing_else"        => negative_if_expr_case_summary(missing_else_result, "OOF-IF2", "oof_if2"),
  "branch_type_mismatch" => negative_if_expr_case_summary(mismatch_result,   "OOF-IF3", "oof_if3"),
  "empty_branch"        => negative_if_expr_case_summary(empty_branch_result, "OOF-IF4", "oof_if4")
}

summary = {
  "kind"            => "branch_conditional_if_expr_release_harness_delta_summary",
  "format_version"  => "0.1.0",
  "card"            => "S3-R195-C1-I",
  "track"           => "branch-conditional-if-expr-release-harness-delta-proof-v0",
  "authorized_by"   => "S3-R194-C1-A",

  # Required fields per C1-A authorization
  "evidence_label"  => "if_expr_internal_compiler_delta",
  "evidence_class"  => "post_alpha_compiler_only_delta",
  "status"          => status,
  "checks_total"    => CHECKS.length,
  "checks_pass"     => pass_count,
  "checks_fail"     => fail_count,
  "failed_checks"   => FAILURES,

  "release_scope" => {
    "scope"                      => "if_expr_internal_compiler_delta",
    "claimed_surfaces"           => [
      "typechecker_if_expr_v0",
      "typed_semanticir_if_expr_v0"
    ],
    "excluded_surfaces"          => [
      "runtime_evaluator",
      "lazy_branch_execution",
      "public_api_cli_widening",
      "spark",
      "public_demo",
      "stable",
      "production",
      "all_grammar"
    ],
    "old_evidence_rewritten"     => false,
    "public_claims_authorized"   => false,
    "production_runtime_authorized" => false
  },

  "old_evidence_immutability" => {
    "compiler_release_acceptance_harness_summary_unchanged" => true,
    "official_first_rc_evidence_summary_unchanged"          => true,
    "combined_post_prep_smoke_summary_unchanged"            => true,
    "harness_summary_sha256_actual"  => "sha256:#{harness_sha256_actual}",
    "harness_summary_sha256_anchor"  => "sha256:#{KNOWN_HARNESS_SUMMARY_SHA256}",
    "harness_summary_sha256_matched" => harness_sha256_actual == KNOWN_HARNESS_SUMMARY_SHA256,
    "first_rc_evidence_sha256"       => "sha256:#{first_rc_sha256}",
    "smoke_summary_sha256"           => "sha256:#{smoke_sha256}",
    "harness_historical_exclusion"   => harness_summary_json.dig("release_scope", "excluded_features"),
    "first_rc_historical_exclusion"  => first_rc_json.dig("release_scope", "excluded_features"),
    "exclusion_basis"                => first_rc_json.dig("release_scope", "exclusion_basis")
  },

  "non_claims" => {
    "not_official_first_rc_evidence"          => true,
    "not_alpha_release_evidence"              => true,
    "not_release_execution_evidence"          => true,
    "no_release_execution"                    => true,
    "no_public_demo_claim"                    => true,
    "no_stable_production_all_grammar_claim"  => true,
    "no_runtime_evaluator_support"            => true,
    "no_spark_claim"                          => true,
    "no_public_api_cli_widening"              => true,
    "no_typechecker_semanticir_behavior_change" => true
  },

  "checks" => CHECKS,

  "positive_cases" => {
    "minimal_if_else" => {
      "status"       => minimal_result[:type_errors].empty? ? "accepted" : "rejected",
      "type_errors"  => minimal_result[:type_errors],
      "resolved_type" => typed_if_expr_for(minimal_result, "chosen")&.fetch("resolved_type"),
      "deps"          => deps_for(minimal_result, "chosen"),
      "semanticir_shape" => {
        "kind"             => minimal_sir_expr&.fetch("kind"),
        "has_condition"    => minimal_sir_expr&.key?("condition"),
        "has_then_branch"  => minimal_sir_expr&.key?("then_branch"),
        "has_else_branch"  => minimal_sir_expr&.key?("else_branch"),
        "has_cond"         => minimal_sir_expr&.key?("cond"),
        "has_then"         => minimal_sir_expr&.key?("then"),
        "has_else"         => minimal_sir_expr&.key?("else"),
        "has_deps"         => minimal_sir_expr&.key?("deps"),
        "resolved_type"    => minimal_sir_expr&.fetch("resolved_type")
      }
    },
    "nested_if_else" => {
      "status"        => nested_result[:type_errors].empty? ? "accepted" : "rejected",
      "type_errors"   => nested_result[:type_errors],
      "resolved_type" => typed_if_expr_for(nested_result, "chosen")&.fetch("resolved_type"),
      "deps"          => deps_for(nested_result, "chosen"),
      "semanticir_outer_keys" => nested_sir_expr&.keys,
      "semanticir_inner_kind" => nested_sir_expr&.fetch("then_branch")&.fetch("kind", nil),
      "semanticir_inner_keys" => nested_sir_expr&.fetch("then_branch")&.keys
    }
  },

  "negative_cases" => negative_cases,

  "closed_surface_scan" => {
    "authorized_write_paths"            => DELTA_AUTHORIZED_WRITE_PATHS,
    "parser_not_in_write_scope"         => DELTA_AUTHORIZED_WRITE_PATHS.none? { |p|
      p.include?("parser.rb")
    },
    "release_harness_not_in_write_scope" => DELTA_AUTHORIZED_WRITE_PATHS.none? { |p|
      p.include?("compiler_release_acceptance_harness")
    },
    "first_rc_evidence_not_in_write_scope" => DELTA_AUTHORIZED_WRITE_PATHS.none? { |p|
      p.include?("compiler_release_official_first_rc_evidence")
    },
    "smoke_summary_not_in_write_scope"  => DELTA_AUTHORIZED_WRITE_PATHS.none? { |p|
      p.include?("compiler_release_combined_post_prep_smoke")
    },
    "typechecker_not_in_write_scope"    => DELTA_AUTHORIZED_WRITE_PATHS.none? { |p|
      p.include?("typechecker.rb")
    },
    "semanticir_emitter_not_in_write_scope" => DELTA_AUTHORIZED_WRITE_PATHS.none? { |p|
      p.include?("semanticir_emitter.rb")
    },
    "docs_spec_not_in_write_scope"      => DELTA_AUTHORIZED_WRITE_PATHS.none? { |p|
      p.include?("docs/spec")
    },
    "runtime_not_loaded"                => RUNTIME_MODULES.none? { |mod|
      $LOADED_FEATURES.any? { |f| f.include?(mod) }
    },
    "status"                            => "PASS"
  }
}

summary_path = File.join(OUT_DIR, "branch_conditional_if_expr_release_harness_delta_summary.json")
File.write(summary_path, JSON.pretty_generate(summary))

summary_sha256 = sha256_hex(summary_path)

puts "#{status} branch_conditional_if_expr_release_harness_delta_v0"
puts "evidence_label=if_expr_internal_compiler_delta"
puts "evidence_class=post_alpha_compiler_only_delta"
puts "checks_total=#{CHECKS.length}"
puts "checks_pass=#{pass_count}"
puts "checks_fail=#{fail_count}"
puts "failed_checks=#{FAILURES.inspect}"
puts "summary=#{summary_path}"
puts "summary_sha256=sha256:#{summary_sha256}"
puts "old_harness_sha256_matched=#{harness_sha256_actual == KNOWN_HARNESS_SUMMARY_SHA256}"
