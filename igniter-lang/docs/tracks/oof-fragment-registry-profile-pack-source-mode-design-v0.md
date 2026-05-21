# Track: OOF/Fragment Registry Profile/Pack Source Mode Design v0

Card: LANG-R114-D1
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Route: UPDATE
Track: `oof-fragment-registry-profile-pack-source-mode-design-v0`
Status: done
Date: 2026-05-21

---

## Goal

Design whether `profile_candidate` and `pack_descriptor_candidate` source modes
should remain held or progress toward proof-only modeling.

This track is design-only. It does not implement code, edit specs/proposals/canon,
open loader/report, public API/CLI, compiler integration, `.igapp`, runtime,
production, or Spark surfaces.

Affected neighbor roles:

- `[Igniter-Lang Research Agent]`: owns any future proof-only profile/pack source
  modeling experiment.
- `[Igniter-Lang Architect Supervisor]`: owns proof authorization and any future
  implementation/source-authority gate.
- `[Igniter-Lang Bridge Agent]`: loader/report, CompatibilityReport, public
  API/CLI, runtime, and production surfaces remain closed.

---

## Evidence Read

- `docs/tracks/oof-fragment-registry-loader-supplied-data-source-design-v0.md`
  (LANG-R106-D1)
- `docs/tracks/oof-fragment-registry-supplied-data-source-proof-v0.md`
  (LANG-R107-P1)
- `docs/gates/oof-fragment-registry-source-envelope-validation-placement-decision-v0.md`
  (LANG-R108-A)
- `docs/tracks/oof-fragment-registry-source-envelope-helper-boundary-design-v0.md`
  (LANG-R109-D1)
- `docs/gates/oof-fragment-registry-source-envelope-helper-implementation-authorization-review-v0.md`
  (LANG-R110-A)
- `docs/tracks/oof-fragment-registry-source-envelope-helper-proof-v0.md`
  (LANG-R111-I1)
- `docs/gates/oof-fragment-registry-source-envelope-helper-acceptance-decision-v0.md`
  (LANG-R112-A)
- `docs/tracks/oof-fragment-registry-utf8-proof-hygiene-cleanup-v0.md`
  (LANG-R113-H1)
- `lib/igniter_lang/oof_fragment_registry.rb`
- `docs/proposals/PROP-036-compiler-profile-manifest-identity-v0.md`
- `docs/proposals/PROP-038-compiler-profile-contract-v0.md`
- `docs/tracks/compiler-pack-boundary-report-v0.md`

No tests or broad proof commands were run.

---

## Decision

Recommendation:

