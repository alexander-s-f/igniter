# Contract Invocation Forms SemanticIR Lowering Proof Acceptance Decision v0

Card: S3-R254-C4-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: contract-invocation-forms-semanticir-lowering-proof-acceptance-decision-v0
Route: UPDATE
Status: accepted / route-import-hiding-overriding-proof-after-r255
Date: 2026-06-05

Depends on:
- S3-R254-C2-I
- S3-R254-C3-X

---

## Decision

Decision:

```text
accept proof-local contract invocation forms SemanticIR lowering evidence
accept FSL-1..FSL-16 as satisfied inside the lab compiler proof
accept lowered target only as explicit call shape plus proof-local metadata
record import hiding/overriding as the held gap before implementation-facing work
keep live mainline implementation and runtime/public authority closed
preserve S3-R255 repository-split reservation as the next Main Line round
carry forms import hiding/overriding proof as the next forms lane after R255
```

S3-R254-C2-I stayed inside the S3-R254-C1-A proof-local lab-only boundary.
S3-R254-C3-X returned `conditional-accept` with a next-route guard, not a
blocking proof fix.

This decision accepts evidence only. It does not authorize mainline parser,
TypeChecker, SemanticIR implementation, runtime, API, CLI, package, stable
grammar, public API, `.igapp` execution, `.igbin` execution, compiler passport
emission, RuntimeSmoke productization, public runtime, Reference Runtime,
production, Spark, release, public performance claims, official/reference
status, alternative certification, portability guarantees, or lab behavior as
canon.

---

## Inputs Read

- `igniter-lang/docs/tracks/contract-invocation-forms-semanticir-lowering-design-authorization-review-v0.md`
- `igniter-lang/docs/tracks/contract-invocation-forms-semanticir-lowering-proof-v0.md`
- `igniter-lang/docs/discussions/contract-invocation-forms-semanticir-lowering-proof-pressure-v0.md`
- `playgrounds/igniter-lab/lab-docs/lab-contract-invocation-forms-semanticir-lowering-proof-v0.md`
- `playgrounds/igniter-lab/igniter-compiler/out/contract_invocation_forms_semanticir_lowering_proof/summary.json`
- `igniter-lang/docs/tracks/stage3-round253-status-curation-v0.md`
- `igniter-lang/docs/tracks/contract-invocation-forms-type-directed-dispatch-proof-acceptance-decision-v0.md`
- `igniter-lang/docs/cards/S3/S3-R255.md`

Verification commands rerun locally:

```text
cargo test
ruby proofs/contract_invocation_forms_type_directed_dispatch_proof.rb
ruby proofs/contract_invocation_forms_semanticir_lowering_proof.rb
```

All passed. Cargo emitted existing warning noise only.

---

## Changed Files Recorded

Mainline C2-I proof artifact:

- `igniter-lang/docs/tracks/contract-invocation-forms-semanticir-lowering-proof-v0.md`

Proof-reported lab files:

- `playgrounds/igniter-lab/igniter-compiler/src/form_resolver.rs`
- `playgrounds/igniter-lab/igniter-compiler/src/emitter.rs`
- `playgrounds/igniter-lab/igniter-compiler/src/main.rs`
- `playgrounds/igniter-lab/igniter-compiler/fixtures/forms/semanticir_lowering/*.ig`
- `playgrounds/igniter-lab/igniter-compiler/proofs/contract_invocation_forms_semanticir_lowering_proof.rb`
- `playgrounds/igniter-lab/igniter-compiler/out/contract_invocation_forms_semanticir_lowering_proof/**`
- `playgrounds/igniter-lab/lab-docs/lab-contract-invocation-forms-semanticir-lowering-proof-v0.md`

Pressure review artifact:

- `igniter-lang/docs/discussions/contract-invocation-forms-semanticir-lowering-proof-pressure-v0.md`

C4-A artifact:

- `igniter-lang/docs/tracks/contract-invocation-forms-semanticir-lowering-proof-acceptance-decision-v0.md`

---

## Acceptance Record

