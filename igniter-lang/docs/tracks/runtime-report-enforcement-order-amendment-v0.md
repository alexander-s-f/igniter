# Track: Runtime Report Enforcement Order Amendment v0

Card: S3-R15-C1-P
Agent: `[Igniter-Lang Bridge Agent]`
Role: `bridge-agent`
Track: `runtime-report-enforcement-order-amendment-v0`
Status: done
Date: 2026-05-09

Affected neighbor roles: `[Igniter-Lang Research Agent]`,
`[Igniter-Lang Compiler/Grammar Expert]`

---

## Purpose

Resolve the ordering drift reported in S3-R14-X1 for
`runtime-report-enforcement-preflight-v0`.

S3-R14-C4 originally placed `gate_state` before `approval_token`. The canonical
runtime diagnostic order is:

```text
CompatibilityReport
-> approval_token
-> gate_state
-> scope
-> cache_key
-> executor_backend
```

---

## Source Read

Read sources:

- `igniter-lang/docs/discussions/phase1-implementation-prep-safety-pressure-v0.md`
- `igniter-lang/docs/tracks/runtime-report-enforcement-preflight-v0.md`
- `igniter-lang/docs/proposals/PROP-030-executor-approval-token-contract-v0.md`
- `igniter-lang/docs/gates/gate3-decision-record-v0.md`

S3-R14-X1 names the drift as medium severity for production guidance, not as a
live-eval leak. PROP-030 and the Gate 3 decision record preserve token validity
as an independent runtime check before executor/backend/cache work.

---

## Amendment Decision

[D] Amend S3-R14-C4 to use the canonical ordering:

```text
compatibility_report
approval_token
gate_state
scope
cache_key
executor_backend
```

`CompatibilityReport` still includes report composition integrity and
descriptor metadata evidence checks. Blocked or malformed descriptor evidence
therefore stops before token, gate, cache, executor, backend, or Ledger entry.

Token-before-gate means:

- missing/blocked token reports `runtime.executor_approval_missing` before
  Gate 3 state is inspected;
- a valid token with Gate 3 closed reports `runtime.temporal_gate3_closed`;
- when both token and Gate 3 are blocked, token diagnostics win first;
- neither condition authorizes executor/cache/TBackend/Ledger/read calls.

---

## PROP-030 Errata

[D] PROP-030 errata is unnecessary.

Reason: the bridge proof has been brought back into the canonical ordering
instead of changing the canonical rule. The amendment preserves PROP-030
semantics:

- approval token validation is independent of Gate 3 state;
- Gate 3 closed still refuses when token shape is otherwise valid;
- cache schema validation still happens before cache use;
- CompatibilityReport remains reporting/evidence until RuntimeMachine enforces
  the same check order.

---

## Proof Update

Updated proof-local fixture:

```text
igniter-lang/experiments/runtime_report_enforcement_preflight/
  runtime_report_enforcement_preflight.rb
  runtime_report_enforcement_preflight_summary.json
```

New mixed-failure case:

```text
approval_missing_with_gate_closed_blocks_before_gate
```

This proves that a missing/blocked approval token is surfaced before a closed
Gate 3 diagnostic when both are present.

---

## Acceptance Matrix

| Case | Expected stop | Reason |
|---|---:|---|
| `ready_preflight` | none | all guards pass; no live call attempted by fixture |
| `split_report_blocks_at_compatibility_report` | `compatibility_report` | split report/enforcement fragments rejected |
| `backend_descriptor_blocked` | `compatibility_report` | descriptor metadata is not trusted |
| `missing_descriptor_hash_blocks_before_gate` | `compatibility_report` | descriptor metadata malformed before token/gate |
| `approval_missing_blocks_before_gate` | `approval_token` | token failure wins before Gate 3 |
| `approval_missing_with_gate_closed_blocks_before_gate` | `approval_token` | mixed failure proves token-before-gate |
| `gate_closed_after_token_check` | `gate_state` | Gate 3 refusal after token passes |
| `bihistory_scope_excluded_before_cache` | `scope` | BiHistory remains excluded |
| `cache_key_blocks_before_executor_backend` | `cache_key` | TEMPORAL cache-key readiness blocks |
| `executor_missing_blocks_before_backend_call` | `executor_backend` | executor readiness blocks |
| `report_only_blocks_before_executor_backend` | `executor_backend` | report-only is not runtime authority |

All blocked cases preserve:

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

## Proof Output

Command:

```bash
ruby igniter-lang/experiments/runtime_report_enforcement_preflight/runtime_report_enforcement_preflight.rb
```

Observed result:

```text
PASS ready preflight reaches executor/backend without calls
PASS split_report_blocks_at_compatibility_report stops at compatibility_report
PASS backend_descriptor_blocked stops at compatibility_report
PASS gate_closed_after_token_check stops at gate_state
PASS approval_missing_blocks_before_gate stops at approval_token
PASS approval_missing_with_gate_closed_blocks_before_gate stops at approval_token
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

This amendment does not authorize:

- live reads;
- Ledger adapter binding;
- live TBackend calls;
- cache access;
- package edits;
- BiHistory serving;
- production signing/authority registry behavior.

It only corrects bridge guidance and proof-local ordering.

---

## Handoff

```text
[Igniter-Lang Bridge Agent]
Track: igniter-lang/runtime-report-enforcement-order-amendment-v0
Status: done
Neighbors: Research Agent | Compiler/Grammar Expert

[D] Decisions:
- Canonical order is CompatibilityReport -> approval_token -> gate_state -> scope -> cache_key -> executor_backend.
- S3-R14-C4 has been amended to match PROP-030 ordering.
- PROP-030 errata is unnecessary because no canonical rule changed.

[R] Recommendations:
- Implementation Agent should use token-before-gate diagnostics in RuntimeMachine preflight.
- Keep descriptor evidence inside CompatibilityReport integrity checks.

[S] Signals:
- Mixed failure case proves approval token blocks before Gate 3 closure.
- Blocked-before-call behavior remains PASS for every blocked case.

[T] Tests / Proofs:
- ruby igniter-lang/experiments/runtime_report_enforcement_preflight/runtime_report_enforcement_preflight.rb
- ruby -c igniter-lang/experiments/runtime_report_enforcement_preflight/runtime_report_enforcement_preflight.rb

[Files] Changed:
- igniter-lang/docs/tracks/runtime-report-enforcement-order-amendment-v0.md
- igniter-lang/docs/tracks/runtime-report-enforcement-preflight-v0.md
- igniter-lang/experiments/runtime_report_enforcement_preflight/runtime_report_enforcement_preflight.rb
- igniter-lang/experiments/runtime_report_enforcement_preflight/runtime_report_enforcement_preflight_summary.json

[Q] Open Questions:
- None for PROP-030 ordering; errata is unnecessary.

[X] Rejected:
- No live reads, Ledger adapter binding, package edits, cache access, or BiHistory serving.

[Next] Proposed next slice:
- Implementation Agent can consume the amended preflight order when wiring proof-local RuntimeMachine guard behavior.
```
