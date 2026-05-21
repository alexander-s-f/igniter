# OOF Fragment Registry Profile/Pack Source Mode Proof v0

Card: LANG-R115-P1  
Agent: `[Igniter-Lang Research Agent]`  
Role: `research-agent`  
Route: UPDATE  
Track: `oof-fragment-registry-profile-pack-source-mode-proof-v0`  
Status: done  
Date: 2026-05-21

---

## Role And Neighbor Awareness

Assigned track: proof-only modeling for `profile_candidate` and
`pack_descriptor_candidate` source modes.

Affected neighbor roles:

- `[Igniter-Lang Compiler/Grammar Expert]` — source-authority and pack/profile
  semantics.
- `[Igniter-Lang Bridge Agent]` — loader/report, CompatibilityReport, public
  API/CLI, runtime, and package surfaces remain closed.

This proof is experiment-local. It does not edit library/compiler/public/report/
spec/runtime files and does not change live helper acceptance.

---

## Current Horizon

```text
R111/R112 landed validate_source_envelope as an internal helper.
Live helper accepts only proof_fixture and caller_supplied.
R114 recommended proof-only modeling for profile_candidate and pack_descriptor_candidate.
LANG-R115 proves the model while live helper still returns held_source_mode.
```

---

## Read Set

- `docs/tracks/oof-fragment-registry-profile-pack-source-mode-design-v0.md`
- `lib/igniter_lang/oof_fragment_registry.rb`
- `experiments/oof_fragment_registry_source_envelope_helper_proof/out/oof_fragment_registry_source_envelope_helper_proof_summary.json`
- `experiments/oof_fragment_registry_implementation_boundary_proof/fixtures/forward_shape_valid.json`
- `docs/tracks/oof-fragment-registry-source-envelope-helper-proof-v0.md`

---

## Proof Output

Executable proof:

```text
igniter-lang/experiments/oof_fragment_registry_profile_pack_source_mode_proof/oof_fragment_registry_profile_pack_source_mode_proof.rb
```

Generated proof-local outputs:

```text
igniter-lang/experiments/oof_fragment_registry_profile_pack_source_mode_proof/out/oof_fragment_registry_profile_pack_source_mode_proof_summary.json
igniter-lang/experiments/oof_fragment_registry_profile_pack_source_mode_proof/out/oof_fragment_registry_profile_pack_source_mode_model.json
igniter-lang/experiments/oof_fragment_registry_profile_pack_source_mode_proof/out/derived_registry_from_pack_candidates.json
```

Result:

```text
PASS oof-fragment-registry-profile-pack-source-mode-proof-v0
cases: 9/9
checks: 7/7
recommendation: SOURCE_AUTHORITY_DESIGN_NEXT
model_id: oof_fragment_profile_pack_source/sha256:8a6a582e14790fe4995a9c62
```

---

## Model Shape

The proof models:

- a synthetic `profile_candidate` envelope with:
  - `authority_kind: "proof_only"`;
  - `canon_status: "non_canon"`;
  - synthetic `profile_ref`;
  - synthetic `profile_contract_ref`;
  - `row_authority_policy: "pack_descriptor_rows_aggregated_by_profile"`;
- synthetic `pack_descriptor_candidate` rows with:
  - `authority_kind: "proof_only"`;
  - `canon_status: "non_canon"`;
  - synthetic `pack_ref`;
  - `owned_oof_descriptors`;
  - `owned_fragment_rows`;
  - `owned_support_markers`;
- a derived registry hash assembled from pack-owned rows and validated through
  the existing internal validator:

```text
IgniterLang::OOFFragmentRegistry#validate
```

The live helper is still tested separately:

```text
IgniterLang::OOFFragmentRegistry#validate_source_envelope
```

For both candidate source modes, live helper returns
`oof_registry.source.validation.held_source_mode` and does not call nested
registry validation.

---

## Case Matrix

| Case | Expected | Result | Purpose |
| --- | --- | --- | --- |
| `profile_candidate_model_valid_non_canon_proof_only` | accepted | PASS | Profile model has proof-only/non-canon authority and synthetic refs only. |
| `pack_descriptor_candidates_model_valid_non_canon_proof_only` | accepted | PASS | Pack descriptor model has proof-only/non-canon authority and pack row ownership. |
| `derived_registry_from_pack_candidates_validates` | accepted | PASS | Derived registry validates through existing `OOFFragmentRegistry#validate`. |
| `live_helper_profile_candidate_still_held` | rejected | PASS | Live helper returns `held_source_mode`; nested registry is not called. |
| `live_helper_pack_descriptor_candidate_still_held` | rejected | PASS | Live helper returns `held_source_mode`; nested registry is not called. |
| `duplicate_oof_row_ownership_rejected_by_proof_model` | rejected | PASS | Duplicate OOF descriptor ownership across pack descriptors is rejected. |
| `duplicate_fragment_row_ownership_rejected_by_proof_model` | rejected | PASS | Duplicate fragment row ownership across pack descriptors is rejected. |
| `compiler_profile_contract_descriptor_rejected_by_proof_model` | rejected | PASS | `compiler_profile_contract.*` cannot become an OOF descriptor. |
| `compiler_profile_contract_refusal_alias_rejected_by_proof_model` | rejected | PASS | `compiler_profile_contract_refusal.*` cannot become an OOF alias. |

