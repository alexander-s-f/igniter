# Track: PROP-030 TEMPORAL Scope Exclusion Errata v0

Card: S3-R13-C2-P
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Track: `prop-030-temporal-scope-exclusion-errata-v0`
Status: done
Date: 2026-05-09

Affected neighbor roles: `[Igniter-Lang Research Agent]`,
`[Igniter-Lang Meta Expert]`, `[Igniter-Lang Bridge Agent]`

---

## Goal

Formalize the canonical refusal reason for out-of-scope temporal artifacts so
Gate 3 AT-7 and AT-12 have a stable runtime code.

---

## Deliverable

[S] Added errata proposal:

```text
docs/proposals/PROP-030A-temporal-scope-exclusion-errata-v0.md
```

---

## Decision

[D] Canonical refusal code:

```text
runtime.temporal_scope_exclusion
```

Meaning:

```text
The artifact reached a TEMPORAL executor path, but its fragment/surface/axis
is outside the currently approved Gate 3 temporal execution scope.
```

For the restricted Gate 3 request, approved scope remains:

```text
History[T] + valid_time + history_read + read_as_of(as_of: DateTime)
```

---

## Reason-Code Matrix

| Incoming artifact/surface | Canonical refusal |
| --- | --- |
| CORE contract reaches `TemporalExecutor` | `runtime.temporal_scope_exclusion` |
| STREAM contract or stream nodes reach `TemporalExecutor` | `runtime.temporal_scope_exclusion` |
| OLAP temporal/multidimensional surface reaches `TemporalExecutor` | `runtime.temporal_scope_exclusion` |
| `BiHistory[T]` / `bihistory_read` / bitemporal axis reaches `TemporalExecutor` | `runtime.temporal_scope_exclusion` |
| Ledger write/replay/compact surface reaches temporal executor path | `runtime.temporal_scope_exclusion` |
| Unknown temporal surface reaches `TemporalExecutor` | `runtime.temporal_scope_exclusion` |

[D] This code does not replace:

- `runtime.executor_approval_*`;
- `runtime.temporal_gate3_closed`;
- `runtime.temporal_capability_missing`;
- `runtime.temporal_cache_schema_mismatch`;
- `runtime.temporal_execution_unsupported`.

---

## Alignment

[S] PROP-030 alignment:

- Adds one runtime refusal code to the existing approval/Gate/cache refusal
  vocabulary.
- Keeps approval-token failures, Gate 3 closed, and cache schema mismatch as
  separate conditions.

[S] AT-7 alignment:

- BiHistory exclusion becomes a named
  `runtime.temporal_scope_exclusion` refusal.

[S] AT-12 alignment:

- CORE artifact reaching `TemporalExecutor` becomes a named
  `runtime.temporal_scope_exclusion` refusal.

[S] Gate 3 request alignment:

- Restricted scope remains History[T] valid_time only.
- STREAM, OLAP, BiHistory, Ledger writes/replay, production cache, parser
  syntax changes, and new SemanticIR node kinds remain unauthorized.

---

## Spec-Lag Notes

[R] Ch7 Runtime should later document `runtime.temporal_scope_exclusion` in the
TEMPORAL evaluate refusal list, but only after Gate 3 approval or Phase 1
implementation authorization.

Required Ch7 sync contents:

- restricted `history_valid_time` scope;
- scope-exclusion matrix;
- distinction from `runtime.temporal_cache_schema_mismatch`;
- no-live-call invariant before cache/TBackend/Ledger/executor evaluation.

[R] Ch6 SemanticIR has no immediate sync requirement because this errata adds no
new node kinds or artifact sections.

---

## Non-Implementation

[D] No parser/runtime implementation was added.

No proof-local fixture was necessary for this slice because the card asks for
formalization. A later Research/Implementation slice can prove the matrix as
executor acceptance if Phase 1 implementation starts.

---

## Handoff

```text
Card: S3-R13-C2-P
Agent: [Igniter-Lang Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: prop-030-temporal-scope-exclusion-errata-v0
Status: done

[D] Decisions
- Canonical refusal code: runtime.temporal_scope_exclusion.
- Applies to CORE/STREAM/OLAP/BiHistory/Ledger write-replay/unknown surfaces
  that reach TemporalExecutor outside the approved History valid_time scope.
- Does not replace approval, Gate 3, capability, or cache-schema refusals.

[S] Shipped / Signals
- Added PROP-030A errata.
- Matrix aligns PROP-030 with Gate 3 request AT-7 and AT-12.

[T] Tests / Proofs
- Docs-only formalization.
- `git diff --check` recommended for changed docs.

[R] Risks / Recommendations
- Ch7 sync after approval/implementation authorization should include this
  refusal code.
- A proof-local fixture can be added before Phase 1 implementation if desired.

[Next] Suggested next slice
- temporal-scope-exclusion-runtime-fixture-v0, or include this matrix in the
  first TemporalExecutor proof after Architect approval.
```

## Files Changed

```text
igniter-lang/docs/proposals/PROP-030A-temporal-scope-exclusion-errata-v0.md
igniter-lang/docs/tracks/prop-030-temporal-scope-exclusion-errata-v0.md
```
