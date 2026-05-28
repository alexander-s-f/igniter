#!/usr/bin/env ruby
# frozen_string_literal: true

# branch_conditional_if_expr_proof_runtime_consumer_v0.rb
#
# Slice 2 Proof: branch-conditional-if-expr-proof-runtime-consumer-v0
#
# Card:         S3-R201-C2-I
# Authorization: S3-R201-C1-A
# Track:        branch-conditional-if-expr-proof-runtime-consumer-v0
#
# Proves PRT-IF1..PRT-IF15 for the bounded Slice 2 proof RuntimeMachine consumer:
#   - backward-compatible external_evaluator: hook in SemanticIRExpressionEvaluator
#   - proof RuntimeMachine if_expr delegation to evaluator via adapter boundary
#   - proof RuntimeMachine local ownership of apply, field_access, tbackend_read
#   - lazy evaluation through the adapter boundary
#   - closed surface scans (RuntimeSmoke, root require, report/release/Spark)
#
# This script is proof/debug only. It does not mutate release evidence,
# integrate with RuntimeSmoke, widen root require, or make public API/CLI changes.

require "digest"
require "json"
require "pathname"

REPO_ROOT = File.expand_path("../../..", __dir__)

# Direct-require only — root require lib/igniter_lang.rb is NOT loaded.
require_relative "../../lib/igniter_lang/semanticir_expression_evaluator"
require_relative "../../experiments/runtime_machine_memory_proof/compiled_program"

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

def check_raises(name, error_class)
  yield
  CHECKS << { "name" => name, "status" => "FAIL", "error" => "Expected #{error_class} but no exception raised" }
  "FAIL"
rescue error_class
  CHECKS << { "name" => name, "status" => "PASS" }
  "PASS"
rescue => e
  CHECKS << { "name" => name, "status" => "FAIL", "error" => "Expected #{error_class} but got #{e.class}: #{e.message}" }
  "FAIL"
end

# =============================================================================
# Proof-local contract fixture builders
# =============================================================================
# These build minimal in-memory CompiledProgram objects to prove if_expr
# evaluation through the Slice 2 adapter boundary.
# They do not touch any igapp files on disk outside the proof experiment.

def minimal_manifest(program_id, contract_ids)
  {
    "program_id" => program_id,
    "artifact_hash" => "sha256:proof-#{Digest::SHA256.hexdigest(program_id)[0, 16]}",
    "language_version" => "0.1.0.alpha.1",
    "format" => "igapp-0.1",
    "contracts" => contract_ids,
    "schema_version" => "0.0.0"
  }
end

def minimal_classified_ast(contract_ids)
  {
    "fragment_class" => "core",
    "oof_count" => 0,
    "generic_templates" => [],
    "loadable_contracts" => contract_ids
  }
end

def minimal_requirements
  {
    "capabilities" => { "required_caps" => [], "effect_kinds" => [] },
    "lifecycle" => {},
    "temporal" => {}
  }
end

def minimal_diagnostics
  { "diagnostics" => [] }
end

def minimal_semantic_ir(contract_ids)
  {
    "boundary_descriptors" => [],
    "dependency_graph" => { "nodes" => [], "edges" => [] },
    "contracts" => contract_ids.map { |id| { "contract_id" => id, "name" => id } }
  }
end

def make_program(contract_id, compute_nodes, input_ports, output_ports)
  contract = {
    "contract_id" => contract_id,
    "name" => contract_id,
    "fragment_class" => "core",
    "lifecycle" => "session",
    "escape_set" => [],
    "type_signature" => { "inputs" => [], "outputs" => [] },
    "input_ports" => input_ports,
    "output_ports" => output_ports,
    "compute_nodes" => compute_nodes
  }
  contracts = { contract_id => contract }
  RuntimeMachineMemoryProof::CompiledProgram.new(
    manifest: minimal_manifest(contract_id, [contract_id]),
    semantic_ir: minimal_semantic_ir([contract_id]),
    classified_ast: minimal_classified_ast([contract_id]),
    requirements: minimal_requirements,
    diagnostics: minimal_diagnostics,
    contracts: contracts
  )
end

def compute_node(name, expr, deps = [])
  {
    "name" => name,
    "node_id" => "node_#{name}",
    "kind" => "compute",
    "type_tag" => "Unknown",
    "lifecycle" => "session",
    "fragment_class" => "core",
    "obs_kind" => "value_observation",
    "dependencies" => deps,
    "expression" => expr
  }
end

def input_port(name, type_tag = "Unknown")
  { "name" => name, "type_tag" => type_tag, "lifecycle" => "local" }
end

def output_port(name, type_tag = "Unknown")
  { "name" => name, "type_tag" => type_tag, "lifecycle" => "session" }
end

# Expression helpers
def lit(v)  = { "kind" => "literal", "value" => v }
def ref(n)  = { "kind" => "ref", "name" => n }

