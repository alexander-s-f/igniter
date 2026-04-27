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

- [Active Tracks Index](./tracks.md)
- [Tracks History](./tracks-history.md)
- [Constraint Sets](./constraints.md)
- [Agent Track Lifecycle Doctrine](./agent-track-lifecycle-doctrine.md)
- [Documentation Compression Doctrine](./documentation-compression-doctrine.md)
- [Current Runtime Snapshot](./current-runtime-snapshot.md)
- [Architecture](./architecture.md)
- [Module System](./module-system.md)
- [Package Map](./package-map.md)
- [Data Ownership](./data-ownership.md)
- [Roadmap And Change Work](./roadmap.md)
- [Legacy Reference](./legacy-reference.md)
- [Contracts Migration Roadmap](./contracts-migration-roadmap.md)
- [Contracts And Extensions Stewardship](./contracts-extensions-stewardship.md)
- [Human Sugar DSL Doctrine](./human-sugar-dsl-doctrine.md)
- [Embed Target Plan](./embed-target-plan.md)
- [Application Target Plan](./application-target-plan.md)
- [Application And Web Integration](./application-web-integration.md)
- [Application Web POC Pattern Guide](./application-web-poc-pattern-guide.md)
- [Enterprise Verification Receipt Hardening Track](./enterprise-verification-receipt-hardening-track.md)
- [Enterprise Public Entry Surface Hygiene Track](./enterprise-public-entry-surface-hygiene-track.md)
- [Enterprise Release Readiness Checklist Track](./enterprise-release-readiness-checklist-track.md)
- [Documentation Compression Solo Track](./documentation-compression-solo-track.md)
- [Cluster Target Plan](./cluster-target-plan.md)
- [Igniter Web Target Plan](./igniter-web-target-plan.md)
- [Core Retirement Inventory](./core-retirement-inventory.md)
- [DebugPack Spec](./debug-pack-spec.md)
- [MCP Adapter Package](./mcp-adapter-package-spec.md)

Older track files remain in this directory as cold history. Use
[Tracks History](./tracks-history.md), accepted track links, or `rg` when you
need a specific slice.

## Package And Layer Boundaries

- [Core](../guide/core.md)
- [App](../guide/app.md)
- [Cluster](../guide/cluster.md)
- [SDK](../guide/sdk.md)

## Active Internal Context

- [Active Tracks Index](./tracks.md)
- [Tracks History](./tracks-history.md)
- [Constraint Sets](./constraints.md)
- [Agent Track Lifecycle Doctrine](./agent-track-lifecycle-doctrine.md)
- [Documentation Compression Doctrine](./documentation-compression-doctrine.md)
- [Architecture Index](./architecture-index.md)
- [Architecture Reference](./architecture-reference.md)
- [Execution Model](./execution-model.md)
- [Current: App Structure](../current/app-structure.md)
- [Namespace Migration Plan](./namespace-migration-plan.md)
- [Backlog](./backlog.md)
- [Application Web POC Pattern Guide](./application-web-poc-pattern-guide.md)
- [Handoff Doctrine](./handoff-doctrine.md)
- [Interaction Doctrine](./interaction-doctrine.md)
- [Runtime Observatory Doctrine](./runtime-observatory-doctrine.md)
- [Embed Contract Class Integration Track](./embed-contract-class-integration-track.md)
- [Differential Shadow Contractable Track](./differential-shadow-contractable-track.md)
- [Human Sugar DSL Doctrine](./human-sugar-dsl-doctrine.md)
- [Data Ownership](./data-ownership.md)

If this list starts accumulating cycle-specific track files again, move them to
[Tracks History](./tracks-history.md) or keep them discoverable by search
instead of turning this README into a full archive.

## Research Horizon

- [Research Horizon](../research-horizon/README.md)
- [Current State Report](../research-horizon/current-state-report.md)
- [Horizon Proposals](../research-horizon/horizon-proposals.md)
- [Supervisor Review](../research-horizon/supervisor-review.md)

## Working Heuristics

- Keep end-user onboarding in `docs/guide/`.
- Keep package-local quick reference in `packages/<gem>/README.md`.
- Keep internal design, placement decisions, and rewrite plans in `docs/dev/`.
- Prefer updating a package README and a guide index before writing new deep
  internal prose.
- Before `v1`, do not preserve weak structure for compatibility alone; prefer
  moving toward the target architecture when a better shape is clear.
