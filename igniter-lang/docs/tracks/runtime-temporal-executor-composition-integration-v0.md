Card: S3-R15-C2-P
Agent: [Igniter-Lang Implementation Agent]
Role: implementation-agent
Track: igniter-lang/runtime-temporal-executor-composition-integration-v0
Status: done
Date: 2026-05-09

---

# Track: Runtime Temporal Executor Composition Integration v0

## Purpose

Close AT-2 by proving `Phase1TemporalExecutorWithReport` consumes the composed
`CompatibilityReport` shape (from `compatibility-report-composition-v0`) instead
of building inline partial reports.

The `RuntimeReportEnforcementPreflight` guard chain (from
`runtime-report-enforcement-preflight-v0`) replaces the inline AT-4/AT-5/AT-6
checks as the single preflight source of truth.

No Ledger adapter, live TBackend call, production cache, or BiHistory is
involved.

---

## Source Signals

- `docs/tracks/compatibility-report-composition-v0.md` (S3-R13-C4-P)
- `docs/tracks/runtime-report-enforcement-preflight-v0.md` (S3-R14-C4-P)
- `docs/gates/gate3-decision-record-v0.md` (S3-R13-C1-A)
- `docs/tracks/runtime-temporal-executor-phase1-preflight-v0.md` (S3-R14-C2-P)

---

## Decisions

### [D] CompatibilityReport is the single preflight source of truth (AT-2)

`Phase1TemporalExecutorWithReport#evaluate` composes one `CompatibilityReport`
per evaluation call, then delegates all preflight checks to
`RuntimeReportEnforcementPreflight.preflight(report)`.

The guard order is enforced by the preflight module, not by inline code:

```text
compatibility_report → approval_token → gate_state → scope →
cache_key → executor_backend → [execution kernel: AT-12, AT-7, AT-10]
```

The inline `eval_blocked` / partial-report pattern from
`Phase1TemporalExecutor#evaluate` is not used in this integration.

### [D] Split report/enforcement fragments rejected at `compatibility_report` stage

If `composition_mode` is anything other than `"single_report"`, the composed
report has `composition_diagnostics.status = "blocked"` with problem
`"compatibility_report.split_report_rejected"`. The preflight returns blocked at
`"compatibility_report"` before any executor, gate, token, cache, or backend
path.

`operation_check.temporal_executor_call_attempted` remains `false`.

### [D] `GATE3_AUTHORITY_REF` embedded as Phase 1 constant

The authority ref recorded in `gate3-decision-record-v0.md §Authority Registry`
is embedded as a constant in the executor for Phase 1. This is the gate
decision's Q1 answer: sufficient for proof-local restricted Phase 1 without
a production signing system.

```text
architect-supervisor://igniter-lang/gates/gate3/
  runtime-temporal-executor/restricted-history-valid-time-v0/2026-05-09
```

---

## Shipped

- `experiments/temporal_executor_composition_integration/temporal_executor_composition_integration.rb`
  — `Phase1TemporalExecutorWithReport` class + 4-case test harness
- `experiments/temporal_executor_composition_integration/out/temporal_executor_composition_integration_summary.json`
  — machine-readable proof summary with AT coverage + remaining blockers

---

## Proof Results

```bash
ruby igniter-lang/experiments/temporal_executor_composition_integration/temporal_executor_composition_integration.rb
```

```text
PASS temporal_executor_composition_integration
  at2.happy_path.report_composed:                  ok
  at2.happy_path.report_single_mode:               ok
  at2.happy_path.report_runtime_enforced:          ok
  at2.happy_path.evaluate_ok:                      ok
  at2.happy_path.observation_emitted:              ok
  at2.split_report.blocked_at_compatibility_report: ok
  at2.split_report.no_executor_call:               ok
  report_preflight.gate_closed.blocked_at_gate_state:   ok
  report_preflight.no_token.blocked_at_approval_token:  ok
```

---

## Updated AT Coverage

