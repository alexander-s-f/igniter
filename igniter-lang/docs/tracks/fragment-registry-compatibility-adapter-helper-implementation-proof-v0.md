# Track: Fragment Registry Compatibility Adapter Helper Implementation Proof v0

Card: S3-R147-C2-I
Agent: `[Igniter-Lang Implementation Agent]`
Role: implementation-agent
Route: UPDATE
Track: `fragment-registry-compatibility-adapter-helper-implementation-proof-v0`
Status: done
Date: 2026-05-22

Authorized by: S3-R147-C1-A
Depends on: S3-R147-C1-A, S3-R147-C2-S

---

## Goal

Create the bounded direct-require-only internal fragment registry compatibility
adapter helper and prove that it preserves R144 selected-fragment compatibility
while remaining unwired from live classifier dispatch and all public/report/
artifact/runtime/Spark/production surfaces.

---

## Evidence Read

- `docs/gates/fragment-registry-compatibility-adapter-helper-implementation-authorization-review-v0.md`
- `docs/gates/fragment-registry-compatibility-adapter-helper-boundary-proof-decision-v0.md`
- `docs/tracks/fragment-registry-compatibility-adapter-internal-helper-boundary-proof-v0.md`
- `docs/tracks/stage3-round147-status-curation-v0.md`
- `experiments/fragment_registry_compatibility_adapter_internal_helper_boundary_proof/out/helper_input_shape.json`
- `experiments/fragment_registry_compatibility_adapter_internal_helper_boundary_proof/out/helper_result_shape.json`
- `experiments/fragment_registry_compatibility_adapter_internal_helper_boundary_proof/out/fragment_registry_compatibility_adapter_internal_helper_boundary_summary.json`

---

## Changed Files

```text
lib/igniter_lang/fragment_registry_compatibility_adapter.rb               NEW
experiments/fragment_registry_compatibility_adapter_helper_implementation_proof/
  fragment_registry_compatibility_adapter_helper_implementation_proof.rb  NEW
  out/fragment_registry_compatibility_adapter_helper_implementation_proof_summary.json  NEW
  out/helper_implementation_result.json                                   NEW
docs/tracks/fragment-registry-compatibility-adapter-helper-implementation-proof-v0.md  NEW (this)
```

No other file changed. Explicitly not created or modified:

```text
lib/igniter_lang.rb                                    UNCHANGED
lib/igniter_lang/classifier.rb                        UNCHANGED
lib/igniter_lang/compilation_report.rb                UNCHANGED
lib/igniter_lang/compiler_result.rb                   UNCHANGED
lib/igniter_lang/assembler.rb                         UNCHANGED
lib/igniter_lang/semanticir_emitter.rb                UNCHANGED
lib/igniter_lang/cli.rb                               UNCHANGED
any .igapp / golden / compiler pass / runtime file    UNCHANGED
```

---

## Implementation

### `lib/igniter_lang/fragment_registry_compatibility_adapter.rb`

```ruby
IgniterLang::FragmentRegistryCompatibilityAdapter.project(input_hash) -> result_hash
```

Direct-require-only. Not required from `lib/igniter_lang.rb`. Not wired into
the live classifier. Result is internal-only.

**Selection rules (R146 proof selection order, exact):**

```text
if oof present      → oof
elsif temporal      → temporal
elsif escape        → escape
elsif stream        → escape   (stream → escape, not a direct fragment)
elsif epistemic     → epistemic
else                → core
```

Constants:

```ruby
FORMAT_VERSION = "0.1.0"
KIND_INPUT     = "fragment_registry_compatibility_adapter_helper_input"
KIND_RESULT    = "fragment_registry_compatibility_adapter_helper_result"
SELECTION_RULES = [
  { presence: "oof",       selected: "oof"       },
  { presence: "temporal",  selected: "temporal"  },
  { presence: "escape",    selected: "escape"    },
  { presence: "stream",    selected: "escape"    },
  { presence: "epistemic", selected: "epistemic" }
]
DEFAULT_SELECTED = "core"
```

Private class methods: `select_fragment(presence_list)`, `rules_in_order_description`.

---

## Proof Summary — 44/44 PASS

```text
status:           PASS
checks_total:     44
checks_pass:      44
r144_contracts:   23
r144_mismatches:  0
input_digest:     47e938fdea0e46e067a2c88b
result_digest:    c109ef1b1b124fd825172327
```

Input digest `47e938fdea0e46e067a2c88b` matches the R146 C1 accepted helper
input digest exactly.

### Result shape checks (RS1–RS6)