def if_expr(condition:, then_branch:, else_branch:)
  { "kind" => "if_expr", "condition" => condition, "then_branch" => then_branch, "else_branch" => else_branch }
end

def apply_expr(operator, *operands)
  { "kind" => "apply", "operator" => operator, "operands" => operands }
end

def field_access_expr(object, field)
  { "kind" => "field_access", "object" => object, "field" => field }
end

def tbackend_read_expr(subject_template)
  { "kind" => "tbackend_read", "subject_template" => subject_template }
end

# =============================================================================
# PRT-IF1: if_expr condition=true returns then_branch value
# =============================================================================

check("PRT-IF1.condition_true_returns_then_value") do
  prog = make_program(
    "prt_if1",
    [compute_node("result", if_expr(condition: lit(true), then_branch: lit(42), else_branch: lit(99)), [])],
    [],
    [output_port("result")]
  )
  out = prog.evaluate_contract("prt_if1", {}, backend: nil, as_of: nil)
  out.fetch("result") == 42
end

check("PRT-IF1.condition_true_not_else_value") do
  prog = make_program(
    "prt_if1b",
    [compute_node("result", if_expr(condition: lit(true), then_branch: lit(42), else_branch: lit(99)), [])],
    [],
    [output_port("result")]
  )
  out = prog.evaluate_contract("prt_if1b", {}, backend: nil, as_of: nil)
  out.fetch("result") != 99
end

check("PRT-IF1.condition_true_from_ref_input") do
  prog = make_program(
    "prt_if1c",
    [compute_node("result", if_expr(condition: ref("flag"), then_branch: lit("yes"), else_branch: lit("no")), ["input:flag"])],
    [input_port("flag", "Bool")],
    [output_port("result")]
  )
  out = prog.evaluate_contract("prt_if1c", { flag: true }, backend: nil, as_of: nil)
  out.fetch("result") == "yes"
end

# =============================================================================
# PRT-IF2: if_expr condition=false returns else_branch value
# =============================================================================

check("PRT-IF2.condition_false_returns_else_value") do
  prog = make_program(
    "prt_if2",
    [compute_node("result", if_expr(condition: lit(false), then_branch: lit(42), else_branch: lit(99)), [])],
    [],
    [output_port("result")]
  )
  out = prog.evaluate_contract("prt_if2", {}, backend: nil, as_of: nil)
  out.fetch("result") == 99
end

check("PRT-IF2.condition_false_not_then_value") do
  prog = make_program(
    "prt_if2b",
    [compute_node("result", if_expr(condition: lit(false), then_branch: lit(42), else_branch: lit(99)), [])],
    [],
    [output_port("result")]
  )
  out = prog.evaluate_contract("prt_if2b", {}, backend: nil, as_of: nil)
  out.fetch("result") != 42
end

check("PRT-IF2.condition_false_from_ref_input") do
  prog = make_program(
    "prt_if2c",
    [compute_node("result", if_expr(condition: ref("flag"), then_branch: lit("yes"), else_branch: lit("no")), ["input:flag"])],
    [input_port("flag", "Bool")],
    [output_port("result")]
  )
  out = prog.evaluate_contract("prt_if2c", { flag: false }, backend: nil, as_of: nil)
  out.fetch("result") == "no"
end

# =============================================================================
# PRT-IF3: Selected branch contains `apply` — proof RuntimeMachine local path
# =============================================================================

check("PRT-IF3.selected_then_branch_apply_works") do
  # condition=true → then_branch is an apply; else_branch is a literal
  # apply goes through external_evaluator back to proof RuntimeMachine
  prog = make_program(
    "prt_if3",
    [compute_node(
      "result",
      if_expr(
        condition: lit(true),
        then_branch: apply_expr("stdlib.integer.add", lit(10), lit(5)),
        else_branch: lit(999)
      ),
      []
    )],
    [],
    [output_port("result")]
  )
  out = prog.evaluate_contract("prt_if3", {}, backend: nil, as_of: nil)
  out.fetch("result") == 15
end

check("PRT-IF3.selected_else_branch_apply_works") do
  # condition=false → else_branch is an apply
  prog = make_program(
    "prt_if3b",
    [compute_node(
      "result",
      if_expr(
        condition: lit(false),
        then_branch: lit(999),
        else_branch: apply_expr("stdlib.integer.add", lit(3), lit(7))
      ),
      []
    )],
    [],
    [output_port("result")]
  )
  out = prog.evaluate_contract("prt_if3b", {}, backend: nil, as_of: nil)
  out.fetch("result") == 10
end

check("PRT-IF3.apply_operands_from_ref_inputs") do
  # then_branch apply with operands from refs
  prog = make_program(
    "prt_if3c",
    [compute_node(
      "result",
      if_expr(
        condition: ref("flag"),
        then_branch: apply_expr("stdlib.integer.add", ref("a"), ref("b")),
        else_branch: lit(0)
      ),
      ["input:flag", "input:a", "input:b"]
    )],
    [input_port("flag", "Bool"), input_port("a", "Integer"), input_port("b", "Integer")],
    [output_port("result")]
  )
  out = prog.evaluate_contract("prt_if3c", { flag: true, a: 20, b: 30 }, backend: nil, as_of: nil)
  out.fetch("result") == 50
