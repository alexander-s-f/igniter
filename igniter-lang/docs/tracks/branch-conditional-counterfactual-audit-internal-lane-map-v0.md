# Branch Conditional Counterfactual Audit Internal Lane Map v0

Card: S3-R215-C1-D
Agent: [Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: branch-conditional-counterfactual-audit-internal-lane-map-v0
Route: UPDATE
Status: done / design-only lane map
Date: 2026-05-30

Depends on:
- S3-R214-C4-A

---

## Neighbor Awareness

Affected neighbor roles:

- Research Agent: owns proof evidence anchors and future proof-local reruns.
- Runtime / Bridge owners: own any later runtime/report/API pressure route.
- Status / Spec Curator: owns later status-map sync if authorized.
- Assumptions owner: owns premise-capsule guardrails; no PROP-032 expansion here.

This card speaks only as `[Compiler/Grammar Expert]`.

---

## Inputs Read

- `igniter-lang/docs/tracks/stage3-round214-status-curation-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-lane-consolidation-decision-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-lane-consolidation-boundary-v0.md`
- `igniter-lang/docs/tracks/counterfactual-audit-runtime-debt-and-time-to-market-pressure-survey-v0.md`
- `igniter-lang/docs/discussions/branch-conditional-counterfactual-audit-lane-consolidation-pressure-v0.md`
- `igniter-lang/docs/dev/semantic-governance-heat-map.md`
- `igniter-lang/docs/spec/README.md`

---

## Fixed Point

This is an internal lane map only. It consolidates route memory for
counterfactual audit work after accepted Level 1, Level 2a, and Level 2b proof
evidence.

It does not create language semantics, source syntax, SemanticIR schema,
runtime behavior, report/result fields, public API, release evidence, or public
claims.

---

## Compact Lane Map

Context baseline:

| Level | Purpose | Current Evidence | Owner Handoff | Status |
| --- | --- | --- | --- | --- |
| L0 baseline | Expression-level `if_expr` compiler/runtime baseline: selected-branch runtime behavior exists in bounded internal/proof routes, with no public all-grammar claim. | R190 internal compiler support; R199 live internal evaluator; R201 proof RuntimeMachine consumer; R203 RuntimeSmoke proof-context consumer. | Compiler/Grammar for semantics; Runtime owner for any future runtime widening. | Accepted background, not counterfactual audit authority. |

Lane levels:

| Level | Purpose | Accepted Evidence Anchors | Owner Handoff | Blocked Promotion Paths |
| --- | --- | --- | --- | --- |
| L1 static branch intention | Explain actual/latent branch structure without evaluating latent branches. | R205 concept proof `46/46`; R207 vocabulary docs sync; Heat Map Level 1 row; Spec README held row. | Compiler/Grammar + Research; Assumptions owner only for premise-capsule wording. | No grammar, no branch-level `uses assumptions`, no SemanticIR schema, no runtime eval, no report/API/public claim. |
| L2a isolated projection concept | Model "what would be projected" in experiment-local isolation, with no compiler/source-backed authority. | R209 Level 2 concept proof acceptance; proof-local projection envelopes and closed-surface checks. | Research owns proof-local model; Runtime/Bridge review only if a later route asks whether isolation can move. | No source-backed artifact authority, no live runtime, no report/result/receipt, no cache/dependency authority. |
| L2b source-backed isolated projection | Reference proof-owned SemanticIR-shaped source evidence, frozen input snapshots, digest refs, and explicit premise sets. | R211 source-backed proof `61/61`; R212 vocabulary boundary; R213 docs sync; Heat Map source-backed row; Spec README held row. | Research for evidence; Compiler/Grammar for language boundary; Status Curator for low-authority docs if authorized. | No canonical artifact, no SemanticIR schema mutation, no compiler-emitted branch-intention artifact, no report/API/runtime support. |
| L3 route map / artifact home / authority design | Decide whether any non-proof-local artifact home, internal carrier, or authority model may exist before runtime/report/API design. | Not opened yet. R214 and this map require it before L4. | Compiler/Grammar with Runtime/Bridge and Status/Portfolio review. | No implementation, no runtime/report/API design until L3 authority questions close. |
| L4 runtime-report-API candidates | Future candidate horizon for runtime/report/API exposure, if ever. | No accepted evidence yet. | Runtime/Bridge/API/Release owners only after explicit gates. | Fully closed: public runtime, reports, receipts, CompatibilityReport, API/CLI, release claims, Spark, production. |

---

## Evidence Anchor Index

| Anchor | What It Proves | What It Does Not Prove |
| --- | --- | --- |
| R205 Level 1 concept proof | Static branch-intention inspection can be modeled without latent execution. | No canonical descriptor, no runtime behavior, no report field. |
| R207 Level 1 vocabulary docs sync | Internal terminology can name Level 1 branch intention with explicit non-claims. | No spec-body promotion and no public feature. |
| R209 Level 2 concept proof | Isolated projection mechanics can be modeled proof-locally. | No source-backed authority and no live dry-run. |
| R211 source-backed Level 2 proof | Proof-owned source evidence can back isolated projection with digest refs and frozen inputs. | No canonical artifact home, no emitted compiler artifact, no report/API/runtime support. |
| R213 source-backed vocabulary docs sync | Low-authority docs/status may name source-backed Level 2 evidence with fences. | No body-spec, PROP-032, runtime, report, public, or Spark claim. |
| R214 lane consolidation decision | L1/L2a/L2b remain distinct but should be consolidated operationally by an internal lane map. | No docs/map sync, implementation, runtime/report/API, or public claim authorization. |

---

## Heat Map And Spec README Decision

Decision:

```text
keep Heat Map rows separate for now
keep Spec README held rows separate for now
do not edit Heat Map or Spec README in this card
use this lane map as the grouping artifact
```

Reasoning:

- L1 and L2b are related, but they have different evidence shapes and different
  promotion risks.
- Merging the rows before an artifact-home / authority route would blur the
  difference between static intention and source-backed isolated projection.
- A later Status / Spec Curator map-sync may add a pointer to this lane map if
  explicitly authorized.

---

## Source-Backed Evidence Stance

Decision:

```text
source-backed Level 2 evidence remains proof-local now
it is not declared proof-local forever
a later L3 artifact-home options route is required before any non-proof-local home
```

The next L3 route must compare at least:

- stay proof-local permanently;
- internal docs/status-only index;
- proof-owned artifact directory with no compiler emission;
- internal carrier object;
- report/result/receipt candidate, likely rejected or held unless separately
  authorized.

Until that route closes, source-backed Level 2 evidence remains non-canonical
and proof-owned.

---

## Internal Tool-Only Use Case

Decision:

```text
held as a future design-only question
not opened by this lane map
```

An internal tool-only use case may be valuable, but it would still need to
answer artifact home, authority, input snapshot, premise-set, report exposure,
and runtime isolation questions. It must not be treated as a shortcut around L3.

Possible later route:

```text
counterfactual-audit-internal-tool-only-use-case-options-v0
```

That route should open only after the runtime-debt / time-to-market review or
as a sub-question inside L3 artifact-home design.

---

## RuntimeSmoke Transitive-Load Wording

Canonical wording for now:

```text
RuntimeSmoke proof-context paths may transitively load the proof RuntimeMachine
and SemanticIRExpressionEvaluator. This is a known consequence of proof harness
wiring, not RuntimeSmoke feature support, not public runtime support, not API
support, and not a production/runtime claim. RuntimeSmoke result shape remains
unchanged.
```

This wording must travel with any future RuntimeSmoke-related counterfactual
audit card.

---

## Minimum Gates Before Runtime / Report / API Design

Runtime/report/API design may not open until these gates close:

| Gate | Required Decision |
| --- | --- |
| G1 lane map | This lane map accepted. |
| G2 runtime-debt / TTM review | Decide whether runtime-debt pressure changes sequencing or confirms L3 first. |
| G3 artifact-home options | Decide whether source-backed evidence stays proof-local or receives an internal non-canonical home. |
| G4 authority model | Define authority for branch-intention refs, input snapshots, premise sets, and source evidence. |
| G5 Runtime/Bridge review | Review evaluator, proof RuntimeMachine, RuntimeSmoke, and non-selected branch isolation boundaries. |
| G6 report/result/receipt surface survey | Explicitly decide whether these surfaces remain closed or which one may receive a design-only route. |
| G7 dependency/cache stance | Reaffirm no dependency/cache authority, or open a separate design route before any runtime exposure. |
| G8 TBackend/effect policy | Preserve refusal for temporal/effect/external IO dry-run unless a separate temporal/effect gate opens. |
| G9 public/API/release/Spark gate | Separate authority required before any public API/CLI, release evidence, demo, Spark, or production claim. |

---

## Blocked Promotion Paths

The lane must not be promoted by changing:

- source grammar or parser syntax;
- branch-level `uses assumptions`;
- TypeChecker or SemanticIR schema;
- compiler-emitted branch-intention artifacts;
- `CompilerResult`, `CompilationReport`, report/result/receipt fields, or
  CompatibilityReport;
- RuntimeSmoke public behavior or result shape;
- `.igapp` schema, manifests, goldens, sidecars, or artifact hashes;
- dependency/cache authority;
- effect execution, external IO, persistence, Ledger/TBackend live reads;
- public API/CLI;
- release evidence or public demo/stable/production/all-grammar wording;
- Spark data, fixtures, ids, integration, demo, or production surfaces.

---

## Permanent Do-Not-Speed-Up Fence

Do not speed up this lane by:

- adding report/result/receipt fields before an explicit surface gate;
- treating RuntimeSmoke proof-context evidence as public runtime support;
- turning `call_trace`, selected-path behavior, or projection trace data into
  dependency/cache authority;
- making source-backed projection envelopes canonical by implication;
- using Spark, public demos, release wording, or product pressure as validation
  shortcuts;
- evaluating non-selected branches in live runtime;
- widening assumptions from premise capsule to branch syntax;
- presenting internal/proof-only terminology as user-facing feature support.

This fence is permanent lane hygiene, not a temporary R214 note.

---

## Runtime-Debt / Time-To-Market Sequencing

Decision:

```text
open runtime-debt / time-to-market review immediately after C4-A acceptance
do not require an extra map-sync step first
```

Reasoning:

- This lane map is the requested consolidation artifact.
- Existing Heat Map and Spec README rows remain accurate enough because they
  explicitly hold Level 1 and source-backed Level 2 as separate proof-local
  entries.
- The next risk is sequencing pressure, not map completeness.
- A later Status / Spec Curator map-sync can happen after the runtime-debt
  review if the accepted route needs status/index pointers.

Suggested next route:

```text
counterfactual-audit-runtime-debt-and-time-to-market-review-v0
```

---

## Recommendation For C4-A

Preferred:

```text
accept lane map
open runtime-debt / time-to-market review next
keep Heat Map and Spec README edits closed for now
keep runtime/report/API/public/Spark claims closed
```

Backup:

```text
accept lane map
hold runtime-debt review if Portfolio wants a pause
```

Not recommended:

```text
open runtime/report/API design immediately
merge Heat Map rows before artifact-home authority is designed
canonize source-backed Level 2 evidence by docs wording alone
```

---

## Closed Surfaces

Remain closed:

- code implementation;
- parser, classifier, TypeChecker, SemanticIR, assembler, orchestrator;
- runtime/evaluator/RuntimeSmoke/proof RuntimeMachine behavior changes;
- live non-selected branch evaluation;
- source grammar and branch-level assumptions syntax;
- body spec chapters, `docs/language-spec.md`, public docs, PROP-032;
- Heat Map, Spec README, current-status, and status index edits;
- report/result/receipt/CompatibilityReport;
- `.igapp`, manifests, sidecars, artifact hashes, goldens;
- public API/CLI;
- release evidence, public demo/stable/production/all-grammar claims;
- Spark, runtime production, Ledger/TBackend, cache, deployment, signing.

---

## Handoff

[D] Created the internal Counterfactual Audit Lane map for L1/L2a/L2b/L3/L4.

[S] Source-backed Level 2 remains proof-local now, but not declared permanently
proof-local; artifact-home options must be designed in L3 before promotion.

[T] RuntimeSmoke transitive-load wording is pinned as proof-harness consequence,
not feature support.

[R] C4-A should accept this map and open runtime-debt / time-to-market review
next.

[Next] Keep runtime/report/API design closed until the explicit gate list is
satisfied.
