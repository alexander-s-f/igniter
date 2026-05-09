Card: S3-R14-C2-P
Agent: [Igniter-Lang Implementation Agent]
Role: implementation-agent
Track: igniter-lang/runtime-temporal-executor-phase1-preflight-v0
Status: done

---

# Track: Runtime Temporal Executor Phase 1 Preflight

## Purpose

Implement and validate the smallest proof-local `Phase1TemporalExecutor` boundary for
`History[T]` valid_time evaluation under Gate 3 approved-restricted scope (AT-1..AT-12).

This track does not open Gate 3. It establishes that the executor guard shape is correct and
that the proof structure is ready for a future Architect-approved Phase 2 live-Ledger addendum.

---

## Scope

```text
Authorized:   History[T] valid_time / proof-local MemoryBackend
Excluded:     Ledger, BiHistory, stream, OLAP, writes, production_cache
gate3_authorized: proof-local flag only (not a real Gate 3 open)
live TBackend: none
production cache: none
```

---

## Shipped

- `experiments/temporal_executor_phase1_preflight/temporal_executor_phase1_preflight.rb`
  — proof-local `Phase1TemporalExecutor` class + 9-case test harness
- `experiments/temporal_executor_phase1_preflight/out/temporal_executor_phase1_preflight_summary.json`
  — machine-readable proof summary with AT coverage + gap list

---

## Design Decisions

### [D] Phase1TemporalExecutor does NOT delegate evaluate to GuardedRuntimeMachine

`GuardedRuntimeMachine#evaluate_contract` reads
`compatibility_metadata.json → runtime_execution.evaluate.decision` and returns
`"refuse_temporal_contract"` even when `gate3_authorized=true`. That is the pre-gate-3
artifact policy. AT-1 (`runtime_enforced=true`) means this policy must be overridden by the
Phase 1 executor, not bypassed or silenced.

`Phase1TemporalExecutor#evaluate` therefore implements its own guard chain:

```
capability check → AT-4 token validation → AT-5 gate3 check → AT-6 cache key schema
  → run_execution_kernel
    → AT-12 fragment_class check
    → AT-7 BiHistory axis check
    → read_as_of + emit temporal_live_read_observation (AT-10)
```

`GuardedRuntimeMachine` is still used for `load` (L-T1..L-T6 artifact validation only).

### [D] `run_execution_kernel` is public for AT-12 / AT-7 defense-in-depth testing

The executor-level CORE fragment check (AT-12) is defense-in-depth: in production, the
guard chain at `evaluate` would reject a CORE artifact before reaching the kernel.
Exposing `run_execution_kernel` allows the proof to test the kernel guard directly without
constructing a second load path.

### [D] Proof-local `gate3_authorized: true` flag

The real Gate 3 decision record does not yet have an `authority_ref` (Gate 3 request is on
HOLD for Architect review). The proof uses a local boolean flag to represent authorization.
This is intentional: the executor shape is correct and ready; the flag will be replaced by
token authority verification when the gate decision is ratified.

---

## Proof Results

```text
PASS temporal_executor_phase1_preflight
  happy_path.load_runtime_enforced:  ok
  happy_path.evaluate_ok:            ok
  happy_path.observation_emitted:    ok
  happy_path.result_present:         ok
  no_token.blocked_at4:              ok   (runtime.executor_approval_missing)
  gate3_closed.blocked_at5:          ok   (runtime.temporal_gate3_closed)
  core_cache_key.blocked_at6:        ok   (runtime.temporal_cache_schema_mismatch)
  bihistory.blocked_at7:             ok   (runtime.temporal_executor_bihistory_excluded)
  core_fragment.blocked_at12:        ok   (runtime.temporal_executor_core_refusal)
```

---

## AT Coverage

| AT | Covered | Evidence |
|----|---------|----------|
| AT-1 | ✅ | load result has `runtime_enforced=true`; artifact `guard_policy` overridden |
| AT-2 | deferred | no composed `CompatibilityReport`; gap listed below |
| AT-3 | ✅ | full guard chain runs before `run_execution_kernel` |
| AT-4 | ✅ | nil token → `executor_approval_missing` before gate3 check |
| AT-5 | ✅ | valid token + `gate3=false` → `temporal_gate3_closed`; checks independent |
| AT-6 | ✅ | CORE cache-key fragment → `temporal_cache_schema_mismatch` at L-T5 position |
| AT-7 | ✅ | BiHistory axis in kernel → `temporal_executor_bihistory_excluded` |
| AT-8 | ✅ | `MemoryBackend` has no write/append/replay API; Ledger not referenced |
| AT-9 | partial | proof-local recorded-decision hash; no external authority registry |
| AT-10 | ✅ | `temporal_live_read_observation` emitted per `read_as_of`; not gated on persistence |
| AT-11 | ✅ | Stage 1 + Stage 2 close candidates PASS (run separately) |
| AT-12 | ✅ | `run_execution_kernel` called directly with CORE contract → `core_refusal` |

