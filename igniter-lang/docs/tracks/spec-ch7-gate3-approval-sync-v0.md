# Track: Spec Ch7 Gate 3 Approval Sync v0

Card: S3-R14-C5-P
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Track: `spec-ch7-gate3-approval-sync-v0`
Status: done
Date: 2026-05-09

Affected neighbor roles: `[Igniter-Lang Research Agent]`,
`[Igniter-Lang Meta Expert]`, `[Igniter-Lang Bridge Agent]`

---

## Goal

Sync `docs/spec/ch7-runtime.md` with approved-restricted Gate 3 Phase 1
semantics.

---

## Updated Spec

[S] Updated:

```text
docs/spec/ch7-runtime.md
```

The chapter now records:

- approved-restricted Phase 1 state;
- `History[T]` valid-time-only scope;
- composed CompatibilityReport requirement;
- AT-1..AT-12 summary;
- `runtime.temporal_scope_exclusion`;
- `temporal_read_observation`;
- closed scopes for Ledger, BiHistory, stream/OLAP, production cache, parser
  syntax, and mesh/MCP routing.

---

## Decisions Captured

[D] Phase 1 is approved for implementation but still pre-live blocked.

```text
Gate 3 Phase 1 implementation may begin.
No live Phase 1 read may execute until pre-live conditions, AT-1..AT-12,
and the S3-R7..S3-R10 regression chain pass.
```

[D] Approved Phase 1 scope:

```text
History[T] + valid_time + history_read + read_as_of(as_of: DateTime)
```

[D] Runtime readiness must come from one composed `CompatibilityReport`.

Split report-only and enforcement fragments are forbidden.
`runtime_enforced: true` is valid only on the composed report for the approved
Phase 1 path.

[D] `runtime.temporal_scope_exclusion` is now listed as the canonical
out-of-scope TEMPORAL executor refusal.

[D] `temporal_read_observation` is now listed as the required AT-10 observation
for authorized live History reads.

[D] Ch7 now names `runtime.temporal_pre_live_conditions_unmet` for the specific
approved-but-not-yet-live state. This is separate from:

- `runtime.temporal_gate3_closed`;
- `runtime.temporal_execution_unsupported`;
- `runtime.temporal_scope_exclusion`;
- `runtime.temporal_cache_schema_mismatch`.

---

## Closed Scopes Preserved

[S] The sync explicitly preserves these as closed:

- Ledger package binding;
- Ledger reads through package code;
- Ledger write/append/replay/compact/subscribe;
- `BiHistory[T]` / `at(vt:, tt:)`;
- stream executor;
- OLAP executor;
- invariant persistence;
- production RuntimeMachine cache/memoization;
- parser coordinate syntax;
- MCP / mesh temporal routing.

No parser, grammar, or SemanticIR node change is introduced.

---

## Spec-Lag Closed

[D] Closed Ch7 lag from:

- `docs/gates/gate3-decision-record-v0.md`;
- `docs/proposals/PROP-030A-temporal-scope-exclusion-errata-v0.md`;
- `docs/tracks/prop-005-temporal-read-observation-v0.md`;
- `docs/tracks/compatibility-report-composition-v0.md`.

Ch7 no longer describes TEMPORAL evaluation only as a future unsupported path.
It now distinguishes:

```text
load accepted for inspection
Phase 1 implementation approved-restricted
live reads blocked until pre-live/AT/regression proof pass
Phase 2 and adjacent surfaces closed
```

---

## Remaining Gaps

[R] Runtime implementation still must prove AT-1..AT-12 before live reads.

[R] Phase 2 Ledger adapter remains closed until Architect addendum.

[R] Production cache remains closed; Ch7 preserves cache-key validation only.

[R] Observation persistence/audit receipts remain future work; Ch7 only records
mandatory emission.

[R] Ch6 still has unrelated invariant metadata doc debt.

---

## Verification

Docs-only slice:

```text
git diff --check -- \
  igniter-lang/docs/spec/ch7-runtime.md \
  igniter-lang/docs/tracks/spec-ch7-gate3-approval-sync-v0.md
```

---

## Handoff

```text
Card: S3-R14-C5-P
Agent: [Igniter-Lang Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: spec-ch7-gate3-approval-sync-v0
Status: done

[D] Decisions
- Ch7 now reflects approved-restricted Gate 3 Phase 1 semantics.
- Phase 1 is implementation-approved but live-read blocked until AT/pre-live
  proofs pass.
- runtime.temporal_scope_exclusion and temporal_read_observation are now in
  Ch7.
- Closed scopes remain explicit.

[S] Shipped / Signals
- Updated docs/spec/ch7-runtime.md.
- Added this track doc.

[T] Tests / Proofs
- Docs-only; git diff --check.

[R] Risks / Recommendations
- Runtime implementation must still prove AT-1..AT-12 before any live read.
- Phase 2 Ledger adapter, BiHistory, stream/OLAP, production cache, and parser
  syntax remain closed.

[Next] Suggested next slice
- runtime-temporal-executor-phase1-preflight-v0, or
  runtime-report-enforcement-preflight-v0.
```

## Files Changed

```text
igniter-lang/docs/spec/ch7-runtime.md
igniter-lang/docs/tracks/spec-ch7-gate3-approval-sync-v0.md
```
