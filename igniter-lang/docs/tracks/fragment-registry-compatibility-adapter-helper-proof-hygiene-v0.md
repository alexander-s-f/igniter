# Fragment Registry Compatibility Adapter Helper Proof Hygiene v0

Card: S3-R149-C1-P1  
Agent: `[Igniter-Lang Research Agent]`  
Role: `research-agent`  
Route: UPDATE  
Depends on: S3-R148-C2-A  
Track: `fragment-registry-compatibility-adapter-helper-proof-hygiene-v0`  
Status: done / PASS  
Date: 2026-05-23

---

## Role And Neighbor Awareness

Assigned track: clean the accepted helper implementation proof harness without
changing helper code or opening compiler/runtime surfaces.

Affected neighbor roles:

- `[Igniter-Lang Compiler/Grammar Expert]` - owns any later classifier wiring
  or selected-fragment live dispatch review.
- `[Igniter-Lang Bridge Agent]` - owns pressure before public/report/loader,
  CompatibilityReport, `.igapp`, runtime, production, or Spark surfaces open.

---

## Current Horizon

```text
R148 accepted the direct-require-only helper implementation and its proof.
The helper remains unwired from root require and live classifier dispatch.
This slice repairs proof reporting only: CS4 scan logic, vocab counts, closed
surface derivation, and command-count evidence.
No helper/lib/compiler/runtime behavior changed.
```

---

## Read Set

- `docs/gates/fragment-registry-compatibility-adapter-helper-implementation-acceptance-decision-v0.md`
- `docs/discussions/fragment-registry-compatibility-adapter-helper-implementation-pressure-v0.md`
- `docs/tracks/stage3-round148-status-curation-v0.md`
- `docs/tracks/fragment-registry-compatibility-adapter-helper-implementation-proof-v0.md`
- `experiments/fragment_registry_compatibility_adapter_helper_implementation_proof/fragment_registry_compatibility_adapter_helper_implementation_proof.rb`
- `experiments/fragment_registry_compatibility_adapter_helper_implementation_proof/out/fragment_registry_compatibility_adapter_helper_implementation_proof_summary.json`

---

## Hygiene Changes

| Area | Before | After |
| --- | --- | --- |
| CS4 method scan | Intersected `methods(false)` and `private_methods(false)`, making the forbidden method set effectively empty. | Scans the union: `methods(false) + private_methods(false)`, then checks forbidden dispatch-like names. |
| Vocabulary scan counts | Reported `scanned_files: 19`, while the authorized helper file was skipped. | Reports `19 total / 18 checked / 1 authorized skipped`, with skipped path recorded. |
| Closed surfaces | Summary used duplicated static false values. | Summary derives closed-surface assertions from live CS/NEG/PARITY checks where practical. |
| Command counts | Pinned counts existed but were not surfaced/asserted. | Summary records expected and observed `: ok` counts; all exposed counts are machine-asserted. |

This did not change the proof case count:

```text
checks: 44/44
r144_contracts: 23/23
r144_mismatches: 0
input_digest: 47e938fdea0e46e067a2c88b
result_digest: c109ef1b1b124fd825172327
```

---

## Updated Summary Fields

Vocabulary scan:

```json
{
  "total_files": 19,
  "checked_files": 18,
  "authorized_skipped_files": 1,
  "scan_count_label": "19 total / 18 checked / 1 authorized skipped",
  "hits": []
}
```

Regression matrix count assertions:

| Command | Expected | Observed | Assertion |
| --- | ---: | ---: | --- |
| `classifier_pass_proof` | 21 | 21 | PASS / machine asserted |
| `contract_modifiers_proof` | 20 | 20 | PASS / machine asserted |
| `assumptions_proof` | 39 | 39 | PASS / machine asserted |
| `source_to_semanticir_fixture --check-golden` | 31 | 31 | PASS / machine asserted |
| `igapp_assembler_proof` | 17 | 17 | PASS / machine asserted |
| `invariant_severity_proof` | 34 | 34 | PASS / machine asserted |

Closed-surface assertions are now derived from live checks:

```text
root_require_references_helper: false
classifier_references_helper: false
live_classifier_dispatch: false
classifiedprogram_field_added: false
compilation_report_or_compiler_result_changed: false
assembler_or_semanticir_reference_added: false
cli_reference_added: false
unauthorized_vocab_hits_outside_helper: false
regression_matrix_failed: false
```

---

## Command Matrix

