# Experimental Lab Ecosystem Pressure Map And Intake Prioritization v0

Card: S3-R236-C1-D
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-lab-ecosystem-pressure-map-and-intake-prioritization-v0
Route: UPDATE
Status: design / recommend-stdlib-intake-next
Date: 2026-06-02

Depends on:
- S3-R235-C5-S

---

## Decision Frame

R235 proves a narrow but important movement:

```text
compile .ig -> .igapp
explicit proof-local passport
explicit input JSON
explicit delegated runtime selector
experimental igc run Slice 0 result packet
```

That is real experimental executable evidence, but it is not public runtime
support, not Reference Runtime support, not stable API, not production support,
and not release evidence.

At the same time, `playgrounds/igniter-lab` has evolved into a coherent
alternative lab ecosystem. The right next move is to map it as pressure and
choose the next intake route, not to promote any component directly.

---

## Inputs Read

Mainline evidence:

```text
igniter-lang/docs/tracks/stage3-round235-status-curation-v0.md
igniter-lang/docs/tracks/experimental-igc-run-slice0-quickstart-docs-v0.md
igniter-lang/docs/tracks/
  experimental-igc-run-slice0-quickstart-docs-authorization-review-v0.md
igniter-lang/docs/tracks/
  delegated-experimental-compiler-rust-candidate-intake-v0.md
igniter-lang/docs/tracks/
  experimental-runtime-implementations-and-portability-boundary-decision-v0.md
igniter-lang/docs/tracks/
  experimental-runtime-implementation-status-model-v0.md
igniter-lang/docs/tracks/
  experimental-runtime-artifact-passport-manifest-proof-acceptance-decision-v0.md
igniter-lang/docs/tracks/
  experimental-igc-run-design-only-boundary-decision-v0.md
igniter-lang/docs/current-status.md
igniter-lang/docs/README.md
```

Lab surface anchors:

```text
playgrounds/igniter-lab/README.md
playgrounds/igniter-lab/igniter-compiler/Cargo.toml
playgrounds/igniter-lab/igniter-compiler/verify_compiler.rb
playgrounds/igniter-lab/igniter-runtime/README.md
playgrounds/igniter-lab/igniter-runtime/docs/**
playgrounds/igniter-lab/igniter-runtime/examples/**
playgrounds/igniter-lab/igniter-runtime/fixtures/**
playgrounds/igniter-lab/igniter-stdlib/Cargo.toml
playgrounds/igniter-lab/igniter-stdlib/stdlib/**
playgrounds/igniter-lab/igniter-stdlib/verify_stdlib.rb
playgrounds/igniter-lab/igniter-tbackend/README.md
playgrounds/igniter-lab/igniter-tbackend/docs/**
playgrounds/igniter-lab/igniter-tbackend/src/packs/**
playgrounds/igniter-lab/igniter-tbackend/verify_*.rb
playgrounds/igniter-lab/acts-as-tbackend/README.md
playgrounds/igniter-lab/igniter-apps/README.md
playgrounds/igniter-lab/igniter-apps/benchmark-app/verify_bench.rb
```

C1-D is a design-level map, not a full code audit. The broad source/file facts
packet remains assigned to S3-R236-C2-P1.

---

## Decision

Accept `playgrounds/igniter-lab` as an **ecosystem-level pressure source** for
routing.

Binding stance:

```text
lab components create evidence, not authority
lab overclaim wording may remain tolerated inside lab
mainline records must translate lab claims into strict evidence/non-claim
language
no component becomes official/reference/certified by existing or future lab
success alone
```

Recommended C4-A outcome, if C2-P1 facts and C3-X pressure do not reveal a
blocker:

```text
accept the ecosystem map
keep igc run Slice 1 held for one more route
open stdlib candidate intake / PROP-013 proof pressure next
route Rust TBackend intake immediately after, or as the next sidecar
keep Rust compiler hardening before any portability comparison
```

---

## Implementation Arena Map

Accepted routing vocabulary:

```text
Igniter Specification
  -> Official Reference Implementation
  -> Delegated Experimental Runtimes
  -> Alternative Experimental Compiler Candidates
  -> Backend / substrate candidates
  -> Stdlib candidates
  -> App-consumer / UX pressure surfaces
  -> Alternative Certified Implementations later
```

Meaning:

