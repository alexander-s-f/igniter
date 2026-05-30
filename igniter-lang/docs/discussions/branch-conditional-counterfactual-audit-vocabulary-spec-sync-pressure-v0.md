# Branch Conditional Counterfactual Audit Vocabulary Spec Sync Pressure v0

Card: S3-R206-C3-X  
Agent: `[Igniter-Lang External Pressure Reviewer]`  
Role: `external-pressure-reviewer`  
Mode: discussion  
Initiator: user  
Track: `branch-conditional-counterfactual-audit-vocabulary-spec-sync-pressure-v0`

---

## Question

Do the S3-R206-C1-D vocabulary/spec-sync design and the S3-R206-C2-P1 doc-target
survey correctly prevent accidental canonization of proof-local descriptors,
PROP-032 assumptions drift, Level 2 dry-run leakage, and API/report/runtime/
public-claim widening? Is the proposed docs-sync boundary narrow and auditable,
and is any outstanding target-divergence between the two cards appropriate for
C4-A resolution rather than a blocker?

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-vocabulary-spec-sync-v0.md` (C1-D)
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-doc-target-survey-v0.md` (C2-P1)
- `igniter-lang/docs/tracks/stage3-round205-status-curation-v0.md` (R205 status)
- `igniter-lang/docs/proposals/PROP-032-assumptions-block-v0.md`

---

## Scope-Check Matrix

| ID | Check | Verdict |
|----|-------|---------|
| SC-1 | No docs/spec edit self-authorized | PASS |
| SC-2 | Proof-local descriptor not promoted to public API/report/receipt | PASS |
| SC-3 | Assumptions-shaped metadata not promoted to PROP-032 branch syntax | PASS |
| SC-4 | Level 2 dry-run remains closed | PASS |
| SC-5 | No runtime/evaluator/RuntimeSmoke changes implied | PASS |
| SC-6 | No dependency/cache authority implied | PASS |
| SC-7 | Forbidden vocabulary remains forbidden as output fields | PASS |
| SC-8 | Proposed docs-sync boundary is narrow and auditable | CONDITIONAL PASS — see NB-1 |

**Result: 7 clean PASS, 1 conditional PASS. No blockers. Verdict: proceed.**

---

## Detailed Findings

### SC-1: No Self-Authorization

Both cards correctly defer all actual docs/spec edits to a future authorized
implementation card. C1-D says "May a docs/spec edit open next? Yes, limited
to Ch5/Ch6/Ch7 plus the language-spec index; no Ch2, PROP, runtime, report,
API, or release edits" — framed as a recommendation to C4-A, not a self-grant.
C2-P1 closes with "Ask Compiler/Grammar Expert or Architect Supervisor to
choose Option A or B before any docs/spec sync implementation opens."

Neither card modifies any `docs/spec/`, `docs/language-spec.md`,
`docs/proposals/`, or any library file. The proposed write scope is clearly
conditional on C4-A authorization.

### SC-2: Proof-Local Descriptor Shape Not Promoted

C1-D explicitly keeps `if_expr_branch_intention` non-canonical:

```text
must not be described as:
SemanticIR node kind / CompilationReport field / CompilerResult field /
CompatibilityReport field / RuntimeSmoke output contract / receipt shape /
public API/CLI object / .igapp artifact schema
```

This matches the R205 acceptance, which accepted only the proof experiment and
track doc as changed files. C2-P1 reinforces with forbidden wording snippets:

```text
SemanticIR now emits branch_intention records.
CompilationReport / CompilerResult / receipt / CompatibilityReport includes
branch_intention or assumption_refs for branches.
```

Both correctly label any future canonization as requiring a "separate
schema/report/API decision" (C1-D) beyond this vocabulary sync.

### SC-3: Assumptions / PROP-032 Boundary

C1-D's assumptions relationship section is explicit:
- `uses assumptions NAME` remains contract-body syntax only.
- Branch-level `uses assumptions` remains closed.
- Proof-local `assumption_refs` in branch-intention descriptors are not canonical
  PROP-032 `assumption_refs`.
- No PROP-032 amendment is needed for this vocabulary sync.
- Future branch-level premise binding must route through a dedicated PROP-032
  amendment or new proposal.

C2-P1 lists PROP-032 as "Avoid for now" and marks it explicitly in docs-to-avoid.
Neither card proposes touching `docs/proposals/PROP-032-assumptions-block-v0.md`.

Recommended wording from C1-D for the future sync:
```text
Level 1 branch-intention metadata may refer to assumptions-shaped premise labels
in proof-local evidence, but those labels are explanatory-only and do not extend
PROP-032 grammar, receipt semantics, or contract-level `uses assumptions`.
```
This wording is sound. It does not drift PROP-032 and does not introduce
branch-level syntax.

