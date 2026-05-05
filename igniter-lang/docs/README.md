# Igniter-Lang Research Index

Status: active research index

## Claim

Igniter-Lang should be explored as a separate language ecosystem, not as an
implementation detail of the current Igniter platform.

## Active Tracks

| Track | Status | Purpose |
|------|--------|---------|
| [tracks/observable-contract-language-v0.md](tracks/observable-contract-language-v0.md) | proposal | Completed first axiom slice for "everything observable, everything contract" |
| [tracks/observable-spine-v0.md](tracks/observable-spine-v0.md) | proposal | Completed minimal observation envelope and packet-kind spine |
| [tracks/failure-observation-v0.md](tracks/failure-observation-v0.md) | proposal | Completed structured failure packet model over the observation spine |
| [tracks/semantic-domain-reconciliation-v0.md](tracks/semantic-domain-reconciliation-v0.md) | done | Reconciled practical tracks with META-001 and PROP-001 formal corrections |
| [tracks/track-errata-application-v0.md](tracks/track-errata-application-v0.md) | done | Applied compact formal errata to completed practical tracks |
| [tracks/temporal-contracts-and-projections-v0.md](tracks/temporal-contracts-and-projections-v0.md) | done | Defined named slices, projection horizons, live/reproducible projections, and action semantics |
| [tracks/runtime-contracts-and-execution-environments-v0.md](tracks/runtime-contracts-and-execution-environments-v0.md) | done | Defined runtime contracts, execution environments, guarantees, and result meaning status |
| [tracks/bridge-observation-envelope-runtime-evidence-v0.md](tracks/bridge-observation-envelope-runtime-evidence-v0.md) | done | Extended bridge vocabulary with runtime evidence, meaning status, and runtime links |
| [tracks/bridge-observation-envelope-package-mapping-v0.md](tracks/bridge-observation-envelope-package-mapping-v0.md) | done | Mapped current package facts, projections, pins, decisions, and runtime session packets to bridge profiles |
| [tracks/runtime-machine-lifecycle-v0.md](tracks/runtime-machine-lifecycle-v0.md) | done | Defined Runtime Machine boot/load/evaluate/checkpoint/resume lifecycle, semantic image, TBackend adapters, compatibility, and CORE/ESCAPE boundary |

## Active Proposals

See [proposals/README.md](proposals/README.md) for the full index.

| Proposal | Status | Author | Summary |
|----------|--------|--------|---------|
| [proposals/META-001](proposals/META-001-compiler-grammar-expert-entry.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | Entry assessment + meta-corrections to existing tracks |
| [proposals/PROP-001](proposals/PROP-001-semantic-domain-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | Formal semantic domain: V, T, Tt, C, Expr, O, F |
| [proposals/PROP-002](proposals/PROP-002-contract-composition-algebra-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | Contract composition: >>, \|\|, branch, over, embed — algebraic laws + closure theorem |
| [proposals/PROP-003](proposals/PROP-003-grammar-fragment-classification-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | Fragment classification: CORE / ESCAPE / OOF; Pass 0 compiler; DSL keyword mapping |
| [proposals/PROP-004](proposals/PROP-004-type-system-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | Structural types, temporal capabilities, Projection[T,horizon], Obs[kind,T], soundness |
| [proposals/PROP-005](proposals/PROP-005-bridge-observation-envelope-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | Formal envelope: ObsPacket[kind,T], Identity/Provenance/Policy, Option[T] payload, package mappings |
| [proposals/PROP-004b](proposals/PROP-004b-axiom-layer-type-signatures-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | Three-tier axiom stack: language built-ins, runtime contracts, platform observations |
| [proposals/PROP-006](proposals/PROP-006-runtime-contract-specification-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | RuntimeContract: scheduler, clock, cache, storage, capability, distributed ESCAPE; conformance |
| [proposals/PROP-007](proposals/PROP-007-conformance-verification-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | Conformance verification: 5 check suites, trust levels, agent trust decision procedure |
| [proposals/PROP-008](proposals/PROP-008-tbackend-contract-v0.md) | proposal | `[Igniter-Lang Compiler/Grammar Expert]` | TBackend[T]: read/append/replay/snapshot/compact/subscribe; reproducible resume; adapter classes |

## Core Documents

| File | Purpose |
|------|---------|
| [ecosystem-split-proposal.md](ecosystem-split-proposal.md) | Defines the Igniter vs Igniter-Lang split |
| [research-process.md](research-process.md) | Research lifecycle, document rotation, handoff protocol |
| [agent-motion.md](agent-motion.md) | Current multi-agent movement and handoff routing |
| [temporal-positioning.md](temporal-positioning.md) | Meta thesis: time, contracts, projections, and language positioning |
| [axiomatic-contract-model.md](axiomatic-contract-model.md) | Meta thesis: language, runtime, distributed execution, and time as contract boundaries |
| [runtime-machine.md](runtime-machine.md) | Meta thesis: Runtime Machine lifecycle, TBackend, semantic image, and resume model |

## Research Vectors

- Observable Contract Language
- Everything Is Contract
- Organic Axiom Layer
- Agent-Friendly Language
- Temporal Contract Semantics
- Projections / Slices / As-Of Views
- Contract Synthesis
- Igniter Bridge
- Formal Semantic Domain (PROP-001)
- Contract Composition Algebra (PROP-002)
- Grammar Fragment Classification (PROP-003)
- Type System v0 (PROP-004)
- Temporal Contract Semantics (PROP-004 + temporal-positioning.md)
- Projections / Slices / As-Of Views (Projection[T, horizon] — PROP-004)
- Bridge Observation Envelope (PROP-005)
- Axiom Layer Type Signatures (PROP-004b)
- Runtime Contract Specification (PROP-006)
- Conformance Verification (PROP-007)
- TBackend Contract (PROP-008)
- Axiomatic Contract Model (axiomatic-contract-model.md)
- Runtime Machine (runtime-machine.md)
- Temporal Contracts and Projections (QUEUED — Research Agent track)
- Runtime Machine Lifecycle (QUEUED — PROP-009)

## Review Cadence

The research agent should produce compact completed slices. `[Architect
Supervisor / Codex]` periodically reviews a complete slice and then either:

- approves the direction
- narrows the next experiment
- rejects a branch
- requests a bridge note back to Igniter platform

## Handoff Format

Use the template in [../handoff/HANDOFF_TEMPLATE.md](../handoff/HANDOFF_TEMPLATE.md).
