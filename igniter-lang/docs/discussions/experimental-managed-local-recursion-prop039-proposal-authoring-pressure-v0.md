# Experimental Managed Local Recursion PROP-039 Proposal Authoring Pressure v0

Card: S3-R251-C3-X  
Skill: IDD Agent Protocol  
Agent: External Pressure Reviewer  
Role: external-pressure-reviewer  
Track: experimental-managed-local-recursion-prop039-proposal-authoring-pressure-v0  
Route: REVIEW  
Status: done / accept  
Date: 2026-06-05  

Depends on:
- S3-R251-C1-A
- S3-R251-C2-I

## Pressure Verdict

ACCEPT.

S3-R251-C2-I stayed inside the S3-R251-C1-A proposal-authoring write scope and preserved the intended authority split. The authored PROP-039 text is proposal authority only, not implementation, runtime, public, stable, Reference Runtime, certification, portability, or lab-canon authority.

No hold or redirect is required before C4-A acceptance.

## Inputs Reviewed

- `igniter-lang/docs/tracks/experimental-managed-local-recursion-prop039-proposal-authoring-authorization-review-v0.md`
- `igniter-lang/docs/tracks/experimental-managed-local-recursion-prop039-proposal-authoring-v0.md`
- `igniter-lang/docs/proposals/PROP-039-managed-local-recursion-and-loop-classes-v0.md`
- `igniter-lang/docs/proposals/README.md`
- `igniter-lang/docs/tracks/experimental-managed-local-recursion-prop039-authoring-boundary-decision-v0.md`
- `igniter-lang/docs/tracks/experimental-loops-recursion-proof-fixture-acceptance-decision-v0.md`
- `igniter-lang/docs/cards/S3/S3-R251.md`

## Write-Scope Pressure

PASS.

C1-A authorized edits only to:
- `igniter-lang/docs/proposals/PROP-039-managed-local-recursion-and-loop-classes-v0.md`
- `igniter-lang/docs/proposals/README.md`
- `igniter-lang/docs/tracks/experimental-managed-local-recursion-prop039-proposal-authoring-v0.md`

C2-I reports only those files changed. Closed surfaces remained closed: `igniter-lang/lib/**`, `bin/igc`, gemspecs, root README, guide/dev/spec docs, `source/**`, `experiments/**`, `playgrounds/**`, runtime/public/release/performance/certification/portability surfaces, Spark integrations, `.igapp`, `.igbin`, compiler passport, RuntimeSmoke, and Reference Runtime claims.

## Boundary Pressure Matrix

| Pressure point | Verdict | Notes |
| --- | --- | --- |
| Bounded local loop wording | PASS | Finite loops are presented as local finite-collection repetition. R248 `for ... max_steps: claims.count` remains pressure only, not canonical grammar. |
| Structural recursion wording | PASS | `recursive contract` is proposal vocabulary tied to structural decreases and future checker work. No execution path is claimed. |
| Fuel-bounded recursion wording | PASS | `fuel_bounded contract` is kept separate from structural recursion and tied to static fuel/budget semantics. |
| `decreases fuel` | PASS | Explicitly treated as a shorthand candidate only. It does not merge structural and fuel-bounded recursion by default. |
| `for` / `loop` split | PASS | `for` is finite collection iteration; `loop` is budgeted local repetition. The split is proposal-level and not parser authority. |
| Static-first `max_steps` | PASS | Static literal budgets are the first-v0 direction. Dynamic budgets remain deferred/held. |
| Service-loop / PROP-037 exclusion | PASS | Service liveness, progression descriptors, `clock.every`, materialization, checkpoints, cancellation, backpressure, and receipts remain PROP-037-owned. |
| `tick.time` / `tick.event_id` | PASS | `tick.time` remains PROP-037 event-time binding only. `tick.event_id` remains unaccepted pressure, not PROP-039 authority. |
| `now()` / OOF-L6 | PASS | Source-level `now()` prohibition remains anchored to Chapter 8 `OOF-L6`; PROP-039 does not replace it. |
| OOF-L / OOF-R candidates | PASS | OOF-L and OOF-R names are candidate diagnostics only. No registry authority is claimed. OOF-SL remains PROP-037 companion pressure. |
| Postulate 28 loop naming | PASS | Named loop/recursion forms are used as proposal pressure. Parser enforcement and final diagnostics remain future work. |
| `break` deferral | PASS | `break` remains deferred and unsupported in v0 proposal semantics. |
| Fixture/lab evidence | PASS | R248 fixtures and igniter-lab/Rust evidence are described as non-authoritative pressure/frontier evidence only. |
| Implementation and public claims | PASS | Parser, TypeChecker, SemanticIR, runtime, VM/linker, CLI, package, stable API, production, release, performance, certification, and portability claims remain closed. |

## Claim-Risk Notes

No blocking claim drift found.

Non-blocking risks for C4-A to record:

1. `OOF-L1..L5` is a candidate diagnostic namespace while Chapter 8 already uses `OOF-L6` for source-level `now()`. PROP-039 labels these as candidates and includes an open namespace question, so this is acceptable now. Any future diagnostic registry route should settle numbering before acceptance.
2. The phrase that `decreases fuel` is "accepted here as a proposal candidate only" must remain scoped to proposal-candidate acceptance. It is not grammar, parser, TypeChecker, SemanticIR, or fixture-canon acceptance.
3. `BudgetedLocalLoop` is newly introduced proposal vocabulary. It is acceptable as PROP-039 proposal terminology, but it must not be treated as Chapter 13 spec authority, implementation class authority, or public documentation authority until governance accepts it.

## C4-A Recommendation

Exact recommendation:

```text
ACCEPT bounded PROP-039 proposal-authoring output.
ACCEPT touched docs as proposal-authoring evidence only.
KEEP parser, TypeChecker, SemanticIR, runtime, VM/linker, CLI, package, public, stable, production, release, performance, certification, portability, Reference Runtime, and lab-canon authority closed.
DO NOT open implementation next.
```

Recommended next route:

```text
experimental-managed-local-recursion-prop039-proof-fixture-authorization-review-v0
```

Recommended next-route boundary:
- Authorize proof-local specification fixtures for FiniteLoop, BudgetedLocalLoop, StructuralRecursion, FuelBoundedRecursion, static-first `max_steps`, `decreases fuel` shorthand pressure, and rejected/deferred forms.
- Preserve R248/R251 non-authority: fixtures may test proposal semantics, but do not make grammar, parser, TypeChecker, SemanticIR, runtime, public, stable, release, performance, certification, portability, or lab behavior canonical.
- Keep OOF-L / OOF-R / OOF-SL as candidate diagnostic names unless a separate registry/errata route is explicitly opened.

Secondary redirect only if C4-A wants namespace cleanup before fixtures:

```text
experimental-managed-local-recursion-prop039-oof-namespace-registry-boundary-v0
```

That redirect is optional, not blocking for C4-A acceptance, because the current PROP-039 wording already marks diagnostic names as candidates and carries the namespace issue as an open question.
