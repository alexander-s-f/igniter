# Profile–Baseline–Pack Assembly Pattern: Formal Analysis

Status: inbox / research
Author: [Igniter-Lang Implementation Agent]
Date: 2026-05-10
Source: igniter-contracts + igniter-extensions, read-only survey

---

## 1. Purpose

This document formally describes the Profile–Baseline–Pack assembly pattern
found in `packages/igniter-contracts` and `packages/igniter-extensions`, then
evaluates whether it applies to the igniter-lang compiler architecture.

---

## 2. The Pattern: Formal Description

### 2.1 Structural Roles

```
Kernel          — mutable accumulator; accepts pack installations; freezes on finalize
Pack            — named unit of capability; declares manifest; installs into Kernel
PackManifest    — declarative contract: what a Pack provides and requires
BaselinePack    — mandatory first pack; defines primitive capabilities
Profile         — immutable, fingerprinted snapshot of a finalized Kernel
Environment     — thin facade wrapping a Profile into a usable API surface
Registry        — unordered, duplicate-safe, key → value store
OrderedRegistry — ordered, duplicate-safe, key → value list (preserves insert order)
```

### 2.2 Assembly Lifecycle

```
1.  Kernel.new
2.  kernel.install(BaselinePack)         # mandatory first: sets primitive registries
3.  kernel.install(PackA)               # idempotent by name; resolves pack.requires_packs first
4.  kernel.install(PackB)               # circular-dep detected via in-progress name list
5.  kernel.finalize                     # validate completeness → freeze → Profile.build_from
→   Profile (frozen, SHA-256 fingerprinted)
→   Environment.new(profile: profile)   # optional facade
```

API shortcut:

```ruby
env = Igniter::Contracts.with(PackA, PackB)
# equivalent to: build_kernel + install(Baseline) + install each + finalize + Environment.new
```

### 2.3 Pack Interface

Every pack must expose two methods:

```ruby
module SomePack
  module_function

  def manifest
    PackManifest.new(
      name: :some_pack,
      node_contracts: [...],       # NodeContract per node kind
      registry_contracts: [...],   # RegistryContract per registry slot
      requires_packs: [...],       # PackDependency list (name + optional pack object)
      provides_capabilities: [...],
      requires_capabilities: [...]
    )
  end

  def install_into(kernel)
    kernel.nodes.register(:my_kind, NodeType.new(...))
    kernel.dsl_keywords.register(:my_keyword, DslKeyword.new(...))
    kernel.validators.register(:my_validator, method(:validate))
    kernel.runtime_handlers.register(:my_kind, method(:handle))
    kernel
  end
end
```

A pack with no manifest still works (`install_into` only), but cannot participate
in completeness validation, capability declarations, or dependency resolution.

### 2.4 Kernel Invariants During Installation

| Invariant | Enforcement point |
|-----------|-------------------|
| No duplicate registry key | Registry#register raises DuplicateRegistrationError |
| No double-pack installation | pack_installed? check before install_into |
| No circular pack dependency | in-progress name list; raises CircularPackDependencyError |
| No mutation after finalize | finalized? guard at install entry |

### 2.5 Finalization Validation

`Kernel#finalize` runs three validation passes before freezing:

**A. Completeness**

For every `NodeContract` declared by any installed manifest:
- a node of that kind must be registered in `nodes`
- if `requires_dsl: true` → a DSL keyword of that kind must be registered
- if `requires_runtime: true` → a runtime handler of that kind must be registered

For every `RegistryContract` declared by any installed manifest:
- that key must be registered in the named registry

Failure raises `IncompletePackError` with a human-readable listing of gaps.

**B. Hook Protocol**

For every entry in every registry, a `HookSpec` validates:
- the implementation responds to the required method name (`:call`)
- it accepts the required keyword arguments

Failure raises `InvalidHookImplementationError`.

**C. Freeze**

All registries are permanently frozen. Post-freeze mutation raises
`FrozenRegistryError`.

### 2.6 Profile: Content-Addressed Snapshot

`Profile.build_from(kernel)` extracts all registries into a frozen value object
and computes a `SHA-256 fingerprint` over the entire registry surface:

```ruby
fingerprint = Digest::SHA256.hexdigest(
  registry_hash.map { |k, v| [k.to_s, serialize(v)] }.inspect
)
```

The fingerprint is a **compile-time compatibility token**. Any pack added or
removed changes the fingerprint. `ComposePack` uses this to detect that nested
sub-contracts were compiled against a different profile:

```ruby
compiled_graph.profile_fingerprint != profile.fingerprint
  # → ValidationFinding :compose_profile_mismatch
```

This makes profile identity a first-class, verifiable artifact.

### 2.7 Capability Declarations

`PackManifest` carries `provides_capabilities` and `requires_capabilities`
as symbol arrays. `Profile` exposes:

```ruby
profile.provided_capabilities   # flat union from all installed manifests
profile.required_capabilities   # flat union from all installed manifests
```

`CapabilitiesPack` (in igniter-extensions) uses these + per-node capability
declarations to enforce capability policies at compile time.

### 2.8 Registries in Use

| Registry | Type | Contents |
|----------|------|----------|
| `nodes` | Registry | kind → NodeType |
| `dsl_keywords` | Registry | name → DslKeyword (callable) |
| `runtime_handlers` | Registry | kind → callable |
| `validators` | OrderedRegistry | name → callable (run in order) |
| `normalizers` | OrderedRegistry | name → callable (run in order) |
| `diagnostics_contributors` | OrderedRegistry | name → module |
| `effects` | Registry | name → callable |
| `executors` | Registry | name → callable |

Order matters for validators and normalizers (first-registered runs first).
Registry is for lookup; OrderedRegistry is for pipeline.

---

## 3. Evidence from igniter-extensions

The extension packages follow the same interface with zero changes to the
core pack protocol:

| Extension pack | Adds | Declares |
|----------------|------|----------|
| `ComposePack` | `:compose` node, 3 validators, runtime handler | `provides_capabilities: %i[subgraph_invocation nested_contracts]` |
| `CapabilitiesPack` | no node, no kernel mutation | pure overlay: reads profile.pack_manifests |
| `SagaPack` | no kernel mutation | metadata: `category: :orchestration`; guards via `ensure_installed!` |
| `BranchPack` | `:branch` node, validator, runtime handler | standard manifest pattern |
| `DataflowPack` | session semantics overlay | reads profile at runtime |

**Key observation**: some packs install nothing into the kernel but still use
the manifest for profile presence checks. This is a valid degenerate case —
the pack is a named capability boundary, not a registry contributor.

---

## 4. Pattern Summary (One Paragraph)

The pattern is a **declarative, finalization-validated, content-addressed
pack assembly system**. A mutable Kernel accumulates named capability units
(Packs) through a standard `manifest + install_into` interface. Each pack
declares what it provides and what it requires; the Kernel resolves
dependencies recursively and detects cycles before installing. At `finalize`,
the Kernel runs a completeness check — every declared contract must have a
real registered implementation — then freezes all registries into an immutable,
SHA-256 fingerprinted Profile. The Profile is the single compile-time identity
token: everything downstream (compiler, runtime, diagnostics, composition
validation) reads from the Profile alone, never from the open Kernel.

---

## 5. Fit Evaluation: igniter-lang Compiler

### 5.1 Current igniter-lang Compiler Architecture

```
lib/igniter_lang/
  parser.rb              — monolithic PEG-style rule set
  classifier.rb          — case/when over fragment kinds
  typechecker.rb         — multi-pass type rules
  semanticir_emitter.rb  — emit_typed dispatch per node type
  assembler.rb           — .igapp writer
  compiler_orchestrator.rb — pipeline wiring
```

Each pass is a flat module with a single entry-point method. Adding a new
fragment class (e.g., TEMPORAL via PROP-028, contract modifiers via PROP-031,
assumptions via PROP-032) requires editing each pass file individually. There
is no explicit declaration that "TEMPORAL support requires parser rule X AND
classifier handler Y AND type rule Z AND SemanticIR emitter W."

### 5.2 Mapping: Ruby contracts → igniter-lang compiler

| Ruby contracts concept | igniter-lang compiler concept |
|------------------------|-------------------------------|
| `Kernel` | `CompilerKernel` — mutable accumulator of compiler passes |
| `Pack` | `CompilerPack` — named language-surface capability unit |
| `PackManifest` | `CompilerManifest` — declares pass slots this surface provides |
| `BaselinePack` | `CoreLanguagePack` — CORE fragment class (input/compute/output/const) |
| `Profile` | `CompilerProfile` — frozen, fingerprinted compiler snapshot |
| `Environment` | `CompilerEnvironment` — `compile(source)` / `assemble(source)` facade |
| `Registry` | `PassRegistry` — emitter kind → handler callable |
| `OrderedRegistry` | `PipelineRegistry` — ordered parse/classify/typecheck rules |
| `nodes` registry | `fragment_classes` — kind → FragmentClassDescriptor |
| `dsl_keywords` registry | `parser_rules` — surface → ParseRule callable |
| `validators` OrderedRegistry | `type_rules` — ordered TypeRule callables |
| `normalizers` OrderedRegistry | `classifier_rules` — ordered ClassifierRule callables |
| `runtime_handlers` registry | `semanticir_handlers` — node kind → emit callable |
| `executors` registry | `assembler_handlers` — artifact type → assemble callable |
| `effects` registry | (no direct analog; could map to OOF code registries) |
| `provides_capabilities` | fragment class guard surface (CORE / TEMPORAL / ESCAPE) |
| `fingerprint` | `.igapp` manifest `compiler_profile_id` for compatibility checks |

