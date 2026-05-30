# Counterfactual Audit Runtime Report API Gate Survey v0

Card: S3-R215-C2-P1
Agent: [Research Agent #1]
Role: research-agent
Track: counterfactual-audit-runtime-report-api-gate-survey-v0
Route: UPDATE
Depends on:
- S3-R214-C4-A
Status: done
Date: 2026-05-30

## Role And Neighbors

Assigned track: survey the minimum gates required before any runtime/report/API
design can open from the Counterfactual Audit Lane.

Affected neighbor roles:
- Compiler/Grammar Expert: owns lane-map, language-boundary, and artifact-home
  design routes.
- Bridge/Runtime owners: own runtime, RuntimeSmoke, proof RuntimeMachine,
  report/result/receipt/cache, and CompatibilityReport authority.
- Portfolio/Status owners: own gate sequencing, public-claim fences, and any
  later low-authority map/status sync.

## Current Horizon

- R214 accepted the Counterfactual Audit Lane as layered: L1, L2a, L2b, L3,
  and future L4.
- R215 C1-D lane map exists as design-only evidence and lists gates before L4.
- Runtime-debt / time-to-market pressure remains non-authorizing context.
- RuntimeSmoke proof-context evidence is not feature support.
- Runtime/report/API design cannot open until L3 artifact-home and authority
  questions close.

## Inputs Read

- `igniter-lang/docs/tracks/stage3-round214-status-curation-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-lane-consolidation-decision-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-internal-lane-map-v0.md`
- `igniter-lang/docs/tracks/counterfactual-audit-runtime-debt-and-time-to-market-pressure-survey-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-runtime-smoke-consumer-proof-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-proof-runtime-consumer-implementation-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-live-runtime-evaluator-implementation-acceptance-decision-v0.md`
- `igniter-lang/lib/igniter_lang/runtime_smoke.rb`
- `igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb`
- `igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb`

## Fixed Point

Current evidence is strong but bounded:

- Live internal evaluator: accepted direct-require-only support for selected
  branch lazy `if_expr`.
- Proof RuntimeMachine: accepted experiment-owned adapter path that delegates
  `if_expr` selection to the evaluator and keeps `apply`, `field_access`, and
  `tbackend_read` local.
- RuntimeSmoke: accepted proof-context consumer evidence only, with unchanged
  source/result shape.
- Counterfactual audit: accepted proof-local source-backed Level 2 evidence,
  not runtime/report/API authority.

This means the next useful gate is not runtime implementation. It is L3:
artifact home plus authority model.

## Compact Gate Table

| Gate | Required before runtime/report/API design | Current evidence | Blocker status |
| --- | --- | --- | --- |
| G1 Lane map accepted | L1/L2a/L2b/L3/L4 definitions, owner handoffs, blocked promotion paths | R215 C1-D lane map exists as design-only input | Needs C4-A acceptance if not already accepted |
| G2 Artifact-home decision | Decide proof-local forever vs internal carrier vs other home | R211 proof-owned artifacts; R215 lane map says L3 required | Open |
| G3 Authority model | Define authority for `source_branch_intention_ref`, input snapshot, premise set, projection, and source evidence | R211 no-authority proof fields | Open |
| G4 Runtime/Bridge review | Review evaluator/proof RuntimeMachine/RuntimeSmoke boundaries and non-selected branch isolation | R199/R201/R203 accepted proofs | Open for L3/L4 review, not implementation |
| G5 Report/result/receipt survey | Decide whether these stay closed or whether a design-only route may consider one | Current surfaces closed | Open, must precede any field design |
| G6 Dependency/cache stance | Reaffirm no dependency/cache authority or open a separate design route | `call_trace` proof/debug only; static dependency union | Open for reaffirmation |
| G7 TBackend/effect policy | Preserve dry-run refusal or open separate temporal/effect gate | R211 refuses `tbackend_read`, escape/effect/external IO | Closed unless later gate opens |
| G8 Public/API/release/Spark gate | Separate authority before any public/API/CLI/Spark/demo/release wording | Repeatedly closed | Closed |
| G9 Regression evidence bundle | Pin proof commands and summary hashes before any L4 design pressure | R199/R201/R203/R211 proof counts exist | Needs current bundle if L4 ever opens |

Minimum answer: runtime/report/API design remains blocked until G1 through G6
close at least as design decisions, while G7 and G8 remain explicit refusals or
separate gates.

## Runtime Gate Inventory

| Runtime gate | Required decision | Current proof evidence | Missing authority |
| --- | --- | --- | --- |
| Runtime scope | Is any counterfactual runtime surface desired, or should runtime stay selected-branch-only? | Live evaluator is selected-branch-only and lazy. | No authority for latent branch live evaluation or runtime dry-run. |
| Evaluator boundary | Can `SemanticIRExpressionEvaluator` remain internal direct-require-only? | R199 accepted direct-require-only, not root-required. | No public/root require/API guarantee. |
| Proof RuntimeMachine boundary | Is proof RuntimeMachine evidence enough for future design, or does production runtime need separate modeling? | R201 accepted experiment-owned consumer path. | No production RuntimeMachine authority. |
| RuntimeSmoke wording | Does proof-context consumer evidence remain non-support? | R203 accepted maximum claim and unchanged result shape. | No feature support claim. |
| Non-selected branch invariant | Must live runtime continue never evaluating non-selected branches? | R199/R201 prove non-selected branch isolation. | No eager latent execution authority. |
| Expression ownership | Who owns `apply`, `field_access`, `tbackend_read` if dry-run ever moves? | Proof RuntimeMachine owns them now. | No production owner decision. |
| Error/diagnostic shape | Should runtime errors ever get canonical diagnostics? | Evaluator exceptions are internal/non-canonical. | No OOF-RT, Diagnostics, CompilationReport integration. |
| TBackend/effect/external IO | Should refusal remain permanent or become parameterized? | R211 refuses live reads/effects/IO. | No non-refusal path authority. |

Runtime gate conclusion: only selected-branch internal runtime is live. Every
counterfactual/dry-run runtime surface is still blocked by artifact-home,
authority, dependency/cache, TBackend/effect, and public-support gates.

## Report / Result / Receipt / API Gate Inventory

| Surface | Gate question | Current status | Exact blocker |
| --- | --- | --- | --- |
| `CompilerResult` | Should projections or source refs ever appear in result objects? | Closed; no counterfactual fields. | Requires report/result surface survey plus authority model. |
| `CompilationReport` | Should proof-local dry-run evidence ever appear in compilation reports? | Closed; source-backed ref is explicitly not a report field. | Requires schema/diagnostic design and non-authority wording. |
| Receipt/audit envelope | Should dry-run projection create a receipt-like object? | Closed. | Requires receipt semantics, persistence decision, and no-confusion with actual output/failure. |
| CompatibilityReport | Should compatibility consume any counterfactual metadata? | Closed. | Requires Bridge decision; current proof says no runtime readiness authority. |
| Public API | Should callers invoke dry-run/counterfactual audit through Ruby API? | Closed. | Requires public API gate, product wording, and release/support boundary. |
| CLI | Should `igc` expose counterfactual commands? | Closed. | Requires CLI/API gate and no public support overclaiming. |
| Spark/API/demo | Should Spark or external API use this lane? | Closed. | Requires separate product/Spark authorization; not a validation shortcut. |

Report/API gate conclusion: no report/result/receipt/API design should open
until artifact-home and authority decisions define whether there is even a
non-proof-local object to report.

## Dependency / Cache Gate Inventory

| Gate | Current stance | Required before design opens |
| --- | --- | --- |
| Static dependency union | Current compiler/runtime boundary; selected-path dependency tracking deferred | Decide whether L4 keeps static union or opens a separate dynamic-dependency design route |
| `call_trace` | Proof/debug evidence only | Reaffirm it is not dependency, cache, receipt, or report authority |
| Projection trace | Proof-local explanatory trace only | Define whether trace is artifact metadata, report metadata, or permanent proof-local detail |
| Cache keys | No path-sensitive cache keys | Separate cache-key design gate required before any runtime/cache exposure |
| Invalidation/freshness | No projection-driven invalidation | Separate runtime/cache/invalidation gate required |
| TBackend temporal read | Refused in dry-run proof | Separate temporal/TBackend authority gate required for non-refusal |

Dependency/cache conclusion: cache and dependency authority must stay closed
unless a dedicated cache/dependency design route opens after artifact-home and
authority decisions.

## Artifact-Home Options

| Option | Description | Benefit | Risk | Current recommendation |
| --- | --- | --- | --- | --- |
| Permanent proof-local only | Keep projections under experiment `out/` forever | Maximum safety, no runtime/report pressure | Limits product/tool reuse | Safe default |
| Internal docs/status index | Track accepted evidence anchors in docs only | Reduces drift without schema | Not machine-consumable | Safe as map/status sync if authorized |
| Proof-owned artifact directory | Keep generated proof artifacts as evidence but not compiler output | Repeatable source-backed proofs | Can be mistaken for canonical artifact | Acceptable if fenced |
| Internal carrier object | Define non-canonical internal carrier for lane tooling | Clarifies source refs and authority fields | Starts looking like product surface | Needs L3 design and Bridge review |
| Compiler-emitted artifact | Compiler emits branch-intention/projection evidence | Strong traceability | High schema/report/runtime pressure | Not recommended now |
| Report/result/receipt sidecar | Attach projection to report/result/receipt path | Product-friendly | Very high authority confusion | Hold until many gates close |

Recommended L3 starting point:

```text
counterfactual-audit-artifact-home-and-authority-options-v0
```

It should compare only proof-local, docs/status index, proof-owned artifacts,
and internal carrier options first. It should not jump directly to compiler
emission or report/result/receipt sidecars.

## Proof Evidence Versus Missing Authority

| Evidence | Proves | Does not authorize |
| --- | --- | --- |
| R199 live evaluator 68/68 | Internal selected-branch lazy evaluation for `literal`, `ref`, `if_expr` | Runtime dry-run, public API, reports, dependency/cache authority |
| R201 proof RuntimeMachine 56/56 | Experiment-owned adapter can evaluate selected `if_expr` branches and delegate selected unsupported kinds | Production runtime, RuntimeSmoke feature support, dynamic dependencies |
| R203 RuntimeSmoke consumer 53/53 | Existing RuntimeSmoke can consume proof-owned if_expr `.igapp` artifacts through proof RuntimeMachine | Public/stable RuntimeSmoke support or result-shape change |
| R211 source-backed proof 61/61 | Proof-owned SemanticIR-shaped artifacts, frozen inputs, digest refs, premise sets support isolated projection | Canonical schema, report/result/receipt field, runtime support |
| R213 docs sync | Low-authority discoverability in internal navigation docs | Spec body, public docs, runtime/report/API/Spark claim |
| R214 lane consolidation | L1/L2a/L2b can be operationally mapped | Schema consolidation or L4 opening |
| R215 lane map | Gate list and route memory | Runtime/report/API implementation |

## Exact Blockers Before Runtime / Report / API Design

Runtime/report/API design must remain closed until these blockers are resolved:

1. Lane map accepted as the controlling L1/L2a/L2b/L3/L4 route map.
2. Artifact-home option selected or explicitly held.
3. Authority model defined for source refs, snapshots, premise sets,
   projection traces, and projected values/failures.
4. Runtime/Bridge review confirms evaluator, proof RuntimeMachine,
   RuntimeSmoke, and non-selected branch isolation boundaries.
5. Report/result/receipt/CompatibilityReport survey decides whether surfaces
   stay closed or whether one design-only route may open.
6. Dependency/cache stance is reaffirmed or separately routed.
7. TBackend/effect/external IO refusal remains binding or receives a separate
   temporal/effect gate.
8. Public API/CLI/release/Spark gates remain explicitly closed unless a later
   authority opens them.
9. Regression bundle is named for R199/R201/R203/R211 before any L4 pressure.
10. Diagnostics namespace decision is made if runtime-facing failures are ever
    considered.
11. No non-selected branch live evaluation is introduced.
12. No "proof-context RuntimeSmoke evidence == feature support" wording appears.

## Recommended Next Route After Lane-Map Acceptance

Preferred next route:

```text
counterfactual-audit-artifact-home-and-authority-options-v0
```

Why:
- It is the smallest L3 route that directly blocks L4.
- It turns the current proof-local evidence into a clear "home or no home"
  decision before anyone designs report/result/API/runtime surfaces.
- It can preserve the time-to-market benefit of route clarity without opening
  implementation.

Alternative if Portfolio wants one more pressure pass:

```text
counterfactual-audit-runtime-report-api-gate-pressure-v0
```

Not recommended next:
- runtime implementation;
- report/result/receipt field design;
- RuntimeSmoke feature support design;
- public API/CLI design;
- Spark/demo route;
- dependency/cache design before artifact-home and authority model.

## Command Matrix

| Command | Result |
| --- | --- |
| `rg "if_expr\|counterfactual audit\|RuntimeSmoke\|proof-context\|without authorizing" /Users/alex/.codex/memories/MEMORY.md` | PASS, memory quick pass |
| `ls igniter-lang/docs/tracks \| rg 'stage3-round214\|lane-consolidation\|runtime-debt\|counterfactual-audit-runtime-report-api-gate'` | PASS, located inputs |
| `sed -n '1,260p' igniter-lang/docs/tracks/stage3-round214-status-curation-v0.md` | PASS |
| `sed -n '1,280p' igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-lane-consolidation-decision-v0.md` | PASS |
| `sed -n '1,320p' igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-internal-lane-map-v0.md` | PASS |
| `sed -n '1,260p' igniter-lang/docs/tracks/counterfactual-audit-runtime-debt-and-time-to-market-pressure-survey-v0.md` | PASS |
| `sed -n '1,220p' igniter-lang/docs/tracks/branch-conditional-if-expr-runtime-smoke-consumer-proof-acceptance-decision-v0.md` | PASS |
| `sed -n '1,220p' igniter-lang/docs/tracks/branch-conditional-if-expr-proof-runtime-consumer-implementation-acceptance-decision-v0.md` | PASS |
| `sed -n '1,220p' igniter-lang/docs/tracks/branch-conditional-if-expr-live-runtime-evaluator-implementation-acceptance-decision-v0.md` | PASS |
| `sed -n '1,220p' igniter-lang/lib/igniter_lang/runtime_smoke.rb` | PASS, read-only |
| `sed -n '1,120p' ... semanticir_expression_evaluator.rb; sed -n '140,260p' ...` | PASS, read-only |
| `sed -n '1,40p' ... compiled_program.rb; sed -n '377,425p' ...; sed -n '661,690p' ...` | PASS, read-only |

No executable proof was required or run. No code was changed.

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/counterfactual-audit-runtime-report-api-gate-survey-v0
Status: done
Neighbors: Compiler/Grammar Expert | Bridge Agent | Research Agent

[D] Decisions:
- Runtime/report/API design remains blocked by L3 artifact-home and authority
  decisions.
- RuntimeSmoke proof-context evidence remains non-support.
- Runtime-debt and time-to-market pressure remain non-authorizing context.

[R] Recommendations:
- After lane-map acceptance, open
  counterfactual-audit-artifact-home-and-authority-options-v0.
- Keep report/result/receipt/API/runtime implementation closed until the exact
  gate list is satisfied.
- Preserve non-selected branch laziness and no dependency/cache authority.

[S] Signals:
- R199/R201/R203/R211 proofs are strong evidence anchors.
- Missing authority is concentrated around artifact home, authority model,
  report/result/receipt/API, dependency/cache, and TBackend/effect policy.

[T] Tests / Proofs:
- Read-only survey commands PASS.
- No new proof/test was required.

[Files] Changed:
- igniter-lang/docs/tracks/counterfactual-audit-runtime-report-api-gate-survey-v0.md

[Q] Open Questions:
- Does L3 choose permanent proof-local status or an internal non-canonical
  carrier?
- Do report/result/receipt surfaces remain permanently closed or get a later
  design-only survey?
- Does any internal tool-only use case exist that does not require runtime/API
  support?

[X] Rejected:
- Runtime implementation as the next step.
- Treating RuntimeSmoke proof-context evidence as feature support.
- Opening report/result/receipt/API/cache/Spark/public design before L3 closes.

[Next] Proposed next slice:
- counterfactual-audit-artifact-home-and-authority-options-v0
```
