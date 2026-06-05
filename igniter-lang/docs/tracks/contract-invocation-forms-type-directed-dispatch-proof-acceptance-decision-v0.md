# Contract Invocation Forms Type-Directed Dispatch Proof Acceptance Decision v0

Card: S3-R252-C4-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: contract-invocation-forms-type-directed-dispatch-proof-acceptance-decision-v0
Route: UPDATE
Status: accepted / route-semanticir-lowering-design-authorization-review
Date: 2026-06-05

Depends on:
- S3-R252-C2-I
- S3-R252-C3-X

---

## Decision

Decision:

```text
accept proof-local contract invocation forms type-directed dispatch evidence
accept FTD-1..FTD-12 as satisfied inside the lab compiler proof
record import hiding/overriding as a held gap
keep mainline implementation authority closed
route SemanticIR lowering design/proof authorization review next
```

S3-R252-C2-I stayed inside the S3-R252-C1-A proof-local lab-only boundary.
S3-R252-C3-X returned `ACCEPT` and found no blocking claim drift.

This decision accepts evidence only. It does not authorize mainline parser,
TypeChecker, SemanticIR, runtime, API, CLI, package, stable grammar, public
API, `.igapp` execution, `.igbin` execution, compiler passport emission,
RuntimeSmoke productization, public runtime support, Reference Runtime support,
production, Spark, release, public performance claims, official/reference
status, alternative certification, portability guarantees, or lab behavior as
canon.

---

## Inputs Read

- `igniter-lang/docs/tracks/contract-invocation-forms-type-directed-dispatch-proof-authorization-review-v0.md`
- `igniter-lang/docs/tracks/contract-invocation-forms-type-directed-dispatch-proof-v0.md`
- `igniter-lang/docs/discussions/contract-invocation-forms-type-directed-dispatch-proof-pressure-v0.md`
- `playgrounds/igniter-lab/lab-docs/lab-contract-invocation-forms-type-directed-dispatch-proof-v0.md`
- `playgrounds/igniter-lab/igniter-compiler/out/contract_invocation_forms_type_directed_dispatch_proof/summary.json`
- `igniter-lang/docs/tracks/stage3-round250-status-curation-v0.md`
- `igniter-lang/docs/tracks/contract-invocation-forms-lowering-boundary-decision-v0.md`

---

## Changed Files Recorded

Repo-tracked C2-I artifact:

- `igniter-lang/docs/tracks/contract-invocation-forms-type-directed-dispatch-proof-v0.md`

Proof-reported lab files:

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

Pressure review artifact:

- `igniter-lang/docs/discussions/contract-invocation-forms-type-directed-dispatch-proof-pressure-v0.md`

---

## Acceptance Record

| Topic | Status |
| --- | --- |
| Command matrix | Accepted: all recorded commands PASS or expected `oof`; summary generated. |
| FTD-1..FTD-12 | Accepted: all PASS in summary JSON and proof doc. |
| Typed-expression source | Accepted as proof-local lab-only: `TypedContract.symbols` plus local expression reconstruction in `FormResolver`. |
| Trait/generic filtering | Accepted as fixture evidence: `Add[T: Additive]` specializes to `Add[Integer]`; no PROP-016/mainline authority. |
| `+` / `++` policy | Accepted: `+` resolves numeric/Additive candidate; `++` remains distinct and resolves `ConcatString`. |
| `E-FORM-AMBIG` | Accepted: hard error after type filtering. |
| Declaration order | Accepted: never selects semantic winner. |
| Primitive pass-through / unresolved trigger | Accepted with narrow wording: known primitive `-` without form remains `primitive_pass_through`; unresolved-trigger split is not newly overclaimed. |
| `unresolved_form_error` | Accepted: registered trigger with no surviving typed candidate emits `E-FORM-UNRESOLVED` plus `unresolved_form_error`. |
| `no_form` fail-closed | Accepted: remains `blocked_no_form` after type facts are available. |
| Explicit-call bypass | Accepted: explicit calls emit `explicit_call_bypass` and bypass form resolution. |
| Import hiding/overriding | Held gap: parsed in lab but not wired into resolver filtering. |
| Sidecar artifacts | Accepted as audit evidence only: `form_table.json` and `form_resolution_trace.json`. |
| SemanticIR/runtime | Closed: no lowering, runtime dispatch, VM linker, `.igapp` execution, or `.igbin` execution. |
| Implementation / stable grammar / public claims | Closed. |

---

## Explicit Answers

### Is proof-local type-directed dispatch evidence accepted?

Yes. It is accepted as proof-local lab-frontier forms type-dispatch evidence.

### May generated outputs be called proof-local forms type-dispatch evidence only?

Yes. That is the only accepted generated-output claim.

### Does this create mainline implementation authority?

No.

### Does this create stable grammar or public API authority?

No.

### May SemanticIR lowering open next or should it wait?

SemanticIR lowering may open next only as a bounded design/proof authorization
review. It should not jump directly to mainline implementation.

### May mainline implementation authorization open next or should it wait?

It should wait. Type-directed dispatch evidence is now accepted, but import
hiding/overriding remains a held gap and SemanticIR lowering has not yet been
designed or proven.

### Does lab behavior create canonical authority?

No. Lab behavior remains frontier evidence only.

### Does the VM linker remain deferred?

Yes. VM linker, subroutine frames, registry loading, and runtime dispatch remain
deferred.

### Do protected claims remain closed?

Yes. Public, stable, production, Reference Runtime, release, performance,
certification, portability, official/reference, Spark, public demo, `.igapp`
execution, `.igbin` execution, compiler passport emission, and RuntimeSmoke
productization claims remain closed.

---

## Exact Next Dispatch Recommendation

Open:

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
may begin for contract invocation forms. It must explicitly address:

```text
sidecar-to-SemanticIR separation
lowering target: ContractInvocation or Call
typed dispatch evidence reuse
E-FORM-AMBIG hard-error preservation
declaration-order rejection
unresolved_form_error preservation
no_form fail-closed preservation
import hiding/overriding held gap or proof requirement
inlining/monomorphization as first execution stance
VM linker/subroutine frames deferred
```

Closed surfaces for the next route:

```text
live mainline implementation
stable grammar
public API
runtime support
VM linker/subroutine frames
API/CLI/package changes
.igapp execution
.igbin execution
compiler passport emission
RuntimeSmoke productization
public runtime support
Reference Runtime support
production readiness
Spark integration
release evidence
public demo evidence
public performance evidence
official/reference status
alternative certification
portability guarantees
lab behavior as canon
```

---

## Compact Decision Summary

```text
ACCEPTED: proof-local forms type-directed dispatch evidence
ACCEPTED: FTD-1..FTD-12, typed filtering, generic fixture, E-FORM-AMBIG,
          unresolved_form_error, no_form, explicit-call bypass, sidecar evidence
HELD GAP: import hiding/overriding
CLOSED: implementation, stable grammar, public API, SemanticIR/runtime authority,
        VM linker, .igapp/.igbin execution, compiler passport, public claims
NEXT: S3-R253-C1-A contract-invocation-forms-semanticir-lowering-design-authorization-review-v0
```
