# Track: Temporal Runtime Load Guard v0

Card: S3-R5-C2-P
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `igniter-lang/temporal-runtime-load-guard-v0`
Status: done
Date: 2026-05-08

---

## Goal

Specify and prove proof-local RuntimeMachine guard behavior for TEMPORAL
`.igapp/` artifacts without adding production temporal execution, Ledger
binding, or runtime cache.

---

## Decision

[D] Chosen policy:

```text
load_accept_evaluate_refuse
```

RuntimeMachine may load a TEMPORAL `.igapp/` for inspection, descriptor checks,
and CompatibilityReport work, but evaluation of a TEMPORAL contract is blocked
until a future RuntimeMachine temporal executor/adapter slice is approved.

[D] Load is still strict. TEMPORAL load must validate `manifest.contract_index`
against the contract file before returning `loaded`.

[D] Guard ownership:

| Phase | Behavior |
| --- | --- |
| load | validate artifact shape and `manifest.contract_index`; accept only for inspection |
| evaluate | refuse TEMPORAL contracts when runtime support/capabilities are absent |
| cache | disabled; no TEMPORAL or CORE key construction |
| Ledger/TBackend | no production binding |

---

## Machine-Readable Guard Field

Temporal assembled artifacts now carry:

```json
{
  "runtime_execution": {
    "status": "unsupported",
    "guard_policy": "load_accept_evaluate_refuse",
    "guard_at": "evaluate",
    "load": {
      "decision": "accept_for_inspection",
      "requires_contract_index": true
    },
    "evaluate": {
      "decision": "refuse_temporal_contract",
      "reason_code": "runtime.temporal_execution_unsupported"
    }
  }
}
```

This lives in `compatibility_metadata.json`. It is a runtime contract field, not
an execution implementation.

---

## Proof Fixture

Added:

```text
igniter-lang/experiments/temporal_runtime_load_guard/temporal_runtime_load_guard.rb
```

The proof-local `GuardedRuntimeMachine`:

- loads assembled History and BiHistory `.igapp/` artifacts;
- validates `manifest.contract_index` using PROP-022A loader gates;
- accepts valid TEMPORAL artifacts for inspection;
- refuses evaluation when temporal runtime support is absent;
- refuses evaluation when required temporal capability is missing;
- refuses load on missing or malformed `manifest.contract_index`;
- refuses load when a TEMPORAL contract advertises a CORE cache hint.

No production RuntimeMachine, Ledger, TBackend adapter, or cache code is bound.

---

## Negative Cases

| Case | Phase | Result |
| --- | --- | --- |
| unsupported temporal runtime | evaluate | `runtime.temporal_execution_unsupported` |
| missing `history_read` | evaluate | `runtime.temporal_capability_missing` |
| missing `bihistory_read` | evaluate | `runtime.temporal_capability_missing` |
| missing `manifest.contract_index` | load | `load_refusal`, gate `L-T1` |
| malformed `manifest.contract_index` | load | `load_refusal`, gate `L-T1` |
| CORE cache hint for TEMPORAL contract | load | `load_refusal`, gate `L-T5` |

---

## Proof Output

```text
ruby igniter-lang/experiments/temporal_runtime_load_guard/temporal_runtime_load_guard.rb
```

Result:

```text
PASS temporal_runtime_load_guard
history_valid.load_accepts_for_inspection: ok
history_valid.evaluate_refuses_unsupported_runtime: ok
history_valid.evaluate_refuses_missing_capability: ok
bihistory_valid.load_accepts_for_inspection: ok
bihistory_valid.evaluate_refuses_unsupported_runtime: ok
bihistory_valid.evaluate_refuses_missing_capability: ok
missing_contract_index.load_refused: ok
malformed_contract_index.load_refused: ok
core_cache_hint_for_temporal.load_refused: ok
```

Summary:

```text
igniter-lang/experiments/temporal_runtime_load_guard/out/temporal_runtime_load_guard_summary.json
```

---

## Regression

```text
PASS temporal_assembler_boundary
PASS igapp_assembler_proof
PASS production_compiler_cli_proof
PASS source_to_semanticir_fixture_golden_check
PASS temporal_semanticir_access_node --check-golden
PASS stage1_close_candidate
PASS stage2_close_candidate
```

---

## Production Recommendation

[R] Production RuntimeMachine should adopt the same two-phase policy:

1. Load may accept well-formed TEMPORAL artifacts for inspection and
   compatibility reporting.
2. Load must refuse malformed TEMPORAL indexes before CompatibilityReport trust.
3. Evaluate must refuse TEMPORAL contracts unless the machine has an explicit
   temporal runtime executor and the required capabilities
   (`history_read` / `bihistory_read`).
4. Runtime cache must remain disabled until a separate cache implementation
   authorizes TEMPORAL key construction.
5. No Ledger adapter should be selected from this guard alone.

---

## Handoff

```text
Card: S3-R5-C2-P
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/temporal-runtime-load-guard-v0
Status: done

[D] Decisions:
- Chose load_accept_evaluate_refuse.
- Load validates manifest.contract_index; evaluate refuses TEMPORAL execution
  without approved runtime support/capabilities.
- Guard policy is machine-readable in compatibility_metadata.runtime_execution.

[S] Shipped / Signals:
- Added proof-local GuardedRuntimeMachine fixture.
- Proved valid History/BiHistory artifacts load for inspection.
- Proved unsupported runtime, missing capability, missing/malformed
  contract_index, and CORE-cache-hint negative cases.

[T] Tests / Proofs:
- temporal_runtime_load_guard PASS.
- temporal_assembler_boundary, igapp_assembler, production compiler CLI,
  source-to-SemanticIR golden, temporal SemanticIR golden, Stage 1, and Stage 2
  guards all PASS.

[R] Risks / Recommendations:
- This is not production temporal execution.
- Production RuntimeMachine should implement the same guard policy before any
  real temporal adapter binding.

[Next] Suggested next slice:
- Bind a report-only RuntimeMachine compatibility check to the same
  guard_policy and temporal required_caps, still without Ledger execution.
```
