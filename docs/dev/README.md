# Igniter Dev

Use this section when you are shaping Igniter itself rather than consuming it as
a framework.

## What Belongs Here

- internal architecture and dependency direction
- placement heuristics across packages and layers
- module/layout rules
- migration plans, implementation notes, and backlog
- contributor-facing design constraints

## Start Here

- [Architecture Index](../ARCHITECTURE_INDEX.md)
- [Architecture v2](../ARCHITECTURE_V2.md)
- [Layers v1](../LAYERS_V1.md)
- [Module System v1](../MODULE_SYSTEM_V1.md)

## Package And Layer Boundaries

- [Core](../core/README.md)
- [App](../app/README.md)
- [Cluster](../cluster/README.md)
- [SDK](../sdk/README.md)

## Active Internal Context

- [Namespace Migration Plan](../NAMESPACE_MIGRATION_PLAN.md)
- [Backlog](../BACKLOG.md)
- [Frontend Packages Idea](../FRONTEND_PACKAGES_IDEA.md)

## Working Heuristics

- Keep end-user onboarding in `docs/guide/`.
- Keep package-local quick reference in `packages/<gem>/README.md`.
- Keep internal design, placement decisions, and rewrite plans in `docs/dev/`.
- Prefer updating a package README and a guide index before writing new deep
  internal prose.
