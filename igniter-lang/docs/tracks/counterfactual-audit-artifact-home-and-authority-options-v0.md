# Counterfactual Audit Artifact Home And Authority Options v0

Card: S3-R217-C1-D
Agent: [Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: counterfactual-audit-artifact-home-and-authority-options-v0
Route: UPDATE
Status: done / design-only options
Date: 2026-05-30

Depends on:
- S3-R216-C4-A

---

## Neighbor Awareness

Affected neighbor roles:

- Research Agent: owns proof-local evidence packets and future proof reruns.
- Runtime / Bridge owners: must review any later runtime/report/API boundary.
- Status / Spec Curator: may own a later internal index/status-home route.
- Assumptions owner: owns premise-capsule boundaries; no PROP-032 widening here.

This card speaks only as `[Compiler/Grammar Expert]`.

---

## Inputs Read

- `igniter-lang/docs/tracks/stage3-round216-status-curation-v0.md`
- `igniter-lang/docs/tracks/counterfactual-audit-runtime-debt-and-time-to-market-decision-v0.md`
- `igniter-lang/docs/tracks/counterfactual-audit-runtime-debt-facts-packet-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-internal-lane-map-decision-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-internal-lane-map-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-source-backed-proof-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-source-backed-proof-v0.md`

---

## Fixed Point

R216 selects L3 artifact-home / authority options as the next technical route.
The current blocker is not missing runtime code. It is missing authority for:

- source refs;
- input snapshots;
- premise sets;
- projections and traces;
- projected values and failures;
- digest stability outside proof-local outputs.

This document compares homes and authority postures only. It does not authorize
implementation, runtime/report/API design, cache/dependency authority, public
docs, release claims, or Spark surfaces.

---

## Current Evidence Basis

Accepted source-backed Level 2 evidence comes from R211:

```text
source-backed proof-local Level 2 counterfactual dry-run evidence
61/61 PASS
proof-owned SemanticIR-shaped source artifacts
SHA-256 digest-addressed refs
frozen input snapshots
explicit premise sets
no-authority projection envelopes
```

Binding disclaimers remain:

```text
projected_value != actual_output
projected_failure != actual_runtime_failure
source evidence from proof-owned SemanticIR-shaped artifacts != canonical schema
source_branch_intention_ref != CompilerResult or CompilationReport field
dry_run_projection != public_runtime_support
Level2_source_backed_proof != public_counterfactual_support
assumptions-shaped premise refs are proof-local labels only
```

---

## Option Matrix

| Option | Artifact Home | Authority Posture | Recommended Status |
| --- | --- | --- | --- |
| A | Permanent proof-local-only evidence | Experiment owns artifacts and all authority remains false. | Safe fallback; too weak for reducing repeated reconstruction. |
| B | Proof-owned artifact directory, no compiler/report authority | A named proof-owned evidence home under experiments or future proof area; still non-canonical. | Preferred next proof/design candidate. |
| C | Internal docs/status index | Human-readable index to evidence anchors; no artifact authority. | Useful companion after B, not enough alone. |
| D | Internal non-canonical carrier | Internal data object/envelope with explicit no-authority fields. | Promising but needs a separate design/proof route after B/C. |
| E | Compiler-emitted artifact | Compiler emits branch-intention/projection evidence. | Comparison only; hold/reject as next route. |
| F | Report/result/receipt sidecar | Report or receipt stores counterfactual projection evidence. | Comparison only; hold/reject as next route. |

---

## Option A: Permanent Proof-Local-Only Evidence

Summary:

```text
keep all source-backed Level 2 artifacts inside proof experiments forever
```

Authority:

| Area | Authority |
| --- | --- |
| Source refs | Proof harness only; digest refs are local evidence anchors. |
| Input snapshots | Proof harness only; frozen snapshots have no persistence/public authority. |
| Premise sets | Proof harness only; assumptions-shaped refs remain labels. |
| Projections/traces | Proof harness only; traces are debug/evidence, not runtime/cache truth. |
| Projected value/failure | No-authority explanatory output only. |

Digest/stability stance:

- SHA-256 stability is scoped to the proof output directory.
- No stable cross-round artifact contract is promised.

Promotion risks:

- Lowest claim risk.
- Highest drift/reconstruction cost.
- Future agents must keep rediscovering where evidence lives.

Required blockers before changing:

- None if held.
- Any non-proof-local movement requires a new L3 decision.

Verdict:

```text
safe fallback, not preferred as the only next route
```

---

## Option B: Proof-Owned Artifact Directory With No Compiler/Report Authority

Summary:

```text
create or designate a proof-owned artifact home for source-backed Level 2
evidence without compiler emission, report fields, runtime support, or public
schema claims
```

Authority:

| Area | Authority |
| --- | --- |
| Source refs | Proof artifact owner validates digest refs and source kind labels. |
| Input snapshots | Proof artifact owner validates frozen snapshots and digest match. |
| Premise sets | Proof artifact owner validates explicit premise set shape and no-authority flags. |
| Projections/traces | Proof artifact owner records isolated projection outputs and trace metadata as no-authority evidence. |
| Projected value/failure | Must carry explicit disclaimer: projection only, not actual runtime result/failure. |

Digest/stability stance:

- Digests may be stable evidence anchors inside the proof-owned home.
- Stability is content-addressed, not language-schema authority.
- Source paths are evidence paths, not compiler artifact paths.

Promotion risks:

- Could be mistaken for canonical artifact schema.
- Could be mistaken for reportable dry-run support.
- Needs strict naming and negative disclaimers in every summary.

Required blockers before future route:

- Define exact home path and write scope.
- Define artifact manifest shape, if any, with `canonical:false`.
- Define required negative fields:
  - `runtime_authority:false`;
  - `report_authority:false`;
  - `cache_authority:false`;
  - `public_api_authority:false`;
  - `compiler_emitted:false`.
- Define parity checks against R211 source-backed proof.
- Confirm no `.igapp`, manifest, report, result, receipt, or CompatibilityReport
  mutation.

Verdict:

```text
preferred next design/proof route
```

Recommended next route name:

```text
counterfactual-audit-proof-owned-artifact-home-design-v0
```

---

## Option C: Internal Docs/Status Index

Summary:

```text
index accepted evidence anchors in internal docs/status without moving artifacts
or creating a machine-readable carrier
```

Authority:

| Area | Authority |
| --- | --- |
| Source refs | Index cites evidence refs only; no validation authority. |
| Input snapshots | Index may list accepted snapshot anchors; no snapshot authority. |
| Premise sets | Index may name premise-set posture; no validation or receipt authority. |
| Projections/traces | Index may summarize proof results; no trace authority. |
| Projected value/failure | Must state explanatory evidence only. |

Digest/stability stance:

- Index points to accepted proof summaries and digests.
- It does not guarantee artifact availability, recomputation, or canonical shape.

Promotion risks:

- Can accidentally become canon by repetition.
- Can blur proof-local evidence and accepted language behavior if wording is too
  broad.

Required blockers before future route:

- Status / Spec Curator authorization.
- Decide target: current-status, Heat Map pointer, spec README pointer, or
  track-only index.
- Preserve separate L1 and L2b rows unless a later decision merges them.

Verdict:

```text
useful companion, not sufficient as the artifact-home answer
```

---

## Option D: Internal Non-Canonical Carrier

Summary:

```text
define an internal object/envelope that can carry source-backed Level 2 evidence
with explicit no-authority posture
```

Authority:

| Area | Authority |
| --- | --- |
| Source refs | Carrier may validate shape and digest syntax only, not source truth. |
| Input snapshots | Carrier may validate frozen/no-mutation flags and digest references. |
| Premise sets | Carrier may validate explicit premise shape; assumptions remain premise capsule only. |
| Projections/traces | Carrier may carry isolated projection evidence; no runtime/cache/report authority. |
| Projected value/failure | Carrier must mark values/failures as projected and non-actual. |

Digest/stability stance:

- May define deterministic serialization for carrier payload.
- Must not imply SemanticIR schema, compiler artifact schema, or report schema.

Promotion risks:

- Very easy to overread as implementation route.
- Could become accidental public/internal API.
- Could pressure report/result fields before surface gates.

Required blockers before future route:

- Option B or equivalent proof-owned home accepted first, or a decision that B
  is unnecessary.
- Exact candidate write scope.
- Internal-only result shape.
- No root require and no compiler pipeline integration.
- Closed-surface scan covering `lib/**`, reports, `.igapp`, RuntimeSmoke,
  CompatibilityReport, API/CLI, Spark, and release docs.
- Bridge review before any loader/report/public/API consideration.

Verdict:

```text
promising later, hold until proof-owned home and authority fields are designed
```

---

## Option E: Compiler-Emitted Artifact, Comparison Only

Summary:

```text
compiler emits source-backed branch-intention or counterfactual audit artifacts
```

Authority:

| Area | Authority |
| --- | --- |
| Source refs | Would become compiler-owned evidence refs. |
| Input snapshots | Unclear; compiler normally should not own runtime input snapshots. |
| Premise sets | Would pressure source syntax or assumptions integration. |
| Projections/traces | Would exceed current compiler role if projections are included. |
| Projected value/failure | Would risk implying compile-time what-if results. |

Digest/stability stance:

- Would require compiler artifact schema and likely `.igapp`/SemanticIR/report
  decisions.

Promotion risks:

- Breaks current separation between compiler support and counterfactual audit
  proof evidence.
- Risks branch-level assumptions syntax, SemanticIR schema mutation, `.igapp`
  schema mutation, or public all-grammar claims.

Required blockers before any future consideration:

- Dedicated compiler artifact proposal or spec route.
- TypeChecker/SemanticIR ownership decision.
- `.igapp`/assembler/report boundary decision.
- Runtime/Bridge and Status/Spec review.

Verdict:

```text
comparison only; reject as next route
```

---

## Option F: Report/Result/Receipt Sidecar, Comparison Only

Summary:

```text
store source-backed counterfactual evidence in CompilerResult,
CompilationReport, receipts, CompatibilityReport, or a sidecar
```

Authority:

| Area | Authority |
| --- | --- |
| Source refs | Would become report/readiness evidence. |
| Input snapshots | Would raise privacy, persistence, and reproducibility questions. |
| Premise sets | Would pressure receipt semantics and assumptions authority. |
| Projections/traces | Would risk becoming support/debug/public API surface. |
| Projected value/failure | Would risk being read as actual result/failure or product promise. |

Digest/stability stance:

- Requires explicit report/result/receipt schema and persistence policy.
- Cannot inherit authority from R211 proof digests.

Promotion risks:

- Highest overclaim risk after public API/Spark.
- Could mutate public/private result key sets or accepted release evidence.
- Could imply runtime support before runtime authority exists.

Required blockers before any future consideration:

- Report/result/receipt surface survey.
- CompatibilityReport boundary review.
- Public/private exposure policy.
- Persistence/privacy policy for snapshots and premise sets.
- Runtime/Bridge review.

Verdict:

```text
comparison only; reject as next route
```

---

## Authority Field Policy For Any Future Non-Proof-Local Route

Any future non-proof-local route must define these fields before implementation:

| Field Area | Minimum Policy |
| --- | --- |
| Source refs | Must name source kind, source path/ref, digest, derivation, canonical flag, and authority flags. |
| Input snapshots | Must name frozen/mutable status, digest, source, persistence posture, and privacy posture. |
| Premise sets | Must name assumed condition, assumed condition source, premise digest, and assumptions relationship. |
| Projections | Must name isolated projection scope, refusal policy, selected/latent branch role, and no-authority flags. |
| Traces | Must be proof/debug/explanatory only; no cache/dependency/report authority. |
| Projected values/failures | Must be disclaimed as projected, non-actual, non-runtime, non-reportable unless separately authorized. |
| Digests | Must state whether digests are evidence anchors, recomputation commitments, or merely local checks. |

Default authority flags:

```text
canonical: false
runtime_authority: false
report_authority: false
cache_authority: false
dependency_authority: false
public_api_authority: false
compiler_emitted: false
spark_authority: false
production_authority: false
```

---

## Preserved Boundaries

Preserved:

- L1 / L2a / L2b separation.
- RuntimeSmoke proof-context wording:

```text
RuntimeSmoke proof-context paths may transitively load the proof RuntimeMachine
and SemanticIRExpressionEvaluator. This is a known consequence of proof harness
wiring, not RuntimeSmoke feature support, not public runtime support, not API
support, and not a production/runtime claim. RuntimeSmoke result shape remains
unchanged.
```

- Live runtime remains lazy: non-selected branches are not evaluated.
- Assumptions remain premise capsule only:
  - no branch-level `uses assumptions`;
  - no PROP-032 amendment;
  - no receipt `assumption_refs`;
  - no source syntax expansion.

---

## Recommended Route For C4-A

Preferred:

```text
accept this options matrix
choose Option B as the next bounded design/proof route
keep Option C as a companion/docs-index route after or alongside B
hold Option D until B clarifies artifact-home and authority fields
reject Options E/F as next routes
```

Recommended next card:

```text
counterfactual-audit-proof-owned-artifact-home-design-v0
```

Goal for that route:

```text
Design the exact proof-owned, non-canonical artifact home and authority field
policy for source-backed Level 2 counterfactual audit evidence, without
compiler emission, report/result/receipt fields, runtime support, public API,
cache/dependency authority, release claims, or Spark authority.
```

Backup:

```text
accept this matrix and hold all non-proof-local homes
```

Not recommended:

```text
runtime/report/API design immediately
compiler-emitted artifact design immediately
report/result/receipt sidecar design immediately
public artifact format selection
```

---

## Blocker List Before Any Future Route

Before Option B can move beyond design:

- exact artifact-home path and ownership;
- proof-owned manifest or index shape, if any;
- no-authority field requirements;
- digest recomputation policy;
- privacy/persistence stance for input snapshots;
- premise-set validation boundary;
- R211 parity proof matrix;
- closed-surface scan matrix;
- Status/Spec wording guard if any index is added.

Before Option D can open:

- Option B accepted or explicitly bypassed;
- internal carrier owner named;
- candidate write scope named;
- no root require, no compiler pipeline, no RuntimeSmoke, no report/result/API
  integration;
- Bridge review for later loader/report/public risks.

Before Options E/F can even be reconsidered:

- separate compiler artifact or report/result/receipt surface survey;
- Runtime/Bridge review;
- Status/Spec review;
- public/private exposure policy;
- explicit rejection of runtime/support overclaim paths.

---

## Closed Surfaces

Remain closed:

- code implementation;
- `lib/**`;
- parser, classifier, TypeChecker, SemanticIR, assembler, orchestrator;
- runtime/evaluator/RuntimeSmoke/proof RuntimeMachine behavior changes;
- live non-selected branch evaluation;
- source grammar and branch-level assumptions syntax;
- CompilerResult / CompilationReport mutation;
- report/result/receipt/CompatibilityReport fields;
- dependency/cache authority;
- TBackend/effect/external IO non-refusal;
- `.igapp`, manifests, sidecars, artifact hashes, goldens;
- body spec chapters, `docs/language-spec.md`, public docs, PROP-032;
- public API/CLI;
- release execution, release evidence, public demo/stable/production claims;
- Spark data, fixtures, ids, integration, demo, or production behavior.

---

## Compact Handoff

[D] Compared six artifact-home options for source-backed Level 2 evidence.

[S] Preferred next route is Option B: proof-owned artifact directory with no
compiler/report/runtime/public authority.

[T] Options E/F are comparison only and should not open next.

[R] C4-A should accept the matrix, choose Option B as the next bounded route,
and keep runtime/report/API/cache/public/Spark authority closed.

[Next] Open `counterfactual-audit-proof-owned-artifact-home-design-v0`, or hold
all non-proof-local homes if Portfolio wants no movement.
