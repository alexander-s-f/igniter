# Igniter Docs

`docs/` is organized by section. Start here, then jump into the lane that matches
what you are trying to do.

## Sections

- [Guide](./guide/README.md) for user-facing docs: getting started, API,
  configuration, integrations, and how-tos
- [Concepts](./concepts/README.md) for mental models and design language
- [Dev](./dev/README.md) for public architecture and package boundaries
- [Assets](./assets/README.md) for shared documentation media such as logos

## Reading Paths

### I want to use Igniter

1. [Guide](./guide/README.md)
2. [Getting Started](./guide/getting-started.md)
3. [Core Runtime Features](./guide/core-runtime-features.md)
4. [Concepts](./concepts/README.md)
5. [Examples](../examples/README.md)

### I want to build an app or stack

1. [Guide](./guide/README.md)
2. [Enterprise Verification](./guide/enterprise-verification.md)
3. [Application Showcase Portfolio](./guide/application-showcase-portfolio.md)
4. [Interactive App Structure](./guide/interactive-app-structure.md)
5. [Examples](../examples/README.md)

### I want distributed execution

1. [Guide](./guide/README.md)
2. [Deployment Modes](./guide/deployment-modes.md)
3. [Distributed Workflows](./guide/distributed-workflows.md)
4. [Cluster](./guide/cluster.md)

### I want to work on the framework

1. [Dev](./dev/README.md)
2. [Architecture](./dev/architecture.md)
3. [Module System](./dev/module-system.md)
4. [Package Map](./dev/package-map.md)

## Package Docs

Package-local quick reference belongs next to the owning gem under
`packages/<gem>/README.md`.

Cross-package product docs belong in [`guide/`](./guide/README.md),
cross-package mental models in [`concepts/`](./concepts/README.md), and public
architecture work in [`dev/`](./dev/README.md).

Legacy deep references and internal history are private working material under
`playgrounds/docs/`, not public onboarding.
