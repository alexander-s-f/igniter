# Track: Compiler Pack/Profile Migration Checkpoint Design v0

Card: LANG-R137-D1
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Route: UPDATE
Depends on: LANG-R136-P1, LANG-R135-D1
Track: `compiler-pack-profile-migration-checkpoint-design-v0`
Status: done
Date: 2026-05-22

---

## Goal

Design migration checkpoints for moving from internal profile assembly evidence
toward future compiler-pack/profile migration, without opening any live carrier.

This is design-only. It does not authorize code, root require, compiler
pipeline usage, public/report carriers, `.igapp` mutation, PROP-036/PROP-038
behavior changes, runtime, production, or Spark behavior.

Affected neighbor roles:

- `[Igniter-Lang Research Agent]` — owns proof-only carrier maps and parity
  harnesses if a later card requests them.
- `[Igniter-Lang Bridge Agent]` — must review before any public API/CLI,
  loader/report, CompatibilityReport, `.igapp`, runtime, production, or Spark
  carrier opens.
- `[Igniter-Lang Meta Expert]` — may route this as a planning/checkpoint map,
  not as implementation authorization.

---

## Evidence Read

- `docs/tracks/internal-profile-assembly-carrier-map-v0.md` (LANG-R136-P1)
- `docs/tracks/internal-profile-assembly-next-carrier-design-v0.md`
  (LANG-R135-D1)
- `docs/tracks/internal-profile-assembly-boundary-proof-maintenance-v0.md`
  (LANG-R134-H1)
- `docs/dev/compiler-profile-architecture-direction.md`
- `docs/tracks/compiler-pack-boundary-report-v0.md`

No code was edited. No test/proof commands were required for this design-only
slice.

---

## Current Fixed Point

The current internal evidence chain is:

```text
InternalProfileAssemblySourcePacket
  -> InternalProfileAssembly.assemble(...)
  -> internal_profile_assembly_result
  -> internal_profile_assembly_carrier_map
```

Current accepted meaning:

- `internal_profile_assembly_result` is internal validation evidence only.
- `internal_profile_assembly_carrier_map` is proof-local/design-only
  classification evidence only.
- Neither artifact is `CompilerProfile`, `compiler_profile_id`,
  `compiler_profile_contract`, `.igapp`, `CompilationReport`, loader/report,
  CompatibilityReport, runtime readiness, or production readiness.
- No live carrier is open.

---

## Checkpoint Sequence

Recommended migration sequence before any compiler pipeline integration:

| Checkpoint | Name | Purpose | Exit condition | Current status |
| --- | --- | --- | --- | --- |
| CP0 | Internal evidence checkpoint | Keep R132/R133/R134 implementation/proof chain and R136 carrier map green. | Existing matrix and carrier anti-confusion checks PASS. | Satisfied as evidence, not migration authority. |
| CP1 | Profile/pack migration design checkpoint | Define future `CompilerProfile` / pack assembly responsibilities, adapter seams, and non-authority boundaries. | Design accepted by Architect; live carriers still closed. | Next recommended movement. |
| CP2 | Bridge pressure checkpoint | Pressure external carriers before public/report/loader/CompatibilityReport/`.igapp` surfaces move. | Bridge track says which external surfaces remain closed, can be designed, or need rejection. | Required before external carrier work. |
| CP3 | Implementation authorization checkpoint | Open only one named internal surface with exact write scope and exclusions. | Gate names file scope, API shape, proof matrix, and forbidden surfaces. | Not open. |
| CP4 | Parity/regression checkpoint | Prove no semantic drift from current compiler/proof outputs. | Byte-for-byte or explicitly accepted deltas across parser/classifier/typechecker/SemanticIR/assembler/report/goldens. | Not open. |

Sequence rule:

```text
CP0 -> CP1 -> CP2 when external surface pressure appears -> CP3 -> CP4
```

No checkpoint may be skipped to open root require, compiler pipeline use,
public API/CLI, loader/report, CompatibilityReport, `.igapp`, runtime, or
production behavior.

---

## Checkpoint Details

### CP0 — Internal Evidence Checkpoint

Required evidence:

- R132/R133/R134 matrix PASS;
- `InternalProfileAssembly` remains direct-require-only;
- root require remains closed;
- compiler pipeline files do not reference the packet, assembly object, result,
  or carrier map;
- R136 carrier map anti-confusion assertions remain false;
- no external surface consumes `internal_profile_assembly_result`.

CP0 permits:

- docs references;
- proof-local JSON maps;
- design-only migration maps.

CP0 does not permit:

- root require;
- new live lib carrier;
- compiler adapter;
- public/report/artifact/runtime carrier.

### CP1 — Profile/Pack Migration Design Checkpoint

Purpose:

```text
Design how future profile-assembled compiler concepts relate to current proof
compiler boundaries without changing current compiler behavior.
```

Required design outputs before implementation:

- define candidate `CompilerProfile` responsibilities;
- define candidate `CompilerPack` / pack descriptor responsibilities;
- define whether an internal adapter is a pure projection, validation wrapper,
  or pack assembly accumulator;
- define pass-boundary ownership for parser, classifier, TypeChecker,
  SemanticIR, assembler, OOF registry, and fragment registry;
- define migration order and rollback/hold points;
- state how PROP-036 `compiler_profile_id` remains separate;
- state how PROP-038 validation/report-only/strict-terminal behavior remains
  separate.

CP1 permits:

- no-code design tracks;
- proof-only migration maps;
- pre-authorization adapter shape sketches.

CP1 does not permit:

- implementation;
- root require;
- public/report/artifact/runtime carriers.

### CP2 — Bridge Pressure Checkpoint

