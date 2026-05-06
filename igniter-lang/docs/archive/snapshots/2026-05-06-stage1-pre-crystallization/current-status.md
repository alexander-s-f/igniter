# Igniter-Lang Current Status

Status: fixed point
Date: 2026-05-06
Role: `[Igniter-Lang Research Agent]`
Track: `igniter-lang/igniter-lang-current-status-refresh-v0`
Supervisor: `[Architect Supervisor / Codex]`
Affected neighbors: `[Igniter-Lang Compiler/Grammar Expert]`, `[Igniter-Lang Bridge Agent]`, `[Igniter-Lang Applied Pressure Agent]`

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
source/polymorphic_add.ig
  -> experiments/parser/igniter_lang_parser.rb
  -> ParsedProgram JSON with parse_errors: []
```

This proves the PROP-014/015 source kernel plus the PROP-016 polymorphic
surface fixture are parseable. It does not prove classification, typechecking,
trait coherence, monomorphization, lowering, or `.igapp` equivalence.

[S] `.igapp` devkit fixtures exist for:

```text
fixtures/add.igapp/
fixtures/availability_projection.igapp/
fixtures/polymorphic_add.igapp/
```

These are compiler acceptance targets, not proof of a full compiler frontend.
`polymorphic_add.igapp` is already monomorphic at the loadable contract layer:
it contains `Add[Integer]` and `Add[Float]` only, with the generic `Add`
template preserved as inspection metadata.

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
The replacement image checker now covers P-1..P-10, including
`migration_chain: []`, no `supersedes` link, and `OOF-MR3` wrong-fingerprint
blocking. It does not prove a general migration DSL or TBackend history rewrite.

[S] PROP-016 now has an executable devkit chain:

```text
polymorphic_add.ig
  -> ParsedProgram
  -> classifier/type proof
  -> SemanticIR emission proof
  -> polymorphic_add.igapp
```

The chain proves `Add[Integer]` and `Add[Float]` acceptance, `Add[String]`
rejection before SemanticIR, no type variables in emitted ContractIRs, no
unresolved trait calls, and no generic loadable `Add` contract.

[S] `polymorphic_add.igapp` has now been probed at the RuntimeMachine load
boundary:

```text
CompiledProgram.load_igapp -> ok
RuntimeMachine.load_program -> blocked by descriptor-ref shape drift
direct evaluate -> blocked by missing stdlib.numeric.add operator support
```

This is a useful blocker, not a conceptual failure. The fixture preserves the
core invariant: only `Add[Integer]` and `Add[Float]` are executable, while
generic `Add` remains metadata-only.

[S] Spark technician availability now has an executable synthetic fixture:

```text
TenantScope
  + ScopedFactRead
  + StepObservation / PipelineTrace
  + AvailabilityProjection
  + AvailabilitySnapshot
  -> positive 4 available / 3 blocked slots
  -> blocked negative cases with no trusted snapshot
```

Negative cases cover wrong tenant, invalid time window, inactive technician,
and schedule status mismatch.

[S] Spark pipeline grammar is specified as source-surface pressure:

```text
pipeline / step / scoped_by / cardinality / tenant_free
  -> Result.flat_map + StepObservation
  -> ScopedTBackendReadNode
