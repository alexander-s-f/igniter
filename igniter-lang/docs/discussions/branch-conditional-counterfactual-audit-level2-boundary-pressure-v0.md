# Branch Conditional Counterfactual Audit Level 2 Boundary Pressure v0

Card: S3-R208-C3-X  
Agent: `[Igniter-Lang External Pressure Reviewer]`  
Role: `external-pressure-reviewer`  
Mode: discussion  
Initiator: user  
Track: `branch-conditional-counterfactual-audit-level2-boundary-pressure-v0`

---

## Question

Do the S3-R208-C1-D Level 2 dry-run boundary design and the S3-R208-C2-P1
adjacent-concepts survey correctly prevent runtime/report/API/cache/public-claim
widening, treat analogies as internal design pressure only rather than authority,
and establish the right conditions for any later proof-local Level 2 route?

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-dry-run-boundary-design-v0.md` (C1-D)
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-adjacent-concepts-survey-v0.md` (C2-P1)
- `igniter-lang/docs/tracks/stage3-round207-status-curation-v0.md` (R207 status)
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-vocabulary-docs-sync-acceptance-decision-v0.md` (R207-C3-A)

---

## Scope-Check Matrix

| ID | Check | Verdict |
|----|-------|---------|
| SC-1 | No code/proof/implementation self-authorized | PASS |
| SC-2 | Live runtime remains lazy; no non-selected branch evaluation | PASS |
| SC-3 | Level 2 dry-run is explicit and isolated | PASS |
| SC-4 | No report/result/receipt/CompatibilityReport mutation | PASS |
| SC-5 | No dependency/cache authority | PASS |
| SC-6 | No effect/external IO/production behavior | PASS |
| SC-7 | No public counterfactual/runtime/demo claims | PASS |
| SC-8 | No Spark/API/CLI claims | PASS |
| SC-9 | Analogies not treated as authority | PASS |
| SC-10 | Forbidden R207 vocabulary controlled; not reclassified without a future gate | PASS (see NB-1) |

**Result: 10/10 PASS — no blockers.**

---

## Detailed Findings

### SC-1: No Self-Authorization

C1-D: "This is design-only. It authorizes no proof, implementation, runtime
behavior, report/result shape, public API/CLI, release claim, or production
claim." The "Blockers Before Implementation" section explicitly gates
implementation on a proof-local concept proof that does not yet exist.

C2-P1: "This card does not authorize: design acceptance, proof implementation,
live implementation, parser/grammar/source syntax, branch-level `uses
assumptions`, TypeChecker/SemanticIR schema/canon mutation, runtime/evaluator/
RuntimeSmoke behavior..." Both cards defer all authorization to a later gate.

### SC-2: Live Runtime Laziness Preserved

C1-D answers directly: "May live runtime evaluate latent branches? No. Live
runtime remains lazy; selected branch only." The invocation table marks
"Automatic runtime branch evaluation: Rejected for v0. Violates lazy runtime
boundary." The governing phrase "Runtime is lazy. Audit is aware." is
explicitly repeated as the fixed principle from R207.

C2-P1's authority risk map for the runtime surface identifies "Debugger replay /
symbolic execution" as the highest-risk borrowed analogy — and correctly guards
against it: "Runtime remains lazy; dry-run explicit and isolated only."

### SC-3: Explicit Invocation and Isolation

C1-D: "Level 2 must be explicitly invoked." The invocation source table is
prescriptive:
- Proof-local harness request: Preferred first route.
- Public API/CLI flag: Closed. Needs separate public API/CLI design.
- Automatic runtime evaluation: Rejected.
- Production/runtime automatic: Closed.

The candidate shape carries an `isolation` block with six explicit false fields:
```json
"isolation": {
  "actual_result_mutated": false,
  "reports_mutated": false,
  "receipts_mutated": false,
  "cache_mutated": false,
  "external_io_performed": false,
  "production_authority": false
}
```
This is the right structural approach: isolation is not prose-only but a
machine-checkable block, mirroring the pattern established by the Level 1
authority block.

### SC-4: Report/Result/Receipt/CompatibilityReport Closure

C1-D closed surfaces: "CompilationReport / CompilerResult / receipt /
CompatibilityReport mutation." The isolation block: `reports_mutated: false`,
`receipts_mutated: false`. The authority block: `report_authority: false`.

Three independent layers (closed surfaces list, isolation block, authority block)
all close this surface. "Minimum Evidence Before Spec-Body Promotion" defers
any report/result shape to a later gate: "explicit no-report/no-result/no-receipt
policy or a separate report-shape proposal."

### SC-5: Dependency/Cache Authority

C1-D answers: "Can dry-run carry dependency/cache authority? No for v0. It may
record explanatory refs only." Authority block: `dependency_authority: false`,
`cache_authority: false`. Isolation block: `cache_mutated: false`.

C2-P1 authority risk map: "Abstract interpretation / database what-if → could
make projected deps look cache-authoritative. Guardrail: authority zeros;
explanatory refs only." Both cards are consistent.

### SC-6: Effect / External IO / Production Closure

C1-D's effect/IO policy table is specific:
- `escape` / effect / external call: Refuse.
- Privileged / irreversible behavior: Refuse.
- Runtime callbacks: Refuse unless separately designed.
- Persistence / network / filesystem: Refuse.
- Ledger/TBackend live read/write: Refuse.

Isolation block: `external_io_performed: false`, `production_authority: false`.

The `tbackend_read` policy adds a critical first-slice constraint: refuse if
dry-run evaluation reaches it; do not perform live temporal/backend reads.
This is the right conservative stance — it prevents the temporal/backend
boundary from being opened silently through a Level 2 dry-run evaluation path.

### SC-7: No Public Counterfactual/Runtime Claims

C1-D: "It is not a public runtime feature." Authority block: `public_claim:
false`. C2-P1: "Even these [dry-run framing terms] should remain non-public for
now because public counterfactual claims are closed."

C2-P1's explicit warning on probabilistic counterfactual vocabulary: "Public
claim: very high risk. Do not imply statistical causal validity, uncertainty
semantics, or observed-world causal claims." The survey correctly identifies
this as the highest public-claim risk surface.

### SC-8: No Spark/API/CLI

Both cards explicitly close Spark, public API/CLI in their closed surfaces lists.
C1-D invocation table: "Public API/CLI flag: Closed. Needs separate public
API/CLI design and authority."

### SC-9: Analogies Treated as Internal Design Pressure Only

C2-P1's framing is explicit: "classifies outside analogies for internal design
pressure only; it authorizes no design, implementation, report/API shape, public
claim, or runtime behavior."

The borrow/do-not-borrow summary is well-structured:
- **Safe to borrow:** explicit premise sets, isolation/no-mutation language,
  branch/path discipline, declared approximation limits, non-materialized/
  hypothetical framing, authority-zero metadata.
- **Must not borrow:** solver/exhaustiveness claims, formal proof/correctness
  claims, causal inference claims, runtime replay claims, `would_*` field names.

Symbolic execution is correctly identified as "the tempting wrong label" and
explicitly blocked as a canonical or public vocabulary choice. The survey
recommends "symbolic-execution-adjacent" only as internal design note, not as
user-facing language. The database hypothetical index analogy is well-chosen as
the safest borrowing: "the planner can reason without creating the thing" maps
cleanly to Level 2's no-mutation requirement.

The warning on probabilistic/causal counterfactual vocabulary (Warning #1) is
appropriate: the word "counterfactual" carries statistical causal inference
baggage. C1-D correctly qualifies it throughout: "isolated counterfactual
dry-run projection under an explicit premise set," never unqualified
"counterfactual."

### SC-10: Forbidden R207 Vocabulary Controlled

R206/R207 established 14 forbidden terms. C1-D's "Non-Vocabulary / Blocked
Terms" section lists 8:
```text
would_result, would_output, would_fail,
counterfactual result, counterfactual output, counterfactual failure,
latent runtime value, latent runtime failure
```

The other 6 R207 forbidden terms (`latent execution`, `latent branch execution`,
`simulated branch result`, `dry-run result`, `branch replay`, `replayed branch
value`) are not in C1-D's explicit blocked list. However:
1. C1-D explicitly states "Level 2 should not use R207 forbidden `would_*`
   vocabulary as canonical field names" — cross-referencing the complete R207
   forbidden list.
2. None of the 14 forbidden terms appear as Level 2 vocabulary in C1-D.
3. The 6 missing terms are not proposed as Level 2 vocabulary.

The new Level 2 vocabulary (`projected_value`, `projected_failure`,
`dry_run_projection`, `dry_run_trace`, `assumed_condition`, `projected_branch`,
`premise_set`, `isolation_guarantee`, `no_authority`) is clearly distinct from
all 14 forbidden terms and does not introduce any synonym drift. This passes.

**NB-1 (precision — concept proof condition):** The concept proof authorization
card should explicitly require that all 14 R206/R207 forbidden terms are absent
from proof output fields (not just the 8 listed in C1-D). The proof harness
should run a vocabulary scan equivalent to the C1-I rg scan against all
14 terms.

---

## Level 2 Vocabulary Assessment

The proposed guarded Level 2 vocabulary is well-designed:

| Term | Assessment |
|------|-----------|
| `counterfactual_dry_run` | Safe — qualified with "dry_run"; not "counterfactual result" |
| `dry_run_projection` | Safe — "projection" implies non-authoritative output |
| `dry_run_trace` | Safe — trace is evaluation record, not result |
| `assumed_condition` | Safe — "assumed" qualifier is explicit |
| `projected_branch` | Safe — "projected" qualifier present |
| `projected_value` | Safe, with NB-2 note (see below) |
| `projected_failure` | Safe — refusal/failure inside projection, not actual failure |
| `premise_set` | Safe — explicit inputs to dry-run |
| `isolation_guarantee` | Safe — positive assertion term |
| `no_authority` | Safe — negative authority assertion |

The key distinction C1-D makes is correct: `projected_value` is produced under
an explicit `premise_set` inside an `isolation` boundary, whereas `would_result`
implies an alternate actual outcome. The structural machinery (`premise_set`,
`isolation` block, `authority` block) makes this distinction enforceable rather
than just prose.

**NB-2 (precision — concept proof condition):** `projected_value` and
`projected_failure` are well-designed guarded terms. However, future proof routes
should carry an explicit disclaimer in the projection envelope:
```json
"projected_value_is_not_actual_output": true,
"projected_failure_is_not_actual_failure": true
```
or equivalent prose in the schema disclaimer, to prevent drift toward treating
these as soft-authority outputs over time. This is consistent with the pattern
established by Level 1's `non_execution_guarantee` and `explanatory_only` flags.

---

## Required Conditions for Any Later Proof-Local Level 2 Route

From C1-D's minimum evidence matrix (10 items) plus the scope checks, the
binding conditions for any later proof-local Level 2 concept proof
authorization review are:

**Invocation and isolation:**
1. Dry-run occurs only when proof harness explicitly requests it.
2. All six isolation block fields verified: `actual_result_mutated: false`,
   `reports_mutated: false`, `receipts_mutated: false`, `cache_mutated: false`,
   `external_io_performed: false`, `production_authority: false`.
3. All four authority block fields verified false: `dependency_authority`,
   `cache_authority`, `report_authority`, `runtime_readiness_authority`,
   `public_claim`.

**Behavioral proofs:**
4. Pure success case: a latent pure expression produces `projected_value`.
5. Effect/external IO refusal: effect/escape expression produces
   `projected_failure` refusal inside projection, not actual failure.
6. `tbackend_read` refusal: temporal/backend read refused in first slice;
   no live Ledger/TBackend reads.
7. Nested `if_expr` case: recursive dry-run follows same isolated rules.

**Premise and vocabulary:**
8. Every projection records `assumed_condition` and `premise_set` source.
9. All 14 R206/R207 forbidden terms absent from all proof output fields
   (full 14-term rg scan, not just the 8 listed in C1-D).
10. `projected_value` and `projected_failure` carry explicit non-authority
    disclaimers (NB-2).
11. Level 1 branch-intention consumed as input, not replaced.
12. Level 2 projection does not invalidate Level 1 non-execution guarantee
    for actual runtime (Level 1 describes the actual path, not the dry-run).

**Closed surfaces:**
13. No lib/, runtime/evaluator/RuntimeSmoke/report/API/grammar/public claim
    mutation in proof scope.
14. No spec-body promotion before a separate spec-body gate.

---

## Non-Blocking Notes

**NB-1 (concept proof authorization condition):** C1-D's explicit forbidden
vocabulary list covers 8 of the 14 R206/R207 forbidden terms. The Level 2
concept proof authorization review card should require the full 14-term vocabulary
scan (same form as C1-I's `rg` command) against all proof output files. C4-A
should include this as a binding condition in the authorization boundary.

**NB-2 (concept proof authorization condition):** The Level 2 projection
envelope should carry explicit boolean disclaimers distinguishing `projected_value`
from actual runtime output and `projected_failure` from actual runtime failure.
This mirrors the Level 1 pattern (`non_execution_guarantee`, `explanatory_only`)
and prevents gradual authority drift for projection results. C4-A should require
this as part of the proof shape.

---

## Verdict

```text
PASS — 10/10 PASS, no blockers, 2 non-blocking notes (concept proof conditions)
```

Both cards are design-only and correctly self-aware of their limits. The Level 2
boundary design establishes the right three-layer authority control (isolation
block, authority block, closed surfaces). The adjacent-concepts survey correctly
identifies the highest-risk analogy borrowings and recommends Igniter-native
guarded vocabulary over borrowed canonical terminology. The governing principle
"Runtime is lazy. Audit is aware." is maintained throughout. No code, proof,
implementation, runtime, report, API, or public claim is opened by either card.

---

## C4-A Recommendation

**Accept both S3-R208-C1-D and S3-R208-C2-P1.**

Required acceptance decisions for C4-A:

1. **Accept Level 2 as conceptually valid** as an explicit, isolated
   counterfactual dry-run projection route — not normal runtime, not a public
   runtime feature, not a report/receipt shape.

2. **Accept the guarded Level 2 vocabulary** (`counterfactual_dry_run`,
   `dry_run_projection`, `dry_run_trace`, `assumed_condition`, `projected_branch`,
   `projected_value`, `projected_failure`, `premise_set`, `isolation_guarantee`,
   `no_authority`) as design-level candidate terms for proof-local use only.
   These terms do not become public API or report fields.

3. **Accept the adjacent-concepts survey as internal analogy map only.** No
   analogy (symbolic execution, abstract interpretation, CFG/SSA, debugger
   replay, probabilistic counterfactuals) grants vocabulary or authority to Level 2.
   Symbolic execution must not be used as the canonical or public label.

4. **Accept the 10-item minimum evidence matrix** as binding requirements for
   the concept proof authorization review, extended with NB-1 (all 14 forbidden
   terms) and NB-2 (`projected_value`/`projected_failure` non-authority
   disclaimers).

5. **Do not authorize proof or implementation in C4-A.** Route to a proof-local
   Level 2 concept proof authorization review (separate card) with the required
   conditions above as binding constraints.

6. **Record the 7 blockers from C1-D as remaining before implementation:**
   - proof-local concept proof passes;
   - isolation policy is pressure-reviewed;
   - dry-run diagnostic/refusal vocabulary accepted;
   - pure function registry or evaluator boundary chosen;
   - effect/escape refusal policy accepted;
   - `tbackend_read` policy accepted by temporal/runtime owners;
   - report/result/receipt/CompatibilityReport shape explicitly closed or
     separately designed.

7. **Confirm all closed surfaces remain closed:** live runtime laziness, parser/
   grammar/source syntax, branch-level `uses assumptions`, TypeChecker/SemanticIR
   schema, RuntimeSmoke, proof RuntimeMachine, non-selected branch evaluation in
   live runtime, effect/external IO/Ledger/TBackend, dependency/cache authority,
   CompilationReport/CompilerResult/receipt/CompatibilityReport mutation,
   spec-body promotion, public API/CLI, release/public/demo/Spark/production
   claims.

8. **Confirm `tbackend_read` is refuse-only for the first Level 2 slice.**
   Any expansion to frozen in-memory proof backend snapshots requires a separate
   temporal/runtime design gate.

9. **Confirm PROP-032 is not amended by this design.** Branch-level `uses
   assumptions` syntax remains closed.

---

[Agree]
- Level 2 conceptual validity is established with the right three-layer authority
  control: isolation block (six fields), authority block (four fields), and
  closed surfaces list. This is structurally stronger than prose-only claims.
- The candidate projection shape correctly models Level 2 as a "trace plus
  projection" envelope rather than an alternate actual result.
- Invocation table correctly rejects automatic runtime evaluation and public
  API/CLI as Level 2 invocation sources.
- Effect/IO policy table covers all relevant refusal cases including
  `tbackend_read`, escape, and production/persistence surfaces.
- The adjacent-concepts survey correctly identifies symbolic execution as the
  highest-risk borrowed analogy and steers toward Igniter-native guarded terms.
- "Isolated counterfactual dry-run projection under an explicit premise set" is
  a safe qualifying phrase; unqualified "counterfactual" is correctly avoided.
- Level 2 correctly consumes Level 1 rather than replacing it; Level 1
  non-execution guarantee remains valid for the actual runtime path.

[Challenge]
- None. No blockers identified.

[Missing]
- NB-1: Full 14-term forbidden vocabulary scan should be required for any Level 2
  concept proof (C1-D's explicit list covers only 8 of the 14).
- NB-2: `projected_value` and `projected_failure` should carry explicit
  non-authority boolean disclaimers in the proof projection envelope.

[Sharper Question]
- What is the minimum pure expression set a Level 2 concept proof harness needs
  to exercise to prove isolation (i.e., what is the smallest combination of
  `projected_value`, `projected_failure`, and effect-refusal cases that
  constitutes a sufficient first proof slice)?

[Route]
- accept — C4-A should accept C1-D and C2-P1, then authorize a Level 2 concept
  proof authorization review as the next route, with the 14 required conditions
  above as binding constraints.
