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
- [Companion Persistence App Status](./companion-persistence-app-status.md) -
  current app-local persistence proof and handoff.
- [Contract Persistence Relations](./contract-persistence-relations.md) -
  research model, specification, and DSL for relation manifests.

## Read First

Before changing architecture or reviewing an agent proposal, read:

1. [Current Runtime Snapshot](../dev/current-runtime-snapshot.md)
2. [Package Map](../dev/package-map.md)
3. [Module System](../dev/module-system.md)
4. [Igniter Lang Foundation](../guide/igniter-lang-foundation.md)
5. [Horizon Protocol](./horizon-protocol.md)
6. [Vision Handoff Protocol](./vision-handoff-protocol.md)
7. [Companion Persistence App Status](./companion-persistence-app-status.md)
8. [Contract Persistence Relations](./contract-persistence-relations.md)

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
  app-local persistence proof now covers records, histories, projections,
  command mutation intents, registry/readiness/manifest, and report-only
  `index`/`scope`/`command` metadata.
- Cluster owns distributed placement, routing, ownership, health, remediation,
  and mesh attempts. Contracts remain local-first and host-agnostic.

## Compression Rule

Each research document should preserve:

- one claim
- the boundary it changes
- the evidence or source pressure
- the smallest reversible next move
- the reasons not to ship it yet
