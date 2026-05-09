# Track: Runtime Report Enforcement Preflight v0

Card: S3-R14-C4-P
Agent: `[Igniter-Lang Bridge Agent]`
Role: `bridge-agent`
Track: `runtime-report-enforcement-preflight-v0`
Status: done
Date: 2026-05-09

Affected neighbor roles: `[Igniter-Lang Research Agent]`,
`[Igniter-Lang Compiler/Grammar Expert]`

---

## Purpose

Map RuntimeMachine preflight behavior onto the composed CompatibilityReport
shape from `compatibility-report-composition-v0`.

This track proves the guard order for an enforcement-capable report without
opening Ledger binding, live TBackend calls, cache calls, or temporal reads.

---

## Source Signal

Primary source:

```text
igniter-lang/docs/tracks/compatibility-report-composition-v0.md
```

Relevant fixed points:

- Gate 3 readiness is represented by one composed CompatibilityReport.
- `runtime_enforced: true` is valid only on the composed report when every
  readiness dimension is ready.
- `report_only: true` remains analysis metadata and cannot become runtime
  authority by implication.
- Descriptor metadata is report evidence only; BiHistory capability metadata is
  not physical serving proof.

---

## Preflight Order

[D] RuntimeMachine preflight should evaluate the composed report in this order:

```text
CompatibilityReport
-> gate state
-> approval token
-> scope
-> cache key
-> executor/backend
```

The `CompatibilityReport` phase includes:

- report kind and composition integrity;
- rejection of split report/enforcement fragments;
- `composition_diagnostics.status == ok`;
- `backend_check.temporal_backend_descriptor` metadata presence and trust:
  `descriptor_hash`, `descriptor_registry_hash`, `capabilities`,
  `history_axes`, and `cursor_policy`.

If descriptor evidence is blocked or malformed, RuntimeMachine stops at the
`CompatibilityReport` phase before gate, token, cache, executor, backend, or
Ledger entry.

---

## Report-Only Boundary

`report_only: true` is allowed for inspection and readiness analysis.

`runtime_enforced: true` requires:

- one composed `compatibility_report`;
- trusted descriptor metadata inside `backend_check`;
- open runtime gate;
- valid `ExecutorApprovalToken` state;
- TEMPORAL `history_valid_time_read` scope;
- valid TEMPORAL cache-key coordinates;
- executor readiness;
- `report_only: false`.

A report with all metadata checks satisfied but `report_only: true` must still
block at `executor_backend` with:

```text
compatibility_report.report_only_not_runtime_authority
```

---

## Proof Fixture

Added proof-local fixture:

```text
igniter-lang/experiments/runtime_report_enforcement_preflight/
  runtime_report_enforcement_preflight.rb
  runtime_report_enforcement_preflight_summary.json
```

The fixture imports the composed report shape from:

```text
igniter-lang/experiments/compatibility_report_composition/
  compatibility_report_composition.rb
```

It verifies that every blocked readiness state prevents:

```json
{
  "temporal_executor_call_attempted": false,
  "cache_call_attempted": false,
  "live_tbackend_call_attempted": false,
  "ledger_call_attempted": false,
  "temporal_read_attempted": false
}
```

---

## Acceptance Matrix

| Case | Expected stop | Reason |
|---|---:|---|
| `ready_preflight` | none | preflight reaches executor/backend readiness without performing calls |
| `split_report_blocks_at_compatibility_report` | `compatibility_report` | split report/enforcement fragments rejected |
| `backend_descriptor_blocked` | `compatibility_report` | descriptor metadata is not trusted |
| `missing_descriptor_hash_blocks_before_gate` | `compatibility_report` | descriptor evidence malformed |
| `gate_closed_blocks_before_token` | `gate_state` | Gate 3 is closed |
| `approval_missing_blocks_before_scope` | `approval_token` | executor approval token missing/blocked |
| `bihistory_scope_excluded_before_cache` | `scope` | BiHistory remains excluded from first Gate 3 |
| `cache_key_blocks_before_executor_backend` | `cache_key` | TEMPORAL cache-key readiness blocked |
| `executor_missing_blocks_before_backend_call` | `executor_backend` | executor readiness missing/blocked |
| `report_only_blocks_before_executor_backend` | `executor_backend` | report-only is not runtime authority |

---

## RuntimeMachine Notes