```

It remains grammar/semantic specification until parser/classifier proof lands.

[S] Schema migration bridge profile is ready for package work. It keeps
single-hop migration evidence report-only and preserves P-1..P-10, including
`migration_chain: []`, no `supersedes`, and blocked `OOF-MR3`.

---

## Parser-Accepted Pressure Fixtures

[S] `source/polymorphic_add.ig` is now parser-accepted and still semantic
pressure only.

It pins the desired PROP-016 surface:

```text
trait Additive[T]
impl Additive[Integer]
impl Additive[Float]
contract_shape AddShape[T]
contract Add[T: Additive] implements AddShape[T]
```

Current status:

- `polymorphic_add.ig` parses with `parse_errors: []`.
- `polymorphic_add.parsed_program.expected.json` is the accepted ParsedProgram
  target.
- output uses `grammar_version: polymorphic-v0`.
- monomorphization, trait coherence, impl resolution, and implements checks
  belong to classification/type/IR work, not parser work.

[S] General migration execution remains pressure-only. The current migration
fixture proves one toy identity replacement image and checker safety; it does
not execute a general `MigrationDecl`, rewrite TBackend history, or settle
multi-hop migration semantics.

[S] External/package candidate equivalence is pressure-only. `selected_profile`
candidate artifacts can pass the checker, but normalized-equivalence rules for
real package-derived packets are not defined yet.

[S] Spark CRM is now the main applied pressure lane. Current pressure/foundation
tracks define technician availability, tenant scope, fail-fast pipelines,
why-not reasons, and candidate fixtures without using real customer data,
endpoints, tokens, or provider payloads.

[S] The second Spark operational pressure target is now lead-signal boundary:
normalized lead signals, deterministic idempotency, exact Decimal bid totals,
hourly rollup, duplicate suppression, retention receipts, and late closed
boundary handling.

---

## Currently Open

Critical:

- no complete parser -> classifier -> typechecker -> SemanticIR compiler path
- no parsed-source-to-`.igapp` surface checker yet
- `polymorphic_add.igapp` RuntimeMachine load is blocked by known loader /
  operator-table gaps, not by fixture shape
- no executable Spark lead-signal boundary fixture yet

High:

- normalized-equivalence profile for real external/FFI/package candidates
- ESCAPE capability algebra: delegation, overlap, revocation, serialization,
  and composition
- `.igapp` schema and artifact hash validator stricter than current fixtures
- replacement image multi-hop chain proof and TBackend preserve-set policy
- migration path selection: direct, shortest-path, or policy-selected
- package implementation of `SchemaCompatibilityDiagnostic` remains pending
- Spark pipeline grammar has no parser/classifier/SemanticIR proof yet
- Spark availability diagnostics bridge profile is not written yet
- Decimal / idempotency / retention / late-boundary semantics are pressure-only

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

## Next Recommended Tracks

1. `[Igniter-Lang Research Agent]`
   `polymorphic-add-runtime-loader-normalization-v0`

   Patch/prove descriptor-ref normalization, specialization manifest validation,
   metadata-only generic rejection, and `stdlib.numeric.add` runtime operator
   support.

2. `[Igniter-Lang Research Agent]`
   `spark-lead-signal-boundary-fixture-v0`

   Implement the second Spark operational fixture: normalized lead signals,
   idempotency, hourly rollup, exact Decimal totals, duplicate suppression,
   retention receipts, and late closed-boundary diagnostics.

3. `[Igniter-Lang Compiler/Grammar Expert]`
   `spark-pipeline-parser-acceptance-v0`

   Add parser acceptance for `pipeline`, `step`, `scoped_by`, `cardinality`,
   and `tenant_free` source examples after the executable availability fixture.

4. `[Igniter-Lang Bridge Agent]`
   `spark-availability-diagnostics-bridge-profile-v0`

   Map availability fixture observations to metadata-only diagnostics: tenant
   scope, scoped reads, cardinality, slot reason counts, failure steps, and
   redaction policy.

5. `[Package Agent / Companion+Store]`
   `igniter-contracts-schema-compatibility-diagnostic-v0`

   Now ready to assign as a large bounded package slice: report-only
   `SchemaCompatibilityDiagnostic` with optional single-hop
   `migration_profile`, no runtime migration execution.

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
ruby igniter-lang/experiments/polymorphic_add_classifier_proof/polymorphic_add_classifier_proof.rb
ruby igniter-lang/experiments/polymorphic_add_semanticir_emission_proof/polymorphic_add_semanticir_emission_proof.rb
ruby igniter-lang/experiments/polymorphic_add_runtime_load_boundary_proof/polymorphic_add_runtime_load_boundary_proof.rb
ruby igniter-lang/experiments/spark_technician_availability_fixture/spark_technician_availability_fixture.rb
ruby igniter-lang/experiments/parser/igniter_lang_parser.rb igniter-lang/source/add.ig
ruby igniter-lang/experiments/parser/igniter_lang_parser.rb igniter-lang/source/availability_projection.ig
ruby igniter-lang/experiments/parser/igniter_lang_parser.rb igniter-lang/source/polymorphic_add.ig
ruby igniter-lang/experiments/classifier_pass_proof/classifier_pass_proof.rb
ruby igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb
```

---

## Stage 1 Progress

_Maintained by `[Igniter-Lang Meta Expert]`. Updated in-place; do not create
new track documents for progress entries. See
`META-EXPERT-003-stage1-implementation-governance-v0.md` for policy._

```text
Stage 1 goal: source.ig → compiler → .igapp/ → RuntimeMachine trusted
```

### Scoreboard — 2026-05-06

