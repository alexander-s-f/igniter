Card: S3-R16-C1-P
Agent: [Igniter-Lang Implementation Agent]
Role: implementation-agent
Track: igniter-lang/runtime-temporal-executor-lib-prep-v0
Status: done
Date: 2026-05-09

---

# Track: Runtime Temporal Executor Lib-Prep v0

## Purpose

Extract the Phase 1 `TemporalExecutor` boundary from `experiments/` into `lib/`
while preserving every guard proven in the pre-live experiments and keeping live
reads blocked by default.

This track is the lib-prep slice required by the Gate 3 `approved-restricted`
status before a live-read decision addendum can be considered.

---

## Source Signals

- `docs/tracks/runtime-temporal-executor-phase1-preflight-v0.md` (S3-R14-C2-P)
- `docs/tracks/runtime-temporal-executor-composition-integration-v0.md` (S3-R15-C2-P)
- `docs/tracks/runtime-report-enforcement-order-amendment-v0.md` (S3-R15-C1-P)
- `docs/tracks/executor-approval-authority-ref-proof-v0.md` (S3-R15-C3-P)
- `docs/tracks/phase1-prelive-regression-chain-v0.md` (S3-R15-C4-P)
- `docs/gates/gate3-decision-record-v0.md` (S3-R13-C1-A)

---

## Decisions

### [D] Standalone lib/ class — no experiment dependency

`IgniterLang::TemporalExecutor::Phase1` is standalone in
`lib/igniter_lang/temporal_executor.rb`. It does not `require` any experiment
file. Any future caller can `require "igniter_lang/temporal_executor"` without
pulling in proof scaffolding.

### [D] Minimal CompatibilityReport hash built inline (AT-2)

The lib/ class does not require `CompatibilityReportComposition` from
experiments. It builds a minimal CompatibilityReport-shaped hash via
`compose_report` and assigns it to `@last_compatibility_report` on every
evaluation path (both blocked and ready). This satisfies AT-2 in lib/ without
coupling to the experiment composition module.

### [D] gate3_authorized: false default — live reads blocked at construction

`Phase1.new(backend:, gate3_authorized: false)` — the default makes the instance
refuse live reads until the caller explicitly opts in. This is the lib-prep
boundary guarantee: mis-construction cannot accidentally open the gate.

### [D] Guard order per S3-R15-C1-P amendment

The lib/ class implements the canonical token-before-gate order:

```text
approval_token (AT-4 + AT-9) →
gate_state (AT-5) →
scope (fragment_class) →
cache_key (AT-6) →
run_execution_kernel (AT-12, AT-7, AT-10)
```

Each blocked stage returns early with `operation_check` all-false.

### [D] AT-9 exact authority_ref match embedded as constant

`GATE3_AUTHORITY_REF` is the exact string from `gate3-decision-record-v0.md
§Authority Registry`. `check_approval_token` requires the token's `authority_ref`
to equal this constant exactly. Missing, stale, or self-issued refs are refused
with `AUTHORITY_UNTRUSTED`.

### [D] AT-10 observations are unconditional

`temporal_live_read_observation` is appended to `@observations` on every
`evaluate_valid_time_node` call regardless of persistence readiness. The
`observations` reader exposes the in-memory array for callers.

---

## Shipped

- `lib/igniter_lang/temporal_executor.rb`
  — `IgniterLang::TemporalExecutor::Phase1` + `ReasonCode` module + `GATE3_AUTHORITY_REF` constant
- `experiments/temporal_executor_lib_prep/temporal_executor_lib_prep.rb`
  — 7-case proof harness (17 checks) that requires only the lib/ file

---

## Proof Results

```bash
ruby igniter-lang/experiments/temporal_executor_lib_prep/temporal_executor_lib_prep.rb
```

```text
PASS temporal_executor_lib_prep
  happy_path.status_ok:                        ok
  happy_path.results_present:                  ok
  happy_path.observation_emitted:              ok
  happy_path.compatibility_report_present:     ok
  happy_path.report_runtime_enforced:          ok
  no_token.blocked_at_approval_token:          ok
  no_token.no_live_operations:                 ok
  wrong_authority_ref.blocked_authority:       ok
  wrong_authority_ref.no_live_operations:      ok
  gate_closed.blocked_at_gate_state:           ok
  gate_closed.no_live_operations:              ok
  core_cache_key.blocked_at_cache_key:         ok
  core_cache_key.no_live_operations:           ok
  bihistory_kernel.blocked_bihistory:          ok
  bihistory_kernel.no_live_operations:         ok
  core_fragment_kernel.blocked_core:           ok
  core_fragment_kernel.no_live_operations:     ok

17/17 PASS
```

---

## AT Coverage (lib/ boundary)

| AT | State | Note |
|----|-------|------|
| AT-1 | ✅ | `gate3_authorized: false` default; MemoryBackend only |
| AT-2 | ✅ | `compose_report` emits CompatibilityReport-shaped hash every evaluation |
| AT-3 | ✅ | Scope exclusion (scope stage refusal) |
| AT-4 | ✅ | `check_approval_token` fires before gate_state |
| AT-5 | ✅ | gate_state check fires after token, before scope/cache/kernel |
| AT-6 | ✅ | cache_key check; non-TEMPORAL fragment key refused with `CACHE_MISMATCH` |
| AT-7 | ✅ | BiHistory refused at kernel (`BIHISTORY_EXCLUDED`) |
| AT-8 | ✅ | No writes, no stream, no OLAP in lib/ |
| AT-9 | ✅ | Exact `authority_ref` match against `GATE3_AUTHORITY_REF` in `check_approval_token` |
| AT-10 | ✅ | `temporal_live_read_observation` appended unconditionally per access node |
| AT-11 | ✅ | Stage 1 + Stage 2 regressions PASS |
| AT-12 | ✅ | Non-TEMPORAL fragment refused at kernel (`CORE_REFUSAL`) |

