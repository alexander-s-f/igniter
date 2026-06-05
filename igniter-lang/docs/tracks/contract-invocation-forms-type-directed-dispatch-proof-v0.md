# Contract Invocation Forms Type-Directed Dispatch Proof v0

Card: S3-R252-C2-I
Skill: IDD Agent Protocol
Agent: [Implementation Agent]
Role: implementation-agent
Track: contract-invocation-forms-type-directed-dispatch-proof-v0
Route: UPDATE
Status: done / proof-local-lab-only
Date: 2026-06-05

Depends on:
- S3-R252-C1-A

---

## Authority Notice

S3-R252-C1-A authorized a bounded proof-local lab-only implementation proof.
This track records evidence only.

This card does not authorize mainline parser, TypeChecker, SemanticIR, runtime,
API, CLI, package, spec, proposal, source, experiment, public documentation,
stable grammar, public API, runtime support, VM linker support, `.igapp`
execution, `.igbin` execution, compiler passport emission, RuntimeSmoke
productization, public runtime support, Reference Runtime support, production
readiness, Spark integration, release evidence, public demo evidence, public
performance claims, official/reference status, alternative certification,
portability guarantees, or lab behavior as canon.

---

## Implementation Summary

Implemented inside `playgrounds/igniter-lab/igniter-compiler/**` only:

- proof-local type filtering for form candidates in `FormResolver`;
- sidecar trace fields for `typed_operands`, `typed_result`,
  `filter_status`, and `refused_candidates`;
- `unresolved_form_error` trace plus `E-FORM-UNRESOLVED` diagnostic when a
  registered trigger has no surviving typed candidate;
- preservation of `E-FORM-AMBIG`, `blocked_no_form`,
  `primitive_pass_through`, and `explicit_call_bypass`;
- lab-local `++` type fact to prove `++` remains separate from `+`;
- type-dispatch fixtures, summary checker, summary JSON, and lab proof doc.

SemanticIR remains sidecar-only. No lowering or runtime path was added.

---

## Changed Files

- `playgrounds/igniter-lab/igniter-compiler/src/form_resolver.rs`
- `playgrounds/igniter-lab/igniter-compiler/src/typechecker.rs`
- `playgrounds/igniter-lab/igniter-compiler/fixtures/forms/type_dispatch/positive.ig`
- `playgrounds/igniter-lab/igniter-compiler/fixtures/forms/type_dispatch/non_additive_plus.ig`
- `playgrounds/igniter-lab/igniter-compiler/fixtures/forms/type_dispatch/concat_separate.ig`
- `playgrounds/igniter-lab/igniter-compiler/fixtures/forms/type_dispatch/ambiguity.ig`
- `playgrounds/igniter-lab/igniter-compiler/fixtures/forms/type_dispatch/declaration_order.ig`
- `playgrounds/igniter-lab/igniter-compiler/fixtures/forms/type_dispatch/missing_trigger.ig`
- `playgrounds/igniter-lab/igniter-compiler/fixtures/forms/type_dispatch/no_form.ig`
- `playgrounds/igniter-lab/igniter-compiler/fixtures/forms/type_dispatch/generic_additive.ig`
- `playgrounds/igniter-lab/igniter-compiler/proofs/contract_invocation_forms_type_directed_dispatch_proof.rb`
- `playgrounds/igniter-lab/igniter-compiler/out/contract_invocation_forms_type_directed_dispatch_proof/**`
- `playgrounds/igniter-lab/lab-docs/lab-contract-invocation-forms-type-directed-dispatch-proof-v0.md`
- `igniter-lang/docs/tracks/contract-invocation-forms-type-directed-dispatch-proof-v0.md`

---

## Command Matrix