| Layer | Current meaning | Authority status |
| --- | --- | --- |
| Igniter Specification | Normative semantic target. | Partially formalized; runtime portability still incomplete. |
| Official Reference Implementation | Mainline controlled implementation path. | Closed for Reference Runtime claims. |
| Delegated Experimental Runtimes | Non-canonical execution candidates producing experience and proof. | Evidence only. |
| Alternative Experimental Compiler Candidates | Compiler candidates outside official line. | Evidence only; hardening before comparison. |
| Backend / substrate candidates | Temporal storage/substrate implementations. | Evidence/pressure only. |
| Stdlib candidates | Declarative and executable standard-library pressure. | Candidate evidence only. |
| App-consumer / UX pressure | Apps showing how temporal/executable surfaces feel in use. | Product pressure only. |
| Alternative Certified Implementations later | Future compatibility/certification category. | Closed. |

---

## Lab Component Classification

| Component | Classification | Evidence signal | Next route stance |
| --- | --- | --- | --- |
| `igniter-compiler` | Alternative experimental compiler candidate | R235 intake accepted candidate evidence; known hardening gaps. | Hardening before portability comparison. |
| `igniter-runtime` | Delegated experimental runtime candidate arena | Existing IVM/adapter/AOT/resident-supervisor evidence line. | Use as current runtime evidence base; do not widen now. |
| `igniter-vm` | Delegated experimental runtime candidate | Rust VM/source surface exists; branch/bytecode pressure. | Intake after stdlib/backend or under runtime-spec route. |
| `igniter-stdlib` | Stdlib candidate | `.ig` signatures plus FFI verifier for decimal/linkability. | **Recommended next Main Line intake.** |
| `igniter-tbackend` | Backend / substrate candidate | Rust TBackend packs, WAL/query/auth/MCP/mesh/snapshot surfaces. | High leverage, but route after stdlib or as sidecar. |
| `acts-as-tbackend` | Adapter / integration candidate | ActiveRecord lifecycle capture sketch over TBackend. | Park as Chronicle concept pressure; not next. |
| `igniter-apps/todolist` | App-consumer / UX pressure | Temporal CLI, WAL/history/audit UX. | Park for app-consumer intake after backend map. |
| `igniter-apps/benchmark-app` | Benchmark/performance pressure only | TBackend stress/benchmark coordinator. | Lab-only; no public performance claim. |

---

## Evidence / Authority Vocabulary

Use these terms in mainline:

```text
accepted as lab evidence
accepted as pressure source
candidate intake evidence
delegated experimental evidence
non-canonical
evidence-only
proof-local
lab-local assertion
future portability/certification gate
```

Avoid or mark as closed:

```text
production-grade
production-ready
Reference Runtime support
public runtime support
official implementation
certified implementation
stable API
portable artifact guarantee
release evidence
public benchmark
Spark integration
```

Lab docs may contain enthusiastic language. Mainline docs must not quote that
language as authority without translating it.

---

## Sequencing Analysis

### Why Not `igc run` Slice 1 Immediately

Slice 0 is useful and honest, but Slice 1 would likely pull in one of:

```text
runtime selector widening
more artifact kinds
.igbin
compiler passport emission
capability matching
backend/substrate assumptions
stdlib/operator behavior
```

Those are exactly the areas where lab has promising evidence but not yet
mainline intake. Slice 1 should wait until at least one more foundational
intake route clarifies what execution depends on.

### Why Stdlib First

`igniter-stdlib` is the smallest high-leverage next route:

```text
low authority risk
small surface
directly improves executable confidence
connects to PROP-013
bridges .ig signatures and native behavior
does not require public runtime, package, or CLI widening
```

It gives runtime/productization momentum without pulling the project into
backend/server/performance claims.

### Why TBackend Second

`igniter-tbackend` is likely the highest strategic backend/substrate pressure,
but it has broad surface area:

```text
daemon mode
Ruby/Magnus style build/linking
packs
WAL and compaction
mesh/gossip
auth/MCP/query/analytics
benchmark wording
possible Spark wording
```

It needs its own intake to separate facts from lab README claims. It should
not be used as the next runtime authority or benchmark claim.

### Why Rust Compiler Hardening Stays Sidecar

R235 already accepted the Rust compiler as lab candidate evidence and recorded
hardening gaps:

```text
vendor_lead_pipeline emits empty contracts
--compiler-profile-source parsed but ignored
compiled_at hardcoded
source_path absolute
no Cargo tests
OOF-M1 commented out
no runtime_implementation_id
```