---

## Regressions

```bash
ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb
# typechecker: PASS / semanticir: PASS / stdlib_kernel: PASS / igapp_assembler: PASS

ruby igniter-lang/experiments/stage2_close_candidate/stage2_close_candidate.rb
# stream_fold: PASS / history_bihistory_temporal_access: PASS
# ledger_tbackend_descriptor: PASS / stage1_regression: PASS

ruby igniter-lang/experiments/temporal_executor_phase1_preflight/temporal_executor_phase1_preflight.rb
# PASS (9/9 — S3-R14-C2-P proof unaffected)

ruby igniter-lang/experiments/temporal_executor_composition_integration/temporal_executor_composition_integration.rb
# PASS (9/9 — S3-R15-C2-P proof unaffected)

ruby igniter-lang/experiments/runtime_report_enforcement_preflight/runtime_report_enforcement_preflight.rb
# PASS (pre-live regression chain unaffected)
```

---

## What Remains Before Live-Read Decision / Addendum

| # | Item | Required for |
|---|------|-------------|
| R1 | `gate3-live-read-decision-addendum-v0` — Architect approval for opening gate3 in lib/ | Live reads in any non-proof context |
| R2 | AT-9: production token authority / signing infrastructure | Phase 2 or any non-proof-local deployment |
| R3 | AT-10: observation persistence — `@observations` is in-memory only | `invariant_persistence` gap closure |
| R4 | TBackend adapter production binding — MemoryBackend is proof-local only | Phase 2 addendum (gate3-decision-record-v0 §Q3 Option C) |
| R5 | BiHistory evaluation (AT-7) — refused at kernel | Separate gate request after `at(vt:,tt:)` proof |
| R6 | Runtime authority registry — no revocation/rotation mechanism | Phase 2 / production authority-revocation |
| R7 | Phase1 class replace/wrap decision — Q1 from S3-R15-C2-P: how does `Phase1` relate to `Phase1TemporalExecutorWithReport` in lib/? | Before any lib/ consolidation |
| R8 | `phase1-lib-prep-regression-chain-v0` — dedicated lib-prep regression fixture | Before lib-prep safety pressure |

None of R1–R8 block proof-local use of `lib/igniter_lang/temporal_executor.rb`.

---

## Non-Authorization

This track does not authorize:

- Live reads from any non-proof-local backend;
- Gate 3 production opening;
- Live Ledger adapter binding;
- Production cache lookup or writes;
- BiHistory serving;
- Stream/OLAP executor paths;
- Package edits;
- Phase 2 addendum work.

---

## Handoff

```text
Card: S3-R16-C1-P
Agent: [Igniter-Lang Implementation Agent]
Role: implementation-agent
Track: igniter-lang/runtime-temporal-executor-lib-prep-v0
Status: done

[D] Decisions
- Phase1 is a standalone lib/ class with no experiment dependency
- Minimal CompatibilityReport hash built inline via compose_report (AT-2 in lib/)
- gate3_authorized: false default — live reads blocked at construction
- Canonical guard order: approval_token → gate_state → scope → cache_key → kernel
- GATE3_AUTHORITY_REF embedded as constant; exact match required (AT-9)
- temporal_live_read_observation emitted unconditionally per access node (AT-10)

[S] Shipped
- lib/igniter_lang/temporal_executor.rb
- experiments/temporal_executor_lib_prep/temporal_executor_lib_prep.rb

[T] Tests / Proofs
- command: ruby igniter-lang/experiments/temporal_executor_lib_prep/temporal_executor_lib_prep.rb
- result: PASS (17/17 checks)
- AT coverage: AT-1..AT-12 all covered or documented
- command: ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb
- result: PASS
- command: ruby igniter-lang/experiments/stage2_close_candidate/stage2_close_candidate.rb
- result: PASS
- command: ruby igniter-lang/experiments/temporal_executor_phase1_preflight/temporal_executor_phase1_preflight.rb
- result: PASS (9/9 — S3-R14-C2-P unaffected)
- command: ruby igniter-lang/experiments/temporal_executor_composition_integration/temporal_executor_composition_integration.rb
- result: PASS (9/9 — S3-R15-C2-P unaffected)
- command: ruby igniter-lang/experiments/runtime_report_enforcement_preflight/runtime_report_enforcement_preflight.rb
- result: PASS

[R] Risks
- Phase1 lib/ class is proof-local only; must not be opened for live reads without gate3-live-read-decision-addendum-v0
- AT-9 proof-local only; no production signing/registry
- R1–R8 documented; none block proof-local use
- Phase1 vs Phase1TemporalExecutorWithReport consolidation question (R7) deferred

[Q] Open questions
- Q1 (carried from S3-R15-C2-P): How does Phase1 relate to Phase1TemporalExecutorWithReport in the eventual lib/ consolidation?

[Next] Suggested next slice
- runtime-temporal-executor-lib-prep-safety-pressure-v0 (pressure on lib-prep boundary)
- phase1-lib-prep-regression-chain-v0 (dedicated lib-prep regression fixture, R8)
- compatibility-report-persistence-audit-v0 (R3 / AT-10 persistence gap)
- gate3-live-read-decision-addendum-v0 (R1 — only after safety pressure and regression pass)
```
