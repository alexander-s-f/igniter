# Track: Compiler Profile Source Input Lifecycle Owner Design v0

Card: LANG-R126-D1
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Route: UPDATE
Depends on: LANG-R125-P1, LANG-R124-D1
Track: `compiler-profile-source-input-lifecycle-owner-design-v0`
Status: done
Date: 2026-05-21

---

## Goal

Design lifecycle and ownership for
`compiler_profile_oof_registry_source_input` before any implementation or
compiler integration is considered.

This is design-only. It does not authorize implementation.

Affected neighbor roles:

- `[Igniter-Lang Research Agent]`: owns any lifecycle proof refinements.
- `[Igniter-Lang Bridge Agent]`: owns pressure before public/API, loader/report,
  CompatibilityReport, or `.igapp` carriers can move.
- `[Architect Supervisor / Codex]`: owns any future implementation gate.

---

## Evidence Read

- `docs/tracks/oof-fragment-registry-compiler-profile-source-input-design-v0.md`
  (LANG-R124-D1)
- `docs/tracks/oof-fragment-registry-compiler-profile-source-input-proof-v0.md`
  (LANG-R125-P1)
- `experiments/oof_fragment_registry_compiler_profile_source_input_proof/out/compiler_profile_oof_registry_source_input.packet.json`
- `experiments/oof_fragment_registry_compiler_profile_source_input_proof/out/oof_fragment_registry_compiler_profile_source_input_proof_summary.json`
- `lib/igniter_lang/oof_fragment_registry.rb`

No commands were run. No code was edited.

---

## Current Fixed Point

R125 proves:

```text
compiler_profile_oof_registry_source_input
  -> profile_candidate helper envelope
  -> pack_descriptor_candidate helper envelopes
  -> IgniterLang::OOFFragmentRegistry#validate_source_envelope
```

Proof result:

```text
PASS
cases: 9/9
checks: 6/6
recommendation: SOURCE_INPUT_MODEL_ACCEPTED
```

R125 does not implement compiler behavior. The packet is still proof-only data.

---

## Decision

Recommended owner model:

```text
hybrid profile assembly owner
```

Meaning:

```text
CompilerPack descriptor finalization
  owns row provenance and individual pack row claims.

CompilerProfile candidate finalization
  owns selected pack set, pack order, and aggregate conflict policy.

Hybrid profile assembly
  owns the source-input packet that binds those two authorities together.
```

Current live owner:

```text
none
```

Current lifecycle:

```text
proof_only
```

This design accepts a future ownership target but keeps implementation review
held. It does not make the packet a compiler pipeline input.

---

## Owner Options

| Candidate owner | Meaning | Strength | Risk | Decision |
| --- | --- | --- | --- | --- |
| CompilerProfile candidate finalization | Profile owns the whole packet and all derived registry source data. | Simple single owner for selected pack set and conflict policy. | Hides pack-row provenance if used alone. | Reject as sole owner. |
| CompilerPack descriptor finalization | Each pack owns its row claims and source envelope. | Precise row provenance and duplicate ownership checks. | Cannot decide selected pack set/order alone. | Reject as sole owner. |
| Explicit proof-only/no live owner | Packet remains only experiment data with no future owner selected. | Maximum caution. | Does not answer the next design question after R125. | Keep as current state, not target. |
| Hybrid profile assembly owner | Pack descriptors own rows; profile candidate owns selection/order/conflict; assembly packet binds them. | Matches R118/R125 semantics and preserves provenance. | Requires a future profile assembly boundary before implementation. | Recommend. |

---

## Lifecycle States

| State | Meaning | Allowed carrier | Authority | Exit condition |
| --- | --- | --- | --- | --- |
| `proof_only` | Experiment-local packet data used to prove mapping to helper envelopes. | Proof fixture files only. | Research proof evidence. | R125 already satisfies packet mapping; further movement needs design/Bridge review. |
| `design_accepted` | Architect accepts the owner/lifecycle design as a future target. | Track/proposal/design docs only. | Architect design gate. | Requires Bridge pressure before any external carrier, or implementation gate for internal-only work. |
| `implementation_candidate` | A future implementation card names exact write scope and accepted internal API shape. | Internal constructor/test seam only. | Architect implementation authorization. | Requires proof matrix and closed-surface assertions. |
| `finalized_internal` | Implemented internal source object or packet accepted as part of profile assembly only. | Internal profile assembly boundary only. | Future accepted implementation gate. | Still not public/report/runtime authority unless separate gates open those surfaces. |

Forbidden shortcut:

```text
proof_only -> finalized_internal
```

There must be at least one explicit design/authorization gate between proof data
and live internal implementation.

---

## Carrier Stance

Current and recommended first implementation carrier:

```text
internal constructor/test seam only
```

Closed carriers:

| Carrier | Status | Reason |
| --- | --- | --- |
| Public API / Ruby facade | Closed | Would widen caller-facing source shape and require docs/API authority. |
| CLI | Closed | Would imply path loading/parsing/discovery and public error semantics. |
| Loader/report | Closed | Would create report/status vocabulary and carrier semantics. |
| CompatibilityReport | Closed | Would turn source-input validation into report/readiness evidence. |
| `.igapp` / manifest | Closed | Would mutate artifact identity and collide with PROP-036 boundaries. |
| Runtime / production | Closed | Registry provenance is compile/profile metadata, not execution authority. |

Design rule:

```text
source input may be carried only as internal profile assembly data until a
separate Bridge-reviewed route opens another carrier.
```

---

## Pass-Boundary Stance

Recommended pass-boundary stance:

```text
profile assembly only
```

Rejected for now:

| Boundary | Decision | Reason |
| --- | --- | --- |
| before compile | Reject for now | Would make the current compiler pipeline consume source input before pack/profile assembly exists. |
| after SemanticIR | Reject | OOF registry provenance is profile/pack metadata, not SemanticIR output. |
| before assembly | Reject | Would risk `.igapp`/manifest and report-for-assembly leakage. |
| current compiler orchestrator | Reject | Would open compiler integration before owner lifecycle is implemented. |
| held/no boundary | Too conservative as target | R125 already proved a useful profile assembly packet. |

The packet should remain outside parser/classifier/TypeChecker/SemanticIR/
assembler/orchestrator paths until a future profile assembly implementation is
explicitly authorized.

---

## Hybrid Ownership Contract

Future `compiler_profile_oof_registry_source_input` ownership should be split:

### Pack Descriptor Finalization Owns

- `pack_ref`;
- `slot_name`;
- `owner_pack_or_boundary`;
- `row_authority_policy: pack_owns_declared_rows`;
- `owned_oof_descriptors`;
- `owned_fragment_rows`;
- `owned_support_markers`;
- per-row provenance and duplicate row/alias claims.

### CompilerProfile Candidate Finalization Owns

- `profile_ref`;
- optional `profile_contract_ref` as evidence only;
- `selected_pack_refs`;
- `pack_order`;
- aggregate `conflict_policy`;
- missing selected pack ref checks;
- no profile override of pack-row ownership conflicts.

### Hybrid Profile Assembly Owns

- source-input packet shape;
- mapping to helper envelopes;
- deterministic packet digest/model id if needed by proof;
- closed-surface assertions;
- final validation result for internal profile assembly.

---

## Required Evidence Before Implementation Review

Before any implementation authorization review, require:

| Evidence | Required result |
| --- | --- |
| R125 source-input proof | PASS and still current. |
| Lifecycle owner design | Accepted by Architect. |
| Bridge pressure | PASS or proceed-with-nonblockers for carrier leakage, even if carrier remains internal. |
| Exact write scope | Named files only; no broad compiler migration. |
| Internal API shape | Exact constructor/result shape, still non-public. |
| No current compiler consumption | Parser/classifier/TypeChecker/SemanticIR/assembler/orchestrator remain untouched. |
| No carrier widening | Public API/CLI, loader/report, CompatibilityReport, `.igapp` remain closed. |
| PROP-036 separation | No `compiler_profile_id`, manifest, loader status, or profile identity mutation. |
| PROP-038 separation | No validator/report/refusal behavior mutation. |
| Full proof matrix | R121/R122/R123/R125 plus new lifecycle/owner proof, if created. |

---

## Closed Surfaces

This track keeps closed:

- implementation;
- compiler integration;
- parser, classifier, TypeChecker, SemanticIR, assembler, orchestrator,
  `CompilationReport`, `CompilerResult`, diagnostics, and CLI changes;
- public API/CLI;
- loader/report;
- CompatibilityReport;
- `.igapp`, `.ilk`, manifest, sidecar, and golden mutation;
- PROP-036 behavior mutation;
- PROP-038 behavior mutation;
- `lib/igniter_lang.rb` require changes;
- `oof_fragment_registry_data.rb`;
- runtime, production, Spark, Ledger/TBackend, Gate 3, cache, and signing.

---

## Recommendation

Recommended next route:

```text
Bridge pressure
```

Suggested card:

```text
compiler-profile-source-input-lifecycle-bridge-pressure-v0
```

Reason:

- R125 already proves the packet mapping.
- R126 now defines the lifecycle owner model.
- Before any implementation review, Bridge should pressure-test whether the
  "internal constructor/test seam only" carrier is sufficiently explicit and
  whether public/report/loader/CompatibilityReport surfaces remain closed.

Implementation review remains held.

---

## Handoff

[D] Choose hybrid profile assembly ownership as the target design: pack
descriptors own row provenance; profile candidate finalization owns selected
pack set/order/conflict policy; hybrid profile assembly owns the source-input
packet.

[S] Current lifecycle remains `proof_only`. `design_accepted` would be a future
gate state, not implementation. `implementation_candidate` and
`finalized_internal` remain closed.

[T] No commands run. Docs-only design track.

[R] Recommended next route: Bridge pressure. Implementation review hold.

[Next] `compiler-profile-source-input-lifecycle-bridge-pressure-v0`.
