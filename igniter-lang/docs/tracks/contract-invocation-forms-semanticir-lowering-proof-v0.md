# Contract Invocation Forms SemanticIR Lowering Proof v0

Card: `S3-R254-C2-I`
Skill: `IDD Agent Protocol`
Agent: `[Implementation Agent]`
Role: `implementation-agent`
Track: `contract-invocation-forms-semanticir-lowering-proof-v0`
Route: `UPDATE`
Status: `done / proof-local-lab-only`
Date: 2026-06-05

Depends on:

- `S3-R254-C1-A`

---

## Authority Notice

S3-R254-C1-A authorized a bounded proof-local lab compiler proof and this
mainline proof track only. This packet records evidence only.

It does not authorize live mainline implementation, stable grammar, canonical
SemanticIR vocabulary, parser, TypeChecker, runtime, VM linker, subroutine
frames, API, CLI, package, `.igapp` execution, `.igbin` execution, compiler
passport emission, RuntimeSmoke productization, public runtime, Reference
Runtime, production, Spark, release, public demo, public performance,
official/reference, certification, portability, or lab behavior as canon.

## Implementation Summary

Implemented in the lab compiler:

- sidecar `lowering_target` evidence for resolved form events;
- proof-local emitter lowering from resolved form binary expressions to the
  existing explicit `call` shape;
- `lowered_from_form` metadata with proof-local authority, source trigger,
  typed operands/result, and no-runtime/no-VM-linker flags;
- fixtures and a proof runner for FSL-1..FSL-16;
- summary JSON under the authorized `out/` directory.

The lowering target is:

```text
explicit call shape plus proof-local lowered_from_form metadata
```

It is not a canonical SemanticIR node name.

## Result Packet

```text
playgrounds/igniter-lab/igniter-compiler/out/contract_invocation_forms_semanticir_lowering_proof/summary.json
```

Status: `PASS`.

## Changed Files

- `playgrounds/igniter-lab/igniter-compiler/src/form_resolver.rs`
- `playgrounds/igniter-lab/igniter-compiler/src/emitter.rs`
- `playgrounds/igniter-lab/igniter-compiler/src/main.rs`
- `playgrounds/igniter-lab/igniter-compiler/fixtures/forms/semanticir_lowering/*.ig`
- `playgrounds/igniter-lab/igniter-compiler/proofs/contract_invocation_forms_semanticir_lowering_proof.rb`
- `playgrounds/igniter-lab/igniter-compiler/out/contract_invocation_forms_semanticir_lowering_proof/**`
- `playgrounds/igniter-lab/lab-docs/lab-contract-invocation-forms-semanticir-lowering-proof-v0.md`
- `igniter-lang/docs/tracks/contract-invocation-forms-semanticir-lowering-proof-v0.md`

## Command Matrix

| Command | Result |
| --- | --- |
| `cargo test` | PASS |
| `cargo run --quiet -- compile fixtures/forms/semanticir_lowering/positive.ig --out out/contract_invocation_forms_semanticir_lowering_proof/positive.igapp` | PASS / `ok` |
| `cargo run --quiet -- compile fixtures/forms/semanticir_lowering/concat_separate.ig --out out/contract_invocation_forms_semanticir_lowering_proof/concat_separate.igapp` | PASS / `ok` |
| `cargo run --quiet -- compile fixtures/forms/semanticir_lowering/explicit_call.ig --out out/contract_invocation_forms_semanticir_lowering_proof/explicit_call.igapp` | PASS / `ok` |
| `cargo run --quiet -- compile fixtures/forms/semanticir_lowering/ambiguity.ig --out out/contract_invocation_forms_semanticir_lowering_proof/ambiguity.igapp` | PASS / expected `oof` |
| `cargo run --quiet -- compile fixtures/forms/semanticir_lowering/declaration_order.ig --out out/contract_invocation_forms_semanticir_lowering_proof/declaration_order.igapp` | PASS / expected `oof` |
| `cargo run --quiet -- compile fixtures/forms/semanticir_lowering/unresolved.ig --out out/contract_invocation_forms_semanticir_lowering_proof/unresolved.igapp` | PASS / expected `oof` |
| `cargo run --quiet -- compile fixtures/forms/semanticir_lowering/no_form.ig --out out/contract_invocation_forms_semanticir_lowering_proof/no_form.igapp` | PASS / expected `oof` |
| `cargo run --quiet -- compile fixtures/forms/semanticir_lowering/primitive_pass_through.ig --out out/contract_invocation_forms_semanticir_lowering_proof/primitive_pass_through.igapp` | PASS / `ok` |
| `ruby proofs/contract_invocation_forms_type_directed_dispatch_proof.rb` | PASS / R252 regression |
| `ruby proofs/contract_invocation_forms_semanticir_lowering_proof.rb` | PASS / summary generated |

## FSL-1..FSL-16

| ID | Status | Evidence |
| --- | --- | --- |
| FSL-1 | PASS | Lowering target is explicit `call` with proof-local metadata. |
| FSL-2 | PASS | R252 typed dispatch evidence is reused, not redefined. |
| FSL-3 | PASS | Resolved numeric/Additive `+` lowers to explicit `AddInteger` invocation. |
| FSL-4 | PASS | Resolved `++` lowers separately to `ConcatString`. |
| FSL-5 | PASS | Explicit calls emit bypass trace and do not require form lowering. |
| FSL-6 | PASS | `E-FORM-AMBIG` remains hard error with no accepted lowered output. |
| FSL-7 | PASS | Declaration order never selects a lowered winner. |
| FSL-8 | PASS | Unresolved typed trigger emits `unresolved_form_error` and no lowered output. |
| FSL-9 | PASS | `no_form` remains fail-closed and no lowered output is accepted. |
| FSL-10 | PASS | Primitive pass-through remains primitive and is not form lowering. |
| FSL-11 | PASS | Sidecar trace links source form, selected candidate, and lowered target. |
| FSL-12 | PASS | Resolved form invocation nodes contain no generic `binary_op`. |
| FSL-13 | PASS | Runtime dispatch table is not required. |
| FSL-14 | PASS | VM linker and subroutine frames remain deferred. |
| FSL-15 | PASS | Import hiding/overriding remains held. |
| FSL-16 | PASS | Closed-surface scan verifies mainline and forbidden lab surfaces. |

## Closed Surface Scan

No edits were made under:

- `igniter-lang/lib/**`
- `igniter-lang/bin/igc`
- `igniter-lang/igniter_lang.gemspec`
- `igniter-lang/README.md`
- `igniter-lang/docs/README.md`
- `igniter-lang/docs/ruby-api.md`
- `igniter-lang/docs/spec/**`
- `igniter-lang/docs/proposals/**`
- `igniter-lang/source/**`
- `igniter-lang/experiments/**`
- `playgrounds/igniter-lab/igniter-vm/**`
- `playgrounds/igniter-lab/igniter-runtime/**`
- `playgrounds/igniter-lab/igniter-stdlib/**`
- `playgrounds/igniter-lab/igniter-tbackend/**`

## D/S/T/R

Decision: proof-local SemanticIR lowering evidence is produced and ready for
pressure review.

Status: `PASS`; FSL-1..FSL-16 all pass.

Trace: summary JSON plus `.igapp` compiler artifacts were inspected only, not
executed.

Recommendation: accept as lab-frontier evidence if pressure review finds no
authority drift; keep implementation/runtime/public authority closed.
