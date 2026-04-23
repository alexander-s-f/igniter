# Canonical Runtime Shapes

This note locks the intended shape of the new Igniter runtime family.

It exists to answer four questions directly:

1. What is required for the canonical contracts DSL?
2. What is required for a contracts-native `Application`?
3. What is required for a contracts-native `Cluster`?
4. What from the old model should be replaced instead of ported?

Read this together with:

- [Post-Core Target Plan](./post-core-target-plan.md)
- [Igniter Contracts Spec](./igniter-contracts-spec.md)
- [Application Target Plan](./application-target-plan.md)
- [Cluster Target Plan](./cluster-target-plan.md)

## Canonical Package Graph

The target package graph should now be treated as:

- `igniter-contracts`
  canonical embedded kernel
- `igniter-extensions`
  packs, tooling, operational behavior, and domain behavior over the kernel
- `igniter-application`
  contracts-native local runtime host
- `igniter-cluster`
  contracts-native distributed runtime
- `legacy`
  reference-only implementation material until deletion

Everything else should be understood as an adapter package, tooling package, or
integration package, not as a fifth runtime pillar.

That includes transport and protocol surfaces such as MCP or HTTP hosting.

Design rule:

- do not treat `server` as a primary architectural layer anymore
- treat transport as an adapter seam owned by `Application`, `Cluster`, or a
  dedicated adapter package

## 1. Canonical Contracts DSL

The contracts DSL must become smaller, sharper, and more semantic.

The canonical embedded DSL should be the minimum language required to describe
deterministic executable work plus explicit effect boundaries.

## Kernel Baseline

The baseline contracts kernel should own:

- graph authoring
- graph compilation
- graph validation
- finalized profile snapshots
- local execution semantics
- explicit effect/executor seams
- diagnostics/reporting seams

The canonical baseline DSL should converge on:

- `input`
- `const`
- `compute`
- `effect`
- `output`

These are the semantic primitives that justify living in the kernel itself:

- `input`
  declares external data the graph depends on
- `const`
  declares graph-owned stable values
- `compute`
  declares pure or capability-scoped derivation
- `effect`
  declares an explicit side-effect boundary through a named effect contract
- `output`
  declares externally observed results

## Pack DSL

Everything more specialized should be built as a pack or compile down to the
kernel primitives.

That includes shapes such as:

- `lookup`
- `project`
- `map`
- `aggregate`
- `branch`
- `collection`
- `compose`
- `guard`
- `expose`
- `export`
- domain-specific node families

Rule:

- if a DSL feature is mostly ergonomics or domain vocabulary, it belongs in
  packs
- if a DSL feature adds a new semantic execution model, it must justify its
  existence as a true kernel primitive

## Baseline vs Extension Decision Table

This is the concrete package split we should use going forward.

### Baseline Now

These belong in `igniter-contracts` baseline immediately:

- `input`
  fundamental external data boundary
- `compute`
  fundamental derivation primitive
- `effect`
  fundamental explicit side-effect boundary
- `output`
  fundamental observed-result boundary
- `const`
  fundamental graph-owned stable value
- kernel/profile/pack machinery
  this is the core assembly model itself
- compiler/normalizer/validator/runtime spine
  this is the executable kernel
- effect registry seam
  contracts must own named effect adapters even if higher layers install them
- executor registry seam
  contracts must own execution mode selection and validation
- minimal diagnostics/report infrastructure
  execution and compilation need contracts-owned reporting hooks

## Canonical Effect Node

`effect` in baseline should stay one explicit graph primitive with one explicit
meaning:

- resolve named dependencies from state
- build a payload deterministically from those dependencies
- invoke a named effect adapter through the finalized profile
- write the adapter result back into graph state under the effect node name

Recommended baseline shape:

```ruby
effect :audit_entry, using: :journal, depends_on: [:total] do |total:|
  { total: total }
end
```

Recommended rules:

- `effect` is for explicit side-effect boundaries, not for general orchestration
- `using:` names a registered effect adapter from the finalized profile
- payload construction should use the same dependency model as `compute`
- the adapter return value becomes the node value in state
- downstream nodes may depend on that value explicitly if needed

Recommended baseline constraints:

- require `using:`
- require a payload callable or block
- validate that the named effect exists in the finalized profile
- validate dependencies the same way `compute` does
- keep retries, compensations, batching, fan-out, and policy layers out of the
  baseline primitive

What should stay out of baseline `effect`:

- saga semantics
- retry orchestration
- journaling bundles
- reactive subscriptions
- transport or remote dispatch policy

