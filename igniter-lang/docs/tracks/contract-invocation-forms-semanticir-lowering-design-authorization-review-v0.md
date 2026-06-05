# Contract Invocation Forms SemanticIR Lowering Design Authorization Review v0

Card: S3-R254-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: contract-invocation-forms-semanticir-lowering-design-authorization-review-v0
Route: UPDATE
Status: authorized / proof-local-lab-only
Date: 2026-06-05

Depends on:
- S3-R252-C4-A
- S3-R253-C5-S

---

## Decision

Decision:

```text
authorize bounded proof-local contract invocation forms SemanticIR lowering proof
authorize lab compiler writes only inside the stated C2-I boundary
authorize mainline proof track documentation only
keep live mainline implementation, runtime, public, stable, release,
certification, portability, and lab-canon authority closed
preserve S3-R255 repository-split reservation
```

R252 accepted proof-local type-directed dispatch evidence for contract
invocation forms. R253 resolved the route-number collision and assigned this
forms lane to S3-R254. The accepted R252 evidence is sufficient to authorize a
bounded lab-only proof that selected resolved forms can be emitted as explicit
lowered invocation nodes in SemanticIR before any runtime boundary.

This authorization does not accept a stable SemanticIR node name, public form
syntax, stable grammar, runtime execution behavior, VM linker behavior,
mainline compiler behavior, or lab behavior as canon.

---

## Inputs Read

- `igniter-lang/docs/tracks/stage3-round252-status-curation-v0.md`
- `igniter-lang/docs/tracks/stage3-round253-status-curation-v0.md`
- `igniter-lang/docs/tracks/contract-invocation-forms-type-directed-dispatch-proof-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/contract-invocation-forms-type-directed-dispatch-proof-v0.md`
- `igniter-lang/docs/tracks/contract-invocation-forms-lowering-boundary-decision-v0.md`
- `playgrounds/igniter-lab/.agents/LAB-FORMS-P4.md`
- `playgrounds/igniter-lab/lab-docs/lab-contract-invocation-forms-lowering-preflight-v0.md`
- `playgrounds/igniter-lab/lab-docs/forms_analysis_and_execution_gaps.md`
- `playgrounds/igniter-lab/igniter-compiler/out/contract_invocation_forms_type_directed_dispatch_proof/summary.json`
- `playgrounds/igniter-lab/igniter-compiler/src/form_resolver.rs`
- `playgrounds/igniter-lab/igniter-compiler/src/typechecker.rs`
- `playgrounds/igniter-lab/igniter-compiler/src/emitter.rs`
- `playgrounds/igniter-lab/igniter-compiler/src/assembler.rs`
- `igniter-lang/docs/cards/S3/S3-R254.md`

---

## Authorization Rationale

The proof-local route may begin because:

- R252 proves typed candidate filtering, ambiguity refusal, no-form refusal,
  unresolved-form refusal, primitive pass-through separation, and explicit-call
  bypass as lab-frontier evidence.
- R252 explicitly kept SemanticIR/runtime authority closed, so the next proof
  can focus narrowly on lowering shape without widening to execution.
- R250/R252 already identify the sidecar-only gap: resolution traces are audit
  evidence, not lowered SemanticIR.
- R253 confirms this route number and preserves S3-R255 for repository split.

The route remains bounded because:

- import hiding/overriding remains a held gap unless C2-I proves it inside the
  authorized lab compiler scope;
- no VM linker, subroutine frame, runtime dispatch, `.igapp` execution, or
  `.igbin` execution may be claimed;
- `ContractInvocation` is not accepted as canonical vocabulary by this card.

---

## C2-I Authorization Boundary

Authorized next card:

```text
Card: S3-R254-C2-I
Skill: IDD Agent Protocol
Agent: [Implementation Agent]
Role: implementation-agent
Track: contract-invocation-forms-semanticir-lowering-proof-v0

Route: UPDATE
Depends on:
- S3-R254-C1-A
```

