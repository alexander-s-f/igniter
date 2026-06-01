# Experimental Runtime Implementations And Portability Boundary Design v0

Card: S3-R229-C1-D
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-runtime-implementations-and-portability-boundary-design-v0
Route: UPDATE
Status: designed / recommend-accept-with-intake-next
Date: 2026-06-01

Depends on:
- S3-R228-C5-S
- experimental-runtime-implementation-status-model-v0

---

## Decision Frame

R223-R228 proved a useful delegated runtime path:

```text
.ig source
  -> compiler-emitted .igapp / semantic_ir_program.json
  -> playground IVM adapter
  -> Ruby IVM / native FFI / .igbin AOT file loading evidence
```

That evidence is real executable progress. It is still not official runtime
authority.

The correct pre-v1 boundary is:

```text
Igniter Specification
  -> Official Reference Implementation
  -> Delegated Experimental Runtimes
  -> Alternative Certified Implementations later
```

This model should be accepted as routing vocabulary for the next rounds.

---

## Inputs Read

- `igniter-lang/docs/tracks/stage3-round228-status-curation-v0.md`
- `igniter-lang/docs/tracks/delegated-experimental-runtime-ivm-aot-bytecode-file-loading-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/experimental-runtime-implementation-status-model-v0.md`
- `igniter-lang/docs/current-status.md`
- `igniter-lang/lib/igniter_lang/cli.rb`
- `igniter-lang/lib/igniter_lang/compiler_orchestrator.rb`
- `igniter-lang/lib/igniter_lang/runtime_smoke.rb`
- `igniter-lang/examples/experimental_executable_quickstart_v0/quickstart.rb`
- `playgrounds/igniter-runtime/docs/ivm-poc-prototype.md`
- `playgrounds/igniter-runtime/docs/resident_native_supervisor_research_report.md`
- `playgrounds/igniter-runtime/docs/c_temporal_backend_integration_research_report.md`
- `playgrounds/igniter-runtime/docs/concurrency_and_embedded_esp32_mesh_research.md`
- `playgrounds/igniter-tbackend/Cargo.toml`
- `playgrounds/igniter-tbackend/src/fact.rs`
- `playgrounds/igniter-tbackend/src/timeline.rs`
- `playgrounds/igniter-tbackend/src/wal.rs`
- `playgrounds/igniter-tbackend/src/server.rs`
- `playgrounds/igniter-tbackend/bench.rb`
- `playgrounds/igniter-tbackend/demo_server.rb`

---

## Current Surface Findings

### Mainline CLI

Current `igc` behavior is compile-only:

```text
igc compile SOURCE --out OUT.igapp [--compiler-profile-source PATH.json]
```

There is no accepted `igc run` command, runtime selection flag, runtime
implementation id, artifact passport, or runtime capability negotiation.

### Compiler Orchestrator

`CompilerOrchestrator` remains a compile pipeline. It can accept a
`runtime_smoke` callback, but that does not create runtime execution authority.

### RuntimeSmoke

`RuntimeSmoke` remains a proof/smoke surface over the proof RuntimeMachine
compiled program loader. It is not productized runtime support and should not be
used as the public runtime boundary for `igc run`.

### R223 Quickstart

The quickstart is accepted executable evidence through a delegated experimental
runtime harness. Its own disclaimer is still binding:

```text
not stable API
not production runtime support
not Reference Runtime support
not public demo or Spark integration claim
```

### Playground Runtime Evidence

Accepted through R228:

```text
R225: compiler-emitted .igapp / SemanticIR -> IVM adapter fit
R226: branch/comparison adapter hardening
R227: native FFI bytecode execution parity
R228: proof-local .igbin AOT bytecode file loading
```

Observed but not yet accepted by Main Line:

```text
resident native supervisor
C temporal backend integration
ESP32/mesh research
Rust TBackend playground
```

These artifacts are useful candidate material. They are not authority until
intaken and decided.

---

## Implementation Hierarchy Vocabulary

### Igniter Specification

The normative contract.

Current status:

```text
partial
not yet a full runtime portability specification
not yet a certification standard
```

Design stance:

```text
The specification owns semantics.
Runtimes implement named subsets/profiles of those semantics.
```

