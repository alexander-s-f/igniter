# Igniter-Lang Current Status

Status: fixed point
Date: 2026-05-05
Supervisor: `[Architect Supervisor / Codex]`

---

## Compact State

Igniter-Lang now has a stable theory-to-devkit spine:

```text
Epistemic Contract Language thesis
  -> SemanticIR / CompiledProgram artifact contract
  -> stdlib + bounded fold/aggregate model
  -> source syntax boundary + module grammar kernel
  -> source fixtures
  -> minimal parser to ParsedProgram JSON
  -> hand-authored .igapp fixtures
  -> RuntimeMachine memory proof
  -> golden packet artifacts
  -> external candidate selected_profile gate
  -> Ruby FFI contractable proof + receipt fixtures
```

The language remains a separate ecosystem from Igniter platform packages.
Igniter Ledger may become one TBackend adapter; it is not the language core.

---

## Current Center

[D] `SemanticIR` remains the stable center of the toolchain.

```text
.ig source
  -> ParsedProgram
  -> ClassifiedProgram
  -> TypedProgram
  -> SemanticIR
  -> CompiledProgram (.igapp, .igc.json, .igc.pack, native later)
  -> RuntimeMachine.load(...)
```

[D] Runtime semantics are owned by `RuntimeMachine`, not by parser output or
native backend code:

```text
boot -> load -> evaluate -> checkpoint -> resume
```

`CompiledProgram` declares contracts, requirements, temporal semantics,
lifecycle, effects, FFI, and provenance anchors. `RuntimeMachine` verifies,
executes, emits observations, checkpoints, and resumes.

---

## Newly Closed Since Previous Fixed Point

[S] `PROP-013` closes the bounded collection gap:

- `Collection[T]`, `Option[T]`, `Result[T, E]`
- `fold`, `map`, `filter`, `group_by`, `count`, `sum`, `avg`, `min`, `max`
- `now(ctx)` instead of ambient clocks
- `TR-1`: bounded collections make fold/map/filter CORE-terminating
- aggregate observations require `aggregated_from` evidence links

[S] `PROP-014` defines the minimal source-to-`SemanticIR` boundary:

- source forms for `Add` and `AvailabilityProjection`
- `ParsedProgram` JSON shape
- parse/classify/type/IR stage boundaries
- explicit OOF rejection rules
- `.igapp` fixtures as compiler acceptance targets

[S] `PROP-015` adds the minimum grammar/module layer:

- pure non-recursive `def` blocks
- structural `TypeDecl`
- one-file-one-module v0 module system
- explicit imports only
- full v0 BNF sufficient for the current fixture pair

[S] `runtime-model-spec-questions-v0.md` records language identity decisions:

- immutable bindings, not variables
- lexical scoping
- value semantics
- region-style evaluation memory
- semantic GC through TBackend lifecycle
- structural DAG parallelism
- staged self-hosting path

[S] External candidate admission is executable:

```text
external_candidate_fixture/raw_candidate.json
  -> external_candidate_normalizer.rb
  -> selected_profile candidate artifacts
  -> packet_builder_check.rb --profile-mode selected_profile
```

[S] Ruby FFI now has contractable proof and receipt/failure fixtures:

```text
FFIRequirement
  -> intent_observation
  -> CapabilityGate
  -> host call
  -> receipt_observation | failure_observation
```

The executable fixture set covers read success, write/audit success,
capability denied, and host error. It still needs normalized-equivalence rules
before package-derived FFI packets may differ from the golden fixture shape.

[S] The source parser harness has started:

```text
igniter-lang/experiments/parser/igniter_lang_parser.rb
  source/add.ig -> ParsedProgram JSON
  source/availability_projection.ig -> ParsedProgram JSON
```

This proves parse viability for the current source fixtures only. It does not
yet classify, typecheck, lower to `SemanticIR`, or compare to `.igapp`.

---

## Current Source And Artifact Fixtures

Source fixtures:

```text
igniter-lang/source/add.ig
igniter-lang/source/availability_projection.ig
```

Artifact fixtures:

```text
igniter-lang/fixtures/add.igapp/
igniter-lang/fixtures/availability_projection.igapp/
```

[D] These source files are acceptance targets for a future parser/compiler
frontend. They are not a final syntax promise beyond the v0 source boundary.

---

## What Is Executable

The standalone memory proof validates:

- boot/load/evaluate/checkpoint/resume/re-evaluate lifecycle
- trusted in-harness resume
- blocked empty-backend resume
- runtime drift downgrade
- contract drift block
- same-value-without-evidence is provisional, not trusted
- evidence links are required for meaning, not only value hashes

The packet checker validates:

