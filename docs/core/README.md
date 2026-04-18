# Core

Use this section when the thing you care about should still make sense in embedded mode with `require "igniter"`.

## Core Means

- contract DSL
- graph model and compilation
- runtime execution and invalidation
- diagnostics, introspection, provenance-friendly observation
- dataflow semantics such as branches, collections, async/deferred execution

If a capability stops making sense without hosting, networking, or optional packs, it probably does not belong in core.

## Read First

- [Guide](../guide/README.md)
- [Guide: API And Runtime](../guide/api-and-runtime.md)
- [Igniter Concepts](../IGNITER_CONCEPTS.md)
- [Architecture v2](../ARCHITECTURE_V2.md)
- [Execution Model v2](../EXECUTION_MODEL_V2.md)
- [API v2](../API_V2.md)

## Focused Topics

- [Patterns](../PATTERNS.md)
- [Dataflow v1](../DATAFLOW_V1.md)
- [Branches v1](../BRANCHES_V1.md)
- [Collections v1](../COLLECTIONS_V1.md)
- [Node Cache v1](../NODE_CACHE_V1.md)
- [Persistence Model v1](../PERSISTENCE_MODEL_V1.md)
- [Content Addressing v1](../CONTENT_ADDRESSING_V1.md)
- [Temporal v1](../TEMPORAL_V1.md)
- [Capabilities v1](../CAPABILITIES_V1.md)

## Legacy Reference Note

Many focused topics here are still documented in `*_V1` files. Treat them as
deep reference behind the guide/dev indexes, not as the primary onboarding path.

## When To Leave Core

- Move to [App](../app/README.md) when you need app runtime/profile concerns.
- Move to [Cluster](../cluster/README.md) when you need networking, mesh, routing, replication, or resilience.
- Move to [SDK](../sdk/README.md) when you need optional packs such as AI, channels, tools, skills, or data.
