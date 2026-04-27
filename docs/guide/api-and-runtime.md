# API And Runtime

Use this index when you already understand the basic idea and want the public
surface area.

## Canonical Public Reads

- [Enterprise Verification](./enterprise-verification.md)
- [Contract Class DSL](./contract-class-dsl.md)
- [Core Runtime Features](./core-runtime-features.md)

## Layer Entry Points

- [Core](./core.md)
- [App](./app.md)
- [Cluster](./cluster.md)
- [SDK](./sdk.md)

Operating modes to keep in mind:

- `Embed` / contracts-first local runtime
- `Application` / local host profile over embed
- `Cluster` / distributed runtime over embed/application

## Focused Topics

- [Contract Class DSL](./contract-class-dsl.md)
- [Igniter Lang Foundation](./igniter-lang-foundation.md)
- [Store Adapters](./store-adapters.md)
- [Deployment Modes](./deployment-modes.md)

## Package Quick Reference

Package-specific entrypoints live next to the owning gem:

- [`packages/igniter-contracts/README.md`](../../packages/igniter-contracts/README.md)
- [`packages/igniter-embed/README.md`](../../packages/igniter-embed/README.md)
- [`packages/igniter-application/README.md`](../../packages/igniter-application/README.md)
- [`packages/igniter-cluster/README.md`](../../packages/igniter-cluster/README.md)
