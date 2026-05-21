# Track: OOF/Fragment Registry Profile/Pack Source Acceptance Preconditions Design v0

Card: LANG-R119-D1
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Route: UPDATE
Depends on: LANG-R118-A
Track: `oof-fragment-registry-profile-pack-source-acceptance-preconditions-design-v0`
Status: done
Date: 2026-05-21

---

## Goal

Define exact preconditions and blockers before any future acceptance of
`profile_candidate` and `pack_descriptor_candidate` in the live
OOF/Fragment Registry source-envelope helper.

This is design-only. It does not authorize implementation and does not change
`SOURCE_ACCEPTED_MODES`.

Affected neighbor roles:

- `[Igniter-Lang Research Agent]`: owns proof parity and any future source-mode
  evidence.
- `[Igniter-Lang Bridge Agent]`: loader/report, public API/CLI, and
  CompatibilityReport remain closed until separate bridge review.
- `[Architect Supervisor / Codex]`: owns any future implementation
  authorization and protected-surface decision.

---

## Evidence Read

- `docs/gates/oof-fragment-registry-source-authority-model-acceptance-decision-v0.md`
  (LANG-R118-A)
- `docs/tracks/oof-fragment-registry-source-authority-precedence-proof-v0.md`
  (LANG-R117-P1)
- `docs/tracks/oof-fragment-registry-source-authority-design-v0.md`
  (LANG-R116-D1)
- `experiments/oof_fragment_registry_profile_pack_source_mode_proof/out/oof_fragment_registry_profile_pack_source_mode_model.json`
- `experiments/oof_fragment_registry_source_authority_precedence_proof/out/oof_fragment_registry_source_authority_precedence_model.json`
- `lib/igniter_lang/oof_fragment_registry.rb` source-mode constants only

No proof commands were run. No code or spec files were edited.

---

## Current Fixed Point

R118 accepts profile/pack source authority as proof/design foundation only.

Current live helper behavior remains:

```text
SOURCE_ACCEPTED_MODES = proof_fixture caller_supplied
SOURCE_HELD_MODES     = profile_candidate pack_descriptor_candidate
```

Accepted source-authority semantics:

```text
pack-row authority:
  owns individual row identity and row provenance

profile-level authority:
  owns selected pack set, selected pack order, and aggregate conflict policy

conflict precedence:
  duplicate pack-row ownership rejects the aggregate;
  profile-level policy cannot silently override pack-row conflicts
```

This track treats those rules as the bar for a later acceptance review, not as
implementation authority.

---

## Decision

Recommendation:

```text
Hold live helper acceptance for now.
Do not open implementation directly from R119.
Open an Architect implementation-authorization review later only after the blocker
checklist below is accepted and Bridge review confirms closed external surfaces.
```

The next route should be:

```text
oof-fragment-registry-profile-pack-source-acceptance-authorization-review-v0
```

or an equivalent Architect gate. A proof-only refinement can run first if any
schema field below is disputed.

---

## Blocker Checklist Before SOURCE_ACCEPTED_MODES May Change

| Blocker | Required closure before acceptance |
| --- | --- |
| Exact write scope | Future implementation card must name the only allowed files. Default candidate is `lib/igniter_lang/oof_fragment_registry.rb` plus a proof-local experiment/track. |
| Mode transition authority | Architect gate must explicitly move one or both modes from `SOURCE_HELD_MODES` to `SOURCE_ACCEPTED_MODES`; no inferred transition from proof PASS. |
| Result-shape decision | Gate must accept the internal result-shape policy below, including no public/report surface changes. |
| Pack descriptor schema | Minimum fields below must be accepted and proof-covered. |
| Profile schema | Minimum selected-pack/order/conflict fields below must be accepted and proof-covered. |
| Authority limits | `authority_kind` and `canon_status` limits below must be enforced by helper validation. |
| Conflict semantics | Duplicate OOF descriptor, fragment row, support marker, alias ownership, missing selected pack ref, and excluded namespace cases must reject. |
| PROP-036 non-mutation | No `.igapp`, manifest, `compiler_profile_id`, profile identity, assembler, loader, or artifact mutation. |
| PROP-038 non-mutation | No validator/report behavior mutation, no `compiler_profile_contract_validation` shape change, no strict-refusal behavior change. |
| Bridge closed-surface review | Bridge must review before loader/report, public API/CLI, or CompatibilityReport move beyond closed future candidates. |
| Parity matrix | Commands in the parity section must PASS before implementation authorization review. |

If any row remains open, `profile_candidate` and `pack_descriptor_candidate`
must stay held modes.

---

## Helper Result Shape Decision

Accepted candidate modes do not require a new public helper result family.
They do require one internal-only extension to the existing source validation
result shape:

```text
result.kind: oof_fragment_registry_source_validation
result.source_mode: profile_candidate | pack_descriptor_candidate
result.valid: true | false
result.diagnostics: []
result.source_authority: { ... }
result.registry_validation: <nested existing registry validation result or null>
result.closed_surface_assertions: { ... all closed surfaces false ... }
```

