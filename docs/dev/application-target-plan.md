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
- `igniter-application` owns local application assembly and runtime hosting

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
- `Application::Manifest`
  explicit user application identity, root, env, layout, and registered surface
- `Application::Layout`
  canonical user application paths
- `Application::Blueprint`
  scaffold-free application structure intent before files are written
- `Application::BootPlan`
  explicit pre-execution boot lifecycle plan
- `Application::PlanExecutor`
  explicit execution seam for application lifecycle plans
- `Application::Config`
  immutable application-owned configuration snapshot
- `Application::Provider`
  explicit provider seam for runtime-owned service exports and boot hooks
- `Application::ProviderLifecycleReport`
  explicit provider resolution / boot / shutdown reporting
- `Application::SeamLifecycleResult`
  explicit loader / scheduler / host lifecycle reporting
- `Application::ShutdownPlan`
  explicit pre-execution shutdown lifecycle plan
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
- mounted interaction surfaces should use generic mount registrations rather
  than pushing web, cluster, or agent semantics into the application core
- composition of larger units should prefer explicit app/subgraph invocation
  here rather than pushing hidden child-runtime semantics back into
  `igniter-contracts`

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
- config
- providers
- service providers
- host adapter
- loader adapter
- scheduler adapter
- diagnostics contributors
- app-local interfaces exposed to sibling apps or upper layers
- session store / durable local session snapshots
- explicit provider lifecycle reports
- explicit host/loader/scheduler lifecycle reports
- explicit boot/shutdown plans before runtime mutation begins
- explicit plan execution seam instead of ad-hoc boot/shutdown orchestration

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
- provider boot and shutdown should be explicit lifecycle phases, not hidden
  lazy side effects of service resolution
- loader, scheduler, and host activation should also be explicit runtime
  lifecycle phases with structured report values
- application boot and shutdown should also be expressible as frozen plan
  objects before execution, so hosts and tooling can inspect intended actions
  before mutating runtime state

## Remote And Mesh Direction

The current application target should stay open for richer cluster and
mesh-specific evolution.

That means:

- application may expose transport-ready invoker seams
- cluster may specialize those seams into routing, placement, ownership, and
  failover execution
- future mesh-specific layers may add membership, peer protocol, trust,
  discovery, or multi-hop behavior above application without changing the
  contracts DSL or local application lifecycle

## Suggested Delivery Sequence

1. define `Application::Kernel` / `Profile` / `Environment`
2. move host/loader/scheduler/service seams onto that model
3. make one minimal app run end-to-end on the new model
4. then decide which current `Igniter::App` APIs become:
   - compatibility wrappers
   - migration helpers
   - deletions

## Prototype Status

A first clean-slate prototype now exists in `packages/igniter-application`:

- `Igniter::Application.build_kernel`
- `Igniter::Application.build_profile`
- `Igniter::Application.with`
- `Igniter::Application::Kernel`
- `Igniter::Application::Profile`
- `Igniter::Application::Environment`
- `Igniter::Application::Snapshot`
- `Igniter::Application::BootReport`

This is intentionally small, but it already establishes the target direction:

- contracts-native app assembly
- immutable config snapshots
- provider-driven service exports
- explicit boot and shutdown plans
- explicit lifecycle plan execution reports
- local durable session store for compose and collection invocations
- transport-ready compose and collection invokers for upper layers
- explicit application manifest and layout shape for user app structure
- scaffold-free application blueprints for planning app shape before writing
  files
- explicit application structure plans for inspecting and materializing missing
  layout paths without reintroducing legacy generator semantics
- named layout profiles and active groups for portable app capsules
- capsule export/import metadata for declaring portable app boundaries and
  host/sibling requirements
- layout-aware application load reports during boot

Current boundary rule:

- `Application` owns local runtime lifecycle and local session durability
- `Cluster` owns routing, placement, membership, incidents, remediation, and
  distributed diagnostics
- frozen profile snapshots
- explicit boot/runtime lifecycle and boot phases
- structured application snapshots for tooling/debug surfaces

The next concrete contracts-native runtime seam should be:

- application-owned session durability for host-side `compose` / `collection`
  workflows
- local-first `session_store` seam in `Application::Kernel` / `Profile`
- application environment helpers that execute contracts-native
  `ComposePack` / `CollectionPack` flows and persist session snapshots without
  pushing that durability concern back into the contracts kernel
- application-owned `compose_invoker` / `collection_invoker` adapters so
  contracts DSL can opt into durable application sessions through `via:`
- transport-ready `remote_compose_invoker` / `remote_collection_invoker`
  adapters that wrap the same session seam in explicit request/response
  envelopes, without turning `Application` itself into the distributed runtime
- future remote/distributed continuation owned by application/cluster adapters,
  not by the contracts baseline

`packages/igniter-app` should now be treated as the frozen legacy/reference
runtime package while the new model grows in `packages/igniter-application`.

## Success Criteria

The target is successful when:

- one local app can boot without legacy/core assumptions
- contracts profile and app profile are explicit and comparable
- host/loader/scheduler are adapters, not hard-coded behavior
- stack becomes optional coordination, not required baseline runtime
- old `Igniter::App` can eventually be deleted as architecture, not just
  renamed