```text
Pass                   PROP              Experiment                    Status
──────────────────────────────────────────────────────────────────────────────
Parser                 PROP-014/015      experiments/parser/           ✅ partial
                                         add.ig, availability.ig,       [gap] OOF
                                         polymorphic_add.ig → ok        rejection at
                                                                         parse time

Classifier             PROP-018/020      experiments/classifier_       ✅ PASS
(CORE/ESCAPE/OOF)                        pass_proof/
                                         add, claim_evidence,
                                         evidence_linked_alert,
                                         OOF negatives → all PASS

SemanticIR Emitter     PROP-019 +        experiments/source_to_        ✅ PASS
(canonical envelope)   PROP-019.1        semanticir_fixture/            ⚠️  needs
                       (errata)          add, claim_evidence,           PROP-019.1
                                         evidence_linked_alert → PASS   migration:
                                                                         oof_log →
                                                                         remove;
                                                                         negative
                                                                         fixtures →
                                                                         compilation_
                                                                         report.json
                                                                         only

TypeChecker            needed: narrow    no proof yet                  🟡 next
                       PROP (PROP-021    structural types: partial        proof
                       candidate)        trait resolution: missing
                                         monomorphization: missing
                                         lifecycle types: deferred

.igapp/ Assembler      PROP-012 +        no experiment yet             🔴 blocked
                       PROP-019.1                                        BLOCKED until
                       (A1-A6 criteria)                                  PROP-019.1
                                                                         migration
                                                                         complete

RuntimeMachine Load    PROP-011          experiments/runtime_          ✅ proven
                                         machine_memory_proof/
                                         load → evaluate →
                                         checkpoint → resume → trusted

Stdlib execution       PROP-013          no experiment yet             🔴 not started
                                         numeric.add, fold, map,
                                         filter, count, first,
                                         or_else missing
──────────────────────────────────────────────────────────────────────────────
STAGE 1 CLOSED:   NO
Blockers:         PROP-019.1 migration → TypeChecker proof → .igapp/ Assembler
                  Stdlib execution kernel
```

### PROP-019.1 Migration: "Do Not Start Assembler Before"

The `.igapp/` assembler experiment must NOT start until:

```text
1. source_to_semanticir_fixture golden files are migrated:
   - oof_log removed from SemanticIRProgram (top-level and ContractIR)
   - compilation_report_ref added to SemanticIRProgram
   - companion *.compilation_report.json created per fixture
   - negative case fixtures: *.semantic_ir.json removed;
     only *.compilation_report.json with pass_result: "oof" retained

2. source_to_semanticir_fixture.rb passes after migration.
   (Validates that the migrated golden files are internally consistent.)

3. stdlib.numeric.add → stdlib.integer.add resolved in golden SemanticIR.
   (Polymorphic operator names must be monomorphic before SemanticIR emission.)

Gate: source_to_semanticir_fixture.rb PASS on migrated golden files.
Then: proceed to igapp_assembler_proof.
```

### Revised Next 3 Slices

```text
Slice 0 (prerequisite — Research Agent):
  Migrate source_to_semanticir_fixture golden files to PROP-019.1 shape.
  - Remove oof_log from SemanticIRProgram fixtures.
  - Add compilation_report_ref.
  - Create *.compilation_report.json companions.
  - Rename negative fixtures: *.semantic_ir.json → *.compilation_report.json.
  - Re-run fixture.rb → PASS.
  Done: source_to_semanticir_fixture PASS on migrated golden files.

Slice A (.igapp/ Assembler — Research Agent):
  Implement experiments/igapp_assembler_proof/igapp_assembler_proof.rb.
  Input: CompilationReport + SemanticIRProgram (from migrated golden files).
  Output: .igapp/ directory per PROP-019.1 §Part 7 (A1..A6).
  Negative: assembler given pass_result: "oof" → refuses, exit != 0.
  Done: RuntimeMachine.load(assembled_add.igapp) → trusted CompatibilityReport.
  Prerequisite: Slice 0 complete.

Slice B (TypeChecker narrow — split ownership):
  [Compiler/Grammar Expert]: PROP-021 TypeChecker narrow spec.
    Scope: annotation-driven resolution, trait constraint check,
           monomorphization (Add[Integer], Add[Float]), OOF-P1 for
           unresolved overloads. Not full PROP-004 — narrow only.
  [Research Agent]: typechecker_proof.rb after PROP-021.
    Input: ClassifiedProgram JSON (from classifier golden files).
    Output: TypedProgram JSON with resolved types, no unresolved T.
    Negatives: Add[String] → OOF-TY1; unresolved overload → OOF-P1.
  Done: TypedProgram shape matches PROP-021 spec, all negatives blocked.
```

_Slice C (Stdlib execution) proceeds in parallel with Slice A/B.
Research Agent may start stdlib_execution_proof independently._
