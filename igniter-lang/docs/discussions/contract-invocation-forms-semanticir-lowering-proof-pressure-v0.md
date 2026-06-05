# Contract Invocation Forms SemanticIR Lowering Proof Pressure v0

Card: `S3-R254-C3-X`  
Skill: IDD Agent Protocol  
Agent: External Pressure Reviewer  
Role: external-pressure-reviewer  
Track: `contract-invocation-forms-semanticir-lowering-proof-pressure-v0`  
Route: UPDATE  
Status: done / conditional-accept  
Date: 2026-06-05  

Depends on:
- `S3-R254-C1-A`
- `S3-R254-C2-I`

## Pressure Verdict

CONDITIONAL ACCEPT with exact hardening follow-up.

S3-R254-C2-I stays inside the S3-R254-C1-A proof-local lab-only write scope and
produces acceptable lab-frontier evidence that resolved invocation forms can
lower to an explicit `call` shape with proof-local `lowered_from_form`
metadata.

The condition is not a fix to this proof. It is a next-route guard: import
hiding/overriding remains held, so C4-A must not treat this as implementation
readiness. Before any implementation-facing route, open a bounded import
hiding/overriding proof or explicitly keep that gap closed.

## Inputs Reviewed

- `igniter-lang/docs/tracks/contract-invocation-forms-semanticir-lowering-design-authorization-review-v0.md`
- `igniter-lang/docs/tracks/contract-invocation-forms-semanticir-lowering-proof-v0.md`
- `playgrounds/igniter-lab/lab-docs/lab-contract-invocation-forms-semanticir-lowering-proof-v0.md`
- `playgrounds/igniter-lab/igniter-compiler/out/contract_invocation_forms_semanticir_lowering_proof/summary.json`
- `playgrounds/igniter-lab/igniter-compiler/src/form_resolver.rs`
- `playgrounds/igniter-lab/igniter-compiler/src/emitter.rs`
- `playgrounds/igniter-lab/igniter-compiler/proofs/contract_invocation_forms_semanticir_lowering_proof.rb`
- `igniter-lang/docs/tracks/contract-invocation-forms-type-directed-dispatch-proof-acceptance-decision-v0.md`
- `igniter-lang/docs/cards/S3/S3-R254.md`

## Scope And Authority Pressure

PASS.

C1-A authorized writes only to:
- `playgrounds/igniter-lab/igniter-compiler/**`
- `playgrounds/igniter-lab/lab-docs/lab-contract-invocation-forms-semanticir-lowering-proof-v0.md`
- `igniter-lang/docs/tracks/contract-invocation-forms-semanticir-lowering-proof-v0.md`

C2-I reports changes only inside that scope plus the required summary JSON under
the authorized lab compiler output directory. No mainline Ruby, `bin/igc`,
gemspec, public README/docs, spec/proposal docs, source, experiments, VM,
runtime, stdlib, tbackend, public/release, or repository-split surface is
reported as changed.

## Lowering Pressure Matrix

