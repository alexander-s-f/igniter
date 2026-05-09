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
| Gate 3 — live TBackend / executor | signed-approved-restricted Phase 1 | Restricted Phase 1 non-proof reads authorized only inside signed addendum scope; no Ledger/BiHistory/cache/audit |

---

## Gate 3 Status

```text
Gate 3 scope: live Ledger/TBackend read-write-replay, runtime executor, production cache
Gate 3 state: SIGNED-APPROVED-RESTRICTED-PHASE1-LIVE-READ

Request: runtime-temporal-executor-gate3-request-v0.md
  Proposed restricted scope: live TEMPORAL History[T] valid_time evaluation only
  Excludes: BiHistory, stream/OLAP executor, Ledger write, production cache
  Decision: approved-restricted-phase1

Decision: gate3-decision-record-v0.md
  Authorized: Phase 1 TEMPORAL History[T] valid_time executor implementation
  Adapter: proof-local or non-Ledger abstract TBackend only
  Authority: architect-supervisor://igniter-lang/gates/gate3/runtime-temporal-executor/restricted-history-valid-time-v0/2026-05-09
  Pre-live: closed for restricted Phase 1 by R20 signed addendum; live reads
    now authorized only within signed addendum scope
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
    routed and later closed by R19
  R19 repair: post-R18 regression rerun PASS 15/15; guard-order amendment
    confirmed; X1 PROCEED to Architect signature review
  R20 signature: addendum signed-approved-restricted-phase1-live-read
  R20 post-signature fixture: PASS 10/10; signing is policy-only, executor
    guard order unchanged, excluded surfaces remain closed
  R20 post-signature pressure: PROCEED; no widened surface; low notes routed
  R21 audit envelope: PASS 10/10; explicit audit-ready export, not persisted;
    no durable audit, production storage, Ledger write, or authority registry
  R21 authority registry shape: PASS 11/11; proof-local caller policy metadata;
    no executor calls, signing, keys, production authority service, or Phase 2
  R21 audit/registry pressure: PROCEED; production checklist P-1..P-7 routed

Authorized signed-addendum scope:
  IgniterLang::TemporalExecutor::Phase1
  History[T] valid_time read
  single explicit as_of coordinate
  MemoryBackend or explicitly named non-Ledger Phase 1 backend
  no durable side effects, production cache, Ledger package binding, BiHistory,
    stream/OLAP, writes, replay, compact, subscribe, production signing/registry,
    or durable audit
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
| Runtime temporal executor lib-prep | landed proof-local | R16 C1 adds `lib/igniter_lang/temporal_executor.rb`; targeted proof PASS 17/17; default `gate3_authorized: false` preserves caller-policy authorization |
| Dedicated lib-prep regression chain | PASS post-C1 | R17 rerun records 14/14 PASS across base chain, pre-live fixtures, C1 proof, Stage 1, and Stage 2 |
| Lib boundary spec sync | done post-C1 | R17 Ch7 sync names `IgniterLang::TemporalExecutor::Phase1` as proof-local boundary, not language semantics |
| Lib-prep safety pressure | PROCEED proof-local | S3-R17-X1 confirms eight scope guarantees; routes pre-production items |
| Live-read decision addendum | signed-approved-restricted-phase1-live-read | S3-R20-C1-A closes signature blocker; `gate3_authorized: true` allowed only by callers that cite the signed addendum and stay inside the restricted scope |
| Proof-local authority/observation comments | done | S3-R18 C2 clarifies authority URI is not cryptographic, observations are in-memory/non-audit, and `gate3_authorized` is caller honor-system |
| Scope-exclusion reason aliases | done | S3-R18 C3 canonicalizes lib out-of-scope emissions to `runtime.temporal_scope_exclusion`; legacy aliases retained |
| Backend identity guard | done Phase 1 / Phase 2 still closed | S3-R18 C4 blocks unmarked, Ledger-backed, Ledger proxy, and malformed identity backends before scope/cache/kernel/read |
| Addendum safety pressure | PROCEED with pre-signing conditions | S3-R18-X1 finds no hidden live-read path; requires post-R18 full regression rerun and guard-order amendment before signature |
| Post-R18 full regression rerun | PASS / closed | S3-R19 C1 records 15/15 PASS and `observation.backend_identity_emitted: ok` |
| Addendum guard-order amendment | done / closed | Draft now matches implementation: `approval_token -> gate_state -> backend_identity -> scope -> cache_key -> executor_backend` |
| Addendum pre-signature pressure | PROCEED to Architect review | S3-R19-X1 closed blockers 1-5; superseded by S3-R20 signature |
| Architect signature/status update | done | S3-R20-C1-A signs the addendum for restricted Phase 1 only |
| First post-signature fixture | PASS 10/10 | S3-R20-C2-P proves policy-only change, unchanged guard order, MemoryBackend and explicit non-Ledger paths pass, excluded surfaces remain closed |
| Post-signature runtime pressure | PROCEED | S3-R20-X1 confirms no scope widening or behavior drift; low traceability/honor-system/full-chain notes remain non-blocking |
| Compatibility audit envelope | proof-local PASS / not persisted | S3-R21-C1-P defines explicit `audit_ready_not_persisted` export; no durable audit or production storage |
| Authority registry shape | proof-local PASS | S3-R21-C2-P defines caller-side active/revoked/superseded/missing/scope/capability/malformed cases; no signing/keys/executor calls |
| Audit/registry pressure | PROCEED | S3-R21-X1 confirms durable audit and production signing are not implied; routes P-1..P-7 pre-production checklist |
| Runtime authority registry v1 | not implemented | Required before production authority-revocation work; durable registry storage/status receipts remain future |
| Production signing/key management | not implemented | Must remain separate from registry shape; sequence after registry v1 before production tokens |
| Real Ledger adapter/package binding | closed | Requires explicit Architect addendum after Phase 1 |
| BiHistory / transaction-time | closed | Requires separate gate; cannot be added by quiet Phase 1/2 addendum |
| Production cache | closed | Requires separate approval; proof-local cache does not imply production memoization |
| Durable audit / production storage | closed | R21 C1 is audit-ready/not-persisted only; durable-observation-persistence-v0 remains future |

---

## Request Index

| File | Card | Status | Proposed Scope |
|------|------|--------|----------------|
| [runtime-temporal-executor-gate3-request-v0.md](runtime-temporal-executor-gate3-request-v0.md) | S3-R11-C1-G / S3-R12-C1-S | approved-restricted | Restricted Gate 3: History[T] valid_time eval; PROP-030 token required; BiHistory/Ledger write/cache excluded |

## Decision Index

| File | Card | Status | Scope |
|------|------|--------|-------|
| [gate3-decision-record-v0.md](gate3-decision-record-v0.md) | S3-R13-C1-A | approved-restricted-phase1 | Phase 1 implementation only: TEMPORAL History[T] valid_time via abstract proof-local/non-Ledger TBackend; pre-live blockers later closed by R20 signed addendum |
| [gate3-live-read-decision-addendum-v0.md](gate3-live-read-decision-addendum-v0.md) | S3-R20-C1-A | signed-approved-restricted-phase1-live-read | Signed addendum for first restricted Phase 1 non-proof read path; Phase 2/Ledger/BiHistory/stream/OLAP/cache/durable audit remain closed |