Those belong in packs or upper runtime layers.

### Extensions

These should live in `igniter-extensions` packs rather than baseline:

- `lookup`
  ergonomic data access node, not a kernel primitive
- `project`
  projection sugar over data extraction; useful, but not baseline-defining
- `count`, `sum`, `avg`
  aggregate/domain operators

Current direction for all of the above:

- keep them as extension-level DSL
- prefer lowering them into `compute` semantics instead of preserving dedicated
  kernel IR node kinds
- commerce DSL
  domain vocabulary
- invariants
  validation/testing layer over execution
- differential
  comparison/testing layer
- audit
  observability layer
- provenance
  explainability layer
- execution report
  richer operator-facing report layer
- debug
  developer bundle layer
- content addressing
  runtime optimization strategy, not base semantics
- capabilities
  policy and metadata interpretation layer over contracts
- journaled executors/effects
  operational instrumentation
- incremental
  alternate orchestration mode over compiled graphs
- dataflow
  stream/window/session orchestration
- reactive
  event/reaction orchestration
- saga
  compensation/orchestration layer
- creator
  authoring tooling
- MCP
  external tooling adapter

### Not Canonical Baseline

These should not remain part of the canonical baseline story unless we later
prove they are true semantic primitives:

- `branch`
- `collection`
- `composition`

`project` also should not remain a dedicated kernel node kind in the long-term
target architecture.

Recommended direction:

- keep `project` as extension-level DSL
- compile it down to `compute` semantics rather than preserving a dedicated
  kernel IR node forever
- keep `ProjectPack` as an ergonomic extension-level DSL pack, not as a kernel
  semantic expansion

Current rule:

- if runtime support is not real, they must not be baseline
- if they are useful only as ergonomic graph sugar, move them to packs
- if they need a richer execution model, redesign them intentionally instead of
  inheriting the old node taxonomy

## Default Extension Story

We should distinguish three things clearly:

- baseline kernel
  the smallest contracts-native executable system
- recommended extensions preset
  the default ergonomic add-ons most users probably want
- optional specialist packs
  domain, orchestration, optimization, and tooling layers

That means a pack can be "default" without becoming "baseline".

Recommended direction:

- keep baseline minimal in `igniter-contracts`
- allow `igniter-extensions` to provide a recommended preset for day-to-day
  authoring
- do not promote a pack into baseline just because it is frequently installed

## IR Rule

The canonical contracts IR should stay smaller than the user-facing DSL.

That means:

- the public DSL may grow through packs
- the executable graph IR should stay compact and profile-validated
- sugar should usually compile into a smaller semantic core

This is the main way to avoid rebuilding the old giant node taxonomy.

## Immediate Corrections

The current rewrite already shows one important roughness:

- baseline currently exposes `composition`, `branch`, and `collection`
- baseline runtime still marks those as unsupported

That should not survive into the canonical model.

Rules:

- baseline must not advertise unsupported node kinds
- a keyword should exist only if compile + runtime semantics are real
- placeholder node families should live in packs or in draft authoring lanes,
  not in the canonical baseline

Another correction that is now part of the target:

- `const` belongs in baseline rather than in an optional novelty lane

## Compiler/Runtime Contract

The canonical contracts DSL also needs a stronger execution contract:

- compile only against finalized profiles
- embed profile fingerprint into compiled artifacts
- validate effect/executor contracts at profile-finalize time
- keep runtime execution profile-compatible and deterministic by default
- make diagnostics a first-class product of compilation and execution, not an
  afterthought

## What Must Stay Out Of Contracts

The canonical contracts DSL must not directly own:

- app boot lifecycle
- code loading conventions
- scheduler ownership
- HTTP or transport hosting
- cluster routing
- replication
- consensus
- mesh topology

Those are upper-layer concerns.

## 2. Contracts-Native Application

`Application` should be the local runtime host over contracts, not a second
kernel.

Its job is to assemble an app-owned runtime profile around finalized contracts
profiles and explicit packs.

## Minimal Application Model

The target object model should be:

- `Application::Kernel`
  mutable assembly surface
- `Application::Profile`
  frozen app runtime snapshot
- `Application::Environment`
  runtime facade over a finalized app profile
- `Application::Config`
  immutable app configuration snapshot
- `Application::Provider`
  provider seam for boot hooks and exported services

The application layer should own these seams explicitly:

- contracts profile installation
- application-local packs
- config
- providers
- services and interfaces
- contract registration/discovery
- loader adapter
- host adapter
- scheduler adapter
- diagnostics contributors
- boot lifecycle