```text
Open proof-only modeling for BOTH `profile_candidate` and
`pack_descriptor_candidate`.
Keep both modes held in the live `OOFFragmentRegistry#validate_source_envelope`
helper.
Do not implement source-mode acceptance.
Do not route to source-authority canon before the shadow model exists.
```

Short form:

```text
proof-only modeling: yes, both modes together
live helper acceptance: no, keep held_source_mode
compiler/profile/pack integration: no
```

Rationale:

- `profile_candidate` alone can model profile-level aggregation but not row
  provenance.
- `pack_descriptor_candidate` alone can model row ownership but not profile slot
  aggregation.
- Together they can test whether OOF/fragment registry rows can be assembled
  from pack-owned descriptors into a profile candidate without changing helper
  behavior.
- R111/R112 already prove live helper rejection for both modes; the next useful
  step is shadow modeling, not live acceptance.

---

## Mode Status

| Source mode | Current live helper status | R114 recommendation | Notes |
| --- | --- | --- | --- |
| `proof_fixture` | accepted | unchanged | Existing proof/source mode. |
| `caller_supplied` | accepted | unchanged | Existing internal proof/caller mode. |
| `profile_candidate` | held via `held_source_mode` | proof-only shadow modeling | Do not add to `SOURCE_ACCEPTED_MODES`. |
| `pack_descriptor_candidate` | held via `held_source_mode` | proof-only shadow modeling | Do not add to `SOURCE_ACCEPTED_MODES`. |
| canon-status envelope | rejected | unchanged | Still forbidden. |

Proof-only modeling means:

```text
experiment validates candidate profile/pack source envelopes
and asserts live helper still rejects those modes
```

It does not mean:

```text
OOFFragmentRegistry accepts profile_candidate or pack_descriptor_candidate
```

---

## Source Authority Expectations

Any proof-only profile/pack model must declare:

| Field | Requirement |
| --- | --- |
| `source_mode` | `profile_candidate` or `pack_descriptor_candidate`. |
| `authority_kind` | `proof_only` only for first proof. |
| `canon_status` | `non_canon` only. |
| `authority_ref` | Must cite the proof card plus relevant design docs. |
| `profile_ref` | Synthetic proof-local profile reference for `profile_candidate`; not `.igapp` manifest authority. |
| `pack_ref` | Synthetic proof-local pack descriptor reference for `pack_descriptor_candidate`. |
| `row_authority_policy` | Must state whether rows are owned per-pack and aggregated by profile. |
| `closed_surface_assertions` | All protected surfaces false. |

Forbidden first-proof authority values:

- `authority_kind: "gate"` as live content authority;
- `authority_kind: "proposal"` or `"spec"` unless a later design opens canon;
- `canon_status: "canon"`;
- `.igapp` manifest as source authority;
- loader/report or CompatibilityReport source authority;
- runtime/production authority.

Historical proof refs may appear as evidence but not as current authority.

---

## Relationship To PROP-036

PROP-036 defines `CompilerProfile` and `compiler_profile_id` as compiler
understanding identity:

```text
CompilerProfile -> identifies compiler understanding
compiler_profile_id -> names the profile that assembled an artifact
```

R114 proof-only `profile_candidate` must preserve:

- no `.igapp/manifest.json` mutation;
- no mandatory `compiler_profile_id`;
- no profile-required loader/report policy;
- no compiler dispatch migration;
- no runtime execution authority;
- no public API/CLI profile input.

Allowed proof-only relationship:

```text
profile_candidate envelope models a non-canon CompilerProfile-like source
containing oof_registry and fragment_registry candidate material.
```

Forbidden relationship:

```text
profile_candidate envelope becomes manifest/compiler_profile_id authority.
```

---

## Relationship To PROP-038

PROP-038 defines `compiler_profile_contract` as a contract object with strict
registries and ordered rules. It also explicitly separates
`compiler_profile_contract.*` diagnostics from language OOF diagnostics.

Allowed proof-only relationship:

- model `profile_candidate` as referencing a synthetic
  `compiler_profile_contract`-like object;
- model `strict_registries.oof_descriptors` one-owner expectations;
- assert `compiler_profile_contract.*` remains excluded from OOF descriptors
  and aliases;
- assert valid profile/contract candidate evidence does not imply dispatch,
  loader/report readiness, runtime readiness, or compile refusal.

Forbidden relationship:

- treating PROP-038 contract validity as OOF source authority by itself;
- accepting `compiler_profile_contract.*` as OOF codes;
- changing report-only profile-contract behavior;
- changing strict-refusal behavior;
- integrating with `CompilerProfileContractValidator`.

Proof-only modeling may cite PROP-038 vocabulary, but it must not mutate or
reuse live PROP-038 validator/report surfaces.

---

## Pack Descriptor Boundary

Candidate `pack_descriptor_candidate` is row-source evidence, not pack loading.

Proof-only pack descriptor may model:

- `pack_ref`;
- `slot_name`;
- `owned_oof_descriptors`;
- `owned_fragment_rows`;
- `owned_support_markers`;
- dependencies as metadata only;
- `non_authority` flags.

It must not model:

- dynamic pack loading;
- install hooks;
- parser/classifier/typechecker rule dispatch;
- SemanticIR or assembler hooks;
- runtime capabilities;
- package installation;
- production execution.

Pack descriptor rows are candidates for ownership proof only:

```text
pack_descriptor_candidate -> rows
profile_candidate -> aggregates rows
OOFFragmentRegistry helper -> still rejects both modes
```

---

## Proof-Only Model Shape

Suggested first proof model:

```json
{
  "kind": "oof_fragment_registry_profile_pack_source_model",
  "format_version": "0.1.0",
  "profile_candidate": {
    "kind": "oof_fragment_registry_source",
    "source_mode": "profile_candidate",
    "authority": {
      "authority_ref": "LANG-R114-D1",
      "authority_kind": "proof_only",
      "canon_status": "non_canon"
    },
    "profile_ref": "compiler_profile_candidate/proof:local",
    "row_authority_policy": "pack_descriptor_rows_aggregated_by_profile"
  },
  "pack_descriptor_candidates": [
    {
      "kind": "oof_fragment_registry_source",
      "source_mode": "pack_descriptor_candidate",
      "authority": {
        "authority_ref": "LANG-R114-D1",
        "authority_kind": "proof_only",
        "canon_status": "non_canon"
      },
      "pack_ref": "pack_descriptor_candidate/proof:CoreLanguagePack",
      "slot_name": "core",
      "owned_oof_descriptors": [],
      "owned_fragment_rows": [],
      "owned_support_markers": []
    }
  ],
  "closed_surface_assertions": {
    "live_helper_acceptance": false,
    "compiler_integration": false,
    "public_api_cli": false,
    "loader_report": false,
    "compatibility_report": false,
    "igapp_mutation": false,
    "runtime_behavior": false,
    "specs_canon_proposals": false
  }
}
```

The proof may assemble a derived registry hash from candidate pack descriptors,
then validate that derived hash with existing `OOFFragmentRegistry#validate`.

