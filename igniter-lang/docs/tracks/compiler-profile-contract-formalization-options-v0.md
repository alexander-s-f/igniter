# Track: Compiler Profile Contract Formalization Options v0

Card: S3-R55-C2-P1
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Track: `compiler-profile-contract-formalization-options-v0`
Route: UPDATE
Status: done
Date: 2026-05-16

Affected neighbor roles: `[Igniter-Lang Research Agent]`,
`[Igniter-Lang Implementation Agent]`, `[Igniter-Lang Bridge Agent]`

---

## Goal

Formalize options for treating `CompilerProfile` as a compiler contract rather
than only a manifest identity, without migrating compiler dispatch.

This is a documentation and design slice only. It does not implement code,
mutate `.igapp` goldens, change profile artifacts, authorize CLI widening,
authorize loader/report work, or grant runtime authority.

---

## Inputs Read

- `docs/proposals/PROP-036-compiler-profile-manifest-identity-v0.md`
- `docs/tracks/compiler-profile-id-manifest-boundary-plan-v0.md`
- `docs/tracks/compiler-profile-chain-closure-index-v0.md`
- `docs/tracks/compiler-kernel-ordered-rule-precedence-v0.md`
- `docs/tracks/minimal-compiler-profile-finalization-proof-v0.md`
- `docs/tracks/assembler-compiler-profile-id-field-v0.md`
- `docs/current-status.md`
- `lib/igniter_lang/`

Key implementation surfaces observed:

- `lib/igniter_lang/assembler.rb`
- `lib/igniter_lang/compiler_orchestrator.rb`
- `lib/igniter_lang/classifier.rb`
- `lib/igniter_lang/typechecker.rb`

---

## Current Boundary

`PROP-036` currently establishes `compiler_profile_id` as a manifest identity
and compiler-understanding marker. It does not make the profile a live dispatch
contract.

The current Ruby and compiler path accepts:

```text
compiler_profile_source: nil
compiler_profile_source: finalized compiler_profile_id_source object
```

The `Assembler` validates the finalized source object and emits a top-level
`manifest.compiler_profile_id` when supplied. `CompilerOrchestrator` forwards
`compiler_profile_source` unchanged into the assembler boundary. Parser,
classifier, typechecker, and SemanticIR emitter are still the current monolithic
compiler surfaces; they are not selected by profile slots, packs, or ordered
rule registries.

Therefore any `CompilerProfile` contract must be treated as a pre-dispatch
contract until a later explicit card authorizes dispatch migration.

---

## Contract Question

The open design question is:

```text
When does a CompilerProfile become an enforceable compiler contract, and what is
the smallest contract shape that can be validated without changing dispatch?
```

This track compares five formalization options.

---

## Formal Options Table

| Option | Authority source | Minimum schema | Validation boundary | Compiler stage affected | Diagnostics / refusal vocabulary | Excluded |
| --- | --- | --- | --- | --- | --- | --- |
| Descriptor-only contract | Frozen compiler profile descriptor and descriptor digest | `kind`, `format_version`, `profile_namespace`, `descriptor_digest`, declared packs/capabilities, non-authority flags | Pre-finalization or proof-local descriptor validator before source compile | Preflight only; no parser/classifier/typechecker dispatch | `compiler_profile_contract.descriptor_missing`, `.wrong_kind`, `.schema_mismatch`, `.digest_mismatch`, `.unsupported_namespace` | Slots, ordered rules, pack dispatch, manifest mutation, loader/report, runtime authority |
| Profile slot contract | `CompilerProfileSpec` slot order and slot assignments | `profile_kind`, `slot_order`, `slot_assignments`, required/optional slots, implementation refs, `dispatch_migration_authorized: false` | Finalization validator before producing `compiler_profile_id_source`; assembler may continue validating only finalized source | Profile preflight and assembler identity injection; current pass order unchanged | `compiler_profile_contract.missing_required_slot`, `.duplicate_slot`, `.unknown_slot`, `.slot_order_mismatch`, `.implementation_id_mismatch` | Rule ordering, callable handlers, pack registry loading, CLI widening, runtime binding |
| Ordered rule contract | Normalized strict and ordered registries | strict registries for OOF/fragment ownership; ordered rule entries with `rule_id`, `stage`, `owner_slot`, `before`, `after`, `priority` | Profile finalization after slots, before source compile | Declared parser/classifier/typechecker rule order only; no live handler dispatch | `compiler_profile_contract.duplicate_strict_key`, `.duplicate_ordered_rule`, `.missing_rule_reference`, `.rule_cycle`, `.owner_mismatch`, `.unknown_stage` | Executing ordered rules, SemanticIR/assembler dispatch unless separately added, runtime readiness |
| Pack registry contract | Compiler kernel pack registry / pack descriptors | pack ids, versions, provided capabilities, required capabilities, contributed registries, implementation ids, compatibility constraints | Kernel assembly or pack-install preflight; proof-local until pack loading is authorized | Future CompilerKernel assembly; current monolith only observed as baseline | `compiler_profile_contract.pack_missing`, `.unsupported_pack_version`, `.capability_missing`, `.duplicate_capability`, `.registry_conflict`, `.incompatible_pack` | Production pack migration, dynamic loading, loader/report, `.igapp` changes, runtime execution |
| Hybrid profile contract | Canonical composition of descriptor, slots, ordered rules, pack registry, and finalized identity digest | `kind: compiler_profile_contract`, format/version, descriptor digest, slot model, strict ownership, ordered registries, pack refs, finalization digest, non-authority flags | Proof-local contract validator before source compile; later may feed finalization and assembler hash input | Contract preflight across compiler understanding; dispatch remains current monolith until authorized | Namespaced union under `compiler_profile_contract.*`, with adapter only where existing `compiler_profile_source.*` assembler refusals already apply | Dispatch migration, loader/report, CompatibilityReport, RuntimeMachine, production behavior, CLI surface changes |

