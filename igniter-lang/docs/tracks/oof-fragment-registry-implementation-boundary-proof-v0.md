# Track: OOF/Fragment Registry Implementation Boundary Proof v0

Card: LANG-R103-I
Agent: `[Igniter-Lang Implementation Agent]`
Role: implementation-agent
Track: `oof-fragment-registry-implementation-boundary-proof-v0`
Route: UPDATE
Status: done
Date: 2026-05-21

Authorized by: LANG-R102-A
(`docs/gates/oof-fragment-registry-implementation-authorization-review-v0.md`)

---

## Goal

Implement the first bounded OOF/Fragment Registry slice:
- isolated internal registry validator (`lib/igniter_lang/oof_fragment_registry.rb`)
- proof-local boundary/parity harness under `experiments/oof_fragment_registry_implementation_boundary_proof/`
- track doc (this file)

---

## Evidence Read

- `docs/gates/oof-fragment-registry-implementation-authorization-review-v0.md` (LANG-R102-A)
- `docs/tracks/oof-fragment-registry-authorization-blocker-closure-design-v0.md` (LANG-R101-D1)
- `docs/tracks/oof-fragment-registry-implementation-boundary-design-v0.md` (LANG-R99-D1)
- `docs/discussions/oof-fragment-registry-implementation-boundary-pressure-v0.md` (LANG-R100-X)
- `experiments/oof_fragment_registry_shadow_proof/out/oof_descriptors.shadow_registry.json`
- `experiments/oof_fragment_registry_shadow_proof/out/fragment_registry.shadow_registry.json`

---

## Changed Files

```text
lib/igniter_lang/oof_fragment_registry.rb                                   NEW
experiments/oof_fragment_registry_implementation_boundary_proof/
  fixtures/forward_shape_valid.json                                          NEW
  oof_fragment_registry_implementation_boundary_proof.rb                    NEW
  out/oof_fragment_registry_implementation_boundary_proof_summary.json      NEW
docs/tracks/oof-fragment-registry-implementation-boundary-proof-v0.md      NEW (this file)
```

No other file changed. Explicitly out-of-scope files NOT created or modified:

```text
lib/igniter_lang/oof_fragment_registry_data.rb        OUT (first slice, separate card)
lib/igniter_lang.rb                                   UNCHANGED
parser / classifier / TypeChecker / SemanticIR /
  assembler / orchestrator / report / result / CLI    UNCHANGED
docs/spec/                                            UNCHANGED
docs/proposals/                                       UNCHANGED
existing .igapp goldens                               UNCHANGED
```

---

## Implementation Summary

### `lib/igniter_lang/oof_fragment_registry.rb`

Isolated internal validator. Validates a caller-supplied registry hash against the
R101 forward bucket shape.

**Isolation contract (every point is enforced):**
- Not required from `lib/igniter_lang.rb`
- No compiler pass integration (parser/classifier/TypeChecker/SemanticIR/assembler)
- No public diagnostics emitted
- No `report["diagnostics"]` writes
- No `CompilerResult` field
- No public API or CLI
- No runtime, Ledger/TBackend, Gate 3, cache, signing, or production behavior

**R92 non-migration note (embedded in file header):**
The shadow proof JSON at
`experiments/oof_fragment_registry_shadow_proof/out/oof_descriptors.shadow_registry.json`
placed PINV-*/TINV-* inside `oof_descriptors` as historical proof evidence. That
placement is NON-FORWARD. LANG-R98-A and LANG-R101-D1 place PINV-*/TINV-*
exclusively under `support_markers.invariant_support_markers`. This validator
enforces the forward shape. R92 JSON is not migrated.

### Registry Shape Validated

The R101 forward bucket shape (as required by LANG-R102-A):

```json
{
  "kind": "oof_fragment_registry",
  "format_version": "0.1.0",
  "source_authority": {},
  "oof_descriptors": [],
  "fragment_rows": [],
  "support_markers": {
    "invariant_support_markers": []
  },
  "excluded_namespaces": []
}
```

### Validation Rules Enforced

