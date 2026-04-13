# Igniter — Cluster Debug v1

This document captures the current debugging and recovery pattern for distributed,
owner-routed Igniter systems.

It is intentionally small and practical. The goal is to give workspaces and apps
one clear mental model for observing cluster behavior without falling back to
"open the database and hope".

## Purpose

Cluster debugging in Igniter should answer these questions quickly:

- who owns this entity?
- what cluster-worthy events happened?
- what does the current read model say?
- what does the owner node say?
- can the read model be replayed or repaired?

The debug surface should be:

- owner-aware
- event-aware
- read-model-aware
- safe to use in development and operations

## Core Pattern

The intended layered model is:

```text
owner-local record
  -> cluster event log
  -> projection feed
  -> read model / projection store
  -> debug surfaces
```

That means debugging should not assume that every node sees one shared table.
Instead, it should traverse the same architecture the runtime uses:

1. ownership
2. cluster events
3. projections
4. owner fetch / route-to-owner
5. replay / repair actions

## Canonical Primitives

These primitives now form the current cluster-debug foundation:

- `Igniter::Cluster::Ownership`
  - who owns an entity
  - how to resolve or route to the owner

- `Igniter::Cluster::Events::Log`
  - append cluster-worthy facts
  - inspect recent event history

- `Igniter::Cluster::Events::ProjectionFeed`
  - apply cluster events to read models
  - maintain checkpoints

- `Igniter::Cluster::ProjectionStore`
  - query-friendly derived state

- `Igniter::Cluster::Events::ReadModelProjector`
  - small adapter for turning events into read models

## Debug Surfaces

Recommended debug surfaces for a workspace app:

### 1. Overview

A top-level overview should show:

- cluster event counts by topic
- projection feed checkpoints
- recent ownership claims
- recent projected entities

This is good for:

- "is the system moving?"
- "are feeds advancing?"
- "which topics are active?"

### 2. Entity Drill-Down

For a single entity, expose:

- `raw claim`
- `owner route`
- `raw record`
- `derived projection`
- `recent cluster events`
- `owner fetch`

This is the most useful operational surface because it lets you compare:

- local projection
- local owner metadata
- owner node response

for the same entity.

### 3. Recovery Actions

At minimum, a debug surface should support:

- `replay projection`
- `fetch from owner`

These are safer and more architecture-aligned than manual table edits.

## Hooks / Decorators

`Igniter::Cluster::Events` now supports lightweight hooks around the event pipeline:

- `before_publish`
- `after_publish`
- `around_publish`
- `before_process`
- `after_process`
- `around_process`

These should be used for:

- trace logging
- timing
- audit notes
- dev diagnostics
- lightweight instrumentation

They should **not** become the place for business logic or hidden side effects.

## Home-Lab Pattern

`playgrounds/home-lab` is the first concrete proving ground for this model.

It currently exposes:

- `/api/overview`
- `/api/cluster_events`
- `/api/debug/entities/:entity_type/:id`
- `/api/debug/entities/:entity_type/:id/fetch_owner`
- `/api/debug/entities/:entity_type/:id/replay_projection`

And HTML pages:

- `/`
- `/debug/entities/:entity_type/:id`
- `/debug/entities/:entity_type/:id/fetch_owner`

This is the current reference implementation for cluster-debug UX.

## Recovery Philosophy

Recovery should prefer:

- replaying projections
- comparing against owner response
- re-fetching owner-local state

over:

- direct mutation of shared state
- hand-editing projection tables
- assuming projections are the source of truth

The source of truth should remain:

- owner-local records
- ownership metadata
- cluster events

Projections are repairable products, not canonical truth.

## Anti-Goals

Avoid these defaults:

- direct database-first debugging as the main story
- assuming projections are authoritative
- skipping ownership when investigating entity mismatches
- mixing recovery tools with business mutation tools

## Recommended Workflow

When debugging an entity:

1. open the entity drill-down
2. inspect `raw claim`
3. inspect `owner route`
4. compare local projection vs owner fetch
5. inspect recent cluster events
6. replay the projection if needed

If replay still does not converge, the next suspect is usually:

- bad event ordering
- missing ownership claim
- missing owner-local record
- wrong route-to-owner metadata

## Summary

Cluster debug in Igniter should be:

- ownership-first
- event-first
- projection-aware
- repairable
- visible from the workspace UI
