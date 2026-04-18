# OLAP Point — v1

Each cluster node is a multi-dimensional queryable surface. This document names that concept, defines its dimensions, and explains how it gives the cluster a unified mental model for routing, placement, and the future query language.

## The Core Idea

Traditional OLAP means multi-dimensional data analysis: slice, dice, drill down across dimensions such as time, region, and product.

An **OLAP Point** applies that same idea to a cluster node:

> Every node is an OLAP Point — a snapshot of its own observable state across several independent dimensions.

The cluster is then a **distributed OLAP field**: a live collection of points you can query, filter, rank, and aggregate across any combination of dimensions.

This is not a new runtime abstraction. It is a naming and framing decision that unifies the capability mesh, the trust model, placement reasoning, and future knowledge queries into one coherent picture.

## Dimensions

Each node exposes these dimensions:

### 1. Capabilities (`can_do`)

What the node is able to do.

- Static capabilities declared at boot
- Runtime capabilities observed during execution
- Policy-constrained capabilities (`allowed_to_do`)
- Freshness and confidence of each capability claim

This dimension is already fully operational as `CapabilityQuery`.

### 2. State (`load`, `health`, `concurrency`)

The node's current runtime condition.

- CPU and memory pressure
- Active contract executions
- Queue depth
- Health probe results

This dimension already exists as gossip metadata. The next step is making it a first-class protocol field inside the observation envelope.

### 3. Trust (`trust_level`, `signed_by`, `trusted_peers`)

The node's identity and its standing in the mesh.

- Stable `node_id`
- Per-node keypair
- Signed capability attestations
- Trusted peer set and verification state
- Trust-weighted routing preference

This dimension is already operational as Phase 1 of the cluster roadmap.

### 4. Locality (`region`, `zone`, `proximity`)

Where the node lives in the physical or logical topology.

- Cloud region and availability zone
- Network proximity to other peers
- Rack or datacenter affiliation

Locality shapes placement and routing latency without becoming a hard constraint.

### 5. Governance (`trail`, `checkpoint`, `crest`)

The node's cluster governance state.

- Signed governance checkpoint
- Compacted trail crest
- Pending approvals and governance actions
- Replicated checkpoint exchange state

This dimension is already operational as the governance slice.

### 6. Knowledge (`domain`, `shards`, `index_size`)

What domain knowledge the node carries.

- Local knowledge shards (future: RAG layer)
- Domain affinity tags
- Index coverage and freshness

This dimension is not yet implemented. It is the target of Phase 5 (Decentralized Knowledge Plane).

## Why This Framing Matters

Before OLAP Point framing, the cluster had several independent subsystems:

- capability routing
- identity/trust
- governance trail
- gossip metadata

These felt like separate concerns. The OLAP Point model shows that they are actually **dimensions of the same thing**: the node's observable profile. Every phase of the cluster roadmap is adding a new dimension to the same per-node snapshot.

This has concrete payoffs:

1. **Routing** is a filter over the capability dimension. When it also factors in trust and load, it becomes a multi-dimensional query — not a different routing mechanism.

2. **Placement** is a ranking over multiple dimensions simultaneously: best-fit capability, lowest load, nearest locality, highest trust.

3. **Diagnostics** can explain a routing failure in terms of which dimension eliminated a candidate: "node X is excluded because its trust level is below required" reads better than "routing failed".

4. **MeshQL** becomes natural once nodes expose a standard dimensional surface. A query language is just a grammar over this field.

## What OLAP Point Is Not

OLAP Point is **not**:

- A new runtime object in core
- A breaking change to CapabilityQuery
- A data warehouse or analytics system
- A reason to rebuild gossip or consensus

It is a **naming layer** over existing and upcoming work that makes the evolution of the cluster legible.

## Relationship to the Cluster Roadmap

| Phase | What It Adds | OLAP Dimension |
|-------|-------------|----------------|
| Phase 0: Capability Mesh | CapabilityQuery routing | capabilities |
| Phase 1: Identity & Trust | Signed manifests, trust store | trust |
| Phase 2: Discovery Protocol | Canonical observation envelope | formalizes all dimensions |
| Phase 3: Placement & Rebalancing | Multi-dimension ranking at placement time | capabilities + load + trust + locality |
| Phase 5: Knowledge Plane | Local shards, distributed retrieval | knowledge |
| Phase 6: Signed Crest | Bounded, auditable replicated state | governance |

**Phase 2 is the key enabler.** A formal discovery protocol means the observation envelope gains a canonical shape across all dimensions. That canonical shape is the OLAP Point protocol surface.

## The Observation Envelope

The canonical per-node snapshot that Phase 2 should produce:

```text
NodeObservation {
  node_id          stable identity
  observed_at      wall clock timestamp
  observed_by      peer that produced this snapshot (self or relay)
  signed_by        signing key reference
  signature        compact attestation over the payload

  capabilities []  {name, available_now, allowed_to_do, confidence}
  state        {}  {load, health, concurrency, queue_depth}
  trust        {}  {level, trusted_peer_ids, last_verified_at}
  locality     {}  {region, zone, proximity_tags}
  governance   {}  {checkpoint_id, crest_digest, pending_approvals}
  knowledge    []  {domain, shard_count, index_freshness}   # Phase 5
}
```

The gossip layer propagates these envelopes. CapabilityQuery already queries the capability slice. The OLAP Point model means routing, placement, and diagnostics can all query the same envelope differently.

## MeshQL — Future Direction

Once nodes expose a standard OLAP Point envelope, a query language becomes possible.

Conceptual sketch:

```
SELECT node_id, capability(:database), load(:cpu), trust.level
FROM cluster
WHERE trust.level >= :trusted
  AND locality.zone = "us-east-1a"
  AND capability(:database).available_now = true
ORDER BY load(:cpu) ASC
LIMIT 3
```

MeshQL is **not in scope for v1**. The preconditions are:

1. Formal observation envelope (Phase 2)
2. At least capabilities + trust + load dimensions in the protocol
3. A query execution model (local evaluation vs. distributed fan-out)

For the MeshQL design, see `MESH_QL_V1.md` when that document exists.

## Implementation Path

Phase 2 discovery protocol is the immediate next step:

1. Define `NodeObservation` as a first-class value object in the cluster layer.
2. Make gossip propagate full observation envelopes, not just raw capability hashes.
3. Give CapabilityQuery an `ObservationPoint` input instead of raw peer metadata.
4. Add dimension fields incrementally as phases land (trust already there; load and locality next).
5. MeshQL can start as a Ruby DSL over `ObservationPoint` arrays before it becomes a query grammar.

## Placement Heuristics

If you are deciding where to put new code related to OLAP Point:

- Observation envelope and dimension schemas → `lib/igniter/cluster/mesh/`
- CapabilityQuery extensions for multi-dimensional ranking → `lib/igniter/cluster/`
- MeshQL parser and execution → `lib/igniter/cluster/query/` (future)
- Knowledge dimension and shard indexing → `lib/igniter/sdk/rag/` (Phase 5)

Core must never know about OLAP Point. The cluster layer owns all of this.
