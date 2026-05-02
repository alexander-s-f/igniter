# Research

Compact research staging for ideas that may shape Igniter's architecture but are
not accepted public API yet.

Use this directory for governance protocols, long-horizon decisions, and cross-cutting
design notes. Keep implementation snapshots and package specs in their respective
`packages/<pkg>/docs/` directories once shipped. See **Rotation Policy** below.

## Index

### Protocols & Governance
- [Horizon Protocol](./horizon-protocol.md) - working protocol, planning frame,
  architect/agent roles, and Igniter Lang guardrails.
- [Vision Handoff Protocol](./vision-handoff-protocol.md) - compact briefing
  format for giving agents a large horizon with a narrow executable slice.
- [Project Status Horizon Report](./project-status-horizon-report.md) -
  whole-project status, verification, strategic insights, and horizon ideas.

### Persistence Design
- [Contract Persistence Landing Zone](./contract-persistence-landing-zone.md) -
  placement decision for app-local proof, staged extraction, and future package
  naming.
- [Contract Persistence Roadmap](./contract-persistence-roadmap.md) -
  compact roadmap for field/table lowerings, migration planning, and
  materialization process.
- [Contract Persistence Development Track](./contract-persistence-development-track.md) -
  accepted development track from Companion pressure and contract-native store
  research.
- [Contract Persistence Organic Model](./contract-persistence-organic-model.md) -
  horizon model for Store/History as future graph-native concepts.

### Wizard Type Spec
- [Wizard Type Spec Research Request](./wizard-type-spec-research-request.md) -
  handoff request for spec lineage, materialization, export, and migration
  analysis.
- [Wizard Type Spec Architecture](./wizard-type-spec-architecture.md) -
  research response defining the canonical spec model, export rules, and
  materializer boundary.

## Rotated to Package Docs

Implementation snapshots that shipped are kept in their package `docs/` directories:

| Document | New Location |
|----------|-------------|
| Contract-Native Store POC spec | [packages/igniter-store/docs/poc-specification.md](../../packages/igniter-store/docs/poc-specification.md) |
| Contract-Native Store Server Model | [packages/igniter-store/docs/server-model.md](../../packages/igniter-store/docs/server-model.md) |
| Contract Persistence Relations | [packages/igniter-store/docs/relations-specification.md](../../packages/igniter-store/docs/relations-specification.md) |
| Companion / Store Convergence | [packages/igniter-store/docs/companion-convergence.md](../../packages/igniter-store/docs/companion-convergence.md) |
| Igniter Store Progress Summary | [packages/igniter-store/docs/progress.md](../../packages/igniter-store/docs/progress.md) |
| Contract-Native Store Research (iterations) | [packages/igniter-store/docs/research/store-iterations.md](../../packages/igniter-store/docs/research/store-iterations.md) |
| Contract-Native Store Sync Hub (iterations) | [packages/igniter-store/docs/research/sync-hub-iterations.md](../../packages/igniter-store/docs/research/sync-hub-iterations.md) |
| Companion Current Status Summary | [packages/igniter-companion/docs/current-status.md](../../packages/igniter-companion/docs/current-status.md) |
| Companion Persistence App Status | [packages/igniter-companion/docs/app-status.md](../../packages/igniter-companion/docs/app-status.md) |
| Companion Persistence Manifest Glossary | [packages/igniter-companion/docs/manifest-glossary.md](../../packages/igniter-companion/docs/manifest-glossary.md) |
| Companion Contract Performance Signal | [packages/igniter-companion/docs/performance.md](../../packages/igniter-companion/docs/performance.md) |
| Inter-Agent Compact Handoff (convergence audit) | [docs/store/convergence-audit.md](../store/convergence-audit.md) |

## Read First

Before changing architecture or reviewing an agent proposal, read:

1. [Current Runtime Snapshot](../dev/current-runtime-snapshot.md)
2. [Package Map](../dev/package-map.md)
3. [Module System](../dev/module-system.md)
4. [Igniter Lang Foundation](../guide/igniter-lang-foundation.md)
5. [Horizon Protocol](./horizon-protocol.md)
6. [Vision Handoff Protocol](./vision-handoff-protocol.md)
7. [Project Status Horizon Report](./project-status-horizon-report.md)
8. [Contract Persistence Landing Zone](./contract-persistence-landing-zone.md)
9. [Contract Persistence Roadmap](./contract-persistence-roadmap.md)
10. [Contract Persistence Development Track](./contract-persistence-development-track.md)
11. [Contract Persistence Organic Model](./contract-persistence-organic-model.md)
12. [Wizard Type Spec Research Request](./wizard-type-spec-research-request.md)
13. [Wizard Type Spec Architecture](./wizard-type-spec-architecture.md)

## Current Research State

Status date: 2026-05-02.

- Active package family: `igniter-contracts`, `igniter-extensions`,
  `igniter-embed`, `igniter-application`, `igniter-ai`, `igniter-agents`,
  `igniter-hub`, `igniter-web`, `igniter-cluster`, `igniter-mcp-adapter`.
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
- `igniter-store` has shipped Phase 1 (StoreServer, NetworkBackend, TCP/Unix transport,
  graceful drain, stats, PID, CLI) and Phase 2 (SubscriptionRegistry reactive push).
- `igniter-companion` is now the typed Record/History facade over
  `igniter-store`, carrying Companion manifest pressure toward package-level
  Store/History experiments.
- Cluster owns distributed placement, routing, ownership, health, remediation,
  and mesh attempts. Contracts remain local-first and host-agnostic.

## Rotation Policy

When a research document's subject is fully implemented and shipped:
1. `git mv` it to `packages/<pkg>/docs/` (or `docs/store/` for cross-package convergence records)
2. Add a row to the **Rotated to Package Docs** table above
3. Remove it from the **Index** and **Read First** list
4. Keep governance docs (protocols, long-horizon decisions, landing zones, roadmaps) here permanently

## Compression Rule

Each research document should preserve:

- one claim
- the boundary it changes
- the evidence or source pressure
- the smallest reversible next move
- the reasons not to ship it yet
