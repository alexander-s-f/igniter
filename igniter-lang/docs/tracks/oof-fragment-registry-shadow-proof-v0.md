# OOF Fragment Registry Shadow Proof v0

Card: S3-R92-C1-P1  
Agent: `[Igniter-Lang Research Agent]`  
Role: `research-agent`  
Track: `oof-fragment-registry-shadow-proof-v0`  
Route: UPDATE  
Status: done  
Date: 2026-05-20

---

## Role And Neighbor Awareness

Assigned track: proof-only shadow registry for OOF descriptors and fragment
semantics.

Affected neighbor roles:

- `[Igniter-Lang Compiler/Grammar Expert]` — OOF/fragment semantics and future
  language correctness review.
- `[Igniter-Lang Bridge Agent]` — loader/report, CompatibilityReport, runtime,
  public API/CLI, and package surfaces remain closed.

This track creates proof-local data only. It does not implement a registry,
dispatch path, compiler migration, or public diagnostic contract.

---

## Current Horizon

```text
LANG-R91 / compiler_pack_shadow_profile_proof_v1 is PASS evidence.
S3-R92-C0-O opens only docs/tracks plus experiments/oof_fragment_registry_shadow_proof.
OOF and fragment registry work is data-only and proof-local.
Profile-contract diagnostics stay outside OOF.
Candidate fragment precedence remains non-canon.
```

---

## Read Set

- `docs/cards/S3/S3-R92.md`
- `docs/org/tracks/oof-fragment-registry-shadow-proof-boundary-v0.md`
- `docs/tracks/compiler-pack-shadow-profile-proof-v1.md`
- `experiments/compiler_pack_shadow_profile_proof_v1/out/compiler_pack_shadow_profile_proof_v1_summary.json`
- `docs/tracks/compiler-pack-boundary-report-v0.md`
- `docs/tracks/compiler-pack-boundary-proof-fixture-and-oof-survey-v0.md`
- current compiler/profile OOF and fragment touchpoints found by:
  `rg "OOF-|PINV-|TINV-|fragment|epistemic|compiler_profile_contract" igniter-lang/docs igniter-lang/experiments igniter-lang/lib -g "*.md" -g "*.json" -g "*.rb"`

---

## Proof Output

Executable proof:

```text
igniter-lang/experiments/oof_fragment_registry_shadow_proof/oof_fragment_registry_shadow_proof.rb
```

Generated proof-local outputs:

```text
igniter-lang/experiments/oof_fragment_registry_shadow_proof/out/oof_fragment_registry_shadow_proof_summary.json
igniter-lang/experiments/oof_fragment_registry_shadow_proof/out/oof_descriptors.shadow_registry.json
igniter-lang/experiments/oof_fragment_registry_shadow_proof/out/fragment_registry.shadow_registry.json
```

Result:

```text
PASS oof-fragment-registry-shadow-proof-v0
checks: 18/18
registry_id: oof_fragment_shadow_registry/sha256:279c9e69b50264539027d6a7
```

The proof reads the R91 shadow profile summary as evidence and verifies it is
`PASS` with `dispatch_mode: shadow_no_dispatch`.

---

## OOF Descriptor Schema

The proof-local descriptor schema covers the C0 required fields:

| Field | Purpose |
| --- | --- |
| `code` | Public diagnostic or proof marker code. |
| `family` | Grouping such as `stream`, `temporal_bihistory`, `invariant`, or `progression_descriptor`. |
| `owner_pack_or_boundary` | Candidate owning pack or support boundary. |
| `source_stage` | Stage vocabulary: `parser`, `classifier`, `typechecker`, `semanticir`, `assembler`, `report`, `runtime_guard`, or `proof_only`. |
| `compiler_layer` | Current layer where the code is emitted or modeled. |
| `severity` | `error`, `warning`, or `proof_marker`. |
| `status_class` | `blocking_oof`, `warning_oof`, `compatibility_alias`, `candidate_oof`, `descriptor_only`, or `proof_marker`. |
| `public_code_stability` | `stable_current`, `stable_compatibility_alias`, `candidate_proof_only`, or `proof_only`. |
| `message_stability` | Message stability class; v0 uses family-level stability. |
| `aliases` | Compatibility alias codes, if any. |
| `deprecated` / `deprecated_by` / `replacement_code` | Alias/deprecation metadata. |
| `source_refs` | Current evidence paths. |
| `current_status` | `current`, `compatibility_alias`, or `candidate`. |
| `non_authority_notes` | Boundary note to prevent implementation/runtime inference. |

The generated descriptor registry has 63 entries and covers every OOF code
listed by `compiler_pack_shadow_profile_proof_v1`.

---

## OOF Descriptor Proof Table

