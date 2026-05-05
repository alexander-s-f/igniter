# Igniter-Lang Current Status

Status: fixed point
Date: 2026-05-05
Supervisor: `[Architect Supervisor / Codex]`

---

## Compact State

Igniter-Lang has moved from pure theory into a small but executable devkit.
The current fixed point is:

```text
semantic theory
  -> CompiledProgram / SemanticIR artifact contract
  -> hand-authored .igapp fixtures
  -> RuntimeMachine memory proof
  -> golden packet artifacts
  -> structural checker
  -> sidecar profile modes for future bridge/package candidates
```

The language remains a separate ecosystem from Igniter platform packages. The
platform may consume selected concepts later, but package integration is not the
source of truth for the language.

---

## Current Center

[D] The center of the toolchain is `SemanticIR`, emitted as a
`CompiledProgram`.

```text
source
  -> parse
  -> classify CORE / ESCAPE / OOF
  -> typecheck
  -> SemanticIR
  -> CompiledProgram (.igapp, .igc.json, .igc.pack, native later)
  -> RuntimeMachine.load(...)
```

[D] Runtime semantics are owned by `RuntimeMachine`, not by the compiled
artifact:

```text
boot -> load -> evaluate -> checkpoint -> resume
```

`CompiledProgram` declares contracts, requirements, temporal semantics,
lifecycle, effects, FFI, and provenance anchors. `RuntimeMachine` verifies,
executes, emits observations, checkpoints, and resumes.

[D] `TBackend` is the temporal substrate for language runtime state. Igniter
Ledger can become one adapter, but Igniter-Lang does not depend on Ledger as
its core persistence model.

---

## What Is Now Proven

The standalone memory proof validates:

- boot/load/evaluate/checkpoint/resume/re-evaluate lifecycle
- trusted in-harness resume
- blocked empty-backend resume
- runtime drift downgrade
- contract drift block
- same-value-without-evidence is provisional, not trusted
- evidence links are required for meaning, not only value hashes

The proof now exports structural golden artifacts:

```text
fixtures/manifest.json
fixtures/obs_packets.golden.json
fixtures/semantic_image.golden.json
fixtures/compatibility_reports.golden.json
fixtures/negative_evidence.golden.json
fixtures/result_summary.golden.json
```

The checker validates packet identity, payload hashes, SemanticImage content,
CompatibilityReport decisions, negative evidence, and result summary shape.

The sidecar builder profiles define two candidate modes:

```text
full_log
  -> full proof regression with complete session packet logs

selected_profile
  -> smaller bridge-admission surface:
     selected packets + result hash + SemanticImage + CompatibilityReport
```

---

## Artifact Fixtures

Current hand-authored artifacts:

```text
igniter-lang/fixtures/add.igapp/
  -> CORE Add contract fixture

igniter-lang/fixtures/availability_projection.igapp/
  -> Spark CRM pressure fixture for temporal/window projection semantics
```

`CompiledProgram.load_igapp` exists in the experiment sidecar and can load these
artifact directories into the memory-proof model. This is still devkit code, not
the final compiler/runtime implementation.

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

The unique vector is not "another general-purpose language". It is:

```text
business meaning as typed, temporal, observable, evidence-linked computation
```

---

## Stable Invariants

- Time is a language dimension, not an ambient runtime clock.
- Observation is the unit of trust, not a raw function result.
- CORE/ESCAPE/OOF is a trust boundary and future trust calculus.
- SemanticImage is the cross-session continuity primitive.
- CompatibilityReport decides resume status: trusted, provisional, downgraded,
  or blocked.
- Equal value hashes are insufficient without evidence links.
- Native/LLVM is a later backend; it must still link or preserve RuntimeMachine
  semantics.
- Host-language calls enter through contractable FFI: typed, capability-gated,
  observable, and receipt/failure-producing.

---

## Open Gaps

Critical:

- no real parser/compiler frontend yet
- stdlib is not formally typed enough for v1
- fold/aggregate primitives are missing
- ESCAPE composition and capability delegation are under-specified

High:

- schema evolution and contract migration need a CompatibilityReport dimension
- FFI Ruby bridge needs a proof track
- `.igapp` schema and artifact hashing need a stricter validator

Medium:

- compensation/retry model for long-running effects
- privacy propagation through contract composition
- file-backed TBackend proof after memory proof remains stable

---

## Recommended Next Round

Give agents work from this fixed point:

1. Compiler/Grammar Expert:
   `PROP-013: Stdlib and Fold/Aggregate v0`

   Close the immediate expressiveness gap while preserving termination and
   explicit time.

2. Compiler/Grammar Expert:
   `PROP-014: Source Syntax to SemanticIR Boundary v0`

   Define minimal source syntax and parser boundary without overbuilding a
   compiler.

3. Research Agent:
   `runtime-machine-proof-external-candidate-adapter-v0`

   Define how an external bridge/package candidate maps into the
   `selected_profile` artifact contract.

4. Research Agent:
   `ffi-ruby-contractable-proof-v0`

   Prove Ruby host calls as ESCAPE contracts with capabilities, receipts,
   failures, lifecycle, and evidence links.

5. Later:
   `file-tbackend-proof-v0`

   Only after the memory proof and artifact fixtures remain stable.

---

## Verification Commands

Current fixed point was checked with:

```bash
ruby igniter-lang/experiments/runtime_machine_memory_proof/runtime_machine_memory_proof.rb
ruby igniter-lang/experiments/runtime_machine_memory_proof/runtime_machine_memory_proof.rb --verify-fixtures
ruby igniter-lang/experiments/runtime_machine_memory_proof/packet_builder_check.rb
ruby igniter-lang/experiments/runtime_machine_memory_proof/sidecar_builder_profiles.rb
ruby igniter-lang/experiments/runtime_machine_memory_proof/sidecar_builder_profiles.rb --profile-mode selected_profile --candidate /private/tmp/igniter_lang_sidecar_selected_check
```

All passed on 2026-05-05.
