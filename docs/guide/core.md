# Core

Use this section when the thing you care about should still make sense in embedded mode with `require "igniter"`.

## Core Means

- contract DSL
- graph model and compilation
- runtime execution and invalidation
- diagnostics, introspection, provenance-friendly observation
- dataflow semantics such as branches, collections, async/deferred execution

If a capability stops making sense without hosting, networking, or optional packs, it probably does not belong in core.

## Current First Reads

- [Guide](../guide/README.md)
- [Guide: API And Runtime](../guide/api-and-runtime.md)
- [Guide: Core Runtime Features](../guide/core-runtime-features.md)
- [Igniter Concepts](../IGNITER_CONCEPTS.md)
- [Dev: Architecture](../dev/architecture.md)

## Supporting Reference

- [Patterns](../PATTERNS.md)
- [Guide: Core Runtime Features](../guide/core-runtime-features.md)
- [Dev: Legacy Reference](../dev/legacy-reference.md)

## When To Leave Core

- Move to [App](../app/README.md) when you need app runtime/profile concerns.
- Move to [Cluster](../cluster/README.md) when you need networking, mesh, routing, replication, or resilience.
- Move to [SDK](../sdk/README.md) when you need optional packs such as AI, channels, tools, skills, or data.