---

## Proof Checks

| Check | Result |
| --- | --- |
| `source_helper_summary.pass_evidence` | PASS |
| `case_matrix.expected_results` | PASS |
| `derived_registry_validated_by_existing_validator` | PASS |
| `live_helper_profile_pack_modes_held` | PASS |
| `proof_model_rejects_duplicate_row_ownership` | PASS |
| `proof_model_excludes_compiler_profile_contract_namespace` | PASS |
| `closed_surfaces_preserved` | PASS |

No failed cases or checks.

---

## Command Matrix

| Command | Result |
| --- | --- |
| `ruby -c igniter-lang/experiments/oof_fragment_registry_profile_pack_source_mode_proof/oof_fragment_registry_profile_pack_source_mode_proof.rb` | PASS / `Syntax OK` |
| `ruby igniter-lang/experiments/oof_fragment_registry_profile_pack_source_mode_proof/oof_fragment_registry_profile_pack_source_mode_proof.rb` | PASS / `cases: 9/9`, `checks: 7/7` |
| `ruby igniter-lang/experiments/oof_fragment_registry_source_envelope_helper_proof/oof_fragment_registry_source_envelope_helper_proof.rb` | PASS / `cases: 9/9`, `checks: 10/10` |
| `ruby igniter-lang/experiments/oof_fragment_registry_implementation_boundary_proof/oof_fragment_registry_implementation_boundary_proof.rb` | PASS / `27/27 checks PASS` |

No broad compiler/runtime matrix was run because this proof is experiment-local
and does not authorize compiler integration.

---

## Recommendation

Recommendation:

```text
SOURCE_AUTHORITY_DESIGN_NEXT
```

Reason:

- proof-only profile/pack source mode modeling is now green;
- duplicate row ownership and excluded namespace behavior are machine-tested;
- live helper still holds both candidate modes;
- the next unresolved question is source authority, not more local modeling.

Implementation remains held. Changing `SOURCE_ACCEPTED_MODES` or routing these
modes into compiler/profile/pack/loader behavior still needs a separate
Architect decision.

---

## Closed-Surface Evidence

The proof asserts closed surfaces:

```text
live_helper_acceptance: false
compiler_integration: false
public_api_cli: false
loader_report: false
compatibility_report: false
igapp_mutation: false
runtime_behavior: false
specs_canon_proposals: false
prop036_manifest_change: false
prop038_validator_report_change: false
```

The proof does not write or modify any library/compiler/public/report/spec/
runtime files.

---

## Blockers Before Implementation

Before either candidate mode can be accepted by live helper or used by compiler
systems, require:

- source-authority design deciding profile-level authority, pack-row authority,
  or both;
- PROP-036 alignment for profile identity without `.igapp` mutation;
- PROP-038 alignment without changing validator/report behavior;
- pack descriptor schema acceptance;
- Bridge review before loader/report or CompatibilityReport is opened;
- full parity proof for compiler/report/`.igapp` behavior;
- explicit Architect authorization to change `SOURCE_ACCEPTED_MODES`.

---

## Closed Surfaces

This proof does not authorize:

- library/compiler/public/report/spec/runtime edits;
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
[Igniter-Lang Research Agent]
Card: LANG-R115-P1
Track: oof-fragment-registry-profile-pack-source-mode-proof-v0
Status: done
Neighbors: Compiler/Grammar Expert | Bridge Agent

[D]
- Added experiment-local proof for profile_candidate and pack_descriptor_candidate
  source modes.
- Built synthetic pack descriptors from the R103 forward fixture and derived a
  registry that validates through OOFFragmentRegistry#validate.
- Proved live validate_source_envelope still returns held_source_mode for both
  candidate modes.

[S]
- PASS: 9/9 cases, 7/7 checks.
- Duplicate OOF row ownership and duplicate fragment row ownership are rejected
  by the proof model.
- compiler_profile_contract.* and compiler_profile_contract_refusal.* remain
  excluded from OOF descriptors/aliases.

[T]
- ruby -c igniter-lang/experiments/oof_fragment_registry_profile_pack_source_mode_proof/oof_fragment_registry_profile_pack_source_mode_proof.rb
  -> Syntax OK
- ruby igniter-lang/experiments/oof_fragment_registry_profile_pack_source_mode_proof/oof_fragment_registry_profile_pack_source_mode_proof.rb
  -> PASS, cases: 9/9, checks: 7/7
- ruby igniter-lang/experiments/oof_fragment_registry_source_envelope_helper_proof/oof_fragment_registry_source_envelope_helper_proof.rb
  -> PASS, cases: 9/9, checks: 10/10
- ruby igniter-lang/experiments/oof_fragment_registry_implementation_boundary_proof/oof_fragment_registry_implementation_boundary_proof.rb
  -> PASS, 27/27 checks

[R]
- Recommendation: source-authority design next.
- Do not change live helper acceptance or compiler/profile/pack/loader behavior.

[Next]
- Open a source-authority design card if progressing; otherwise hold.
```