Implementation Agent should model this as a deterministic preflight guard, not
as scattered checks around executor/cache/backend calls.

Suggested integration notes:

- Load exactly one composed CompatibilityReport for the candidate evaluation.
- Reject split report/enforcement fragments before reading gate or token state.
- Validate descriptor metadata only as report evidence; do not treat it as live
  backend capability proof.
- Read `evaluation_readiness` and component checks from the composed report, but
  independently enforce this guard order before any operational entry.
- Stop on first blocked stage and emit a stage trace plus reason code.
- On any blocked stage, leave all operation attempt flags false.
- Only after the guard returns ready may the later runtime slice enter
  executor/cache/backend code.
- Preserve the Phase 1 adapter boundary: proof-local or non-Ledger abstract
  `History[T]` valid-time read only.
- Preserve the BiHistory exclusion until a separate physical
  `at(vt:, tt:)` serving proof exists.

The implementation-facing guard order is:

```text
compatibility_report
gate_state
approval_token
scope
cache_key
executor_backend
```

---

## Proof Results

Command:

```bash
ruby igniter-lang/experiments/runtime_report_enforcement_preflight/runtime_report_enforcement_preflight.rb
```

Observed result:

```text
PASS ready preflight reaches executor/backend without calls
PASS split_report_blocks_at_compatibility_report stops at compatibility_report
PASS backend_descriptor_blocked stops at compatibility_report
PASS gate_closed_blocks_before_token stops at gate_state
PASS approval_missing_blocks_before_scope stops at approval_token
PASS bihistory_scope_excluded_before_cache stops at scope
PASS cache_key_blocks_before_executor_backend stops at cache_key
PASS executor_missing_blocks_before_backend_call stops at executor_backend
PASS missing_descriptor_hash_blocks_before_gate stops at compatibility_report
PASS report-only remains distinct from runtime_enforced
PASS blocked cases perform no executor/cache/tbackend/ledger/read calls
PASS summary written igniter-lang/experiments/runtime_report_enforcement_preflight/runtime_report_enforcement_preflight_summary.json
```

---

## Non-Authorization

This track does not authorize:

- Ledger binding;
- live Ledger reads/writes/replay/compact/subscribe;
- live TBackend adapter calls;
- cache lookup or cache writes;
- temporal reads;
- BiHistory serving;
- package edits;
- production RuntimeMachine execution.

It only proves the report preflight order and blocked-before-call behavior.

---

## Handoff

```text
[Igniter-Lang Bridge Agent]
Track: igniter-lang/runtime-report-enforcement-preflight-v0
Status: done
Neighbors: Research Agent | Compiler/Grammar Expert

[D] Decisions:
- RuntimeMachine preflight order is CompatibilityReport -> gate state -> token -> scope -> cache-key -> executor/backend.
- Descriptor metadata is checked inside the CompatibilityReport phase and remains evidence only.
- `report_only: true` never becomes runtime authority by passing metadata checks.

[R] Recommendations:
- Implementation Agent should implement one deterministic preflight guard before executor/cache/backend entry.
- Preserve Phase 1 as non-Ledger abstract History[T] valid-time read only.

[S] Signals:
- Proof-local fixture shows every blocked readiness state leaves executor/cache/TBackend/Ledger/read attempts false.
- BiHistory scope remains excluded and blocks before cache-key evaluation.

[T] Tests / Proofs:
- ruby igniter-lang/experiments/runtime_report_enforcement_preflight/runtime_report_enforcement_preflight.rb
- ruby -c igniter-lang/experiments/runtime_report_enforcement_preflight/runtime_report_enforcement_preflight.rb

[Files] Changed:
- igniter-lang/docs/tracks/runtime-report-enforcement-preflight-v0.md
- igniter-lang/experiments/runtime_report_enforcement_preflight/runtime_report_enforcement_preflight.rb
- igniter-lang/experiments/runtime_report_enforcement_preflight/runtime_report_enforcement_preflight_summary.json

[Q] Open Questions:
- Does Architect want the eventual RuntimeMachine guard named as a preflight object, a CompatibilityReport consumer, or an evaluation gate?

[X] Rejected:
- No Ledger binding, live reads, cache calls, package edits, or BiHistory serving.

[Next] Proposed next slice:
- Implementation Agent can translate this preflight matrix into proof-local RuntimeMachine guard behavior after Architect approval for that implementation slice.
```