Those should be fixed before portability comparison or official/reference
compiler discussion. They do not block stdlib or TBackend intake.

---

## Next-Route Prioritization Matrix

| Option | TTM value | Authority risk | Size | Recommendation |
| --- | --- | --- | --- | --- |
| Stdlib candidate intake / PROP-013 pressure | High | Low | Small | **Open next** |
| Rust TBackend candidate intake / Phase 2 pressure | High | Medium-high | Large | Open after stdlib or sidecar |
| Lab ecosystem docs/status map sync | Medium | Low | Small | Optional after C4-A if map accepted |
| Rust compiler hardening authorization review | Medium | Medium | Medium | Sidecar/follow-up, not Main Line next |
| `igc run` Slice 1 design-only | High | Medium-high | Medium | Wait for stdlib/backend intake |
| Runtime Specification input slice | Medium | Low-medium | Medium | Useful after stdlib route |
| benchmark-app consumer intake | Medium | High claim risk | Small | Hold; benchmark claims closed |
| acts-as-tbackend / Chronicle concept | Medium | Medium | Medium | Hold until TBackend intake |
| Hold / pause | Low | Low | Small | Not recommended |

---

## Explicit Answers

Whether the lab ecosystem is accepted as an ecosystem-level pressure source:

```text
Yes. Accept as ecosystem-level pressure source for routing.
```

Whether lab components create authority or only evidence:

```text
Only evidence. No authority is created by lab success, verifier output,
benchmark output, README wording, or external report wording.
```

Whether lab overclaim wording may remain tolerated inside lab while mainline
records strict non-claims:

```text
Yes. Lab-local enthusiasm may be tolerated as research-agent style. Mainline
must translate it to strict evidence/non-claim language.
```

Whether `igniter-stdlib` should be prioritized before more runtime work:

```text
Yes. It is the strongest next Main Line route because it is small, executable,
and strengthens semantics without widening runtime authority.
```

Whether `igniter-tbackend` should be prioritized before more runtime work:

```text
Yes, but second. It is high leverage and should receive separate candidate
intake before it influences runtime/productization decisions.
```

Whether Rust compiler hardening should open before portability comparison:

```text
Yes. Portability comparison must wait until the R235 hardening gaps are
addressed or explicitly bounded.
```

Whether `igc run` Slice 1 should wait for more intake:

```text
Yes. Slice 1 should wait for at least stdlib intake, and preferably TBackend
classification if Slice 1 touches temporal/backend behavior.
```

Whether public/stable/production/Reference Runtime/Spark/release/performance
claims remain closed:

```text
Yes. All remain closed.
```

Exact C4-A recommendation:

```text
Accept the lab ecosystem pressure map.
Do not authorize implementation.
Open next Main Line route:
  experimental-stdlib-candidate-intake-and-prop013-pressure-v0
Route type:
  read-only candidate intake / proof-pressure design, not implementation.
Keep Rust TBackend candidate intake as next sidecar or immediate following
route.
Keep igc run Slice 1 design-only held until at least stdlib intake closes.
```

---

## Proposed Next Card Boundary

Recommended next Main Line if C4-A accepts:

```text
Card: S3-R237-C1-D
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-stdlib-candidate-intake-and-prop013-pressure-v0

Goal:
Review `playgrounds/igniter-lab/igniter-stdlib` as a stdlib candidate and
PROP-013 applied-pressure source, preserving candidate/evidence-only status
and keeping runtime/API/package/public authority closed.

Allowed output:
  igniter-lang/docs/tracks/
    experimental-stdlib-candidate-intake-and-prop013-pressure-v0.md

Closed:
  code
  package/gemspec
  public docs
  stable API
  Reference Runtime
  public runtime
  release
  public performance claims
```

Alternative if C3-X argues for backend-first:

```text
experimental-rust-tbackend-candidate-intake-and-phase2-pressure-v0
```

---

## Closed Surfaces

This design does not authorize:

```text
implementation
igc run widening
.igbin execution
compiler passport emission
RuntimeSmoke productization
Reference Runtime implementation
public runtime support
stable API before v1
production readiness
public docs claims
public demo claims
Spark integration
release execution or release evidence
public performance claims
Official Reference Implementation status
alternative certification
artifact portability guarantees
mainline runtime/API/CLI/package changes
```
