# Track: Runtime CompatibilityReport Temporal Load Check v0

Card: S3-R7-C1-P
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `igniter-lang/runtime-compatibility-report-temporal-load-check-v0`
Status: done
Date: 2026-05-08

Affected neighbor roles: `[Igniter-Lang Compiler/Grammar Expert]`,
`[Igniter-Lang Bridge Agent]`

---

## Goal

Turn the TEMPORAL `.igapp/` load-time guard into a concrete
CompatibilityReport-shaped boundary without enabling production temporal
execution, Ledger binding, or live TBackend operations.

---

## Current Horizon

- Production compiler path is `Parser -> Classifier -> TypeChecker ->
  SemanticIREmitter.emit_typed -> Assembler`.
- TEMPORAL artifacts assemble with `manifest.fragment_summary`,
  `manifest.contract_index`, and `compatibility_metadata.runtime_execution`.
- Runtime may load TEMPORAL `.igapp/` artifacts for inspection.
- Runtime evaluate for TEMPORAL remains blocked until executor/TBackend work is
  approved.
- This slice makes the load/evaluate distinction visible in a report-only
  CompatibilityReport shape.

---

## Decision

[D] The report boundary keeps the existing guard policy:

```text
load_accept_evaluate_refuse
```

Load is represented as:

```json
{
  "bundle_load": {
    "decision": "accept_for_inspection",
    "blocked": false,
    "guard_policy": "load_accept_evaluate_refuse"
  }
}
```

Evaluation readiness is represented separately:

```json
{
  "evaluation_readiness": {
    "decision": "blocked",
    "blocks_bundle_load": false,
    "guard_at": "evaluate"
  }
}
```

[D] Missing temporal TBackend capability blocks evaluation readiness, not bundle
loading.

[D] A metadata-only runtime profile with the required capability still blocks
evaluation because there is no temporal executor and no live TBackend binding.

[D] The report remains report-only:

```json
{
  "report_only": true,
  "runtime_enforced": false
}
```

---

## Implemented Proof

Added:

```text
igniter-lang/experiments/runtime_compatibility_report_temporal_load_check/
  runtime_compatibility_report_temporal_load_check.rb
  out/runtime_compatibility_report_temporal_load_check_summary.json
  out/assembled/*.igapp/
```

The proof assembles the existing `history_valid` and `bihistory_valid`
TEMPORAL SemanticIR goldens, then builds CompatibilityReport-shaped payloads
from:

| Artifact evidence | Report use |
| --- | --- |
| `manifest.fragment_summary` | confirms max fragment is `temporal` |
| `manifest.contract_index` | identifies TEMPORAL contracts, axes, coordinates, required capabilities, and cache hint |
| `compatibility_metadata.runtime_execution.guard_policy` | preserves `load_accept_evaluate_refuse` and `guard_at: evaluate` |
| runtime profile capabilities | drives `backend_check` and `evaluation_readiness` |

Cases:

| Case | Bundle load | Evaluation readiness | Reason |
| --- | --- | --- | --- |
| History, missing capability | accepted for inspection | blocked | `runtime.temporal_capability_missing` |
| BiHistory, missing capability | accepted for inspection | blocked | `runtime.temporal_capability_missing` |
| History, metadata capability only | accepted for inspection | blocked | `runtime.temporal_execution_unsupported` |
| BiHistory, metadata capability only | accepted for inspection | blocked | `runtime.temporal_execution_unsupported` |

---

## Proof Output

Command:

```bash
ruby igniter-lang/experiments/runtime_compatibility_report_temporal_load_check/runtime_compatibility_report_temporal_load_check.rb
```

Observed output:

```text
PASS runtime_compatibility_report_temporal_load_check
history_valid.report_consumes_fragment_summary: ok
history_valid.report_consumes_contract_index: ok
history_valid.report_consumes_guard_policy: ok
history_valid.detects_required_tbackend_capability: ok
history_valid.detects_temporal_axes: ok
history_valid.missing_capability_blocks_evaluation_not_load: ok
history_valid.capability_metadata_still_blocks_without_executor: ok
history_valid.report_only_no_live_binding: ok
bihistory_valid.report_consumes_fragment_summary: ok
bihistory_valid.report_consumes_contract_index: ok
bihistory_valid.report_consumes_guard_policy: ok
bihistory_valid.detects_required_tbackend_capability: ok
bihistory_valid.detects_temporal_axes: ok
bihistory_valid.missing_capability_blocks_evaluation_not_load: ok
bihistory_valid.capability_metadata_still_blocks_without_executor: ok
bihistory_valid.report_only_no_live_binding: ok
```

Summary:

```text
igniter-lang/experiments/runtime_compatibility_report_temporal_load_check/out/runtime_compatibility_report_temporal_load_check_summary.json
```

---

## Non-Authorization

This proof does not authorize:

- production RuntimeMachine temporal execution
- live Ledger or TBackend binding
- adapter selection from report metadata
- runtime cache enablement
- persistence of CompatibilityReport observations
- Gate 3 read/write/replay operations

---

## Remaining Gate 3 Gaps

[R] Remaining Runtime/TBackend work before evaluation can become trusted:

1. Define production RuntimeMachine temporal executor boundary.
2. Approve live TBackend adapter binding separately from descriptor metadata.
3. Persist CompatibilityReport observations with audit evidence.
4. Define adapter selection and capability negotiation semantics.
5. Keep TEMPORAL cache disabled until production cache key/freshness enforcement
   is approved.

---

## Handoff

```text
Card: S3-R7-C1-P
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/runtime-compatibility-report-temporal-load-check-v0
Status: done

[D] Decisions
- CompatibilityReport now carries load acceptance and evaluation readiness as
  separate decisions.
- Missing temporal TBackend capability blocks evaluation readiness but does not
  block bundle loading for inspection.
- Required capability metadata alone is not enough for evaluation; no executor
  and no live binding still blocks.
- Report remains report-only and runtime_enforced=false.

[S] Shipped / Signals
- Added runtime_compatibility_report_temporal_load_check proof.
- Reports consume manifest.fragment_summary, manifest.contract_index, and
  compatibility_metadata guard_policy.
- History and BiHistory TEMPORAL artifacts both produce blocked evaluation
  readiness without refusing bundle load.

[T] Tests / Proofs
- ruby igniter-lang/experiments/runtime_compatibility_report_temporal_load_check/runtime_compatibility_report_temporal_load_check.rb -> PASS

[R] Risks / Recommendations
- Gate 3 remains closed: no live TBackend, no Ledger operations, no temporal
  executor, no production cache.
- Next Runtime slice should decide whether CompatibilityReport persistence or
  temporal executor boundary comes first.

[Next] Suggested next slice
- Runtime temporal executor Gate 3 request, or descriptor compatibility package
  consumption if Bridge wants to carry the report-only evidence outward.
```