| AT | Previous state | Now |
|----|---------------|-----|
| AT-1 | ✅ S3-R14-C2-P | ✅ (unchanged) |
| AT-2 | ⚠️ deferred gap | ✅ **closed** — composed report consumed; split fragments rejected |
| AT-3 | ✅ | ✅ (unchanged) |
| AT-4 | ✅ | ✅ via report preflight (approval_token stage) |
| AT-5 | ✅ | ✅ via report preflight (gate_state stage) |
| AT-6 | ✅ | ✅ via report preflight (cache_key stage) |
| AT-7 | ✅ | ✅ (unchanged, in kernel) |
| AT-8 | ✅ | ✅ (unchanged) |
| AT-9 | partial | partial — proof-local hash; production authority registry not yet defined |
| AT-10 | ✅ | ✅ (unchanged, in kernel) |
| AT-11 | ✅ regressions | ✅ Stage 1 + Stage 2 PASS |
| AT-12 | ✅ | ✅ (unchanged, in kernel) |

AT-2 is now closed. All 12 AT conditions are either covered or have a documented
blocker.

---

## Regression

```bash
ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb
# typechecker: PASS / semanticir: PASS / stdlib_kernel: PASS / igapp_assembler: PASS

ruby igniter-lang/experiments/stage2_close_candidate/stage2_close_candidate.rb
# stream_fold: PASS / history_bihistory_temporal_access: PASS
# ledger_tbackend_descriptor: PASS / stage1_regression: PASS

ruby igniter-lang/experiments/temporal_executor_phase1_preflight/temporal_executor_phase1_preflight.rb
# PASS (9/9 checks — S3-R14-C2-P proof unaffected)
```

---

## Remaining Blockers Before Live Reads

| # | Blocker | Current state | Required for |
|---|---------|--------------|-------------|
| B1 | AT-9: production token authority / signature | proof-local recorded-decision hash | Phase 2 Ledger or production deployment |
| B2 | AT-10: observation persistence | in-memory array only | `invariant_persistence` gap closure |
| B3 | TBackend adapter production binding | MemoryBackend proof-local | Phase 2 addendum (gate3-decision-record-v0.md §Q3 Option C) |
| B4 | BiHistory evaluation (AT-7) | refused at executor | separate gate request after `at(vt:,tt:)` proof |
| B5 | Runtime authority registry | not yet defined | Phase 2 / production authority-revocation |

---

## Non-Authorization

This track does not authorize:

- Gate 3 production opening;
- live Ledger adapter binding;
- live TBackend call;
- cache lookup or writes;
- temporal reads beyond proof-local MemoryBackend;
- BiHistory serving;
- package edits.

---

## Handoff

```text
Card: S3-R15-C2-P
Agent: [Igniter-Lang Implementation Agent]
Role: implementation-agent
Track: igniter-lang/runtime-temporal-executor-composition-integration-v0
Status: done

[D] Decisions
- Phase1TemporalExecutorWithReport composes one CompatibilityReport per evaluation
  and delegates preflight to RuntimeReportEnforcementPreflight — no inline AT-4/5/6 checks
- Split report/enforcement fragments rejected at compatibility_report stage before
  any executor/gate/token/cache/backend path
- GATE3_AUTHORITY_REF embedded as Phase 1 constant (gate3-decision-record-v0.md §Q1)

[S] Shipped
- experiments/temporal_executor_composition_integration/temporal_executor_composition_integration.rb
- experiments/temporal_executor_composition_integration/out/temporal_executor_composition_integration_summary.json
- docs/tracks/runtime-temporal-executor-composition-integration-v0.md

[T] Tests / Proofs
- command: ruby igniter-lang/experiments/temporal_executor_composition_integration/temporal_executor_composition_integration.rb
- result: PASS (9/9 checks)
- AT-2_compatibility_report_composed: true
- command: ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb
- result: PASS
- command: ruby igniter-lang/experiments/stage2_close_candidate/stage2_close_candidate.rb
- result: PASS
- command: ruby igniter-lang/experiments/temporal_executor_phase1_preflight/temporal_executor_phase1_preflight.rb
- result: PASS (S3-R14-C2-P proof unaffected)

[R] Risks
- Phase1TemporalExecutorWithReport is experiments-local; must not enter lib/ before Gate 3 production ratification
- AT-9 partial: proof-local hash only; authority registry not yet defined
- 5 remaining blockers documented; none block proof-local use

[Q] Open questions
- Q1: Is there a preference for how Phase1TemporalExecutorWithReport relates to
  Phase1TemporalExecutor (replacement, wrapper, parallel) in the eventual lib/ class?

[Next] Suggested next slice
- PROP-029 parser proof: S3-R12-C1-P (entrypoint/section syntax; no gate blocker)
- OR: invariant_persistence gap track (closes B2 / AT-10 persistence; Stage 2 deferred gap)
```