Rules:

- keep diagnostics under the source-envelope helper result;
- do not add top-level compiler/report diagnostics;
- do not expose new public API/CLI result keys;
- do not write `.igapp`, sidecars, loader reports, or CompatibilityReports;
- validate source authority before nested registry validation;
- run nested registry validation only after source envelope and aggregation pass.

For `pack_descriptor_candidate`, `registry_validation` can be null unless the
single pack carries a complete proof-local registry fixture. For
`profile_candidate`, `registry_validation` should be the validation of the
derived aggregate registry after selected-pack aggregation passes.

---

## Minimum Pack Descriptor Candidate Schema

Future acceptance should require at least:

```json
{
  "kind": "oof_fragment_registry_source",
  "format_version": "0.1.0",
  "source_mode": "pack_descriptor_candidate",
  "authority": {
    "authority_ref": "gate-or-proof-ref",
    "authority_kind": "proof_only | design_accepted",
    "canon_status": "non_canon | accepted_design"
  },
  "pack_ref": "pack_descriptor_candidate/...",
  "slot_name": "core_language",
  "owner_pack_or_boundary": "CoreLanguagePack",
  "row_authority_policy": "pack_owns_declared_rows",
  "owned_oof_descriptors": [],
  "owned_fragment_rows": [],
  "owned_support_markers": [],
  "closed_surface_assertions": {
    "compiler_integration": false,
    "public_api_cli": false,
    "loader_report": false,
    "compatibility_report": false,
    "igapp_mutation": false,
    "runtime_behavior": false,
    "prop036_manifest_change": false,
    "prop038_validator_report_change": false
  }
}
```

Field rules:

- `pack_ref` must be unique inside a profile aggregate.
- `slot_name` must be explicit; no implicit slot derivation.
- `owner_pack_or_boundary` must match row provenance on owned rows.
- `owned_oof_descriptors` and `owned_fragment_rows` must pass existing registry
  validator row rules.
- `owned_support_markers` may include invariant support markers only as support
  metadata, not OOF descriptors.
- `compiler_profile_contract.*` and `compiler_profile_contract_refusal.*`
  remain excluded namespaces.

---

## Minimum Profile Candidate Schema

Future acceptance should require at least:

```json
{
  "kind": "oof_fragment_registry_source",
  "format_version": "0.1.0",
  "source_mode": "profile_candidate",
  "authority": {
    "authority_ref": "gate-or-proof-ref",
    "authority_kind": "proof_only | design_accepted",
    "canon_status": "non_canon | accepted_design"
  },
  "profile_ref": "compiler_profile_candidate/...",
  "profile_contract_ref": "compiler_profile_contract_candidate/...",
  "row_authority_policy": "pack_descriptor_rows_aggregated_by_profile",
  "authority_precedence": {
    "row_identity_and_ownership": "pack_row_authority",
    "selected_pack_set_order_conflict_policy": "profile_level_authority",
    "pack_row_conflict": "profile_rejects_aggregate_no_override"
  },
  "selected_pack_refs": [],
  "pack_order": [],
  "conflict_policy": {
    "duplicate_oof_descriptor": "reject",
    "duplicate_fragment_row": "reject",
    "duplicate_support_marker": "reject",
    "duplicate_alias_owner": "reject",
    "missing_selected_pack_ref": "reject",
    "excluded_namespace": "reject"
  },
  "closed_surface_assertions": {
    "compiler_integration": false,
    "public_api_cli": false,
    "loader_report": false,
    "compatibility_report": false,
    "igapp_mutation": false,
    "runtime_behavior": false,
    "prop036_manifest_change": false,
    "prop038_validator_report_change": false
  }
}
```

Field rules:

- `selected_pack_refs` names the exact pack descriptors allowed in the aggregate.
- `pack_order` is explicit and deterministic; it must not infer compiler
  dispatch order.
- every selected pack ref must resolve inside the supplied profile candidate
  envelope or proof harness.
- duplicate row ownership rejects the aggregate before nested registry
  validation.
- profile-level conflict policy cannot override pack-row ownership conflicts.

---

## Authority Kind And Canon Status Limits

Future accepted candidate modes may remain internal-only only if authority stays
inside this limited vocabulary:

| Field | Allowed before canon/spec route | Forbidden |
| --- | --- | --- |
| `authority_kind` | `proof_only`, `design_accepted` | `runtime`, `loader`, `public_api`, `manifest`, `canon`, `production` |
| `canon_status` | `non_canon`, `accepted_design` | `canon`, `implemented_canon`, `production_canon` |

Interpretation:

- `proof_only` is acceptable only for proof harnesses and internal validation
  fixtures.
- `design_accepted` may be used only after an Architect gate accepts the exact
  source shape.
- `canon_status: "accepted_design"` is still not spec canon and not public
  authority.
- `canon_status: "canon"` must stay rejected until a separate spec/canon route
  explicitly opens it.

---

## PROP-036 Non-Mutation Conditions

Future source acceptance must not mutate or imply mutation of PROP-036 surfaces:

