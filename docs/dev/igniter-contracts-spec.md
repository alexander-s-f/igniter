# Igniter Contracts Spec

This document defines the target architecture for `igniter-contracts`.

The point of the package is not just a new gem name. It is the chance to build
the embedded kernel as a clean composition root while `igniter-core` remains
available as the legacy implementation package during the transition.

## Goals

- make `igniter-contracts` the canonical embedded dependency for Rails and other
  host apps
- keep the contracts kernel loadable without app/server/cluster/frontend layers
- let upper layers extend the kernel through explicit registration seams
- compare behavior against the legacy `igniter-core` package while the rewrite
  is in progress
- design the extension pattern first, then grow functionality inside it

## Non-Goals

- do not preserve historical coupling just because it already exists
- do not let remote, hosted, or distributed behavior remain implicit in the
  embedded contracts package
- do not make `igniter-contracts` depend on `igniter/app`, `igniter/server`,
  `igniter/cluster`, `igniter-frontend`, or schema rendering packages
- do not make global mutation the primary architecture for extensions

## Composition Root Rule

`require "igniter/contracts"` should be assembled by the contracts package
itself.

- it should not route through `require "igniter/core"`
- it should not route through `require "igniter-core"`
- the package should explicitly choose which lower-level files make up the
  contracts kernel

That keeps the package boundary visible and lets us replace internals
incrementally instead of inheriting the entire historical umbrella.

## Research Synthesis

The recommended pattern here is not a single borrowed framework idea, but a
combination of a few proven extension models:

- `pluggy` contributes the strongest idea for explicit extension contracts:
  define host-owned hook specifications, validate implementations against them,
  and register them through a manager instead of ad-hoc monkeypatching.
- `dry-container` / `dry-system` contribute the container/provider lifecycle:
  explicit registration, deferred boot, and a clear distinction between a
  mutable assembly phase and a finalized runtime shape.
- Rails `Railtie` contributes phased initialization: extensions should attach
  during known lifecycle steps instead of mutating runtime behavior at random
  times.
- MLIR extensible dialects contribute the key structural idea: the core can be
  extensible at runtime, but the host still owns the dialect/kernel and the
  extension points.
- RuboCop's plugin API contributes an important packaging lesson: a public
  extension API is healthier than telling consumers to `require` arbitrary files
  and hope their side effects line up.

These references all point in the same direction:

- host-owned extension seams
- explicit registration
- phased finalization
- stable public plugin contracts
- minimal baseline kernel

## Boundary Rule

The contracts layer may expose extension seams, but it should not require upper
runtime layers.

Forbidden knowledge:

- app hosts
- HTTP/server boot
- cluster routing and trust
- frontend rendering packages
- framework plugins

Allowed concepts:

- contracts and DSL
- graph model
- compilation and validation
- local execution/runtime
- diagnostics/report assembly
- registries and extension seams

## Recommended Pattern

The primary architecture should be:

- `Kernel` or `Builder` for mutable assembly
- `Profile` for the finalized immutable runtime shape
- `Pack` for extension bundles installed into a kernel during assembly
- host-owned registries for phase-specific extension points

The important choice is that registration should happen against a kernel
instance, not against process-global mutable state.

Good:

```ruby
kernel = Igniter::Contracts::Kernel.new
kernel.install(Igniter::Contracts::BaselinePack)
kernel.install(Igniter::Machine::RemotePack)
profile = kernel.finalize
```

Convenience sugar may exist:

```ruby
Igniter::Contracts.install(Igniter::Machine::RemotePack)
```

but that should be a wrapper over a default kernel/profile, not the real source
of truth.

Why this is preferred over plain global `register`:

- avoids test bleed and load-order coupling
- allows multiple isolated profiles in one process
- lets compile and runtime share the same frozen capability snapshot
- makes behavior comparable across profiles
- keeps the public extension API explicit

## Layering Spec

The contracts package should become extensible by registration, not by hard
coding knowledge of every upper-layer concern.

Target seam categories:

- node kinds
- DSL keywords/builders
- compiler validators
- runtime planners/resolvers/handlers
- diagnostics contributors
- effect/executor adapters

Target rule:

- if a feature such as remote execution, agent routing, or hosted orchestration
  is not registered, `igniter-contracts` should not know how to do it
- higher layers should opt in by registering the pieces they own

That means the contracts package can define interfaces and registries for these
areas, but not the machine-specific implementations by default.

## Kernel / Profile Model

Recommended objects:

- `Igniter::Contracts::Kernel`
  Mutable assembly object used while installing packs and registering extension
  points.
