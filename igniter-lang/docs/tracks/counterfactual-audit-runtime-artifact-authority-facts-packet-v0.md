# Counterfactual Audit Runtime Artifact Authority Facts Packet v0

Card: S3-R217-C2-P1
Agent: Research Agent #1
Role: research-agent
Track: counterfactual-audit-runtime-artifact-authority-facts-packet-v0
Route: UPDATE
Depends on: S3-R217-C1-D
Status: complete

## Purpose

Produce a facts packet for artifact-home and authority decisions around
source-backed Level 2 counterfactual audit evidence.

This packet is decision support for C4-A. It does not authorize implementation,
public claims, runtime/report/API design, or any compiler/report/runtime surface
change.

## Inputs Read

- `stage3-round216-status-curation-v0.md`
- `counterfactual-audit-runtime-debt-and-time-to-market-decision-v0.md`
- `counterfactual-audit-runtime-debt-facts-packet-v0.md`
- `counterfactual-audit-artifact-home-and-authority-options-v0.md`
- `branch-conditional-counterfactual-audit-level2-source-backed-proof-v0.md`
- `branch_conditional_counterfactual_audit_level2_source_backed_proof_v0_summary.json`

## Current Facts

R211 established proof-local source-backed Level 2 evidence:

- proof-owned SemanticIR-shaped JSON source artifacts;
- SHA-256 digest-addressed source refs, input snapshots, and premise sets;
- frozen input snapshots;
- explicit premise sets;
- isolated no-authority projection envelopes;
- PASS 61/61 in the source-backed proof.

R216 accepted the runtime-debt fact pattern:

- live runtime support is limited to selected-branch `if_expr` evaluation;
- proof RuntimeMachine and RuntimeSmoke evidence remain proof-context only;
- source-backed Level 2 has no accepted non-proof-local artifact home;
- authority is undefined for refs, snapshots, premises, projections, projected
  values/failures, and traces outside the proof.

R217 C1-D compared six artifact-home options and recommended Option B as the
next bounded design/proof route.

## Authority Inventory

| Evidence area | Current authority | What can be trusted now | What must remain false | Missing decision |
| --- | --- | --- | --- | --- |
| Source artifacts | R211 proof harness only | The proof wrote and digested its own SemanticIR-shaped JSON artifacts. | Not canonical SemanticIR schema authority, not compiler-emitted artifact authority. | Whether a proof-owned artifact home should be designated. |
| `source_branch_intention_ref` | R211 proof harness only | Ref includes source kind/path/digest in proof output. | Not a `CompilerResult`, `CompilationReport`, manifest, receipt, or public API field. | Ref authority fields for any non-proof-local home. |
| `input_snapshot_ref` | R211 proof harness only | Snapshot is frozen and digest-addressed inside the proof. | Not runtime input persistence, not report persistence, not privacy policy. | Snapshot persistence/privacy posture. |
| `premise_set` | R211 proof harness only | Premises are explicit and digest-addressed inside the proof. | Not PROP-032 receipt authority, not branch-level source syntax, not dependency/cache authority. | Premise-set validation boundary and assumption relationship. |
| Projection envelope | R211 proof harness only | Projection ran in isolated no-authority envelope. | Not actual runtime evaluation, not selected-path execution, not reportable output. | Projection authority flags and trace policy. |
| `projected_value` | R211 proof harness only | A calculated counterfactual projection value inside the proof. | `projected_value != actual_output`. | Whether any future artifact may carry projected value, and with what disclaimers. |
| `projected_failure` | R211 proof harness only | A calculated counterfactual projection refusal/failure label inside the proof. | `projected_failure != actual_runtime_failure`. | Whether any future artifact may carry projected failure, and with what disclaimers. |
| Trace/debug evidence | R211 proof harness only | Useful for explaining proof projection steps. | Not cache, dependency, report, runtime readiness, or public support authority. | Trace retention and redaction stance. |
| R209 execution summary refs | Read-only context only | Can compare actual-path proof context. | Not source authority for Level 2. | Whether to keep as citation-only evidence. |
| Compiler-emitted artifacts | Closed | Comparison target only. | No compiler emission for Level 2 evidence. | Separate compiler artifact design would be needed. |
| Report/result/receipt sidecars | Closed | Comparison target only. | No sidecar, report, receipt, `CompilerResult`, or `CompilationReport` authority. | Separate report/result/receipt design would be needed. |