- no `.igapp/manifest.json` change;
- no `compiler_profile_id` derivation or rewrite;
- no profile discovery/defaulting/finalization behavior;
- no assembler field changes;
- no loader/report `present_verified` or status behavior;
- no public Ruby API or CLI source-shape widening.

Allowed wording:

```text
profile_candidate is an internal source-envelope candidate for OOF/fragment
registry provenance.
```

Forbidden wording:

```text
profile_candidate is the compiler_profile_id source for artifacts.
```

---

## PROP-038 Non-Mutation Conditions

Future source acceptance must not mutate or imply mutation of PROP-038 behavior:

- no `CompilerProfileContractValidator` behavior change;
- no `compiler_profile_contract_validation.diagnostics` shape change;
- no report-only integration change;
- no strict-refusal trigger or public result change;
- no `compiler_profile_contract.*` diagnostics promoted to OOF descriptors;
- no compiler profile contract validity used as OOF source authority.

Allowed wording:

```text
profile/pack candidate metadata is compatible with PROP-038 ownership concepts.
```

Forbidden wording:

```text
PROP-038 contract validity accepts profile_candidate as a live OOF source.
```

---

## Bridge Review Requirements

Bridge review is required before any of these closed surfaces move beyond
future-candidate wording:

| Surface | Bridge review must define |
| --- | --- |
| Loader/report | accepted input source, report fields, legacy/no-source behavior, and refusal/status vocabulary. |
| Public API/CLI | caller-facing source shape, invalid-input behavior, public key-set, docs, and no accidental profile loading. |
| CompatibilityReport | whether registry source evidence is report-only metadata, readiness evidence, or excluded. |
| `.igapp` / manifests | whether any manifest field is proposed; default is no mutation. |
| Runtime/production | must remain closed unless a separate runtime gate opens it. |

Until Bridge review lands, those surfaces remain closed and must appear only in
`closed_surface_assertions` with `false` behavior.

---

## Parity Matrix Required Before Implementation Authorization Review

At minimum, a future implementation authorization review should require:

| Command | Required result |
| --- | --- |
| `ruby -c igniter-lang/lib/igniter_lang/oof_fragment_registry.rb` | PASS |
| `ruby igniter-lang/experiments/oof_fragment_registry_source_authority_precedence_proof/oof_fragment_registry_source_authority_precedence_proof.rb` | PASS |
| `ruby igniter-lang/experiments/oof_fragment_registry_profile_pack_source_mode_proof/oof_fragment_registry_profile_pack_source_mode_proof.rb` | PASS |
| `ruby igniter-lang/experiments/oof_fragment_registry_source_envelope_helper_proof/oof_fragment_registry_source_envelope_helper_proof.rb` | PASS |
| `ruby igniter-lang/experiments/oof_fragment_registry_implementation_boundary_proof/oof_fragment_registry_implementation_boundary_proof.rb` | PASS |
| `ruby igniter-lang/experiments/classifier_pass_proof/classifier_pass_proof.rb` | PASS |
| `ruby igniter-lang/experiments/typechecker_proof/typechecker_proof.rb --check-golden` | PASS |
| `ruby igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb --check-golden` | PASS |
| `ruby igniter-lang/experiments/igapp_assembler_proof/igapp_assembler_proof.rb` | PASS |
| `ruby igniter-lang/experiments/prop038_report_only_compiler_integration/prop038_report_only_compiler_integration.rb` | PASS |

The review should also require a proof assertion that:

```text
SOURCE_ACCEPTED_MODES changed only by the authorized implementation card;
no loader/report, public API/CLI, CompatibilityReport, .igapp, runtime,
or PROP-038 report behavior changed.
```

---

## Closed Surfaces

This track keeps closed:

- implementation;
- changing `SOURCE_ACCEPTED_MODES`;
- editing `lib/`;
- `oof_fragment_registry_data.rb`;
- static registry constants;
- `lib/igniter_lang.rb` require changes;
- compiler integration;
- parser, classifier, TypeChecker, SemanticIR, assembler, orchestrator, or
  `CompilationReport` changes;
- public API/CLI;
- loader/report and CompatibilityReport;
- specs/canon/proposals mutation;
- PROP-036 `.igapp` or profile identity mutation;
- PROP-038 validator/report/refusal mutation;
- `.igapp`, `.ilk`, golden, runtime, production, cache, signing, Ledger/TBackend,
  Gate 3, or Spark behavior.

---

## Handoff

[D] Future acceptance of `profile_candidate` and `pack_descriptor_candidate`
requires an explicit Architect implementation-authorization review. R119 does
not open implementation.

[S] Candidate modes need no new public result family, but they do need an
internal-only source-authority subshape and proof coverage before moving out of
`SOURCE_HELD_MODES`.

[T] No proof commands run. Docs-only verification only.

[R] Recommendation: hold now; open implementation authorization review later
only after this blocker checklist and Bridge review requirements are accepted.

[Next] Proposed next route:
`oof-fragment-registry-profile-pack-source-acceptance-authorization-review-v0`.