- `Igniter::Contracts::Profile`
  Frozen, runtime-safe snapshot created from a kernel.
- `Igniter::Contracts::Pack`
  Extension bundle that installs related functionality into a kernel.

Suggested API direction:

```ruby
module Igniter
  module Contracts
    class Kernel
      attr_reader :nodes,
                  :dsl_keywords,
                  :validators,
                  :runtime_handlers,
                  :diagnostics,
                  :effects,
                  :executors

      def install(pack)
        pack.install_into(self)
        self
      end

      def finalize
        Profile.build_from(self)
      end
    end

    class Profile
      attr_reader :fingerprint

      def node_class(kind); end
      def dsl_keyword(name); end
      def validator_pipeline; end
      def runtime_handler(kind); end
    end
  end
end
```

The compile/runtime rule should be strict:

- compile against a finalized profile
- embed the profile fingerprint into the compiled graph
- runtime requires a compatible profile

This keeps extension registration from becoming implicit mutable ambient state.

## Registries

Registries should be phase-specific instead of one generic bucket.

Recommended registries:

- `nodes`
- `dsl_keywords`
- `validators`
- `normalizers`
- `runtime_handlers`
- `diagnostics_contributors`
- `effects`
- `executors`

Each registry should have a small explicit interface:

- `register`
- `fetch`
- `registered?`
- `entries`
- `freeze`

Registries should reject duplicate keys by default unless a seam explicitly
supports decoration or replacement.

## Pack Model

Packs are the preferred unit of extension.

Each pack should expose a `manifest` in addition to `install_into`.

The manifest is the pack's explicit capability declaration:

- which node kinds it owns
- which registry seams it contributes to
- which compile/runtime/diagnostics hooks it expects to be present after
  installation

That keeps capability validation host-owned instead of inferred entirely from
side effects.

Example:

```ruby
module Igniter
  module Machine
    module RemotePack
      module_function

      def manifest
        Igniter::Contracts::PackManifest.new(
          name: :remote,
          node_contracts: [Igniter::Contracts::PackManifest.node(:remote)],
          registry_contracts: [
            Igniter::Contracts::PackManifest.validator(:remote_shape),
            Igniter::Contracts::PackManifest.diagnostic(:remote_summary)
          ]
        )
      end

      def install_into(kernel)
        kernel.nodes.register(:remote, Igniter::Machine::RemoteNode)
        kernel.dsl_keywords.register(:remote, Igniter::Machine::DSL::RemoteKeyword)
        kernel.validators.register(:remote_shape, Igniter::Machine::Compiler::RemoteValidator)
        kernel.runtime_handlers.register(:remote, Igniter::Machine::Runtime::RemoteHandler)
        kernel.diagnostics_contributors.register(:remote_summary, Igniter::Machine::Diagnostics::RemoteContributor)
      end
    end
  end
end
```

Important rule:

- a pack should install a coherent slice across phases
- a feature like `remote` should not be half-registered

That favors pack-based registration over scattered one-off `register` calls
throughout the codebase.

## Baseline Contracts Profile

`igniter-contracts` should ship with one small baseline pack that is installed by
default.

That baseline should include only truly embedded concepts:

- `input`
- `compute`
- `composition`
- `branch`
- `collection`
- `output`
- local execution/runtime
- base diagnostics and errors

Candidates to move out of baseline:

- `remote`
- `agent`
- orchestration/session transport
- hosted routing
- cluster trust/ownership concerns

`await` should be reconsidered explicitly instead of assumed. If it implies
external orchestration or suspended hosted workflows, it belongs above the
baseline contracts profile.

## Registration Lifecycle

Registration should have phases.

Recommended lifecycle:

1. build kernel
2. install packs
3. finalize profile
4. compile graphs against profile
5. run graphs against the same profile family

Rules:

- packs install only before finalize
- finalized profiles are immutable
- late registration after finalize is an error
- compile and runtime should not silently see different registrations

This is closer to `dry-system` providers and Rails initialization than to
open-ended global patching.

## Hookspec Direction

Not every seam should be a loose registry of arbitrary objects. Some seams need
spec validation.

Recommended approach:

- use plain registries for simple keyed lookups such as node class by kind
- use hook specifications for richer callback-style extensibility

Likely hookspec-style seams:

- diagnostics contribution
- compile-time graph augmentation
- runtime event observation
- execution planning callbacks

In the current contracts kernel direction, the first concrete use of this idea
should be hook signature validation during `Kernel#finalize`.

That means:

- `validators` and `normalizers` must accept `operations:` and `profile:`
- `runtime_handlers` must accept `operation:`, `state:`, `outputs:`, `inputs:`,
  and `profile:`
