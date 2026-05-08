# Track: Executor Approval Token Report Proof v0

Card: S3-R10-C1-P
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `igniter-lang/executor-approval-token-report-proof-v0`
Status: done
Date: 2026-05-08

Affected neighbor roles: `[Igniter-Lang Compiler/Grammar Expert]`,
`[Igniter-Lang Bridge Agent]`

---

## Goal

Turn PROP-030 `ExecutorApprovalToken` from proposal shape into proof-local
CompatibilityReport coverage.

This is not a Gate 3 authorization. It proves report behavior and refusal
ordering before executor, TBackend, Ledger, or cache access.

---

## Current Horizon

Stage 3 TEMPORAL artifacts can compile and load for inspection. Evaluation
remains closed until an executor, TBackend binding, approval token enforcement,
cache-key boundary, and Gate 3 opening decision all exist together.

PROP-030 defines explicit executor approval as a scoped
`ExecutorApprovalToken`; this slice proves the report matrix for that contract.

---

## Decision

[D] The proof validates a token against loaded `.igapp` manifest evidence:

```text
compiled TEMPORAL .igapp
  -> manifest.contract_index
  -> artifact_ref / contract_ref / required_capabilities
  -> ExecutorApprovalToken validation
  -> CompatibilityReport.executor_approval_check
```

[D] Every failing token case blocks evaluation readiness before live operation.

[D] A valid token is necessary but insufficient. With Gate 3 still closed:

```text
valid token -> executor_approval_check: ok
Gate 3 closed -> evaluation_readiness: blocked(runtime.temporal_gate3_closed)
```

[D] The proof remains report-only:

```json
{
  "report_only": true,
  "runtime_enforced": false,
  "operation_check": {
    "temporal_executor_call_attempted": false,
    "live_tbackend_call_attempted": false,
    "ledger_call_attempted": false,
    "cache_call_attempted": false
  }
}
```

---

## Implemented Proof

Added:

```text
igniter-lang/experiments/executor_approval_token_report_proof/
  executor_approval_token_report_proof.rb
  out/executor_approval_token_report_proof_summary.json
  out/history_single_axis.igapp/
```

The proof compiles the existing History single-axis source into a TEMPORAL
`.igapp`, reads `manifest.contract_index`, and uses that artifact identity as
the token validation target.

---

## Validation Matrix

| Case | Expected reason |
| --- | --- |
| missing token | `runtime.executor_approval_missing` |
| malformed token | `runtime.executor_approval_malformed` |
| invalid token hash | `runtime.executor_approval_signature_invalid` |
| invalid signature | `runtime.executor_approval_signature_invalid` |
| untrusted authority | `runtime.executor_approval_authority_untrusted` |
| expired token | `runtime.executor_approval_expired` |
| revoked token | `runtime.executor_approval_revoked` |
| wrong gate | `runtime.executor_approval_wrong_gate` |
| wrong scope | `runtime.executor_approval_wrong_scope` |
| wrong artifact | `runtime.executor_approval_artifact_mismatch` |
| wrong contract | `runtime.executor_approval_contract_mismatch` |
| wrong capability | `runtime.executor_approval_capability_mismatch` |
| missing evidence | `runtime.executor_approval_evidence_missing` |
| valid token while Gate 3 is closed | `runtime.temporal_gate3_closed` |

The valid-token case also proves `executor_approval_check.decision == "ok"`;
only `evaluation_readiness` is blocked by Gate 3.

---

## Proof Output

Command:

```bash
ruby igniter-lang/experiments/executor_approval_token_report_proof/executor_approval_token_report_proof.rb
```

Observed output:

```text
PASS executor_approval_token_report_proof
missing.reason_code: ok
malformed.reason_code: ok
invalid_hash.reason_code: ok
invalid_signature.reason_code: ok
untrusted_authority.reason_code: ok
expired.reason_code: ok
revoked.reason_code: ok
wrong_gate.reason_code: ok
wrong_scope.reason_code: ok
wrong_artifact.reason_code: ok
wrong_contract.reason_code: ok
wrong_capability.reason_code: ok
missing_evidence.reason_code: ok
valid_token_gate3_closed.reason_code: ok
all_reports_block_before_executor: ok
no_live_operation_attempted: ok
all_reports_remain_report_only: ok
valid_token_approval_ok_but_gate3_closed: ok
summary: igniter-lang/experiments/executor_approval_token_report_proof/out/executor_approval_token_report_proof_summary.json
```

---

## Remaining Gate 3 Gaps

[R] RuntimeMachine must enforce this same approval decision before evaluator,
cache, or TBackend entry.

[R] Gate 3 opening needs a recorded Architect decision defining trusted
authorities and revocation registry.

[R] Production signature verification must replace the proof-local
deterministic `recorded-decision-hash`.

[R] CompatibilityReport persistence and audit receipts are still missing.

[R] The executor cache-key boundary must remain ordered before cache lookup or
TBackend access.

---

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/executor-approval-token-report-proof-v0
Status: done
Neighbors: Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- ExecutorApprovalToken validation is represented as a report-only
  CompatibilityReport dimension.
- Missing/invalid approval blocks before executor, TBackend, Ledger, or cache.
- Valid approval still blocks while Gate 3 is closed.

[R] Recommendations:
- Next runtime slice should bind this report decision to GuardedRuntimeMachine
  enforcement before evaluator/cache/TBackend entry.
- Gate 3 request should include trusted authority, revocation, signature, audit,
  and cache-key ordering evidence.

[S] Signals:
- Added proof-local validation matrix for all PROP-030 runtime refusal cases.
- Summary JSON records operation_check fields proving no live calls attempted.
- Valid-token case distinguishes approval validity from Gate 3 authorization.

[T] Tests / Proofs:
- ruby igniter-lang/experiments/executor_approval_token_report_proof/executor_approval_token_report_proof.rb -> PASS

[Files] Changed:
- igniter-lang/experiments/executor_approval_token_report_proof/executor_approval_token_report_proof.rb
- igniter-lang/experiments/executor_approval_token_report_proof/out/executor_approval_token_report_proof_summary.json
- igniter-lang/experiments/executor_approval_token_report_proof/out/history_single_axis.igapp/
- igniter-lang/docs/tracks/executor-approval-token-report-proof-v0.md

[Q] Open Questions:
- Which authority registry and revocation source owns production token trust?

[X] Rejected:
- No live executor, live TBackend, Ledger binding, production cache, or Gate 3
  opening was introduced.

[Next] Proposed next slice:
- guarded-runtime-executor-approval-enforcement-v0
```
