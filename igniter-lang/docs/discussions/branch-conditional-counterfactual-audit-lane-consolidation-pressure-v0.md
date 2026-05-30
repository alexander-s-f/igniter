# Branch Conditional Counterfactual Audit Lane Consolidation Pressure v0

Card: S3-R214-C3-X
Agent: [External Pressure Reviewer]
Role: external-pressure-reviewer
Track: branch-conditional-counterfactual-audit-lane-consolidation-pressure-v0
Route: REVIEW
Status: complete
Date: 2026-05-30

Depends on:
- S3-R214-C1-D
- S3-R214-C2-P1

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-lane-consolidation-boundary-v0.md` (C1-D)
- `igniter-lang/docs/tracks/counterfactual-audit-runtime-debt-and-time-to-market-pressure-survey-v0.md` (C2-P1)
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-lane-consolidation-decision-v0.md` (C4-A, current HOLD)
- `igniter-lang/docs/tracks/stage3-round213-status-curation-v0.md` (R213 accepted state)
- `igniter-lang/docs/dev/semantic-governance-heat-map.md`
- `igniter-lang/docs/spec/README.md`

---

## Scope-Check Matrix

| Check | Source(s) | Finding | Safe? |
| --- | --- | --- | --- |
| Lane vocabulary does not become public support | C1-D "Closed Surfaces"; C2-P1 Surface Map column "Must not infer" | Lane labels (L1/L2a/L2b) are internal design terms. Heat Map rows (`branch_intention`, `source_backed_dry_run_projection`) are internal navigation vocabulary explicitly marked non-canonical, not spec chapters, not PROP entries, not grammar symbols. No public-facing claim is introduced or implied. | ✅ SAFE |
| Level 1 / Level 2 / source-backed Level 2 remain semantically distinct | C1-D "Compact Lane Model" and "Relationship Between Levels" | C1-D explicitly states "levels should not collapse semantically." L1 is static audit vocabulary without evaluation; L2a is isolated projection mechanics using proof-local fixtures; L2b adds source-backed artifacts, digest chains, and explicit premise sets. The three-row Heat Map and the evidence anchor table keep each level's maturity and basis traceable. | ✅ SAFE |
| Level 2 dry-run remains proof-local and isolated | C1-D "Compact Lane Model" L2a/L2b rows; C2-P1 "Proven / Live / Closed / Ambiguous" | Both L2a and L2b have authority fields false, `projected_value ≠ actual_output`, `projected_failure ≠ actual_runtime_failure`. No cache, no report, no runtime behavior. Evaluation occurs only in experiment-local isolated projection; never in production or RuntimeSmoke. | ✅ SAFE |
| Source-backed evidence remains non-canonical | C1-D "Source-Backed Evidence Stance"; C2-P1 "Keep" list | Enumerated: `source_branch_intention_ref` is not CompilerResult; digest-addressed refs are not artifact schema; `dry_run_projection` is not runtime support. The forbidden-implication list in C1-D is comprehensive and not disputed by C2-P1. | ✅ SAFE |
| Runtime remains lazy; non-selected branches are not live-evaluated | C1-D "Closed Surfaces" (live non-selected branch evaluation closed); C2-P1 Surface Map (`SemanticIRExpressionEvaluator`: lazy selected branch only) | Closing is unambiguous in both documents. C1-D's governing phrase ("Runtime is lazy. Audit is aware.") is still accurate. C2-P1 explicitly classifies non-selected branch evaluation as closed with severity 6/10 false-claim risk if fence is removed. | ✅ SAFE |
| Report / result / receipt / API / cache authority remains closed | C1-D "Closed Surfaces" (comprehensive list); C2-P1 Surface Map and Debt Map | Both documents close `CompilerResult`, `CompilationReport`, `CompatibilityReport`, receipt, cache authority, and API/CLI. No field additions are proposed. C2-P1 correctly rates the "Report/result/receipt absence" as Medium-low risk — good for safety, not a current blocker. | ✅ SAFE |
| Assumptions remain premise-capsule-only | C1-D "Assumptions Stance" | Accepted uses are precisely scoped to proof-local `premise_set` labels. Closed: `uses assumptions` branch syntax, PROP-032 grammar extension, runtime assumption injection, evidence-list validation expansion. No new assumption surface is opened. | ✅ SAFE |
| Time-to-market pressure is not ignored | C1-D "Market Pressure"; C2-P1 "Time-To-Market Interpretation" | C1-D acknowledges TTM risk as product risk, not just documentation preference. C2-P1 scores it 4/10 moderate and interprets it as a process/interpretation cost, not a build blocker. Both documents agree the fastest safe path is a compact route map, not runtime expansion. Pressure is acknowledged and routed, not suppressed. | ✅ SAFE |
| Proof methodology is preserved without becoming process drag | C1-D "Market Pressure" last paragraph; C2-P1 "Proof-Quality Preservation Notes" | C1-D explicitly: "Consolidation should reduce future friction, not add ceremony." C2-P1 lists proof-quality invariants (digest-addressed refs, no-authority fields, explicit premise sets) as a floor to preserve, not as repeating ceremony. The route-map recommendation is specifically designed to prevent repeated boundary reconstruction. | ✅ SAFE |
| C1-D internal lane map is structurally safe | C1-D "Compact Lane Model" table; C1-D "Recommended Next Route" | L1/L2a/L2b/L3/L4 structure is correct. L3 is explicitly a route-map / artifact-home / authority design step — it gates L4. L4 is labeled "Runtime-report-API candidates," which is appropriately speculative, not an open route. The lane map is a design consolidation, not a schema. No promotion path from proof-local to canonical is implied. | ✅ SAFE |
| C2-P1 runtime-debt interpretation is accurate and not overstated | C2-P1 "Runtime Surface Map" and "Runtime Debt Map" | Live evaluator exists (R199, 68/68 PASS) but is direct-require-only and non-root-required — correctly classified as live internal, not public. Proof RuntimeMachine consumer (R201, 56/56 PASS) is in `experiments/`, not production — correctly classified as proof-owned. RuntimeSmoke proof-context evidence (R203, 53/53 PASS) correctly flagged as transitive load, not feature support. Debt severities (Medium/Medium-low) are calibrated. No overstating and no understating found. | ✅ ACCURATE |
| Public / runtime / API / Spark claims remain closed | C1-D "Closed Surfaces"; C2-P1 Surface Map "Spark/API/CLI" row | Both documents are explicit and redundant in closing these surfaces. No drift from R213 accepted state. | ✅ SAFE |