### SC-4: Level 2 Dry-Run Firewall

C1-D has a dedicated "Level 2 Dry-Run Firewall" section. Key additions beyond
the previously established forbidden vocabulary:

The R204/R205 accepted forbidden list was:
```text
would_result, would_output, would_fail, counterfactual result,
latent runtime value, latent runtime failure
```

C1-D expands it to 13 terms, adding:
```text
counterfactual output
counterfactual failure
latent execution
latent branch execution
simulated branch result
dry-run result
branch replay
replayed branch value
```

This is a positive and appropriate tightening. It closes vocabulary channels
that could be used to re-introduce Level 2 concepts through synonyms. The
expansion is additive only — no previously forbidden term is weakened or removed.

Level 2 also requires a distinct future gate: explicit dry-run invocation source,
effect-free isolation, no mutation of actual result, no replacement of actual
output, no cache/dependency authority unless separately designed. This gating
language is appropriately demanding.

### SC-5: Runtime / Evaluator / RuntimeSmoke Closure

C1-D's closed surfaces list includes "Runtime/evaluator behavior changes" and
"RuntimeSmoke public support." The non-claim block includes "RuntimeSmoke public
support" and "public runtime/evaluator support." C2-P1 rates ch7-runtime.md as
"Very high-risk: Avoid in C4-A unless only adding a closed-surface note. It can
easily imply runtime/counterfactual support."

No runtime source files are in the proposed write scope. The vocabulary sync is
terminology-only. No `$LOADED_FEATURES` concern applies here since this is a
design/survey card with no code output.

### SC-6: Dependency / Cache Authority Closure

C1-D's non-claim block: "dependency/cache authority." C2-P1's risk matrix:
"Static latent refs become dependency/cache authority → Say: static refs are
explanatory-only and carry no dependency/cache authority." Both cards are
consistent.

The safe wording snippet provided by C2-P1 explicitly addresses this:
```text
Level 1 static audit explicitly excludes ... dependency/cache authority, and
report/result/receipt/CompatibilityReport shape changes.
```

### SC-7: Forbidden Vocabulary Enforcement

C1-D's forbidden vocabulary list (13 terms) is the binding control. All 13 terms
must not appear as positive Level 1 claims in any future docs/spec sync. They may
appear only in a forbidden-vocabulary list or Level 2+ discussion.

C2-P1's "Forbidden Wording Snippets" section independently lists the highest-risk
sentence forms. Verification: the two lists are consistent — C2-P1 covers the
conceptual risk categories; C1-D covers the specific term-level names. Together
they provide complete coverage.

---

## SC-8: Docs-Sync Boundary Narrowness — Design Tension (NB-1)

This is the most substantive finding. There is a known divergence between C1-D
and C2-P1 on the recommended target set:

**C1-D proposed write scope (if C4-A approves):**
```text
docs/language-spec.md
docs/spec/ch5-compiler-pipeline.md
docs/spec/ch6-semanticir.md
docs/spec/ch7-runtime.md
docs/tracks/branch-conditional-counterfactual-audit-vocabulary-spec-sync-v0.md
```

**C2-P1 preferred target set (Option A):**
```text
docs/current-status.md          (status-only)
docs/dev/semantic-governance-heat-map.md  (design-map)
docs/spec/README.md             (optional tiny pointer only)
docs/language-spec.md           (tiny index note only, optional)
```

C2-P1 explicitly rates:
- ch5: "Medium-risk. If authorized, add design-only note — no CompilationReport/CompilerResult shape change."
- ch6: "High-risk. Prefer avoid for first sync."
- ch7: "Very high-risk. Avoid in C4-A unless only adding a closed-surface note."

This divergence is **not a blocker** — it is a known design-authority question
appropriate for C4-A resolution. Both cards agree that:
- All proposed edits would be negative/closure notes, not additions of new
  schema or behavior.
- The edits would not change grammar, runtime, report/result, or API surfaces.
- The implementation should be split from the authority decision.

The risk C2-P1 identifies is drift gravity: once a term appears in ch6 or ch7,
future readers may treat it as having schema or runtime authority even if the
note is negative. Ch5/Ch6/Ch7 are the highest-authority spec documents in this
codebase. A closure note placed inside a chapter section carries different weight
than the same note placed in a design-map row.

**Verdict for SC-8:** The divergence is correctly surfaced and requires C4-A
resolution. C4-A must make an explicit positive selection between:
- Option A (C2-P1 preferred): status/dev-map only; no spec-body edits.
- Option B (C1-D proposed): spec-body sync with negative-only closure notes in
  ch5/ch6/ch7.
- Option B-limited: ch5 only, deferring ch6 and ch7 to a later gate.

