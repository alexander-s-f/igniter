# Gate 3 Opening Request: Runtime TEMPORAL Executor (Restricted Scope) v0

Card: S3-R11-C1-G
Agent: [Igniter-Lang Meta Expert]
Role: meta-expert
Mode: Gate Request Author
Track: `igniter-lang/runtime-temporal-executor-gate3-request-v0`
Date: 2026-05-08
Status: request — pending Architect decision

**This document is a formal request to the Architect Supervisor. It does not
open Gate 3. Only the Architect Supervisor can open Gate 3.**

---

## I. What Is Being Requested

A restricted Gate 3 opening for **live TEMPORAL History[T] evaluation over
valid_time only**.

This means:

- A `TemporalExecutor` may be implemented and bound to `RuntimeMachine`.
- A `TBackend` adapter may be called for `history_read` reads against a
  `read_as_of` time coordinate.
- `CompatibilityReport` transitions from `report_only: true` to a production
  report with `runtime_enforced: true` for the TEMPORAL execution path.
- `ExecutorApprovalToken` must be validated before any live TBackend call is
  attempted.
- Production `RuntimeMachine` checks Gate 3 state, approval token, and
  TEMPORAL cache-key schema independently before evaluating.

Nothing in this request authorizes BiHistory, stream evaluation, OLAP
evaluation, Ledger write/append/replay/compact, production memoization, or
self-issued approval tokens.

---

## II. Evidence Summary (S3-R7 → S3-R10)

All evidence below is proof-local. It demonstrates the required boundary
semantics without enabling live operations.

### S3-R7: Load Boundary Established

| Track | Verdict | Signal |
|-------|---------|--------|
| `runtime-compatibility-report-temporal-load-check-v0` | PASS | `load_accept_evaluate_refuse` proven; load is inspection-only; evaluate is blocked |

Evaluation readiness depends on: required capabilities present + live TBackend
binding + temporal executor + explicit approval + Gate 3 authorized + artifact
`guard_policy` allows evaluation.

### S3-R8: Positive Executor Flags Are Insufficient

| Track | Verdict | Signal |
|-------|---------|--------|
| `runtime-compatibility-report-executor-boundary-v0` | PASS | Runtime profiles with `temporal_executor: true` + `live_tbackend_binding: true` still block; missing explicit approval blocks before executor, TBackend, or cache |

Key proof: even a claimed executor + live binding still produces
`executor_approval_missing` without an explicit `ExecutorApprovalToken`.

### S3-R9: Approval Token Shape + Cache Key Contract

| Track | Verdict | Signal |
|-------|---------|--------|
| `prop-030-executor-approval-token-contract-v0` | docs-only | `ExecutorApprovalToken` shape formalized; PROP-030 authored; Gate 3 still closed |
| `executor-boundary-cache-key-contract-v0` | PASS | CORE-shaped key for TEMPORAL refused with L-T5; silent staleness prevented |

Key proof: History `same inputs + different as_of` produces different TEMPORAL
keys and identical CORE keys. CORE key for TEMPORAL is semantic corruption, not
a cache detail.

### S3-R10: Validation Matrix + Enforcement Proof

| Track | Verdict | Signal |
|-------|---------|--------|
| `executor-approval-token-report-proof-v0` | PASS | 13-case token validation matrix PASS; valid token with Gate 3 closed = `temporal_gate3_closed` not approval error |
| `guarded-runtime-executor-approval-enforcement-v0` | PASS | `GuardedRuntimeMachine` enforces missing token, Gate 3 closed, bad TEMPORAL cache key; History and BiHistory load-for-inspection preserved; no live ops attempted |

Key proofs:
- Approval is necessary but insufficient: valid token + Gate 3 closed → still
  blocked at `temporal_gate3_closed`.
- Gate 3 and approval are independent checks; both must pass.
- CORE-shaped cache key refusal (L-T5) is enforced at the executor boundary
  before any cache lookup or TBackend access.

---

## III. Decision Table

### Authorize (if Architect approves Gate 3)

| Item | Scope | Condition |
|------|-------|-----------|
| `TemporalExecutor` implementation | History[T] valid_time read only | Production code; proof-local executor also acceptable as first implementation |
| TBackend `read_as_of(as_of: DateTime)` call | History[T] only | `history_read` capability; Architect-trusted TBackend adapter only |
| `runtime_enforced: true` in CompatibilityReport | TEMPORAL History path only | Must not be set for paths not authorized by this gate |
| `ExecutorApprovalToken` production validation | Architect-signed token required | Cannot use proof-local deterministic hash in production |
| Gate 3 state check in `RuntimeMachine` | Independent of token presence | Token presence does not replace Gate 3 check |
| TEMPORAL cache-key enforcement at executor boundary | L-T5 before cache/TBackend | Must precede every cache lookup and TBackend call |

### Exclude (not authorized by this request)

