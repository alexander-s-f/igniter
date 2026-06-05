# Contract Invocation Forms Type-Directed Dispatch Proof Authorization Review v0

Card: S3-R252-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: contract-invocation-forms-type-directed-dispatch-proof-authorization-review-v0
Route: UPDATE
Status: authorized / proof-local-lab-only
Date: 2026-06-05

Depends on:
- S3-R250-C4-A
- S3-R251-C5-S

---

## Decision

Decision:

```text
authorize bounded proof-local contract invocation forms type-directed dispatch proof
authorize only lab-frontier proof changes under the allowed scope
keep mainline implementation, stable grammar, SemanticIR lowering, runtime,
VM linker, public API, release, performance, certification, portability, and
lab-canon authority closed
```

R250 accepted contract invocation forms lowering as a design-only boundary and
identified type-directed dispatch as the next semantic blocker. R251 closed the
intervening PROP-039 authoring route and does not block the forms lane.

This card authorizes C2-I proof work only. It does not authorize mainline
parser, TypeChecker, SemanticIR, runtime, API, CLI, package, spec, proposal,
source, experiment, or public documentation changes.

---

## Inputs Read

- `igniter-lang/docs/tracks/stage3-round250-status-curation-v0.md`
- `igniter-lang/docs/tracks/stage3-round251-status-curation-v0.md`
- `igniter-lang/docs/tracks/contract-invocation-forms-lowering-boundary-decision-v0.md`
- `igniter-lang/docs/tracks/contract-invocation-forms-lowering-and-execution-boundary-v0.md`
- `igniter-lang/docs/tracks/contract-invocation-forms-lowering-current-surface-facts-v0.md`
- `igniter-lang/docs/discussions/contract-invocation-forms-lowering-boundary-pressure-v0.md`
- `playgrounds/igniter-lab/.agents/LAB-FORMS-P2.md`
- `playgrounds/igniter-lab/.agents/LAB-FORMS-P4.md`
- `playgrounds/igniter-lab/lab-docs/lab-contract-invocation-forms-lowering-preflight-v0.md`
- `playgrounds/igniter-lab/igniter-compiler/out/lab_contract_invocation_forms_hardening_proof/summary.json`
- `playgrounds/igniter-lab/igniter-compiler/src/form_resolver.rs`
- `playgrounds/igniter-lab/igniter-compiler/src/typechecker.rs`
- `playgrounds/igniter-lab/igniter-compiler/src/emitter.rs`
- `playgrounds/igniter-lab/igniter-compiler/src/assembler.rs`

---

## Authorization Boundary

### Allowed Write Scope

C2-I may write only:

```text
playgrounds/igniter-lab/igniter-compiler/**
playgrounds/igniter-lab/lab-docs/lab-contract-invocation-forms-type-directed-dispatch-proof-v0.md
igniter-lang/docs/tracks/contract-invocation-forms-type-directed-dispatch-proof-v0.md
```

Required result packet:

```text
playgrounds/igniter-lab/igniter-compiler/out/contract_invocation_forms_type_directed_dispatch_proof/summary.json
```

