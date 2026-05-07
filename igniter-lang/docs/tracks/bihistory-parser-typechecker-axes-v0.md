# Track: BiHistory Parser/TypeChecker Axes v0

Role: `[Igniter-Lang Compiler/Grammar Expert]`
Track: igniter-lang/bihistory-parser-typechecker-axes-v0
Card: S2-R3-C1-P
Status: done
Date: 2026-05-07
Depends on: S2-R2-C4-B (sparkcrm_bihistory_fixture — PASS)

---

## Goal

Generalize parser/typechecker for `BiHistory[T]` and `bihistory_at` with full
axis validation. Parser was already correct after S2-R2-C2-B (structured TypeRef).
All work landed in the TypeChecker.

---

## Parser — No Change Required

After `history-type-parser-acceptance-v0` (S2-R2-C2-B), the parser already
produces correct structured output for `BiHistory[T]`:

```text
input:  read avail_history: BiHistory[String]
output: { kind:"type_ref", name:"BiHistory", params:[{kind:"type_ref",name:"String",params:[]}] }

input:  compute avail_at = bihistory_at(avail_history, valid_time, transaction_time)
output: { kind:"call", fn:"bihistory_at", args:[ref, ref, ref] }
```

No parser changes were needed for this card.

---

## TypeChecker Changes

### 1. `read` node handling

`typecheck_contract` previously handled only `input / compute / output`.
`read` nodes (History[T] / BiHistory[T]) were silently skipped, leaving the
history symbol undefined when `compute` tried to reference it.

```ruby
when "read"
  type = type_ir(decl.fetch("type_annotation"))
  symbol_types[decl.fetch("name")] = type
  typed_decls << typed_decl(decl, type, nil, [])
```

### 2. `call` expression handler

`infer_expr` previously fell through to `OOF-TY0` for any `call` expression.
A `when "call"` branch now routes to `infer_call`.

### 3. `infer_call` — history_at and bihistory_at axis rules

```text
history_at(history, as_of):
  OOF-H1: args.length < 2 (missing as_of)
  OOF-BT1: as_of type != DateTime
  result: Option[inner T of History[T]]

bihistory_at(history, vt, tt):
  OOF-BT2: args.length < 2 (missing vt)
  OOF-BT3: args.length < 3 (missing tt)
  OOF-BT4: vt or tt type != DateTime
  result: Option[inner T of BiHistory[T]]
```

### 4. `option_type_from` helper

Extracts `Option[inner]` from a `History[inner]` or `BiHistory[inner]` TypeRef.
Reads `params[0].name` from the structured TypeRef node (enabled by S2-R2-C2-B).

### 5. `type_ir` — generic TypeRef preservation

`type_ir` previously always stripped params:
```ruby
def type_ir(name) = { "name" => normalize_type(name), "params" => [] }
```
Now preserves structured `params` from a Hash TypeRef input:
```ruby
def type_ir(annotation)
  return annotation.dup if annotation.is_a?(Hash) && annotation.key?("name")
  name = annotation.is_a?(Hash) ? annotation.fetch("name","Unknown") : annotation.to_s
  params = annotation.is_a?(Hash) ? annotation.fetch("params",[]).map { |p| type_ir(p) } : []
  { "name" => name, "params" => params }
end
```

### 6. `blocking_rule_present?` expanded

```ruby
%w[OOF-P1 OOF-CE4 OOF-OS2 OOF-H1 OOF-BT2 OOF-BT3 OOF-BT4]
```

---

## New Classified Fixtures

4 new classified JSON fixtures created in `typechecker_proof/classified/`:

```text
bihistory_valid.classified.json               -> accepted (OOF-BT2..4 all absent)
negative_bihistory_missing_vt.classified.json -> OOF-BT2 (args.length < 2)
negative_bihistory_missing_tt.classified.json -> OOF-BT3 (args.length < 3)
negative_bihistory_wrong_axis_type.classified.json -> OOF-BT4 (vt is String not DateTime)
```

---

## New TypeChecker Proof Checks (15 total, was 11)

```text
typed.bihistory_valid: ok
negative.bihistory_missing_vt: ok
negative.bihistory_missing_tt: ok
negative.bihistory_wrong_axis_type: ok
```

---

## Verification Results

```text
ruby typechecker_proof/typechecker_proof.rb
  -> PASS typechecker_proof (15/15 checks)

ruby sparkcrm_bihistory_fixture/sparkcrm_bihistory_fixture.rb
  -> PASS sparkcrm_bihistory_fixture (13 checks)

ruby history_type_proof/history_type_proof.rb
  -> PASS history_type_proof (14 checks)

ruby stage1_close_candidate/stage1_close_candidate.rb
  -> PASS stage1_close_candidate

bundle exec rspec spec/igniter/parser_acceptance_spec.rb
  -> 61 examples, 0 failures
```

---

## Handoff

```text
[Igniter-Lang Compiler/Grammar Expert]
Card: S2-R3-C1-P
Track: igniter-lang/bihistory-parser-typechecker-axes-v0
Status: done

[D] Decisions:
- Parser required no changes (structured TypeRef already correct from S2-R2-C2-B).
- TypeChecker adds: read node handler, call expression handler, infer_call,
  option_type_from, expanded type_ir (params-preserving), expanded blocking_rule_present?.
- OOF-BT2/BT3/BT4 are TypeChecker-owned arity + axis type checks.
- OOF-H1 also validated inside infer_call for history_at.
- 4 new classified fixtures created directly (not via live classifier).
- typechecker_proof.rb now has 15 checks (was 11).

[S] Signals:
- BiHistory[T] parser acceptance + typechecker axis validation is now proven.
- history_at OOF-H1 and bihistory_at OOF-BT2/BT3/BT4 all confirmed.
- type_ir now preserves generic params — History/BiHistory/Option/Collection
  types all roundtrip correctly through type_ir.

[T] Tests:
- typechecker_proof.rb: PASS (15/15)
- sparkcrm_bihistory_fixture.rb: PASS
- history_type_proof.rb: PASS
- stage1_close_candidate.rb: PASS
- parser_acceptance_spec.rb: 61 examples, 0 failures

[R] Research Agent: TypeChecker infer_call is proof-local.
  Production extraction should lift it into TypecheckerPass::CallInferrer
  when package boundary is drawn.

[Files] Changed:
- igniter-lang/experiments/typechecker_proof/typechecker_proof.rb [MODIFIED]
- igniter-lang/experiments/typechecker_proof/classified/bihistory_valid.classified.json [NEW]
- igniter-lang/experiments/typechecker_proof/classified/negative_bihistory_missing_vt.classified.json [NEW]
- igniter-lang/experiments/typechecker_proof/classified/negative_bihistory_missing_tt.classified.json [NEW]
- igniter-lang/experiments/typechecker_proof/classified/negative_bihistory_wrong_axis_type.classified.json [NEW]
- igniter-lang/docs/tracks/bihistory-parser-typechecker-axes-v0.md [NEW]
- igniter-lang/docs/agent-motion.md [updated]

[Next]:
- S2-R3-C2-P (parallel): runtime extraction slice (temporal_access_node evaluation).
- S2-R4: SemanticIR emitter generalization for History/BiHistory temporal nodes.
```