| Rule | Diagnostic code |
| --- | --- |
| Required sections present | `oof_registry.validation.missing_section` |
| Wrong kind | `oof_registry.validation.wrong_kind` |
| Duplicate OOF descriptor code | `oof_registry.validation.duplicate_code` |
| Alias cross-collision (same alias, two descriptors) | `oof_registry.validation.alias_collision` |
| Deprecated without replacement | `oof_registry.validation.alias_missing_replacement` |
| Excluded namespace prefix in descriptor code | `oof_registry.validation.excluded_namespace_collision` |
| PINV-*/TINV-* in oof_descriptors | `oof_registry.validation.support_marker_in_oof_descriptors` |
| Support marker with public stability | `oof_registry.validation.support_marker_public` |
| Support marker with emitted lifecycle_state/status_class | `oof_registry.validation.support_marker_emitted` |
| Support marker code collides with OOF code/alias | `oof_registry.validation.support_marker_code_collision` |
| oof row loadable:true | `oof_registry.validation.oof_projection_loadable` |
| oof row capability:true | `oof_registry.validation.oof_projection_capability` |
| olap/progression not `not_fragment_class` | `oof_registry.validation.guarded_non_fragment_violation` |
| Required excluded namespace prefixes absent | `oof_registry.validation.missing_section` |

These are **internal validator diagnostics only** — not public language OOF codes and not
central `IgniterLang::Diagnostics` entries.

### Absent-Owner Inactive Row Behavior

When `installed_boundaries:` is supplied:
- Rows whose `owner_pack_or_boundary` is absent from the installed set are
  recorded in `inactive_rows` — **not silently skipped**.
- Inactive rows have a `reason: "owner_pack_or_boundary_absent_from_installed_boundaries"` field.
- Shape-valid inactive rows do **not** flip `valid: false`.
- Inactive rows are **not emitted** — `closed_surface_assertions.compiler_integration: false`.
- Coverage: OOF descriptors, fragment rows, AND support markers (all three buckets).

---

## Proof Matrix — 27/27 PASS

### Valid fixture cases

| Check | Result |
| --- | --- |
| V1. valid_forward_shape_passes | PASS |
| V2. result_shape_fields_present | PASS |
| V3. closed_surface_assertions_all_false | PASS |
| V4. pinv_tinv_not_in_oof_descriptors | PASS |
| V5. pinv_tinv_in_support_markers_bucket | PASS |

### Rejection cases

| Check | Result |
| --- | --- |
| R1. duplicate_oof_descriptor_code_rejected | PASS |
| R2. alias_collision_rejected | PASS |
| R3. deprecated_without_replacement_rejected | PASS |
| R4. pinv_in_oof_descriptors_rejected | PASS |
| R5. tinv_in_oof_descriptors_rejected | PASS |
| R6. support_marker_public_stability_rejected | PASS |
| R7. support_marker_code_collision_rejected | PASS |
| R8. excluded_namespace_descriptor_rejected | PASS |
| R9. oof_fragment_loadable_rejected | PASS |
| R10. oof_fragment_capability_rejected | PASS |
| R11. olap_fragment_class_rejected | PASS |
| R12. progression_fragment_class_rejected | PASS |
| R13. missing_required_excluded_namespace_rejected | PASS |

### Absent-owner inactive-row cases

| Check | Result |
| --- | --- |
| INV-ABS1. absent_owner_rows_recorded_as_inactive | PASS |
| INV-ABS2. inactive_rows_not_emitted | PASS |
| INV-ABS3. no_boundary_check_without_installed_boundaries | PASS |

### Closed-surface assertions

| Check | Result |
| --- | --- |
| CS1. validator_not_in_igniter_lang_rb | PASS |
| CS2. validator_no_compiler_pass_methods | PASS |
| CS3. result_has_no_public_fields | PASS |
| CS4. data_file_does_not_exist | PASS |
| CS5. r92_historical_json_not_migrated | PASS |
| CS6. validator_no_public_cli_methods | PASS |

---

## Pinned 8-Command Proof Matrix

| Command | Result |
| --- | --- |
| `ruby -c lib/igniter_lang/oof_fragment_registry.rb` | Syntax OK |
| `ruby experiments/oof_fragment_registry_implementation_boundary_proof/oof_fragment_registry_implementation_boundary_proof.rb` | PASS (27/27) |
| `ruby experiments/classifier_pass_proof/classifier_pass_proof.rb` | PASS |
| `ruby experiments/typechecker_proof/typechecker_proof.rb --check-golden` | PASS |
| `ruby experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb --check-golden` | PASS |
| `ruby experiments/igapp_assembler_proof/igapp_assembler_proof.rb` | PASS |
| `ruby experiments/invariant_severity_proof/invariant_severity_proof.rb` | PASS |
| `ruby experiments/prop038_report_only_compiler_integration/prop038_report_only_compiler_integration.rb` | PASS |

