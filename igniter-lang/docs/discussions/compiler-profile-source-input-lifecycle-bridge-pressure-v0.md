# Compiler Profile Source Input Lifecycle Bridge Pressure v0

Card: LANG-R127-X
Agent: `[Igniter-Lang Bridge Agent]`
Role: bridge-agent
Mode: discussion
Track: `compiler-profile-source-input-lifecycle-bridge-pressure-v0`
Route: UPDATE
Depends on: LANG-R126-D1, LANG-R125-P1
Status: complete
Date: 2026-05-21

---

## Question

Does the compiler-profile OOF/Fragment registry source-input lifecycle and owner
design leak a carrier into public API/CLI, loader/report, CompatibilityReport,
`.igapp`, PROP-036, PROP-038, compiler pipeline, runtime, production, or Spark
authority before any implementation review?

---

## Inputs Read

- `igniter-lang/roles/base-role.md`
- `igniter-lang/roles/bridge-agent.md`
- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/tracks/README.md`
- `igniter-lang/docs/tracks/oof-fragment-registry-compiler-profile-source-input-proof-v0.md`
  (LANG-R125-P1)
- `igniter-lang/docs/tracks/compiler-profile-source-input-lifecycle-owner-design-v0.md`
  (LANG-R126-D1)
- `igniter-lang/docs/tracks/oof-fragment-registry-compiler-profile-source-input-design-v0.md`
  (LANG-R124-D1, supporting context)

No code, package, compiler, runtime, report, `.igapp`, fixture, or package docs
were edited.

---

## Verdict

```text
proceed-with-nonblockers
```

R126 is safe to proceed to Architect implementation review as a design/owner
packet. It keeps the carrier internal-only, does not open public/report/runtime
surfaces, and does not authorize implementation.

No blocker amendments are required.

Two non-blocking wording amendments are recommended to prevent future readers
from confusing this internal packet with public compiler-profile source input or
PROP-036 profile identity/finalization.

---

## Source Evidence Summary

R125 proves a proof-only packet:

```text
compiler_profile_oof_registry_source_input
  -> profile_candidate helper envelope
  -> pack_descriptor_candidate helper envelopes
  -> IgniterLang::OOFFragmentRegistry#validate_source_envelope
