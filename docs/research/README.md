# Research

Compact research staging for ideas that may shape Igniter's architecture but are
not accepted public API yet.

Use this directory for compressed horizon notes, decision filters, and agent
operating protocols. Keep long-form expert reports, cycle history, and private
research material under `playgrounds/docs/`.

## Index

- [Horizon Protocol](./horizon-protocol.md) - working protocol, planning frame,
  architect/agent roles, and Igniter Lang guardrails.
- [Vision Handoff Protocol](./vision-handoff-protocol.md) - compact briefing
  format for giving agents a large horizon with a narrow executable slice.
- [Inter-Agent Compact Handoff](./inter-agent-compact-handoff.md) - compact
  pressure-packet protocol for coordinating parallel agents without context
  dumps.
- [Companion Current Status Summary](./companion-current-status-summary.md) -
  compact current-state handoff for the Companion persistence/materializer
  vertical.
- [Companion Persistence App Status](./companion-persistence-app-status.md) -
  current app-local persistence proof and handoff.
- [Companion Persistence Manifest Glossary](./companion-persistence-manifest-glossary.md) -
  compact guide for reading `/setup/manifest` and materializer status packets.
- [Companion Contract Performance Signal](./companion-contract-performance-signal.md) -
  POC performance finding for setup packet recomputation and optimization
  ladder.
- [Contract Persistence Landing Zone](./contract-persistence-landing-zone.md) -
  placement decision for app-local proof, staged extraction, and future package
  naming.
- [Contract Persistence Roadmap](./contract-persistence-roadmap.md) -
  compact roadmap for field/table lowerings, migration planning, and
  materialization process.
- [Contract Persistence Development Track](./contract-persistence-development-track.md) -
  accepted development track from Companion pressure and contract-native store
  research.
- [Companion / Store Convergence](./companion-store-convergence.md) -
  compact cross-track note connecting app-local Companion, `igniter-companion`,
  and `igniter-store`.
- [Igniter Store Progress Summary](./igniter-store-progress-summary.md) -
  compact checkpoint for the hot fact engine, Store/History pressure, and Rust
  snapshot gaps.
- [Contract Persistence Organic Model](./contract-persistence-organic-model.md) -
  horizon model for Store/History as future graph-native concepts.
- [Contract-Native Store Research](./contract-native-store-research.md) -
  living research on compile-time access paths, time-travel, reactivity, and
  agent/cluster store pressure.
- [Contract-Native Store POC](./contract-native-store-poc.md) - POC
  specification for immutable facts, causation chains, time-travel,
  invalidation, and WAL replay.
- [Contract-Native Store Sync Hub](./contract-native-store-sync-hub.md) -
  PostgreSQL sync-hub and retention research for hot/cold store circuits.
- [Contract Persistence Relations](./contract-persistence-relations.md) -
  research model, specification, and DSL for relation manifests.
- [Wizard Type Spec Research Request](./wizard-type-spec-research-request.md) -
  handoff request for spec lineage, materialization, export, and migration
  analysis.
- [Wizard Type Spec Architecture](./wizard-type-spec-architecture.md) -
  research response defining the canonical spec model, export rules, and
  materializer boundary.

## Read First

Before changing architecture or reviewing an agent proposal, read:

1. [Current Runtime Snapshot](../dev/current-runtime-snapshot.md)
2. [Package Map](../dev/package-map.md)
3. [Module System](../dev/module-system.md)
4. [Igniter Lang Foundation](../guide/igniter-lang-foundation.md)
5. [Horizon Protocol](./horizon-protocol.md)
6. [Vision Handoff Protocol](./vision-handoff-protocol.md)
7. [Inter-Agent Compact Handoff](./inter-agent-compact-handoff.md)
8. [Companion Current Status Summary](./companion-current-status-summary.md)
9. [Companion Persistence App Status](./companion-persistence-app-status.md)
10. [Companion Persistence Manifest Glossary](./companion-persistence-manifest-glossary.md)
11. [Companion Contract Performance Signal](./companion-contract-performance-signal.md)
12. [Contract Persistence Landing Zone](./contract-persistence-landing-zone.md)
13. [Contract Persistence Roadmap](./contract-persistence-roadmap.md)
14. [Contract Persistence Development Track](./contract-persistence-development-track.md)
15. [Companion / Store Convergence](./companion-store-convergence.md)
16. [Igniter Store Progress Summary](./igniter-store-progress-summary.md)
17. [Contract Persistence Organic Model](./contract-persistence-organic-model.md)
18. [Contract-Native Store Research](./contract-native-store-research.md)
19. [Contract-Native Store POC](./contract-native-store-poc.md)
20. [Contract-Native Store Sync Hub](./contract-native-store-sync-hub.md)
21. [Contract Persistence Relations](./contract-persistence-relations.md)
22. [Wizard Type Spec Research Request](./wizard-type-spec-research-request.md)
23. [Wizard Type Spec Architecture](./wizard-type-spec-architecture.md)

## Current Research State

Status date: 2026-04-29.

- Active package family: `igniter-contracts`, `igniter-extensions`,
  `igniter-application`, `igniter-ai`, `igniter-agents`, `igniter-hub`,
  `igniter-web`, `igniter-cluster`, `igniter-mcp-adapter`.
- `Igniter::Lang` is additive and report-only: Ruby backend wrapper,
  immutable descriptors (`History`, `BiHistory`, `OLAPPoint`, `Forecast`),
  `VerificationReport`, and `MetadataManifest`.
- Lang metadata is declared, not enforced. `return_type`, `deadline`, `wcet`,
  descriptors, stores, and invariants must graduate through reports before
  runtime checks.
- AI and agents have first package slices: provider-neutral AI envelopes and
  minimal single-turn agent state. Tool contracts, memory, handoff, and human
  gates remain future package work.
- Companion is the strongest product pressure for persistence and agents. Its
  app-local proof now covers records, histories, projections, command mutation
  intents, typed effect intent descriptors, relation manifests, relation health diagnostics,
  registry/readiness/manifest, `WizardTypeSpec`, static materialization planning,
  and a review-only materializer/approval audit vertical.
- Cluster owns distributed placement, routing, ownership, health, remediation,
  and mesh attempts. Contracts remain local-first and host-agnostic.

## Compression Rule

Each research document should preserve:

- one claim
- the boundary it changes
- the evidence or source pressure
- the smallest reversible next move
- the reasons not to ship it yet
