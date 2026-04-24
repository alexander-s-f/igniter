# Igniter Guide

Use this section for user-facing documentation: learning the framework, choosing
entrypoints, configuring runtime behavior, and building applications on top of
Igniter.

Current loading guidance:

- prefer `require "igniter"` for embedded/default usage
- prefer contracts-facing entrypoints when you are evaluating the migration path
- treat `require "igniter/core"` as a deprecated compatibility alias
- use `require "igniter/legacy"` only when you intentionally want the explicit
  legacy/reference lane

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
- [Application Capsules](./application-capsules.md)
- [How-Tos](./how-tos.md)
- [Configuration](./configuration.md)
- [Deployment Modes](./deployment-modes.md)
- [Integrations](./integrations.md)
- [Distributed Workflows](./distributed-workflows.md)
- [Core Runtime Features](./core-runtime-features.md)
- [AI And Tool Surfaces](./ai-and-tools.md)
- [Embedded Kernel](./core.md)
- [App](./app.md)
- [Cluster](./cluster.md)
- [SDK](./sdk.md)
- [CLI](./cli.md)
- [Store Adapters](./store-adapters.md)
- [Frontend Authoring](./frontend-authoring.md)
- [Frontend Components](./frontend-components.md)
- [Schema Rendering Authoring](./schema-rendering-authoring.md)

## Core Guide References

- [Concepts](../concepts/README.md)
- [Igniter Concepts](../concepts/igniter.md)
- [Patterns](../concepts/patterns.md)
- [Examples](../../examples/README.md)
- [Companion example](../../examples/companion/README.md)

## Package-Level Docs

Package-specific quick reference should live next to the gem that owns the
surface:

- [`packages/igniter-contracts/README.md`](../../packages/igniter-contracts/README.md)
- [`packages/igniter-core/README.md`](../../packages/igniter-core/README.md)
- [`packages/igniter-ai/README.md`](../../packages/igniter-ai/README.md)
- [`packages/igniter-sdk/README.md`](../../packages/igniter-sdk/README.md)
- [`packages/igniter-app/README.md`](../../packages/igniter-app/README.md)
- [`packages/igniter-server/README.md`](../../packages/igniter-server/README.md)
- [`packages/igniter-cluster/README.md`](../../packages/igniter-cluster/README.md)
- [`packages/igniter-web/README.md`](../../packages/igniter-web/README.md)
- [`packages/igniter-extensions/README.md`](../../packages/igniter-extensions/README.md)
- [`packages/igniter-rails/README.md`](../../packages/igniter-rails/README.md)
- [`packages/igniter-frontend/README.md`](../../packages/igniter-frontend/README.md)
- [`packages/igniter-schema-rendering/README.md`](../../packages/igniter-schema-rendering/README.md)

Cross-package narratives and tutorials stay here in `docs/guide/`.

## Legacy Reference

Older deep documents still exist, but they should usually be reached through the
guide indexes above or the [legacy reference list](../dev/legacy-reference.md).
`packages/igniter-core/README.md` should now be read as reference/compatibility
material rather than the default path for new onboarding.