---

## Option A: Descriptor-Only Contract

### Shape

Descriptor-only treats the compiler profile as a canonical descriptor artifact:

```text
kind: compiler_profile_descriptor
format_version
profile_namespace
descriptor_digest
declared_packs
declared_capabilities
runtime_authority_granted: false
dispatch_migration_authorized: false
```

### Boundary

Validation belongs before finalization, or inside a proof-local descriptor
validator. It proves that a descriptor is well-formed and digest-stable, but not
that the current compiler can enforce the described profile.

### Fit

This option is the safest first formal shape because it does not touch live
compiler stages. It is also too weak to be called a full compiler contract unless
paired with slot and rule checks.

### Recommended use

Use descriptor-only as the input layer for a future contract proof, not as the
final contract.

---

## Option B: Profile Slot Contract

### Shape

Profile slot contract makes the `slot_order` and `slot_assignments` from the
minimal finalization proof normative:

```text
profile_kind
slot_order
slot_assignments
required_slots
optional_slots
implementation_refs
dispatch_migration_authorized: false
runtime_authority_granted: false
```

### Boundary

Validation belongs in finalization before a `compiler_profile_id_source` object
exists. The current assembler can continue validating the finalized identity
source without becoming the owner of slot semantics.

### Fit

This is the smallest option that starts to feel like a compiler contract. It can
say which conceptual compiler slots are present without changing how the current
parser/classifier/typechecker are invoked.

### Risk

Slots alone can overstate safety if they imply handler availability. The
contract must say that a slot assignment is a declared ownership claim, not live
dispatch.

---

## Option C: Ordered Rule Contract

### Shape

Ordered rule contract promotes the ordered rule proof into profile contract
material:

```text
strict_registries:
  oof_descriptors
  fragment_class_owners
ordered_registries:
  parser_rules
  classifier_rules
  typechecker_rules
rule_entry:
  rule_id
  stage
  owner_slot
  before
  after
  priority
```

Strict registries preserve one key / one owner. Ordered registries preserve
deterministic rule order with cycle checks.

### Boundary

Validation belongs after slot validation and before source compilation. The
validator can prove ordering consistency without calling rule handlers.

### Fit

This is the strongest pre-dispatch contract for grammar/compiler work. It makes
future dispatch migration tractable because handler order becomes a validated
artifact before any code path consumes it.

### Risk

The current monolithic compiler does not expose stable rule handler ids for all
behavior. A proof-local model must avoid claiming that every current branch is
already a registered rule.

---

## Option D: Pack Registry Contract

### Shape

Pack registry contract makes the pack layer authoritative:

```text
pack_id
pack_version
implementation_id
provided_capabilities
required_capabilities
registry_contributions
compatibility_constraints
```

### Boundary

Validation belongs to a future CompilerKernel assembly or pack-install preflight.
Today it should remain proof-local because no production pack loader or dispatch
kernel is authorized.

### Fit

