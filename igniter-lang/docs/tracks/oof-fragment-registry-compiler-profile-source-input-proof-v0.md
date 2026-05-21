# OOF Fragment Registry Compiler Profile Source Input Proof v0

Card: LANG-R125-P1  
Agent: `[Igniter-Lang Research Agent]`  
Role: `research-agent`  
Route: UPDATE  
Depends on: LANG-R124-D1, LANG-R123-H1  
Track: `oof-fragment-registry-compiler-profile-source-input-proof-v0`  
Status: done  
Date: 2026-05-21

---

## Role And Neighbor Awareness

Assigned track: proof-only compiler-profile source-input packet model for OOF
Fragment Registry profile/pack candidates.

Affected neighbor roles:

- `[Igniter-Lang Compiler/Grammar Expert]` — owns future source-input/profile
  semantics if implementation is ever authorized.
- `[Igniter-Lang Bridge Agent]` — public API/CLI, loader/report,
  CompatibilityReport, runtime, and production surfaces remain closed.

This track creates only an experiment-local proof. It does not implement
compiler behavior and does not change `IgniterLang::OOFFragmentRegistry`.

---

## Current Horizon

```text
R121/R122 accept profile_candidate and pack_descriptor_candidate inside the internal helper.
R123 refreshed stale proof expectations and made the R121/R122 matrix green.
R124 recommends a proof-only compiler-profile source-input model, with implementation held.
R125 proves the source-input packet maps deterministically into helper-accepted envelopes.
```

---

## Read Set

- `docs/tracks/oof-fragment-registry-compiler-profile-source-input-design-v0.md`
- `docs/tracks/oof-fragment-registry-profile-pack-source-proof-refresh-v0.md`
- `lib/igniter_lang/oof_fragment_registry.rb`
- `experiments/oof_fragment_registry_profile_pack_source_mode_proof/out/oof_fragment_registry_profile_pack_source_mode_proof_summary.json`
- `experiments/oof_fragment_registry_implementation_boundary_proof/fixtures/forward_shape_valid.json`

---

## Proof Output

Executable proof:

```text
igniter-lang/experiments/oof_fragment_registry_compiler_profile_source_input_proof/oof_fragment_registry_compiler_profile_source_input_proof.rb
```

Generated proof-local outputs:

```text
igniter-lang/experiments/oof_fragment_registry_compiler_profile_source_input_proof/out/oof_fragment_registry_compiler_profile_source_input_proof_summary.json
igniter-lang/experiments/oof_fragment_registry_compiler_profile_source_input_proof/out/compiler_profile_source_input_model.json
igniter-lang/experiments/oof_fragment_registry_compiler_profile_source_input_proof/out/compiler_profile_oof_registry_source_input.packet.json
igniter-lang/experiments/oof_fragment_registry_compiler_profile_source_input_proof/out/mapped_helper_envelopes.json
```

Result:

```text
PASS oof-fragment-registry-compiler-profile-source-input-proof-v0
cases: 9/9
checks: 6/6
recommendation: SOURCE_INPUT_MODEL_ACCEPTED
model_id: compiler_profile_oof_registry_source_input/sha256:0df0206bd910f3ecee4a5fc2
```

---

## Packet Model

The proof defines a proof-only packet:

```json
{
  "kind": "compiler_profile_oof_registry_source_input",
  "format_version": "0.1.0",
  "authority": {
    "authority_ref": "LANG-R124-D1 plus LANG-R125-P1",
    "authority_kind": "proof_only",
    "canon_status": "non_canon"
  },
  "profile_candidate": {},
  "pack_descriptor_candidates": [],
  "validation_target": "oof_fragment_registry_source_envelope_helper",
  "closed_surface_assertions": {}
}
```

The packet is not a compiler API, CLI option, loader/report field, manifest
field, PROP-036 authority, PROP-038 authority, runtime input, or production
surface. It is mapped into helper envelopes before validation:

```text
compiler_profile_oof_registry_source_input
  -> profile_candidate helper envelope
  -> pack_descriptor_candidate helper envelopes
  -> IgniterLang::OOFFragmentRegistry#validate_source_envelope
```

---

## Case Matrix