### Allowed Write Scope

Allowed:

```text
playgrounds/igniter-lab/igniter-compiler/**
playgrounds/igniter-lab/lab-docs/lab-contract-invocation-forms-semanticir-lowering-proof-v0.md
igniter-lang/docs/tracks/contract-invocation-forms-semanticir-lowering-proof-v0.md
```

Required result packet:

```text
playgrounds/igniter-lab/igniter-compiler/out/contract_invocation_forms_semanticir_lowering_proof/summary.json
```

### Read-Only / Closed Unless Later Authorized

Closed:

```text
igniter-lang/lib/**
igniter-lang/bin/igc
igniter-lang/igniter_lang.gemspec
igniter-lang/README.md
igniter-lang/docs/README.md
igniter-lang/docs/ruby-api.md
igniter-lang/docs/spec/**
igniter-lang/docs/proposals/**
igniter-lang/source/**
playgrounds/igniter-lab/igniter-vm/**
playgrounds/igniter-lab/igniter-runtime/**
playgrounds/igniter-lab/igniter-stdlib/**
playgrounds/igniter-lab/igniter-tbackend/**
```

---

## Required Proof Stance

| Topic | Authorized Stance |
| --- | --- |
| Lowering target | Prefer existing explicit `call` expression shape where possible. If a `ContractInvocation`-like shape is introduced, it must be explicitly named lab-only/candidate vocabulary and cannot be called canonical SemanticIR. |
| Resolved forms | May lower to explicit invocation nodes for accepted resolved form events only. |
| Sidecars | `form_table.json` and `form_resolution_trace.json` remain audit/provenance sidecars, not execution authority. |
| Typed dispatch | Reuse R252 evidence and preserve typed filtering semantics; do not redefine stable typechecker API. |
| Import hiding/overriding | Held gap by default. If touched, it must be proven in matrix and reported separately. |
| Explicit calls | Must continue to bypass form resolution/lowering and retain explicit-call trace. |
| Primitive pass-through | Must remain primitive and not be overclaimed as form lowering. |
| Unresolved/no_form/ambiguous | Must fail closed and must not produce accepted lowered SemanticIR output. |
| Declaration order | Must never choose a lowered semantic winner. |
| Runtime dispatch | Closed. Lowered output must not require runtime form registry dispatch. |
| `.igapp` artifacts | May be generated and inspected as compiler artifacts; execution remains closed. |
| VM linker/subroutine frames | Deferred and closed. |

---

## Proof Matrix

Required C2-I matrix:

```text
FSL-1  lowering target is documented as explicit call or lab-only candidate
FSL-2  R252 typed dispatch evidence is reused and preserved
FSL-3  resolved numeric/Additive + lowers to explicit invocation
FSL-4  resolved ++ lowers separately from +
FSL-5  explicit calls bypass form lowering
FSL-6  E-FORM-AMBIG remains hard error with no accepted lowered output
FSL-7  declaration order never selects a lowered winner
FSL-8  unresolved typed trigger emits unresolved_form_error and no lowered output
FSL-9  no_form remains fail-closed and no lowered output is accepted
FSL-10 primitive pass-through remains primitive and is not form lowering
FSL-11 sidecar trace links source form, selected candidate, and lowered target
FSL-12 semantic_ir_program.json contains no generic binary_op for resolved form invocations
FSL-13 lowered SemanticIR does not require runtime form dispatch
FSL-14 VM linker and subroutine frames remain deferred
FSL-15 import hiding/overriding is either proven or explicitly held
FSL-16 closed-surface scan verifies mainline and forbidden lab surfaces
```

Minimum command matrix:

```text
cargo test
cargo run --quiet -- compile fixtures/forms/semanticir_lowering/positive.ig --out out/contract_invocation_forms_semanticir_lowering_proof/positive.igapp
cargo run --quiet -- compile fixtures/forms/semanticir_lowering/concat_separate.ig --out out/contract_invocation_forms_semanticir_lowering_proof/concat_separate.igapp
cargo run --quiet -- compile fixtures/forms/semanticir_lowering/explicit_call.ig --out out/contract_invocation_forms_semanticir_lowering_proof/explicit_call.igapp
cargo run --quiet -- compile fixtures/forms/semanticir_lowering/ambiguity.ig --out out/contract_invocation_forms_semanticir_lowering_proof/ambiguity.igapp
cargo run --quiet -- compile fixtures/forms/semanticir_lowering/unresolved.ig --out out/contract_invocation_forms_semanticir_lowering_proof/unresolved.igapp
cargo run --quiet -- compile fixtures/forms/semanticir_lowering/no_form.ig --out out/contract_invocation_forms_semanticir_lowering_proof/no_form.igapp
cargo run --quiet -- compile fixtures/forms/semanticir_lowering/primitive_pass_through.ig --out out/contract_invocation_forms_semanticir_lowering_proof/primitive_pass_through.igapp
ruby proofs/contract_invocation_forms_semanticir_lowering_proof.rb
```

C2-I may adjust fixture names if the summary JSON records equivalent command
coverage.

---

## Result Packet Shape

The required summary JSON must include at least:

```text
kind
card
track
status
authority_status
changed_files
command_matrix
proof_matrix
lowering_target_status
typed_dispatch_reuse_status
sidecar_vs_semanticir_status
lowered_invocation_status
binary_op_elimination_status
explicit_call_bypass_status
primitive_pass_through_status
unresolved_no_form_ambiguous_status
import_hiding_overriding_status
runtime_dispatch_status
igapp_execution_status
closed_surface_scan
non_claims
```

---

## Explicit Answers

### May C2-I begin?

Yes. S3-R254-C2-I may begin as a bounded proof-local lab compiler proof.

### May writes under `playgrounds/igniter-lab/igniter-compiler/**` occur?

Yes, inside the C2-I proof boundary only.

### May the mainline proof track doc be written?

Yes. `igniter-lang/docs/tracks/contract-invocation-forms-semanticir-lowering-proof-v0.md`
is authorized.

### May `igniter-lang/lib/**`, `bin/igc`, gemspec, README, public docs,
RuntimeSmoke, CompilerResult, or CompilationReport be edited?

No.

### May `.igapp` artifact generation be inspected without authorizing
`.igapp` execution?

Yes. Compiler artifact generation and inspection are authorized for proof
evidence. `.igapp` execution remains closed.

### May generated SemanticIR contain lowered explicit invocation nodes for
resolved forms?

Yes, for accepted resolved form events only. The preferred proof target is an
explicit `call` shape or a clearly lab-only equivalent.

### Must unresolved, no_form, and ambiguous cases avoid lowered output?

Yes. They must fail closed and must not produce accepted lowered SemanticIR
output.

### Do VM linker/subroutine frames remain deferred?

Yes. VM linker, subroutine frames, registry loading, and runtime dispatch remain
closed.

### Do stable grammar, public API, public runtime, Reference Runtime, release,
performance, certification, and portability claims remain closed?

Yes. All remain closed. S3-R255 also remains reserved for repository split and
is not consumed by this route.

---

## Compact Decision Summary

```text
AUTHORIZED: S3-R254-C2-I proof-local forms SemanticIR lowering proof
OPEN: lab compiler write scope plus mainline proof track doc
TARGET: explicit call or lab-only candidate invocation shape, not canonical SIR
REQUIRE: FSL-1..FSL-16, summary JSON, command matrix, closed-surface scan
CLOSED: mainline implementation, stable grammar, runtime, VM linker,
        .igapp/.igbin execution, public/runtime/reference/release/performance,
        certification, portability, lab behavior as canon
RESERVED: S3-R255 repository split boundary
```