The conditional PASS acknowledges that the boundary is auditable (both cards
describe their targets precisely), but the specific target set is not yet locked,
which is appropriate for this design-stage card.

---

## C1-D Vocabulary Acceptance Analysis

The 10 vocabulary terms proposed by C1-D for docs status:

| Term | Risk assessment |
|------|----------------|
| `branch_intention` | Safe as docs vocabulary — defined as "static explanatory record" |
| `actual_branch` | Safe — tied to observed condition, not a new runtime command |
| `latent_branch` | Safe — explicitly "inspected structurally but not evaluated" |
| `branch_role` | Safe — binary enum (`actual`/`latent`), no authority |
| `branch_label` | Safe — source-level label (`then`/`else`), no authority |
| `condition_observation` | Safe — "already-observed condition value; not a new evaluation command" |
| `static_branch_metadata` | Safe — "structural facts" qualifier is clear |
| `intention_source` | Safe — "compiler/SemanticIR structure or proof-local metadata" |
| `explanatory_only` | Safe — required boundary flag, non-authority marker |
| `non_execution_guarantee` | Safe — positive assertion of non-execution |

No term in this set implies execution, runtime value production, dependency
authority, or public API surface. All 10 are appropriate for docs/spec
vocabulary in a closure or explanation context.

The definitions are marginally tighter in C2-P1's glossary table:
C1-D defines `intention_source` as "Source of the explanation, usually
compiler/SemanticIR structure or proof-local metadata." C2-P1 defines it as
"Proof-local source for the explanation." C2-P1's tighter scoping is safer
(avoids implying future expansion of `intention_source` values). C4-A should
prefer the C2-P1 wording if the term appears in any spec-body text.

---

## Non-Blocking Notes

**NB-1 (design tension requiring C4-A decision):** C1-D proposes including
ch5/ch6/ch7 in the docs/spec sync write scope; C2-P1 prefers Option A
(status/dev-map only) and labels ch6/ch7 as high/very-high risk. This divergence
is not a blocker — both cards are correctly aligned on what the edits would
contain (negative closure notes only). C4-A must make an explicit positive
selection:

- **Option A** (C2-P1 preferred): `docs/current-status.md` and
  `docs/dev/semantic-governance-heat-map.md` as the primary targets; optional
  one-line pointer in `docs/spec/README.md` or `docs/language-spec.md`; no
  ch5/ch6/ch7 body edits.

- **Option B** (C1-D proposed): narrow ch5/ch6/ch7 sync with negative-only
  closure text; must explicitly lock wording to avoid authority drift in
  high-risk chapters.

- **Option B-limited**: ch5 only (medium-risk); defer ch6/ch7 to a later gate.

C4-A should not default to C1-D's write scope without an explicit decision.
The split (design-authority decision first, then implementation card) recommended
by C2-P1 is correct structure regardless of which option is chosen.

**NB-2 (wording precision — ch7 risk):** If C4-A chooses Option B including
ch7-runtime.md, the exact wording must be locked to a strictly negative closure
statement. C1-D's proposed ch7 edit ("add a runtime boundary note that lazy
evaluation remains the rule") is phrased as an addition rather than a closure
note. C2-P1 warns this "can easily imply runtime/counterfactual support." The
safe form would be:

```text
Level 1 branch-intention does not change runtime evaluation order, lazy
selection behavior, CompatibilityReport, receipt shape, or cache behavior.
Level 2 counterfactual dry-run is not authorized by Level 1 static audit.
```

C4-A should require that any ch7 text be strictly negative (listing what does
NOT change) with no affirmative description of Level 1 as a runtime feature.

**NB-3 (framing precision — C1-D defaults):** C1-D presents "May a docs/spec
edit open next? Yes, limited to Ch5/Ch6/Ch7 plus the language-spec index" as a
default-open position. This could be read as C4-A defaulting to authorizing all
four spec targets unless it actively restricts them. The safer framing is that
C4-A must make a positive authorization of each target. C2-P1 correctly frames
this as "Ask Architect to choose Option A or B." C4-A should treat each target
as requiring explicit positive inclusion, not default inclusion.

---

## Verdict

```text
proceed — 7/8 clean PASS, 1 conditional PASS (SC-8 design tension for C4-A)
no blockers, 3 non-blocking notes
```

Both cards correctly prevent self-authorization, proof-local descriptor
promotion, PROP-032 drift, Level 2 dry-run leakage, and public-claim widening.
The forbidden vocabulary list is expanded appropriately. The design-authority
split (C1-D designs, C2-P1 surveys risks, C4-A decides, future card implements)
is the right structure. The target-set divergence between C1-D and C2-P1 is a
known, appropriate, and correctly surfaced question for C4-A resolution.

---