- manifest hashes
- artifact headers
- ObsPacket identity
- SemanticImage content
- CompatibilityReport decisions
- negative evidence
- result summary

The external candidate normalizer validates a raw external candidate and emits
a `selected_profile` candidate directory that passes the checker.

The FFI receipt fixture checker validates descriptors, scenario packets,
required links, lifecycle expectations, capability denial before host call, and
host-error failure shape.

The parser experiment currently parses both source fixtures to `ParsedProgram`
JSON without parse errors.

---

## Positioning

The current public thesis:

```text
Igniter-Lang is an Epistemic Contract Language.

Every result is:
  a typed value
  evaluated at an explicit temporal horizon
  produced by a contract
  justified by observation evidence
  constrained by lifecycle, capability, and effect declarations
```

The unique vector is:

```text
business meaning as typed, temporal, observable, evidence-linked computation
```

---

## Stable Invariants

- Time is a language dimension, not an ambient runtime clock.
- Observation is the unit of trust, not a raw function result.
- Equal value hashes are insufficient without evidence links.
- CORE/ESCAPE/OOF is a trust boundary.
- CORE computation is finite, bounded, immutable, and structurally parallel.
- ESCAPE must be declared, capability-gated, and receipt/failure-producing.
- SemanticImage is the cross-session continuity primitive.
- CompatibilityReport decides resume status: trusted, provisional, downgraded,
  or blocked.
- Lifecycle belongs to language semantics; TBackend enforces retention.
- Native/LLVM is a later backend and must preserve RuntimeMachine semantics.

---

## Open Gaps

Critical:

- no real parser/compiler frontend yet
- parser exists only as a partial devkit; no fixture comparison/classification
  yet

High:

- normalized-equivalence checker profile for real external and FFI candidates
- schema evolution and contract migration need a CompatibilityReport dimension
- ESCAPE composition and capability delegation remain under-specified
- `.igapp` schema and artifact hashing need a stricter validator

Medium:

- compensation/retry model for long-running effects
- privacy propagation through contract composition
- file-backed TBackend proof after memory proof remains stable

Deferred:

- pattern matching, generics, traits
- native backend and self-hosting beyond the staged plan

---

## Recommended Next Round

1. Compiler/Grammar Expert:
   `source-fixture-parsed-surface-checker-v0`

   Compare parsed source surfaces for `source/add.ig` and
   `source/availability_projection.ig` against the existing `.igapp` contract
   and SemanticIR surfaces. This should still be devkit/proof work, not a full
   compiler.

2. Research Agent:
   `runtime-machine-ffi-ruby-intent-and-delegation-v0`

   Add explicit `intent_observation` and capability delegation semantics around
   the FFI receipt fixtures before any package adapter integration.

3. Compiler/Grammar Expert:
   `escape-capability-algebra-v0`

   Formalize ESCAPE composition, capability overlap, delegation, revocation, and
   resource serialization before package bridge work depends on it.

4. Later:
   `runtime-machine-normalized-equivalence-profile-v0`

   Define where external/package candidates may substitute refs or host
   descriptors while preserving result meaning, evidence links, SemanticImage
   rules, CompatibilityReport decisions, and FFI receipt/failure semantics.

5. Later:
   `contract-schema-evolution-v0`

   Add schema version/migration dimensions to CompatibilityReport.

6. Later:
   `file-tbackend-proof-v0`

   Only after memory proof, source fixtures, and FFI fixtures remain stable.

---

## Verification Commands

Current executable checks:

```bash
ruby igniter-lang/experiments/runtime_machine_memory_proof/runtime_machine_memory_proof.rb
ruby igniter-lang/experiments/runtime_machine_memory_proof/runtime_machine_memory_proof.rb --verify-fixtures
ruby igniter-lang/experiments/runtime_machine_memory_proof/packet_builder_check.rb
ruby igniter-lang/experiments/runtime_machine_memory_proof/sidecar_builder_profiles.rb
ruby igniter-lang/experiments/runtime_machine_memory_proof/sidecar_builder_profiles.rb --profile-mode selected_profile --candidate /private/tmp/igniter_lang_sidecar_selected_check
ruby igniter-lang/experiments/runtime_machine_memory_proof/external_candidate_normalizer.rb
ruby igniter-lang/experiments/runtime_machine_memory_proof/ffi_ruby_receipt_fixtures.rb
ruby igniter-lang/experiments/parser/igniter_lang_parser.rb igniter-lang/source/add.ig
ruby igniter-lang/experiments/parser/igniter_lang_parser.rb igniter-lang/source/availability_projection.ig
```

All passed on 2026-05-05 during Architect review.
