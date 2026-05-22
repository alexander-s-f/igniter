# Track: Internal Profile Assembly Next Carrier Design v0

Card: LANG-R135-D1
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Route: UPDATE
Depends on: LANG-R134-H1, LANG-R133-I1
Track: `internal-profile-assembly-next-carrier-design-v0`
Status: done
Date: 2026-05-22

---

## Goal

Design the next internal carrier boundary after
`IgniterLang::InternalProfileAssembly` closure, without connecting to the
current compiler pipeline.

This is design-only. It does not authorize implementation.

Affected neighbor roles:

- `[Igniter-Lang Research Agent]` — owns any next proof-only carrier fixture or
  regression matrix.
- `[Igniter-Lang Bridge Agent]` — must review before public API/CLI,
  loader/report, CompatibilityReport, `.igapp`, runtime, or production carriers
  open.
- `[Igniter-Lang Meta Expert]` — may route scoreboard/spec-lag notes if this
  line becomes a round planning item.

---

## Evidence Read

- `docs/tracks/internal-profile-assembly-boundary-proof-maintenance-v0.md`
  (LANG-R134-H1)
- `docs/tracks/internal-profile-assembly-boundary-implementation-v0.md`
  (LANG-R133-I1)
- `docs/tracks/internal-profile-assembly-boundary-design-v0.md`
  (LANG-R130-D1)
- `docs/tracks/internal-profile-assembly-source-packet-implementation-v0.md`
  (LANG-R129-I1)
- `docs/dev/compiler-profile-architecture-direction.md`
- `docs/tracks/compiler-pack-boundary-report-v0.md`
- `docs/tracks/oof-fragment-registry-compiler-profile-source-input-proof-v0.md`

No commands beyond read/status checks were needed. No code was edited.

---

## Current Fixed Point

R134 resolved the R131/R133 proof conflict. The current accepted local state is:

```text
InternalProfileAssemblySourcePacket
  -> InternalProfileAssembly.assemble(...)
  -> internal_profile_assembly_result
```

The result is:

- internal-only;
- direct-require-only;
- not root-required;
- not consumed by parser/classifier/TypeChecker/SemanticIR/assembler/
  orchestrator;
- not persisted;
- not a public API/CLI carrier;
- not loader/report or CompatibilityReport evidence;
- not `.igapp` or manifest identity;
- not PROP-036 finalization;
- not PROP-038 validator/report behavior;
- not runtime or production readiness.

R134 proof maintenance records the full R132/R133 matrix as PASS.

---

## Carrier Options

| Option | Meaning | Verdict |
| --- | --- | --- |
| Internal profile assembly hold | Stop after R134 and leave `internal_profile_assembly_result` as an internal proof/implementation island. | Safe fallback, but leaves the profile-pack migration line without a named next design step. |
| Internal compiler-pack/profile migration design | Use `internal_profile_assembly_result` as evidence for a no-code carrier map that designs future profile assembly output, pack selection, and migration checkpoints. | Recommended next. |
| Bridge pressure first | Ask Bridge to pressure public/report/loader/CompatibilityReport carriers before any more internal design. | Not first; premature while no internal carrier semantics are stable. Required before crossing external surfaces. |
| Docs/spec sync only | Update spec chapters to mention internal profile assembly. | Not recommended now; this is internal compiler architecture, not language semantics or public runtime behavior. |

Decision:

```text
Next movement should be internal compiler-pack/profile migration design.
Live carrier hold remains in force.
Bridge pressure is required before any external carrier opens.
Docs/spec sync is not needed for this internal-only result yet.
```

---

## Recommended Next Route

Recommended next track:

```text
internal-profile-assembly-carrier-map-v0
```

Route type:

```text
design-only / no-code
```

Purpose:

```text
Define a future internal carrier model that can reference
internal_profile_assembly_result without connecting to the current compiler
pipeline.
```

Candidate model name, design-only:

```text
internal_profile_assembly_carrier_map
```