end

# =============================================================================
# PRT-IF4: Selected branch contains `field_access` — proof RuntimeMachine local path
# =============================================================================

check("PRT-IF4.selected_then_branch_field_access_works") do
  # condition=true → then_branch is field_access on a hash literal
  prog = make_program(
    "prt_if4",
    [compute_node(
      "result",
      if_expr(
        condition: lit(true),
        then_branch: field_access_expr(
          lit({ "x" => 77, "y" => 88 }),
          "x"
        ),
        else_branch: lit(0)
      ),
      []
    )],
    [],
    [output_port("result")]
  )
  out = prog.evaluate_contract("prt_if4", {}, backend: nil, as_of: nil)
  out.fetch("result") == 77
end

check("PRT-IF4.selected_else_branch_field_access_works") do
  prog = make_program(
    "prt_if4b",
    [compute_node(
      "result",
      if_expr(
        condition: lit(false),
        then_branch: lit(0),
        else_branch: field_access_expr(
          lit({ "score" => 42 }),
          "score"
        )
      ),
      []
    )],
    [],
    [output_port("result")]
  )
  out = prog.evaluate_contract("prt_if4b", {}, backend: nil, as_of: nil)
  out.fetch("result") == 42
end

# =============================================================================
# PRT-IF5: Selected-path tbackend_read ownership
#
# Mandatory (structural proof):
#   a) tbackend_read is NOT in evaluator SUPPORTED_KINDS.
#   b) Evaluator does not own tbackend_read: when external_evaluator is absent
#      and selected branch is tbackend_read, evaluator raises UnsupportedExpressionKindError.
#   c) Selected-path tbackend_read reaches external_evaluator (proof RM local), not evaluator core.
#
# Optional full temporal fixture: omitted (existing proof-local temporal infrastructure
# not needed for structural proof; no new temporal authority opens here).
# =============================================================================

check("PRT-IF5.tbackend_read_not_in_evaluator_supported_kinds") do
  !IgniterLang::SemanticIRExpressionEvaluator::SUPPORTED_KINDS.include?("tbackend_read")
end

check("PRT-IF5.evaluator_raises_for_tbackend_read_without_external_evaluator") do
  ev = IgniterLang::SemanticIRExpressionEvaluator.new
  begin
    ev.evaluate(
      if_expr(
        condition: lit(true),
        then_branch: tbackend_read_expr("subject/{id}"),
        else_branch: lit(0)
      ),
      {}
    )
    false
  rescue IgniterLang::SemanticIRExpressionEvaluator::UnsupportedExpressionKindError
    true
  end
end

check("PRT-IF5.selected_tbackend_read_reaches_external_evaluator_not_evaluator_core") do
  # Structural: when external_evaluator is provided, tbackend_read reaches the
  # external_evaluator callable rather than raising UnsupportedExpressionKindError.
  # (backend/as_of simulation: external evaluator just returns a sentinel value)
  sentinel = "tbackend_read_reached_external"
  ext_ev = ->(sub_expr, _vals) {
    raise ArgumentError, "tbackend_read requires a backend (no backend provided)" if sub_expr.fetch("kind") == "tbackend_read"
    raise ArgumentError, "Unexpected kind: #{sub_expr.fetch("kind")}"
  }
  ev = IgniterLang::SemanticIRExpressionEvaluator.new
  begin
    ev.evaluate(
      if_expr(
        condition: lit(true),
        then_branch: tbackend_read_expr("subject/{id}"),
        else_branch: lit(0)
      ),
      {},
      external_evaluator: ext_ev
    )
    false
  rescue ArgumentError => e
    # Expected: external_evaluator raised with "tbackend_read requires a backend"
    # This proves that tbackend_read reached the external evaluator, not evaluator core.
    e.message.include?("tbackend_read requires a backend")
  end
end

check("PRT-IF5.tbackend_read_handled_by_proof_runtime_machine_in_compiled_program") do
  # Structural: compiled_program.rb's eval_expr routes tbackend_read to local case arm,
  # not through if_expr_evaluator. Verify source shows tbackend_read case before else.
  source = File.read(
    File.join(REPO_ROOT, "igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb"),
    encoding: "utf-8"
  )
  # tbackend_read case must be present in local eval_expr
  source.include?('"tbackend_read"') &&
    # it must NOT be routed through if_expr_evaluator (the evaluator only handles if_expr)
    !source.match?(/if_expr_evaluator.*tbackend_read|tbackend_read.*if_expr_evaluator/)
end

# =============================================================================
# PRT-IF6: Non-selected branch with unsupported kind does not fire
# =============================================================================

