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
  R18 addendum: gate3-live-read-decision-addendum-v0.md drafted, not signed
  R18 cleanup: proof-local docstrings, reason-code aliasing, and backend
    identity guard landed
  R18 safety pressure: PROCEED for cleanup tracks; two pre-signing conditions
    remain
  R19 repair: post-R18 regression rerun PASS 15/15; guard-order amendment
    confirmed; X1 PROCEED to Architect signature review
  Still blocked before live reads: explicit Architect signature/status change
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
| Live-read decision addendum | draft-not-signed / ready for signature review | S3-R19 evidence closes blockers 1-5; live reads remain blocked until explicit Architect signature/status change |
| Proof-local authority/observation comments | done | S3-R18 C2 clarifies authority URI is not cryptographic, observations are in-memory/non-audit, and `gate3_authorized` is caller honor-system |
| Scope-exclusion reason aliases | done | S3-R18 C3 canonicalizes lib out-of-scope emissions to `runtime.temporal_scope_exclusion`; legacy aliases retained |
| Backend identity guard | done Phase 1 / Phase 2 still closed | S3-R18 C4 blocks unmarked, Ledger-backed, Ledger proxy, and malformed identity backends before scope/cache/kernel/read |
| Addendum safety pressure | PROCEED with pre-signing conditions | S3-R18-X1 finds no hidden live-read path; requires post-R18 full regression rerun and guard-order amendment before signature |
| Post-R18 full regression rerun | PASS / closed | S3-R19 C1 records 15/15 PASS and `observation.backend_identity_emitted: ok` |
| Addendum guard-order amendment | done / closed | Draft now matches implementation: `approval_token -> gate_state -> backend_identity -> scope -> cache_key -> executor_backend` |
| Addendum pre-signature pressure | PROCEED to Architect review | S3-R19-X1 closes blockers 1-5; blocker 6 remains Architect signature/status update |
| Architect signature/status update | required for authorization | Until signed or status-updated by Architect, live reads remain blocked |
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
| [gate3-live-read-decision-addendum-v0.md](gate3-live-read-decision-addendum-v0.md) | S3-R18-C1-A / S3-R19 repair | draft-not-signed / ready for signature review | Draft for first restricted Phase 1 non-proof read path; evidence blockers closed, Architect signature still required |
