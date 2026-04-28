# Igniter Guide

Use this section for user-facing documentation: learning the framework, choosing
entrypoints, configuring runtime behavior, and building applications on top of
Igniter.

Current loading guidance:

- prefer `require "igniter"` for embedded/default usage
- prefer contracts-facing entrypoints when you are evaluating the migration path
- use package README files for package-specific entrypoints
- treat legacy entrypoints as private/reference context, not onboarding

Pre-v1 status: Igniter intentionally does not promise backward compatibility or
a stable public API yet. Public docs describe the current direction, not a
compatibility contract.

## What Belongs Here

- getting started and first contract/app flows
- public API and entrypoint guidance
- how-to guides and cookbook material
- configuration and operational usage
- examples and package selection guidance

## Canonical Guide Docs

- [Top-level README](../../README.md)
- [Getting Started](./getting-started.md)
- [API And Runtime](./api-and-runtime.md)
- [Contract Class DSL](./contract-class-dsl.md)
- [Igniter Lang Foundation](./igniter-lang-foundation.md)
- [Application Capsules](./application-capsules.md)
- [Application Showcase Portfolio](./application-showcase-portfolio.md)
- [Interactive App Structure](./interactive-app-structure.md)
- [How-Tos](./how-tos.md)
- [Configuration](./configuration.md)
- [Credentials](./credentials.md)
- [Deployment Modes](./deployment-modes.md)
- [Integrations](./integrations.md)
- [Distributed Workflows](./distributed-workflows.md)
- [Core Runtime Features](./core-runtime-features.md)
- [AI And Tool Surfaces](./ai-and-tools.md)
- [Embedded Kernel](./core.md)
- [App](./app.md)
- [Cluster](./cluster.md)
- [CLI](./cli.md)
- [Store Adapters](./store-adapters.md)
- [Contract Persistence Target Plan](../dev/contract-persistence-target-plan.md)

## Core Guide References

- [Concepts](../concepts/README.md)
- [Igniter Concepts](../concepts/igniter.md)
- [Examples](../../examples/README.md)
- [Application Showcase Portfolio](./application-showcase-portfolio.md)

## Package-Level Docs

Package-specific quick reference should live next to the gem that owns the
surface:

- [`packages/igniter-contracts/README.md`](../../packages/igniter-contracts/README.md)
- [`packages/igniter-embed/README.md`](../../packages/igniter-embed/README.md)
- [`packages/igniter-application/README.md`](../../packages/igniter-application/README.md)
- [`packages/igniter-cluster/README.md`](../../packages/igniter-cluster/README.md)
- [`packages/igniter-web/README.md`](../../packages/igniter-web/README.md)
- [`packages/igniter-extensions/README.md`](../../packages/igniter-extensions/README.md)
- [`packages/igniter-mcp-adapter/README.md`](../../packages/igniter-mcp-adapter/README.md)

Cross-package narratives and tutorials stay here in `docs/guide/`.

## Legacy Boundary

Legacy deep references are private working material under `playgrounds/docs/`.
Public onboarding should start from the current guide, package READMEs,
examples, and application showcase path.
