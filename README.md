# Igniter

Igniter is a Ruby framework for building business logic as validated dependency graphs.

At the center is a small, strict idea:

- describe dependencies explicitly
- validate the graph before runtime
- resolve only what is needed
- keep the runtime observable

From there, Igniter scales by layers instead of by reinvention:

- **Core** for contracts, compilation, execution, diagnostics
- **App** for a single-node runtime/profile
- **Cluster** for capability-based distributed execution
- **SDK** for optional packs such as AI, channels, tools, and data

This README is an entrypoint, not the full reference. The reference now lives in [`docs/`](./docs/README.md).

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

### 1. Core

Start here if you want the kernel:

- contract DSL
- compiler and graph validation
- lazy runtime and invalidation
- diagnostics, events, introspection

Read:

- [`docs/core/`](./docs/core/README.md)

### 2. App

Use this when you want Igniter to be the runtime shape of an application:

- app profile
- host/loader/scheduler seams
- stack-style project layout
- app diagnostics and evolution/governance layers

Read:

- [`docs/app/`](./docs/app/README.md)

### 3. Cluster

Use this when execution stops being single-node:

- mesh and gossip
- capability-based routing
- replication and distributed coordination
- resilience and decentralized runtime concerns

Read:

- [`docs/cluster/`](./docs/cluster/README.md)

### 4. SDK

Use SDK packs when the kernel needs optional capabilities:

- AI
- channels
- tools
- skills
- data and app-facing capability packs

Read:

- [`docs/sdk/`](./docs/sdk/README.md)

## Suggested Reading Paths

If you are new to Igniter:

1. Read [`docs/README.md`](./docs/README.md)
2. Read [`docs/general/`](./docs/general/README.md)
3. Read [`docs/core/`](./docs/core/README.md)
4. Run one or two scripts from [`examples/README.md`](./examples/README.md)

If you want the standard app shape:

1. Read [`docs/app/`](./docs/app/README.md)
2. Explore [`examples/companion/README.md`](./examples/companion/README.md)

If you want distributed ideas:

1. Read [`docs/cluster/`](./docs/cluster/README.md)
2. Run cluster-oriented scripts from [`examples/README.md`](./examples/README.md)

If you are iterating on ideas locally:

- keep public learning material in [`examples/`](./examples/README.md)
- keep local-first experiments in [`playgrounds/`](./playgrounds/README.md)

## Installation

```ruby
gem "igniter"
```

## Public Entry Points

| Need | Require |
|------|---------|
| Core contracts/runtime | `require "igniter"` |
| Actor/tool foundation | `require "igniter/core"` |
| SDK registry | `require "igniter/sdk"` |
| App runtime/profile | `require "igniter/app"` |
| Cluster runtime | `require "igniter/cluster"` |

The fuller map lives in [`docs/general/README.md`](./docs/general/README.md).

## Repository Landmarks

- [`docs/`](./docs/README.md) — structured documentation portal
- [`examples/`](./examples/README.md) — public runnable examples
- [`examples/companion/`](./examples/companion/README.md) — canonical stack-style demo
- [`playgrounds/`](./playgrounds/README.md) — local-first experiments such as home-lab work

## Status

Igniter is intentionally being shaped as layered infrastructure:

- keep `core` small and strict
- let `app` and `cluster` grow above it
- move reusable optional capabilities into `sdk`
- keep the top-level docs welcoming, and the reference material deeper in `docs/`

For the full documentation map, start at [`docs/README.md`](./docs/README.md).
