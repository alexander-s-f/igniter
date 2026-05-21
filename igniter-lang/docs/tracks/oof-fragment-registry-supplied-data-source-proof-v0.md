# OOF Fragment Registry Supplied Data Source Proof v0

Card: LANG-R107-P1  
Agent: `[Igniter-Lang Research Agent]`  
Role: `research-agent`  
Route: UPDATE  
Track: `oof-fragment-registry-supplied-data-source-proof-v0`  
Status: done  
Date: 2026-05-21

---

## Role And Neighbor Awareness

Assigned track: proof-only supplied-data source experiment for the OOF/Fragment
Registry after R106 design.

Affected neighbor roles:

- `[Igniter-Lang Compiler/Grammar Expert]` — source-envelope semantics and
  future registry/source authority.
- `[Igniter-Lang Bridge Agent]` — loader/report, CompatibilityReport, public
  API/CLI, runtime, and package surfaces remain closed.

This proof creates experiment-local evidence only. It does not edit specs,
canon, proposals, compiler integration, runtime, public API/CLI, reports,
CompatibilityReport, `.igapp`, or goldens.

---

## Current Horizon

```text
R103 accepted an isolated internal OOFFragmentRegistry validator.
R104 accepted the validator closure and kept static data / compiler integration closed.
R105 rejected static internal library data for now.
R106 designed only a future supplied-data source envelope.
R107 proves that envelope locally while keeping implementation held.
```

---

## Read Set

- `docs/tracks/oof-fragment-registry-implementation-boundary-proof-v0.md`
- `docs/gates/oof-fragment-registry-implementation-acceptance-decision-v0.md`
- `docs/tracks/oof-fragment-registry-static-internal-data-design-v0.md`
- `docs/tracks/oof-fragment-registry-loader-supplied-data-source-design-v0.md`
- `lib/igniter_lang/oof_fragment_registry.rb`
- `experiments/oof_fragment_registry_implementation_boundary_proof/fixtures/forward_shape_valid.json`
- `experiments/oof_fragment_registry_implementation_boundary_proof/out/oof_fragment_registry_implementation_boundary_proof_summary.json`

---

## Proof Output

Executable proof:

```text
igniter-lang/experiments/oof_fragment_registry_supplied_data_source_proof/oof_fragment_registry_supplied_data_source_proof.rb
```

Generated proof-local outputs:

```text
igniter-lang/experiments/oof_fragment_registry_supplied_data_source_proof/out/oof_fragment_registry_supplied_data_source_proof_summary.json
igniter-lang/experiments/oof_fragment_registry_supplied_data_source_proof/out/oof_fragment_registry_source_model.json
```

Result:

```text
PASS oof-fragment-registry-supplied-data-source-proof-v0
cases: 7/7
checks: 9/9
recommendation: PASS_FOR_PROOF_ONLY_SUPPLIED_DATA_SOURCE_HOLD_IMPLEMENTATION
source_model_id: oof_fragment_registry_source/sha256:113ed721edf851c171a13693
```

---

## Supplied Source Envelope

The proof models the R106 source envelope:

```json
{
  "kind": "oof_fragment_registry_source",
  "format_version": "0.1.0",
  "source_mode": "proof_fixture",
  "authority": {
    "authority_ref": "LANG-R106-D1",
    "authority_kind": "proof_only",
    "canon_status": "non_canon"
  },
  "row_authority_policy": "whole_registry",
  "historical_source_refs": [
    "experiments/oof_fragment_registry_shadow_proof/out/oof_descriptors.shadow_registry.json"
  ],
  "closed_surface_assertions": {
    "static_data_file": false,
    "lib_igniter_lang_rb_require": false,
    "compiler_pass_integration": false,
    "public_api_cli": false,
    "top_level_report_diagnostics": false,
    "compiler_result_field": false,
    "loader_report": false,
    "compatibility_report": false,
    "runtime_behavior": false,
    "igapp_mutation": false,
    "specs_canon_proposals": false
  },
  "registry": "{ nested oof_fragment_registry hash }"
}
```

