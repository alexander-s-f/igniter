# Igniter-Lang Proposals Index

Status: active index
Maintainer: `[Igniter-Lang Compiler/Grammar Expert]`

This directory contains design proposals for Architect review.
Proposals are smaller than full research tracks — they focus on a single
design decision or formal specification.

---

## Active Proposals

| File | Status | Author | Summary |
|------|--------|--------|---------|
| [META-001-compiler-grammar-expert-entry.md](META-001-compiler-grammar-expert-entry.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | Entry assessment, meta-corrections to existing tracks, proposed research vectors |
| [PROP-001-semantic-domain-v0.md](PROP-001-semantic-domain-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | Formal semantic domain: values, types, temporal context, contracts, observations, failures |
| [PROP-002-contract-composition-algebra-v0.md](PROP-002-contract-composition-algebra-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | Typed port graph algebra: >>, ||, branch, over, embed; algebraic laws; composition closure theorem |
| [PROP-003-grammar-fragment-classification-v0.md](PROP-003-grammar-fragment-classification-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | Three-class fragment model: CORE / ESCAPE / OOF; Pass 0 compiler; DSL keyword mapping |
| [PROP-004-type-system-v0.md](PROP-004-type-system-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | Structural types, temporal capabilities, Projection[T,horizon], Obs[kind,T], soundness theorem |
| [PROP-005-bridge-observation-envelope-v0.md](PROP-005-bridge-observation-envelope-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | Formal envelope spec: Obs[kind,T], Identity/Provenance/Policy groups, Option[T] payload, package mappings |
| [PROP-004b-axiom-layer-type-signatures-v0.md](PROP-004b-axiom-layer-type-signatures-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | Three-tier axiom stack: built-ins, runtime contracts, platform observations; language boundary definition |
| [PROP-006-runtime-contract-specification-v0.md](PROP-006-runtime-contract-specification-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | RuntimeContract: scheduler, clock, cache, storage, capability, distributed ESCAPE; conformance levels |

---

## Queued Proposals (not yet authored)

| ID | Title | Depends On | Priority |
|----|-------|------------|----------|
| PROP-007 | Conformance Verification | PROP-006 | medium |

---

## Proposal Lifecycle

```text
authored -> proposal -> Architect review -> approved | rejected | redirect
```

Approved proposals may become:

- a new track (`docs/tracks/`)
- an experiment (`docs/experiments/`)
- a bridge note (`docs/bridge/`)
- an implementation candidate

---

## Key Meta-Corrections (from META-001)

These are corrections to existing tracks that should be reviewed before
new tracks are authored:

1. **Law 3 / Law 6 tension** — Restate Law 3 as: "The default core is a
   finite, stratified dependency graph, *parameterized over an explicit
   temporal context Tt*. Each evaluation at a fixed Tt is a closed
   computation." (PROP-001 formalizes this.)

2. **Observation envelope field categories** — Separate required fields
   into Identity / Provenance / Policy groups. Two packets are the "same
   observation" iff their identity fields agree. (PROP-001 §6.)

3. **Two-dimensional failure status** — `degraded` and `failed` are
   orthogonal. Replace flat `status` with
   `computation_status x service_level`. (PROP-001 §7.)

4. **Reason code openness** — The closed core reason codes must be
   formally distinguished from open platform extensions. Platform
   extensions are advisory; they cannot change core failure semantics.
   (META-001.)