The proof must also call `validate_source_envelope` on both candidate modes and
assert `held_source_mode`, proving the live helper did not accept them.

---

## Why This Does Not Imply Compiler Integration

Proof-only source-mode modeling remains outside compiler integration because:

- no compiler pass consumes the profile/pack model;
- `SOURCE_ACCEPTED_MODES` remains `proof_fixture caller_supplied`;
- `profile_candidate` and `pack_descriptor_candidate` continue to return
  `oof_registry.source.validation.held_source_mode` from the live helper;
- the proof owns any synthetic aggregation logic;
- no `lib/igniter_lang.rb` exposure is created;
- no parser/classifier/typechecker/SemanticIR/assembler/report file changes;
- no `.igapp` manifest/profile field changes;
- no loader/report or CompatibilityReport behavior.

This lane only answers:

```text
Can a proof model describe profile/pack provenance for registry rows?
```

It does not answer:

```text
Should the compiler use that provenance?
```

---

## Exact Blockers Before Proof

Before opening proof-only modeling, require:

- Architect proof authorization naming both modes and exact write scope;
- decision that the live helper remains unchanged and keeps both modes held;
- proof model shape accepted as non-canon;
- source-authority fields pinned to `proof_only` + `non_canon`;
- synthetic profile/pack refs explicitly not `.igapp`, loader/report, runtime,
  or public API authority;
- proof case list and command matrix accepted;
- closed-surface assertions for compiler/public/report/runtime/spec surfaces;
- confirmation that no PROP-036/PROP-038 docs or validators are edited.

Suggested proof-only write scope:

```text
experiments/oof_fragment_registry_profile_pack_source_mode_proof/**
docs/tracks/oof-fragment-registry-profile-pack-source-mode-proof-v0.md
```

No library writes should be needed.

---

## Proof Matrix

Minimum future proof matrix:

| Command | Purpose |
| --- | --- |
| `ruby experiments/oof_fragment_registry_profile_pack_source_mode_proof/oof_fragment_registry_profile_pack_source_mode_proof.rb` | Validate proof-only profile/pack source model and derived registry. |
| `ruby experiments/oof_fragment_registry_source_envelope_helper_proof/oof_fragment_registry_source_envelope_helper_proof.rb` | Prove live helper still holds/rejects profile/pack modes. |
| `ruby experiments/oof_fragment_registry_implementation_boundary_proof/oof_fragment_registry_implementation_boundary_proof.rb` | Prove nested registry validator remains stable. |