| Check | Result |
| --- | --- |
| RS1. result_kind_correct | PASS |
| RS2. result_format_version | PASS |
| RS3. held_live_dispatch_true | PASS |
| RS4. classifier_wiring_authorized_false | PASS |
| RS5. selected_fragment_projection_present | PASS |
| RS6. rules_in_order_present (6 rules) | PASS |

### R144 parity checks (R144.*)

| Check | Result |
| --- | --- |
| R144. row_count_23 | PASS |
| R144. all_rows_pass | PASS |
| R144. mismatches_empty | PASS |
| R144. r144_parity_preserved | PASS |
| R144. r144_source_digest_matches | PASS |

### Required compatibility cases (COMPAT1–COMPAT5)

| Check | Result |
| --- | --- |
| COMPAT1. stream_presence_selects_escape | PASS |
| COMPAT2. epistemic_plus_escape_selects_escape | PASS |
| COMPAT3. epistemic_only_selects_epistemic | PASS |
| COMPAT4. temporal_plus_escape_selects_temporal | PASS |
| COMPAT5. oof_present_selects_oof | PASS |

### OOF projection policy (OOF1–OOF4)

| Check | Result |
| --- | --- |
| OOF1. policy_status_primary | PASS |
| OOF2. policy_blocked_true | PASS |
| OOF3. policy_loadable_false | PASS |
| OOF4. policy_capability_false | PASS |

### Guarded non-fragments (GNF1–GNF3)

| Check | Result |
| --- | --- |
| GNF1. olap_is_guarded_non_fragment (not_fragment_class) | PASS |
| GNF2. progression_is_guarded_non_fragment (not_fragment_class) | PASS |
| GNF3. guarded_selected_fragment_null | PASS |

### Dynamic closed-surface checks (CS1–CS10)

All checks are live filesystem/content reads — not hardcoded static values.

| Check | Result |
| --- | --- |
| CS1. helper_file_exists_at_authorized_path | PASS |
| CS2. root_require_does_not_reference_helper | PASS |
| CS3. classifier_does_not_reference_helper | PASS |
| CS4. no_live_classifier_dispatch_method | PASS |
| CS5. classifier_wiring_false_in_result | PASS |
| CS6. held_live_dispatch_true_in_result | PASS |
| CS7. no_classifiedprogram_field_added | PASS |
| CS8. no_compilation_report_or_compiler_result_change | PASS |
| CS9. no_assembler_or_semanticir_reference | PASS |
| CS10. no_cli_reference | PASS |

### Broad negative vocabulary scan (NEG1)

Scanned: all `lib/igniter_lang/*.rb` files (18 files).

Forbidden terms outside the authorized helper file:

```text
fragment_registry_compatibility_adapter
FragmentRegistryCompatibilityAdapter
declaration_fragment_presence
selected_fragment_projection
```

| Check | Result |
| --- | --- |
| NEG1. vocab_scan_no_hits_outside_helper | PASS |

Result: **CLEAN — 0 hits** in any file outside
`lib/igniter_lang/fragment_registry_compatibility_adapter.rb`.

### Regression matrix (REG.*)

| Check | Result |
| --- | --- |
| REG. classifier_pass_proof.passes | PASS |
| REG. contract_modifiers_proof.passes | PASS |
| REG. assumptions_proof.passes | PASS |
| REG. source_to_semanticir_fixture.passes | PASS |
| REG. igapp_assembler_proof.passes | PASS |
| REG. invariant_severity_proof.passes | PASS |

### Parity evidence (PARITY.*)

| Check | Result |
| --- | --- |
| PARITY. igapp_result_summary_stable | PASS |
| PARITY. semanticir_golden_stable | PASS |
| PARITY. regression_all_commands_passed | PASS |
| PARITY. assumptions_golden_stable | PASS |

---

## Command Matrix

| Command | Required | Result |
| --- | --- | --- |
| `ruby -c igniter-lang/lib/igniter_lang/fragment_registry_compatibility_adapter.rb` | Syntax OK | **PASS** |
| `ruby igniter-lang/experiments/fragment_registry_compatibility_adapter_helper_implementation_proof/fragment_registry_compatibility_adapter_helper_implementation_proof.rb` | PASS; 44 checks | **PASS (44/44)** |
| `ruby igniter-lang/experiments/classifier_pass_proof/classifier_pass_proof.rb` | PASS; 21 named checks | **PASS** |
| `ruby igniter-lang/experiments/contract_modifiers_proof/contract_modifiers_proof.rb` | PASS; 20 named checks | **PASS** |
| `ruby igniter-lang/experiments/assumptions_proof/assumptions_proof.rb` | PASS; 39 named checks | **PASS** |
| `ruby igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb --check-golden` | PASS; 31 named checks | **PASS** |
| `ruby igniter-lang/experiments/igapp_assembler_proof/igapp_assembler_proof.rb` | PASS; 17 named checks | **PASS** |
| `ruby igniter-lang/experiments/invariant_severity_proof/invariant_severity_proof.rb` | PASS; 34 named checks | **PASS** |

