# Core Runtime Features

Use this page when you need execution features that still belong to the kernel or
to public core/extension activation surfaces.

## Current Feature Set

- incremental dataflow via `Igniter::Extensions::Contracts::DataflowPack`
- capability policy via `Igniter::Extensions::Contracts::CapabilitiesPack`
- content-addressed reuse via `Igniter::Extensions::Contracts::ContentAddressingPack`
- cross-execution node caching via `require "igniter/core/node_cache"`
- temporal replay via `require "igniter/core/temporal"`

The legacy `require "igniter/extensions/*"` activators still exist during
retirement, but they are now migration shims rather than the preferred public
path.

## Practical Heuristic

Use these features when the goal is still about computation semantics or
execution behavior, not about app hosting or cluster coordination.

If the feature only makes sense with HTTP hosting, external frameworks, or
distributed routing, it probably belongs above core.

## Reading Path

- [Core](./core.md)
- [Guide: API And Runtime](./api-and-runtime.md)
- [Dev: Module System](../dev/module-system.md)

## Historical Deep Reference

- [DATAFLOW_V1.md](../DATAFLOW_V1.md)
- [CAPABILITIES_V1.md](../CAPABILITIES_V1.md)
- [CONTENT_ADDRESSING_V1.md](../CONTENT_ADDRESSING_V1.md)
- [NODE_CACHE_V1.md](../NODE_CACHE_V1.md)
- [TEMPORAL_V1.md](../TEMPORAL_V1.md)