| Topic | Status |
| --- | --- |
| Command matrix | Accepted: required commands PASS or expected `oof`; R252 regression rerun PASS. |
| FSL-1..FSL-16 | Accepted: all PASS in proof doc and summary JSON. |
| Lowering target | Accepted as existing explicit `call` shape with `lowered_from_form` proof-local metadata. Not canonical SemanticIR vocabulary. |
| Typed dispatch reuse | Accepted: reuses R252 `typed_operands`, `resolved_to`, `form_id`, and `lowering_target`; no stable TypeChecker API authority. |
| Sidecar vs lowered IR | Accepted: sidecars remain audit/provenance; accepted ok SemanticIR carries lowered call shape. |
| Numeric/Additive `+` | Accepted: resolved `+` lowers to `fn: AddInteger`. |
| `++` separation | Accepted: resolved `++` lowers to `fn: ConcatString`, separate from `+`. |
| Explicit-call bypass | Accepted: explicit `length(...)` remains normal call without `lowered_from_form`. |
| Primitive pass-through | Accepted: primitive `-` remains `binary_op`, not form lowering. |
| Ambiguity / declaration order | Accepted: `E-FORM-AMBIG` remains hard error; declaration order never selects lowered winner. |
| Unresolved / no_form | Accepted: both fail closed and produce no accepted lowered output. |
| Import hiding/overriding | Held gap. Not implementation-ready. |
| `.igapp` generation vs execution | Generation and inspection accepted as compiler proof evidence only; `.igapp` execution remains closed. |
| VM linker / subroutine frames | Deferred and closed. |
| Closed-surface scan | Accepted: no mainline implementation or forbidden lab-surface widening reported. |
| S3-R255 reservation | Preserved for repository split boundary. |
| Public/stable/runtime/release claims | Closed. |

---

## Explicit Answers

### Is proof-local SemanticIR lowering evidence accepted?

Yes. It is accepted as proof-local lab-frontier forms lowering evidence.

### May generated outputs be called proof-local forms lowering evidence only?

Yes. That is the only accepted generated-output claim.

### Does this create mainline implementation authority?

No.

### Does this create stable grammar or public API authority?

No.

### Does `.igapp` execution remain closed?

Yes. `.igapp` directories may be inspected as compiler artifacts only.
Execution remains closed.

### Do VM linker/subroutine frames remain deferred?

Yes. VM linker, subroutine frames, registry loading, and runtime dispatch
remain deferred.

### May mainline implementation authorization open next or should it wait?

It should wait. Import hiding/overriding remains a held gap and must be proven
or explicitly excluded before any implementation-facing forms route.

### Does lab behavior create canonical authority?

No. Lab behavior remains frontier evidence only.

### Does S3-R255 remain reserved for repository split?

Yes. S3-R255 remains reserved for:

```text
S3-R255-C1-D
igniter-lang-repository-split-boundary-and-migration-plan-v0
```

### Do protected claims remain closed?

Yes. Public, stable, production, Reference Runtime, release, performance,
certification, portability, official/reference, Spark, public demo, runtime,
compiler passport, RuntimeSmoke, `.igapp`, `.igbin`, and lab-canon claims
remain closed.

---

## Exact Next Dispatch Recommendation

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

Expected post-R255 forms route type:

```text
proof-local lab compiler authorization review
```

Expected focus:

```text
prove import hiding/overriding candidate visibility before lowering
preserve R252 typed filtering
preserve R254 explicit call lowering
preserve E-FORM-AMBIG and declaration-order rejection
preserve unresolved/no_form fail-closed behavior
preserve explicit-call bypass
preserve primitive pass-through
keep sidecars audit/provenance only
keep runtime, VM linker, .igapp execution, stable grammar, public API,
release, performance, certification, portability, and lab-canon authority closed
```

---

## Compact Decision Summary

```text
ACCEPTED: proof-local forms SemanticIR lowering evidence
ACCEPTED: FSL-1..FSL-16
ACCEPTED TARGET: explicit call + lowered_from_form metadata only
HELD GAP: import hiding/overriding
CLOSED: implementation, stable grammar, public API, runtime, VM linker,
        .igapp/.igbin execution, compiler passport, RuntimeSmoke, public claims
NEXT MAIN LINE: S3-R255-C1-D repository split boundary
NEXT FORMS LANE: S3-R256-C1-A import hiding/overriding proof authorization review
```
