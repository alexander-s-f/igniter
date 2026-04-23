# Application Target Plan

This note defines the target direction for a contracts-native `Application`
layer.

It should be read together with:

- [Post-Core Target Plan](./post-core-target-plan.md)
- [Igniter Contracts Spec](./igniter-contracts-spec.md)
- [Current: App Structure](../current/app-structure.md)

The central design rule is:

- do not ask "how do we preserve the old `Igniter::App`?"
- ask "what application runtime should exist if legacy/core did not exist?"

## Problem Statement

The current `Igniter::App` accumulated several responsibilities into one layer:

- application identity and profile
- code loading
- host adapter selection
- scheduler selection
- contract registration
- service registration
- diagnostics contribution
- stack mounting
- scaffolding assumptions
- orchestration/evolution/credential surfaces

That made sense as a growing implementation, but it is now too much to serve as
the target model.

The contracts-first architecture needs a cleaner split.

## Target Thesis

`Application` should become a contracts-native host/profile layer.

That means:

- `igniter-contracts` owns executable graph semantics
- `igniter-extensions` owns packs and operational/tooling/domain behavior
- `igniter-app` owns local application assembly and runtime hosting

In other words:

- `Application` is not the embedded kernel
- `Application` is not the distributed runtime
- `Application` is the local host that assembles contracts, packs, services,
  loaders, schedulers, and adapters into a coherent runtime profile

## Non-Goals

- do not preserve the current giant `Igniter::App` API just because it exists
- do not make `Application` mutate global ambient runtime state by default
- do not make `Application` depend on cluster semantics
- do not make stacks the primary abstraction for basic app runtime
- do not embed scaffolding/generator concerns into the minimal runtime model

## Core Design Questions

The new `Application` model must answer:

1. What is the minimal object that represents an application runtime profile?
2. How are contracts and packs installed into that profile?
3. How are host adapters, loaders, schedulers, and services attached?
4. What is boot lifecycle versus runtime lifecycle?
5. What belongs in `Application` versus `Stack` versus `Cluster`?

## Recommended Model

The recommended target shape is:

- `Application::Kernel`
  mutable assembly object for one app runtime
- `Application::Profile`
  frozen runtime-safe snapshot of that app assembly
- `Application::Environment`
  ergonomic runtime facade bound to a finalized profile
- `Application::HostAdapter`
  explicit hosting seam
- `Application::LoaderAdapter`
  explicit code-loading seam
- `Application::SchedulerAdapter`
  explicit scheduling seam
- `Application::ServiceRegistry`
  explicit app-local service/provider registry

Conceptually:

```ruby
kernel = Igniter::App::Kernel.new
kernel.install_contracts(profile: :baseline)
kernel.install_pack(Igniter::Extensions::Contracts::DebugPack)
kernel.host(:app_host)
kernel.loader(:filesystem)
kernel.scheduler(:threaded)
kernel.provide(:notes_api, NotesAPI.new)
kernel.register("GreetContract", MyApp::GreetContract)

profile = kernel.finalize
app = Igniter::App::Environment.new(profile)
app.boot
```

This mirrors the `Assembly` / `Execution` split already established in
`igniter-contracts`.

## Recommended Splits

### 1. Assembly vs Runtime

Current `App` code should be split into:

- assembly concerns
  registration, configuration, pack selection, services, adapters
- runtime concerns
  booting, loading code, scheduling jobs, host serving, diagnostics snapshots

This should reduce the amount of class-level mutable state and make app
profiles more comparable and testable.

### 2. App vs Stack

`Application` should be the leaf unit.

`Stack` should be optional coordination over multiple applications.

Rules:

- a single app should be bootable without stack orchestration
- stack should compose apps, not redefine app runtime semantics
- cross-app access should stay explicit through service/interface contracts

### 3. App vs Cluster

`Application` should remain local-first.

Cluster-specific concerns should not leak downward:

- remote routing
- replication
- consensus
- network topology
- ownership and distributed coordination

`Cluster` may host or coordinate applications, but `Application` should not
assume cluster presence in its core model.

## Keep / Rebuild / Drop

### Keep

These ideas still look strong:

- explicit host seam
- explicit loader seam
- explicit scheduler seam
- explicit service exposure (`provide`)
- explicit contract registration
- app-local diagnostics contributors
- portable app structure

### Rebuild

These should likely be redesigned rather than preserved as-is:

- giant class-level `Igniter::App` configuration surface
- implicit boot/load side effects
- mixed runtime + scaffold ownership
- stack-centric assumptions in the basic app model
- app runtime globals that mutate through subclass state

### Drop Or Demote

These should not shape the target model:

- compatibility-driven API preservation for its own sake
- hidden global registries as the primary architecture
- old "app as a big umbrella over everything" semantics
- forcing users to adopt stack orchestration for simple local app runtime

## First-Class Seams

The target app model should expose these seams explicitly:

- contracts profile
- extensions/packs
- service providers
- host adapter
- loader adapter
- scheduler adapter
- diagnostics contributors
- app-local interfaces exposed to sibling apps or upper layers

Each seam should be:

- host-owned
- explicit
- testable in isolation
- representable in a finalized profile snapshot

## Proposed Public Surface

The public API should probably trend toward:

```ruby
module Igniter
  module App
    def self.build_kernel(*packs); end
    def self.build_profile(*packs); end
    def self.with(*packs); end
  end
end
```

Then a more explicit form:

```ruby
kernel = Igniter::App::Kernel.new
kernel.host(:app_host)
kernel.loader(:filesystem)
kernel.scheduler(:threaded)
kernel.install_pack(MyApp::ObservabilityPack)
kernel.register("ContractName", MyContract)
kernel.provide(:notes_api, NotesAPI.new)
profile = kernel.finalize
```

This would align `Application` ergonomics with the contracts environment model
instead of preserving old subclass-mutation semantics as the only path.

## Diagnostics Direction

Application diagnostics should be rebuilt as contracts-native reporting over the
app profile/runtime state.

That means:

- app diagnostics should enrich contracts diagnostics, not replace them
- loader/scheduler/host diagnostics should be contributor-based
- app runtime snapshots should be serializable and stable for tooling
- `DebugPack` should be able to introspect application state through explicit
  seams rather than through special-case hacks

## Suggested Delivery Sequence

1. define `Application::Kernel` / `Profile` / `Environment`
2. move host/loader/scheduler/service seams onto that model
3. make one minimal app run end-to-end on the new model
4. then decide which current `Igniter::App` APIs become:
   - compatibility wrappers
   - migration helpers
   - deletions

## Success Criteria

The target is successful when:

- one local app can boot without legacy/core assumptions
- contracts profile and app profile are explicit and comparable
- host/loader/scheduler are adapters, not hard-coded behavior
- stack becomes optional coordination, not required baseline runtime
- old `Igniter::App` can eventually be deleted as architecture, not just
  renamed
