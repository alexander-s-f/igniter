# Track: Temporal Scope Exclusion Runtime Fixture v0

Card: S3-R14-C3-P
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `igniter-lang/temporal-scope-exclusion-runtime-fixture-v0`
Status: done
Date: 2026-05-09

Affected neighbor roles: `[Igniter-Lang Compiler/Grammar Expert]`,
`[Igniter-Lang Bridge Agent]`

---

## Goal

Turn the PROP-030A refusal matrix into executable proof-local runtime evidence.

This fixture proves `runtime.temporal_scope_exclusion` for out-of-scope
surfaces that reach a simulated `TemporalExecutor`.

---

## Current Horizon

Gate 3 Phase 1 is approved-restricted for implementation, but live reads remain
blocked until pre-live conditions and AT-1 through AT-12 pass. Approved scope is:

```text
History[T] + valid_time + history_read + read_as_of(as_of: DateTime)
```

Everything else that reaches the temporal executor path must refuse before
cache lookup, TBackend access, Ledger access, live adapter access, or executor
evaluation.

---

## Decision

[D] This proof assumes earlier gates already succeeded:

```text
approval token valid
Gate 3 Phase 1 open
```

That lets the fixture test the scope gate directly instead of masking it with
approval or gate-closed refusals.

[D] Out-of-scope surfaces refuse with:

```text
runtime.temporal_scope_exclusion
```

[D] The refusal carries the PROP-030A minimum diagnostic envelope:

```json
{
  "reason_code": "runtime.temporal_scope_exclusion",
  "expected_scope": "history_valid_time",
  "actual_fragment": "core|stream|temporal|unknown",
  "actual_surface": "core|stream|olap|bihistory|ledger_write|ledger_replay|unknown",
  "actual_axis": "valid_time|bitemporal|multi_dimensional|unknown|null",
  "artifact_ref": "igapp/sha256:<artifact-hash>",
  "contract_ref": "contract/<name>/sha256:<contract-hash>"
}
```

[D] The approved History valid-time control case is not scope-excluded; it
returns `runtime.temporal_scope_accepted` and stops before cache/backend calls.

---

## Implemented Proof

Added:

```text
igniter-lang/experiments/temporal_scope_exclusion_runtime_fixture/
  temporal_scope_exclusion_runtime_fixture.rb
  out/temporal_scope_exclusion_runtime_fixture_summary.json
```

The proof-local `ProofTemporalExecutor` evaluates synthetic artifact envelopes.

| Case | Expected result |
| --- | --- |
| CORE contract reaches TemporalExecutor | `runtime.temporal_scope_exclusion` |
| STREAM contract / `stream_nodes` reaches TemporalExecutor | `runtime.temporal_scope_exclusion` |
| OLAP temporal surface reaches TemporalExecutor | `runtime.temporal_scope_exclusion` |
| BiHistory / bitemporal surface reaches TemporalExecutor | `runtime.temporal_scope_exclusion` |
| Ledger write/append/compact-like surface reaches path | `runtime.temporal_scope_exclusion` |
| Ledger replay surface reaches path | `runtime.temporal_scope_exclusion` |
| Unknown TEMPORAL surface reaches path | `runtime.temporal_scope_exclusion` |
| History valid-time control | `runtime.temporal_scope_accepted` |

All refusal cases prove:

```json
{
  "executor_evaluation_attempted": false,
  "cache_lookup_attempted": false,
  "tbackend_call_attempted": false,
  "ledger_call_attempted": false,
  "live_adapter_call_attempted": false
}
```

---

## Proof Output

Command:

```bash
ruby igniter-lang/experiments/temporal_scope_exclusion_runtime_fixture/temporal_scope_exclusion_runtime_fixture.rb
```

Observed output:

```text
PASS temporal_scope_exclusion_runtime_fixture
core.refused_scope_exclusion: ok
stream.refused_scope_exclusion: ok
olap.refused_scope_exclusion: ok
bihistory.refused_scope_exclusion: ok
ledger_write.refused_scope_exclusion: ok
ledger_replay.refused_scope_exclusion: ok
unknown.refused_scope_exclusion: ok
refusals_before_live_operations: ok
valid_history_scope_not_excluded: ok
control_does_not_call_live_paths: ok
summary: igniter-lang/experiments/temporal_scope_exclusion_runtime_fixture/out/temporal_scope_exclusion_runtime_fixture_summary.json
```

Syntax check:

```text
ruby -c igniter-lang/experiments/temporal_scope_exclusion_runtime_fixture/temporal_scope_exclusion_runtime_fixture.rb -> Syntax OK
```

---

## Remaining Runtime Gaps

[R] Production `TemporalExecutor` must run this scope check after approval/Gate
checks and before cache/TBackend/Ledger calls.

[R] Production `CompatibilityReport` should surface the same
`runtime.temporal_scope_exclusion` reason and diagnostic envelope.

[R] Phase 1 still needs the approved `History[T]` valid-time executor path and
AT-1 through AT-12 regression proof.

[R] BiHistory, STREAM, OLAP, Ledger write/replay/compact/subscribe, and
production cache remain outside Phase 1 scope.

---

## Non-Authorization

[X] No live TBackend.

[X] No Ledger adapter.

[X] No Ledger read/write/replay.

[X] No production cache.

[X] No BiHistory, STREAM, or OLAP executor.

[X] No Gate 3 Phase 2 behavior.

---

## Handoff

```text
Card: S3-R14-C3-P
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/temporal-scope-exclusion-runtime-fixture-v0
Status: done

[D] Decisions
- PROP-030A scope exclusion is now executable proof-local runtime evidence.
- CORE, STREAM, OLAP, BiHistory, Ledger write/replay, and unknown temporal
  surfaces refuse with runtime.temporal_scope_exclusion.
- Refusal happens before executor/backend/cache/Ledger/live-adapter calls.

[S] Shipped / Signals
- Added temporal_scope_exclusion_runtime_fixture experiment and summary JSON.
- Added approved History valid-time control case to show scope gate is narrow,
  not blanket TEMPORAL refusal.

[T] Tests / Proofs
- ruby -c temporal_scope_exclusion_runtime_fixture.rb -> Syntax OK
- ruby temporal_scope_exclusion_runtime_fixture.rb -> PASS

[R] Risks / Recommendations
- Production TemporalExecutor must bind this same scope check before cache or
  backend access.
- CompatibilityReport composition should surface the same reason code.

[Next] Suggested next slice
- runtime-temporal-executor-phase1-preflight-v0, or
  runtime-report-enforcement-preflight-v0.
```
