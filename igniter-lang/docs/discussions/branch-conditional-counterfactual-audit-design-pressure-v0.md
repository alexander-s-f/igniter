# Branch Conditional Counterfactual Audit Design Pressure v0

Card: S3-R204-C3-X  
Agent: `[Igniter-Lang External Pressure Reviewer]`  
Role: `external-pressure-reviewer`  
Mode: discussion  
Initiator: user  
Track: `branch-conditional-counterfactual-audit-design-pressure-v0`

---

## Question

Do the S3-R204-C1-D counterfactual-audit / branch-intention boundary design and
the S3-R204-C2-P1 assumptions capsule fit analysis correctly contain non-selected
branch evaluation, authority creep, and runtime/public-claim leakage? Is the
`branch_intention` vocabulary precise enough that a future implementer cannot
read execution authority into it? Are assumptions correctly scoped as premise
capsule only, with no hidden PROP-032 grammar extension? Is the next route
narrow and proof-local only?

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-design-boundary-v0.md` (C1-D)
- `igniter-lang/docs/tracks/branch-conditional-assumptions-capsule-fit-analysis-v0.md` (C2-P1)
- `igniter-lang/docs/tracks/stage3-round203-status-curation-v0.md` (R203 status)
- `igniter-lang/docs/proposals/PROP-032-assumptions-block-v0.md`
- `igniter-lang/docs/discussions/branch-conditional-counterfactual-audit-future-pressure-v0.md`

---

## Scope-Check Matrix

| ID | Check | Verdict |
|----|-------|---------|
| SC-1 | No non-selected branch evaluation proposed | PASS |
| SC-2 | No eager latent branch execution proposed | PASS |
| SC-3 | No runtime/evaluator/RuntimeSmoke change authorized | PASS |
| SC-4 | No dependency/cache authority opened | PASS |
| SC-5 | No report/result/API/CLI/public surface widened | PASS |
| SC-6 | No public runtime/counterfactual support claim made | PASS |
| SC-7 | Assumptions not overloaded beyond PROP-032 without explicit amendment route | PASS |
| SC-8 | Next route is proof-local/design-only and narrow | PASS |

**Result: 8/8 PASS — no blockers.**

---

## Detailed Findings

### SC-1 / SC-2: Non-Selected Branch Evaluation and Eager Execution

C1-D is unambiguous: "non-selected branch evaluation remains forbidden." The
"Runtime Must Not" section covers the full surface:

- no `evaluate` call on a latent branch;
- no `external_evaluator` invocation for a non-selected branch;
- no `tbackend_read` from a latent branch;
- no effects, no output value, no runtime failure reporting, no cache update from
  a latent branch.

The future pressure doc's Level 2 (counterfactual dry-run) is not opened by
either card. C1-D explicitly requires that any future dry-run "must be explicit,
isolated, effect-free, and separately authorized." The firewall is binding.

The design principle "Runtime is lazy. Audit is aware." is correctly
operationalized: static inspection of SemanticIR shape is the authorized
mechanism, not any form of execution.

### SC-3: Runtime / Evaluator / RuntimeSmoke Closure

C1-D's closed-surfaces list explicitly names:
- code implementation;
- parser/grammar changes;
- runtime/evaluator changes;
- RuntimeSmoke changes;
- proof RuntimeMachine changes;
- CompilerOrchestrator, CompilerResult, CompilationReport.

C2-P1 says "Implementation, grammar/spec mutation, runtime changes, RuntimeSmoke
changes, report/receipt shape changes, dependency/cache authority, public API/CLI
widening, release claims, and production behavior should remain held."

The existing lazy behavior in `SemanticIRExpressionEvaluator` and proof
RuntimeMachine is explicitly required to remain unchanged. No tension with the
R203 accepted baseline.

### SC-4: Dependency / Cache Authority

C1-D's candidate static record shape carries an explicit authority block:

```json
"authority": {
  "dependency_authority": false,
  "cache_authority": false,
  "runtime_readiness_authority": false,
  "public_claim": false
}
```

The prose reinforces this: static mentions of contracts/capabilities/refs/deps
"must carry `dependency_authority: false`, `cache_authority: false`, and
`runtime_readiness_authority: false`." C2-P1's overload risks section
explicitly calls out "using `assumption_refs` to create path-sensitive
dependency/cache authority" as a forbidden pattern.

Both cards close the dependency/cache surface through vocabulary and through
explicit authority fields. No gap visible.

### SC-5: Report / Result / API / CLI / Public Surface

C1-D explicitly defers all of: CompilerOrchestrator, CompilerResult,
CompilationReport, Diagnostics, public API/CLI widening, loader/report or
CompatibilityReport behavior, and public demo/release/stable/production claims.

C2-P1's illustrative proof metadata is labeled "proof metadata only. It does not
define syntax, SemanticIR, report, receipt, CLI, or public API shape." This
disclaimer is explicit and comprehensive.

### SC-6: Public Runtime / Counterfactual Support Claim

C1-D answers directly: "Is counterfactual audit a public feature now? No. It
remains design/proof pressure only." The R203 maximum accepted claim boundary
is not widened. No claim beyond proof-context evidence is asserted.

### SC-7: PROP-032 Boundary and Assumptions Overload

The most technically sensitive check. Three sub-checks:

**Sub-7a: `uses assumptions` scope preserved.**
Current PROP-032 attaches `uses assumptions NAME` to the contract body. C2-P1
explicitly establishes that branch-level attachment would be "a grammar and
semantics extension" and is not authorized. The proof-local route must use
"assumptions-shaped proof metadata, not PROP-032 grammar extension." This is
correct and clearly labeled.

**Sub-7b: `assumption_refs` field name collision.**
C1-D's candidate static record shape uses `assumption_refs` as a field name
inside branch records:
```json
{ "assumption_refs": ["threshold_policy"] }
```
PROP-032 also uses `assumption_refs` in the evidence chain (classified contract,
SemanticIR `contract_ir`, receipt). Without an explicit disambiguation statement
in the proof record itself, a future reader could conflate proof-local branch
metadata `assumption_refs` with PROP-032 receipt `assumption_refs`. C1-D carries
"This shape is not canon. It is a proof-local candidate for a future concept
proof only." — this is the right intent, but the field name collision is a
precision risk. C4-A should require that the concept proof explicitly labels
proof-local `assumption_refs` as distinct from PROP-032 receipt fields (e.g., in
the summary schema header or shape documentation).

**Sub-7c: `strength` overload.**
C2-P1 correctly identifies and forbids treating `strength` as branch probability
or runtime branch confidence. This is explicitly named in the overload risks
section. The design does not use `strength` in branch-intention shapes; it
appears only as a PROP-032 field on the assumption itself, not on the branch
record.

**Sub-7d: Amendment route.**
C2-P1 establishes: "A PROP-032 amendment is NOT required before a proof-local
concept route." This correctly separates proof-local metadata use from grammar
change. The amendment route (if ever needed for branch-level `uses assumptions`
syntax) remains an explicit future gate, not a silent consequence of the proof
route.

Assumptions are accepted as premise capsule only, not as the whole
branch-intention surface. SemanticIR structure remains the native structural
source. This two-dimension split is sound.

### SC-8: Narrowness of Next Route

C1-D's recommended next route (`branch-conditional-counterfactual-audit-concept-proof-v0`)
has these constraints:

- no `lib/` edits;
- no parser/grammar edits;
- no RuntimeSmoke/evaluator/proof RuntimeMachine edits;
- no release/public/Spark/API/CLI changes;
- no runtime dry-run;
- no latent branch evaluation;
- all records must be proof-local and explanatory-only.

The proof matrix (BIA-1..BIA-10) is correspondingly narrow: structural
extraction, static type facts, non-evaluation guarantee, and closed-surface
verification. No runtime execution checks are in the matrix.

---

## Vocabulary Precision Analysis

C1-D introduces a branch-intention vocabulary. Examining each term for
execution-authority risk:

| Term | Risk assessment |
|------|----------------|
| `branch_intention` | Defined as "static explanation record" — no execution implied |
| `actual_branch` | The selected branch; runtime evidence available because it ran — correct |
| `latent_branch` | The non-selected, non-evaluated branch — name is precise |
| `branch_role` | `actual` or `latent` — binary enum, no authority |
| `branch_label` | `then` or `else` — structural label, no authority |
| `condition_observation` | "Runtime observation of condition value, if available from actual execution proof" — correctly qualified to actual-path evidence |
| `static_branch_metadata` | "Compile-time/IR-derived information" — no execution implied |
| `intention_source` | `semanticir_static`, `typed_static`, `assumption_ref`, `proof_summary` — all retrospective/static |
| `explanatory_only` | Explicit non-authority marker |
| `non_execution_guarantee` | Positive assertion of non-execution — good |

One precision point: `intention_source` includes "or future source" as an open
slot. The Static Intention Source Candidates table correctly labels `runtime trace`
as "Actual-path evidence only; not latent execution," which closes the most
dangerous future misread. C4-A should note that any addition of a new
`intention_source` value (especially one derived from execution) requires explicit
authorization.

The vocabulary correctly avoids: `would_result`, `would_output`, `would_fail`.
C1-D explicitly calls out these terms as forbidden for v0 static branch intention.

---

## Counterfactual Dry-Run Firewall

The three levels (from the future pressure doc) are correctly handled:

| Level | Status after R204 |
|-------|-------------------|
| Level 1 — Static Branch Audit | Design accepted; proof-local concept route may be opened |
| Level 2 — Counterfactual Dry Run | Held; requires explicit, isolated, effect-free, separately authorized gate |
| Level 3 — Comparison Report | Held; not discussed in these cards |

The promotion path from Level 1 to Level 2 cannot happen silently: C1-D requires
separate authorization. No vocabulary in either card creates a gradient toward
Level 2 that a future card could claim as a natural extension without re-authorization.

---

## Non-Blocking Notes

**NB-1 (precision — concept proof constraint):** The candidate static record
shape in C1-D uses `assumption_refs` as a field name inside branch records. This
name is shared with PROP-032's evidence-chain field. C1-D labels the shape as
"not canon" and "proof-local candidate only," but the proof route implementation
should additionally annotate this field at the schema header level to distinguish
proof-local branch descriptors from PROP-032 receipt fields. Suggested: the
concept proof summary schema should carry a header key such as:
```json
"proof_metadata_disclaimer": "assumption_refs here are proof-local branch
  premise labels, not PROP-032 receipt assumption_refs"
