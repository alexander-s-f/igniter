# Experimental Runtime Implementations And Portability Boundary Decision v0

Card: S3-R229-C4-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-runtime-implementations-and-portability-boundary-decision-v0
Route: UPDATE
Status: accepted / resident-supervisor-intake-next
Date: 2026-06-01

Depends on:
- S3-R229-C1-D
- S3-R229-C2-P1
- S3-R229-C3-X

---

## Decision

Accept the experimental runtime implementation arena and portability boundary
design.

Accepted:

```text
implementation hierarchy vocabulary
delegated runtime wording for experimental executable evidence
candidate intake policy
runtime_implementation_id as evidence metadata
capability manifest as evidence comparison metadata
artifact passport vocabulary as future portability design
igc run implementation closure
```

Accepted inputs:

```text
C1-D design output: accepted
C2-P1 facts packet: accepted as facts basis
C3-X pressure verdict: PASS accepted
```

Next Main Line route:

```text
S3-R230-C1-A
delegated-experimental-runtime-resident-supervisor-candidate-intake-authorization-review-v0
```

This next route is an authorization review only. It may decide whether a
bounded resident supervisor candidate intake/proof packet can begin; it does
not authorize mainline runtime implementation.

---

## Compact Summary

```text
accepted
implementation arena vocabulary is now binding for routing
delegated experimental runtimes may be named in experimental evidence
portability/passport vocabulary accepted as future design, not authority
resident supervisor opens next as candidate intake
C temporal backend and Rust TBackend remain separate later intakes
igc run implementation remains closed
Reference Runtime and public runtime claims remain closed
```

---

## Inputs Read

- `igniter-lang/docs/tracks/experimental-runtime-implementations-and-portability-boundary-design-v0.md`
- `igniter-lang/docs/tracks/experimental-runtime-implementation-surface-and-candidate-facts-v0.md`
- `igniter-lang/docs/discussions/experimental-runtime-implementations-and-portability-boundary-pressure-v0.md`
- `igniter-lang/docs/tracks/stage3-round228-status-curation-v0.md`
- `igniter-lang/docs/tracks/experimental-runtime-implementation-status-model-v0.md`

---

## Accepted Statuses

### Implementation Hierarchy

Accepted as routing vocabulary:

```text
Igniter Specification
  -> Official Reference Implementation
  -> Delegated Experimental Runtimes
  -> Alternative Certified Implementations later
```

Binding interpretation:

```text
Specification owns semantics.
Official implementation remains the mainline authority path.
Delegated experimental runtimes produce evidence and experience.
Alternative certified implementations remain future-only.
```

### Delegated Runtime Wording

Accepted for experimental executable evidence when explicitly scoped:

```text
runs using delegated experimental runtime candidate <runtime_implementation_id>
evidence class: delegated experimental runtime evidence only
pre-v1 / subject to change / no stable API guarantee
not Reference Runtime support
not public runtime support
not production support
```

Forbidden promotion remains:

```text
official runtime support
Reference Runtime support
public runtime support
production ready
stable API
certified implementation
portable artifact
public performance claim
Spark integration
release evidence
```

### Official / Reference Implementation

Status:

```text
Official implementation line remains in controlled mainline surfaces.
Reference Runtime support remains closed.
Official runtime package/API/CLI authority remains closed.
```

Playground success may inform the official line only after an explicit later
authorization decision.

### Candidate Intake

Accepted policy:

```text
Playground candidates must enter Main Line through separate intake decisions.
Successful sandbox proofs do not auto-authorize routing, implementation, or
public claims.
```

Accepted intake packet minimum:

```text
candidate name
runtime_implementation_id
implementation class
source location
supported artifact inputs
supported semantics subset
unsupported semantics
failure behavior
proof commands
evidence class
authority non-claims
closed-surface scan
portability implications
recommended next boundary
```

Candidate ordering:

```text
1. resident native supervisor intake
2. C temporal backend intake
3. Rust TBackend intake
4. ESP32/mesh remains comparison-only until portability exists
```

### Artifact Passport / Portability

Accepted as future design vocabulary, not current authority.

Minimum field family accepted for later design:

```text
artifact_kind
artifact_format_version
spec_version
compiler_id
compiler_profile_id
compiled_at
source_digest
semantic_ir_digest
artifact_digest
runtime_target_kind
runtime_implementation_id
required_capabilities
feature_set
required_opcodes
semantics_profile
input_contract
failure_policy
evidence_class
authority_status
non_claims
```

Binding stance:

```text
No current artifact is portable merely because it ran in one runtime.
Passport work should open before igc run implementation.
Passport work does not block resident supervisor candidate intake.
Alternative certification remains future-only.
```