| Case | Expected | Result | Purpose |
| --- | --- | --- | --- |
| `valid_source_input_packet_shape` | accepted | PASS | Packet has proof-only authority, non-canon status, profile candidate, pack descriptors, and closed surfaces. |
| `deterministic_mapping_to_helper_envelopes` | accepted | PASS | Re-mapping the same packet yields the same canonical digest. |
| `helper_accepts_valid_profile_source_input` | accepted | PASS | Mapped `profile_candidate` envelope derives and validates registry through the helper. |
| `helper_accepts_valid_pack_source_inputs` | accepted | PASS | Mapped pack descriptor envelopes validate internally without requiring nested registry. |
| `missing_pack_ref_rejected` | rejected | PASS | Missing selected pack ref stays an internal source diagnostic. |
| `duplicate_row_ownership_rejected` | rejected | PASS | Duplicate row ownership stays an internal source diagnostic. |
| `bad_authority_rejected` | rejected | PASS | Invalid authority kind is rejected before nested registry validation. |
| `forbidden_canon_status_rejected` | rejected | PASS | Canon status is rejected before nested registry validation. |
| `excluded_namespace_claim_rejected` | rejected | PASS | `compiler_profile_contract.*` remains excluded from OOF descriptors. |

---

## Proof Checks

| Check | Result |
| --- | --- |
| `r123_refresh_summary_pass_evidence` | PASS |
| `helper_modes_exact_r121_r122` | PASS |
| `case_matrix_expected_results` | PASS |
| `failure_diagnostics_internal_only` | PASS |
| `no_compiler_pass_uses_source_input` | PASS |
| `closed_surfaces_preserved` | PASS |

No failed cases or checks.

---

## Command Matrix

| Command | Result |
| --- | --- |
| `ruby -c igniter-lang/experiments/oof_fragment_registry_compiler_profile_source_input_proof/oof_fragment_registry_compiler_profile_source_input_proof.rb` | PASS / `Syntax OK` |
| `ruby igniter-lang/experiments/oof_fragment_registry_compiler_profile_source_input_proof/oof_fragment_registry_compiler_profile_source_input_proof.rb` | PASS / `cases: 9/9`, `checks: 6/6` |
| `ruby igniter-lang/experiments/oof_fragment_registry_profile_pack_source_mode_proof/oof_fragment_registry_profile_pack_source_mode_proof.rb` | PASS / `cases: 9/9`, `checks: 7/7` |
| `ruby igniter-lang/experiments/oof_fragment_registry_profile_pack_source_acceptance_proof/oof_fragment_registry_profile_pack_source_acceptance_proof.rb` | PASS / `cases: 13/13`, `checks: 5/5` |
| `ruby igniter-lang/experiments/oof_fragment_registry_source_envelope_helper_proof/oof_fragment_registry_source_envelope_helper_proof.rb` | PASS / `cases: 9/9`, `checks: 10/10` |
| `ruby igniter-lang/experiments/oof_fragment_registry_source_authority_precedence_proof/oof_fragment_registry_source_authority_precedence_proof.rb` | PASS / `cases: 9/9`, `checks: 9/9` |
| `ruby igniter-lang/experiments/oof_fragment_registry_implementation_boundary_proof/oof_fragment_registry_implementation_boundary_proof.rb` | PASS / `27/27 checks PASS` |
| `ruby -c igniter-lang/lib/igniter_lang/oof_fragment_registry.rb` | PASS / `Syntax OK` |

---

## Closed Surfaces

The proof asserts these surfaces remain closed:

```text
compiler_integration: false
public_api_cli: false
loader_report: false
compatibility_report: false
igapp_mutation: false
prop036_manifest_change: false
prop038_validator_report_change: false
runtime_behavior: false
production_behavior: false
spark_surface: false
```

The proof also scans current compiler pass files and public/report/CLI-adjacent
files to ensure they do not mention or consume
`compiler_profile_oof_registry_source_input`.

---

## Recommendation

Recommendation:

```text
SOURCE_INPUT_MODEL_ACCEPTED
```

Interpretation:

- the proof-only source-input packet model is sufficient as a design/proof
  bridge from compiler-profile candidate data to the accepted helper envelopes;
- more proof is not required for this packet-to-helper mapping itself;
- implementation remains held for any compiler integration, public/API carrier,
  report/loader/CompatibilityReport carrier, `.igapp` mutation, or runtime use.

---

## Handoff

[D] A proof-only `compiler_profile_oof_registry_source_input` packet can carry
profile/pack candidate data and deterministically map into helper-accepted OOF
Fragment Registry source envelopes.

[S] Valid profile and pack mappings are accepted by the internal helper.
Failures remain internal source diagnostics: missing pack, duplicate row
ownership, bad authority, forbidden canon status, and excluded namespace.

[T] PASS:
`ruby igniter-lang/experiments/oof_fragment_registry_compiler_profile_source_input_proof/oof_fragment_registry_compiler_profile_source_input_proof.rb`
-> `cases: 9/9`, `checks: 6/6`.

[R] Recommendation: source-input model accepted. Hold implementation.

[Next] If progressing, the next card should decide whether this packet becomes
a compiler-pack/profile implementation candidate, and must name exact write
scope plus Bridge review before public/report/loader surfaces open.
