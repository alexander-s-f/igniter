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
require "igniter/legacy"
require "igniter/extensions/dataflow"
require "igniter/extensions/saga"
require "igniter/sdk/data"
```

Common embedded Rails profile:

```ruby
require "igniter"
require "igniter/plugins/rails"
```

Choose this when:

- contracts are called directly from Rails, jobs, scripts, or services
- you want compile-time validation and lazy execution without hosting
- HTTP, stack scaffolding, and cluster behavior are not needed

Rails note:

- `require "igniter/plugins/rails"` keeps you in embedded mode
- it adds Rails adapters, not the app/server/cluster runtime layers
- if you later need app hosting or cluster behavior, require those layers explicitly

## 2. App / Server

Use this when Igniter becomes the runtime shape of a standalone app.

Load:

```ruby
require "igniter/app"
```

Add packs only when needed:

```ruby
require "igniter/agents"
require "igniter/ai"
require "igniter/sdk/channels"
require "igniter/plugins/rails"
```

The Rails plugin remains an integration surface here too; it does not replace
`igniter/app` or `igniter/server`.

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
| Explicit legacy kernel lane | `require "igniter/legacy"` |
| Actor runtime and built-in agents | `require "igniter/agent"` or `require "igniter/agents"` |
| Extensions | `require "igniter/extensions/<feature>"` |
| SDK pack | `require "igniter/sdk/<pack>"`, `require "igniter/ai"`, or `require "igniter/agents"` |
| App runtime/profile | `require "igniter/app"` |
| Stack coordination | `require "igniter/stack"` |
| Cluster runtime | `require "igniter/cluster"` |
| Rails integration | `require "igniter/plugins/rails"` |

`require "igniter/core"` still works as a compatibility alias, but it should no
longer be the recommended onboarding path.

## See Also

- [Getting Started](./getting-started.md)
- [Configuration](./configuration.md)
- [App](./app.md)
- [Cluster](./cluster.md)
