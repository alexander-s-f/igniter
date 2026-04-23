# Igniter

Igniter is being rebuilt around a contracts-native package graph:

- `igniter-contracts` — canonical embedded kernel
- `igniter-extensions` — packs, tooling, and domain behavior
- `igniter-application` — contracts-native app runtime
- `igniter-web` — contracts-first web runtime and authoring lane
- `igniter-cluster` — distributed runtime
- `igniter-mcp-adapter` — transport-facing MCP surface

The active repository surface is intentionally limited to those packages. Older
legacy-root layers are no longer part of the current framework story and are
being recreated step by step instead of being carried forward.

## Root Facade

`require "igniter"` is now a thin convenience facade over the current packages.
It exposes:

- `Igniter::Contracts`
- `Igniter::Application`
- delegation helpers like `Igniter.with`, `Igniter.compile`, and `Igniter.application`

Archived legacy entrypoints such as `igniter/contract`, `igniter/runtime`, and
`igniter/diagnostics` are no longer active root APIs.

## Small Example

```ruby
require "igniter"

environment = Igniter.with

result = environment.run(inputs: { order_total: 100, country: "UA" }) do
  input :order_total
  input :country

  compute :vat_rate, depends_on: [:country] do |country:|
    country == "UA" ? 0.2 : 0.0
  end

  compute :gross_total, depends_on: %i[order_total vat_rate] do |order_total:, vat_rate:|
    order_total * (1 + vat_rate)
  end

  output :gross_total
end

result.output(:gross_total)
# => 120.0
```

## Packages

### `igniter-contracts`

Use this for:

- DSL authoring
- graph compilation
- execution/runtime
- diagnostics
- baseline effect and executor seams

### `igniter-extensions`

Use this for:

- lowered DSL packs such as `lookup`, `project`, and aggregates
- operational packs such as journaling and execution reporting
- debug, provenance, reactive, invariant, differential, and MCP tooling layers

### `igniter-application`

Use this for:

- contracts-native local hosting
- providers, services, contracts, and boot flow
- application profiles and embedded host runtime

### `igniter-web`

Use this for:

- contracts-first web ingress and transport surfaces
- higher-level web application authoring DSL
- streams, dashboards, chats, wizards, and operator-facing UI workflows
- optional record-style persistence facade

### `igniter-mcp-adapter`

Use this for:

- MCP tool catalog exposure
- tool invocation wrappers
- JSON-RPC host and server surfaces

## Examples And Docs

- Runnable examples: [examples/README.md](/Users/alex/dev/projects/igniter/examples/README.md)
- Internal design docs: [docs/dev/README.md](/Users/alex/dev/projects/igniter/docs/dev/README.md)
- Package docs:
  - [packages/igniter-contracts/README.md](/Users/alex/dev/projects/igniter/packages/igniter-contracts/README.md)
  - [packages/igniter-extensions/README.md](/Users/alex/dev/projects/igniter/packages/igniter-extensions/README.md)
  - [packages/igniter-application/README.md](/Users/alex/dev/projects/igniter/packages/igniter-application/README.md)
  - [packages/igniter-web/README.md](/Users/alex/dev/projects/igniter/packages/igniter-web/README.md)
  - [packages/igniter-cluster/README.md](/Users/alex/dev/projects/igniter/packages/igniter-cluster/README.md)
  - [packages/igniter-mcp-adapter/README.md](/Users/alex/dev/projects/igniter/packages/igniter-mcp-adapter/README.md)
| Explicit legacy kernel lane | `require "igniter/legacy"` |
| Embedded contracts kernel | `require "igniter/contracts"` or `require "igniter-contracts"` |
| Actor runtime and built-in agents | `require "igniter/agent"` or `require "igniter/agents"` |
| SDK registry | `require "igniter/sdk"` |
| App runtime/profile | `require "igniter/app"` |
| Cluster runtime | `require "igniter/cluster"` |

`igniter/core` remains available only as a deprecated compatibility alias during
the retirement track and now emits a legacy notice on public runtime
entrypoints by default.

The fuller map lives in [`docs/guide/README.md`](./docs/guide/README.md).

## Repository Landmarks

- [`docs/`](./docs/README.md) — structured documentation portal
- [`docs/guide/`](./docs/guide/README.md) — user-facing docs
- [`docs/dev/`](./docs/dev/README.md) — contributor-facing docs
- [`examples/`](./examples/README.md) — public runnable examples
- [`examples/companion/`](./examples/companion/README.md) — canonical stack-style demo
- [`playgrounds/`](./playgrounds/README.md) — local-first experiments such as home-lab work

## Status

Igniter is intentionally being shaped as layered infrastructure:

- keep `core` small and strict
- let `app` and `cluster` grow above it
- move reusable optional capabilities into `sdk`
- keep user docs in `docs/guide/`
- keep internal architecture and planning docs in `docs/dev/`
- keep package-local quick reference next to each package README

For the full documentation map, start at [`docs/README.md`](./docs/README.md).
