# Contract Invocation Forms Type-Directed Dispatch Proof Pressure v0

Card: S3-R252-C3-X  
Skill: IDD Agent Protocol  
Agent: External Pressure Reviewer  
Role: external-pressure-reviewer  
Track: contract-invocation-forms-type-directed-dispatch-proof-pressure-v0  
Route: REVIEW  
Status: done / accept  
Date: 2026-06-05  

Depends on:
- S3-R252-C1-A
- S3-R252-C2-I

## Pressure Verdict

ACCEPT.

S3-R252-C2-I stays inside the S3-R252-C1-A proof-local lab-only authorization
boundary. The output proves enough type-directed dispatch behavior to accept it
as lab-frontier evidence only. It does not open canonical syntax, stable
grammar, mainline parser, mainline TypeChecker, SemanticIR lowering, runtime,
VM linker, API/CLI/package, public/stable/release, performance, certification,
portability, Reference Runtime, production, Spark, or lab-canon authority.

No hold is required. C4-A should accept the proof with explicit non-authority
language and carry import hiding/overriding as a held gap.

## Inputs Reviewed

- `igniter-lang/docs/tracks/contract-invocation-forms-type-directed-dispatch-proof-authorization-review-v0.md`
- `igniter-lang/docs/tracks/contract-invocation-forms-type-directed-dispatch-proof-v0.md`
- `playgrounds/igniter-lab/lab-docs/lab-contract-invocation-forms-type-directed-dispatch-proof-v0.md`
- `playgrounds/igniter-lab/igniter-compiler/out/contract_invocation_forms_type_directed_dispatch_proof/summary.json`
- `playgrounds/igniter-lab/igniter-compiler/src/form_resolver.rs`
- `playgrounds/igniter-lab/igniter-compiler/src/typechecker.rs`
- `playgrounds/igniter-lab/igniter-compiler/proofs/contract_invocation_forms_type_directed_dispatch_proof.rb`
- `igniter-lang/docs/tracks/contract-invocation-forms-lowering-boundary-decision-v0.md`
- `igniter-lang/docs/cards/S3/S3-R252.md`

## Write-Scope Pressure

PASS.

C1-A authorized writes only to:
- `playgrounds/igniter-lab/igniter-compiler/**`
- `playgrounds/igniter-lab/lab-docs/lab-contract-invocation-forms-type-directed-dispatch-proof-v0.md`
- `igniter-lang/docs/tracks/contract-invocation-forms-type-directed-dispatch-proof-v0.md`

C2-I reports only those surfaces plus the required summary JSON under the
authorized lab compiler output directory. The proof output does not report edits
to mainline Ruby, `bin/igc`, gemspec, public README/docs, spec/proposal docs,
source, experiments, runtime/VM/stdlib/tbackend lab packages, release surfaces,
or public claim surfaces.

## Dispatch Semantics Pressure Matrix

| Pressure point | Verdict | Notes |
| --- | --- | --- |
| Typed-expression source | PASS | Type facts are proof-local: `TypedContract.symbols` plus local expression reconstruction inside the lab `FormResolver`. No mainline TypeChecker API authority is claimed. |
| Operand/result candidate filtering | PASS | Summary and resolver show candidates filtered by typed operands before selection, with typed result recorded as trace evidence. |
| Trait/generic filtering | PASS | Generic Additive fixture specializes to `Add[Integer]`; summary explicitly denies PROP-016/mainline authority. |
| `E-FORM-AMBIG` hard error | PASS | Equal surviving candidates emit `E-FORM-AMBIG`, trace `ambiguity_error`, and no resolved winner. |
| Declaration-order winner rejection | PASS | Declaration-order fixture remains ambiguous; first declaration is not selected. |
| `primitive_pass_through` vs `unresolved_trigger` | PASS | Known primitive `-` with no registered form remains `primitive_pass_through`. The unresolved-trigger distinction is held to existing policy, not overclaimed as newly proven. |
| `unresolved_form_error` | PASS | Registered trigger with no surviving typed candidate emits `E-FORM-UNRESOLVED` plus trace kind `unresolved_form_error`. |
| `no_form` fail-closed behavior | PASS | `no_form` candidates remain `blocked_no_form` before typed candidate selection. |
| Explicit-call bypass | PASS | Explicit `length(...)` call emits `explicit_call_bypass` and is not form-resolved. |
| Sidecar artifact authority | PASS | `form_table.json` and `form_resolution_trace.json` remain audit sidecars only, not SemanticIR facts. |
| SemanticIR/runtime non-claims | PASS | Summary and proof check no `ContractInvocation` / `contract_invocation` lowering and no runtime/VM dispatch authority. |
| Public/stable/release claims | PASS | Non-claims are repeated in the proof track, lab doc, and summary JSON. |

## Claim-Risk Notes

No blocking claim drift found.

Non-blocking risks for C4-A to record:

1. Import hiding/overriding remains a held gap. The proof may be accepted for
   type-directed dispatch, but no later implementation-facing forms route should
   treat module-scope filtering as proven by this card.
2. `unresolved_trigger` is not fully reproven here. The proof exercises
   `primitive_pass_through` for a known primitive with no registered form and
   keeps the unresolved-trigger split as existing policy. That is acceptable
   because C1-A allowed either separation proof or explicit status, but C4-A
   should not overstate new unresolved-trigger evidence.
3. The proof-local resolver reconstructs expression type facts inside the lab
   sidecar pass. This is sufficient evidence for the proof, not an accepted
   TypeChecker API shape or SemanticIR contract.
4. Generated `.igapp` directories appear as compiler proof outputs. They are
   evidence artifacts only; they do not imply `.igapp` execution, runtime
   support, compiler passport authority, or RuntimeSmoke productization.

## C4-A Recommendation

Exact recommendation:

```text
ACCEPT S3-R252-C2-I as proof-local lab-frontier type-directed dispatch evidence.
ACCEPT typed candidate filtering, E-FORM-AMBIG hard-error behavior,
unresolved_form_error classification, no_form fail-closed behavior, explicit
call bypass, and sidecar trace evidence as proven inside the lab compiler proof.
KEEP canonical syntax, stable grammar, mainline parser, mainline TypeChecker,
SemanticIR lowering, runtime, VM linker, API/CLI/package, public/stable/release,
performance, certification, portability, Reference Runtime, production, Spark,
and lab-canon authority closed.
RECORD import hiding/overriding as a held gap.
DO NOT treat primitive_pass_through as a fail-closed security claim.
DO NOT open implementation directly from this proof.
```

Recommended next route:

```text
contract-invocation-forms-semanticir-lowering-design-authorization-review-v0
```

Recommended next-route boundary:
- Design/review only; do not authorize mainline implementation yet.
- Use R252 evidence as proof-local input that type-directed dispatch can be
  specified before lowering.
- Require explicit handling of import hiding/overriding, sidecar-to-SemanticIR
  separation, declaration-order rejection, and `E-FORM-AMBIG` fail-closed
  behavior before any implementation-facing route.
- Keep runtime/VM linker, public/stable/release/performance/certification,
  portability, Reference Runtime, production, Spark, and lab-canon claims closed.

Alternate hold is not recommended. Redirect only if C4-A wants import
hiding/overriding proven before any SemanticIR-lowering design route:

```text
contract-invocation-forms-import-scope-filtering-proof-authorization-review-v0
```