---

## Runtime Gaps Before Live Reads

These gaps block Phase 2 (real Ledger) but do not block Phase 1 proof-local use:

| # | Gap | Current State | Needed |
|---|-----|--------------|--------|
| G1 | AT-2: `CompatibilityReport` composition | Phase 1 builds partial report inline | `compatibility-report-composition-shape-v0` track (Gate 3 §III Require) |
| G2 | AT-9: production token authority / signature | proof-local hash only; no external registry | Architect-recorded `authority_ref` in gate decision (Q1) |
| G3 | Gate 3 decision record with `authority_ref` | Gate 3 request on HOLD | Architect approval; `gate3_authorized=true` is proof-local only |
| G4 | AT-10: observation persistence | in-memory array only | `invariant_persistence` gap closure (Stage 2 deferred) |
| G5 | TBackend adapter production binding | `MemoryBackend` proof-local only | Phase 2 addendum to gate decision (Gate 3 §III Q3 Option C) |
| G6 | BiHistory evaluation (AT-7) | BiHistory refused in Phase 1 | separate gate request after `at(vt:, tt:)` serving proof |

---

## Regression

```bash
ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb
# typechecker: PASS / semanticir: PASS / stdlib_kernel: PASS / igapp_assembler: PASS

ruby igniter-lang/experiments/stage2_close_candidate/stage2_close_candidate.rb
# stream_fold: PASS / history_bihistory_temporal_access: PASS / ledger_tbackend_descriptor: PASS
# stage1_regression: PASS
```

---

## Risks

- [R] Phase 1 uses `gate3_authorized: true` as a proof-local boolean. Any test reading this
  as "Gate 3 is open" would be wrong. The flag is scoped to the proof; Gate 3 remains closed
  until Architect approves the gate decision document with `authority_ref`.

- [R] `Phase1TemporalExecutor` is experiments-local only. It must not be promoted to `lib/`
  until Gate 3 is ratified and PROP-030 token validation is production-approved.

---

## Open Questions

- [Q1] What is the `authority_ref` value for the Gate 3 decision record? This is the last
  blocker for AT-9 and for closing the gate decision document. Architect-owned.

- [Q2] Should `CompatibilityReport` composition (AT-2 gap, G1) be its own track, or is it
  absorbed into the Gate 3 ratification slice?

---

## Handoff

```text
Card: S3-R14-C2-P
Agent: [Igniter-Lang Implementation Agent]
Role: implementation-agent
Track: igniter-lang/runtime-temporal-executor-phase1-preflight-v0
Status: done

[D] Decisions
- Phase1TemporalExecutor implements own evaluate guard chain; does not delegate to
  GuardedRuntimeMachine (artifact's guard_policy is pre-gate-3 artifact artifact and must be
  overridden, not silenced)
- run_execution_kernel is public for direct AT-12/AT-7 defense-in-depth tests
- gate3_authorized is proof-local boolean; real Gate 3 remains closed

[S] Shipped
- experiments/temporal_executor_phase1_preflight/temporal_executor_phase1_preflight.rb
- experiments/temporal_executor_phase1_preflight/out/temporal_executor_phase1_preflight_summary.json
- docs/tracks/runtime-temporal-executor-phase1-preflight-v0.md

[T] Tests / Proofs
- command: ruby igniter-lang/experiments/temporal_executor_phase1_preflight/temporal_executor_phase1_preflight.rb
- result: PASS (9/9 checks)
- AT coverage: AT-1,3,4,5,6,7,8,10,11,12 covered; AT-2 deferred; AT-9 partial
- command: ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb
- result: PASS
- command: ruby igniter-lang/experiments/stage2_close_candidate/stage2_close_candidate.rb
- result: PASS

[R] Risks / Recommendations
- Phase1TemporalExecutor is experiments-local only; must not enter lib/ before Gate 3 ratification
- gate3_authorized=true is proof-local; real Gate 3 still closed
- 6 runtime gaps documented; none block Phase 1 proof use

[Q] Open questions
- Q1: authority_ref value for Gate 3 decision record (Architect-owned blocker for AT-9)
- Q2: CompatibilityReport composition (AT-2) — own track or absorbed into Gate 3 ratification?

[Next] Suggested next slice
- Gate 3 decision ratification: add authority_ref to gate decision document (Meta/Gate ownership)
  or assign to Implementation Agent as a docs-only pass if Architect approves
- PROP-029 parser proof: S3-R12-C1-P (entrypoint/section syntax; proof-local; no gate blocker)
```
