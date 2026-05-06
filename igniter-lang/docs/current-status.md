# Igniter-Lang Current Status

Status: fixed point
Date: 2026-05-06
Role: `[Igniter-Lang Research Agent]`
Track: `igniter-lang/igniter-lang-current-status-refresh-v0`
Supervisor: `[Architect Supervisor / Codex]`
Affected neighbors: `[Igniter-Lang Compiler/Grammar Expert]`, `[Igniter-Lang Bridge Agent]`

---

## Compact Identity

Igniter-Lang is an **Epistemic Contract Language**:

```text
contracts + explicit time + observation evidence
  -> ParsedProgram
  -> ClassifiedProgram
  -> TypedProgram
  -> SemanticIR
  -> CompiledProgram / .igapp
  -> RuntimeMachine.load(...)
  -> evaluate / checkpoint / resume
  -> SemanticImage + CompatibilityReport
  -> TBackend adapters
  -> schema evolution + migration receipts
```

Short map:

- **Contracts** name the meaning boundary; everything meaningful must be
  contract-addressable.
- **Time** is a language dimension: evaluations require explicit `TemporalCtx`,
  horizons, windows, slices, and lifecycle rules.
- **Projections / slices** make temporal views addressable and reproducible.
- **RuntimeMachine** owns boot/load/evaluate/checkpoint/resume semantics.
- **Schema evolution** is part of compatibility, not a deployment afterthought.

Igniter Ledger may become a durable `TBackend` adapter. It is not the language
core.

---

## Current Toolchain Center

[D] `SemanticIR` is the stable compiler boundary. Parser output, `.igapp`
fixtures, runtime proofs, and future native/server artifacts all converge here.

[D] A `CompiledProgram` is a typed, content-addressed, loadable semantic
artifact. It carries contracts, requirements, descriptors, provenance anchors,
schema descriptors, diagnostics, and artifact identity. It does not own runtime
execution.

[D] `RuntimeMachine` is the semantic owner of runtime lifecycle:

```text
boot -> load -> evaluate -> checkpoint -> resume
```

`RuntimeMachine.load(...)` consumes a compiled/loadable unit, verifies runtime
requirements, emits descriptor observations, and records the loaded schema
descriptor used by compatibility checks.

---

## What Is Decided

[D] CORE / ESCAPE / OOF is the trust boundary:

- CORE must be deterministic, bounded, immutable, explicit-time, and free of
  hidden host effects.
- ESCAPE must be declared, capability-gated, and receipt/failure-producing.
- OOF must not be accepted silently by compiler or runtime paths.

[D] Observation evidence is the unit of trust. Equal raw result values or equal
value hashes do not prove equivalence without required evidence links.

[D] `CompatibilityReport` gates resume. It now includes runtime/backend/
observation checks plus PROP-017 `schema_check`.

[D] Schema evolution has first-class rules:

- contracts carry `schema_version`
- observable surfaces carry `schema_fingerprint`
- safe drift may be `provisional`
- breaking drift without migration is `blocked`
- visible migrations produce `schema_check:migrating`
- migration evidence is descriptor -> intent -> audit receipt
- migration receipts must include `caused_by`, `produced_by`, and `replaces`

[D] PROP-016 settles polymorphism direction:

- generic contracts use parametric types and trait constraints
- traits are compile-time capabilities, not OO inheritance
- `contract_shape` is structural port conformance
- impl coherence and overload resolution are compile-time concerns
- `SemanticIR` must contain no unresolved overloads or type variables
- RuntimeMachine must reject artifacts that still contain generic type
  variables or unresolved trait calls

[D] PROP-012 settles deployment direction:

- `.igapp/` is the current human-readable devkit artifact
- `.igc.json`, `.igc.pack`, embedded/server, and native artifacts are later
  formats over the same semantic artifact model
- native code may accelerate pure compute, but RuntimeMachine still owns time,
  evidence, effects, lifecycle, and compatibility

---

## What Is Proven

[S] Source parser proof:

```text
source/add.ig
source/availability_projection.ig
  -> experiments/parser/igniter_lang_parser.rb
  -> ParsedProgram JSON with parse_errors: []
```

This proves the PROP-014/015 source kernel is parseable for the two current
accepted source fixtures. It does not prove classification, typechecking,
lowering, or `.igapp` equivalence.

[S] `.igapp` devkit fixtures exist for:

```text
fixtures/add.igapp/
fixtures/availability_projection.igapp/
```

These are compiler acceptance targets, not proof of a full compiler frontend.

[S] Runtime Machine memory proof is executable and standalone:

```text
boot -> load -> evaluate -> checkpoint -> resume -> re-evaluate
```

It proves trusted in-harness resume, explicit-time blocking, empty-backend
resume blocking, runtime drift downgrade, contract drift block, missing evidence
provisional, same-value-without-evidence provisional, trusted schema match,
provisional schema drift, and migrating schema drift.

[S] The previous standalone proof regression is fixed and should remain a
guardrail. `schema_check` once depended on hidden `loaded_program` state from
`compiled_program.rb`, causing direct memory proof runs to fail. The primitive
runtime boundary is now:

```text
RuntimeMachine.loaded_unit
+ RuntimeMachine.loaded_schema_descriptor
```