### 5.3 Concrete PROP Mapping as Packs

```ruby
profile = IgniterLang::Compiler.build_profile(
  IgniterLang::CoreLanguagePack,         # CORE: input/compute/output/const/effect
  IgniterLang::TemporalPack,             # PROP-028: TEMPORAL fragment class + History[T]
  IgniterLang::StreamPack,               # PROP-023: stream T / OOF-S1..5
  IgniterLang::OLAPPack,                 # PROP-024: OLAPPoint[T,Dims]
  IgniterLang::InvariantPack,            # PROP-025: invariant severity
  IgniterLang::ContractModifiersPack,    # PROP-031: pure/observed/effect/privileged/irreversible
  IgniterLang::AssumptionsPack           # PROP-032: assumptions {} / uses assumptions NAME
)
```

Each pack would declare exactly what it adds to each compiler pass. A
`TemporalPack.manifest` might look like:

```ruby
CompilerManifest.new(
  name: :temporal,
  fragment_class_contracts: [
    CompilerManifest.fragment_class(:TEMPORAL)
  ],
  pass_contracts: [
    CompilerManifest.parser_rule(:temporal_input),
    CompilerManifest.parser_rule(:temporal_access),
    CompilerManifest.classifier_rule(:temporal_fragment),
    CompilerManifest.type_rule(:temporal_history_type),
    CompilerManifest.type_rule(:temporal_bihistory_type),
    CompilerManifest.semanticir_handler(:temporal_input),
    CompilerManifest.semanticir_handler(:temporal_access),
    CompilerManifest.assembler_handler(:temporal_manifest_index)
  ],
  requires_packs: [CoreLanguagePack],
  provides_capabilities: %i[temporal_evaluation history_valid_time]
)
```

The `kernel.finalize` would catch: "TemporalPack declared a SemanticIR handler
for `:temporal_input` but no handler was registered" — exactly the kind of
gap that currently surfaces only as a runtime error or missing golden check.

### 5.4 Where the Pattern Fits Well

**Completeness validation at assembly time, not golden-check time.**
Currently, a missing classifier branch for a new fragment class is discovered
when a proof script runs. With pack assembly, the gap is caught when
`CompilerProfile` is built — before any source is compiled.

**Explicit dependency declaration between PROPs.**
`AssumptionsPack` can declare `requires_packs: [CoreLanguagePack]` and
optionally express that `epistemic` fragment class requires grammar that
precedes PROP-032. The current governance approach (explicit implementation
gate before classifier work) maps directly to a `requires_packs` declaration.

**Profile fingerprint for `.igapp` compatibility.**
The `.igapp` manifest already carries `compatibility_metadata`. The profile
fingerprint could become a first-class `compiler_profile_id` in the manifest,
enabling hard compatibility checks when loading a `.igapp` artifact: "this
artifact was compiled with a profile that did not include TemporalPack."

**Staged gate authority via capability declarations.**
The current Gate 3 scope exclusion (TEMPORAL execution is proof-local only)
could be modeled as `TemporalPack` declaring `provides_capabilities:
[:temporal_scope_restricted]` and the RuntimeMachine checking capability
before evaluation — without hardcoded guards in the executor.

**Clean surface for PROP-032 implementation gate.**
The explicit gate "PROP-032 needs an implementation gate before classifier
work starts" is exactly a `requires_packs` dependency. If
`AssumptionsPack.manifest.requires_packs` references a not-yet-built pack,
`Kernel#install` raises `UnknownPackDependencyError` at assembly time.

### 5.5 Where the Pattern Requires Adaptation

**Fragment class vs node kind.**
In igniter-contracts, each node kind has exactly one DSL keyword and one
runtime handler. In igniter-lang, a fragment class (CORE, TEMPORAL, ESCAPE)
contains multiple node kinds, and the classifier operates at the
fragment-class level, not per-node-kind. The mapping is:

```
Fragment class → Pack
Node kind within class → individual handler registered by that Pack
```

This works but requires one extra indirection in the manifest design.

**Ordered rules with explicit precedence.**
The current V-3 rule (temporal modifier takes precedence over contract
modifier) is currently embedded as a Classifier sorting rule. With
`OrderedRegistry`, this would need explicit ordering at install time:

```ruby
kernel.classifier_rules.register(:temporal_precedence_over_modifier,
                                  method(:classify_temporal_modifier),
                                  after: :contract_modifiers)
```

The current `OrderedRegistry` has no `after:` / `before:` semantics — it
is insertion-order only. This is a gap that would need to be addressed or
worked around (e.g., by mandating a canonical pack installation order).