Required proof cases:

- profile candidate envelope has `proof_only` + `non_canon`;
- pack descriptor candidate envelope has `proof_only` + `non_canon`;
- derived registry validates through existing registry validator;
- duplicate OOF ownership across pack descriptors is rejected by proof model;
- `compiler_profile_contract.*` remains excluded from OOF descriptors/aliases;
- `PINV-*` / `TINV-*` remain support markers;
- live helper returns `held_source_mode` for profile candidate;
- live helper returns `held_source_mode` for pack descriptor candidate;
- no `oof_fragment_registry_data.rb`;
- no `lib/igniter_lang.rb` require;
- no compiler pass require/call;
- no public/report/runtime/`.igapp` fields.

If any library, compiler, report, or public file is touched, the proof-only
scope is violated and the card must stop.

---

## Blockers Before Implementation

Before any implementation that accepts either mode in
`OOFFragmentRegistry#validate_source_envelope`, require:

- accepted proof-only profile/pack source model;
- separate source-authority design;
- decision whether authority is profile-level, pack-row-level, or both;
- PROP-036 alignment decision for profile identity without `.igapp` mutation;
- PROP-038 alignment decision for strict registry ownership without report
  behavior changes;
- pack descriptor schema acceptance;
- Bridge review for any loader/report or CompatibilityReport mention;
- full parity matrix for compiler/report/`.igapp` behavior;
- explicit Architect authorization to change `SOURCE_ACCEPTED_MODES`.

Until then:

```text
profile_candidate and pack_descriptor_candidate remain held in live helper.
```

---

## Recommendation

Recommendation:

```text
Open proof-only source-mode modeling for both `profile_candidate` and
`pack_descriptor_candidate`.
Keep live helper acceptance held.
Do not redirect to source-authority canon first.
Do not implement code.
```

Suggested next route:

```text
oof-fragment-registry-profile-pack-source-mode-proof-v0
```

Route type:

```text
proof-only
experiment-local
no library/compiler/public/report/spec/runtime changes
```

---

## Closed Surfaces

This design does not authorize:

- code implementation;
- changing `SOURCE_ACCEPTED_MODES`;
- loader/report behavior;
- public API/CLI input or output;
- compiler integration;
- specs, proposals, or canon edits;
- `lib/igniter_lang/oof_fragment_registry_data.rb`;
- static registry constants;
- `lib/igniter_lang.rb` require changes;
- parser, classifier, TypeChecker, SemanticIR, assembler, orchestrator,
  `CompilationReport`, `CompilerResult`, diagnostics, or CLI changes;
- `.igapp`, `.ilk`, or golden mutation;
- live pack registry or dispatch;
- PROP-036 manifest changes;
- PROP-038 validator/report changes;
- RuntimeMachine, Gate 3, Ledger/TBackend, BiHistory, stream/OLAP production
  executors, cache, signing, deployment, production behavior, or Spark work.

---

## Handoff

```text
[Igniter-Lang Compiler/Grammar Expert]
Card: LANG-R114-D1
Track: oof-fragment-registry-profile-pack-source-mode-design-v0
Status: done

[D]
- Designed profile/pack source mode route after accepted source-envelope helper.
- Recommended proof-only modeling for both `profile_candidate` and
  `pack_descriptor_candidate`.
- Kept live helper acceptance held.

[S]
- Profile candidate models non-canon compiler-profile-like aggregation only.
- Pack descriptor candidate models non-canon row provenance only.
- PROP-036 identity, PROP-038 profile contract, and pack descriptor boundaries
  remain evidence/design references, not compiler authority.

[T]
- Docs-only design.
- No tests or broad proofs run.

[R]
- Next route may be proof-only:
  `oof-fragment-registry-profile-pack-source-mode-proof-v0`.
- No implementation or accepted source-mode change is authorized.

[Next]
- Architect proof authorization for the proof-only route, if desired.
```