```

R125 result:

```text
PASS
cases: 9/9
checks: 6/6
recommendation: SOURCE_INPUT_MODEL_ACCEPTED
```

R126 chooses the target owner model:

```text
hybrid profile assembly owner
```

Meaning:

- CompilerPack descriptor finalization owns row provenance and individual pack
  row claims.
- CompilerProfile candidate finalization owns selected pack set, pack order, and
  aggregate conflict policy.
- Hybrid profile assembly owns the source-input packet that binds those two
  authorities together.

Current lifecycle remains:

```text
proof_only
```

Current carrier remains:

```text
proof fixture / internal model only
```

---

## Bridge Pressure Matrix

| Surface | Pressure result | Verdict |
| --- | --- | --- |
| Internal constructor/test seam carrier | R126 recommends internal constructor/test seam only for any first implementation carrier. The packet stays outside current compiler passes. | PASS |
| Public API / CLI source input | R126 closes Ruby facade, CLI, config, docs/API, path loading, and caller-facing source shape. | PASS |
| Loader/report carrier | R126 closes loader/report and states the packet is not a report/status vocabulary carrier. | PASS |
| CompatibilityReport evidence | R126 closes CompatibilityReport and blocks the packet from becoming readiness or report evidence. | PASS |
| `.igapp` / manifest mutation | R126 closes `.igapp`, `.ilk`, manifest, sidecar, and golden mutation. | PASS |
| PROP-036 profile identity | R126 keeps source input separate from `compiler_profile_id`, manifest identity, loader status, discovery/defaulting/finalization, and profile identity mutation. | PASS with NB-2 wording improvement |
| PROP-038 validator/report/refusal | R126 closes validator/report/refusal behavior changes and does not use source input as PROP-038 authority. | PASS |
| Parser/classifier/TypeChecker/SemanticIR/assembler/orchestrator usage | R126 rejects before-compile, after-SemanticIR, before-assembly, and current orchestrator boundaries. It recommends profile assembly only. | PASS |
| Runtime / production / Spark authority | R126 closes runtime, production, Spark, Ledger/TBackend, Gate 3, cache, and signing. | PASS |

---

## Hybrid Profile Assembly Owner Review

The hybrid owner model is bridge-safe because it separates three jobs:

| Owner | Owns | Must not own |
| --- | --- | --- |
| CompilerPack descriptor finalization | Row provenance, row ownership, pack-local OOF/fragment/support claims. | Profile selection, public loading, compiler dispatch, runtime authority. |
| CompilerProfile candidate finalization | Selected pack set, pack order, aggregate conflict policy. | Pack row provenance override, `compiler_profile_id`, public identity, manifest mutation. |
| Hybrid profile assembly | Internal source-input packet, mapping to helper envelopes, internal validation result. | Public/API carrier, report carrier, CompatibilityReport evidence, `.igapp`, runtime behavior. |

This matches the R118/R125 evidence chain. It avoids profile-only authority
hiding pack row provenance and avoids pack-only authority omitting profile
selection/order.

Bridge pressure: the owner model should continue to say "profile assembly" and
"internal packet" rather than "compiler input" in public-facing contexts. NB-1
captures this naming caution.

---

## Carrier Boundary Review

### Internal Constructor/Test Seam Only

PASS.

R126 names the first implementation carrier as:

```text
internal constructor/test seam only
```

It also keeps the current state as `proof_only`, with `implementation_candidate`
and `finalized_internal` requiring later Architect gates.

### No Public API / CLI Source Input

PASS.

R126 explicitly closes:

- public API / Ruby facade;
- CLI;
- docs/API source shape;
- path loading/parsing/discovery;
- public error semantics.

### No Loader / Report Carrier

PASS.

R126 says loader/report carriers are closed and would require Bridge-reviewed
report/status vocabulary before movement.

### No CompatibilityReport Evidence

PASS.

R126 says CompatibilityReport is closed because otherwise source-input
validation could become report/readiness evidence.

### No `.igapp` / Manifest Mutation

PASS.

R126 rejects before-assembly and `.igapp`/manifest carriers, specifically to
avoid artifact identity and PROP-036 collisions.

### No PROP-036 Mutation

PASS.

The design does not derive or mutate `compiler_profile_id`, does not introduce
profile identity, and does not open loader status. NB-2 recommends making the
word `finalized_internal` visibly distinct from PROP-036 finalization.

### No PROP-038 Mutation

PASS.

R125 and R126 do not alter `CompilerProfileContractValidator`, report-only
integration, strict refusal, or `compiler_profile_contract_validation`.

### No Compiler Pipeline Usage

PASS.

R126 rejects:

- before compile;
- after SemanticIR;
- before assembly;
- current compiler orchestrator.

The only recommended boundary is:

```text
profile assembly only
```

outside parser/classifier/TypeChecker/SemanticIR/assembler/orchestrator paths.

### No Runtime / Production / Spark Authority

PASS.

R126 keeps runtime, production, Spark, Ledger/TBackend, Gate 3, cache, and
signing closed.

---

## Blockers

```text
none
```

No exact blocker amendments are required before Architect implementation review.

---

## Non-Blocking Wording Amendments

### NB-1: Avoid "source input" as public-facing shorthand

The packet name `compiler_profile_oof_registry_source_input` is accurate inside
the proof chain, but "source input" has public API/CLI gravity because PROP-036
already has bounded profile-source transport history.

Suggested wording for implementation review:

```text
Use "internal profile-assembly source packet" when discussing carrier scope.
Reserve "source input" for the exact proof packet name or internal API only.
```

This is non-blocking because R126 explicitly closes public API/CLI.

### NB-2: Clarify `finalized_internal` is not PROP-036 finalization

R126 lifecycle includes:

```text
finalized_internal
```

That is safe in context, but future readers could confuse it with PROP-036
`compiler_profile_id_source` finalization or public profile identity.

Suggested wording:

```text
finalized_internal = internal profile-assembly object accepted by a future
implementation gate; it is not `compiler_profile_id_source`, does not produce
`compiler_profile_id`, and is not manifest/profile identity finalization.
```

This is non-blocking because R126 already states no PROP-036 mutation.

---

## Exact Blockers Or Non-Blocking Amendments

Blockers:

```text
none
```

Non-blocking amendments:

```text
NB-1: Prefer "internal profile-assembly source packet" for carrier-scope wording.
NB-2: Define `finalized_internal` as non-PROP-036, non-manifest, non-identity
      internal assembly state.
```

---

## [Agree]

- R125 proves the proof-only packet-to-helper mapping without compiler/public/
  report/runtime changes.
- R126's hybrid owner model is the right target: pack rows own provenance,
  profile candidate owns selection/order/conflict, hybrid assembly binds them.
- Carrier stance is correctly internal constructor/test seam only.
- Loader/report, CompatibilityReport, `.igapp`, PROP-036, PROP-038, compiler
  pipeline, runtime, production, and Spark surfaces remain closed.

## [Challenge]

- The phrase "source input" should be carefully scoped because it can sound like
  public API/CLI input.
- `finalized_internal` should be defined as an internal assembly lifecycle state,
  not profile identity finalization.

## [Missing]

- No bridge blocker is missing.
- A future implementation review still needs exact write scope, internal API
  shape, proof matrix, and explicit closed-surface assertions.

## [Sharper Question]

What is the smallest internal profile-assembly constructor/test seam that can
carry the R125 packet while proving the current compiler pipeline and all public
carriers remain untouched?

## [Route]

```text
review
```

Proceed to Architect implementation review with NB-1/NB-2 as non-blocking
wording amendments. Do not implement and do not open public/API, report,
CompatibilityReport, `.igapp`, PROP-036, PROP-038, compiler-pipeline, runtime,
production, or Spark carriers from this discussion.