```
C4-A may require this as a condition of the proof route.

**NB-2 (future-drift risk — informational):** Both cards use the phrase
"assumptions-shaped proof metadata." This is correctly bounded today. The risk
is that repeated proof-local use of PROP-032-shaped metadata structures could
create gravity toward treating them as de facto PROP-032 branch extensions. C4-A
should record explicitly that proof-local use of assumptions-shaped descriptors
does not grant canonical PROP-032 status, does not constitute a grammar
extension, and cannot be promoted to canonical shape without a separate PROP or
PROP-032 amendment decision.

**NB-3 (implementation note — informational):** BIA-6 ("Non-selected branch with
would-fail kind: recorded structurally, not executed, no runtime failure
produced") is architecturally sound but subtly demanding: the concept proof
would need to derive what the latent branch "would require" purely from static
TypeChecker/SemanticIR knowledge, not from evaluation. The proof must not
evaluate the latent branch even to confirm it would fail. This is a correct
design constraint, not a blocker, but the concept proof route authorization
should make it explicit.

---

## Verdict

```text
proceed — 8/8 PASS, no blockers, 3 non-blocking notes
```

The counterfactual-audit / branch-intention boundary is sound. The "Runtime is
lazy. Audit is aware." principle is correctly operationalized. No non-selected
branch evaluation, no eager latent execution, no runtime change, no
dependency/cache authority, no PROP-032 grammar extension, and no public claim
is proposed or implied. The assumptions fit analysis correctly scopes assumptions
as premise capsule only. The vocabulary is sufficiently precise. The next route
is narrow and proof-local.

---

## C4-A Recommendation

**Accept both S3-R204-C1-D and S3-R204-C2-P1.**

Required acceptance decisions for C4-A:

1. **Accept the branch-intention boundary design (C1-D):**
   - "Runtime is lazy. Audit is aware." is the binding design principle.
   - Actual branch may carry runtime evidence because it ran.
   - Latent branch may carry static intention metadata only; it must not be
     evaluated.
   - The authority block (`dependency_authority: false`, `cache_authority: false`,
     `runtime_readiness_authority: false`, `public_claim: false`) is required on
     all branch-intention records in the concept proof.

2. **Accept the assumptions fit analysis (C2-P1):**
   - Assumptions are the leading candidate capsule for epistemic premises inside
     branch intentions; they are not the whole branch-intention capsule.
   - PROP-032 `uses assumptions NAME` remains contract-body only; branch-level
     attachment is a future grammar extension, not authorized by these cards.
   - A proof-local concept route may use assumptions-shaped fixture metadata
     without amending PROP-032, provided the route carries explicit disclaimers.

3. **Record binding constraints on the concept proof route:**
   - No `lib/` edits.
   - No parser/grammar/TypeChecker/SemanticIR schema changes.
   - No runtime, evaluator, or RuntimeSmoke changes.
   - No latent branch evaluation under any condition.
   - No public API/CLI widening.
   - All records must carry `explanatory_only: true` and the authority block
     with all four fields false.
   - Summary must mark all records proof-local.

4. **Open the proof-local concept route** (`branch-conditional-counterfactual-audit-concept-proof-v0`)
   within the write scope specified in C1-D:
   ```text
   igniter-lang/experiments/branch_conditional_counterfactual_audit_concept_proof_v0/**
   igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-concept-proof-v0.md
   ```
   Required proof matrix: BIA-1..BIA-10 as specified in C1-D.

5. **Hold Level 2 (counterfactual dry-run):** Any promotion to dry-run evaluation
   requires a new explicit authorization — explicit isolation, effect-free
   guarantee, and separate gate. It cannot be claimed as a natural extension of
   the Level 1 concept proof.

6. **Apply NB-1 as a concept proof condition:** The proof route must annotate
   proof-local `assumption_refs` fields with a schema-level disclaimer
   distinguishing them from PROP-032 receipt `assumption_refs`.

7. **Record NB-2 as a standing policy:** Proof-local use of assumptions-shaped
   descriptors does not grant canonical PROP-032 status and cannot be promoted
   to canonical shape without a separate PROP or PROP-032 amendment decision.

8. **Record NB-3 as an implementation constraint on the concept proof:** BIA-6
   must derive latent-branch structural facts from TypeChecker/SemanticIR only;
   no execution of the latent branch is permitted even to demonstrate failure.

9. **Confirm all closed surfaces remain closed** (per C1-D list): parser,
   grammar, TypeChecker, SemanticIR emitter, compiler pipeline, assembler,
   runtime/evaluator, RuntimeSmoke, proof RuntimeMachine, CompilerOrchestrator,
   CompilerResult, CompilationReport, Diagnostics, `.igapp`/`.ilk`/manifest
   mutation outside proof-owned out/, release evidence, release commands, public
   demo/stable/production/all-grammar claims, public API/CLI, CompatibilityReport,
   dependency/cache authority, counterfactual dry-run, effect sandboxing, Spark,
   Gate 3 production authority.

---

[Agree]
- The design principle "Runtime is lazy. Audit is aware." is correctly
  operationalized through vocabulary, the "Runtime Must Not" list, and the
  authority block on all candidate shapes.
- The vocabulary (branch_intention, latent_branch, actual_branch,
  non_execution_guarantee, explanatory_only) is precise and execution-neutral.
- Assumptions are correctly scoped as premise capsule only; SemanticIR remains
  the native structural source for branch shape.
- PROP-032 grammar extension is not proposed; proof-local metadata use is cleanly
  separated.
- The Level 2 dry-run firewall is explicit and binding.
- Next route is narrow, proof-local, and constrained.

[Challenge]
- None. No blockers identified.

[Missing]
- NB-1: `assumption_refs` field name collision needs explicit schema-level
  disclaimer in the concept proof.
- NB-2: "assumptions-shaped metadata" phrase needs a standing canonical non-promotion
  policy to prevent drift.
- NB-3: BIA-6 latent-branch failure case needs an explicit no-evaluation constraint
  in the concept proof authorization.

[Sharper Question]
- If the concept proof successfully proves BIA-1..BIA-10, what is the exact gate
  for promoting Level 1 static intent evidence to a public explanation surface —
  and does that require a new C1-A or a PROP amendment or both?

[Route]
- accept — C4-A should accept C1-D and C2-P1 and open the concept proof route
  under the constraints in this recommendation.