### `igc run`

Status:

```text
implementation closed
design-only route may open later
no CLI/API/package changes authorized
```

Any later `igc run` design-only route must first preserve:

```text
runtime id selection
artifact passport requirements
capability manifest requirements
non-claim wording
closed implementation boundary
```

### RuntimeSmoke

Status:

```text
RuntimeSmoke productization remains closed.
RuntimeSmoke result shape remains closed.
RuntimeSmoke remains proof/smoke context, not public runtime boundary.
```

### Public / Stable / Production / Spark / Release Claims

Status:

```text
public runtime support: closed
stable API: closed
production readiness: closed
public demo claims: closed
Spark integration/authority: closed
release execution/evidence: closed
public performance claims: closed
alternative certification: closed
```

---

## Acceptance Note From C3-X

AN-1 is accepted as binding wording discipline:

```text
Performance numbers in C2-P1 Section 3B are accepted only as in-playground
sandbox measurements.

They are not accepted as evidence for public wording, Main Line performance
claims, candidate intake status, release notes, public docs, product claims, or
stable API/runtime claims.

Any later intake that cites these numbers must re-contextualize them as
informational research-signal / proof-local timing only.
```

This applies to numbers such as:

```text
1.56M iterations/sec
15.2x
2.0x
1.5M timeline evaluations/sec
15.6x
```

---

## Explicit Answers

| Question | Answer |
| --- | --- |
| Is implementation arena vocabulary accepted? | Yes. The four-tier hierarchy is accepted as routing vocabulary. |
| Can experimental executable use name delegated runtimes? | Yes, when runtime id and delegated/non-canonical/evidence-only wording are explicit. |
| Is portability/passport vocabulary accepted? | Yes, as future design vocabulary only. It creates no current portability guarantee. |
| Do resident supervisor, C temporal backend, and Rust TBackend remain unaccepted until separate intake? | Yes. All remain unaccepted candidates until their own intake decisions. |
| Does `igc run` implementation remain closed? | Yes. Only a later design-only route may discuss it. |
| Do Reference Runtime and public runtime remain closed? | Yes. |
| Does RuntimeSmoke productization remain closed? | Yes. |
| Are stable API, production, Spark, release, and public performance claims closed? | Yes. |
| What exact next route should open? | `S3-R230-C1-A delegated-experimental-runtime-resident-supervisor-candidate-intake-authorization-review-v0`. |

---

## Exact Next Dispatch Recommendation

```text
Card: S3-R230-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: delegated-experimental-runtime-resident-supervisor-candidate-intake-authorization-review-v0

Route: UPDATE
Depends on:
- S3-R229-C5-S

Goal:
Decide whether a bounded resident native supervisor candidate intake/proof
packet may begin, using playground-only artifacts and explicit delegated
experimental runtime identity, without authorizing mainline implementation,
igc run, Reference Runtime, public runtime support, stable API, production,
Spark, release, or public performance claims.

Must decide:
- whether resident supervisor intake may begin;
- whether writes under playgrounds/igniter-runtime/** are allowed for the
  proof packet, if any;
- whether mainline docs/tracks output is allowed;
- exact runtime_implementation_id and capability manifest expectations;
- exact evidence class and non-claim wording;
- whether performance numbers may be copied or must be re-measured /
  re-contextualized;
- whether C temporal backend, Rust TBackend, ESP32/mesh, and todolist app
  consumer remain separate routes.

Do not authorize:
- mainline runtime/API/CLI/package changes;
- igc run implementation;
- Reference Runtime implementation;
- RuntimeSmoke productization;
- public runtime support;
- stable API, production, Spark, release, or public performance claims.
```

Secondary follow-up after or alongside resident supervisor intake:

```text
experimental-runtime-artifact-passport-minimum-boundary-v0
```

Held until later:

```text
C temporal backend candidate intake
Rust TBackend candidate intake
experimental igc run design-only route
examples/helper productization authorization review
Runtime Specification input slice
```

Companion, not primary Main Line:

```text
delegated-experimental-app-consumer-todolist-surface-intake-v0
```

The todolist app-consumer intake may run as a companion surface survey if
capacity allows, but it should not displace resident supervisor intake as the
primary runtime architecture next move.

---

## Non-Authorization

This decision does not authorize:

```text
live implementation
igc run implementation
mainline runtime/API/CLI/package changes
public runtime support
Reference Runtime implementation
RuntimeSmoke productization
stable API
production readiness
public demo
Spark integration
release execution
public performance claims
alternative certification
portable artifact claims
```
