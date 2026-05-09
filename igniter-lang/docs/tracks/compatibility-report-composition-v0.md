# Track: CompatibilityReport Composition v0

Card: S3-R13-C4-P
Agent: `[Igniter-Lang Bridge Agent]`
Role: `bridge-agent`
Track: `compatibility-report-composition-v0`
Status: done
Date: 2026-05-09

Affected neighbor roles: `[Igniter-Lang Research Agent]`,
`[Igniter-Lang Compiler/Grammar Expert]`

---

## Purpose

Specify and prove that Gate 3 readiness is represented by **one composed
CompatibilityReport**, not split report/enforcement fragments.

This closes the shape referenced by the Gate 3 request acceptance condition:

```text
CompatibilityReport is composed as a single production report, not as two
separate report-only and enforcement objects.
```

No Ledger adapter binding, live TBackend call, cache call, or temporal read is
performed by this track.

---

## Composition Claim

[D] A Gate 3 readiness report must compose all readiness dimensions in one
artifact:

```text
package descriptor backend_check
  + runtime gate state
  + ExecutorApprovalToken state
  + executor readiness
  + TEMPORAL cache-key readiness
  -> one CompatibilityReport.evaluation_readiness
```

`runtime_enforced: true` is valid only on that single composed report, and only
when every required dimension is ready.

`report_only: true` remains valid for pre-Gate-3 analysis, even if all metadata
checks are otherwise satisfied.

---

## Implemented Proof

Added proof-local fixture:

```text
igniter-lang/experiments/compatibility_report_composition/
  compatibility_report_composition.rb
  compatibility_report_composition_summary.json
```

The fixture composes:

- package descriptor `backend_check.temporal_backend_descriptor`;
- `runtime_gate_check`;
- `executor_approval_check`;
- `executor_readiness`;
- `cache_key_check`;
- `composition_diagnostics`;
- `evaluation_readiness`;
- `operation_check`.

The proof remains local and non-operational:

```json
{
  "live_ledger_binding": false,
  "live_tbackend_call": false,
  "temporal_read": false,
  "proof_local_only": true
}
```

---

## Composition Shape

Canonical shape:

```json
{
  "kind": "compatibility_report",
  "format_version": "0.1.0",
  "composition": {
    "mode": "single_report",
    "single_report_required": true,
    "split_fragments_allowed": false
  },
  "artifact_ref": "igapp/sha256:<artifact>",
  "contract_ref": "contract/<name>/sha256:<contract>",
  "fragment_class": "TEMPORAL",
  "report_only": true,
  "runtime_enforced": false,
  "schema_check": {
    "decision": "not_evaluated_here",
    "independent_from_backend_descriptor": true
  },
  "backend_check": {
    "decision": "trusted_metadata",
    "temporal_backend_descriptor": {
      "source": "ratified_package_descriptor_metadata",
      "descriptor_hash": "sha256:<descriptor>",
      "descriptor_registry_hash": "sha256:<registry>",
      "capabilities": ["history_read"],
      "history_axes": ["valid_time"],
      "cursor_policy": {}
    }
  },
  "runtime_gate_check": {
    "gate": "tbackend_gate3",
    "decision": "closed"
  },
  "executor_approval_check": {
    "decision": "ok",
    "token_ref": "approval/<id>"
  },
  "executor_readiness": {
    "decision": "ok",
    "executor_kind": "proof_local_memory_tbackend"
  },
  "cache_key_check": {
    "decision": "ok",
    "fragment": "TEMPORAL",
    "required_coordinates": ["valid_time"]
  },
  "composition_diagnostics": {
    "status": "ok",
    "problems": []
  },
  "evaluation_readiness": {
    "decision": "blocked",
    "reason_code": "runtime.temporal_gate3_closed",
    "blocks_before_executor": true
  },
  "operation_check": {
    "temporal_executor_call_attempted": false,
    "live_tbackend_call_attempted": false,
    "ledger_call_attempted": false,
    "temporal_read_attempted": false,
    "cache_call_attempted": false
  }
}
```

Post-approval readiness shape is the same report with:

```json
{
  "report_only": false,
  "runtime_enforced": true,
  "evaluation_readiness": {
    "decision": "ready",
    "reason_code": "runtime.temporal_evaluation_ready",
    "blocks_before_executor": false
  }
}
```

That shape is proof-local here. It does not open Gate 3.

---

## Acceptance Matrix

| Case | Expected result | Signal |
|---|---|---|
| `report_only_gate3_closed` | blocked, `report_only: true`, `runtime_enforced: false` | Gate 3 closed blocks before executor |
| `runtime_enforced_ready` | ready, `report_only: false`, `runtime_enforced: true` | Only one composed report can become enforcement-ready |
| `split_report_rejected` | blocked | split report/enforcement fragments rejected |
| `descriptor_blocked` | blocked | backend descriptor metadata must be trusted |
| `approval_missing` | blocked | approval token is required |
| `executor_missing` | blocked | executor readiness is required |
| `cache_key_blocked` | blocked | TEMPORAL cache key is required |
| `report_only_all_checks_ok` | report-only ready, not runtime authority | report-only cannot silently become enforcement |

Every case preserves:

```json
{
  "temporal_executor_call_attempted": false,
  "live_tbackend_call_attempted": false,
  "ledger_call_attempted": false,
  "temporal_read_attempted": false,
  "cache_call_attempted": false
}
```

---

## Proof Results

Command:

```bash
ruby igniter-lang/experiments/compatibility_report_composition/compatibility_report_composition.rb
```

Observed result:

```text
PASS gate3 closed report remains report-only and blocked
PASS runtime_enforced ready only on one composed report
PASS split report is rejected
PASS descriptor_blocked blocks before executor
PASS approval_missing blocks before executor
PASS executor_missing blocks before executor
PASS cache_key_blocked blocks before executor
PASS report-only all checks ok does not become runtime authority
PASS no case performs live operations
PASS summary written igniter-lang/experiments/compatibility_report_composition/compatibility_report_composition_summary.json
```

Syntax check:

```text
ruby -c igniter-lang/experiments/compatibility_report_composition/compatibility_report_composition.rb
-> Syntax OK
```

---

## Non-Authorization

This track does not authorize:

- Gate 3 opening;
- live Ledger adapter binding;
- live TBackend call;
- temporal read;
- cache lookup;
- RuntimeMachine production execution;
- package edits.

It only defines and proves the composed report shape.

---

## Handoff

```text
Card: S3-R13-C4-P
Agent: [Igniter-Lang Bridge Agent]
Role: bridge-agent
Track: compatibility-report-composition-v0
Status: done

[D] Decisions
- Gate 3 readiness must be represented by one composed CompatibilityReport.
- Split report/enforcement fragments are rejected.
- runtime_enforced:true is valid only on the single composed report when all
  readiness dimensions are ready.

[S] Signals
- Descriptor backend_check, gate state, approval token, executor readiness, and
  cache-key readiness compose into evaluation_readiness.
- report_only all-checks-ok is not runtime authority.
- No live operations are attempted in the proof.

[T] Tests / Proofs
- ruby igniter-lang/experiments/compatibility_report_composition/compatibility_report_composition.rb -> PASS
- ruby -c igniter-lang/experiments/compatibility_report_composition/compatibility_report_composition.rb -> Syntax OK

[R] Risks / Recommendations
- Production implementation must not create separate report-only and
  enforcement fragments.
- RuntimeMachine should consume evaluation_readiness from the composed report
  before executor/cache/TBackend entry.

[Next] Suggested next slice
- Use this shape in runtime-report-enforcement-preflight-v0 after Architect
  approval.
```