This option is best for future modular compiler assembly. It is not the right
next step for the current card because it would pull the design toward pack
loading before the contract vocabulary is stable.

### Risk

Pack registry authority can blur into runtime capability authority. The contract
must keep compiler-understanding capabilities separate from runtime execution
capabilities.

---

## Option E: Hybrid Profile Contract

### Shape

Hybrid profile contract composes the previous layers into one canonical
compiler-understanding contract:

```text
kind: compiler_profile_contract
format_version
profile_namespace
compiler_profile_id
descriptor_digest
finalization_payload_digest
slot_order
slot_assignments
strict_registries
ordered_registries
pack_refs
dispatch_migration_authorized: false
runtime_authority_granted: false
```

### Boundary

Validation is proof-local first. It should run before source compilation and
before assembler hashing, but it should not replace the existing assembler
`compiler_profile_source.*` refusal path until an implementation card says so.

### Fit

Hybrid is the best target shape for an eventual compiler contract because it can
explain:

- what compiler capabilities are understood;
- which ownership slots are present;
- which diagnostics and fragment classes have one owner;
- how future ordered rules would be sorted;
- why the profile identity digest is stable.

### Risk

Hybrid is too broad for immediate implementation authorization. It needs one more
proof-local experiment before becoming a normative proposal or code boundary.

---

## Diagnostics And Refusal Vocabulary

Recommended namespace for contract validation:

```text
compiler_profile_contract.*
```

This should stay separate from existing assembler source refusals:

```text
compiler_profile_source.*
```

Boundary rule:

```text
compiler_profile_source.* = caller/facade/assembler source object refusal
compiler_profile_contract.* = semantic profile contract validation refusal
```

Suggested first vocabulary:

| Code | Meaning |
| --- | --- |
| `compiler_profile_contract.descriptor_missing` | No descriptor material exists where the contract validator requires it. |
| `compiler_profile_contract.schema_mismatch` | Descriptor or contract fields do not match the expected format version. |
| `compiler_profile_contract.digest_mismatch` | Canonical digest does not match declared digest. |
| `compiler_profile_contract.missing_required_slot` | A required compiler slot is absent. |
| `compiler_profile_contract.slot_order_mismatch` | Declared slot order differs from the canonical slot order. |
| `compiler_profile_contract.duplicate_strict_key` | A strict registry key has more than one owner. |
| `compiler_profile_contract.missing_rule_reference` | An ordered rule references a missing `before` / `after` target. |
| `compiler_profile_contract.rule_cycle` | Ordered rule graph contains a cycle. |
| `compiler_profile_contract.pack_missing` | A referenced pack descriptor is absent. |
| `compiler_profile_contract.runtime_authority_forbidden` | Contract material attempts to grant runtime authority. |
| `compiler_profile_contract.dispatch_migration_forbidden` | Contract material attempts to enable dispatch migration before authorization. |

The existing assembler vocabulary should remain valid for finalized source
transport:

```text
compiler_profile_source.missing
compiler_profile_source.malformed
compiler_profile_source.wrong_kind
compiler_profile_source.unfinalized
compiler_profile_source.unsupported_namespace
compiler_profile_source.malformed_id
compiler_profile_source.id_digest_mismatch
compiler_profile_source.slot_order_mismatch
compiler_profile_source.runtime_authority_forbidden
compiler_profile_source.dispatch_migration_forbidden
compiler_profile_source.payload_id_inclusion_forbidden
```

Do not reuse loader status vocabulary such as `present_verified`, `mismatch`,
`malformed`, or `missing_required` as compiler contract refusal codes. Those
belong to load/report interpretation, not pre-dispatch compiler validation.

---

## Recommendation

Recommended next route:

```text
1. Design-only track: compiler-profile-contract-boundary-v0
2. Proof-local experiment: compiler-profile-contract-proof-v0
3. New PROP if proof stabilizes the contract as canonical language/compiler
   architecture
4. Implementation authorization only after the proof fixes diagnostics,
   validation order, and non-authority flags
```

Do not make this a narrow `PROP-036` errata as the primary route. `PROP-036`
owns manifest identity and the finalized source transport path. Treating
`CompilerProfile` as a compiler contract is broader than manifest identity and
should become either a new PROP or a separate design/proof packet first.

Do not request implementation authorization yet. The next executable work should
be proof-local and should validate a hybrid contract object without changing
parser, classifier, typechecker, SemanticIR, assembler goldens, loader/report,
RuntimeMachine, or CLI behavior.

