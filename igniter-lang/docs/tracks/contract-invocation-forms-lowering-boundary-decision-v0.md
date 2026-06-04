# Contract Invocation Forms Lowering Boundary Decision v0

Card: S3-R250-C4-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: contract-invocation-forms-lowering-boundary-decision-v0
Route: UPDATE
Status: accepted / route-proof-local-type-dispatch-authorization-review
Date: 2026-06-04

Depends on:
- S3-R250-C1-D
- S3-R250-C2-P1
- S3-R250-C3-X

---

## Decision

Decision:

```text
accept contract invocation forms lowering boundary
accept LAB-FORMS-P4 as lab-frontier preflight evidence only
accept C2-P1 as facts-only current-surface evidence
accept C3-X pressure verdict
keep implementation authorization closed
route proof-local type-directed dispatch authorization review next
```

This decision accepts the boundary, not the implementation. It does not
authorize parser, TypeChecker, SemanticIR, runtime, API, CLI, package, stable
grammar, public API, public runtime support, Reference Runtime support,
production, Spark, release, public demo, public performance, official/reference
status, alternative certification, or portability claims.

---

## Inputs Read

- `igniter-lang/docs/tracks/contract-invocation-forms-lowering-and-execution-boundary-v0.md`
- `igniter-lang/docs/tracks/contract-invocation-forms-lowering-current-surface-facts-v0.md`
- `igniter-lang/docs/discussions/contract-invocation-forms-lowering-boundary-pressure-v0.md`
- `igniter-lang/docs/tracks/stage3-round249-status-curation-v0.md`
- `playgrounds/igniter-lab/.agents/LAB-FORMS-P4.md`

---

## Accepted Boundary Status

| Surface | Decision Status | Notes |
| --- | --- | --- |
| LAB-FORMS-P4 | Accepted | Preflight evidence only; no canonical authority. |
| C2-P1 facts packet | Accepted | Facts-only current-surface report. |
| C3-X verdict | Accepted | Pressure verdict is `ACCEPT`; no blockers. |
| Forms lowering boundary | Accepted | Design boundary only. |
| Implementation authority | Closed | Requires later explicit authorization. |
| Public/stable/runtime claims | Closed | No public API, runtime support, release, performance, certification, or portability claim. |

---

## Required Record

| Topic | Status |
| --- | --- |
| LAB-FORMS-P4 acceptance | Accepted as lab-frontier preflight evidence only. |
| Invocation form vs constructor form | Accepted as separate vocabulary. Constructor forms name typed artifacts; invocation forms name ways to call contracts. |
| Explicit form syntax | `form (left) "+" (right)` remains the strongest baseline syntax candidate, not stable grammar. |
| `form:` DX | DX sugar candidate only; not canonical syntax and not implementation authority. |
| Type-directed dispatch | Required before implementation authorization. Next proof route must focus here. |
| Ambiguity policy | `E-FORM-AMBIG` remains a hard error after type filtering. |
| Declaration order | Must not choose a semantic winner. |
| Primitive pass-through / unresolved trigger | Accepted as design evidence only. `unresolved_form_error` remains deferred until type filtering exists. |
| Import hiding / overriding | Parse evidence exists in lab; enforcement remains unproven and closed. |
| Lowering target | Future target is explicit `ContractInvocation` or `Call`. |
| Sidecar vs lowered IR | Sidecars are audit evidence only; they are not SemanticIR lowering facts. |
| Inlining / monomorphization | Preferred first runtime stance before VM bytecode. |
| VM linker deferral | Dynamic VM linker, subroutine frames, registry loading, and runtime dispatch remain deferred. |
| Implementation authority | Closed; no parser/typechecker/SemanticIR/runtime/API/CLI/package change opens here. |
| Public/stable/runtime/release claims | Closed. |

---

## Decision Rationale

The R250 surface is strong enough to accept as a design boundary:

- LAB-FORMS-P4 establishes a clean preflight matrix.
- C2-P1 confirms the actual current state: lab forms are
  `sidecar_resolution_only`, while mainline Ruby has no general form registry
  or form syntax support.
- C3-X found no blocking authority drift.

The same evidence also shows why implementation must wait:

- type-directed candidate filtering is the main semantic blocker;
- import hiding/overriding enforcement is not wired;
- SemanticIR still retains generic `binary_op` nodes in lab evidence;
- sidecars prove resolution intent, not runtime-lowerable IR;
- VM linker work would widen runtime authority too early.

Therefore the next route should prove type-directed dispatch before any
mainline lowering implementation authorization.

---

## Next Route

Open the next available forms Main Line route after the already-routed S3-R251
PROP-039 authorization review:

```text
Card: S3-R252-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: contract-invocation-forms-type-directed-dispatch-proof-authorization-review-v0
Route: UPDATE
Depends on:
- S3-R250-C4-A
```

Route type:

```text
proof-local proof authorization review
```

The route may decide whether a bounded proof-local type-dispatch proof can
begin. It must not authorize mainline parser/typechecker/SemanticIR/runtime
implementation directly.

### Candidate C2-I Boundary If Authorized

Candidate:

```text
Card: S3-R252-C2-I
Skill: IDD Agent Protocol
Agent: [Implementation Agent]
Role: implementation-agent
Track: contract-invocation-forms-type-directed-dispatch-proof-v0
```

Candidate allowed write scope:

```text
playgrounds/igniter-lab/igniter-compiler/**
playgrounds/igniter-lab/lab-docs/lab-contract-invocation-forms-type-directed-dispatch-proof-v0.md
igniter-lang/docs/tracks/contract-invocation-forms-type-directed-dispatch-proof-v0.md
```

Read-only / closed unless explicitly authorized:

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

Expected proof focus:

```text
expression-level type availability for form resolution
candidate filtering by operand/result type
generic/trait-bound candidate filtering
E-FORM-AMBIG after type filtering
unresolved_form_error after type filtering
primitive_pass_through separation
import hiding/overriding facts or explicit gap record
sidecar evidence remains audit-only
no mainline implementation authority
```

Expected proof matrix:

```text
FTD-1  typed operand facts are visible to resolver
FTD-2  matching numeric/Additive `+` candidate resolves
FTD-3  non-Additive `+` candidate refuses or passes through by policy
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

Closed surfaces for the next route:

```text
stable grammar
public API
mainline parser/typechecker/SemanticIR changes
runtime support
VM linker/subroutine frames
API/CLI/package changes
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

## Explicit Answers

### Is the forms lowering boundary accepted?

Yes. The contract invocation forms lowering boundary is accepted as a
design-only boundary.

### Is `form:` canonical?

No. `form:` remains a DX sugar candidate only.

### May implementation authorization open next?

Not directly. The next route may be a proof-local type-directed dispatch
authorization review. Live mainline implementation remains closed.

### Does lab behavior create canonical authority?

No. Lab behavior remains frontier/preflight evidence only.

### Does the VM linker remain deferred?

Yes. VM linker, subroutine frames, contract registry loading, and runtime
dispatch remain deferred.

### Do protected claims remain closed?

Yes. Public, stable, production, Reference Runtime, release, performance,
certification, portability, official/reference, Spark, and public demo claims
remain closed.

---

## Compact Decision Summary

```text
ACCEPT: forms lowering boundary
ACCEPT: LAB-FORMS-P4 preflight evidence only
ACCEPT: C2-P1 facts packet
ACCEPT: C3-X pressure verdict
CLOSE: implementation, stable grammar, runtime, public API, release claims
NEXT: S3-R252-C1-A type-directed dispatch proof authorization review
```