The carrier map should be a document/proof model, not a new library class by
default. If a later implementation card opens, it must name exact write scope
and prove no root require or pipeline usage.

---

## What May Consume `internal_profile_assembly_result`

Current allowed consumers:

| Consumer | Allowed now? | Rule |
| --- | --- | --- |
| Existing R133 proof harness | Yes | Direct proof output only. |
| R134 maintained R131 proof | Yes | Only as local proof evidence after maintenance. |
| Track docs / design docs | Yes | May cite result shape and digests as evidence. |
| New proof-only carrier map experiment | Yes, if assigned | Must live under `experiments/**`, direct-require only, no compiler/pipeline use. |
| Internal migration design packet | Yes, as docs | May classify candidate consumers and blockers. |

Not allowed current consumers:

| Consumer | Status |
| --- | --- |
| `lib/igniter_lang.rb` root require | Closed. |
| `IgniterLang.compile` / Ruby facade | Closed. |
| CLI | Closed. |
| Parser/classifier/TypeChecker/SemanticIR/assembler/orchestrator | Closed. |
| `CompilationReport`, `CompilerResult`, or diagnostics centralization | Closed. |
| Loader/report or CompatibilityReport | Closed. |
| `.igapp`, `.ilk`, manifest, sidecar, or golden output | Closed. |
| PROP-036 manifest identity or source contract behavior | Closed. |
| PROP-038 validator/report/strict-refusal behavior | Closed. |
| RuntimeMachine, Gate 3, Ledger/TBackend, cache, signing, production, Spark | Closed. |

Interpretation:

```text
internal_profile_assembly_result may be consumed as evidence by docs and
proof-only harnesses. It may not become a live compiler input, public field,
artifact field, report field, or runtime signal without separate gates.
```

---

## Candidate Internal Carrier Map Shape

A future design/proof-only carrier map may describe:

```json
{
  "kind": "internal_profile_assembly_carrier_map",
  "format_version": "0.1.0",
  "source_result_kind": "internal_profile_assembly_result",
  "source_result_lifecycle_state": "finalized_internal",
  "candidate_consumers": [],
  "blocked_consumers": [],
  "pack_boundary_refs": [],
  "oof_fragment_registry_refs": [],
  "required_parity_proofs": [],
  "bridge_review_required_before": [],
  "closed_surface_assertions": {}
}
```

Rules:

- It is a map, not an installed profile.
- It is not a `CompilerProfile`.
- It is not `compiler_profile_id`.
- It is not a `.igapp` manifest field.
- It is not a `CompilationReport` field.
- It is not a loader/report or CompatibilityReport input.
- It is not runtime readiness.

Its job would be to name, compare, and block candidate future consumers before
any implementation card exists.

---

## Boundary Between Assembly Result And Future Profile

| Concept | Current status | Future pressure |
| --- | --- | --- |
| `InternalProfileAssemblySourcePacket` | Internal implementation object; direct require only. | Could remain as constructor/test seam for profile assembly proofs. |
| `internal_profile_assembly_result` | Internal validation result; not persisted or public. | Can seed a carrier map and migration design. |
| `internal_profile_assembly_carrier_map` | Proposed design/proof model only. | Could enumerate candidate profile/pack consumers and blockers. |
| `CompilerProfile` | Directional architecture concept; no migration authorized. | Needs separate design/proof before implementation. |
| `compiler_profile_id` | PROP-036 manifest identity field with bounded implementation history. | Must not be derived from internal assembly result without PROP-036 authority. |
| `compiler_profile_contract` | PROP-038 validation/report-only/strict-terminal line. | Must stay separate; internal assembly is not PROP-038 authority. |

---

## Blockers Before Any Surface Opens

