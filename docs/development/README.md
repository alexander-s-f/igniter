# Development Context

Use this section when you are shaping Igniter itself rather than only consuming it.

## What This Covers

- boundary discipline between layers
- placement heuristics for new code
- filesystem and module layout
- contributor-facing architecture context

## Read First

- [Architecture Index](../ARCHITECTURE_INDEX.md)
- [Layers v1](../LAYERS_V1.md)
- [Module System v1](../MODULE_SYSTEM_V1.md)

## Historical / Planning Docs

- [Namespace Migration Plan](../NAMESPACE_MIGRATION_PLAN.md)
- [Backlog](../BACKLOG.md)

## Working Heuristics

- Put things in `core` only if they remain valuable in embedded mode.
- Put things in `app` when they are about runtime profile, boot shape, or single-node operational behavior.
- Put things in `cluster` when the network becomes part of the execution model.
- Put things in `sdk` when the capability is reusable and optional.
- Prefer adding navigational docs and layer indexes before rewriting every deep reference at once.

## Adjacent Context

- [General](../general/README.md)
- [Core](../core/README.md)
- [App](../app/README.md)
- [Cluster](../cluster/README.md)
- [SDK](../sdk/README.md)
