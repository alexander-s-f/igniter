# Experimental Igniter VM Candidate Intake Decision v0

Card: S3-R239-C4-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-igniter-vm-candidate-intake-decision-v0
Route: UPDATE
Status: accepted / proof-authorization-next
Date: 2026-06-03

Depends on:
- S3-R239-C2-P1
- S3-R239-C3-X

---

## Decision

Accept `igniter-vm` candidate intake evidence.

Accepted meaning:

```text
delegated experimental VM candidate evidence only
proof-local / lab-local intake evidence
not public runtime support
not Reference Runtime support
not runtime/API/CLI/package authority
not stable API
not production readiness
not public performance evidence
not portability or certification guarantee
```

Next Main Line route:

```text
S3-R240-C1-A
experimental-igniter-vm-candidate-proof-authorization-review-v0
```

Route type:

```text
future proof-local VM proof authorization review
not live implementation
not igc run widening
not public runtime support
not Reference Runtime support
```

The pressure-review notes AN-1 and AN-2 are accepted as mandatory next-route
conditions, not blockers for this C4-A acceptance.

---

## Inputs Read

```text
igniter-lang/docs/tracks/
  experimental-igniter-vm-candidate-intake-authorization-review-v0.md
igniter-lang/docs/tracks/
  experimental-igniter-vm-candidate-surface-facts-v0.md
igniter-lang/docs/discussions/
  experimental-igniter-vm-candidate-intake-pressure-v0.md
igniter-lang/docs/tracks/stage3-round238-status-curation-v0.md
igniter-lang/docs/tracks/
  experimental-stdlib-candidate-proof-acceptance-decision-v0.md
```

---

## Compact Decision Summary

```text
VM candidate intake: accepted
C2-P1 facts packet: sufficient
C3-X pressure verdict: PASS with non-blocking next-proof conditions
vm_tests.rs command: 12/12 PASS
cargo test --lib: PASS, 0 tests
cargo metadata --no-deps: PASS
R238 stdlib dependency context: accepted as dependency context only
runtime_implementation_id in crate: absent, accepted as proof gap
capability manifest in crate: absent, accepted as proof gap
reactive_tests/tbackend daemon surface: classified, not accepted as run proof
igc run Slice 1: held
runtime/API/CLI/package authority: closed
public/runtime/reference/stable/performance claims: closed
```

---

## Accepted Evidence

Accepted as delegated experimental VM candidate evidence:

```text
playgrounds/igniter-lab/igniter-vm crate shape
Rust 2021 package: igniter_vm v0.1.0
library target: src/lib.rs
binary target: src/main.rs
opcode/instruction model
stack + register execution model
AOT AST-to-bytecode compiler
if_expr lowering with jump/backpatch structure
Decimal arithmetic delegation through igniter_stdlib path dependency
OP_LOAD_AS_OF temporal read surface
observation sink surface
map/filter/fold/count/first aggregate evaluator
MemoryHistoryBackend test surface
12/12 vm_tests.rs baseline candidate evidence
```

Accepted only as classified-but-unrun surface:

```text
reactive_tests.rs
ReactiveListener
ProjectionPipeline
LedgerTcpBackend / external tbackend daemon path
local listener / port / server behavior
```

The unrun reactive/backend surface is useful candidate context but does not
count as runtime proof, public runtime support, or backend authority.

---

## Command Matrix

| Command | Result | Decision status |
| --- | --- | --- |
| `cargo test --manifest-path playgrounds/igniter-lab/igniter-vm/Cargo.toml --test vm_tests` | 12/12 PASS | accepted as candidate intake evidence |
| `cargo test --manifest-path playgrounds/igniter-lab/igniter-vm/Cargo.toml --lib` | exit 0; 0 tests | accepted as package-shape signal; carries G-3 |
| `cargo metadata --manifest-path playgrounds/igniter-lab/igniter-vm/Cargo.toml --no-deps` | exit 0 | accepted as package metadata signal |

Not accepted as run evidence:

```text
full cargo test
reactive_tests.rs
cargo run
release build
server / daemon / listener execution
tbackend startup
```

---

## Recorded Surface Status

VM candidate acceptance status:

```text
accepted as delegated experimental VM candidate evidence only.
```

Stdlib dependency status:

```text
accepted as dependency context only.
R238 Decimal FFI and stdlib proof-local evidence may be cited as dependency
context, not as public stdlib API or runtime authority.
```

`runtime_implementation_id` / capability manifest status:

```text
absent in crate source.
accepted as known proof gap.
next proof route must provide proof-local metadata in a result packet.
```

Lazy branch / execution semantics status:

```text
if_expr lowering and selected-branch behavior have candidate evidence.
explicit non-selected-branch silence is not proven yet.
next proof route must include a dedicated non-selected-branch silence check.
```

Unsupported / malformed behavior status:

```text
unsupported op and unknown opcode surfaces exist.
proof coverage is not yet sufficient for acceptance as fail-closed proof.
next proof route should include unsupported selected-path and malformed input
checks.
```

Artifact passport relationship status:

```text
no crate-level passport emission or manifest parsing exists.
proof-local result packet may include runtime_implementation_id,
evidence_class, authority_status, non_claims, and capability fields.
compiler passport emission remains closed.
```

`igc run` Slice 1 status:

```text
held.
This intake does not authorize igc run widening or Slice 1 design/implementation.
```

Frontier/conformance adjacent-artifact status:

```text
separate.
No frontier/conformance artifacts are accepted, rejected, or ratified by this
decision. They must not be cited as VM candidate intake evidence.
```

Public/runtime/reference/stable/performance claim status:

```text
all closed.
```

---

## Pressure Verdict Handling

C3-X verdict:

```text
PASS with two non-blocking conditions
```

Accepted handling:

```text
AN-1 and AN-2 are mandatory requirements for the next proof authorization
review. They are not blockers for accepting the C2-P1 facts packet.
```

AN-1 wording requirement for next route:

```text
Observation IDs must be described as hash-based trace identifiers only.
Forbidden in proof output/result packet:
  tamper-evident
  cryptographic audit chain
  digital signature
  security authority
  security proof
```

AN-2 lazy-branch requirement for next route:

```text
The proof matrix must include an explicit non-selected-branch silence check:
false condition selects else branch, then branch is not executed, and then
branch emits no observation to the observation sink.
```

---

## Next Route Boundary

Recommended next card:

```text
Card: S3-R240-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-igniter-vm-candidate-proof-authorization-review-v0

Route: UPDATE
Depends on:
- S3-R239-C4-A

Goal:
Decide whether a bounded proof-local `igniter-vm` candidate proof may begin,
using the accepted R239 VM intake evidence and R238 stdlib dependency context,
without authorizing public runtime support, Reference Runtime support,
runtime/API/CLI/package changes, `igc run` widening, `.igbin` execution,
compiler passport emission, RuntimeSmoke productization, stable API,
production readiness, Spark integration, release evidence, public performance
claims, official/reference status, alternative certification, or portability
guarantees.
```

Future route type:

```text
proof-local authorization review
not implementation authorization yet
not live runtime implementation
not mainline runtime/API/CLI/package route
```

Candidate future proof boundary, if authorized by S3-R240-C1-A:

```text
Allowed write scope candidate:
  playgrounds/igniter-lab/igniter-vm/**
  igniter-lang/docs/tracks/experimental-igniter-vm-candidate-proof-v0.md

Required result packet candidate:
  playgrounds/igniter-lab/igniter-vm/out/
    vm_candidate_proof/summary.json

Closed unless explicitly authorized:
  igniter-lang/lib/**
  igniter-lang/bin/igc
  igniter-lang/igniter_lang.gemspec
  igniter-lang/README.md
  igniter-lang/docs/README.md
  igniter-lang/docs/ruby-api.md
  igniter-lang/lib/igniter_lang/runtime_smoke.rb
  igniter-lang/lib/igniter_lang/compiler_result.rb
  igniter-lang/lib/igniter_lang/compilation_report.rb
  playgrounds/igniter-lab/igniter-tbackend/**
  playgrounds/igniter-lab/igniter-runtime/**
```

Required proof/facts matrix expectations for next route:

```text
VMG-1 runtime_implementation_id present in proof-local summary metadata
VMG-2 evidence_class / authority_status / non_claims present
VMG-3 command matrix scoped to VM proof, no daemon/server side effects unless
      separately authorized
VMG-4 Decimal add/sub/mul/div delegation parity with R238 dependency context
VMG-5 AOT compiler lowering evidence
VMG-6 stack/register execution evidence
VMG-7 selected branch evidence
VMG-8 non-selected branch silence evidence (AN-2)
VMG-9 unsupported selected-path fail-closed evidence
VMG-10 malformed input / unknown opcode behavior evidence
VMG-11 OP_LOAD_AS_OF / observation trace evidence with AN-1 wording
VMG-12 map-reduce aggregate evidence
VMG-13 reactive/tbackend surface kept classified or explicitly skipped
VMG-14 closed-surface scan
VMG-15 no public/stable/reference/performance/portability claims
```

Evidence / authority wording:

```text
generated output may be called proof-local VM candidate evidence only.
generated output must not be called runtime support evidence, Reference Runtime
evidence, public API evidence, release evidence, performance evidence, or
portability evidence.
```

Adjacent frontier/conformance exclusion stance:

```text
frontier/conformance artifacts remain separate and excluded.
They may be routed later through a frontier/conformance boundary.
```

Closed surfaces:

```text
runtime/API/CLI/package changes
igc run widening
.igbin execution
compiler passport emission
RuntimeSmoke productization
public runtime support
Reference Runtime support
stable API
production readiness
Spark integration
release execution
public performance claims
official/reference status
alternative certification
portability guarantees
```

---

## Explicit Answers

Whether `igniter-vm` candidate evidence is accepted:

```text
yes, as delegated experimental VM candidate evidence only.
```

Whether this creates public runtime support:

```text
no.
```

Whether this creates Reference Runtime support:

```text
no.
```

Whether this creates runtime/API/CLI/package authority:

```text
no.
```

Whether implementation may open next:

```text
no live implementation may open next.
Only a future proof-local authorization-review route may open.
```

Whether proof-local VM candidate proof authorization may open next:

```text
yes. Open S3-R240-C1-A next.
```

Whether `igc run` Slice 1 remains held:

```text
yes.
```

Whether adjacent frontier/conformance artifacts remain separate:

```text
yes.
```

Whether public/stable/production/Reference Runtime/Spark/release/performance
and portability claims remain closed:

```text
yes, all remain closed.
```

Exact next dispatch recommendation:

```text
S3-R240-C1-A
experimental-igniter-vm-candidate-proof-authorization-review-v0
```