---

## C1-D Assessment: Lane Consolidation Design

**Finding: safe to accept.**

C1-D's lane consolidation design is correctly scoped as design-only. The semantic
distinctness of L1, L2a, and L2b is preserved by separate level definitions with
distinct evidence anchors, authority fields, and evaluation descriptions. The
operational consolidation into one internal lane map is a discovery aid, not a schema
merge. Heat Map rows remain separate, which is the correct call: L1 has 46/46 PASS on
static vocabulary only; L2b has 61/61 PASS on source-backed projection with digest
chains. Conflating their maturity levels under one row would hide that difference.

The proposed lane map structure (L1/L2a/L2b/L3/L4) has correct gating: L3 requires a
route map before L4 opens, and L4 is labeled "candidates" — appropriately speculative.

The closed surfaces list in C1-D is comprehensive and covers all surfaces that prior
pressure rounds have confirmed closed.

One non-blocking observation: C1-D's "Open Questions" section asks "Is there an
internal tool-only use case before runtime support?" This is a legitimate design question
for a future route map, but it must not be read as implicit authorization to begin any
tool-only path. The route map card that follows should answer this question with a named
decision, not treat the question itself as an open door.

**C1-D verdict: accept.**

---

## C2-P1 Assessment: Runtime-Debt / TTM Survey

**Finding: safe to accept as non-authorizing pressure context.**

C2-P1 correctly classifies the live evaluator, proof RuntimeMachine consumer, and
RuntimeSmoke proof-context evidence as having separate authority levels. The survey does
not conflate these into a single "runtime support" claim. The split runtime story debt
item (Medium) is correctly identified: the three proof paths can be misread by new
readers if not fenced, and C2-P1 explains the containment mechanism (acceptance docs
stating proof-context only).