### Official Reference Implementation

The official implementation path maintained by Igniter.

Current status:

```text
Reference Runtime implementation remains closed
official runtime package/API/CLI authority remains closed
```

Design stance:

```text
The official line may learn from playgrounds.
It does not get replaced by playground success.
```

### Delegated Experimental Runtimes

Non-canonical implementations that run or support Igniter semantics under an
explicit evidence boundary.

Current status:

```text
accepted as implementation arena
allowed to produce executable evidence
allowed to be named in experimental-use evidence
not public runtime support
not stable API
not Reference Runtime
```

Design stance:

```text
More implementations are good.
They compete by contract and evidence.
They do not automatically create public or official authority.
```

### Alternative Certified Implementations

Future category for implementations that pass a compatibility/certification
gate against a named spec/profile.

Current status:

```text
future only
no certified alternative implementation exists
no portability guarantee exists
```

---

## Experimental Executable Use Boundary

Experimental executable use may name a delegated runtime if the wording is
explicit.

Allowed wording:

```text
runs using delegated experimental runtime candidate <runtime_implementation_id>
evidence class: delegated experimental runtime evidence only
pre-v1 / subject to change / no stable API guarantee
not Reference Runtime support
not public runtime support
not production support
```

Forbidden wording:

```text
Igniter runtime support
Reference Runtime support
official runtime support
production ready
stable API
certified implementation
portable artifact
public performance claim
Spark integration
release evidence
```

This means R223/R225-R228 can be used as experimental executable momentum, but
only with runtime id and evidence-class disclaimers attached.

---

## `igc run` Boundary

`igc run` remains closed to implementation.

Reason:

```text
CLI run implies a product surface.
A product surface needs runtime selection, capability negotiation,
artifact portability expectations, failure vocabulary, and public wording.
Those gates are not designed yet.
```

Design-only route may open later if it stays limited to:

```text
syntax sketch
runtime id selection
artifact passport requirements
capability manifest requirements
non-claim wording
closed implementation boundary
```

No next card should implement `igc run` yet.

---

## Playground Candidate Intake Policy

Playground candidates should enter Main Line through an intake decision before
they affect routing.

Minimum intake packet:

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

Candidate classes:

```text
delegated.experimental.runtime
delegated.experimental.temporal_backend
delegated.experimental.transport
delegated.experimental.embedded_runtime
comparison_only.research
```

Observed candidates needing separate intake:

```text
resident native supervisor
C temporal backend
Rust TBackend
ESP32/mesh research
```

Recommended sequencing:

```text
1. resident native supervisor intake
2. C temporal backend intake
3. Rust TBackend intake
4. ESP32/mesh remains comparison-only until runtime portability exists
```

Rationale:

```text
The resident supervisor directly answers the R228 load-once/execute-many
runtime bottleneck. Temporal backends and embedded/mesh claims are more
authority-sensitive and should not be mixed into the first intake.
```

---

## Runtime Implementation ID Stance

Runtime ids should be stable enough for evidence packets, but not public API.

Provisional id pattern:

```text
<authority>.<class>.<name>.<variant>
```

Examples:

```text
igniter.official.reference.ruby
igniter.delegated.experimental.ivm.ruby
igniter.delegated.experimental.ivm.c_ffi
igniter.delegated.experimental.ivm.c_resident
igniter.delegated.experimental.ivm.c_temporal_backend
igniter.delegated.experimental.tbackend.rust_magnus
```

Status:

```text
evidence metadata only
not stable API
not package identity
not certification identity
```

---

## Capability Manifest Stance

Every runtime candidate should declare capabilities before its evidence can be
compared.

Minimum manifest fields:

```text
runtime_implementation_id
implementation_class
artifact_inputs
execution_model
supported_expression_kinds
supported_operators
supports_if_expr_lazy_branching
supports_aot_bytecode
supports_file_loading
supports_resident_module_loading
supports_temporal_read
temporal_backend_kind
failure_behavior
trace_kind
unsupported_features
authority_status
evidence_class
non_claims
```

This manifest is not an API contract. It is an evidence comparison tool.

---

## Artifact Passport Minimum

Portability should open before `igc run` implementation, but only as a
minimal design/proof boundary. Full certification can wait.

