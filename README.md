# Igniter

Igniter is a Ruby framework for building business logic as validated dependency graphs.

At the center is a small, strict idea:

- describe dependencies explicitly
- validate the graph before runtime
- resolve only what is needed
- keep the runtime observable

From there, Igniter scales by layers instead of by reinvention:

- **Embedded / Legacy kernel** for contracts, compilation, execution, diagnostics
- **App** for a single-node runtime/profile
- **Cluster** for capability-based distributed execution
- **SDK** for optional packs such as AI, channels, tools, and data

This README is an entrypoint, not the full reference. The reference now lives in
[`docs/`](./docs/README.md), organized into [`guide`](./docs/guide/README.md),
[`concepts`](./docs/concepts/README.md), [`current`](./docs/current/README.md),
and [`dev`](./docs/dev/README.md).

## Why Igniter

Igniter is useful when your domain logic wants more structure than “service objects everywhere” but less ceremony than a full workflow engine.

You define a graph of inputs, computations, branches, collections, compositions, and outputs. Igniter compiles that graph, validates it, and gives you a runtime that is lazy, inspectable, and capable of growing from embedded usage to app hosting and then to a cluster.

## A Tiny Example

```ruby
require "igniter"

class PriceContract < Igniter::Contract
  define do
    input :order_total, type: :numeric
    input :country, type: :string

    compute :vat_rate, depends_on: [:country] do |country:|
      country == "UA" ? 0.2 : 0.0
    end

    compute :gross_total, depends_on: %i[order_total vat_rate] do |order_total:, vat_rate:|
      order_total * (1 + vat_rate)
    end

    output :gross_total
  end
end

contract = PriceContract.new(order_total: 100, country: "UA")
contract.result.gross_total
# => 120.0
```

## One Real Example

Imagine a post-call analysis pipeline for a call center.

The business task is simple to describe:

- take a recording
- transcribe it
- extract structured facts
- score the call
- prepare CRM updates and supervisor follow-up

In Igniter, that stays one explicit graph:

```ruby
require "igniter/cluster"

class PostCallAnalysisContract < Igniter::Contract
  define do
    input :call_id, type: :string
    input :audio_url, type: :string
    input :recorded_at, type: :string

    remote :transcript,
           contract: "TranscribeCall",
           query: { all_of: [:audio_transcription], tags: [:gpu] },
           inputs: { audio_url: :audio_url }

    remote :analysis,
           contract: "AnalyzeCall",
           query: { all_of: [:llm_inference] },
           inputs: {
             call_id: :call_id,
             transcript: :transcript,
             recorded_at: :recorded_at
           }

    compute :crm_patch, depends_on: [:analysis] do |analysis:|
      {
        disposition: analysis[:disposition],
        sentiment: analysis[:sentiment],
        next_action: analysis[:next_action],
        escalation_required: analysis[:escalation_required]
      }
    end

    output :analysis
    output :crm_patch
  end
end
```

Why this is interesting:

- the domain flow is still one contract, not a pile of queue handlers
- transcription and analysis can land on different nodes with different capabilities
- the cluster routes by capabilities, not by hard-coded machine roles
- if one matching node disappears, the network can select another suitable peer without changing the contract

That is the general Igniter idea: keep the business graph stable, let the runtime grow from local execution to a capability-driven cluster.

## The Levels

### 1. Embedded Kernel

Start here if you want the embedded kernel:

- contract DSL
- compiler and graph validation
- lazy runtime and invalidation
- diagnostics, events, introspection

Preferred loading lane:

- `require "igniter"` for the quiet embedded/default path
- `require "igniter/legacy"` only when you want to be explicit about the
  legacy implementation lane during migration

Deprecated compatibility alias:

- `require "igniter/core"` still works, but it is now a warning alias for the
  legacy/reference implementation and should not be the default recommendation

Read:

- [`docs/guide/core.md`](./docs/guide/core.md)

### 2. App

Use this when you want Igniter to be the runtime shape of an application:

- app profile
- host/loader/scheduler seams
- stack-style project layout
- app diagnostics and evolution/governance layers

Read:

- [`docs/guide/app.md`](./docs/guide/app.md)

### 3. Cluster

Use this when execution stops being single-node:

- mesh and gossip
- capability-based routing
- replication and distributed coordination
- resilience and decentralized runtime concerns

Read:

- [`docs/guide/cluster.md`](./docs/guide/cluster.md)

### 4. SDK

Use SDK packs when the kernel needs optional capabilities:

- AI
- channels
- tools
- skills
- data and app-facing capability packs

Read:

- [`docs/guide/sdk.md`](./docs/guide/sdk.md)

## Suggested Reading Paths

If you are new to Igniter:

1. Read [`docs/guide/`](./docs/guide/README.md)
2. Read [`docs/concepts/`](./docs/concepts/README.md)
3. Run one or two scripts from [`examples/README.md`](./examples/README.md)
   If you are specifically evaluating the new contracts migration path, start at the
   `Contracts Migration Track` section in [`examples/README.md`](./examples/README.md).

If you want to work on Igniter itself:

1. Read [`docs/dev/`](./docs/dev/README.md)
2. Read [`docs/dev/architecture-index.md`](./docs/dev/architecture-index.md)
3. Then move to the relevant package or layer index

If you want the standard app shape:

1. Read [`docs/guide/`](./docs/guide/README.md)
2. Read [`docs/guide/app.md`](./docs/guide/app.md)
3. Read [`docs/guide/cli.md`](./docs/guide/cli.md)
4. Explore [`examples/companion/README.md`](./examples/companion/README.md)

If you want distributed ideas:

1. Read [`docs/guide/`](./docs/guide/README.md)
2. Read [`docs/guide/cluster.md`](./docs/guide/cluster.md)
3. Run cluster-oriented scripts from [`examples/README.md`](./examples/README.md)

If you are iterating on ideas locally:

- keep public learning material in [`examples/`](./examples/README.md)
- keep local-first experiments in [`playgrounds/`](./playgrounds/README.md)

## Documentation Layout

- [`docs/guide/`](./docs/guide/README.md) — user-facing docs: getting started, API, how-tos, configuration
- [`docs/concepts/`](./docs/concepts/README.md) — durable mental models and patterns
- [`docs/current/`](./docs/current/README.md) — current-state notes and near-term direction
- [`docs/dev/`](./docs/dev/README.md) — internal docs: architecture, package boundaries, migration plans, backlog
- [`packages/*/README.md`](./packages/igniter-core/README.md) — package-local quick reference owned by each gem
- [`docs/`](./docs/README.md) — top-level docs portal that routes between sections

## Legacy Note

`igniter-core` now exists as a legacy/reference implementation during the
retirement track. Prefer:

- `require "igniter"` for embedded usage
- `require "igniter/legacy"` only when you intentionally want the explicit
  compatibility lane
- `require "igniter-contracts"` and contracts-facing packs for the migration
  path

Treat `require "igniter/core"` as a deprecated compatibility alias rather than
the canonical onboarding path.

If you want to scaffold a new stack quickly:

```bash
bin/igniter-stack new my_app
bin/igniter-stack new my_hub --profile dashboard
bin/igniter-stack new mesh_lab --profile cluster
bin/igniter-stack new playgrounds/home-lab --profile playground
```

## Installation

```ruby
gem "igniter"
```

## Public Entry Points

| Need | Require |
|------|---------|
| Core contracts/runtime | `require "igniter"` |
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