Trigger:

```text
Any proposal to expose profile assembly evidence outside internal proof/design
surfaces.
```

Bridge pressure must answer:

- whether callers need a public API/CLI carrier at all;
- whether loader/report or CompatibilityReport should see compiler-profile
  assembly evidence;
- whether `.igapp` or manifest identity should be affected;
- whether public wording can avoid confusing internal validation with runtime
  readiness;
- whether Spark or production pressure is in scope or explicitly rejected.

CP2 permits:

- Bridge review/pressure docs;
- public-surface blocker lists.

CP2 does not permit:

- implementing those public/report/artifact/runtime surfaces.

### CP3 — Implementation Authorization Checkpoint

Any implementation card must name exactly one surface.

Minimum gate content:

- exact file write scope;
- constructor/result shape;
- direct-require/root-require policy;
- whether the surface is proof-only, internal live, public, report, artifact,
  or runtime-facing;
- required negative cases;
- required regression matrix;
- explicit closed surfaces.

Default recommendation for first possible implementation:

```text
direct-require-only internal adapter, if and only if CP1 accepts an adapter
shape and CP0 remains green.
```

Even that first adapter must not connect to the compiler pipeline.

### CP4 — Parity/Regression Checkpoint

Required before any compiler pipeline adapter:

- parser goldens unchanged or accepted deltas;
- classifier goldens unchanged or accepted deltas;
- typechecker goldens unchanged or accepted deltas;
- SemanticIR and CompilationReport goldens unchanged or accepted deltas;
- `.igapp` assembler proof unchanged or accepted deltas;
- OOF/Fragment registry parity with current hardcoded behavior;
- PROP-036 profile-source/manifest identity behavior unchanged unless
  separately authorized;
- PROP-038 report-only and strict terminal behavior unchanged unless
  separately authorized;
- public result key set unchanged unless separately authorized.

CP4 must run after CP3 implementation, not before, because parity proves the
actual implementation did not drift.

---

## Preconditions Before Specific Surfaces

| Surface | May consider only after | Additional preconditions |
| --- | --- | --- |
| Root require | CP3 | Explicit root-require authorization; load-order proof; public API/CLI remains unchanged; no automatic compile/pipeline invocation. |
| Internal adapter | CP1 + CP3 | Adapter shape accepted; exact write scope; direct-require-only default; invalid/non-finalized result rejection; no root require; no pipeline references. |
| Compiler pipeline adapter | CP1 + CP3 + CP4 | Pass-boundary adapter design; byte-for-byte or accepted golden deltas; OOF/fragment parity; no dispatch migration without specific authority. |
| Public API/CLI carrier | CP2 + CP3 + CP4 | Caller-facing contract; public wording; public result key-set proof; backwards behavior proof; no accidental strict source. |
| Loader/report carrier | CP2 + CP3 + CP4 | Report field ownership; nested/top-level diagnostics decision; loader/report status vocabulary; CompatibilityReport separation. |
| CompatibilityReport carrier | CP2 + CP3 + CP4 | Readiness semantics; load/evaluate boundary; runtime authority review; no compiler evidence treated as runtime capability. |
| `.igapp` / manifest carrier | CP2 + CP3 + CP4 | PROP-036 alignment; assembler authority; artifact hash ordering proof; manifest schema/version decision; golden mutation authorization. |
| PROP-036 behavior | CP2 + CP3 + CP4 | PROP-036 addendum/gate; no implicit derivation of `compiler_profile_id` from internal assembly evidence. |
| PROP-038 behavior | CP2 + CP3 + CP4 | PROP-038 addendum/gate; validator remains evidence unless strict-refusal authority explicitly changes. |
| Runtime / production / Spark | CP2 + separate authority | Runtime/Gate 3/production/Spark-specific review; internal compiler metadata remains non-executable by default. |

---

## Must Stay Closed

This track preserves closure for:

- code implementation;
- root require;
- compiler pipeline usage;
- parser/classifier/TypeChecker/SemanticIR/assembler/orchestrator changes;
- `CompilationReport`, `CompilerResult`, diagnostics, and CLI changes;
- public API/CLI;
- loader/report;
- CompatibilityReport;
- `.igapp`, `.ilk`, manifest, sidecar, and golden mutation;
- PROP-036 behavior mutation;
- PROP-038 behavior mutation;
- runtime, production, Spark, Ledger/TBackend, Gate 3, cache, signing, and
  deployment behavior.

---

## Recommended Next Route

Recommendation:

```text
proof/design next, implementation review later
```

Specific next card:

```text
compiler-pack-profile-migration-design-v0
```

Purpose:

```text
Perform CP1: define future CompilerProfile / CompilerPack / internal adapter
responsibilities and migration order without implementing anything.
```

Do not open Bridge pressure first unless the next planned surface is external
or report/artifact/runtime-facing. Bridge pressure is mandatory before those
surfaces, but internal migration design can proceed first.

Hold implementation review until CP1 produces an accepted adapter shape and
names whether implementation should remain direct-require-only.

---

## Handoff

[D] The next movement is checkpointed, not live-carrier migration. CP0 evidence
exists; CP1 profile/pack migration design is the next recommended step.

[S] Root require, internal adapter, compiler pipeline adapter, and public/report/
manifest carriers each require separate gates. Pipeline and external surfaces
also require Bridge and parity checkpoints before implementation.

[T] No tests were run; this was a design-only track with no code changes.

[R] Recommend `compiler-pack-profile-migration-design-v0` as the next route.
Hold live carriers and implementation review for now.

[Next] Architect can open CP1 migration design, request Bridge pressure if an
external carrier is desired, or hold at the R136 carrier-map checkpoint.