## Evidence-Home Comparison

| Option | Route-debt reduction | Authority posture | Main risk | Recommendation |
| --- | --- | --- | --- | --- |
| A. Permanent proof-local only | Low | Proof harness only | Repeated reconstruction; no durable decision target | Safe fallback, not enough alone. |
| B. Proof-owned artifact directory | High | Proof artifact owner only; explicitly non-canonical | Mistaken for canonical artifact schema unless flags are strict | Best next route. |
| C. Internal docs/status index | Medium for discovery, low for validation | Citation/index only | Docs repetition can look like canon | Companion after or alongside B, not sufficient alone. |
| D. Internal non-canonical carrier | Medium-high later | Internal carrier could validate shape/digest syntax only | Accidental API/internal implementation surface | Premature; hold until B clarifies home and authority fields. |
| E. Compiler-emitted artifact | High but unsafe | Would require compiler artifact authority | Compiler/schema/report pressure | Comparison only; reject as next route. |
| F. Report/result/receipt sidecar | High but unsafe | Would require report/result/receipt authority | Highest overclaim and persistence risk | Comparison only; reject as next route. |

## Option Risk Table

| Option | Claim risk | Implementation pressure | Runtime/report/API pressure | Route debt left |
| --- | --- | --- | --- | --- |
| A | Low | None | None | High |
| B | Medium if poorly named; low with authority flags | Design/proof only | Low if report/runtime fields are forbidden | Low-medium |
| C | Medium canon-by-repetition risk | Docs/status only | Low-medium if wording drifts | Medium |
| D | High accidental internal API risk | Medium | Medium-high | Low if later accepted |
| E | High | High | High | Low but wrong route now |
| F | Very high | High | Very high | Low but wrong route now |

## Required Authority Flags

Any non-proof-local route must default to:

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

For Option B, the proof-owned artifact home should additionally make these
truths visible:

- source evidence is proof-owned and non-canonical;
- digest refs are evidence anchors, not language-schema commitments;
- projected values/failures are projection-only;
- traces are explanatory/debug evidence only;
- compiler, report, receipt, cache, runtime, public API, release, and Spark
  surfaces remain closed.

## Explicit Answers

Can any option reduce route debt without implementation?

Yes. Option B can reduce route debt as a design/proof route by naming a
proof-owned non-canonical artifact home and authority field policy. Option C can
reduce discovery debt as a companion. Option A is safe but leaves most route debt
in place. Options D/E/F should not be used as the immediate route.

Do compiler-emitted artifacts remain comparison-only?

Yes. Compiler-emitted artifacts remain comparison-only. Using them as a home for
Level 2 evidence would require separate compiler artifact authority and would
pressure SemanticIR, `.igapp`, reports, and release claims.

Do report/result/receipt sidecars remain comparison-only?

Yes. Report/result/receipt sidecars remain comparison-only. They require a
separate report/result/receipt surface decision and would risk implying public
support, persistence, or runtime authority.

Is an internal docs/status index enough?

No. It is useful for discoverability, but too weak as the sole authority home. It
can cite proof evidence; it cannot validate refs, snapshots, premises,
projections, traces, or digest stability.

Is an internal non-canonical carrier premature?

Yes for the next route. It is promising later, but should wait until Option B
defines the artifact home, authority fields, closed-surface scans, and owner
boundary.

## Promotion-Risk Notes