The source-envelope precheck is proof-local. The nested registry hash is
validated through the existing internal validator:

```text
IgniterLang::OOFFragmentRegistry#validate
```

The proof requires `canon_status: "non_canon"` for proof/caller sources. A
`canon` source envelope is rejected internally.

---

## Case Matrix

| Case | Expected | Result | Purpose |
| --- | --- | --- | --- |
| `valid_proof_fixture_source_validates_nested_registry` | accepted | PASS | Proof fixture envelope validates and nested registry validates through `OOFFragmentRegistry#validate`. |
| `valid_caller_supplied_source_validates_nested_registry` | accepted | PASS | Caller-supplied local envelope validates without public API/CLI exposure. |
| `invalid_source_envelope_wrong_kind_internal_only` | rejected | PASS | Wrong envelope kind returns internal source validation diagnostic only. |
| `invalid_source_envelope_canon_status_internal_only` | rejected | PASS | Canon source status is refused in this proof-only route. |
| `invalid_source_envelope_missing_registry_internal_only` | rejected | PASS | Missing nested registry is internal-only failure. |
| `invalid_source_envelope_profile_candidate_internal_only` | rejected | PASS | Profile candidate mode remains closed until a separate gate. |
| `valid_source_envelope_invalid_nested_registry_rejected_internally` | rejected | PASS | Valid envelope plus invalid nested registry is rejected by existing validator only. |

Internal source diagnostics exercised:

- `oof_registry.source.validation.wrong_kind`
- `oof_registry.source.validation.invalid_canon_status`
- `oof_registry.source.validation.missing_registry`
- `oof_registry.source.validation.unsupported_source_mode`

Nested registry validator diagnostic exercised:

- `oof_registry.validation.wrong_kind`

---

## Proof Checks

| Check | Result |
| --- | --- |
| `r103_validator_proof.pass_evidence` | PASS |
| `case_matrix.expected_results` | PASS |
| `nested_registry_hash_validated_by_existing_validator` | PASS |
| `invalid_source_envelopes_internal_only` | PASS |
| `no_static_data_file` | PASS |
| `lib_igniter_lang_rb_does_not_require_registry` | PASS |
| `no_compiler_pass_integration_require` | PASS |
| `validator_result_no_public_surface_keys` | PASS |
| `no_public_api_cli_report_compatibility_runtime_fields` | PASS |

No failed cases or checks.

---

## Closed-Surface Evidence

The proof explicitly checks:

- `lib/igniter_lang/oof_fragment_registry_data.rb` does not exist;
- `lib/igniter_lang.rb` does not require `oof_fragment_registry`;
- parser, classifier, TypeChecker, SemanticIR emitter, assembler,
  orchestrator, compilation report, compiler result, CLI, and diagnostics files
  do not require `oof_fragment_registry`;
- source validation and nested registry validation results contain no public
  result keys such as `igapp_path`, `compilation_report_path`, `report`,
  `compatibility_report`, `runtime_ready`, or `evaluation_ready`;
- closed-surface assertions remain false for public API/CLI, reports,
  CompatibilityReport, runtime, `.igapp`, compiler integration, and specs/canon.

The proof directly requires `lib/igniter_lang/oof_fragment_registry.rb` from the
experiment harness. It does not require `lib/igniter_lang.rb`, and it does not
expose the validator through the package facade.

---

## Command Matrix

| Command | Result |
| --- | --- |
| `ruby -c igniter-lang/experiments/oof_fragment_registry_supplied_data_source_proof/oof_fragment_registry_supplied_data_source_proof.rb` | PASS / `Syntax OK` |
| `ruby igniter-lang/experiments/oof_fragment_registry_supplied_data_source_proof/oof_fragment_registry_supplied_data_source_proof.rb` | PASS / `cases: 7/7`, `checks: 9/9` |
| `ruby igniter-lang/experiments/oof_fragment_registry_implementation_boundary_proof/oof_fragment_registry_implementation_boundary_proof.rb` | PASS / `27/27 checks PASS` |

