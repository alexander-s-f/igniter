# Igniter — Persistence Model V1

## Purpose

This document fixes the intended direction for persistence in Igniter.

The goal is not "one database for everything", and not "every node magically sees all state".
The direction is:

- local-first application data
- explicit ownership of state
- small replicated cluster state
- optional external databases as plugins, not as the philosophical center of Igniter

This keeps Igniter aligned with a distributed, decentralized architecture.

## Core Position

Igniter should not assume a single central database as its primary persistence model.

A centralized store such as PostgreSQL can be very useful and should be supported,
but as an optional deployment mode or plugin profile.

The default architecture should remain:

- each node can persist its own local state
- cluster routing knows which node owns which data
- replication is explicit and scoped
- dashboards and read models are derived from events or projections

## Data Classes

Igniter should treat persistence as several different categories of data, not one bucket.

### 1. Local Node Data

Data owned by one node and stored locally.

Examples:

- device sessions
- edge ingest buffers
- temporary media artifacts
- execution snapshots
- local queues
- app-local notes and cached projections

Default storage:

- `SQLite`
- `File`
- `Memory`

Properties:

- fast
- simple
- local-first
- not automatically shared cluster-wide

### 2. Replicated Cluster State

Small but important shared state that the cluster must agree on.

Examples:

- topology
- peer registry
- role ownership
- capability routing
- leases
- bindings between device ids and owner nodes

This belongs to `Igniter::Cluster`, not `Igniter::Application`.

Properties:

- small surface area
- explicit semantics
- replicated or consensus-backed
- not a general-purpose app database

### 3. Derived Read Models

State built from events or projections for query and visualization.

Examples:

- dashboard summaries
- recent activity feeds
- device status overviews
- reminder counts
- audit timelines

Properties:

- can be rebuilt
- may be local or replicated
- optimized for reads
- should not define system ownership

### 4. External Durable Systems

Optional external storage systems integrated by deployment choice.

Examples:

- PostgreSQL
- Redis
- S3-compatible object storage

Properties:

- useful
- often practical
- optional
- should live behind plugins or app profiles

## Ownership Model

The key architectural primitive is ownership.

Igniter should model many entities as being owned by a specific node or role.

Examples:

- a voice session is owned by the `edge` node that accepted it
- a device binding is owned by the node responsible for that device
- an execution snapshot is owned by the node that ran it

Requests should be routed to the owner.

That means the cluster story should prefer:

- "where is the owner?"

over:

- "how do all nodes read the same table?"

## Default Persistence by Layer

### Core

Core should remain storage-agnostic.

It may define interfaces and store adapters, but must not require a database server.

### Application / Workspace

Application profile should be local-first by default.

Recommended defaults:

- `Igniter::Data::Stores::SQLite`
- `Igniter::Runtime::Stores::SQLiteStore`

This is practical for single-node apps and development workspaces.

### Cluster

Cluster should provide explicit distributed state primitives rather than pretending all app data is global.

Likely future primitives:

- ownership registry
- cluster event log / envelopes
- projection store for derived read models
- projection feeds over cluster events
- replicated key-value for small metadata
- leases
- event propagation
- replicated log or projection feeds

### Plugins

External databases should be supported via plugins or deployment profiles.

Examples:

- `Igniter::Plugins::Postgres`
- `Igniter::Plugins::Redis`

These are valid deployment choices, but not the architectural center.

## Anti-Goals

Igniter should avoid these defaults:

- one global database assumed by every app and every node
- hidden cross-node shared state
- app code silently depending on cluster-wide visibility
- treating all data as if it needs consensus

## Home-Lab Implications

The `home-lab` playground is a good test of this model.

For example:

- `voice_sessions` should be owner-local to `edge`
- `show` and `ack` should route to the owner node
- `dashboard` should consume projections or API responses, not assume direct shared DB visibility
- `main` may coordinate workflows without owning every raw edge artifact

This means home-lab should gradually move toward:

- owner-local writes
- explicit routing
- derived read models for monitoring

instead of:

- treating the shared SQLite file as the final cluster abstraction

For the operational/debugging layer that sits on top of this model, see
[Cluster Debug v1](./CLUSTER_DEBUG_V1.md).

## Recommended Next Steps

### Near Term

1. Keep `Igniter::Data` focused on local stores.
2. Add clearer ownership concepts at the cluster level.
3. Distinguish local entity storage from replicated cluster metadata.
4. Use `home-lab` to validate owner-routed flows such as edge device sessions.

### Medium Term

1. Define `Igniter::Cluster` ownership APIs.
2. Add projection store patterns for dashboards and monitoring apps.
3. Introduce replicated metadata primitives for bindings and routing.
4. Introduce external storage plugins for centralized deployment modes.

## Canonical Mental Model

```text
node-local state is normal
shared cluster state is explicit
read models are derived
external databases are optional
```

## Summary

Igniter's persistence direction should be:

- decentralized by default
- local-first in application profiles
- explicit about ownership
- selective about replication
- open to centralized plugins without depending on them
