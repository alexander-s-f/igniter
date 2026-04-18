# Data Ownership

Use this page when the question is not “which database?” but “who owns this
state and at which layer?”

## Current Heuristic

- node-local state is normal
- shared cluster state should be explicit and small
- read models should be derived
- external durable systems are deployment choices, not the architectural center

## Layer View

- core stays storage-agnostic
- app/runtime defaults stay local-first
- cluster owns replicated metadata and routing state
- integrations or deployment profiles may add external storage systems

## Ownership Questions

Ask:

1. Which node or layer owns this data?
2. Is this local state, replicated metadata, or a read model?
3. Does it really need shared consensus visibility?

## Historical Deep Reference

- [PERSISTENCE_MODEL_V1.md](../PERSISTENCE_MODEL_V1.md)