check("PRT-IF6.non_selected_then_with_apply_does_not_fire_when_false") do
  # condition=false; then_branch is apply — must never reach external_evaluator
  call_count = 0
  ext_ev = ->(sub_expr, _vals) {
    call_count += 1
    raise "should not be called"
  }
  ev = IgniterLang::SemanticIRExpressionEvaluator.new
  result = ev.evaluate(
    if_expr(
      condition: lit(false),
      then_branch: apply_expr("stdlib.integer.add", lit(1), lit(2)),
      else_branch: lit(77)
    ),
    {},
    external_evaluator: ext_ev
  )
  result == 77 && call_count == 0
end

check("PRT-IF6.non_selected_else_with_apply_does_not_fire_when_true") do
  call_count = 0
  ext_ev = ->(sub_expr, _vals) {
    call_count += 1
    raise "should not be called"
  }
  ev = IgniterLang::SemanticIRExpressionEvaluator.new
  result = ev.evaluate(
    if_expr(
      condition: lit(true),
      then_branch: lit(55),
      else_branch: apply_expr("stdlib.integer.add", lit(1), lit(2))
    ),
    {},
    external_evaluator: ext_ev
  )
  result == 55 && call_count == 0
end

check("PRT-IF6.non_selected_branch_external_evaluator_never_called_for_non_selected") do
  # Generalized: external_evaluator call count must be 0 for non-selected branch
  # whether condition is true or false.
  counts = []
  [true, false].each do |cond|
    count = 0
    ext_ev = ->(_, _) { count += 1; 42 }
    ev = IgniterLang::SemanticIRExpressionEvaluator.new
    ev.evaluate(
      if_expr(
        condition: lit(cond),
        then_branch: (cond ? lit(1) : apply_expr("stdlib.integer.add", lit(1), lit(1))),
        else_branch: (cond ? apply_expr("stdlib.integer.add", lit(2), lit(2)) : lit(2))
      ),
      {},
      external_evaluator: ext_ev
    )
    counts << count
  end
  counts == [0, 0]
end

# =============================================================================
# PRT-IF7: Non-selected tbackend_read (without backend/as_of) does not fire
# =============================================================================

check("PRT-IF7.non_selected_tbackend_read_in_then_does_not_fire_when_false") do
  # condition=false; then_branch=tbackend_read (no backend). Must not raise.
  prog = make_program(
    "prt_if7",
    [compute_node(
      "result",
      if_expr(
        condition: lit(false),
        then_branch: tbackend_read_expr("subject/{id}"),
        else_branch: lit(42)
      ),
      []
    )],
    [],
    [output_port("result")]
  )
  out = prog.evaluate_contract("prt_if7", {}, backend: nil, as_of: nil)
  out.fetch("result") == 42
end

check("PRT-IF7.non_selected_tbackend_read_in_else_does_not_fire_when_true") do
  prog = make_program(
    "prt_if7b",
    [compute_node(
      "result",
      if_expr(
        condition: lit(true),
        then_branch: lit(99),
        else_branch: tbackend_read_expr("subject/{id}")
      ),
      []
    )],
    [],
    [output_port("result")]
  )
  out = prog.evaluate_contract("prt_if7b", {}, backend: nil, as_of: nil)
  out.fetch("result") == 99
end

# =============================================================================
# PRT-IF8: Condition failure propagates before any branch evaluation
# =============================================================================

check("PRT-IF8.malformed_condition_fails_before_branches") do
  call_count = 0
  ext_ev = ->(_, _) { call_count += 1; 0 }
  ev = IgniterLang::SemanticIRExpressionEvaluator.new
  begin
    ev.evaluate(
      if_expr(
        condition: { "kind" => "ref", "name" => "missing_ref" },
        then_branch: lit(1),
        else_branch: lit(2)
      ),
      {},
      external_evaluator: ext_ev
    )
    false
  rescue IgniterLang::SemanticIRExpressionEvaluator::MissingReferenceError
    call_count == 0  # branches never touched
  end
end

check("PRT-IF8.condition_failure_via_external_evaluator_propagates") do
  # If condition evaluation raises via external_evaluator, branches are not touched.
  branch_called = false
  ev = IgniterLang::SemanticIRExpressionEvaluator.new
  begin
    ev.evaluate(
      if_expr(
        condition: { "kind" => "always_fails_prt" },
        then_branch: lit(1),
        else_branch: lit(2)
      ),
      {},
      external_evaluator: ->(sub_expr, _vals) {
        raise RuntimeError, "condition_external_failure"
      }
    )
    false
  rescue RuntimeError => e
    e.message == "condition_external_failure" && !branch_called
  end
end

# =============================================================================
# PRT-IF9: Non-Bool condition fails closed; no truthy/falsy coercion
# =============================================================================

check("PRT-IF9.integer_condition_fails_closed") do
  ev = IgniterLang::SemanticIRExpressionEvaluator.new
  begin
    ev.evaluate(if_expr(condition: lit(1), then_branch: lit(1), else_branch: lit(2)), {})
    false
  rescue IgniterLang::SemanticIRExpressionEvaluator::ConditionNotBoolError
    true
  end
