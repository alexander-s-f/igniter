# Embed Target Plan

This note defines the target role of `Embed` in the post-core architecture.

It should be read together with:

- [Post-Core Target Plan](./post-core-target-plan.md)
- [Igniter Contracts Spec](./igniter-contracts-spec.md)
- [Application Target Plan](./application-target-plan.md)

The key rule is simple:

- `Embed` is not an optional side mode
- `Embed` is the foundation of the new architecture

`Application` and `Cluster` should grow on top of it, not replace it.

## Problem Statement

The old architecture often blurred these concerns together:

- embedded contracts/runtime semantics
- application hosting/profile semantics
- distributed/cluster semantics

That blur made it too easy for the embedded kernel to absorb behavior that
really belonged to higher layers.

The post-core architecture needs a firmer base.

## Target Thesis

`Embed` should be the canonical contracts-first operating mode.

That means:

- `igniter-contracts` defines the executable graph kernel
- `igniter-extensions` defines optional packs over that kernel
- embedded use should work without app hosting, stack orchestration, or
  distributed runtime

If something does not make sense in embedded usage, it probably does not belong
in the embedded kernel.

## What Embed Is

Embed means:

- a host app, script, job, worker, or service process uses Igniter as an
  internal executable graph runtime
- contracts are compiled and executed locally
- packs are installed explicitly
- there is no required application host layer
- there is no required stack layer
- there is no required cluster layer

Typical embedded hosts:

- Rails applications
- background jobs
- CLI commands
- scripts
- internal service runtimes
- local automation/tooling flows

## What Embed Is Not

Embed is not:

- application boot lifecycle
- scheduler orchestration
- host adapter orchestration
- server/container runtime
- cross-app composition
- network routing
- consensus / replication / distributed control planes

Those belong to higher layers.

## Canonical Package Story

The target embedded package story should be:

- `igniter-contracts`
  canonical embedded kernel
- `igniter-extensions`
  optional packs for embedded/runtime/diagnostics/tooling/domain behavior

In this model:

- `igniter-app` is not required for embedded use
- `igniter-cluster` is not required for embedded use
- `igniter-legacy` is not required for embedded use

## Canonical Entry Point Story

The target embedded entrypoint story should converge on:

```ruby
require "igniter/contracts"
require "igniter/extensions/contracts"
```

or package-level convenience wrappers built on the same model.

The important part is not the exact spelling, but the architecture:

- explicit contracts kernel
- explicit packs
- explicit environment/profile

The root `require "igniter"` may remain as an umbrella convenience path during
transition, but it should not hide the real architecture.

## Authoring Surface

`igniter-contracts` should expose two valid, equal authoring forms before any
host layer is involved:

```ruby
compiled = Igniter::Contracts.compile do
  input :amount
  output :amount
end
```

and:

```ruby
class PriceContract < Igniter::Contract
  define do
    input :order_total, type: :numeric
    input :country, type: :string

    compute :gross_total, depends_on: %i[order_total country] do |order_total:, country:|
      order_total * (country == "UA" ? 1.2 : 1.0)
    end

    output :gross_total
  end
end
```

The block compile form is the low-level kernel API. The class form is the
human-facing authoring API for app code, agents, examples, Rails projects, and
future `Application` usage.

`Embed` must consume this class DSL; it must not own or redefine it. Its job is
host-local configuration, registry/discovery, compiled graph cache, reload
integration, and named execution around contracts that remain valid without
Embed.

## Embedded Runtime Model

The embedded model should center on:

- contracts kernel
- finalized profile
- compiled graph / reports
- runtime execution
- diagnostics / tooling hooks

A minimal shape looks like:

```ruby
environment = Igniter::Contracts.with(
  Igniter::Extensions::Contracts::DebugPack
)

compiled = environment.compile do
  input :name

  compute :message, depends_on: [:name] do |name:|
    "hello #{name}"
  end

  output :message
end

result = environment.execute(compiled, inputs: { name: "Alex" })
```

This is the baseline the upper layers must respect.

## Design Rules

### 1. Embed Owns Graph Semantics

The embedded layer owns:

- DSL
- graph model
- compile/validation pipeline
- local execution/runtime semantics
- structured reports and diagnostics hooks

Higher layers must not silently redefine these semantics.

### 2. Packs Must Stay Explicit

Embedded behavior should be assembled explicitly through packs and profiles.

Do not return to:

- hidden ambient global extension state
- implicit runtime patching
- app/cluster behavior leaking into the embedded kernel by default

### 3. Embed Must Be Host-Agnostic

The embedded kernel should not assume:

- Rails
- an application host
- a stack
- a server
- a scheduler
- a cluster

Hosts may use it, but it should not depend on them.

## Boundary To Application

`Application` begins when you need:

- boot lifecycle
- code loading
- host adapters
- scheduler adapters
- service registries
- local app diagnostics and operational runtime structure

So the rule is:

- embedded contracts runtime first
- application hosting second

`Application` should be a host/profile layer over embedded contracts, not a new
kernel.

## Boundary To Cluster

`Cluster` begins when execution becomes distributed and network-aware:

- remote execution
- routing
- capability admission
- replication
- consensus
- ownership / distributed coordination

So the rule is:

- embedded contracts runtime first
- application hosting optionally above that
- cluster distribution above that

## Keep / Rebuild / Drop

### Keep

- explicit contracts environments
- explicit packs
- compile/runtime reports
- diagnostics/tooling hooks
- embedded-first execution story

### Rebuild

- root umbrella ergonomics if they obscure the true contracts-first model
- old embedded APIs that were coupled to legacy global runtime mutation

### Drop

- any assumption that the embedded kernel should directly own app or cluster
  semantics
- compatibility-first embedded surface design

## Operating Modes

The target architecture should be described as three operating modes:

1. `Embed`
   canonical contracts-first local runtime
2. `Application`
   local host/runtime profile over `Embed`
3. `Cluster`
   distributed runtime over `Embed` / `Application`

This ordering matters.

`Embed` is the foundation, not the smallest leftover mode.

## Success Criteria

This target is successful when:

- embedded usage is fully coherent without `Application` or `Cluster`
- `igniter-contracts` is clearly the canonical embedded kernel
- `igniter-extensions` provides the optional pack ecosystem around that kernel
- `Application` and `Cluster` can be described as higher layers over `Embed`
- future design discussions stop using legacy/core as the starting point