The 4/10 TTM score is calibrated. The interpretation — that the risk is "we can keep
spending review cycles re-proving what remains closed" rather than "we cannot build
this" — is the right framing. The fastest safe path identified (compact route map) is
consistent with C1-D.

The RuntimeSmoke transitive load ambiguity (Low-Medium severity) is correctly classified:
RuntimeSmoke requires proof `compiled_program`, which requires the evaluator — this is a
known architectural consequence from R201/R203, not a feature claim. Future lane map
documentation must carry this classification forward explicitly so it is not re-litigated
in every future review card.

The "Do not 'speed up' by" list in C2-P1 is exactly correct and should be reproduced in
the future internal lane map as a permanent fence.

**C2-P1 verdict: accept as non-authorizing pressure context.**

---

## Explicit Answers

| Question | Answer |
| --- | --- |
| Is C1-D lane consolidation safe to accept? | Yes. Semantic distinctness preserved; operational consolidation is design-only; closed surfaces comprehensive. Accept. |
| Is C2-P1 runtime-debt survey safe to accept as non-authorizing pressure context? | Yes. Accurate, calibrated, no implementation authorization leaks. Accept. |
| May a future internal lane map route open next? | Yes. Both C1-D and C2-P1 recommend it as the immediate next step after C4-A acceptance. |
| Should a runtime-debt / TTM review open after lane-map closure or immediately? | After lane-map closure. C2-P1 serves as the current pressure-context survey. A dedicated runtime-debt review should wait until the lane map establishes ownership boundaries and surface gates — otherwise the review has no clear scope to evaluate against. |
| Is any runtime / report / API implementation route premature? | Yes, premature. L3 route map and authority design must come first. L4 remains a future candidates list, not an open route. |
| Do public / runtime / API / Spark claims remain closed? | Yes. Unambiguous in both C1-D and C2-P1; consistent with R213 accepted state. |

---

## Non-Blocking Acceptance Notes

These are carry-forward notes for the internal lane map card, not blockers for C4-A.

**AN-1 — Open question about internal tool-only use case must remain a question.**
C1-D's "Open Questions" section asks whether there is an internal tool-only use case
before runtime support. The lane map card must answer this with a named decision, not
leave it open. An unanswered "could we" question in a design document is a latent
authorization ambiguity.

**AN-2 — RuntimeSmoke transitive load framing must be carried forward.**
The C2-P1 classification of the RuntimeSmoke transitive load as a known consequence
(not feature support) must be reproduced in the internal lane map document. This
prevents repeated re-litigation in future pressure rounds.

**AN-3 — "Do not speed up by" list should be a permanent fence in the lane map.**
C2-P1's "Do not 'speed up' by" list (adding fields to CompilerResult/CompilationReport/
receipts; treating RuntimeSmoke as public; turning call_trace into dependency/cache
authority; making projection envelopes canonical by implication; using Spark/public
demos as shortcuts) should appear verbatim or in equivalent form in the lane map as a
permanently visible fence.

---

## Verdict

```text
PASS

C1-D: accept
C2-P1: accept as non-authorizing pressure context
C4-A HOLD: release; proceed to final acceptance decision
```

No blockers. Three non-blocking acceptance notes (AN-1, AN-2, AN-3) to carry into the
internal lane map card.

---

## Recommendation for S3-R214-C4-A Rerun

C4-A may now proceed to final acceptance:

```text
Card: S3-R214-C4-A (rerun)
Track: branch-conditional-counterfactual-audit-lane-consolidation-decision-v0
Route: UPDATE
Mode: final acceptance decision
Depends on: C3-X PASS (this document)

Accept:
- C1-D lane consolidation boundary design
- C2-P1 runtime-debt / TTM survey as non-authorizing pressure context

Open next:
- branch-conditional-counterfactual-audit-internal-lane-map-v0

After lane-map closure:
- runtime-debt-and-time-to-market-review-v0 (scope to be defined by lane map)

Keep closed:
- runtime / evaluator / RuntimeSmoke feature claims
- report / result / receipt / CompatibilityReport fields
- cache / dependency authority
- CompilerResult / CompilationReport mutation
- public API / CLI / Spark / demo routes
- any implementation authorization
```

Candidate non-blocking notes for C4-A acceptance record: AN-1, AN-2, AN-3 above.