## C4-A Recommendation

**Accept both S3-R206-C1-D and S3-R206-C2-P1, with explicit target-set decision.**

Required acceptance decisions for C4-A:

1. **Accept the vocabulary list** (10 terms from C1-D) as Level 1 docs
   vocabulary — terminology and boundary markers only, not object schema or
   public API surface.

2. **Accept the expanded forbidden vocabulary list** (13 terms from C1-D) as
   binding: `would_result`, `would_output`, `would_fail`, `counterfactual result`,
   `counterfactual output`, `counterfactual failure`, `latent runtime value`,
   `latent runtime failure`, `latent execution`, `latent branch execution`,
   `simulated branch result`, `dry-run result`, `branch replay`,
   `replayed branch value` — none may appear as positive Level 1 output field
   names or claims.

3. **Make an explicit target-set decision** (NB-1). C4-A must actively choose
   one:

   - **Option A (preferred):** Authorize only `docs/current-status.md` and
     `docs/dev/semantic-governance-heat-map.md` as primary targets; optional
     one-line pointer in `docs/spec/README.md` or `docs/language-spec.md`
     only. Defer ch5/ch6/ch7 to a later gate with explicit negative-only wording
     requirements.

   - **Option B:** Authorize ch5/ch6/ch7 sync with strict wording locks (see
     NB-2 for ch7 constraint). Requires specifying the exact negative-only
     sentence forms for each chapter before implementation opens.

   - **Option B-limited:** Authorize ch5 only (medium-risk); explicitly defer
     ch6/ch7 to a later gate.

4. **Require the implementation split** (C2-P1 recommendation): the
   docs/spec sync must be two cards — this C4-A authority/design decision, then
   a separate implementation card that applies only the approved wording.
   Do not combine target-set choice and spec editing in one broad implementation
   card.

5. **Lock `intention_source` wording** to C2-P1's tighter definition ("proof-local
   source for the explanation") rather than C1-D's broader framing, if the term
   appears in any spec-body text.

6. **Confirm `if_expr_branch_intention` remains non-canonical:** no SemanticIR
   node kind, no CompilationReport/CompilerResult/CompatibilityReport field, no
   receipt shape, no public API/CLI object, no `.igapp` artifact schema.

7. **Confirm PROP-032 amendment not needed** and not implied by this vocabulary
   sync. `docs/proposals/PROP-032-assumptions-block-v0.md` must not be edited.
   Branch-level `uses assumptions` syntax remains closed.

8. **Confirm all closed surfaces remain closed:** parser/grammar, TypeChecker/
   SemanticIR schema, runtime/evaluator, RuntimeSmoke, proof RuntimeMachine,
   non-selected branch evaluation, Level 2 dry-run, Level 3 comparison report,
   report/result/receipt/CompatibilityReport shapes, dependency/cache authority,
   public API/CLI widening, release/production/Spark/all-grammar claims.

9. **If Option B or B-limited is chosen**, require that ch7-runtime.md text be
   strictly negative (NB-2): listing what does NOT change, with no affirmative
   description of Level 1 as a runtime feature. Exact wording must be specified
   by C4-A before the implementation card opens.

---

[Agree]
- Neither card self-authorizes docs/spec edits; both correctly defer to C4-A.
- Proof-local `if_expr_branch_intention` descriptor remains non-canonical in both
  cards; canonization is reserved for a separate future schema/report/API decision.
- Assumptions boundary is correctly maintained: PROP-032 unmodified, no
  branch-level syntax, proof-local `assumption_refs` distinguished from receipt.
- Forbidden vocabulary list correctly expanded with 8 new synonym-blocking terms.
- Level 2 dry-run firewall is explicit and gated on separate future authorization.
- Target-set divergence between C1-D and C2-P1 is known, surfaced, and
  appropriate for C4-A resolution rather than a reviewer blocker.
- The two-card split (authority decision → implementation) is the right structure.

[Challenge]
- None. No blockers identified.

[Missing]
- NB-1: C4-A explicit positive target selection (Option A, B, or B-limited) not yet made — correct at this design stage but required before implementation opens.
- NB-2: Ch7 wording must be locked to strictly negative closure text before any Option B implementation.
- NB-3: C1-D's "default open" framing for ch5/ch6/ch7 should be reread by C4-A as requiring positive authorization, not as a default grant.

[Sharper Question]
- Is the vocabulary sync goal discoverability (then Option A is sufficient) or
  a permanent negative-annotation on spec chapters (which requires Option B)?
  C4-A should state the goal explicitly before choosing the target set.

[Route]
- accept — C4-A should accept C1-D and C2-P1, choose Option A, B, or B-limited
  explicitly, and authorize only a future implementation card with locked wording
  per the constraints above.
