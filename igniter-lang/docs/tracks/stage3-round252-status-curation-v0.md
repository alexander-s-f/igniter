# Stage 3 Round 252 Status Curation v0

Card: `S3-R252-C5-S`
Track: `stage3-round252-status-curation-v0`
Role: `status-curator`
Route: `SUMMARY`
Status: `done / accepted`
Date: 2026-06-05

## Summary

R252 accepted proof-local contract invocation forms type-directed dispatch
evidence. The proof satisfies FTD-1..FTD-12 inside the lab compiler proof
surface and records import hiding/overriding as a held gap.

This is accepted evidence only. It does not create mainline implementation,
stable grammar, canonical syntax, parser, TypeChecker, SemanticIR lowering,
runtime, VM linker, API, CLI, package, `.igapp`, `.igbin`, compiler passport,
RuntimeSmoke, public runtime, Reference Runtime, production, Spark, release,
public demo, performance, official/reference, certification, portability, or
lab-canon authority.

## Outcome Table

| Card | Artifact | Status | Notes |
| --- | --- | --- | --- |
| S3-R252-C1-A | `contract-invocation-forms-type-directed-dispatch-proof-authorization-review-v0.md` | authorized / proof-local-lab-only | Opened bounded lab compiler proof only. |
| S3-R252-C2-I | `contract-invocation-forms-type-directed-dispatch-proof-v0.md` | done / proof-local-lab-only | Implemented lab-only proof, fixtures, summary JSON, and proof track. |
| S3-R252-C3-X | `contract-invocation-forms-type-directed-dispatch-proof-pressure-v0.md` | done / accept | No blocking claim drift; import hiding/overriding carried as held gap. |
| S3-R252-C4-A | `contract-invocation-forms-type-directed-dispatch-proof-acceptance-decision-v0.md` | accepted | Accepts proof evidence and routes SemanticIR lowering design/proof authorization review next. |
| S3-R252-C5-S | this track | done | Current status updated with compact route delta. |

## Exact Changed Files

C2-I repo-tracked artifact:

- `igniter-lang/docs/tracks/contract-invocation-forms-type-directed-dispatch-proof-v0.md`

C2-I proof-reported lab files:

- `playgrounds/igniter-lab/igniter-compiler/src/form_resolver.rs`
- `playgrounds/igniter-lab/igniter-compiler/src/typechecker.rs`
- `playgrounds/igniter-lab/igniter-compiler/fixtures/forms/type_dispatch/ambiguity.ig`
- `playgrounds/igniter-lab/igniter-compiler/fixtures/forms/type_dispatch/concat_separate.ig`
- `playgrounds/igniter-lab/igniter-compiler/fixtures/forms/type_dispatch/declaration_order.ig`
- `playgrounds/igniter-lab/igniter-compiler/fixtures/forms/type_dispatch/generic_additive.ig`
- `playgrounds/igniter-lab/igniter-compiler/fixtures/forms/type_dispatch/missing_trigger.ig`
- `playgrounds/igniter-lab/igniter-compiler/fixtures/forms/type_dispatch/no_form.ig`
- `playgrounds/igniter-lab/igniter-compiler/fixtures/forms/type_dispatch/non_additive_plus.ig`
- `playgrounds/igniter-lab/igniter-compiler/fixtures/forms/type_dispatch/positive.ig`
- `playgrounds/igniter-lab/igniter-compiler/proofs/contract_invocation_forms_type_directed_dispatch_proof.rb`
- `playgrounds/igniter-lab/igniter-compiler/out/contract_invocation_forms_type_directed_dispatch_proof/summary.json`
- `playgrounds/igniter-lab/igniter-compiler/out/contract_invocation_forms_type_directed_dispatch_proof/**`
- `playgrounds/igniter-lab/lab-docs/lab-contract-invocation-forms-type-directed-dispatch-proof-v0.md`

C3-X changed:

- `igniter-lang/docs/discussions/contract-invocation-forms-type-directed-dispatch-proof-pressure-v0.md`

C4-A added:

- `igniter-lang/docs/tracks/contract-invocation-forms-type-directed-dispatch-proof-acceptance-decision-v0.md`

C5-S changed:

- `igniter-lang/docs/tracks/stage3-round252-status-curation-v0.md`
- `igniter-lang/docs/current-status.md`

## Proof Matrix Result

| Surface | Status |
| --- | --- |
| Command matrix | Accepted: all recorded commands PASS or expected `oof`; summary generated. |
| FTD-1..FTD-12 | Accepted: all PASS in proof track and summary JSON. |
| Typed-expression source | Accepted as proof-local lab-only: `TypedContract.symbols` plus local expression reconstruction. |
| Trait/generic filtering | Accepted as fixture evidence only; no PROP-016 or mainline TypeChecker authority. |
| `+` / `++` policy | Accepted: `+` remains numeric/Additive first, `++` remains separate concat candidate. |
| `E-FORM-AMBIG` | Accepted as hard error after type filtering. |
| Declaration order | Accepted: does not select semantic winner. |
| Primitive pass-through / unresolved trigger | Accepted with narrow wording; unresolved-trigger split is not newly overclaimed. |
| `unresolved_form_error` | Accepted: `E-FORM-UNRESOLVED` plus `unresolved_form_error`. |
| `no_form` | Accepted: fail-closed after type facts are available. |
| Explicit-call bypass | Accepted: explicit calls bypass form resolution. |
| Import hiding/overriding | Held gap. |
| Sidecar artifacts | Accepted as audit evidence only. |
| SemanticIR/runtime | Closed. |

## Accepted Evidence / Non-Authority

R252 evidence may be used as proof-local input that contract invocation forms
can be type-filtered before lowering. It may not be used as authority for
canonical syntax, stable grammar, mainline parser or TypeChecker APIs,
SemanticIR lowering, runtime dispatch, VM linker behavior, public APIs,
release evidence, performance evidence, official/reference status,
certification, portability, or lab behavior as canon.

## Closed Surfaces

| Surface | Status |
| --- | --- |
| Mainline implementation | closed |
| Stable grammar / canonical syntax / `form:` canon | closed |
| Parser / TypeChecker / SemanticIR lowering | closed |
| Runtime / VM linker / subroutine frames | closed |
| API / CLI / package | closed |
| `.igapp` / `.igbin` execution | closed |
| Compiler passport / RuntimeSmoke | closed |
| Public runtime / Reference Runtime | closed |
| Production / Spark / release / public demo | closed |
| Performance / official-reference / certification / portability | closed |
| Lab behavior as canon | closed |

## Exact Next Route

C4-A recommends opening:

```text
Card: S3-R253-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: contract-invocation-forms-semanticir-lowering-design-authorization-review-v0
Route: UPDATE
Depends on:
- S3-R252-C4-A
```

Route type:

```text
design/proof authorization review
```

The next route should decide whether a bounded SemanticIR lowering design/proof
may begin for contract invocation forms. It must not authorize live mainline
implementation, runtime, public API, release, performance, certification,
portability, Spark, or lab-canon behavior.

## Route Watchpoint

R251 also named `S3-R253-C1-A` as the future PROP-039 proof-local fixture
authorization review after S3-R252. R252 C4-A independently names
`S3-R253-C1-A` for the forms SemanticIR-lowering design/proof authorization
review. This packet preserves both accepted decisions and records the numbering
collision as a dispatch watchpoint; it does not renumber either route.
