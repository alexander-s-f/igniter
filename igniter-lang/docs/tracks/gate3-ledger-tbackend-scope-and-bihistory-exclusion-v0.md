# Track: Gate 3 Ledger TBackend Scope And BiHistory Exclusion v0

Card: S3-R11-C3-G
Agent: `[Igniter-Lang Bridge Agent]`
Role: `bridge-agent`
Track: `gate3-ledger-tbackend-scope-and-bihistory-exclusion-v0`
Status: done
Date: 2026-05-09

Affected neighbor roles: `[Igniter-Lang Research Agent]`,
`[Igniter-Lang Compiler/Grammar Expert]`

---

## Purpose

Define the Ledger/TBackend scope boundary for a future Gate 3 request.

Gate 2 is already ratified, but only for metadata:

```text
ratified descriptor metadata -> trusted report-only input
```

Gate 2 does not authorize live operations. This track narrows what the first
Gate 3 request should ask for.

---

## Current Evidence

Accepted evidence:

- Gate 2 descriptor metadata is ratified as trusted report metadata.
- `CompatibilityReport.backend_check.temporal_backend_descriptor` can consume
  descriptor metadata as report-only evidence.
- Executor approval token/report/guard proofs exist as prerequisites, not
  execution authorization.
- Gate 3 remains closed.

BiHistory evidence status:

```text
descriptor bihistory_read is metadata evidence only;
it does not prove physical BiHistory at(vt:, tt:) serving
```

Current package review evidence says the native data plane does not yet prove a
true two-axis `at(vt:, tt:)` query. Therefore BiHistory is not ready for the
first Gate 3 live-operation request.

---

## Minimal Gate 3 Live Operation Candidate

Recommended first live operation candidate:

```text
History[T] valid_time read only
```

Candidate operation boundary:

| Axis | Scope |
|---|---|
| Language type | `History[T]` only |
| Time dimension | `valid_time` point read only |
| Runtime operation | one approved temporal read path |
| TBackend operation | read-only |
| Descriptor input | Gate 2 descriptor metadata as report/preflight evidence |
| Cache key | must include explicit time coordinate |
| Evidence | observation/receipt-producing, capability checked |
| Enforcement | only if Gate 3 is explicitly opened by Architect Supervisor |

Explicitly out of scope for the first Gate 3 request:

- Ledger writes;
- append;
- replay;
- compact;
- subscriptions;
- stream binding;
- `BiHistory[T]`;
- `bihistory_at`;
- transaction-time reads;
- two-axis `at(vt:, tt:)`;
- migration execution;
- Ledger-as-core semantics.

---

## BiHistory Options

### Option A: Include BiHistory

Option A would include `BiHistory[T]` or `bihistory_at` in the first Gate 3
request.

Required proof before Option A is acceptable:

- physical data-plane API for `at(vt:, tt:)`;
- valid-time and transaction-time serving semantics;
- evidence that valid-time is an indexed/readable axis, not only a field;
- replay/restore fidelity that preserves identity and transaction time;
- fixture proving two-axis reads against representative data;
- CompatibilityReport evidence distinguishing descriptor capability from
  physical serving proof;
- RuntimeMachine refusal cases for missing `vt`, `tt`, or serving capability.

Current status:

```text
not proven
```

Recommendation:

```text
do not include Option A in the first Gate 3 request
```

### Option B: Exclude BiHistory

Option B excludes `BiHistory[T]` from the first Gate 3 request and asks only for
`History[T]` valid-time reads.

Benefits:

- keeps Gate 3 small enough to verify;
- avoids claiming physical bitemporal serving from descriptor metadata;
- lets the first live TBackend path prove read-only capability and evidence
  receipts before adding replay or transaction-time semantics;
- preserves the value-index warning from C3/R10.

Risks:

- `BiHistory[T]` remains descriptor/report metadata only;
- future BiHistory work needs its own package/data-plane proof slice;
- applications needing transaction-time semantics stay blocked.

Recommendation:

```text
choose Option B for the first Gate 3 request
```

---

## Recommended Exclusion Language

Use this language in the Gate 3 request:

```text
The first Gate 3 Ledger/TBackend request excludes BiHistory[T].

This request does not authorize bihistory_at, transaction-time reads, two-axis
at(vt:, tt:) serving, replay-derived bitemporal reconstruction, or any claim
that descriptor bihistory_read proves physical serving.

The only live operation candidate is History[T] valid_time read-only access,
with explicit time coordinates, capability checks, evidence receipts, and
CompatibilityReport preflight. Ledger writes, replay, compact, subscriptions,
stream binding, and migrations remain out of scope.
```

---

## Scope Appendix For Gate 3 Request

### Appendix: First Gate 3 Ledger/TBackend Scope

First request name:

```text
ledger_tbackend_history_valid_time_read_v0
```

Allowed:

- consume ratified Gate 2 descriptor metadata as report/preflight evidence;
- verify descriptor hash and registry hash;
- require `history_read`;
- require `valid_time`;
- require read-only TBackend capability;
- require explicit valid-time coordinate;
- require TEMPORAL cache key with time coordinate;
- require observation/receipt output;
- keep all Ledger write/replay/stream surfaces disabled.

Not allowed:

- `BiHistory[T]`;
- `bihistory_at`;
- transaction-time coordinate reads;
- physical `at(vt:, tt:)`;
- Ledger writes/appends;
- Ledger replay;
- compaction;
- subscriptions;
- stream binding;
- migration execution.

Acceptance shape for the future request:

- positive proof: valid `History[T]` read-only request with explicit
  `valid_time` coordinate and approved executor scope;
- negative proof: missing time coordinate blocks;
- negative proof: missing `history_read` or `valid_time` descriptor evidence
  blocks;
- negative proof: any `bihistory_at` / `BiHistory[T]` request blocks;
- negative proof: any write/replay/compact/subscribe/stream request blocks;
- negative proof: CORE-shaped cache key for TEMPORAL read blocks.

---

## Non-Authorization Statement

This track does not open Gate 3.

It does not implement:

- package code;
- RuntimeMachine live binding;
- Ledger calls;
- temporal reads;
- replay;
- writes;
- BiHistory physical serving.

It only prepares the scope boundary for a future Gate 3 request.

---

## Handoff

```text
Card: S3-R11-C3-G
Agent: [Igniter-Lang Bridge Agent]
Role: bridge-agent
Track: gate3-ledger-tbackend-scope-and-bihistory-exclusion-v0
Status: done

[D] Decisions
- Recommend the first Gate 3 request be History[T] valid_time read only.
- Recommend Option B: exclude BiHistory from first Gate 3.
- Gate 2 descriptor metadata remains trusted report-only input, not runtime
  authority.

[S] Signals
- Current evidence does not prove physical BiHistory at(vt:, tt:) serving.
- Descriptor bihistory_read remains metadata evidence only.
- Scope appendix is ready to link from a future Gate 3 request.

[T] Tests / Proofs
- Docs-only scope track; no proof fixture or package spec run.

[R] Risks / Recommendations
- Do not include BiHistory until physical serving proof exists.
- Do not bundle writes, replay, compact, subscriptions, or stream binding into
  the first Gate 3 request.

[Next] Suggested next slice
- Draft runtime-temporal-executor-gate3-request-v0 using the appendix scope and
  recommended BiHistory exclusion language.
```
