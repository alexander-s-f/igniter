# Igniter Dev

Use this section when you are shaping Igniter itself rather than consuming it as
a framework.

## What Belongs Here

- internal architecture and dependency direction
- placement heuristics across packages and layers
- module/layout rules
- migration plans, implementation notes, and backlog
- contributor-facing design constraints

## Canonical Dev Docs

- [Architecture](./architecture.md)
- [Module System](./module-system.md)
- [Package Map](./package-map.md)
- [Data Ownership](./data-ownership.md)
- [Roadmap And Change Work](./roadmap.md)
- [Legacy Reference](./legacy-reference.md)
- [Contracts Migration Roadmap](./contracts-migration-roadmap.md)
- [DebugPack Spec](./debug-pack-spec.md)

## Package And Layer Boundaries

- [Core](../guide/core.md)
- [App](../guide/app.md)
- [Cluster](../guide/cluster.md)
- [SDK](../guide/sdk.md)

## Active Internal Context

- [Architecture Index](./architecture-index.md)
- [Architecture Reference](./architecture-reference.md)
- [Execution Model](./execution-model.md)
- [Current: App Structure](../current/app-structure.md)
- [Namespace Migration Plan](./namespace-migration-plan.md)
- [Backlog](./backlog.md)
- [Frontend Packages Idea](./frontend-packages-idea.md)
- [Data Ownership](./data-ownership.md)

## Working Heuristics

- Keep end-user onboarding in `docs/guide/`.
- Keep package-local quick reference in `packages/<gem>/README.md`.
- Keep internal design, placement decisions, and rewrite plans in `docs/dev/`.
- Prefer updating a package README and a guide index before writing new deep
  internal prose.
- Before `v1`, do not preserve weak structure for compatibility alone; prefer
  moving toward the target architecture when a better shape is clear.
