# Core

This document currently describes the embedded/kernel role. In the target
architecture, the clearer name for that role is `Embed`.

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
- [Dev: Embed Target Plan](../dev/embed-target-plan.md)
- [Igniter Concepts](../concepts/igniter.md)
- [Dev: Architecture](../dev/architecture.md)

## Supporting Reference

- [Guide: Core Runtime Features](../guide/core-runtime-features.md)

## When To Leave Core

- Move to [App](./app.md) when you need app runtime/profile concerns.
- Move to [Cluster](./cluster.md) when you need networking, mesh, routing,
  replication, or resilience.
- Move to [SDK](./sdk.md) when you need optional packs such as AI, channels,
  tools, skills, or data.

Current design direction:

- treat this layer as the canonical embedded/contracts-first operating mode
- do not let it absorb application or cluster concerns by default
- for the target model, follow the [Embed Target Plan](../dev/embed-target-plan.md)