No broad compiler/runtime matrix was run because this card is experiment-local
and must not claim compiler integration.

---

## PASS / HOLD Recommendation

Recommendation:

```text
PASS_FOR_PROOF_ONLY_SUPPLIED_DATA_SOURCE
HOLD_IMPLEMENTATION
```

Meaning:

- PASS: the supplied-data source envelope can be modeled locally; valid proof
  and caller-supplied envelopes validate their nested registry through
  `OOFFragmentRegistry#validate`; invalid envelopes remain internal-only.
- HOLD: live loader/caller integration, static data, compiler pass usage,
  public API/CLI, reports, CompatibilityReport, runtime, specs/canon, and
  production behavior remain closed.

---

## Blockers Before Implementation

Still required before any implementation route:

- Architect decision naming exact stage and write scope;
- decision whether source-envelope validation belongs in a library helper or
  remains proof-local;
- source-authority acceptance for non-proof data;
- profile/pack source coordination if `profile_candidate` or
  `pack_descriptor_candidate` is ever opened;
- Bridge review before loader/report or CompatibilityReport is mentioned as
  anything beyond closed future candidate;
- parity proof for compiler/report/`.igapp` behavior if any integration is
  opened later.

---

## Closed Surfaces

This proof does not authorize:

- static internal registry data constants;
- `lib/igniter_lang/oof_fragment_registry_data.rb`;
- `lib/igniter_lang.rb` require changes;
- compiler integration;
- specs, proposals, or canon edits;
- parser, classifier, TypeChecker, SemanticIR, assembler, orchestrator,
  report, `CompilerResult`, diagnostics, or CLI behavior changes;
- public diagnostic renames, promotions, aliases, or wording changes;
- public API/CLI registry input;
- loader/report or CompatibilityReport changes;
- `.igapp`, `.ilk`, or golden mutation;
- live pack registry or dispatch;
- RuntimeMachine, Gate 3, Ledger/TBackend, BiHistory, stream/OLAP production
  executors, cache, signing, deployment, or production behavior.

---

## Handoff

```text
[Igniter-Lang Research Agent]
Card: LANG-R107-P1
Track: oof-fragment-registry-supplied-data-source-proof-v0
Status: done
Neighbors: Compiler/Grammar Expert | Bridge Agent

[D]
- Added experiment-local source-envelope proof.
- Valid proof_fixture and caller_supplied envelopes validate nested registry
  through existing IgniterLang::OOFFragmentRegistry#validate.
- Invalid envelope cases remain internal-only and produce no public/result/
  report/runtime fields.

[S]
- PASS proof-only: 7/7 cases, 9/9 checks.
- Static data file remains absent.
- lib/igniter_lang.rb and compiler passes do not require oof_fragment_registry.

[T]
- ruby -c igniter-lang/experiments/oof_fragment_registry_supplied_data_source_proof/oof_fragment_registry_supplied_data_source_proof.rb
  -> Syntax OK
- ruby igniter-lang/experiments/oof_fragment_registry_supplied_data_source_proof/oof_fragment_registry_supplied_data_source_proof.rb
  -> PASS, cases: 7/7, checks: 9/9
- ruby igniter-lang/experiments/oof_fragment_registry_implementation_boundary_proof/oof_fragment_registry_implementation_boundary_proof.rb
  -> PASS, 27/27 checks

[R]
- Recommendation: PASS for proof-only supplied-data source evidence; HOLD
  implementation.
- Do not open loader/report, public API/CLI, compiler integration, specs/canon,
  .igapp, runtime, or production behavior from this proof.

[Next]
- If progressing, route a decision/design card for whether source-envelope
  validation should remain proof-local or become an internal library helper.
```