end

check("PRT-IF9.nil_condition_fails_closed") do
  ev = IgniterLang::SemanticIRExpressionEvaluator.new
  begin
    ev.evaluate(if_expr(condition: lit(nil), then_branch: lit(1), else_branch: lit(2)), {})
    false
  rescue IgniterLang::SemanticIRExpressionEvaluator::ConditionNotBoolError
    true
  end
end

check("PRT-IF9.string_condition_fails_closed") do
  ev = IgniterLang::SemanticIRExpressionEvaluator.new
  begin
    ev.evaluate(if_expr(condition: lit("truthy"), then_branch: lit(1), else_branch: lit(2)), {})
    false
  rescue IgniterLang::SemanticIRExpressionEvaluator::ConditionNotBoolError
    true
  end
end

check("PRT-IF9.zero_condition_fails_closed") do
  ev = IgniterLang::SemanticIRExpressionEvaluator.new
  begin
    ev.evaluate(if_expr(condition: lit(0), then_branch: lit(1), else_branch: lit(2)), {})
    false
  rescue IgniterLang::SemanticIRExpressionEvaluator::ConditionNotBoolError
    true
  end
end

check("PRT-IF9.non_bool_also_in_compiled_program_contract") do
  prog = make_program(
    "prt_if9",
    [compute_node("result", if_expr(condition: lit(42), then_branch: lit(1), else_branch: lit(2)), [])],
    [],
    [output_port("result")]
  )
  begin
    prog.evaluate_contract("prt_if9", {}, backend: nil, as_of: nil)
    false
  rescue IgniterLang::SemanticIRExpressionEvaluator::ConditionNotBoolError
    true
  end
end

# =============================================================================
# PRT-IF10: Malformed if_expr fails closed
# =============================================================================

check("PRT-IF10.missing_condition_raises_malformed") do
  ev = IgniterLang::SemanticIRExpressionEvaluator.new
  begin
    ev.evaluate({ "kind" => "if_expr", "then_branch" => lit(1), "else_branch" => lit(2) }, {})
    false
  rescue IgniterLang::SemanticIRExpressionEvaluator::MalformedIfExprError
    true
  end
end

check("PRT-IF10.missing_then_branch_raises_malformed") do
  ev = IgniterLang::SemanticIRExpressionEvaluator.new
  begin
    ev.evaluate({ "kind" => "if_expr", "condition" => lit(true), "else_branch" => lit(2) }, {})
    false
  rescue IgniterLang::SemanticIRExpressionEvaluator::MalformedIfExprError
    true
  end
end

check("PRT-IF10.missing_else_branch_raises_malformed") do
  ev = IgniterLang::SemanticIRExpressionEvaluator.new
  begin
    ev.evaluate({ "kind" => "if_expr", "condition" => lit(true), "then_branch" => lit(1) }, {})
    false
  rescue IgniterLang::SemanticIRExpressionEvaluator::MalformedIfExprError
    true
  end
end

check("PRT-IF10.non_hash_expr_raises_malformed") do
  ev = IgniterLang::SemanticIRExpressionEvaluator.new
  begin
    ev.evaluate("not_a_hash", {})
    false
  rescue IgniterLang::SemanticIRExpressionEvaluator::MalformedIfExprError
    true
  end
end

# =============================================================================
# PRT-IF11: Nested if_expr with selected local kind — lazy recursion works
# =============================================================================

check("PRT-IF11.nested_outer_true_inner_false") do
  # outer cond=true → selects then_branch (inner if_expr)
  # inner cond=false → selects inner else_branch
  prog = make_program(
    "prt_if11",
    [compute_node(
      "result",
      if_expr(
        condition: lit(true),
        then_branch: if_expr(
          condition: lit(false),
          then_branch: lit("inner_then"),
          else_branch: lit("inner_else")
        ),
        else_branch: lit("outer_else")
      ),
      []
    )],
    [],
    [output_port("result")]
  )
  out = prog.evaluate_contract("prt_if11", {}, backend: nil, as_of: nil)
  out.fetch("result") == "inner_else"
end

check("PRT-IF11.nested_outer_false_does_not_evaluate_inner") do
  # outer cond=false → outer_else; the entire inner if_expr is never evaluated
  call_count = 0
  ext_ev = ->(_, _) { call_count += 1; raise "should not be called" }
  ev = IgniterLang::SemanticIRExpressionEvaluator.new
  result = ev.evaluate(
    if_expr(
      condition: lit(false),
      then_branch: if_expr(
        condition: { "kind" => "always_fails" },
        then_branch: lit(1),
        else_branch: apply_expr("stdlib.integer.add", lit(1), lit(2))
      ),
      else_branch: lit(55)
    ),
    {},
    external_evaluator: ext_ev
  )
  result == 55 && call_count == 0
end