- `diagnostics_contributors` must implement `augment(report:, result:, profile:)`
- `dsl_keywords` must accept `builder:` even if they also accept free-form args

This pushes extension failures into profile assembly instead of letting them
surface later as ad-hoc `ArgumentError` or `NoMethodError`.

This is where `pluggy` is especially relevant: the host defines the spec first,
and extension packs implement it.

## Error Model

Missing or incomplete extension installation should fail clearly.

Examples:

- unknown DSL keyword: required pack is not installed
- node kind registered without runtime handler: incomplete pack installation
- compiled graph profile mismatch at runtime: wrong runtime profile
- validator references unknown node kind: invalid extension registration
- registered hook has an incompatible callable signature: invalid hook
  implementation

Errors should name:

- missing keyword / node kind / seam
- expected pack when known
- current profile fingerprint

## Weak Coupling Rules

Weak coupling here means more than "no require".

It means:

- no baseline knowledge of upper-layer concepts
- extensions communicate through host-owned seams
- phase boundaries are explicit
- compile/runtime shape is profile-driven, not ambient-state-driven
- extension packages can be absent without distorting the contracts kernel

In practical terms:

- `igniter-contracts` may define the existence of a `runtime_handlers` registry
- it should not define `RemoteHandler` in the baseline package

## API Sketch

Illustrative direction:

```ruby
kernel = Igniter::Contracts::Kernel.new
kernel.install(Igniter::Contracts::BaselinePack)

if use_remote
  kernel.install(Igniter::Machine::RemotePack)
end

profile = kernel.finalize

compiled = Igniter::Contracts.compile(profile: profile) do
  input :amount
  compute :tax, depends_on: [:amount] do |amount:|
    amount * 0.2
  end
end

Igniter::Contracts::Runtime.execute(compiled, profile: profile, inputs: { amount: 10 })
```

Optional sugar:

```ruby
Igniter::Contracts.default_kernel.install(Igniter::Machine::RemotePack)
```

but the profile object should remain the real architectural center.

## Concrete Baseline API Draft

This section proposes the first concrete public API shape worth building.

The intent is:

- small enough to implement incrementally
- strong enough to enforce weak coupling
- explicit enough to support upper-layer packs without monkeypatching

### Top-Level Entry Surface

Suggested public module:

```ruby
module Igniter
  module Contracts
    class << self
      def build_kernel
        Kernel.new.install(BaselinePack)
      end

      def default_kernel
        @default_kernel ||= build_kernel
      end

      def default_profile
        @default_profile ||= default_kernel.finalize
      end

      def compile(profile: default_profile, &block)
        Compiler.compile(profile: profile, &block)
      end

      def execute(compiled_graph, inputs:, profile: default_profile, **options)
        Runtime.execute(compiled_graph, inputs: inputs, profile: profile, **options)
      end
    end
  end
end
```

Rules:

- `default_kernel` is convenience only
- first-class code should accept explicit profiles
- compile and execute should never silently invent different profiles

### Kernel

Suggested responsibilities:

- own mutable registries
- install packs
- enforce registration timing
- produce an immutable profile

Suggested shape:

```ruby
module Igniter
  module Contracts
    class Kernel
      attr_reader :nodes,
                  :dsl_keywords,
                  :validators,
                  :normalizers,
                  :runtime_handlers,
                  :diagnostics_contributors,
                  :effects,
                  :executors

      def initialize(
        nodes: Registry.new(name: :nodes),
        dsl_keywords: Registry.new(name: :dsl_keywords),
        validators: OrderedRegistry.new(name: :validators),
        normalizers: OrderedRegistry.new(name: :normalizers),
        runtime_handlers: Registry.new(name: :runtime_handlers),
        diagnostics_contributors: OrderedRegistry.new(name: :diagnostics_contributors),
        effects: Registry.new(name: :effects),
        executors: Registry.new(name: :executors)
      )
      end

      def install(pack)
        raise FrozenKernelError, "kernel already finalized" if finalized?

        resolved_pack = pack.respond_to?(:install_into) ? pack : pack.new
        resolved_pack.install_into(self)
        self
      end

      def finalize
        freeze_registries!
        @finalized = true
        Profile.build_from(self)
      end

      def finalized?
        !!@finalized
      end
    end
  end
end
```

Kernel invariants:

- packs may only install before finalization
- duplicate registration raises by default
- every registry is frozen before profile creation

### Profile

The profile is the compile/runtime contract.

Suggested responsibilities:

- expose frozen resolved registries
- provide fingerprinting
- answer capability lookups
- expose installed pack manifests
- validate compiled graph compatibility at runtime

Suggested shape:

```ruby
module Igniter
  module Contracts
    class Profile
      attr_reader :fingerprint

      def self.build_from(kernel)
        new(
          nodes: kernel.nodes.to_h.freeze,
          dsl_keywords: kernel.dsl_keywords.to_h.freeze,
          validators: kernel.validators.entries.freeze,
          normalizers: kernel.normalizers.entries.freeze,
          runtime_handlers: kernel.runtime_handlers.to_h.freeze,
          diagnostics_contributors: kernel.diagnostics_contributors.entries.freeze,
          effects: kernel.effects.to_h.freeze,
          executors: kernel.executors.to_h.freeze
        )
      end

      def node_class(kind)
        nodes.fetch(kind.to_sym)
      end

      def dsl_keyword(name)
        dsl_keywords.fetch(name.to_sym)
      end

      def runtime_handler(kind)
        runtime_handlers.fetch(kind.to_sym)
      end

      def supports_node_kind?(kind)
        nodes.key?(kind.to_sym)
      end

      def pack_manifest(name)
      end

      def declared_registry_keys(registry)
      end
    end
  end
end
```

Profile invariants:

- immutable after creation
- fingerprint changes when registrations change
- compile embeds the fingerprint
- runtime rejects mismatched fingerprints unless explicitly allowed

### Registry Types

One registry abstraction is probably not enough.

Recommended baseline:

- `Registry`
  Keyed single-value registry
- `OrderedRegistry`
  Ordered list registry for pipelines/contributors

Suggested shape:

```ruby
module Igniter
  module Contracts
    class Registry
      def initialize(name:)
        @name = name
        @entries = {}
        @frozen = false
      end

      def register(key, value)
        raise FrozenRegistryError, "#{@name} is frozen" if @frozen
        key = key.to_sym
        raise DuplicateRegistrationError, "#{@name} already has #{key}" if @entries.key?(key)

        @entries[key] = value
      end

      def fetch(key)
        @entries.fetch(key.to_sym)
      end

      def registered?(key)
        @entries.key?(key.to_sym)
      end

      def to_h
        @entries.dup
      end

      def freeze!
        @frozen = true
        @entries.freeze
        self
      end
    end

    class OrderedRegistry
      Entry = Data.define(:key, :value)

      def initialize(name:)
        @name = name
        @entries = []
        @keys = {}
        @frozen = false
      end

      def register(key, value)
        raise FrozenRegistryError, "#{@name} is frozen" if @frozen
        key = key.to_sym
        raise DuplicateRegistrationError, "#{@name} already has #{key}" if @keys.key?(key)

        entry = Entry.new(key: key, value: value)
        @entries << entry
        @keys[key] = true
      end

      def entries
        @entries.dup
      end

      def freeze!
        @frozen = true
        @entries.freeze
        @keys.freeze
        self
      end
    end
  end
end
```

### Pack Contract

Packs should be tiny and explicit.

Suggested contract:

```ruby
module Igniter
  module Contracts
    module Pack
      def install_into(kernel)
        raise NotImplementedError
      end
    end
  end
end
```

Recommended pack rules:

- a pack owns one coherent feature slice
- a pack can depend on baseline seams, not on ambient globals
- a pack should fail fast if required seams are missing

### BaselinePack

The default embedded kernel should be installed through one explicit baseline
pack.

Suggested contents:

- node kinds:
  `input`, `compute`, `composition`, `branch`, `collection`, `output`
- DSL keywords for those node kinds
- baseline validators:
  uniqueness, outputs, dependencies, callables, types
- local runtime handlers for baseline node kinds
- base diagnostics contributors

Suggested shape:

```ruby
module Igniter
  module Contracts
    module BaselinePack
      module_function

      def install_into(kernel)
        install_nodes(kernel)
        install_dsl(kernel)
        install_validation(kernel)
        install_runtime(kernel)
        install_diagnostics(kernel)
      end
    end
  end
end
```

Important exclusion:

- no `remote`
- no `agent`
- no cluster/session transport
- no hosted orchestration behavior

### DSL Registration Model

The DSL should be profile-driven.

Recommended direction:

- the builder receives a profile
- each keyword is resolved through `profile.dsl_keyword`
- missing keywords fail with a pack-oriented error

Example:

```ruby
compiled = Igniter::Contracts.compile(profile: profile) do
  input :amount
  compute :tax, depends_on: [:amount] do |amount:|
    amount * 0.2
  end
end
```

That means the builder itself does not hardcode every keyword forever. It
delegates keyword installation to the profile.

