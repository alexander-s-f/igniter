# Igniter-Lang Gates

Status: active
Owner: `[Architect Supervisor / Codex]`
Last updated: 2026-05-09

---

## Purpose

Gate documents record formal authorization decisions that permit production
binding of capabilities that are otherwise closed by policy.

Gate requests are authored by `[Igniter-Lang Meta Expert]`.
Gate decisions are made exclusively by `[Architect Supervisor / Codex]`.

A gate request does not open the gate. Only a gate decision document does.

---

## Gate Lifecycle

```text
research proves boundary semantics (proof-local, report-only)
  -> Meta Expert authors gate request document
  -> Architect Supervisor reviews and decides
  -> Architect records gate decision document (approve / restrict / redirect / hold)
  -> Implementation authorized within approved scope only
```

---

## Active Gates

| Gate | Status | Scope |
|------|--------|-------|
| Gate 2 — descriptor metadata | ✅ ratified | Metadata-only descriptor package exposure; no live binding |
| Gate 3 — live TBackend / executor | approved-restricted | Phase 1 implementation only; live reads pre-live blocked; no Ledger/BiHistory/cache |

---

## Gate 3 Status

```text
Gate 3 scope: live Ledger/TBackend read-write-replay, runtime executor, production cache
Gate 3 state: APPROVED-RESTRICTED-PHASE1

Request: runtime-temporal-executor-gate3-request-v0.md
  Proposed restricted scope: live TEMPORAL History[T] valid_time evaluation only
  Excludes: BiHistory, stream/OLAP executor, Ledger write, production cache
  Decision: approved-restricted-phase1

Decision: gate3-decision-record-v0.md
  Authorized: Phase 1 TEMPORAL History[T] valid_time executor implementation
  Adapter: proof-local or non-Ledger abstract TBackend only
  Authority: architect-supervisor://igniter-lang/gates/gate3/runtime-temporal-executor/restricted-history-valid-time-v0/2026-05-09
  Pre-live: blocked until composition, observation, scope-exclusion errata,
    AT-1..AT-12, and regression proof chain pass
  Phase 2: real Ledger-backed adapter requires explicit Architect addendum

Safety review: gate3-decision-safety-pressure-v0.md
  Verdict: PROCEED
  Finding: no hidden authorization leaks; no blocker for Phase 1 implementation
  Follow-up: non-blocking wording amendments landed in decision record

Phase 1 prep review: phase1-implementation-prep-safety-pressure-v0.md
  Verdict: PROCEED for proof-local Phase 1 prep
  Finding: no live-eval, Ledger, BiHistory, or production-cache leak
  R15 closure: C4 ordering fixed, AT-2 closed, AT-9 proof-local PASS,
    regression chain PASS
  R16 lib-prep: C1 landed lib/ Phase1 boundary with targeted 17/17 PASS
  Async-order note: C2 regression and C3 spec-sync tracks were recorded before
    C1 landed and remain stale-blocked/no-op until rerun post-C1
  Safety pressure: no R16 lib-prep safety verdict discovered yet
  Still blocked before live reads: post-C1 rerun, lib-prep safety pressure,
    and explicit Architect live-read addendum
```

---

## Gate 3 Follow-Up Boundaries

| Follow-up | Status | Rule |
|-----------|--------|------|
| Phase 1 authority URI wording | landed | Phase 1 may embed the trusted authority URI as a constant until a registry exists |
| Runtime preflight ordering | closed for lib-prep | R15 fixes canonical approval-token-before-gate ordering; no PROP-030 errata needed |
| AT-2 executor/report integration | closed for lib-prep | R15 proves Phase1TemporalExecutor consumes the composed CompatibilityReport shape |
| AT-9 authority_ref comparison | proof-local PASS for lib-prep | R15 proves exact decision-URI match; production signing/registry remains separate |
| Pre-live regression chain | PASS for lib-prep | R15 records S3-R7..R10 9/9, added pre-live 6/6, and Stage 1/2 close candidates PASS |
| Runtime temporal executor lib-prep | landed proof-local | R16 C1 adds `lib/igniter_lang/temporal_executor.rb`; targeted proof PASS 17/17; `gate3_authorized: false` keeps live reads blocked by default |
| Dedicated lib-prep regression chain | rerun required | R16 C2 track is stale-blocked from before C1 landed; do not treat it as post-C1 PASS |
| Lib boundary spec sync | rerun if naming boundary | R16 C3 track is a stale no-op from before C1 landed; Ch7 remains synced to approved-restricted semantics but not to the new lib boundary |
| Lib-prep safety pressure | not landed | No R16 lib-prep safety verdict found; required before any live-read addendum routing |
| Live-read decision addendum | required / not opened | C1 proof-local PASS is not live-read authorization; only an Architect decision document can open live reads |
| Runtime authority registry | not defined | Required before Phase 2 / production authority-revocation work; not a Phase 1 blocker |
| Real Ledger adapter/package binding | closed | Requires explicit Architect addendum after Phase 1 |
| BiHistory / transaction-time | closed | Requires separate gate; cannot be added by quiet Phase 1/2 addendum |
| Production cache | closed | Requires separate approval; proof-local cache does not imply production memoization |

---

## Request Index

| File | Card | Status | Proposed Scope |
|------|------|--------|----------------|
| [runtime-temporal-executor-gate3-request-v0.md](runtime-temporal-executor-gate3-request-v0.md) | S3-R11-C1-G / S3-R12-C1-S | approved-restricted | Restricted Gate 3: History[T] valid_time eval; PROP-030 token required; BiHistory/Ledger write/cache excluded |

## Decision Index

| File | Card | Status | Scope |
|------|------|--------|-------|
| [gate3-decision-record-v0.md](gate3-decision-record-v0.md) | S3-R13-C1-A | approved-restricted-phase1 | Phase 1 implementation only: TEMPORAL History[T] valid_time via abstract proof-local/non-Ledger TBackend; live reads blocked until pre-live conditions pass |