**Monolithic passes need decomposition.**
`classifier.rb`, `typechecker.rb`, and `semanticir_emitter.rb` are currently
monolithic. Migrating them to registry-based dispatch requires:
1. Extracting each fragment-class branch into a standalone callable
2. Registering each callable with a named key
3. Replacing the monolithic `case/when` with a registry dispatch loop

This is a significant refactor — not a drop-in. It should be a dedicated
migration track, not a side effect of a new PROP.

**No runtime side of the compiler.**
igniter-lang's compiler has no analogue to `effects` or `executors`
registries. These slots would simply be absent from `CompilerKernel`. The
registries needed are a strict subset.

**OOF code registry.**
The current OOF (out-of-fragment) error code system has no explicit registry.
This is a natural additional registry slot: `oof_codes → OOFDescriptor`.
A pack would declare which OOF codes it owns and what they mean.

---

## 6. Assessment

### 6.1 Fit Verdict

**Strong architectural fit for Stage 3+ compiler extensibility.**

The pattern directly solves the current pain: each new PROP (PROP-032,
future PROPs) currently requires editing multiple monolithic pass files.
With pack assembly:
- each PROP becomes a named, dependency-declared, completeness-validated pack
- the compiler surface is open to new PROPs without touching existing packs
- `.igapp` compatibility becomes explicit and verifiable via profile fingerprint
- the implementation gate requirement (explicit for PROP-032) is structurally
  enforced by `requires_packs`

### 6.2 Risk / Readiness

| Item | Assessment |
|------|------------|
| Benefit is real, timing is not now | The current monolithic passes work; rewriting them mid-Stage-3 risks regression |
| Migration cost is non-trivial | 3 monolithic passes → registry dispatch is a full implementation track |
| Ordered-rule precedence needs design | V-3 ordering is not expressible with insertion-order-only registry |
| Profile fingerprint in .igapp is ready | The compatibility_metadata slot exists; this is additive |
| Pack assembly for new PROPs (PROP-032+) | Greenfield PROPs can be written as packs even if older passes are not yet migrated |

### 6.3 Recommendation

Route as a **Stage 3 architectural PROP** (or META-EXPERT analysis):
"CompilerProfile: Pack-based compiler assembly for igniter-lang."

Do not attempt migration of existing passes until:
1. The post-R30 bounded durable-audit implementation track is complete
2. A dedicated migration-plan card assigns scope and regression budget
3. The ordered-rule precedence design question is resolved

Greenfield work (PROP-032 `AssumptionsPack`, PROP-029 `EntrypointPack`) could
be written as packs from the start, even if `CoreLanguagePack` is not yet
extracted from the current monolithic passes. This creates a migration path
that does not break existing proofs.

---

## 7. Sources Read

```
packages/igniter-contracts/lib/igniter/contracts/assembly/kernel.rb
packages/igniter-contracts/lib/igniter/contracts/assembly/profile.rb
packages/igniter-contracts/lib/igniter/contracts/assembly/pack.rb
packages/igniter-contracts/lib/igniter/contracts/assembly/pack_manifest.rb
packages/igniter-contracts/lib/igniter/contracts/assembly/baseline_pack.rb
packages/igniter-contracts/lib/igniter/contracts/assembly/registry.rb
packages/igniter-contracts/lib/igniter/contracts/assembly/ordered_registry.rb
packages/igniter-contracts/lib/igniter/contracts/assembly/hook_spec.rb
packages/igniter-contracts/lib/igniter/contracts/environment.rb
packages/igniter-contracts/lib/igniter/contracts/api.rb
packages/igniter-extensions/lib/igniter/extensions/contracts/compose_pack.rb
packages/igniter-extensions/lib/igniter/extensions/contracts/capabilities_pack.rb
packages/igniter-extensions/lib/igniter/extensions/contracts/saga_pack.rb
packages/igniter-contracts/spec/igniter/contracts/pack_completeness_spec.rb
packages/igniter-contracts/spec/igniter/contracts/baseline_layering_spec.rb
packages/igniter-contracts/spec/igniter/contracts/extension_layering_spec.rb
packages/igniter-contracts/README.md
```

---

## 8. Suggested Routes

```
[R] Route to Meta Expert / Architect for scoping:
    "CompilerProfile: pack-based compiler assembly" as a Stage 3 PROP or
    META-EXPERT analysis before any migration card is opened.

[R] Greenfield PROPs (PROP-032, PROP-029) can be designed as packs
    from the start — no monolithic migration required for new surfaces.

[Q] Ordered-rule precedence design:
    Does OrderedRegistry insertion order suffice, or do we need
    explicit before:/after: declarations for rules like V-3?
    → Route to Compiler/Grammar Expert.

[Q] Profile fingerprint in .igapp:
    Should compiler_profile_id become a mandatory manifest field?
    → Route to Architect (manifest contract decision).
```