| Family / codes | Owner | Stage / layer | Status classification | Stability |
| --- | --- | --- | --- | --- |
| `OOF-P0`, `OOF-P1`, `OOF-P2`, `OOF-P28`, `OOF-TY0`, `OOF-DM3` | `CoreLanguagePack` | parser / classifier / typechecker / semanticir | current blocking OOF | stable current |
| `OOF-PG1`, `OOF-PG2`, `OOF-PG3`, `OOF-PG5` | `PipelinePack` | parser | current blocking OOF | stable current |
| `OOF-H1`, `OOF-BT1`, `OOF-BT2`, `OOF-BT3`, `OOF-BT4` | `TemporalPack` | typechecker | current blocking OOF | stable current |
| `OOF-TM1`, `OOF-TM3`, `OOF-TM4`, `OOF-TM5`, `OOF-TM6` | `TemporalPack` | typechecker | compatibility aliases for `OOF-H1` / `OOF-BT*` | stable compatibility alias |
| `OOF-H2`, `OOF-H3`, `OOF-H4` | `TemporalPack` | proof-only | candidate temporal pressure | candidate proof-only |
| `OOF-S1`..`OOF-S5` | `StreamPack` | parser / classifier / typechecker | current blocking OOF | stable current |
| `OOF-O2` | `OLAPPack` | typechecker | warning OOF | stable current |
| `OOF-O3`, `OOF-O4`, `OOF-O5` | `OLAPPack` | typechecker | current blocking OOF | stable current |
| `OOF-O1` | `OLAPPack` | proof-only | candidate owner pressure | candidate proof-only |
| `OOF-IV1`, `OOF-IV2`, `OOF-IV3`, `OOF-I4` | `InvariantPack` | parser / typechecker | current blocking OOF | stable current |
| `OOF-I1`, `OOF-I2`, `OOF-I3`, `OOF-I5`, `PINV-*`, `TINV-*` | `InvariantPack` | proof/parser/typechecker markers | candidate/proof marker | proof-only |
| `OOF-M1` | `ContractModifiersPack` | classifier / typechecker | current blocking OOF | stable current |
| `OOF-A1`, `TASSUMP-1` | `AssumptionsPack` | classifier / typechecker | current blocking diagnostic | stable current |
| `OOF-CE4`, `OOF-OS2`, `OOF-OS4` | `EvidenceObservationPack` | classifier / semanticir | current blocking OOF | stable current |
| `OOF-PR1`..`OOF-PR9` | `PipelinePack` pressure only | descriptor proof | descriptor-only candidate | candidate proof-only |

Explicit exclusions:

| Namespace / code | Classification | Reason |
| --- | --- | --- |
| `compiler_profile_contract.*` | excluded from OOF | Nested report-only validator diagnostics. |
| `compiler_profile_contract_refusal.*` | excluded from OOF | Internal strict-terminal wrapper diagnostics. |
| `OOF-RUNTIME-SMOKE` | excluded runtime helper | Runtime smoke helper must not seed the language OOF registry. |

---

## Alias / Deprecation / Status Classification

Compatibility alias model:

| Alias | Replacement / canonical code | Status |
| --- | --- | --- |
| `OOF-TM1` | `OOF-H1` | stable compatibility alias |
| `OOF-TM3` | `OOF-BT1` | stable compatibility alias |
| `OOF-TM4` | `OOF-BT2` | stable compatibility alias |
| `OOF-TM5` | `OOF-BT3` | stable compatibility alias |
| `OOF-TM6` | `OOF-BT4` | stable compatibility alias |

V0 policy:

- current codes are not renamed or deleted;
- aliases remain explicit descriptors with `replacement_code`;
- candidate/proof-only codes are marked `candidate` and cannot be treated as
  public blocking OOF codes by this proof;
- `PINV-*` and `TINV-*` are proof/checkpoint markers, not current public OOF
  diagnostics;
- profile-contract diagnostics are separate namespaces, not OOF aliases.

---

## Fragment Registry Proof Table

The generated fragment registry has 8 rows: 6 current shadow fragments plus 2
guarded non-fragments.

| Fragment / state | Owner | Classification | Value/status note |
| --- | --- | --- | --- |
| `core` | `CoreLanguagePack` | language fragment | Baseline pure compiler surface. |
| `escape` | `EscapeBoundaryPack` | trust-boundary fragment | Runtime authority remains closed. |
| `temporal` | `TemporalPack` | language fragment | Temporal read node is temporal; selected value remains CORE-typed. |
| `stream` | `StreamPack` | current shadow language fragment | Ingress/executor remains production-closed. |
| `epistemic` | `AssumptionsPack` | language fragment | Current assumptions evidence; PROP-033 evidence-list validation closed. |
| `oof` | `OOFRegistryPack` | status/fragment-both candidate | Blocks SemanticIR/assembly; must not imply capability. |
| `olap` | `OLAPPack` | not a fragment class | Owner surface only; no fragment promotion. |
| `progression` | `PipelinePack` | not a fragment class | Remains pipeline metadata; no PROGRESSION fragment class. |

Candidate precedence proved deterministic and non-canon:

```text
oof > temporal > stream > epistemic > escape > core
```

