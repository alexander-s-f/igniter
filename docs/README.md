# Igniter Docs

This directory now has two primary lanes:

- [Guide](./guide/README.md) for users of Igniter
- [Dev](./dev/README.md) for contributors working on Igniter itself

Layer indexes still exist, but they now sit under a simpler top-level split.

## Choose Your Lane

### I want to use Igniter

Start with:

1. [Guide](./guide/README.md)
2. [Core](./core/README.md)
3. [Examples](../examples/README.md)

### I want to build an app or stack

Start with:

1. [Guide](./guide/README.md)
2. [App](./app/README.md)
3. [CLI](./CLI.md)
4. [Companion example](../examples/companion/README.md)

### I want distributed execution

Start with:

1. [Guide](./guide/README.md)
2. [Cluster](./cluster/README.md)
3. [cluster/STATE_NEXT.md](./cluster/STATE_NEXT.md)
4. [cluster/ROADMAP_NEXT.md](./cluster/ROADMAP_NEXT.md)

### I want to work on the framework

Start with:

1. [Dev](./dev/README.md)
2. [Architecture Index](./ARCHITECTURE_INDEX.md)
3. The relevant package/layer index below

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

## Compatibility Notes

- Existing V1/V2 docs remain as reference material.
- Existing `docs/general/` and `docs/development/` paths remain as compatibility entrypoints.
- The main change here is navigation and ownership, not a forced rewrite of every deep doc in one pass.