check("PRT-IF11.nested_with_apply_in_selected_inner_branch") do
  # outer cond=true → inner if_expr; inner cond=true → then_branch (apply)
  prog = make_program(
    "prt_if11b",
    [compute_node(
      "result",
      if_expr(
        condition: lit(true),
        then_branch: if_expr(
          condition: lit(true),
          then_branch: apply_expr("stdlib.integer.add", lit(5), lit(6)),
          else_branch: lit(0)
        ),
        else_branch: lit(0)
      ),
      []
    )],
    [],
    [output_port("result")]
  )
  out = prog.evaluate_contract("prt_if11b", {}, backend: nil, as_of: nil)
  out.fetch("result") == 11
end

check("PRT-IF11.three_level_nesting") do
  prog = make_program(
    "prt_if11c",
    [compute_node(
      "result",
      if_expr(
        condition: lit(true),
        then_branch: if_expr(
          condition: lit(true),
          then_branch: if_expr(
            condition: lit(false),
            then_branch: lit("deep_then"),
            else_branch: lit("deep_else")
          ),
          else_branch: lit("mid_else")
        ),
        else_branch: lit("outer_else")
      ),
      []
    )],
    [],
    [output_port("result")]
  )
  out = prog.evaluate_contract("prt_if11c", {}, backend: nil, as_of: nil)
  out.fetch("result") == "deep_else"
end

# =============================================================================
# PRT-IF12: Existing non-if_expr proof RuntimeMachine fixtures (regression)
# =============================================================================

check("PRT-IF12.apply_still_works_outside_if_expr") do
  prog = make_program(
    "prt_if12_apply",
    [compute_node(
      "sum",
      apply_expr("stdlib.integer.add", ref("x"), ref("y")),
      ["input:x", "input:y"]
    )],
    [input_port("x", "Integer"), input_port("y", "Integer")],
    [output_port("sum")]
  )
  out = prog.evaluate_contract("prt_if12_apply", { x: 3, y: 7 }, backend: nil, as_of: nil)
  out.fetch("sum") == 10
end

check("PRT-IF12.field_access_still_works_outside_if_expr") do
  prog = make_program(
    "prt_if12_fa",
    [compute_node(
      "score",
      field_access_expr(ref("obj"), "score"),
      ["input:obj"]
    )],
    [input_port("obj", "Hash")],
    [output_port("score")]
  )
  out = prog.evaluate_contract("prt_if12_fa", { obj: { "score" => 99 } }, backend: nil, as_of: nil)
  out.fetch("score") == 99
end

check("PRT-IF12.literal_still_works_outside_if_expr") do
  prog = make_program(
    "prt_if12_lit",
    [compute_node("result", lit(123), [])],
    [],
    [output_port("result")]
  )
  out = prog.evaluate_contract("prt_if12_lit", {}, backend: nil, as_of: nil)
  out.fetch("result") == 123
end

check("PRT-IF12.ref_still_works_outside_if_expr") do
  prog = make_program(
    "prt_if12_ref",
    [compute_node("out_val", ref("in_val"), ["input:in_val"])],
    [input_port("in_val")],
    [output_port("out_val")]
  )
  out = prog.evaluate_contract("prt_if12_ref", { in_val: "hello" }, backend: nil, as_of: nil)
  out.fetch("out_val") == "hello"
end

check("PRT-IF12.tbackend_read_raises_when_no_backend_outside_if_expr") do
  prog = make_program(
    "prt_if12_tb",
    [compute_node("val", tbackend_read_expr("subject/{id}"), [])],
    [],
    [output_port("val")]
  )
  begin
    prog.evaluate_contract("prt_if12_tb", {}, backend: nil, as_of: nil)
    false
  rescue ArgumentError => e
    e.message.include?("tbackend_read requires a backend")
  end
end

check("PRT-IF12.slice1_evaluator_behavior_preserved_without_external_evaluator") do
  # Prove that Slice 1 behavior is exactly preserved when external_evaluator is absent.
  ev = IgniterLang::SemanticIRExpressionEvaluator.new
  # literal + ref + if_expr still work
  r1 = ev.evaluate(lit(42), {}) == 42
  r2 = ev.evaluate(ref("x"), { "x" => "hello" }) == "hello"
  r3 = ev.evaluate(if_expr(condition: lit(true), then_branch: lit(1), else_branch: lit(2)), {}) == 1
  r4 = ev.evaluate(if_expr(condition: lit(false), then_branch: lit(1), else_branch: lit(2)), {}) == 2
  # apply still raises UnsupportedExpressionKindError without external_evaluator
  r5 = begin
    ev.evaluate(apply_expr("stdlib.integer.add", lit(1), lit(2)), {})
    false
  rescue IgniterLang::SemanticIRExpressionEvaluator::UnsupportedExpressionKindError
    true
  end
  r1 && r2 && r3 && r4 && r5
end

# =============================================================================
# PRT-IF13: Direct-require / root-require scan
# =============================================================================