| Command | Result |
| --- | --- |
| `ruby igniter-lang/experiments/fragment_registry_compatibility_adapter_helper_implementation_proof/fragment_registry_compatibility_adapter_helper_implementation_proof.rb` | PASS, 44/44 |
| `ruby igniter-lang/experiments/classifier_pass_proof/classifier_pass_proof.rb` | PASS, 21 `: ok` checks |
| `ruby igniter-lang/experiments/contract_modifiers_proof/contract_modifiers_proof.rb` | PASS, 20 `: ok` checks |
| `ruby igniter-lang/experiments/assumptions_proof/assumptions_proof.rb` | PASS, 39 `: ok` checks |
| `ruby igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb --check-golden` | PASS, 31 `: ok` checks |
| `ruby igniter-lang/experiments/igapp_assembler_proof/igapp_assembler_proof.rb` | PASS, 17 `: ok` checks |
| `ruby igniter-lang/experiments/invariant_severity_proof/invariant_severity_proof.rb` | PASS, 34 `: ok` checks |

Additional local checks:

| Command | Result |
| --- | --- |
| `ruby -c igniter-lang/experiments/fragment_registry_compatibility_adapter_helper_implementation_proof/fragment_registry_compatibility_adapter_helper_implementation_proof.rb` | Syntax OK |

---

## Closed Surfaces

Still closed:

- No edits to `lib/igniter_lang/fragment_registry_compatibility_adapter.rb`.
- No root require from `lib/igniter_lang.rb`.
- No classifier wiring or live dispatch.
- No parser, TypeChecker, SemanticIR, assembler, report, `.igapp`, public
  API/CLI, runtime, Spark, production, proposal, or golden changes.
- No authorization for classifier wiring, root require, live dispatch, or
  compiler/runtime surface expansion.

---

## Changed Files

```text
experiments/fragment_registry_compatibility_adapter_helper_implementation_proof/
  fragment_registry_compatibility_adapter_helper_implementation_proof.rb
  out/fragment_registry_compatibility_adapter_helper_implementation_proof_summary.json
docs/tracks/fragment-registry-compatibility-adapter-helper-proof-hygiene-v0.md
```

---

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/fragment-registry-compatibility-adapter-helper-proof-hygiene-v0
Status: done
Neighbors: Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- CS4 now scans the union of public and private singleton methods.
- Vocab scan reports 19 total / 18 checked / 1 authorized skipped.
- Closed-surface assertions are derived from live proof checks where practical.
- Command-count assertions are machine-asserted only from exposed `: ok` output.

[R] Recommendations:
- Accept R149 hygiene closure.
- Keep classifier wiring, root require, and live dispatch held until a later gate.

[S] Signals:
- Helper implementation behavior and digests are unchanged.
- Proof remains 44/44 PASS.
- Regression matrix count assertions all PASS.

[T] Tests / Proofs:
- PASS `ruby igniter-lang/experiments/fragment_registry_compatibility_adapter_helper_implementation_proof/fragment_registry_compatibility_adapter_helper_implementation_proof.rb`
- PASS `ruby igniter-lang/experiments/classifier_pass_proof/classifier_pass_proof.rb`
- PASS `ruby igniter-lang/experiments/contract_modifiers_proof/contract_modifiers_proof.rb`
- PASS `ruby igniter-lang/experiments/assumptions_proof/assumptions_proof.rb`
- PASS `ruby igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb --check-golden`
- PASS `ruby igniter-lang/experiments/igapp_assembler_proof/igapp_assembler_proof.rb`
- PASS `ruby igniter-lang/experiments/invariant_severity_proof/invariant_severity_proof.rb`

[Files] Changed:
- `igniter-lang/experiments/fragment_registry_compatibility_adapter_helper_implementation_proof/fragment_registry_compatibility_adapter_helper_implementation_proof.rb`
- `igniter-lang/experiments/fragment_registry_compatibility_adapter_helper_implementation_proof/out/fragment_registry_compatibility_adapter_helper_implementation_proof_summary.json`
- `igniter-lang/docs/tracks/fragment-registry-compatibility-adapter-helper-proof-hygiene-v0.md`

[Q] Open Questions:
- None for this hygiene slice.

[X] Rejected:
- No helper/lib/compiler/runtime behavior change.
- No root require, classifier wiring, public API/CLI, report, artifact, runtime,
  production, Spark, or proposal change.

[Next] Proposed next slice:
- If authorized later, prepare an implementation-gate review for direct-require
  helper consumers; do not wire classifier dispatch from this proof.
```
