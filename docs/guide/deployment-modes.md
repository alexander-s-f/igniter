# Deployment Modes

Igniter has three practical usage modes. The important part is that the domain
graph can stay stable while the runtime grows around it.

## 1. Embedded

Use this when Igniter is just the business-logic kernel inside another app.

Load:

```ruby
require "igniter"
```

Optional additions:

```ruby
require "igniter/core"
require "igniter/extensions/dataflow"
require "igniter/extensions/saga"
require "igniter/sdk/data"
```

Choose this when:

- contracts are called directly from Rails, jobs, scripts, or services
- you want compile-time validation and lazy execution without hosting
- HTTP, stack scaffolding, and cluster behavior are not needed

## 2. App / Server

Use this when Igniter becomes the runtime shape of a standalone app.

Load:

```ruby
require "igniter/app"
```

Add packs only when needed:

```ruby
require "igniter/sdk/agents"
require "igniter/sdk/ai"
require "igniter/sdk/channels"
require "igniter/plugins/rails"
```

Choose this when:

- you want stack/app conventions
- you want built-in HTTP hosting and background scheduling
- one machine or one local stack is still enough

## 3. Cluster

Use this when the network itself becomes part of execution.

Load:

```ruby
require "igniter/cluster"
```

Choose this when:

- contracts need capability-based remote routing
- ownership, replication, trust, and distributed coordination matter
- a single node is no longer the right operational shape

## Current Entry Point Heuristic

Prefer the smallest public require that matches the job:

| Need | Require |
|------|---------|
| Core contracts/runtime | `require "igniter"` |
| Actor/tool foundation | `require "igniter/core"` |
| Extensions | `require "igniter/extensions/<feature>"` |
| SDK pack | `require "igniter/sdk/<pack>"` |
| App runtime/profile | `require "igniter/app"` |
| Stack coordination | `require "igniter/stack"` |
| Cluster runtime | `require "igniter/cluster"` |
| Rails integration | `require "igniter/plugins/rails"` |

## See Also

- [Getting Started](./getting-started.md)
- [Configuration](./configuration.md)
- [App](../app/README.md)
- [Cluster](../cluster/README.md)
