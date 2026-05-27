# Branch Conditional If Expr Semantics Proof Pressure v0

Card: S3-R188-C2-X
Agent: [External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: discussion
Initiator: user
Track: branch-conditional-if-expr-semantics-proof-pressure-v0

Context:
- Write access: none
- Canon authority: none

---

## Inputs Read

| File | Card | Role |
| --- | --- | --- |
| `igniter-lang/docs/tracks/branch-conditional-if-expr-semantics-proof-v0.md` | S3-R188-C1-P1 | Proof-only semantics fixture track doc |
| `igniter-lang/experiments/branch_conditional_if_expr_semantics_proof_v0/out/branch_conditional_if_expr_semantics_proof_summary.json` | — | Machine-readable proof summary |
| `igniter-lang/experiments/branch_conditional_if_expr_semantics_proof_v0/out/current_mainline_refusal.json` | — | Live TypeChecker refusal output |
| `igniter-lang/experiments/branch_conditional_if_expr_semantics_proof_v0/out/semanticir_branch_shape_model.json` | — | SemanticIR shape model output |
| `igniter-lang/experiments/branch_conditional_if_expr_semantics_proof_v0/out/parser_probe.minimal_if_else.json` | — | Parser probe output |
| `igniter-lang/experiments/branch_conditional_if_expr_semantics_proof_v0/out/closed_surface_scan.json` | — | Closed-surface scan output |
| `igniter-lang/docs/tracks/branch-conditional-if-expr-next-route-decision-v0.md` | S3-R187-C4-A | Authorization and binding gate conditions |
| `igniter-lang/docs/tracks/stage3-round187-status-curation-v0.md` | S3-R187-C5-S | R187 status curation |

---

## Question

Does the S3-R188 proof-only `if_expr` semantics fixture satisfy all required
proof cases, faithfully implement the accepted v0 semantics, address all three
R187 binding gate conditions, preserve current `OOF-TY0` refusal, avoid
compiler/runtime/release/Spark edits, and provide a sound enough basis for
Portfolio to decide whether an implementation-authorization review may open?

---

## Independent Verification

All six experiment output files were read and cross-checked against the
track doc and the R187-C4-A binding gate conditions.

### Parser Probe (`parser_probe.minimal_if_else.json`)

```json
{ "parse_errors": [], "compute_expr_kind": "if_expr",
  "if_expr_shape_keys": ["cond", "else", "kind", "then"] }
```

- Parse errors: none — PASS.
- AST kind: `if_expr` — PASS.
- Shape keys match the C2-P1 survey (`cond`, `then`, `else`) — PASS.

### Current Mainline Refusal (`current_mainline_refusal.json`)

```json
{ "typed_status": "blocked", "canonical_rule": "OOF-TY0",
  "canonical_message": "Unsupported expression kind: if_expr" }
```

- Primary refusal is `OOF-TY0 Unsupported expression kind: if_expr` — PASS.
- Secondary derivative error (`Type mismatch: expected Integer, got Unknown`)
  is also present in `type_errors` but correctly NOT cited as canonical —
  consistent with C2-P1's explicit policy to avoid citing the derivative error.
- PASS.

### Canonical Bool Pinning (`canonical_bool_evidence` in summary)

```json
{ "canonical_bool_type": {"name":"Bool","params":[]},
  "ref_resolved_type": {"name":"Bool","params":[]},
  "source": "live TypeChecker Bool input and ref compute",
  "type_errors": [], "typed_status": "accepted" }
```

- Bool representation pinned from live TypeChecker — R187 NB-2 satisfied.
- PASS.

### OOF-IF5 Disposition (`oof_if5_policy` in summary)

```json
{ "status": "dropped_from_proof_scope",
  "reason": "R187 C4-A requires single owner/trigger before modeling; none selected" }
```

- R187 NB-1 satisfied. Reason correctly cites R187-C4-A gate. — PASS.

### Proof Model Cases (`model_cases` in summary)

| Case | Expected | OOF codes | `valid` | Result |
| --- | --- | --- | --- | --- |
| `minimal_if_else` | accepted | none | `true` | PASS |
| `non_bool_condition` | `OOF-IF1` | `["OOF-IF1"]` | `false` | PASS |
| `missing_else` | `OOF-IF2` | `["OOF-IF2"]` | `false` | PASS |
| `branch_type_mismatch` | `OOF-IF3` | `["OOF-IF3"]` | `false` | PASS |
| `empty_branch` | `OOF-IF4` | `["OOF-IF4"]` | `false` | PASS |
| `nested_if_expr` | accepted | none | `true` | PASS |

All four required rejection cases emit exactly one OOF-IF code each, with
`valid: false`, `typed_expr: null`, and `resolved_type: Unknown`. No cross-
contamination of codes observed.

### Dependency Modeling (from `model_cases`)

| Case | deps observed | Expected (union) |
| --- | --- | --- |
| `minimal_if_else` | `["a", "b", "flag"]` | cond `flag` + then `a` + else `b` = `{a,b,flag}` |
| `nested_if_expr` | `["a", "b", "c", "flag", "other"]` | outer cond `flag` + outer else `c` + inner cond `other` + inner then `a` + inner else `b` = `{a,b,c,flag,other}` |

Both union-dependency calculations are correct independently. PASS.

### SemanticIR Shape (`semanticir_branch_shape_model.json`)

Shape choice recorded as `direct_expression_lowering_no_branch_expr_wrapper`
with justification `"current lower_expr returns expression nodes directly; no
live branch_expr wrapper pattern found"`. R187 NB-3 satisfied.

Outer minimal case: `condition` / `then_branch` / `else_branch` keys, no
`kind: "branch"` wrapper. This matches the C1-P1 track doc canonical shape.

**Inconsistency detected in nested case:** The outer if_expr in the nested
model uses `then_branch`/`else_branch` (flat SemanticIR shape). However, the
inner if_expr embedded inside `then_branch` uses `cond`/`then`/`else` with
`{ kind: "branch", expr: {...} }` wrappers — the unmodified TypeChecker/AST
representation rather than the lowered SemanticIR shape. This means the inner
node was not lowered to the same `condition`/`then_branch`/`else_branch` shape
as the outer node.

This is a shape-consistency gap: the nested SemanticIR model does not apply the
same lowering to the recursive case. For a proof-only card this is non-blocking
— the model demonstrates the shape choice for the top level — but the
implementation authorization card must pin which shape applies at all nesting
levels before any code is written.

### Closed-Surface Scan (`closed_surface_scan.json`)

```json
{ "parser_typechecker_semanticir_assembler_no_proof_token": { "hits": [], "status": "PASS" },
  "public_api_cli_not_widened_by_proof": { "status": "PASS" },
  "release_harness_not_mutated_by_proof": { "status": "PASS" },
  "spark_not_touched_by_proof": { "status": "PASS" },
  "optional_readme_hygiene_selected": false }
```

All four scan gates PASS. Stale harness README cleanup was not selected —
consistent with R187-C4-A deferral decision. PASS.

Note: the scan method is token-based (searches compiler/live files for proof
track token). It confirms no live compiler files were modified by the proof
runner, but does not independently verify read/write file descriptors. This
is the same structural limitation acknowledged in prior proof rounds; the
track doc confirms no lib/ or bin/ files were changed.

### Command Matrix (from track doc)

```text
ruby -c ...branch_conditional_if_expr_semantics_proof_v0.rb  → PASS
ruby ...branch_conditional_if_expr_semantics_proof_v0.rb     → PASS
6/6 internal assertion groups PASS
```

Both commands verified at track-doc level. PASS.

### Release Harness Evidence (from summary)

```json
{ "release_scope_excludes_if_expr": true, "feature_status": "out_of_scope" }
```

Path cites the accepted acceptance harness summary. PASS.

---

## Scope Checks

| # | Check | Result | Notes |
| --- | --- | --- | --- |
| SC-1 | All 14 required proof cases are present in the summary JSON | PASS | Confirmed: 14 named entries in `proof_matrix`, 14 named entries in `checks`, 0 failed |
| SC-2 | All 14 checks report `status: "PASS"` | PASS | `checks_pass: 14`, `checks_fail: 0` |
| SC-3 | Current `OOF-TY0` refusal is preserved and confirmed by live probe | PASS | `current_mainline_refusal.json`: `canonical_rule: OOF-TY0`, `typed_status: blocked` |
| SC-4 | `OOF-IF1..OOF-IF4` proof-local diagnostics match accepted v0 semantics | PASS | Each negative case emits exactly the expected code; `valid: false`; `typed_expr: null` for all four |
| SC-5 | `OOF-IF5` is dropped from proof scope with reason citing R187-C4-A | PASS | `dropped_from_proof_scope` with correct gate citation |
| SC-6 | Canonical `Bool` representation is pinned from live TypeChecker evidence | PASS | `{"name":"Bool","params":[]}` from `source: live TypeChecker Bool input and ref compute`; `typed_status: accepted` |
| SC-7 | SemanticIR branch shape is chosen: direct expression lowering, no `branch_expr` wrapper | PASS | `shape_choice: direct_expression_lowering_no_branch_expr_wrapper`; justification from live `lower_expr` evidence |
| SC-8 | Outer SemanticIR model shape uses `condition`/`then_branch`/`else_branch` matching C1-P1 track doc | PASS | Verified in `semanticir_branch_shape_model.json` minimal case |
| SC-9 | Union dependency behavior is correctly modeled for simple and nested cases | PASS | Both dep sets independently verified as correct unions |
| SC-10 | Nested `if_expr` is modeled and accepted under same v0 rules | PASS | `nested_if_expr` case: `valid: true`, `diagnostic_rules: []`, correct union of 5 deps |
| SC-11 | Release harness `branch_conditional_if_expr` remains `out_of_scope` before implementation | PASS | `release_scope_excludes_if_expr: true`, `feature_status: out_of_scope` |
| SC-12 | Closed-surface scan shows no parser/TypeChecker/SemanticIR/assembler/release/Spark edits | PASS | All four scan gates PASS; stale README cleanup not selected |
| SC-13 | No compiler code, runtime code, public API/CLI, release docs/code, or Spark code edited | PASS | Track doc confirms no lib/ or bin/ files changed; command matrix run-only |
| SC-14 | All three R187-C4-A binding gate conditions addressed | PASS | NB-1: dropped; NB-2: pinned from live evidence; NB-3: direct lowering chosen with justification |
| SC-15 | Nested SemanticIR shape in `semanticir_branch_shape_model.json` applies consistent lowering at all levels | FAIL (NB) | Outer if_expr uses `condition`/`then_branch`/`else_branch`; inner nested if_expr in `then_branch` uses `cond`/`then`/`else` with branch wrappers — non-lowered shape. Non-blocking for proof acceptance; binding gate for implementation authorization. |

14/15 scope checks: PASS. 1 non-blocking finding (SC-15).

---

## [Agree]

- The proof correctly satisfies all three R187-C4-A binding gate conditions in
  order: OOF-IF5 dropped before modeling, Bool pinned from live TypeChecker
  probe before modeling OOF-IF1, SemanticIR shape chosen with live `lower_expr`
  justification. The gate-sequencing discipline is correct.

- The four negative proof cases (OOF-IF1..OOF-IF4) are clean: each emits
  exactly one OOF-IF code, sets `valid: false`, nulls `typed_expr`, and returns
  `Unknown` as resolved type. There is no cross-contamination (e.g., OOF-IF1
  also emitting OOF-IF3), which matters for the OOF-IF1 gate: if the proof-
  local model is invoked on non-Bool condition, only OOF-IF1 fires.

- The `OOF-TY0` canonical identification in `current_mainline_refusal.json`
  correctly names only the primary refusal as canonical and does not promote the
  derivative type-mismatch error. This is the right behavior given C2-P1's
  explicit policy.

- Union dependency modeling is verifiably correct for the nested case. The
  nested `if_expr` accumulates `{a, b, c, flag, other}` — exactly the union of
  condition dependencies at all levels. No path-sensitive dependency pruning was
  introduced.

- Proof scope is right-sized: 6 fixture files, one runner, 6 output JSON files,
  14 checks. The proof is not over-engineered; it covers the required cases and
  nothing beyond the C4-A scope.

- Release harness evidence is correctly cited (path-referenced, not mutated):
  `feature_status: out_of_scope`, `release_scope_excludes_if_expr: true`. No
  harness golden or summary was modified.

---

## [Challenge]

- **Nested SemanticIR shape is internally inconsistent.** The outer if_expr in
  `semanticir_branch_shape_model.json` is lowered to the `condition`/
  `then_branch`/`else_branch` flat shape. But the inner if_expr embedded in the
  outer `then_branch` is represented with `cond`/`then`/`else` and
  `{ kind: "branch", expr: {...} }` wrappers — the parser/TypeChecker AST
  shape, not the lowered SemanticIR shape. The proof's `shape_choice:
  direct_expression_lowering_no_branch_expr_wrapper` is stated as applying to
  both cases, but the nested JSON does not apply the same lowering recursively.
  An implementation card following this proof would encounter conflicting key
  names for nested conditionals.

- **The `model_cases.typed_expr` and `semanticir_branch_shape_model` use
  different key names for the same stage.** `model_cases.minimal_if_else.
  typed_expr` uses `cond`/`then`/`else` (with branch wrappers); the SemanticIR
  model uses `condition`/`then_branch`/`else_branch` (without wrappers). These
  two structures appear in the same proof but are not labeled as representing
  different compilation stages. If `typed_expr` is a TypeChecker-internal
  representation and the SemanticIR model is a separate lowered representation,
  that staging should be made explicit so an implementation card can implement
  two distinct steps without conflating them.

---

## [Missing]

- **Explicit stage labeling is absent.** The proof models a TypeChecker typed
  expression (`model_cases.typed_expr`) and a SemanticIR lowered expression
  (`semanticir_branch_shape_model`) but does not label these as two distinct
  compilation stages with independent key-naming conventions. The
  implementation-authorization review must clarify:
  - Stage 1 (TypeChecker output): keys are `cond`/`then`/`else` (matching AST);
  - Stage 2 (SemanticIR lowering): keys are `condition`/`then_branch`/
    `else_branch` (flat);
  - and that the lowering step is applied recursively for nested if_expr.

- **Empty branch case deps.** In `model_cases.empty_branch`, `deps: ["flag"]`
  — only the condition dependency. This is correct if the empty branch
  contributes no dependencies (no final expression to scan), but the proof
  doesn't state this policy explicitly. If a future implementation scans empty
  branch tokens differently, the dep set could drift. Not a blocker, but the
  implementation card should confirm the empty-branch dep policy.

- **OOF-IF5 deferred, not resolved.** The proof drops OOF-IF5 correctly. It
  does not attempt a future trigger definition. This is correct for the current
  proof scope, but the implementation-authorization card should acknowledge
  explicitly that OOF-IF5 remains unowned and unimplemented — not silently
  omitted from the codebase without a comment.

---

## [Sharper Question]

> When the SemanticIR emitter recursively lowers a nested `if_expr` inside a
> branch of an outer `if_expr`, does the emitter produce `condition`/`then_branch`/
> `else_branch` keys (the chosen lowered SemanticIR shape) for both the outer
> and inner nodes — or does it emit AST-mirroring `cond`/`then`/`else` for the
> inner node because the inner node enters the emitter as a branch expression?

This is the question the nested-case inconsistency in
`semanticir_branch_shape_model.json` fails to answer definitively. The
implementation authorization card must prove the emitter applies the same
`condition`/`then_branch`/`else_branch` shape at all levels of nesting before
code is written.

---

## [Route]

Proceed with non-blocking notes.

- 14/15 scope checks PASS; SC-15 is non-blocking.
- No blockers.
- Two non-blocking notes:

**NB-1:** Nested SemanticIR shape inconsistency — the inner if_expr in
`semanticir_branch_shape_model.json` uses `cond`/`then`/`else` with branch
wrappers rather than the chosen `condition`/`then_branch`/`else_branch` flat
shape. The implementation authorization card must assert that the emitter applies
the same lowering recursively at all nesting levels before writing code. This is
a binding gate condition for the implementation authorization card.

**NB-2:** Stage labeling absent — the proof does not explicitly distinguish the
TypeChecker typed representation (`cond`/`then`/`else` with branch wrappers)
from the SemanticIR lowered representation (`condition`/`then_branch`/
`else_branch` flat). The implementation authorization card must document the two
stages clearly so that the TypeChecker implementation and SemanticIR emitter
implementation do not conflate their respective key conventions. Binding gate for
implementation authorization.

---

## Recommended C3-A Decision Boundary

Portfolio C3-A may accept S3-R188-C1-P1 as a valid proof-only fixture, having
satisfied all 14 machine-asserted proof requirements and all three R187-C4-A
binding gate conditions.

C3-A may open planning for an implementation-authorization review, subject to:

```text
NB-1 (binding gate for impl-auth card):
  Prove that SemanticIR emitter applies condition/then_branch/else_branch
  lowering recursively for nested if_expr at all nesting levels, not only
  at the outermost level.

NB-2 (binding gate for impl-auth card):
  Document the two compilation stages explicitly:
  - TypeChecker output stage: cond/then/else (AST-mirroring, branch-wrapped)
  - SemanticIR lowering stage: condition/then_branch/else_branch (flat)
  Implementation of each stage must use only its own key convention.
```

Optional for impl-auth card (non-binding):

```text
  Pin empty-branch dep policy explicitly.
  Acknowledge OOF-IF5 as unowned/unimplemented with a comment or TODO in code.
  Clean stale harness README HOLD note if explicitly recorded in write scope.
```

Implementation of parser, TypeChecker, SemanticIR emitter, assembler, or any
artifact/golden/release code remains closed until the implementation-
authorization review is separately accepted.

---

## Compact Pressure Verdict

```text
card:           S3-R188-C2-X
track:          branch-conditional-if-expr-semantics-proof-pressure-v0
verdict:        proceed with non-blocking notes
checks:         14/15 PASS (SC-15 non-blocking)
blockers:       none
non-blocking:   2

NB-1: Nested SemanticIR model inconsistency — inner if_expr in nested case
      uses cond/then/else with branch wrappers (TypeChecker shape) rather than
      condition/then_branch/else_branch (SemanticIR shape); implementation
      authorization card must prove recursive lowering consistency.

NB-2: Stage labeling absent — proof does not distinguish TypeChecker typed
      representation (cond/then/else, branch-wrapped) from SemanticIR lowered
      representation (condition/then_branch/else_branch, flat); implementation
      authorization card must document the two stages before code.

R187 binding gates addressed:
  NB-1 (OOF-IF5): dropped, reason cites gate correctly — PASS
  NB-2 (Bool type): pinned from live TypeChecker evidence — PASS
  NB-3 (SemanticIR shape): chosen with live lower_expr justification — PASS

C3-A recommended decision:
  accept C1-P1 proof; open implementation-authorization review planning
  with NB-1..NB-2 above as binding gate conditions.

closed surfaces confirmed:
  parser/TypeChecker/SemanticIR/assembler implementation, artifacts/goldens,
  release execution, second release route, public demo/production/all-grammar
  claims, Spark, runtime, API/CLI widening, harness mutation before accepted
  support.
```