## Application Boundary

`Application` begins when we need local runtime hosting concerns:

- loading app code
- assembling providers and services
- selecting a host adapter
- selecting a loader
- selecting a scheduler
- booting a coherent local runtime

`Application` is not the place to redefine graph semantics.

Rule:

- `Application` hosts contracts
- `Application` does not reinterpret contracts

## Server Is Not A Runtime Pillar

The old model made it too easy to think in terms of:

- core
- server
- app
- cluster

That should be replaced with:

- contracts
- application
- cluster
- adapters

If HTTP hosting exists, it should usually be one of:

- an application host adapter
- a cluster transport adapter
- a dedicated integration package

not the semantic center of the architecture.

## Application Success Criteria

The application model is correct when:

- one app can boot without stack orchestration
- the app profile is frozen and inspectable
- provider/service wiring is explicit
- host/loader/scheduler are replaceable seams
- contracts execution remains a lower-layer dependency, not a merged concern

## 3. Contracts-Native Cluster

`Cluster` should be the distributed runtime substrate over contracts and, when
useful, over application profiles.

It should own distributed concerns directly instead of smuggling them through
the kernel.

## Minimal Cluster Model

The cluster layer should converge on explicit subdomains:

- remote execution
- routing and admission
- ownership and placement
- topology and membership
- distributed diagnostics/explainability
- coordination where actually required

That implies a minimal object vocabulary such as:

- `ExecutionEnvelope`
  what distributed execution moves between peers
- `RouteRequest`
  what routing evaluates
- `RouteDecision`
  why a peer was selected or rejected
- `CapabilityManifest`
  what a peer or profile can actually do
- `AdmissionPolicy`
  what is allowed to run where
- `PlacementRecord`
  who currently owns an entity or workload
- `RemoteExecutor`
  transport-agnostic remote execution seam

The exact class names can change, but those responsibilities should not blur
together.

## Cluster Boundary

Cluster begins when work becomes network-aware:

- execution may run on another peer
- routing/admission must make decisions
- ownership may outlive a single process
- capacity and topology matter
- operators need explanations for placement behavior

Cluster should not own:

- basic local boot lifecycle
- code loading as a primary semantic concern
- application scaffolding
- kernel DSL semantics

## Capability Rule

Capabilities should become a canonical input into cluster routing, not a loose
metadata side channel.

That means:

- contracts and packs should declare capability requirements explicitly
- application or cluster profiles should publish capability manifests
- routing and admission should reason over those manifests directly
- diagnostics should explain capability mismatches in routing terms

## Coordination Rule

Consensus should not be the default home for every distributed behavior.

Stronger rule:

- use strong coordination only where safety really requires it
- prefer explicit weaker models for routing, placement, and recovery where they
  are sufficient

That keeps `igniter-cluster` from turning back into a giant umbrella package.

## 4. Replace, Do Not Port

The old architecture contains ideas worth keeping, but several structural
patterns should be replaced outright.

## Replace These Patterns

- global mutable registries as the primary extension model
- class-level app configuration as ambient shared state
- stack-first assumptions in the basic application runtime
- server as a central semantic layer
- cluster as one wide package that mixes transport, routing, ownership,
  replication, and consensus
- placeholder DSL keywords without fully supported runtime semantics
- hidden boot/load side effects
- compatibility-driven public API preservation as a design goal

## Rebuild These Ideas In Better Form

- extension activation
  rebuild as pack installation into explicit kernels/profiles
- app composition
  rebuild as explicit providers, services, interfaces, and adapters
- transport hosting
  rebuild as adapter packages or explicit host seams
- distributed execution
  rebuild as explicit remote execution/routing/placement contracts
- diagnostics
  rebuild as profile-aware, execution-aware, and routing-aware reporting

## Keep These Ideas

These ideas still look worth preserving, but in new form:

- explicit contracts and graph compilation
- frozen runtime profiles
- capability-aware execution
- effect and executor seams
- explainability as a product feature, not just a debug helper
- embedded-first design before app and cluster layers

## Near-Term Delivery Order

The next implementation sequence should be:

1. tighten `igniter-contracts` around the canonical baseline DSL
2. remove unsupported baseline node kinds from the canonical kernel story
3. design the canonical baseline `effect` node instead of shipping a partial
   keyword too early
4. finish `igniter-application` as the local runtime host
5. treat transport/server work as adapter work, not as a runtime pillar
6. start `igniter-cluster` from explicit distributed seams instead of porting
   the old umbrella

Success means deleting legacy becomes cleanup work, not architecture work.
