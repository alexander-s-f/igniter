# OOF Fragment Registry Source Authority Precedence Proof v0

Card: LANG-R117-P1  
Agent: `[Igniter-Lang Research Agent]`  
Role: `research-agent`  
Route: UPDATE  
Depends on: LANG-R116-D1, LANG-R115-P1  
Track: `oof-fragment-registry-source-authority-precedence-proof-v0`  
Status: done  
Date: 2026-05-21

---

## Role And Neighbor Awareness

Assigned track: proof-only profile/pack source-authority precedence for the
OOF/Fragment Registry.

Affected neighbor roles:

- `[Igniter-Lang Compiler/Grammar Expert]` — source-authority semantics and any
  future registry/candidate mode implementation.
- `[Igniter-Lang Bridge Agent]` — loader/report, CompatibilityReport, public
  API/CLI, runtime, and production surfaces remain closed.

This proof is experiment-local. It does not edit library/compiler/public/report/
spec/runtime files and does not change `SOURCE_ACCEPTED_MODES`.

---

## Current Horizon

```text
R115 proved profile_candidate and pack_descriptor_candidate as proof-only models.
R116 selected both-authority semantics: pack rows own row provenance; profile owns selected pack set, order, and conflict policy.
R117 proves precedence and conflict behavior without changing live helper acceptance.
```

---

## Read Set

- `docs/tracks/oof-fragment-registry-source-authority-design-v0.md`
- `docs/tracks/oof-fragment-registry-profile-pack-source-mode-proof-v0.md`
- `experiments/oof_fragment_registry_profile_pack_source_mode_proof/out/oof_fragment_registry_profile_pack_source_mode_proof_summary.json`
- `lib/igniter_lang/oof_fragment_registry.rb`
- `experiments/oof_fragment_registry_implementation_boundary_proof/fixtures/forward_shape_valid.json`

---

## Proof Output

Executable proof:

```text
igniter-lang/experiments/oof_fragment_registry_source_authority_precedence_proof/oof_fragment_registry_source_authority_precedence_proof.rb
```

Generated proof-local outputs:

```text
igniter-lang/experiments/oof_fragment_registry_source_authority_precedence_proof/out/oof_fragment_registry_source_authority_precedence_proof_summary.json
igniter-lang/experiments/oof_fragment_registry_source_authority_precedence_proof/out/oof_fragment_registry_source_authority_precedence_model.json
igniter-lang/experiments/oof_fragment_registry_source_authority_precedence_proof/out/derived_registry_authority_precedence.json
```

Result:

```text
PASS oof-fragment-registry-source-authority-precedence-proof-v0
cases: 9/9
checks: 9/9
recommendation: R122_CLOSURE_ACCEPTED
model_id: oof_fragment_source_authority_precedence/sha256:9a1d154be544cb87dfa7001b
```

---

## Authority Model Proven

The proof models the R116 precedence rule:

```text
row identity/ownership: pack-row authority wins
selected row set/order/conflict policy: profile-level authority wins
conflict between pack row claims: profile rejects aggregate; no override
```

The derived registry is validated only after proof-model aggregation succeeds.
The existing `IgniterLang::OOFFragmentRegistry#validate` remains the nested
registry validator.

The existing live source-envelope helper now accepts both candidate modes inside
the internal helper only:

```text
profile_candidate -> source valid, derived registry validated
pack_descriptor_candidate -> source valid, registry_validation may remain null
```

`SOURCE_ACCEPTED_MODES` is exactly:

```text
proof_fixture caller_supplied profile_candidate pack_descriptor_candidate
```

---

## Case Matrix

| Case | Expected | Result | Purpose |
| --- | --- | --- | --- |
| `pack_row_authority_owns_row_provenance` | accepted | PASS | Pack row metadata owns row provenance and row identity. |
| `profile_authority_owns_selected_pack_set_order_conflict_policy` | accepted | PASS | Profile metadata owns selected pack refs, pack order, and conflict policy. |
| `derived_registry_validates_after_proof_model_aggregation` | accepted | PASS | Aggregate registry validates through existing registry validator only after proof aggregation. |
| `duplicate_row_ownership_rejects_aggregate` | rejected | PASS | Duplicate OOF row ownership across packs rejects aggregate. |
| `profile_cannot_silently_override_pack_row_conflicts` | rejected | PASS | Profile-level override attempt cannot hide a pack-row conflict. |
| `missing_selected_pack_ref_rejects_aggregate` | rejected | PASS | Profile-selected missing pack ref rejects aggregate. |
| `excluded_namespace_rejects_aggregate` | rejected | PASS | `compiler_profile_contract.*` remains excluded from OOF descriptors. |
| `live_helper_profile_candidate_accepted_internal_only` | accepted | PASS | Live helper accepts `profile_candidate` internally, derives registry, and calls nested validation. |
| `live_helper_pack_descriptor_candidate_accepted_internal_only` | accepted | PASS | Live helper accepts `pack_descriptor_candidate` internally without requiring nested registry. |

