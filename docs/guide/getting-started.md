# Getting Started

This is the shortest user-facing path into Igniter.

## 1. Start With The Core Idea

Read:

- [Top-level README](../../README.md)
- [Igniter Concepts](../concepts/igniter.md)
- [Core](./core.md)
- [Enterprise Verification](./enterprise-verification.md)

## 2. Run Something Real

Use:

- [Examples](../../examples/README.md)
- [Application Showcase Portfolio](./application-showcase-portfolio.md)
- [Interactive App Structure](./interactive-app-structure.md)

## 3. Pick The Runtime Shape

- Stay in [Core](./core.md) if you only need embedded contracts and execution.
- Move to [App](./app.md) if Igniter becomes the runtime of an app.
- Move to [Cluster](./cluster.md) if execution becomes distributed.
- Add [Extensions](../../packages/igniter-extensions/README.md) only when
  optional capabilities are needed.

Current architecture note:

- `Core` here really means the embedded/contracts-first operating mode
- `App` builds on top of that embedded mode
- `Cluster` builds on top of embedded/application runtime

## 4. Scaffold When You Want The Standard Shape

Read:

- [CLI](./cli.md)
- [Application Capsules](./application-capsules.md)

Then try:

```bash
bin/igniter-stack new my_app
bin/igniter-stack new my_hub --profile dashboard
bin/igniter-stack new mesh_lab --profile cluster
```