`CompiledProgram` is only one producer of `schema_descriptor`; it is not the
owner of compatibility semantics.

[S] Packet fixtures and checker are executable:

- golden ObsPackets
- SemanticImage
- CompatibilityReport
- negative evidence
- result summary
- sidecar builder profiles
- selected-profile external candidate normalizer

[S] Ruby FFI is contractable at proof scale:

```text
FFIRequirement
  -> intent_observation
  -> CapabilityGate
  -> host call
  -> receipt_observation | failure_observation
```

Read success, write/audit success, capability denial, and host error have
standalone receipt/failure fixtures and checker coverage.

[S] Schema migration has a first proof fixture:

```text
loaded MigrationDescriptor
  -> schema_check:migrating CompatibilityReport
  -> intent_observation
  -> audit receipt_observation
  -> replacement SemanticImage
  -> trusted CompatibilityReport
```

This proves report, receipt, replacement-image, and post-migration trust shape.
It does not prove a general migration DSL or TBackend history rewrite.

---

## Pressure-Only Fixtures

[S] `source/polymorphic_add.ig` is intentionally a pressure fixture, not a
parser-accepted fixture today.

It pins the desired PROP-016 surface:

```text
trait Additive[T]
impl Additive[Integer]
impl Additive[Float]
contract_shape AddShape[T]
contract Add[T: Additive] implements AddShape[T]
```

Current parser status:

- `polymorphic_add.ig` is expected to fail until the parser accepts trait,
  impl, `using`, `contract_shape`, generic contract headers, and `implements`.
- `polymorphic_add.parsed_program.expected.json` is the future acceptance
  target.
- monomorphization, trait coherence, impl resolution, and implements checks
  belong to classification/type/IR work, not parser work.

[S] General migration execution remains pressure-only. The current migration
fixture proves one toy identity replacement image; it does not execute a
general `MigrationDecl`, rewrite TBackend history, or settle multi-hop
migration semantics.

[S] External/package candidate equivalence is pressure-only. `selected_profile`
candidate artifacts can pass the checker, but normalized-equivalence rules for
real package-derived packets are not defined yet.

---

## Currently Open

Critical:

- no complete parser -> classifier -> typechecker -> SemanticIR compiler path
- no parsed-source-to-`.igapp` surface checker yet
- `polymorphic_add.ig` is not parser-accepted yet
- no PROP-016 classifier/type/monomorphization proof

High:

- normalized-equivalence profile for real external/FFI/package candidates
- ESCAPE capability algebra: delegation, overlap, revocation, serialization,
  and composition
- `.igapp` schema and artifact hash validator stricter than current fixtures
- replacement-image formal semantics: fields, link rels, lifecycle, and
  multi-hop chain policy
- migration path selection: direct, shortest-path, or policy-selected

Medium:

- file-backed TBackend proof after memory proof remains stable
- compensation/retry semantics for long-running effects
- privacy and redaction propagation through contract composition
- parser diagnostics shape: plain JSON vs ObsPacket-style failures

Deferred:

- pattern matching
- higher-kinded types / associated types
- native backend
- self-hosting beyond staged plan

---

## Next 3 Recommended Tracks

1. `[Igniter-Lang Research Agent]`
   `polymorphic-add-parser-acceptance-v0`

   Implement the bounded parser delta from the pressure map: lexer `_`, trait,
   impl `using`, `contract_shape`, generic contract header, and `implements`.
   Compare `polymorphic_add.ig` to
   `polymorphic_add.parsed_program.expected.json`; keep existing accepted
   parser fixtures green.

2. `[Igniter-Lang Compiler/Grammar Expert]`
   `polymorphic-add-classifier-and-monomorphizer-v0`

   Define ClassifiedProgram/TypedProgram handling for trait/impl/shape nodes,
   coherence checks, impl resolution, implements checks, and monomorphic
   `Add[Integer]` / `Add[Float]` SemanticIR emission. Preserve the invariant:
   no type variables or unresolved overloads in SemanticIR.

3. `[Igniter-Lang Compiler/Grammar Expert]`
   `migration-replacement-image-formalization-v0`

   Formalize replacement image fields, link rels, lifecycle, and multi-hop
   semantics before bridge/package integration.

---

## Useful Verification Commands

Current proof/check commands:

```bash
ruby igniter-lang/experiments/runtime_machine_memory_proof/runtime_machine_memory_proof.rb
ruby igniter-lang/experiments/runtime_machine_memory_proof/runtime_machine_memory_proof.rb --verify-fixtures
ruby igniter-lang/experiments/runtime_machine_memory_proof/packet_builder_check.rb
ruby igniter-lang/experiments/runtime_machine_memory_proof/sidecar_builder_profiles.rb
ruby igniter-lang/experiments/runtime_machine_memory_proof/external_candidate_normalizer.rb
ruby igniter-lang/experiments/runtime_machine_memory_proof/ffi_ruby_receipt_fixtures.rb
ruby igniter-lang/experiments/parser/igniter_lang_parser.rb igniter-lang/source/add.ig
ruby igniter-lang/experiments/parser/igniter_lang_parser.rb igniter-lang/source/availability_projection.ig
```

As of this checkpoint, `polymorphic_add.ig` should not be added to parser
acceptance as a passing fixture until `polymorphic-add-parser-acceptance-v0`
lands.
