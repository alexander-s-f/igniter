# Igniter Docs

This directory now has two primary lanes:

- [Guide](./guide/README.md) for users of Igniter
- [Dev](./dev/README.md) for contributors working on Igniter itself

Layer indexes still exist, but they now sit under a simpler top-level split.

## Choose Your Lane

### I want to use Igniter

Start with:

1. [Guide](./guide/README.md)
2. [Getting Started](./guide/getting-started.md)
3. [Core Runtime Features](./guide/core-runtime-features.md)
4. [Core](./core/README.md)
5. [Examples](../examples/README.md)

### I want to build an app or stack

Start with:

1. [Guide](./guide/README.md)
2. [How-Tos](./guide/how-tos.md)
3. [AI And Tool Surfaces](./guide/ai-and-tools.md)
4. [App](./app/README.md)
5. [CLI](./CLI.md)
6. [Companion example](../examples/companion/README.md)

### I want distributed execution

Start with:

1. [Guide](./guide/README.md)
2. [Deployment Modes](./guide/deployment-modes.md)
3. [Configuration](./guide/configuration.md)
4. [Distributed Workflows](./guide/distributed-workflows.md)
5. [Cluster](./cluster/README.md)
6. [cluster/STATE_NEXT.md](./cluster/STATE_NEXT.md)
7. [cluster/ROADMAP_NEXT.md](./cluster/ROADMAP_NEXT.md)

### I want to work on the framework

Start with:

1. [Dev](./dev/README.md)
2. [Architecture](./dev/architecture.md)
3. [Module System](./dev/module-system.md)
4. [Package Map](./dev/package-map.md)
5. [Data Ownership](./dev/data-ownership.md)
6. The relevant package/layer index below

## Layer Indexes

- [Core](./core/README.md)
- [App](./app/README.md)
- [Cluster](./cluster/README.md)
- [SDK](./sdk/README.md)

## Package Docs

User-facing package quick reference belongs next to the owning gem under
`packages/<gem>/README.md`.

Cross-package guides, tutorials, and conceptual API maps belong in
[`guide/`](./guide/README.md).

Internal architecture, placement decisions, migration plans, and backlog belong
in [`dev/`](./dev/README.md).

Legacy deep-reference documents are cataloged in
[`dev/legacy-reference.md`](./dev/legacy-reference.md).

## Compatibility Notes

- Existing legacy docs remain as reference material.
- Existing `docs/general/` and `docs/development/` paths remain as compatibility entrypoints.
- The main change here is navigation and ownership, not a forced rewrite of every deep doc in one pass.