### Compiler Registration Model

Compiler structure should separate:

- baseline compile pipeline
- node-aware validations
- optional feature validators

Recommended compile pipeline:

1. build graph from DSL events
2. normalize graph through ordered normalizers
3. validate graph through ordered validators
4. emit compiled graph with profile fingerprint

This lets upper packs register validators without changing the compiler core.

The related pack manifest should declare those validators explicitly, so
`finalize` can fail fast when a pack advertises a compile seam but does not
actually register it.

`finalize` should also validate that each registered validator matches the
contracts hookspec, not just that it exists under the expected key.

### Runtime Registration Model

Runtime should dispatch by node kind through the profile.

Recommended direction:

```ruby
handler = profile.runtime_handler(node.kind)
handler.call(node: node, execution: execution, resolver: resolver)
```

That is the key to keeping `igniter-contracts` ignorant of `remote` until a
pack provides a `:remote` node class and a `:remote` runtime handler.

### Diagnostics Registration Model

Diagnostics should use ordered contributors, not hardcoded knowledge of every
concern.

Recommended direction:

```ruby
profile.diagnostics_contributors.each do |entry|
  entry.value.augment(report: report, execution: execution)
end
```

Baseline contributors should describe only baseline execution. Upper layers can
append richer diagnostics through packs.

Diagnostics contributors should also be listed in the pack manifest so profile
capabilities remain inspectable after finalization.

They should additionally be hookspec-validated during finalization so packs
cannot register contributors that omit required execution context keywords.

### Error Classes

Suggested baseline error additions:

- `FrozenKernelError`
- `FrozenRegistryError`
- `DuplicateRegistrationError`
- `UnknownDslKeywordError`
- `UnknownNodeKindError`
- `MissingRuntimeHandlerError`
- `ProfileMismatchError`
- `IncompletePackError`

These are important because extension architecture fails best when the errors
point to the missing seam, not to some downstream `NoMethodError`.

### Minimal Implementation Sequence

The first concrete implementation slice should likely be:

1. `Registry` and `OrderedRegistry`
2. `Kernel`
3. `Profile`
4. `BaselinePack`
5. profile-aware DSL builder
6. profile-aware compiler pipeline
7. profile-aware runtime dispatch

Only after that should we add the first upper-layer experimental pack.

### First Experimental Pack

The best first experimental pack is probably not `remote`, but a deliberately
small extension to prove the architecture.

Good candidates:

- `const`
- `project`
- `aggregate`
- a synthetic `audit_marker` diagnostics contributor

Why:

- lower operational risk
- easier to validate pack completeness
- proves the seams before we move machine/distributed behavior onto them

After that, `remote` becomes a much safer second or third pack.

## Migration Strategy

1. keep `igniter-core` intact as the legacy implementation package
2. build `igniter-contracts` as a separate composition root
3. define the baseline contracts profile and its allowed node kinds
4. introduce kernel/profile/pack abstractions
5. strengthen behavioral parity specs between baseline `igniter/contracts` and
   the current embedded subset of `igniter/core`
6. move knowledge of upper-layer concerns behind registries/seams
7. gradually replace the contracts composition with native contracts-owned code
8. leave the umbrella `igniter` gem as a convenience layer, not the architectural source of truth

## Current Checks

We should keep strengthening three kinds of checks:

- load-time boundary checks
- static dependency-boundary checks
- behavioral parity checks against the legacy implementation

We should add two more:

- profile finalization / immutability checks
- extension-pack completeness checks

## Research Inputs

Primary references that informed this direction:

- pluggy docs: hookspecs, plugin manager, spec validation
  [pluggy docs](https://pluggy.readthedocs.io/en/stable/)
- dry-container docs: explicit registry/resolver behavior
  [dry-container registry and resolver](https://dry-rb.org/gems/dry-container/main/registry-and-resolver/)
- dry-system docs: providers, boot lifecycle, explicit container finalization
  [dry-system providers](https://dry-rb.org/gems/dry-system/main/providers/)
  [dry-system booting](https://dry-rb.org/gems/dry-system/0.19/booting/)
- Rails docs: phased initialization through railties
  [Rails::Railtie API](https://api.rubyonrails.org/v7.1.0/classes/Rails/Railtie.html)
- MLIR docs: extensible dialects as host-owned extensibility model
  [MLIR extensible dialects](https://mlir.llvm.org/docs/DefiningDialects/)
- RuboCop docs: official plugin API instead of ad-hoc requires
  [RuboCop plugins](https://docs.rubocop.org/rubocop/latest/plugins.html)