---

## Closed-Surface Assertions

```text
compiler_integration:          false
public_api_cli:                false
top_level_report_diagnostics:  false
compiler_result_field:         false
loader_report:                 false
compatibility_report:          false
runtime_behavior:              false
igapp_mutation:                false
oof_fragment_registry_data_rb: false (file does not exist; separate later card)
lib_igniter_lang_rb_changed:   false
spec_proposal_canon_changed:   false
existing_golden_changed:       false
```

---

## R92 Historical JSON Note

`experiments/oof_fragment_registry_shadow_proof/out/oof_descriptors.shadow_registry.json`
is retained unchanged. It contains PINV-*/TINV-* inside `oof_descriptors` as historical
proof evidence from R92. That placement is **non-forward**:

- R98-A accepted PINV-*/TINV-* as support metadata, not OOF descriptors.
- R101-D1 pinned the forward shape with PINV-*/TINV-* exclusively under
  `support_markers.invariant_support_markers`.
- This implementation validates and enforces the forward shape.
- The R92 JSON is not migrated (non-migration policy, per LANG-R101-D1).

The forward fixture at `fixtures/forward_shape_valid.json` has zero PINV-*/TINV-* in
`oof_descriptors` and PINV-1, PINV-2, TINV-1 in `support_markers.invariant_support_markers`.

---

## Source-Authority Rules (Preserved From LANG-R102-A)

| Rule | Status |
| --- | --- |
| Implementation code cannot promote lifecycle state | ✓ Enforced — validator reads data only |
| PINV-*/TINV-* remain support metadata | ✓ Enforced — rejected in oof_descriptors |
| Support metadata cannot become public OOF without proposal/spec/gate | ✓ Enforced — no promotion path in validator |
| Guarded non-fragments remain non-fragments | ✓ Enforced — olap/progression rejected if classification_kind != "not_fragment_class" |
| Excluded namespaces remain excluded | ✓ Enforced — required prefixes checked, descriptor code rejection active |

---

## Remaining Blockers

1. **`oof_fragment_registry_data.rb`**: static internal data constants require a separate
   design or authorization card after this isolated validator proof passes.

2. **Compiler pass integration**: compiler-level OOF lookup (parser/classifier/TypeChecker)
   requires separate authority. This validator does not connect to any compiler pass.

3. **Report/CompilerResult/public API/CLI exposure**: internal result only; any public
   surface requires separate Bridge/Architect card.

4. **Loader/report or CompatibilityReport fields**: separately closed.

5. **Live pack registry or dispatch**: separately closed.

6. **Golden migration**: existing `.igapp` goldens are unchanged; any profiled-registry
   compilation output changes require a separate decision.

---

## Handoff

```text
Card: LANG-R103-I
Agent: [Igniter-Lang Implementation Agent]
Role: implementation-agent
Track: oof-fragment-registry-implementation-boundary-proof-v0
Status: done

[D]
- Implemented isolated internal registry validator (lib/igniter_lang/oof_fragment_registry.rb).
- Validator enforces R98 forward shape: PINV/TINV only under support_markers.invariant_support_markers.
- Absent-owner inactive rows: recorded in result, not silently skipped, not emitted.
- Valid/invalid separation: valid=true when diags empty; inactive rows do not flip valid.
- R92 historical JSON untouched (non-migration policy).
- oof_fragment_registry_data.rb not created (explicitly out of first slice).
- lib/igniter_lang.rb unchanged (validator not required from public entrypoint).

[S]
- 27/27 proof checks PASS.
- 8/8 pinned parity commands PASS.
- All closed-surface assertions: false.

[T]
- ruby -c lib/igniter_lang/oof_fragment_registry.rb       → Syntax OK
- ruby .../oof_fragment_registry_implementation_boundary_proof.rb → PASS 27/27
- All 6 parity commands                                    → PASS

[R]
- No caller today uses OOFFragmentRegistry outside the proof script.
- Compiler integration, public API, and oof_fragment_registry_data.rb remain
  separately blocked; each requires a new authorization card.

[Next]
- Architect may authorize oof_fragment_registry_data.rb (static internal constants).
- Architect may authorize compiler pass lookup integration (separate bounded slice).
```