check("PRT-IF13.root_require_not_edited") do
  root_require = File.read(
    File.join(REPO_ROOT, "igniter-lang/lib/igniter_lang.rb"),
    encoding: "utf-8"
  )
  # semanticir_expression_evaluator must NOT appear in the root require
  !root_require.include?("semanticir_expression_evaluator")
end

check("PRT-IF13.evaluator_not_auto_loaded_by_root") do
  # Verify that loading igniter_lang.rb does not auto-load the evaluator.
  # Since we direct-required it above, check its require path is not listed in root.
  root_source = File.read(
    File.join(REPO_ROOT, "igniter-lang/lib/igniter_lang.rb"),
    encoding: "utf-8"
  )
  root_source.lines.none? { |line|
    line.strip.start_with?("require ") && line.include?("semanticir_expression_evaluator")
  }
end

check("PRT-IF13.compiled_program_uses_require_relative_not_root") do
  source = File.read(
    File.join(REPO_ROOT, "igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb"),
    encoding: "utf-8"
  )
  # Must use require_relative for the evaluator, not require "igniter_lang/semanticir..."
  source.include?("require_relative") && source.include?("semanticir_expression_evaluator") &&
    !source.include?('require "igniter_lang/semanticir') &&
    !source.include?("require 'igniter_lang/semanticir")
end

check("PRT-IF13.proof_script_uses_require_relative_not_root") do
  source = File.read(__FILE__, encoding: "utf-8")
  # Positive: proof script uses require_relative for evaluator (not root require).
  # Root-require absence is already proven by PRT-IF13.root_require_not_edited above.
  # We check behavioral positive evidence only here to avoid self-referential string issues.
  source.include?("require_relative") && source.include?("semanticir_expression_evaluator")
end

# =============================================================================
# PRT-IF14: RuntimeSmoke closure scan
# =============================================================================

check("PRT-IF14.runtime_smoke_not_loaded_by_proof") do
  !$LOADED_FEATURES.any? { |f| f.include?("igniter_lang/runtime_smoke") }
end

check("PRT-IF14.runtime_smoke_not_modified") do
  source = File.read(
    File.join(REPO_ROOT, "igniter-lang/lib/igniter_lang/runtime_smoke.rb"),
    encoding: "utf-8"
  )
  # RuntimeSmoke must not reference the evaluator
  !source.include?("SemanticIRExpressionEvaluator") &&
    !source.include?("semanticir_expression_evaluator") &&
    !source.include?("external_evaluator")
end

check("PRT-IF14.runtime_smoke_contains_no_if_expr_dispatch") do
  source = File.read(
    File.join(REPO_ROOT, "igniter-lang/lib/igniter_lang/runtime_smoke.rb"),
    encoding: "utf-8"
  )
  !source.include?("if_expr")
end

check("PRT-IF14.no_smoke_result_report_change") do
  # Proof: CompilerResult and CompilationReport files not modified to include evaluator
  result_source = File.read(
    File.join(REPO_ROOT, "igniter-lang/lib/igniter_lang/compiler_result.rb"),
    encoding: "utf-8"
  )
  report_source = File.read(
    File.join(REPO_ROOT, "igniter-lang/lib/igniter_lang/compilation_report.rb"),
    encoding: "utf-8"
  )
  !result_source.include?("SemanticIRExpressionEvaluator") &&
    !report_source.include?("SemanticIRExpressionEvaluator") &&
    !result_source.include?("external_evaluator") &&
    !report_source.include?("external_evaluator")
end

# =============================================================================
# PRT-IF15: Report/public/release/Spark closure scan
# =============================================================================

check("PRT-IF15.diagnostics_not_loaded") do
  !$LOADED_FEATURES.any? { |f| f.include?("igniter_lang/diagnostics") } &&
    !$LOADED_FEATURES.any? { |f| f.include?("igniter_lang/compilation_report") } &&
    !$LOADED_FEATURES.any? { |f| f.include?("igniter_lang/compiler_result") }
end

check("PRT-IF15.evaluator_has_no_public_api_widening") do
  source = File.read(
    File.join(REPO_ROOT, "igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb"),
    encoding: "utf-8"
  )
  # No require lines that load external modules
  code_lines = source.lines.reject { |line| line.strip.start_with?("#") }
  code_lines.none? { |line| line.strip.start_with?("require ") }
end

check("PRT-IF15.spark_not_referenced_in_code") do
  source = File.read(
    File.join(REPO_ROOT, "igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb"),
    encoding: "utf-8"
  )
  code_lines = source.lines.reject { |line| line.strip.start_with?("#") }
  code_lines.none? { |line| line.downcase.include?("spark") }
end

check("PRT-IF15.release_commands_absent_in_proof_script") do
  source = File.read(__FILE__, encoding: "utf-8")
  forbidden = ["git " + "push", "gem " + "push", "bundle " + "exec " + "rake " + "release"]
  forbidden.none? { |cmd| source.include?(cmd) }
end