| Surface | Blockers before opening |
| --- | --- |
| Root require | Explicit implementation authorization; proof that root require does not expose public API/CLI; load-order test; no automatic pipeline invocation. |
| Compiler pipeline | Pack migration design accepted; pass-boundary adapter design; byte-for-byte parser/classifier/typechecker/SemanticIR/assembler golden parity; OOF/fragment registry parity; no dispatch migration without gate. |
| Public API/CLI | Bridge review; caller-facing source contract; public error/status wording; no accidental strict source; public key-set proof; backwards behavior proof. |
| Loader/report | Bridge review; report field ownership; nested vs top-level diagnostics decision; CompatibilityReport separation; refusal/status vocabulary design. |
| `.igapp` / manifest | PROP-036 alignment; assembler authority; artifact hash ordering proof; golden mutation authorization; manifest schema/version policy. |
| PROP-036 | Explicit PROP-036 addendum/errata or gate; no mutation of `compiler_profile_id` source or manifest identity from internal assembly alone. |
| PROP-038 | Explicit PROP-038 addendum/errata or gate; no mutation of validator diagnostics, report-only behavior, strict terminal behavior, or refusal authority. |
| Runtime / Gate 3 | Runtime authority gate; CompatibilityReport/load guard design; no compiler metadata treated as executable capability. |
| Production | Deployment/safety review; signing/cache/Ledger/TBackend decisions; proof that internal profile assembly is not production readiness. |
| Spark | Separate applied-pressure/bridge route; Spark material remains pressure only, not compiler authority. |

---

## Required Proof Before Implementation Review Later

Before any live carrier implementation review, require a proof matrix that shows:

- current R132/R133/R134 matrix remains PASS;
- new carrier map is deterministic;
- carrier map cannot be mistaken for `CompilerProfile`, `compiler_profile_id`,
  `.igapp`, report, or runtime readiness;
- no root require from `lib/igniter_lang.rb`;
- no references from parser/classifier/TypeChecker/SemanticIR/assembler/
  orchestrator;
- no public API/CLI key-set changes;
- no `.igapp`, manifest, sidecar, golden, report, or CompatibilityReport
  mutation;
- no PROP-036 or PROP-038 behavior mutation;
- no runtime/production/Spark behavior.

If a future card proposes a live library carrier, add:

- exact write scope;
- direct-require-only proof;
- invalid-result/non-finalized-result rejection cases;
- pack-selection conflict cases;
- public/report/runtime closed-surface assertions.

---

## Spec-Lag Disposition

No spec sync is recommended from this slice.

Reason:

- `internal_profile_assembly_result` is an internal compiler architecture
  proof/implementation boundary;
- it does not change source syntax, TypeChecker semantics, SemanticIR,
  assembler artifacts, `.igapp`, runtime load/evaluate behavior, or public API;
- Ch6 / CompilationReport spec-lag remains the broader R90 disposition, not a
  new R135 blocker.

If a future carrier touches `.igapp`, `CompilationReport`, public API/CLI, or
runtime readiness, open a separate spec-sync card after the relevant authority
gate.

---

## Recommendation

Recommended next route:

```text
internal compiler-pack/profile migration design
```

Concretely:

```text
Open a no-code `internal-profile-assembly-carrier-map-v0` design/proof card.
```

Do not open implementation review yet.

Do not open Bridge pressure first unless the next card proposes public/report/
loader/CompatibilityReport/`.igapp` carriers. Bridge pressure becomes mandatory
before any external carrier or runtime-facing evidence opens.

Hold all live consumers.

---

## Handoff

[D] `internal_profile_assembly_result` may be consumed only as internal evidence
by docs and proof-only harnesses today.

[S] The next useful movement is a no-code internal compiler-pack/profile
migration design, shaped as a carrier map. It should classify possible
consumers and blockers before any implementation card exists.

[T] No tests were run; this was a design-only track with no code changes.

[R] Recommend `internal-profile-assembly-carrier-map-v0` as the next route.
Implementation review later; Bridge pressure required before any external
carrier opens.

[Next] Architect can open the carrier-map design/proof card or hold the line at
R134 closure.
