# Core Runtime Features

Use this page for features that still belong near the embedded contracts
kernel.

## Current Shape

- contract DSL and class DSL
- graph compilation and validation
- local execution
- diagnostics and structured reports
- explicit optional packs from `igniter-extensions`

Optional features should be installed through explicit packs. Avoid hidden
global activation and old `igniter/core/*` entrypoints in new public examples.

## Heuristic

Keep a feature near the embedded kernel when it is about computation semantics
or local execution behavior.

Move it upward when it needs:

- app boot/profile lifecycle
- web rendering or browser interaction
- framework integration
- distributed routing or placement

## Reading Path

- [Core](./core.md)
- [API And Runtime](./api-and-runtime.md)
- [Module System](../dev/module-system.md)
- [`packages/igniter-extensions/README.md`](../../packages/igniter-extensions/README.md)