Minimum artifact passport fields:

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

Optional later fields:

```text
accepted_by
verified_by
certification_level
portable_to
signature
attestation
provenance_chain
```

Design stance:

```text
Passport work should open before any CLI run implementation.
Passport work does not need to block candidate intake.
```

---

## Portability And Certification Future Gate

No current artifact is portable merely because it ran in one runtime.

Future portability gate must answer:

```text
Who compiled this artifact?
Which spec/profile does it target?
Which runtime capabilities are required?
Which runtime implementation accepted it?
What failure semantics apply?
Can another implementation refuse it without violating the spec?
Can another implementation accept it with the same observable semantics?
```

Certification remains future-only:

```text
no alternative certified implementation exists
no public compatibility claim exists
no portability claim exists
```

---

## Route Matrix

| Route option | TTM impact | Risk | Decision | Reason |
| --- | --- | --- | --- | --- |
| Resident supervisor candidate intake | High | Medium | Prefer next | Directly addresses load-once/execute-many runtime bottleneck without mainline implementation. |
| C temporal backend candidate intake | High | High | Later/separate | Temporal authority and public performance risk are larger; intake after resident supervisor. |
| Rust TBackend candidate intake | Medium | Medium | Later/separate | Important backend candidate, but storage/backend authority should not be coupled to first runtime intake. |
| Experimental `igc run` design-only | High | Medium | After intake/passport | Useful, but premature before runtime ids and passport minimum are accepted. |
| Examples/helper productization authorization | Medium | Low | Hold | Could improve usability, but does not solve runtime implementation identity. |
| Runtime Specification input slice | Medium | Low | Hold/parallel later | Valuable, but too slow if it becomes a full spec rewrite before runtime momentum. |
| Hold / pause | Low | Low | Reject | Market-window pressure argues against pausing executable runtime work. |

---

## Recommended C4-A Decision

C4-A should accept this design with sequencing:

```text
accept implementation arena vocabulary
accept delegated runtime naming for experimental executable evidence
keep igc run implementation closed
keep Reference Runtime and public runtime claims closed
open resident supervisor candidate intake next
require minimal runtime id and capability manifest in the intake
route artifact passport design immediately after or alongside the intake
```

Recommended next dispatch:

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
```

Alternative if C4-A wants more portability first:

```text
Card: S3-R230-C1-D
Track: experimental-runtime-artifact-passport-minimum-boundary-v0
Route: UPDATE
Goal: define the minimum passport fields required before any experimental
igc run implementation authorization review can open.
```

Preferred ordering:

```text
resident supervisor intake first
artifact passport minimum second
experimental igc run design-only third
```

---

## Explicit Answers

| Question | Answer |
| --- | --- |
| Is implementation arena vocabulary accepted for routing? | Recommended yes. Use the accepted hierarchy from the status model. |
| May experimental executable use name a delegated runtime? | Yes, if it names the runtime id and states delegated/non-canonical/evidence-only status. |
| Does `igc run` remain closed to implementation? | Yes. Only design-only discussion may open later. |
| Should portability/passport work open before implementation? | Yes before `igc run`; no, it should not block resident supervisor candidate intake. |
| Do resident supervisor, C temporal backend, and Rust TBackend need separate intake before Main Line effect? | Yes. Each candidate needs separate intake because each carries different authority risk. |
| Are resident supervisor, C temporal backend, Rust TBackend, or ESP32/mesh accepted as authority? | No. They remain unaccepted playground/sandbox material until separate intake/decision. |
| Does Reference Runtime remain closed? | Yes. |
| Do public runtime claims remain closed? | Yes. |
| Do stable API, production, public demo, Spark, release, and public performance claims remain closed? | Yes. |
| Exact C4-A recommendation? | Accept design; route resident supervisor candidate intake next; keep implementation/public authority closed. |

---

## Non-Claims

This design does not authorize:

```text
code edits
igc run implementation
mainline runtime/API/CLI/package changes
Reference Runtime implementation
RuntimeSmoke productization
public runtime support
public performance claims
stable API before v1
production readiness
public demo
Spark integration
release execution
alternative implementation certification
artifact portability guarantees
```