- `projected_value` must never be described as actual output.
- `projected_failure` must never be described as actual runtime failure.
- `source_branch_intention_ref` must not become a `CompilerResult` or
  `CompilationReport` field by implication.
- Proof-owned SemanticIR-shaped artifacts must not be described as canonical
  SemanticIR schema.
- RuntimeSmoke proof-context paths must not be described as RuntimeSmoke support.
- Digest-addressed proof refs must not be described as cache/dependency
  authority.
- A docs/status index must not become canon by repetition.
- A non-canonical carrier must not be root-required, compiler-consumed, or
  report/projected.

## Route Ranking For C4-A

1. Accept Option B next:
   `counterfactual-audit-proof-owned-artifact-home-design-v0`.
2. Allow Option C only as companion/index work after or alongside B:
   `counterfactual-audit-docs-status-index-sync-options-v0`.
3. Hold Option D until B clarifies artifact-home and authority fields:
   `counterfactual-audit-internal-noncanonical-carrier-options-v0`.
4. Keep Option A as fallback if Portfolio wants no non-proof-local movement.
5. Reject Option E as next route; compiler-emitted artifacts remain
   comparison-only.
6. Reject Option F as next route; report/result/receipt sidecars remain
   comparison-only.

## Closed Surfaces

Remain closed:

- implementation and `lib/**` edits;
- parser, classifier, TypeChecker, SemanticIR, assembler, orchestrator;
- runtime/evaluator/RuntimeSmoke/proof RuntimeMachine behavior changes;
- live non-selected branch evaluation;
- source grammar and branch-level assumptions syntax;
- CompilerResult and CompilationReport mutation;
- report/result/receipt/CompatibilityReport fields;
- dependency/cache authority;
- TBackend/effect/external IO non-refusal;
- `.igapp`, manifests, sidecars, artifact hashes, goldens;
- body spec chapters, `docs/language-spec.md`, public docs, PROP-032;
- public API/CLI;
- release execution, release evidence, public demo/stable/production claims;
- Spark data, fixtures, ids, integration, demo, or production behavior.

## Command Matrix

| Command | Result | Note |
| --- | --- | --- |
| `sed -n '1,260p' igniter-lang/docs/tracks/stage3-round216-status-curation-v0.md` | PASS | Read R216 status basis. |
| `sed -n '1,260p' igniter-lang/docs/tracks/counterfactual-audit-runtime-debt-and-time-to-market-decision-v0.md` | PASS | Read R216 decision. |
| `sed -n '1,260p' igniter-lang/docs/tracks/counterfactual-audit-runtime-debt-facts-packet-v0.md` | PASS | Read runtime-debt facts packet. |
| `sed -n '1,760p' igniter-lang/docs/tracks/counterfactual-audit-artifact-home-and-authority-options-v0.md` | PASS | Read C1-D options matrix. |
| `sed -n '1,260p' igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-source-backed-proof-v0.md` | PASS | Read R211 source-backed proof track. |
| `ruby -rjson -e '...' igniter-lang/experiments/branch_conditional_counterfactual_audit_level2_source_backed_proof_v0/out/branch_conditional_counterfactual_audit_level2_source_backed_proof_v0_summary.json` | PASS | Confirmed R211 summary shape: PASS 61/61 and no-authority claim policy. |

No code tests were run because this card is a read-only facts packet plus track
doc. No implementation artifacts were changed.

## Handoff

[D] R217 C2 confirms the authority problem is artifact-home and promotion risk,
not missing runtime implementation.

[S] Option B is the safest route-debt reducer: proof-owned, non-canonical
artifact home with explicit false authority flags.

[T] Compiler-emitted artifacts and report/result/receipt sidecars remain
comparison-only and should not open next.

[R] Recommend C4-A accept the facts packet and route to
`counterfactual-audit-proof-owned-artifact-home-design-v0`.

[Next] Define Option B path, artifact ownership, no-authority fields, digest
recomputation policy, snapshot privacy posture, and closed-surface scan matrix.