---

## Proof Checks

| Check | Result |
| --- | --- |
| `r115_profile_pack_proof.pass_evidence` | PASS |
| `case_matrix.expected_results` | PASS |
| `pack_row_authority_primary` | PASS |
| `profile_authority_owns_selection_order_conflict_policy` | PASS |
| `conflicts_reject_without_profile_override` | PASS |
| `derived_registry_validates_only_after_aggregation` | PASS |
| `live_helper_profile_pack_modes_accepted_internal_only` | PASS |
| `source_accepted_modes_authorized_exact` | PASS |
| `closed_surfaces_preserved` | PASS |

No failed cases or checks.

---

## Command Matrix

| Command | Result |
| --- | --- |
| `ruby -c igniter-lang/experiments/oof_fragment_registry_source_authority_precedence_proof/oof_fragment_registry_source_authority_precedence_proof.rb` | PASS / `Syntax OK` |
| `ruby igniter-lang/experiments/oof_fragment_registry_source_authority_precedence_proof/oof_fragment_registry_source_authority_precedence_proof.rb` | PASS / `cases: 9/9`, `checks: 9/9` |
| `ruby igniter-lang/experiments/oof_fragment_registry_profile_pack_source_mode_proof/oof_fragment_registry_profile_pack_source_mode_proof.rb` | PASS / `cases: 9/9`, `checks: 7/7` |
| `ruby igniter-lang/experiments/oof_fragment_registry_source_envelope_helper_proof/oof_fragment_registry_source_envelope_helper_proof.rb` | PASS / `cases: 9/9`, `checks: 10/10` |
| `ruby igniter-lang/experiments/oof_fragment_registry_implementation_boundary_proof/oof_fragment_registry_implementation_boundary_proof.rb` | PASS / `27/27 checks PASS` |

No broad compiler/runtime matrix was run because this proof is local to
source-authority modeling and does not authorize integration.

---

## Closed-Surface Evidence

The proof asserts the following surfaces remain closed:

```text
source_accepted_modes_widened_beyond_authorized: false
compiler_integration: false
public_api_cli: false
loader_report: false
compatibility_report: false
igapp_mutation: false
runtime_behavior: false
specs_canon_proposals: false
prop036_manifest_change: false
prop038_validator_report_change: false
implementation_authorized: false
```

The proof does not change:

- `SOURCE_ACCEPTED_MODES` beyond the four R121/R122 modes;
- `lib/igniter_lang/oof_fragment_registry.rb`;
- library/compiler/public/report/spec/runtime files;
- `.igapp` artifacts or goldens;
- loader/report, CompatibilityReport, RuntimeMachine, Ledger/TBackend, cache,
  production, PROP-036 manifest, or PROP-038 report behavior.

---

## Recommendation

Recommendation:

```text
R122_CLOSURE_ACCEPTED
```

Interpretation:

- source-authority design remains accepted at proof level;
- more proof is not required for the R116/R121/R122 precedence model itself;
- internal helper acceptance is now reflected by the proof;
- compiler/profile/pack/loader integration remains held.

---

## Handoff

[D] Pack-row authority owns individual row provenance; profile authority owns
selected pack set, order, and conflict policy. Duplicate row ownership rejects
the aggregate and cannot be silently overridden by the profile.

[S] Proof-local experiment only. Live helper now accepts `profile_candidate`
and `pack_descriptor_candidate` inside the internal helper boundary;
`SOURCE_ACCEPTED_MODES` is exactly the four R121/R122 modes.

[T] PASS:
`ruby igniter-lang/experiments/oof_fragment_registry_source_authority_precedence_proof/oof_fragment_registry_source_authority_precedence_proof.rb`
-> `cases: 9/9`, `checks: 9/9`.

[R] Recommendation is R122 closure accepted for this proof surface; broader
implementation remains held.

[Next] If Architect opens implementation later, name exact write scope for
source-envelope acceptance, pack/profile schema, registry provenance fields, and
Bridge review before any loader/report or public API surface changes.
