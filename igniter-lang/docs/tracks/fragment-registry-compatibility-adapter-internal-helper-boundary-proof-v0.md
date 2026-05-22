# Fragment Registry Compatibility Adapter Internal Helper Boundary Proof v0

Card: S3-R146-C1-P1  
Agent: `[Igniter-Lang Research Agent]`  
Role: `research-agent`  
Route: UPDATE  
Depends on: S3-R145-C4-A / `fragment-registry-adapter-implementation-boundary-decision-v0`  
Track: `fragment-registry-compatibility-adapter-internal-helper-boundary-proof-v0`  
Status: done / PASS  
Date: 2026-05-22

---

## Role And Neighbor Awareness

Assigned track: model and prove the proof-only internal helper API/result
boundary for the fragment registry compatibility adapter.

Affected neighbor roles:

- `[Igniter-Lang Compiler/Grammar Expert]` - owns final selected-fragment
  semantics and any later implementation-candidate review.
- `[Igniter-Lang Bridge Agent]` - must review before public/report/loader,
  CompatibilityReport, `.igapp`, runtime, production, or Spark surfaces open.

---

## Current Horizon

```text
R144 proves two-layer adapter parity against 23 observed classifier goldens.
R145 accepts only proof/design route; implementation and classifier wiring stay held.
R146 models an internal helper input/result boundary without creating a lib file.
Negative scans prove no root require, classifier wiring, report, artifact, public,
runtime, or Spark surface is touched.
```

---

## Read Set

- `docs/gates/fragment-registry-adapter-implementation-boundary-decision-v0.md`
- `docs/tracks/fragment-registry-adapter-implementation-boundary-design-v0.md`
- `docs/tracks/fragment-registry-adapter-evidence-and-risk-map-v0.md`
- `docs/discussions/fragment-registry-adapter-boundary-pressure-v0.md`
- `docs/tracks/fragment-precedence-compatibility-adapter-proof-v0.md`
- `experiments/fragment_precedence_compatibility_adapter_proof/out/fragment_precedence_compatibility_adapter_summary.json`
- `experiments/fragment_precedence_compatibility_adapter_proof/out/fragment_precedence_compatibility_adapter_matrix.json`

---

## Proof Artifacts

Runner:

```text
igniter-lang/experiments/fragment_registry_compatibility_adapter_internal_helper_boundary_proof/fragment_registry_compatibility_adapter_internal_helper_boundary_proof.rb
```

Generated proof-local outputs:

```text
igniter-lang/experiments/fragment_registry_compatibility_adapter_internal_helper_boundary_proof/out/helper_input_shape.json
igniter-lang/experiments/fragment_registry_compatibility_adapter_internal_helper_boundary_proof/out/helper_result_shape.json
igniter-lang/experiments/fragment_registry_compatibility_adapter_internal_helper_boundary_proof/out/fragment_registry_compatibility_adapter_internal_helper_boundary_summary.json
```

Digests:

```text
helper_input_digest: 47e938fdea0e46e067a2c88b
helper_result_digest: ae26685d3afd77a2e2cc35c5
source_r144_matrix_digest: 65e876f5ae23ce761c16b704
```

---

## Helper Input Shape

The proof models an input object:

```json
{
  "kind": "fragment_registry_compatibility_adapter_helper_input",
  "format_version": "0.1.0",
  "boundary_mode": "proof_only_internal_helper",
  "direct_require_only_if_later_implemented": true,
  "classifier_wiring_authorized": false,
  "contracts": [
    {
      "contract_ref": "...",
      "declaration_fragment_presence": ["core", "escape", "stream"],
      "current_selected_fragment": "escape"
    }
  ],
  "guarded_non_fragments": [
    {
      "name": "olap",
      "classification_kind": "not_fragment_class",
      "selected_fragment": null
    },
    {
      "name": "progression",
      "classification_kind": "not_fragment_class",
      "selected_fragment": null
    }
  ],
  "oof_projection_policy": {
    "primary_semantics": "status",
    "blocked": true,
    "loadable": false,
    "capability": false
  }
}
```

This is proof-local. It is not a `ClassifiedProgram` schema change and is not
compiler input.

---

## Helper Result Shape

The proof models a result object:

```json
{
  "kind": "fragment_registry_compatibility_adapter_helper_result",
  "format_version": "0.1.0",
  "boundary_mode": "proof_only_internal_helper",
  "selected_fragment_projection": {
    "rows": [],
    "mismatches": []
  },
  "held_live_dispatch": true,
  "classifier_wiring_authorized": false
}
```

The result preserves R144 selected-fragment compatibility. It is not live
classifier dispatch, not report output, and not artifact metadata.

---

## Presence And Selected-Fragment Projection

Rules:

```text
if oof present:       selected = oof
elsif temporal:       selected = temporal
elsif escape:         selected = escape
elsif stream:         selected = escape
elsif epistemic:      selected = epistemic
else:                 selected = core
```

Projection result:

```text
observed_contract_count: 23
selected_fragment_mismatches: []
```

Required cases:

| Case | Result |
| --- | --- |
| Stream presence still selects `escape` | PASS |
| Epistemic + escape still selects `escape` | PASS |
| Epistemic-only still selects `epistemic` | PASS |
| Temporal + escape still selects `temporal` | PASS |
| OOF remains status-primary / blocked / non-loadable / non-capability | PASS |
| `olap` and `progression` remain guarded non-fragments | PASS |
| R144 selected-fragment compatibility is preserved | PASS |

---

## Negative Scans

| Scan | Target | Result |
| --- | --- | --- |
| Root require | `lib/igniter_lang.rb` | PASS |
| Classifier wiring | `lib/igniter_lang/classifier.rb` | PASS |
| Report surface | `lib/igniter_lang/compilation_report.rb` | PASS |
| `.igapp` / assembler surface | `lib/igniter_lang/assembler.rb` | PASS |
| Public CLI surface | `lib/igniter_lang/cli.rb` | PASS |
| Runtime surface | `lib/igniter_lang/temporal_executor.rb` | PASS |
| Spark surface | `experiments/sparkcrm_bihistory_fixture/sparkcrm_bihistory_fixture.rb` | PASS |

All scans returned no hits for the proof helper vocabulary or
`declaration_fragment_presence`.

---

## Command Matrix

| Command | Result |
| --- | --- |
| `ruby igniter-lang/experiments/fragment_registry_compatibility_adapter_internal_helper_boundary_proof/fragment_registry_compatibility_adapter_internal_helper_boundary_proof.rb` | PASS |
| `ruby igniter-lang/experiments/classifier_pass_proof/classifier_pass_proof.rb` | PASS |
| `ruby igniter-lang/experiments/contract_modifiers_proof/contract_modifiers_proof.rb` | PASS |
| `ruby igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb --check-golden` | PASS |
| `ruby igniter-lang/experiments/igapp_assembler_proof/igapp_assembler_proof.rb` | PASS |
| `ruby -c igniter-lang/experiments/fragment_registry_compatibility_adapter_internal_helper_boundary_proof/fragment_registry_compatibility_adapter_internal_helper_boundary_proof.rb` | Syntax OK |

Proof runner output:

```text
PASS fragment_registry_compatibility_adapter_internal_helper_boundary
check_count: 19
failed_checks: []
summary: ae26685d3afd77a2e2cc35c5
```

---

## Blockers Before Implementation Authorization

Implementation remains blocked until a later gate explicitly decides:

- whether a `lib/igniter_lang/fragment_registry_compatibility_adapter.rb`
  helper file may be created;
- whether it is direct-require-only or root-required;
- whether classifier wiring remains forbidden or is explicitly opened;
- whether helper output can remain purely internal or must become a
  `ClassifiedProgram` field;
- exact byte-for-byte classifier parity requirements;
- exact TypeChecker, SemanticIR, assembler, report, `.igapp`, and stage
  regression matrix;
- negative vocabulary scans for public/report/runtime/Spark surfaces;
- PROP-036 and PROP-038 non-mutation assertions.

Classifier wiring is explicitly forbidden for the next implementation candidate
unless a later gate opens it.

---

## Closed Surfaces

This proof does not authorize:

- implementation;
- a `lib/` helper file;
- root require;
- classifier wiring or `contract_fragment_for` replacement;
- parser, TypeChecker, SemanticIR, assembler, report, `.igapp`, public API/CLI,
  runtime, Spark, production, or proposal edits;
- existing golden mutation;
- `ClassifiedProgram` schema changes;
- `CompilationReport`, `CompilerResult`, loader/report, or CompatibilityReport
  changes;
- PROP-036 or PROP-038 behavior mutation;
- RuntimeMachine, Gate 3, Ledger/TBackend, BiHistory, stream/OLAP production
  executors, cache, signing, or deployment behavior.

---

## Changed Files

```text
igniter-lang/docs/tracks/fragment-registry-compatibility-adapter-internal-helper-boundary-proof-v0.md
igniter-lang/experiments/fragment_registry_compatibility_adapter_internal_helper_boundary_proof/fragment_registry_compatibility_adapter_internal_helper_boundary_proof.rb
igniter-lang/experiments/fragment_registry_compatibility_adapter_internal_helper_boundary_proof/out/helper_input_shape.json
igniter-lang/experiments/fragment_registry_compatibility_adapter_internal_helper_boundary_proof/out/helper_result_shape.json
igniter-lang/experiments/fragment_registry_compatibility_adapter_internal_helper_boundary_proof/out/fragment_registry_compatibility_adapter_internal_helper_boundary_summary.json
```

---

## Handoff

[D] R146 proves a proof-only internal helper boundary for the fragment registry
compatibility adapter, without creating a `lib/` helper or wiring classifier.

[S] Helper input/result shape preserves R144 selected-fragment compatibility:
stream -> `escape`, epistemic+escape -> `escape`, epistemic-only ->
`epistemic`, temporal+escape -> `temporal`, OOF -> blocked status projection.

[T] PASS: proof runner, classifier regression, contract modifiers regression,
source-to-SemanticIR golden check, igapp assembler proof, syntax check, and
negative scans.

[R] Accept proof-only helper boundary evidence. Hold implementation and
classifier wiring until a later gate opens an exact write scope.

[Next] Architect/Compiler should decide whether a direct-require-only `lib/`
helper implementation card is warranted; classifier wiring should remain closed.
