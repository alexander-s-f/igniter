# Igniter-Lang Bridge Notes

Status: active bridge index
Owner: `[Igniter-Lang Bridge Agent]`

## Purpose

This directory is the landing pad for bridge notes from `igniter-lang`
research into the Igniter platform.

Bridge notes do not authorize package edits. They translate approved language
signals into compact platform requests that the `[Architect Supervisor /
Codex]` can approve, redirect, or reject.

## Bridge Rules

- Start from an approved source signal, fixture, proposal, or completed track.
- Name the bridge claim and target package touch points explicitly.
- Preserve the current fixed point: contract-addressable meaning, explicit
  time, observation evidence, CORE / ESCAPE / OOF, capability gates, receipts,
  SemanticIR with no unresolved overloads, and schema migration evidence.
- Prefer metadata-only sidecar builders, diagnostics, and fixture admission
  before any runtime/package behavior changes.
- Treat Ledger as a possible `TBackend` adapter, not the language core.
- End every bridge note with a handoff in
  `igniter-lang/handoff/HANDOFF_TEMPLATE.md` shape.

## Active Bridge Notes

| Bridge Note | Status | Purpose |
|-------------|--------|---------|
| [bridge-agent-entry-v0.md](bridge-agent-entry-v0.md) | research | Initializes Bridge Agent presence and records current bridge pressure before any package integration request |
| [schema-compatibility-diagnostics-bridge-v0.md](schema-compatibility-diagnostics-bridge-v0.md) | proposal | First metadata-only bridge request for schema compatibility diagnostics |

## Current Bridge Pressure

[S] The bridge surface is ready for analysis but not package integration.
Runtime evidence, packet profiles, FFI receipts, and schema migration receipts
have proof-scale artifacts. The next safe bridge motion is to convert approved
signals into metadata-only sidecar or diagnostics requests.

[S] Schema compatibility diagnostics now have a first bridge request. It stays
read-only and metadata-only: schema versions, schema fingerprints,
`schema_check` outcome, migration availability/ref, compatibility decision, and
evidence links.

[Q] Should the first Architect-approved package slice target core diagnostics,
contract metadata, or application readiness reporting?
