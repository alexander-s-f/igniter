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

## Package And Layer Boundaries

- [Core](../core/README.md)
- [App](../app/README.md)
- [Cluster](../cluster/README.md)
- [SDK](../sdk/README.md)

## Active Internal Context

- [Namespace Migration Plan](../NAMESPACE_MIGRATION_PLAN.md)
- [Backlog](../BACKLOG.md)
- [Frontend Packages Idea](../FRONTEND_PACKAGES_IDEA.md)
- [Data Ownership](./data-ownership.md)

## Working Heuristics

- Keep end-user onboarding in `docs/guide/`.
- Keep package-local quick reference in `packages/<gem>/README.md`.
- Keep internal design, placement decisions, and rewrite plans in `docs/dev/`.
- Prefer updating a package README and a guide index before writing new deep
  internal prose.