This differs from some historical/current implementation orderings in small
ways and is intentionally not used to change classifier or assembler behavior.

---

## `oof` Fragment / Status Alternatives

| Model | Benefit | Risk | Shadow recommendation |
| --- | --- | --- | --- |
| `oof_as_fragment` | Fits current fragment summaries and assembler refusal checks. | Failure can look like a capability. | Not preferred alone. |
| `oof_as_status` | Cleaner diagnostic/status model. | Does not fully explain current `fragment_class: oof`. | Insufficient alone. |
| `oof_as_both` | Matches current proof/compiler intuition while keeping blocking explicit. | Needs stronger non-authority invariants before canonization. | Preferred shadow model only. |

Recommendation: use `oof_as_both` for shadow registry modeling only. A later
Architect/spec decision must choose any canon semantics.

---

## PASS / FAIL Summary

| Check group | Result |
| --- | --- |
| R91 source evidence is PASS and `shadow_no_dispatch` | PASS |
| Descriptor code uniqueness and required fields | PASS |
| R91 OOF codes covered | PASS |
| Alias/replacement metadata deterministic | PASS |
| Profile-contract diagnostics excluded from OOF | PASS |
| Runtime smoke helper excluded | PASS |
| Current fragment owners covered | PASS |
| `olap` and `progression` guarded as non-fragments | PASS |
| Temporal node/value split represented | PASS |
| Epistemic current / PROP-033 closed represented | PASS |
| Candidate precedence deterministic and non-canon | PASS |
| `oof` alternatives evaluated | PASS |
| Closed-surface assertions preserved | PASS |

No failed checks.

---

## Command Matrix

| Command | Result |
| --- | --- |
| `ruby -c igniter-lang/experiments/oof_fragment_registry_shadow_proof/oof_fragment_registry_shadow_proof.rb` | PASS / `Syntax OK` |
| `ruby igniter-lang/experiments/oof_fragment_registry_shadow_proof/oof_fragment_registry_shadow_proof.rb` | PASS / `checks: 18/18` |

No broad compiler/runtime test suite was run because this card is proof-local
and must not mutate live compiler behavior.

---

## Blockers Before Implementation

Implementation remains blocked until a later decision separately authorizes it.
Known blockers:

- choose canon semantics for `oof`: fragment, status, or both;
- decide whether candidate precedence belongs in spec, registry data, or
  assembler-only summary logic;
- define public-code stability policy for candidate/proof-only codes;
- decide whether `PINV-*` / `TINV-*` remain proof markers or become diagnostic
  descriptors;
- define registry ownership: kernel service data, installed pack data, or
  compiler support metadata;
- prove byte-for-byte diagnostic/report/golden parity before any live migration;
- keep profile-contract diagnostics outside OOF unless a future proposal says
  otherwise.

---

## Closed Surfaces

This track does not authorize:

- compiler code edits;
- specs/proposals edits;
- registry implementation;
- live pack dispatch;
- profile-assembled compiler migration;
- parser/classifier/TypeChecker/SemanticIR/assembler/orchestrator rewrites;
- diagnostic renames, deletions, or public wording changes;
- `.igapp` or golden mutation;
- public API/CLI widening;
- loader/report or CompatibilityReport status;
- runtime, Gate 3, Ledger/TBackend, BiHistory, stream/OLAP production executor,
  production cache, signing, or production behavior;
- Spark fixture/spec work or Spark production integration.

---

## Handoff

```text
[Igniter-Lang Research Agent]
Track: oof-fragment-registry-shadow-proof-v0
Status: done
Card: S3-R92-C1-P1
Neighbors: Compiler/Grammar Expert | Bridge Agent

[D]
- Added proof-local OOF descriptor and fragment registry data under
  experiments/oof_fragment_registry_shadow_proof/.
- Covered 63 descriptor entries, 8 fragment rows, R91 OOF coverage, aliases,
  exclusions, and candidate precedence.
- Kept compiler_profile_contract.* and compiler_profile_contract_refusal.*
  explicitly outside OOF.

[S]
- Proof recommends `oof_as_both` only as a shadow model.
- Candidate precedence is deterministic but non-canon:
  oof > temporal > stream > epistemic > escape > core.
- `olap` and `progression` remain guarded non-fragments.

[T]
- ruby -c igniter-lang/experiments/oof_fragment_registry_shadow_proof/oof_fragment_registry_shadow_proof.rb
  -> Syntax OK
- ruby igniter-lang/experiments/oof_fragment_registry_shadow_proof/oof_fragment_registry_shadow_proof.rb
  -> PASS oof-fragment-registry-shadow-proof-v0, checks: 18/18

[R]
- Proceed to C2/C3 semantics/pressure review.
- Do not implement a live registry or dispatch path from this proof.

[Next]
- C2 should pressure `oof_as_both`, candidate precedence, and
  PINV/TINV/progression descriptor classification before C4-A.
```