---

## Byte-for-Byte Parity Evidence

| Artifact | Path | Digest |
| --- | --- | --- |
| .igapp result summary | `experiments/igapp_assembler_proof/out/result_summary.json` | `f8b4426843a85b6a03d6629a` |
| SemanticIR golden dir (23 files) | `experiments/source_to_semanticir_fixture/golden/` | `f3f7fa48455bed3adb2e8777` |
| Assumptions golden dir (12 files) | `experiments/assumptions_proof/golden/` | `156da071b981e15cc32fea13` |
| Contract modifiers golden dir (23 files) | `experiments/contract_modifiers_proof/golden/` | `319721cd4d9e10f0a23c4fa1` |
| Invariant severity summary | `experiments/invariant_severity_proof/summary.json` | `b47e6cf8f64de68cd911c516` |

SemanticIR and .igapp parity: `--check-golden` and assembler proof verify byte-for-byte
against existing golden files, which are unchanged (no golden mutation occurred).

---

## Broad Negative Vocabulary Scan

Scanned 18 `lib/igniter_lang/*.rb` files for 4 forbidden terms:

```text
fragment_registry_compatibility_adapter
FragmentRegistryCompatibilityAdapter
declaration_fragment_presence
selected_fragment_projection
```

Result: **0 hits** outside the authorized helper file.

Additional targeted scans:

| File | Result |
| --- | --- |
| `lib/igniter_lang.rb` | CLEAN |
| `lib/igniter_lang/classifier.rb` | CLEAN |
| `lib/igniter_lang/compilation_report.rb` | CLEAN |
| `lib/igniter_lang/assembler.rb` | CLEAN |
| `lib/igniter_lang/cli.rb` | CLEAN |
| `lib/igniter_lang/compiler_result.rb` | CLEAN |
| `lib/igniter_lang/semanticir_emitter.rb` | CLEAN |

---

## Closed-Surface Assertions

```text
helper_file_exists_at_authorized_path:      true (AUTHORIZED — verified dynamically)
root_require_references_helper:             false
classifier_references_helper:               false
live_classifier_dispatch:                   false
classifiedprogram_field_added:              false
compilation_report_changed:                 false
compiler_result_changed:                    false
assembler_changed:                          false
semanticir_emitter_changed:                 false
cli_changed:                                false
igapp_golden_mutated:                       false
source_to_semanticir_golden_mutated:        false
prop036_mutated:                            false
prop038_mutated:                            false
runtime_spark_production_changed:           false
```

---

## Handoff

```text
Card: S3-R147-C2-I
Agent: [Igniter-Lang Implementation Agent]
Role: implementation-agent
Track: fragment-registry-compatibility-adapter-helper-implementation-proof-v0
Status: done

[D]
- Created lib/igniter_lang/fragment_registry_compatibility_adapter.rb.
- Implemented IgniterLang::FragmentRegistryCompatibilityAdapter.project(input_hash).
- R146 selection rules exact: oof > temporal > escape > stream→escape > epistemic > core.
- Direct-require-only; not required from lib/igniter_lang.rb.
- Not wired into classifier; held_live_dispatch: true; classifier_wiring_authorized: false.

[S]
- 44/44 proof checks PASS.
- 23/23 R144 contracts preserve current selected fragment; 0 mismatches.
- R144 source digest confirmed: 47e938fdea0e46e067a2c88b.
- Regression matrix: 6/6 required commands PASS.
- Broad vocab scan: CLEAN (0 hits outside authorized file).
- All dynamic closed-surface checks: PASS.
- All parity evidence recorded.

[T]
- ruby -c lib/igniter_lang/fragment_registry_compatibility_adapter.rb  → Syntax OK
- Helper implementation proof runner                                   → PASS 44/44
- classifier_pass_proof                                                → PASS
- contract_modifiers_proof                                             → PASS
- assumptions_proof                                                    → PASS
- source_to_semanticir_fixture --check-golden                          → PASS
- igapp_assembler_proof                                                → PASS
- invariant_severity_proof                                             → PASS

[R]
- Classifier wiring and live classifier dispatch remain closed.
- The helper is available for future authorized callers via direct require.
- No ClassifiedProgram schema field was added.
- No public/report/artifact/runtime/Spark/production surface opened.
- A separate later gate is required for any classifier wiring consideration.
```