| Check | Verdict | Notes |
| --- | --- | --- |
| Lowered IR clarity | PASS | Target is explicit `call` plus proof-local `lowered_from_form` metadata, not a canonical `ContractInvocation` node name. |
| Typed-dispatch reuse | PASS | R252 sidecar facts are reused through `typed_operands`, `resolved_to`, `form_id`, and `lowering_target`; no stable TypeChecker API is claimed. |
| Numeric/Additive `+` lowering | PASS | Resolved `+` lowers to `fn: AddInteger` in accepted ok output. |
| `++` separation | PASS | Resolved `++` lowers to `fn: ConcatString`, separate from `+`. |
| Explicit-call bypass | PASS | Explicit `length(...)` remains a normal `call` without `lowered_from_form`. |
| Ambiguity fail-closed | PASS | `E-FORM-AMBIG` remains hard error with no accepted lowered output. |
| Declaration-order rejection | PASS | Declaration order remains ambiguous; no lowered winner is selected. |
| Unresolved fail-closed | PASS | `unresolved_form_error` / `E-FORM-UNRESOLVED` produces no accepted lowered output. |
| `no_form` fail-closed | PASS | `no_form` remains blocked and produces no accepted lowered output. |
| Primitive pass-through | PASS | Primitive `-` remains `binary_op` and is not form-lowered. |
| Sidecar vs execution | PASS | Sidecars remain audit/provenance; only accepted ok SemanticIR outputs carry lowered call shape. |
| `.igapp` claim boundary | PASS | `.igapp` artifacts are generated and inspected as compiler outputs only; execution remains closed. |
| Runtime / VM linker | PASS | Lowered nodes record `runtime_dispatch_required=false` and `vm_linker_required=false`; subroutine frames remain deferred. |
| Import hiding/overriding | HELD | Correctly recorded as held; not proven or wired by this card. |
| Stable/public claims | PASS | Stable grammar, canonical SemanticIR vocabulary, public API/runtime, release, performance, certification, portability, Reference Runtime, Spark, and lab-canon claims remain closed. |

## Compact Risk List

1. Import hiding/overriding remains the main held gap. This proof should not
   unlock implementation-facing routing until that gap is either proven or
   explicitly excluded from the implementation slice.
2. The phrase "SemanticIR lowering" is easy to overread as mainline support.
   C4-A should preserve the exact proof-local wording: explicit `call` shape
   plus `lowered_from_form` metadata, not canonical SemanticIR vocabulary.
3. `.igapp` directories exist as compiler proof artifacts. They are not
   execution evidence, `.igapp` runtime support, compiler passport evidence, or
   RuntimeSmoke productization.
4. Runtime and VM risk is low because lowered nodes explicitly carry
   `runtime_dispatch_required=false` and `vm_linker_required=false`, but those
   flags are evidence, not runtime contracts.
5. Sidecar evidence remains useful provenance, but must not become execution
   authority or a runtime dispatch registry.

## Exact Recommendation To C4-A

Accept with this exact decision shape:

```text
ACCEPT S3-R254-C2-I as proof-local lab-frontier evidence.
ACCEPT FSL-1..FSL-16 as satisfied inside the lab compiler proof.
ACCEPT the lowering target only as explicit call shape plus proof-local
lowered_from_form metadata, not canonical SemanticIR vocabulary.
ACCEPT that ambiguous, declaration-order, unresolved, and no_form cases fail
closed and produce no accepted lowered output.
ACCEPT sidecars as audit/provenance evidence only.
RECORD import hiding/overriding as held and not implementation-ready.
KEEP live mainline parser, TypeChecker, SemanticIR implementation, runtime,
VM linker, subroutine frames, API, CLI, package, stable grammar, public API,
.igapp execution, .igbin execution, compiler passport emission, RuntimeSmoke,
public runtime, Reference Runtime, production, Spark, release, public demo,
performance, official/reference, certification, portability, repository split,
and lab-canon authority closed.
DO NOT authorize implementation directly from this proof.
```

Recommended next route:

```text
contract-invocation-forms-import-hiding-overriding-proof-authorization-review-v0
```

Recommended next-route boundary:
- proof-local lab compiler scope only;
- prove import hiding/overriding candidate visibility before lowering;
- preserve R252/R254 type filtering, ambiguity refusal, declaration-order
  rejection, unresolved/no_form fail-closed behavior, explicit-call bypass,
  primitive pass-through, and sidecar non-execution status;
- do not open runtime, VM linker, `.igapp` execution, stable grammar, public,
  release, performance, certification, portability, or lab-canon authority.

If C4-A declines that hardening route, the fallback is to accept R254 while
explicitly holding implementation authorization closed pending a future
import-scope proof. Hold, proposal/errata redirect, and pause are not
recommended for this proof.