| Command | Result |
| --- | --- |
| `cargo test` | PASS; compile ok, 0 tests |
| `cargo run -- compile fixtures/forms/type_dispatch/positive.ig --out out/contract_invocation_forms_type_directed_dispatch_proof/positive.igapp` | PASS; `ok` |
| `cargo run --quiet -- compile fixtures/forms/type_dispatch/non_additive_plus.ig --out out/contract_invocation_forms_type_directed_dispatch_proof/non_additive_plus.igapp` | PASS; expected `oof` |
| `cargo run --quiet -- compile fixtures/forms/type_dispatch/concat_separate.ig --out out/contract_invocation_forms_type_directed_dispatch_proof/concat_separate.igapp` | PASS; `ok` |
| `cargo run --quiet -- compile fixtures/forms/type_dispatch/ambiguity.ig --out out/contract_invocation_forms_type_directed_dispatch_proof/ambiguity.igapp` | PASS; expected `oof` |
| `cargo run --quiet -- compile fixtures/forms/type_dispatch/declaration_order.ig --out out/contract_invocation_forms_type_directed_dispatch_proof/declaration_order.igapp` | PASS; expected `oof` |
| `cargo run --quiet -- compile fixtures/forms/type_dispatch/missing_trigger.ig --out out/contract_invocation_forms_type_directed_dispatch_proof/missing_trigger.igapp` | PASS; `ok` |
| `cargo run --quiet -- compile fixtures/forms/type_dispatch/no_form.ig --out out/contract_invocation_forms_type_directed_dispatch_proof/no_form.igapp` | PASS; expected `oof` |
| `cargo run --quiet -- compile fixtures/forms/type_dispatch/generic_additive.ig --out out/contract_invocation_forms_type_directed_dispatch_proof/generic_additive.igapp` | PASS; `ok` |
| `ruby proofs/contract_invocation_forms_type_directed_dispatch_proof.rb` | PASS; summary generated |

Cargo emitted existing warning noise, but all required commands reached the
expected status.

---

## FTD-1..FTD-12

| ID | Status | Evidence |
| --- | --- | --- |
| FTD-1 | PASS | Typed operand facts appear in sidecar trace. |
| FTD-2 | PASS | Integer `+` selects `AddInteger`. |
| FTD-3 | PASS | String `+` refuses through `unresolved_form_error` and refused candidate evidence. |
| FTD-4 | PASS | `++` selects `ConcatString`; `+` remains separate. |
| FTD-5 | PASS | Equal typed candidates emit `E-FORM-AMBIG`. |
| FTD-6 | PASS | Declaration order does not select winner. |
| FTD-7 | PASS | Missing registered form for known primitive `-` remains `primitive_pass_through`. |
| FTD-8 | PASS | Trigger with no surviving typed candidate emits `E-FORM-UNRESOLVED` and `unresolved_form_error`. |
| FTD-9 | PASS | `no_form` remains fail-closed. |
| FTD-10 | PASS | Explicit `length(...)` call bypasses form resolution. |
| FTD-11 | PASS | Sidecar trace records selected, missed/pass-through, refused, and blocked candidates. |
| FTD-12 | PASS | No SemanticIR/runtime support is claimed or emitted. |

Summary JSON:

- `playgrounds/igniter-lab/igniter-compiler/out/contract_invocation_forms_type_directed_dispatch_proof/summary.json`

---

## Required Status Fields

| Field | Status |
| --- | --- |
| Typed-expression source | Proof-local lab-only: `TypedContract.symbols` plus expression reconstruction in `FormResolver`. |
| Trait/generic filtering | PASS: `Add[T: Additive]` specializes to `Add[Integer]`; no PROP-016/mainline authority claimed. |
| Ambiguity | `E-FORM-AMBIG` hard error after type filtering. |
| Declaration order | No semantic winner. |
| Primitive pass-through / unresolved trigger | Known primitives pass through by policy; unresolved-trigger distinction held from prior proof. |
| `unresolved_form_error` | PASS: trace kind `unresolved_form_error`, diagnostic `E-FORM-UNRESOLVED`. |
| Import hiding/overriding | Held gap; parsed in lab but not wired into resolver filtering. |
| Sidecar artifact | Evidence only; not SemanticIR lowering. |
| SemanticIR/runtime | Closed; no `ContractInvocation`, VM linker, runtime dispatch, `.igapp` execution, or `.igbin` execution authority. |

---

## Closed-Surface Scan

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

---

## Recommendation

Ready for pressure review / acceptance as proof-local lab-frontier evidence.

Keep mainline implementation closed. Import hiding/overriding remains the
explicit held gap before any later implementation-facing forms lowering route.