---

## Recommended Grammar / Compiler Contract Route

The grammar route should stay descriptor-first:

```text
profile source syntax pressure
  -> descriptor/profile contract object
  -> finalized compiler_profile_id_source
  -> manifest compiler_profile_id
```

No source syntax should be accepted in this slice. If a future syntax is
proposed, it should lower to descriptor or profile contract material first. It
should not directly alter compiler dispatch.

For compiler architecture, the preferred target is the hybrid profile contract,
with staged proof gates:

| Gate | Purpose | Must not do |
| --- | --- | --- |
| Contract shape proof | Validate canonical hybrid object shape and digest stability | No live dispatch |
| Slot/rule proof | Validate slots, strict registries, and ordered rule graph | No handler execution |
| Source object adapter proof | Show how finalized contract produces existing `compiler_profile_id_source` | No assembler golden migration |
| Conformance proof | Show current monolith can be described by the contract | No pack loader |
| Implementation request | Ask for a tiny validator boundary only after proof closure | No CLI/runtime widening |

---

## Open Questions

- Is `CompilerProfileContract` authoritative for build acceptance, source
  compilation, artifact emission, or only profile finalization?
- Should the contract object live beside `compiler_profile_id_source`, under it,
  or only as a proof-local input until a new PROP lands?
- Which registries are strict versus ordered for SemanticIR and assembler?
- Does the current monolithic compiler have enough stable internal rule ids to
  prove conformance honestly?
- How should diagnostic ownership be versioned so OOF namespace ownership cannot
  drift between packs?
- Should `CompilerProfileContract` ever appear in `.igapp`, or should manifests
  continue carrying only `compiler_profile_id`?
- What is the relationship between contract validation, future
  `CompilationReceipt`, `.ilk`, and signing?
- When can `profile_required` rollout be reconsidered without breaking legacy
  optional manifests?
- How do we prevent contract validation from implying runtime readiness,
  executor approval, or production authority?

---

## Blockers Before Implementation Authorization

- A canonical `compiler_profile_contract` object shape is not yet accepted.
- Contract diagnostics are not yet proof-validated.
- Current compiler pass internals are not mapped to stable rule ids.
- Slot/rule/pack validation ordering is not yet fixed in an executable proof.
- No migration plan exists for assembler goldens or `.igapp` profile-required
  output.
- Loader/report and CompatibilityReport ownership remains explicitly out of
  scope for this card.
- CLI source-shape widening remains closed unless a later card reopens it.
- Runtime authority remains forbidden.

---

## Non-Authorization

This track does not authorize:

- parser syntax changes;
- profile source syntax acceptance;
- compiler dispatch migration;
- pack loading;
- loader/report implementation;
- CompatibilityReport changes;
- RuntimeMachine changes;
- `.igapp` manifest or golden mutation;
- `.ilk` or signing changes;
- CLI flags or API widening;
- environment/config/sidecar discovery;
- profile defaulting or named lookup;
- Ledger/TBackend;
- stream/OLAP/temporal executor widening;
- production cache;
- production behavior.

---

## Handoff

```text
Card: S3-R55-C2-P1
Agent: [Igniter-Lang Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: compiler-profile-contract-formalization-options-v0
Status: done

[D] Decisions
- `compiler_profile_id_source` remains the current finalized identity transport.
- `compiler_profile_contract.*` should be the separate vocabulary for future
  semantic contract validation.
- Hybrid profile contract is the preferred target shape, but only after a
  proof-local validator stabilizes it.

[S] Signals
- Descriptor-only is safe but too weak.
- Profile slots are the smallest contract-like layer.
- Ordered rules are the strongest pre-dispatch compiler contract layer.
- Pack registry belongs later, after contract vocabulary is stable.
- Hybrid is the likely eventual target but not ready for implementation
  authorization.

[T] Tests / Proofs
- Documentation-only slice.
- No code, `.igapp` goldens, or profile artifacts were changed.

[R] Recommendation
- Open a design-only `compiler-profile-contract-boundary-v0` card.
- Follow with a proof-local `compiler-profile-contract-proof-v0` experiment.
- Route canonical semantics through a new PROP if the proof stabilizes.
- Do not use PROP-036 errata as the main vehicle for this broader contract.

[Next]
- Prove a hybrid contract object that validates descriptor, slots, strict
  ownership, ordered rule graph, and non-authority flags without touching live
  compiler dispatch.
```
