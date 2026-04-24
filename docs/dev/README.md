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
- [Post-Core Target Plan](./post-core-target-plan.md)
- [Canonical Runtime Shapes](./canonical-runtime-shapes.md)
- [Embed Target Plan](./embed-target-plan.md)
- [Embed Contract Class Integration Track](./embed-contract-class-integration-track.md)
- [Differential Shadow Contractable Track](./differential-shadow-contractable-track.md)
- [Application Target Plan](./application-target-plan.md)
- [Application And Web Integration](./application-web-integration.md)
- [Agent-Native Application Track Proposal](./agent-native-application-track-proposal.md)
- [Agent-Native Interaction Session Track](./agent-native-interaction-session-track.md)
- [Application Feature Slice And Flow Declaration Track](./application-feature-slice-flow-track.md)
- [Application Capsule Inspection Track](./application-capsule-inspection-track.md)
- [Application Capsule Guide Track](./application-capsule-guide-track.md)
- [Cluster Target Plan](./cluster-target-plan.md)
- [Igniter Web Target Plan](./igniter-web-target-plan.md)
- [Igniter Web DSL Sketch](./igniter-web-dsl-sketch.md)
- [Igniter Web Composition Track](./igniter-web-composition-track.md)
- [Core Retirement Inventory](./core-retirement-inventory.md)
- [DebugPack Spec](./debug-pack-spec.md)
- [MCP Adapter Package](./mcp-adapter-package-spec.md)

## Package And Layer Boundaries

- [Core](../guide/core.md)
- [App](../guide/app.md)
- [Cluster](../guide/cluster.md)
- [SDK](../guide/sdk.md)

## Active Internal Context

- [Active Tracks Index](./tracks.md)
- [Architecture Index](./architecture-index.md)
- [Architecture Reference](./architecture-reference.md)
- [Execution Model](./execution-model.md)
- [Current: App Structure](../current/app-structure.md)
- [Namespace Migration Plan](./namespace-migration-plan.md)
- [Backlog](./backlog.md)
- [Frontend Packages Idea](./frontend-packages-idea.md)
- [Igniter Web Target Plan](./igniter-web-target-plan.md)
- [Igniter Web DSL Sketch](./igniter-web-dsl-sketch.md)
- [Igniter Web Composition Track](./igniter-web-composition-track.md)
- [Agent-Native Application Track Proposal](./agent-native-application-track-proposal.md)
- [Agent-Native Interaction Session Track](./agent-native-interaction-session-track.md)
- [Application Feature Slice And Flow Declaration Track](./application-feature-slice-flow-track.md)
- [Application Capsule Inspection Track](./application-capsule-inspection-track.md)
- [Application Capsule Guide Track](./application-capsule-guide-track.md)
- [Embed Contract Class Integration Track](./embed-contract-class-integration-track.md)
- [Differential Shadow Contractable Track](./differential-shadow-contractable-track.md)
- [Human Sugar DSL Doctrine](./human-sugar-dsl-doctrine.md)
- [Data Ownership](./data-ownership.md)

## Working Heuristics

- Keep end-user onboarding in `docs/guide/`.
- Keep package-local quick reference in `packages/<gem>/README.md`.
- Keep internal design, placement decisions, and rewrite plans in `docs/dev/`.
- Prefer updating a package README and a guide index before writing new deep
  internal prose.
- Before `v1`, do not preserve weak structure for compatibility alone; prefer
  moving toward the target architecture when a better shape is clear.
