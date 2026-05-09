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
    C1 landed; R17 supersedes them with post-C1 reruns
  R17 repair: post-C1 regression rerun PASS 14/14; Ch7 lib-boundary sync rerun done
  Safety pressure: S3-R17-X1 PROCEED for proof-local Phase 1
  Still blocked before live reads: explicit Architect live-read addendum, plus
    routed pre-production safeguards before any non-proof/live use
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
| Dedicated lib-prep regression chain | PASS post-C1 | R17 rerun records 14/14 PASS across base chain, pre-live fixtures, C1 proof, Stage 1, and Stage 2 |
| Lib boundary spec sync | done post-C1 | R17 Ch7 sync names `IgniterLang::TemporalExecutor::Phase1` as proof-local boundary, not language semantics |
| Lib-prep safety pressure | PROCEED proof-local | S3-R17-X1 confirms eight scope guarantees; routes pre-production items |
| Live-read decision addendum | draftable / not opened | R17 evidence supports drafting an Architect addendum route; live reads remain blocked until an explicit decision exists |
| Proof-local authority/observation comments | recommended before non-proof callers | Clarify `GATE3_AUTHORITY_REF` is not cryptographic authorization and `observations` are in-memory, not audit receipts |
| Scope-exclusion reason aliases | required before production/live route | Reconcile lib proof-local reason codes with canonical `runtime.temporal_scope_exclusion` before operator-facing use |
| Backend identity guard | required before Phase 2 binding | Prevent `gate3_authorized: true` from reaching real adapters without an allowed-backend/addendum check |
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
