# Stage 3 Round 254 Status Curation v0

Card: `S3-R254-C5-S`
Track: `stage3-round254-status-curation-v0`
Role: `status-curator`
Route: `SUMMARY`
Status: `done / accepted`
Date: 2026-06-06

## Summary

R254 accepted proof-local contract invocation forms SemanticIR lowering
evidence. FSL-1..FSL-16 are accepted as satisfied inside the lab compiler
proof. The accepted lowering target is only the existing explicit `call` shape
plus proof-local `lowered_from_form` metadata; it is not canonical SemanticIR
vocabulary and does not create implementation authority.

Import hiding/overriding remains the held gap before any implementation-facing
forms route. The exact next Main Line dispatch is the reserved repository split
boundary at `S3-R255-C1-D`. The next forms lane is carried as a post-R255
candidate: `S3-R256-C1-A`
`contract-invocation-forms-import-hiding-overriding-proof-authorization-review-v0`.

No implementation, runtime, public, stable, release, performance,
certification, portability, repository migration, or lab-canon authority opens
in R254.

## Outcome Table

| Card | Artifact | Status | Notes |
| --- | --- | --- | --- |
| S3-R254-C1-A | `contract-invocation-forms-semanticir-lowering-design-authorization-review-v0.md` | authorized / proof-local-lab-only | Authorized bounded lab compiler proof only. |
| S3-R254-C2-I | `contract-invocation-forms-semanticir-lowering-proof-v0.md` | done / proof-local-lab-only | Produced proof, fixtures, summary JSON, and mainline proof track. |
| S3-R254-C3-X | `contract-invocation-forms-semanticir-lowering-proof-pressure-v0.md` | conditional accept | Proof acceptable; import hiding/overriding remains next-route guard. |
| S3-R254-C4-A | `contract-invocation-forms-semanticir-lowering-proof-acceptance-decision-v0.md` | accepted | Accepts evidence, preserves R255, carries forms hardening after R255. |
| S3-R254-C5-S | this track | done | Current status updated with compact route delta. |

## Proof-Local Forms Lowering Status

| Surface | Status |
| --- | --- |
| Evidence class | Proof-local lab-frontier evidence only. |
| FSL-1..FSL-16 | Accepted: all PASS in proof doc and summary JSON. |
| Command matrix | Accepted: required commands PASS or expected `oof`; R252 regression rerun PASS. |
| Lowering target | Accepted as explicit `call` shape plus proof-local `lowered_from_form` metadata only. |
| Canonical SemanticIR vocabulary | Closed; no canonical `ContractInvocation` node is accepted. |
| Typed-dispatch reuse | Accepted: reuses R252 evidence, not a stable TypeChecker API. |
| Sidecar vs lowered IR | Sidecars remain audit/provenance; accepted ok SemanticIR carries lowered call shape. |
| `.igapp` generation | Accepted as compiler artifact inspection only; execution remains closed. |
| VM linker / subroutine frames | Deferred and closed. |

## FSL Matrix Summary

| Range | Status |
| --- | --- |
| FSL-1..FSL-5 | PASS: explicit call target, R252 typed evidence reuse, numeric/Additive `+`, `++`, and explicit-call bypass. |
| FSL-6..FSL-10 | PASS: ambiguity/declaration-order/unresolved/no_form failures stay closed; primitive pass-through remains primitive. |
| FSL-11..FSL-14 | PASS: sidecar trace links source/candidate/target; resolved calls avoid generic `binary_op`; no runtime table, VM linker, or subroutine frames. |
| FSL-15 | PASS with held gap: import hiding/overriding remains held, not implementation-ready. |
| FSL-16 | PASS: closed-surface scan accepted. |

## Exact Next Dispatch

Open the reserved repository split boundary next:

```text
Card: S3-R255-C1-D
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: igniter-lang-repository-split-boundary-and-migration-plan-v0
Route: UPDATE
Depends on:
- S3-R254-C4-A
```

Route type:

```text
design boundary / migration-plan boundary only
```

This does not authorize repository migration, `git subtree split`,
`git filter-repo`, remote push, release execution, package rename, public
claims, CI/package changes, framework-to-language authority transfer, or lab
behavior as canon.

## Deferred Forms Route

Carry the next forms technical lane as a post-R255 candidate:

```text
Card: S3-R256-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: contract-invocation-forms-import-hiding-overriding-proof-authorization-review-v0
Route: UPDATE
Depends on:
- S3-R254-C4-A
- S3-R255-C5-S if present
```

Expected route type:

```text
proof-local lab compiler authorization review
```

Expected focus:

- prove import hiding/overriding candidate visibility before lowering;
- preserve R252 typed filtering;
- preserve R254 explicit call lowering;
- preserve `E-FORM-AMBIG` and declaration-order rejection;
- preserve unresolved/no_form fail-closed behavior;
- preserve explicit-call bypass and primitive pass-through;
- keep sidecars audit/provenance only;
- keep runtime, VM linker, `.igapp` execution, stable grammar, public API,
  release, performance, certification, portability, and lab-canon authority
  closed.

R253 already deferred PROP-039 proof-local fixtures to `S3-R256-C1-A` or later
by explicit accepted routing decision. R254 names forms import
hiding/overriding as the next forms lane after R255. This packet does not
renumber the post-R255 lanes; R255 or later route curation must keep the
post-R255 sequencing explicit without consuming the reserved R255 boundary.

## S3-R255 Reservation Preservation

`S3-R255` remains reserved for:

```text
S3-R255-C1-D
igniter-lang-repository-split-boundary-and-migration-plan-v0
```

The reservation does not authorize repository migration, `git subtree split`,
`git filter-repo`, remote push, release execution, package rename, public
claims, CI/package changes, framework-to-language authority transfer, or lab
behavior as canon.

## Closed Surfaces

Closed:

- live mainline implementation;
- parser / TypeChecker / SemanticIR implementation;
- runtime / API / CLI / package changes;
- stable grammar / public API;
- `igc run` widening;
- `.igapp` or `.igbin` execution;
- compiler passport emission;
- RuntimeSmoke productization;
- public runtime support;
- Reference Runtime support;
- production readiness;
- Spark integration;
- release execution or release evidence;
- public demo or public performance claims;
- official/reference status;
- alternative certification;
- portability guarantees;
- repository migration;
- R255 consumption by a non-repository-split route;
- lab behavior as canon.