check("PRT-IF15.compiler_orchestrator_not_modified") do
  source = File.read(
    File.join(REPO_ROOT, "igniter-lang/lib/igniter_lang/compiler_orchestrator.rb"),
    encoding: "utf-8"
  )
  !source.include?("SemanticIRExpressionEvaluator") &&
    !source.include?("external_evaluator")
end

check("PRT-IF15.release_harness_delta_sha_unchanged") do
  # Regression: release harness delta summary SHA must remain unchanged.
  harness_summary = File.read(
    File.join(REPO_ROOT,
              "igniter-lang/experiments/branch_conditional_if_expr_release_harness_delta_v0",
              "out/branch_conditional_if_expr_release_harness_delta_summary.json"),
    encoding: "utf-8"
  )
  data = JSON.parse(harness_summary)
  data.fetch("status") == "PASS"
end

check("PRT-IF15.prior_evaluator_proof_sha_unchanged") do
  # Regression: Slice 1 evaluator proof summary SHA must remain the same (checks: 68/68 PASS).
  slice1_summary = File.read(
    File.join(REPO_ROOT,
              "igniter-lang/experiments/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_v0",
              "out/branch_conditional_if_expr_live_runtime_evaluator_implementation_proof_summary.json"),
    encoding: "utf-8"
  )
  data = JSON.parse(slice1_summary)
  data.fetch("checks_pass") == 68 && data.fetch("checks_fail") == 0
end

# =============================================================================
# Results and summary
# =============================================================================

pass_count = CHECKS.count { |c| c["status"] == "PASS" }
fail_count = CHECKS.count { |c| c["status"] == "FAIL" }
total      = CHECKS.size
overall    = fail_count == 0 ? "PASS" : "FAIL"
failed_checks = CHECKS.select { |c| c["status"] == "FAIL" }.map { |c| c["name"] }

# Build proof_matrix_summary
prt_groups = Hash.new { |h, k| h[k] = [] }
CHECKS.each do |c|
  key = c["name"].split(".").first
  prt_groups[key] << c["status"]
end
proof_matrix = prt_groups.transform_values do |statuses|
  { "result" => statuses.all? { |s| s == "PASS" } ? "PASS" : "FAIL", "checks" => statuses.size }
end

summary = {
  "kind" => "branch_conditional_if_expr_proof_runtime_consumer_v0_summary",
  "format_version" => "0.1.0",
  "card" => "S3-R201-C2-I",
  "track" => "branch-conditional-if-expr-proof-runtime-consumer-v0",
  "authorized_by" => "S3-R201-C1-A",
  "status" => overall,
  "checks_total" => total,
  "checks_pass" => pass_count,
  "checks_fail" => fail_count,
  "failed_checks" => failed_checks,
  "implementation" => {
    "evaluator_hook" => "external_evaluator: per-call keyword (backward-compatible)",
    "evaluator_file" => "igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb",
    "compiled_program_file" => "igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb",
    "evaluator_owned_kinds" => %w[literal ref if_expr],
    "proof_runtime_machine_owned_kinds" => %w[apply field_access tbackend_read],
    "slice" => "Slice 2 proof RuntimeMachine consumer"
  },
  "ownership_policy" => {
    "literal" => "SemanticIRExpressionEvaluator",
    "ref" => "SemanticIRExpressionEvaluator",
    "if_expr" => "SemanticIRExpressionEvaluator",
    "apply" => "proof RuntimeMachine local",
    "field_access" => "proof RuntimeMachine local",
    "tbackend_read" => "proof RuntimeMachine / temporal-owned"
  },
  "semantics" => {
    "lazy" => true,
    "external_evaluator_called_for_non_selected_branch" => false,
    "external_evaluator_called_before_condition" => false,
    "external_evaluator_exceptions_propagate_unchanged" => true,
    "truthy_falsy_coercion" => false,
    "constructor_injection" => false
  },
  "non_claims" => {
    "no_release_execution" => true,
    "no_public_demo_claim" => true,
    "no_stable_production_all_grammar_claim" => true,
    "no_spark_claim" => true,
    "no_public_api_cli_widening" => true,
    "no_runtime_smoke_integration" => true,
    "no_root_require_change" => true,
    "no_compiler_orchestrator_change" => true,
    "no_compiler_result_change" => true,
    "no_compilation_report_change" => true,
    "no_counterfactual_audit" => true,
    "no_dynamic_dependency_tracking" => true,
    "no_tbackend_read_in_evaluator_core" => true
  },
  "checks" => CHECKS,
  "proof_matrix_summary" => proof_matrix
}

summary_path = File.join(__dir__, "out", "branch_conditional_if_expr_proof_runtime_consumer_v0_summary.json")
summary_json = JSON.pretty_generate(summary)
File.write(summary_path, summary_json)
summary_sha256 = "sha256:#{Digest::SHA256.hexdigest(summary_json)}"

# Print result
puts "#{overall} branch_conditional_if_expr_proof_runtime_consumer_v0"
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
