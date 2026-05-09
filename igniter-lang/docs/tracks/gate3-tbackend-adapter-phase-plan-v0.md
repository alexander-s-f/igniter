# Track: Gate 3 TBackend Adapter Phase Plan v0

Card: S3-R12-C4-P
Agent: `[Igniter-Lang Bridge Agent]`
Role: `bridge-agent`
Track: `gate3-tbackend-adapter-phase-plan-v0`
Status: done
Date: 2026-05-09

Affected neighbor roles: `[Igniter-Lang Research Agent]`,
`[Igniter-Lang Compiler/Grammar Expert]`

---

## Purpose

Clarify the TBackend adapter phase boundary for the revised Gate 3 request.

This resolves the C-3 ambiguity from X1:

```text
"Gate 3 authorizes TBackend History[T] valid_time read"
```

must not be read as:

```text
"Gate 3 authorizes a real Ledger-backed adapter"
```

For the first Gate 3 opening, authorization should target the abstract
TBackend read interface only. Concrete adapters are phased.

---

## Source Signals

- Updated Bridge onboarding card says the Gate 3 request is drafted but held
  pending revision, and the current scope recommendation is `History[T]`
  `valid_time` read-only with BiHistory excluded.
- `gate3-ledger-tbackend-scope-and-bihistory-exclusion-v0` recommends first
  Gate 3 scope as `History[T] valid_time read only`.
- `runtime-temporal-executor-gate3-request-v0` already separates Phase 1
  proof-local `MemoryBackend` from Phase 2 real adapter binding.
- Gate 2 descriptor metadata is ratified as report metadata only.
- Gate 3 live operations remain closed until Architect decision.

---

## Decision

[D] The revised Gate 3 request should authorize only:

```text
abstract TBackend History[T] valid_time read interface
```

It should not authorize a real Ledger-backed adapter in the base Gate 3
decision.

Recommended adapter phasing:

```text
Phase 1: proof-local MemoryBackend or equivalent non-Ledger adapter
Phase 2: real Ledger-backed adapter only after explicit Architect sign-off/addendum
```

---

## Phase Table

| Phase | Adapter | Allowed operations | Approval boundary | Explicit exclusions |
|---|---|---|---|---|
| Phase 0 | none | report-only descriptor and approval-token checks | Already landed as prerequisites; no live execution | all live reads/writes/replay |
| Phase 1 | proof-local `MemoryBackend` or equivalent non-Ledger adapter | `History[T]` `valid_time` read via abstract TBackend interface | Covered only if Architect opens restricted Gate 3 | Ledger binding, writes, replay, compact, subscribe, streams, BiHistory |
| Phase 2 | real Ledger-backed adapter | `History[T]` `valid_time` read only | Requires explicit Architect addendum/sign-off naming adapter identity and audit/observation plan | writes, replay, compact, subscribe, streams, BiHistory unless separately approved |
| Future | bitemporal/stream/write adapters | not in this request | separate proof and approval | not implied by Phase 1 or Phase 2 |

Phase 1 may prove `runtime_enforced: true` against a non-Ledger adapter after
Gate 3 opens. Phase 1 must not call Ledger.

Phase 2 is not authorized by the base Gate 3 request. A real Ledger adapter
requires a named Architect addendum before binding.

---

## Approval Boundary

Base Gate 3 approval may authorize:

- `TemporalExecutor` route for `History[T]`;
- explicit `valid_time` coordinate;
- abstract TBackend `history_read` / `read_as_of` interface;
- proof-local or non-Ledger adapter satisfying the interface;
- `runtime_enforced: true` only for the authorized Phase 1 proof surface;
- observation emission for each approved read;
- refusal of any out-of-scope operation.

Base Gate 3 approval must not authorize:

- real Ledger-backed adapter binding;
- Ledger reads through package code;
- Ledger writes;
- append;
- replay;
- compact;
- subscribe;
- stream binding;
- `BiHistory[T]`;
- `bihistory_at`;
- transaction-time reads;
- two-axis `at(vt:, tt:)`;
- production cache;
- migration execution.

Phase 2 Ledger adapter sign-off must record:

- adapter identity and package/class boundary;
- descriptor hash / registry hash expected at binding time;
- operation scope: `History[T]` `valid_time` read only;
- approval token scope;
- audit observation emission shape;
- observation persistence or explicit persistence-gap handling;
- refusal cases for writes/replay/compact/subscribe/stream/BiHistory.

---

## C1-Ready Wording Block

Use this wording in the Gate 3 request document if needed:

```text
TBackend adapter scope is phased.

The base Gate 3 request authorizes only the abstract TBackend interface for
History[T] valid_time read-only access. It does not authorize any concrete
Ledger-backed adapter or package binding.

Phase 1, if Gate 3 is approved, may use a proof-local MemoryBackend or
equivalent non-Ledger adapter to satisfy the abstract read interface and prove
runtime_enforced:true behavior for the restricted History[T] valid_time path.
Phase 1 must not call Ledger.

Phase 2, real Ledger-backed TBackend binding, requires a separate explicit
Architect sign-off/addendum to the Gate 3 decision record before any package
binding or Ledger read occurs. The addendum must name the adapter identity,
operation scope, audit/observation mechanism, and persistence-gap handling.

Ledger writes, append, replay, compact, subscribe, stream binding, BiHistory[T],
bihistory_at, transaction-time reads, and two-axis at(vt:, tt:) remain excluded
from both Phase 1 and the base Gate 3 request.
```

---

## BiHistory Exclusion Preserved

BiHistory remains excluded from the first Gate 3 opening.

Required warning:

```text
descriptor bihistory_read is metadata evidence only;
it does not prove physical BiHistory at(vt:, tt:) serving
```

Phase 2 Ledger adapter sign-off cannot silently add BiHistory. Adding
`BiHistory[T]`, `bihistory_at`, transaction-time reads, or two-axis
`at(vt:, tt:)` requires a separate proof and explicit Architect approval.

---

## Non-Authorization

This track does not:

- edit packages;
- open Gate 3;
- approve Phase 1;
- approve Phase 2;
- bind RuntimeMachine to a live adapter;
- call Ledger;
- authorize Ledger reads/writes/replay/compact/subscribe;
- authorize stream binding;
- authorize BiHistory.

It only clarifies the phase boundary for the Gate 3 request.

---

## Handoff

```text
Card: S3-R12-C4-P
Agent: [Igniter-Lang Bridge Agent]
Role: bridge-agent
Track: gate3-tbackend-adapter-phase-plan-v0
Status: done

[D] Decisions
- Gate 3 should authorize the abstract TBackend History[T] valid_time read
  interface only.
- Phase 1 uses proof-local MemoryBackend or equivalent non-Ledger adapter.
- Phase 2 real Ledger-backed adapter requires explicit Architect addendum.
- BiHistory remains excluded.

[S] Signals
- C-3 ambiguity is resolved: abstract TBackend interface does not imply concrete
  Ledger adapter binding.
- Wording block is ready to paste into the C1 Gate 3 request if needed.

[T] Tests / Proofs
- Docs-only phase plan; no package specs or proof fixture run.

[R] Risks / Recommendations
- Do not let Phase 1 runtime_enforced:true imply real Ledger authorization.
- Do not let a Phase 2 Ledger addendum expand into writes/replay/compact/
  subscribe/stream/BiHistory.

[Next] Suggested next slice
- Apply the C1-ready wording block to the Gate 3 request if the Architect asks
  for a direct document revision.
```
