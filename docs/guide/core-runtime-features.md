# Core Runtime Features

Use this page when you need execution features that still belong to the kernel or
to public core/extension activation surfaces.

## Current Feature Set

- incremental dataflow via `require "igniter/extensions/dataflow"`
- capability policy via `require "igniter/extensions/capabilities"`
- content-addressed reuse via `require "igniter/extensions/content_addressing"`
- cross-execution node caching via `require "igniter/core/node_cache"`
- temporal replay via `require "igniter/core/temporal"`

## Practical Heuristic

Use these features when the goal is still about computation semantics or
execution behavior, not about app hosting or cluster coordination.

If the feature only makes sense with HTTP hosting, external frameworks, or
distributed routing, it probably belongs above core.

## Reading Path

- [Core](../core/README.md)
- [Guide: API And Runtime](./api-and-runtime.md)
- [Dev: Module System](../dev/module-system.md)

## Historical Deep Reference

- [DATAFLOW_V1.md](../DATAFLOW_V1.md)
- [CAPABILITIES_V1.md](../CAPABILITIES_V1.md)
- [CONTENT_ADDRESSING_V1.md](../CONTENT_ADDRESSING_V1.md)
- [NODE_CACHE_V1.md](../NODE_CACHE_V1.md)
- [TEMPORAL_V1.md](../TEMPORAL_V1.md)