### Read-Only / Closed Unless Explicitly Authorized Later

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
igniter-lang/experiments/**
playgrounds/igniter-lab/igniter-vm/**
playgrounds/igniter-lab/igniter-runtime/**
playgrounds/igniter-lab/igniter-stdlib/**
playgrounds/igniter-lab/igniter-tbackend/**
```

No other lab package may be edited.

`Cargo.toml` / `Cargo.lock` inside `playgrounds/igniter-lab/igniter-compiler/`
may be touched only if the proof can still run without network access and no
claim is made about production dependencies. Prefer no new dependencies.

---

## Required Proof Stances

| Topic | Authorized stance |
| --- | --- |
| Type-fact source | May be proof-local inside lab compiler only. Does not create mainline TypeChecker API authority. |
| Trait / generic filtering | May prove minimal fixture-level trait/generic filtering. Does not accept PROP-016 implementation. |
| `+` / `++` policy | `+` remains numeric/Additive first; `++` remains separate concat/append candidate. |
| `E-FORM-AMBIG` | Must remain hard error after type filtering. |
| Declaration order | Must never choose semantic winner. |
| Primitive pass-through | Must remain honest classification, not fail-closed security claim. |
| `unresolved_trigger` | Missing unknown trigger may be traced separately from primitive pass-through. |
| `unresolved_form_error` | Must be proven when trigger exists but typed candidates do not survive filtering. |
| `no_form` | Must remain fail-closed after type filtering. |
| Explicit calls | Must bypass form resolution and remain trace-visible. |
| Import hiding / overriding | May be proven or explicitly recorded as held gap; no module-scope authority opens here. |
| Sidecar artifacts | Audit evidence only; not SemanticIR lowering facts. |
| SemanticIR lowering | Closed. No `ContractInvocation` / `Call` lowering authority opens here. |
| Runtime / VM linker | Closed. No runtime dispatch, VM frames, or subroutine linker authority opens here. |

---

## Proof Matrix

C2-I must satisfy FTD-1..FTD-12 or stricter:

```text
FTD-1  typed operand facts are visible to resolver
FTD-2  matching numeric/Additive `+` candidate resolves
FTD-3  non-Additive `+` candidate refuses or passes through by explicit policy
FTD-4  `++` remains separate from `+`
FTD-5  equal surviving candidates produce E-FORM-AMBIG
FTD-6  declaration order never selects a winner
FTD-7  missing trigger remains unresolved_trigger / primitive_pass_through by policy
FTD-8  trigger with no surviving typed candidate produces unresolved_form_error
FTD-9  no_form remains fail-closed after filtering
FTD-10 explicit calls bypass form resolution
FTD-11 sidecar trace records selected, missed, and refused candidates
FTD-12 no SemanticIR/runtime support is claimed
```

If import hiding/overriding is not implemented, C2-I must include a specific
held-gap record and must not imply scope enforcement exists.

---

## Command Matrix

C2-I should run a compact local command matrix inside
`playgrounds/igniter-lab/igniter-compiler/`, for example:

```text
cargo test
cargo run -- compile <type-dispatch-positive-fixture> --out <proof-out>
cargo run -- compile <type-dispatch-ambiguity-fixture> --out <proof-out>
cargo run -- compile <type-dispatch-unresolved-form-fixture> --out <proof-out>
cargo run -- compile <type-dispatch-no-form-fixture> --out <proof-out>
cargo run -- compile <type-dispatch-plus-policy-fixture> --out <proof-out>
```

The exact command names may follow the lab compiler CLI. The proof track must
record the actual commands and outcomes.

---

## Result Packet Shape

The required summary JSON must include:

```text
kind
card
track
status
authority_status
changed_files
command_matrix
proof_matrix FTD-1..FTD-12
typed_expression_source_status
trait_generic_filtering_status
plus_policy_status
ambiguity_status
declaration_order_status
primitive_pass_through_status
unresolved_trigger_status
unresolved_form_error_status
no_form_status
explicit_call_bypass_status
import_hiding_overriding_status
sidecar_artifact_status
semantic_ir_status
runtime_status
closed_surface_scan
non_claims
```

Generated outputs may be called proof-local forms type-dispatch evidence only.

---

## Forbidden Wording / Non-Claims

C2-I must not claim:

```text
canonical syntax
stable grammar
form: canon
mainline parser support
mainline TypeChecker support
SemanticIR lowering support
runtime support
VM linker support
public API
public runtime support
Reference Runtime support
production readiness
Spark integration
release evidence
public demo evidence
public performance evidence
official/reference status
alternative certification
portability guarantee
lab behavior as canon
```

`form:` remains a DX sugar candidate only. Explicit
`form (left) "+" (right)` remains a baseline syntax candidate only, not stable
grammar.

---

## Must-Answer Items

### May C2-I begin?

Yes. C2-I may begin as bounded proof-local lab work.

### Are writes under `playgrounds/igniter-lab/igniter-compiler/**` allowed?

Yes, inside the proof boundary.

### May the lab proof doc be written?

Yes.

### May the mainline proof track doc be written?

Yes.

### May `igniter-lang/lib/**`, `bin/igc`, gemspec, README, public docs, spec/proposal docs, source, experiments, RuntimeSmoke, CompilerResult, or CompilationReport be edited?

No.

### May generated output be called proof-local forms type-dispatch evidence only?

Yes. That is the only accepted claim.

### Does `form:` remain DX sugar candidate only?

Yes.

### Does explicit `form (left) "+" (right)` remain baseline candidate only?

Yes.

### Do implementation, stable grammar, runtime, VM linker, public runtime, Reference Runtime, release, performance, certification, and portability claims remain closed?

Yes.

---

## C2-I Dispatch

```text
Card: S3-R252-C2-I
Skill: IDD Agent Protocol
Agent: [Implementation Agent]
Role: implementation-agent
Track: contract-invocation-forms-type-directed-dispatch-proof-v0
Route: UPDATE
Depends on:
- S3-R252-C1-A
```

Allowed write scope:

```text
playgrounds/igniter-lab/igniter-compiler/**
playgrounds/igniter-lab/lab-docs/lab-contract-invocation-forms-type-directed-dispatch-proof-v0.md
igniter-lang/docs/tracks/contract-invocation-forms-type-directed-dispatch-proof-v0.md
```

Required result packet:

```text
playgrounds/igniter-lab/igniter-compiler/out/contract_invocation_forms_type_directed_dispatch_proof/summary.json
```

---

## Compact Decision Summary

```text
AUTHORIZED: proof-local forms type-directed dispatch proof
ALLOWED: lab compiler proof surface + lab proof doc + mainline proof track doc
CLOSED: igniter-lang/lib, bin/igc, gemspec, README/public docs, spec/proposals,
        source, experiments, runtime, VM linker, SemanticIR lowering, public claims
NEXT: S3-R252-C2-I
```