| Item | Reason |
|------|--------|
| `BiHistory[T]` / bitemporal evaluation | Physical `at(vt:, tt:)` serving proof has not landed; cannot authorize two-axis live eval |
| Stream executor | No stream executor proof; ESCAPE/stream surface separate from TEMPORAL lane |
| OLAP executor | No executor proof; OLAP is separate language surface |
| Ledger `append` / `write` / `replay` / `compact` | Gate 3 has never authorized Ledger write operations; separate gate decision required |
| Production RuntimeMachine memoization / cache | Proof-local only (S3-R3-C3, S3-R4-C5); production cache is a separate authorization |
| Self-issued `ExecutorApprovalToken` | Tokens not backed by Architect recorded decision are invalid; authority registry must be Architect-controlled |
| Ledger-backed TBackend (real Ledger reads) | Gate 3 originally opened metadata-only (Gate 2); read binding against real Ledger requires Architect decision on audit trail and observation persistence |

### Require (before any live eval is attempted)

| Condition | Where checked | Evidence reference |
|-----------|--------------|-------------------|
| `runtime_enforced: true` set explicitly | CompatibilityReport | R7 load check; R8 executor boundary |
| CompatibilityReport is a single composed production report | CompatibilityReport | R8 boundary; must not split report/enforcement |
| `RuntimeMachine` checks readiness before executor/cache/TBackend | Production RuntimeMachine | R10 guarded enforcement proof |
| `ExecutorApprovalToken` validated (all PROP-030 fields) | RuntimeMachine / CompatibilityReport | R10 token proof; 13-case matrix |
| Gate 3 state checked independently of token | RuntimeMachine | PROP-030 §7; R10 proof |
| TEMPORAL cache-key schema checked before any cache or backend | Executor boundary | R9 cache key contract; L-T5 |
| Trusted authority registry defined by Architect | ExecutorApprovalToken | PROP-030 §3; open Q1 below |
| Audit observation emitted per live read | TemporalExecutor | See open Q5 below |

### Defer (not in this request; future gate or separate decision)

| Item | Defer to |
|------|----------|
| BiHistory[T] live evaluation | Separate gate request after physical `at(vt:, tt:)` serving proof |
| Production RuntimeMachine cache | Separate production cache gate decision |
| Ledger write/append/replay | Separate gate decision; write is a higher-risk boundary than read |
| Stream / OLAP / invariant executor | Respective language surface gates |
| MCP / mesh temporal routing | Future mesh gate |
| Parser coordinate syntax for temporal reads | Future PROP-029+ proposal |
| CompatibilityReport persistence and audit receipts | `compatibility-report-persistence-audit-v0` track (not yet landed) |

---

## IV. Open Decisions — Architect Must Approve or Reject

These questions cannot be resolved by agents. Each requires an explicit
Architect decision before production executor work begins.

**Q1 — Token authority registry**

PROP-030 specifies `authority_ref` pointing to a recorded Architect decision.
Who owns the trust anchor? Is it:

- A specific key or hash recorded in `docs/gates/` alongside this document?
- A runtime config field that carries the authority ref at startup?
- A per-deployment policy file baked into the `.igapp/` requirements?

Decision required: authority source, format, and revocation mechanism.

**Q2 — BiHistory exclusion scope**

Is BiHistory[T] excluded from this Gate 3 opening permanently (requires new
gate) or temporarily (included once `at(vt:, tt:)` serving proof lands, within
this gate)?

Decision required: permanent exclusion requiring a separate gate, or deferred
inclusion within Gate 3.

**Q3 — TBackend adapter scope**

The requested authorization is `history_read` reads only. Acceptable TBackend
adapters for a first implementation:

- Option A: proof-local `MemoryBackend` with `read_as_of` (minimal; no network)
- Option B: real external TBackend adapter for target store (maximum; requires integration)
- Option C: proof-local first, then Architect approval before real adapter binding

Decision required: minimum viable adapter for Gate 3 initial implementation.

**Q4 — Production cache scope**

Is production memoization of TEMPORAL History reads in scope for this opening
or deferred?

Arguments for in-scope: cache key contract is proven (R9); freshness states
are defined; TEMPORAL key schema prevents silent staleness.

Arguments for deferral: no production cache store is implemented; cache
invalidation on TBackend state change is unproven; separate gate is cleaner.

Decision required: include production cache in Gate 3 or keep deferred.

**Q5 — Audit observation per live read**

Does every authorized `read_as_of` call need to emit a structured observation
record (per the PROP-005 observation envelope)? If so:

- What observation kind covers a live temporal read?
- Where is it persisted (invariant persistence gap is still open)?

Decision required: audit trail requirement for Gate 3 temporal reads.

**Q6 — Executor refusal for CORE contracts**

If a CORE contract happens to load with a runtime profile that has Gate 3 open,
does the executor check `fragment_class` and refuse to apply temporal evaluation
to CORE nodes?

Expected answer: yes — TEMPORAL executor must check manifest `fragment_class`
and refuse CORE artifacts. Explicit confirmation requested.

---

## V. Production Acceptance Checklist

When Architect approves Gate 3 (restricted), the implementation must satisfy
these conditions before any live TEMPORAL read is attempted:

```text
AT-1  CompatibilityReport transitions from report_only:true to runtime_enforced:true
      for the TEMPORAL execution path. This must be set explicitly, not inferred.

AT-2  CompatibilityReport is composed as a single production report, not as two
      separate report-only and enforcement objects.

AT-3  RuntimeMachine checks evaluation_readiness from CompatibilityReport before
      executor, cache, or TBackend entry. Runtime does not call executor when
      evaluation_readiness is blocked.

AT-4  ExecutorApprovalToken is validated against all PROP-030 fields:
        kind, version, gate, scope, artifact_ref, contract_ref,
        required_capability, authority_ref, expiry, revocation, evidence_ref.
      Malformed, missing, expired, revoked, wrong-gate, wrong-scope, or
      wrong-artifact tokens refuse before any TBackend call.

AT-5  Gate 3 state is checked independently of token presence. A valid token
      with Gate 3 closed must still refuse with runtime.temporal_gate3_closed.

AT-6  TEMPORAL cache-key schema is checked at the executor boundary before any
      cache lookup or TBackend access. A CORE-shaped key for a TEMPORAL contract
      is refused with L-T5 (runtime.temporal_cache_schema_mismatch) before the
      read is attempted.

AT-7  No live BiHistory[T] evaluation is performed. If a BiHistory artifact
      reaches the executor, it must be refused with a gate-scope-exclusion refusal.

AT-8  No Ledger write, append, replay, or compact operation is called from the
      TEMPORAL executor path.

AT-9  The trusted authority for ExecutorApprovalToken is recorded in the
      Architect decision document. Proof-local deterministic hash signatures must
      not be used in production token validation.

AT-10 Every authorized live read emits a structured observation record (if Q5
      is approved). Runtime does not silently consume TBackend reads.

AT-11 Stage 1 regression PASS. Stage 2 regression PASS. All existing proofs
      pass after executor implementation lands.
```

---

## VI. Recommendation

**Approve restricted Gate 3** with the following conditions:

1. Architect records the trusted authority ref for `ExecutorApprovalToken` in
   `docs/gates/gate3-decision-record-v0.md`.
2. BiHistory is explicitly deferred (Q2 = separate gate required).
3. TBackend adapter scope defaults to Option C (proof-local first, then
   approval before real adapter).
4. Production cache is deferred (Q4 = not in this opening).
5. Audit observation is required for every live read (Q5 = yes), but
   persistence is proof-local until invariant persistence gap closes.
6. CORE-contracts are refused by the TEMPORAL executor (Q6 = confirmed).
7. AT-1 through AT-11 are verified before any live read is executed.

**Hold** if any of the following is unresolved:

- Architect cannot record the authority ref before executor implementation
  starts.
- Audit observation requirement creates a blocking dependency (invariant
  persistence not ready).

**Redirect** if:

- BiHistory must be included in the first Gate 3 implementation (go back to
  proof, then file a new request covering both axes).
- The Architect prefers to open a full Gate 3 (not restricted) — in that case
  this request document should be superseded by a broader scope request.

---

## VII. Not In This Request

```text
❌ Gate 3 authorization                    — only the Architect opens Gate 3
❌ ExecutorApprovalToken implementation   — requires Architect authority record first
❌ TemporalExecutor implementation        — follows gate opening
❌ Any live TBackend/Ledger call          — no live operations in this document
❌ Parser coordinate syntax               — not a gate concern
❌ BiHistory evaluation                   — explicitly excluded
❌ Stream / OLAP executor                 — separate lane
❌ Production cache                       — deferred
```

---

## Handoff

```text
Card: S3-R11-C1-G
Agent: [Igniter-Lang Meta Expert]
Role: meta-expert
Track: igniter-lang/runtime-temporal-executor-gate3-request-v0
Status: done — request authored; pending Architect decision

[D] Decisions made in this document:
- Default proposed scope: live TEMPORAL History[T] valid_time only.
- BiHistory explicitly excluded until physical at(vt:, tt:) serving proof lands.
- Stream/OLAP/Ledger write/production cache excluded.
- 11 production acceptance conditions (AT-1..AT-11) defined.
- 6 open decisions (Q1..Q6) require Architect resolution.
- Recommendation: approve restricted Gate 3 with conditions; hold if authority
  ref cannot be recorded before implementation starts.

[S] Shipped:
- docs/gates/ directory created.
- docs/gates/runtime-temporal-executor-gate3-request-v0.md authored.
- tracks/README.md updated with R11-C1-G entry.

[R] Risks:
- Gate 3 must not be opened before authority ref is recorded (Q1).
  A missing authority source means tokens cannot be validated in production.
- BiHistory exclusion must be explicit in the Architect decision document.
  An implicit inclusion would create an unproven two-axis live eval path.
- AT-6 (TEMPORAL cache-key check before cache/TBackend) must be verified
  in the executor implementation before any read. Silent staleness is the
  primary correctness risk for TEMPORAL evaluation.

[Next]:
- Architect Supervisor: review, and either:
  (a) open Gate 3 via docs/gates/gate3-decision-record-v0.md; or
  (b) redirect with scope changes; or
  (c) hold pending Q1/Q5 resolution.
- If approved: Research Agent implements executor with AT-1..AT-11 as acceptance.
- If approved: Compiler/Grammar Expert records authority format in PROP-030 errata.
```
