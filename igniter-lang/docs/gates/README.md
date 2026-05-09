# Igniter-Lang Gates

Status: active
Owner: `[Architect Supervisor / Codex]`
Last updated: 2026-05-08

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
| Gate 3 — live TBackend / executor | 📋 request pending | See request below |

---

## Gate 3 Status

```text
Gate 3 scope: live Ledger/TBackend read-write-replay, runtime executor, production cache
Gate 3 state: CLOSED

Pending request: runtime-temporal-executor-gate3-request-v0.md
  Proposed restricted scope: live TEMPORAL History[T] valid_time evaluation only
  Excludes: BiHistory, stream/OLAP executor, Ledger write, production cache
  Pending: Architect decision
```

---

## Request Index

| File | Card | Status | Proposed Scope |
|------|------|--------|----------------|
| [runtime-temporal-executor-gate3-request-v0.md](runtime-temporal-executor-gate3-request-v0.md) | S3-R11-C1-G | pending | Restricted Gate 3: History[T] valid_time live eval; PROP-030 token required; BiHistory/Ledger write/cache excluded |

## Decision Index

_No gate decisions recorded yet._
