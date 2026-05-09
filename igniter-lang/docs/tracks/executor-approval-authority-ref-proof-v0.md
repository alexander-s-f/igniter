# Track: Executor Approval Authority Ref Proof v0

Card: S3-R15-C3-P
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `igniter-lang/executor-approval-authority-ref-proof-v0`
Status: done
Date: 2026-05-09

Affected neighbor roles: `[Igniter-Lang Compiler/Grammar Expert]`,
`[Igniter-Lang Bridge Agent]`

---

## Goal

Close the AT-9 Phase 1 proof gap by proving
`ExecutorApprovalToken.authority_ref` exact-match validation against the Gate 3
decision URI.

This is proof-local only. It does not implement a production signing system or
runtime authority registry.

---

## Source Authority

Read from:

```text
igniter-lang/docs/gates/gate3-decision-record-v0.md
```

Trusted Phase 1 authority ref:

```text
architect-supervisor://igniter-lang/gates/gate3/runtime-temporal-executor/restricted-history-valid-time-v0/2026-05-09
```

The proof parses this URI from the decision record instead of duplicating a
nearby hand-written value.

---

## Decision

[D] Phase 1 proof-local validation accepts only exact string equality with the
Gate 3 decision authority URI.

[D] Missing `authority_ref` is malformed:

```text
runtime.executor_approval_malformed
```

[D] Wrong, stale/superseded, or self-issued authority refs are untrusted:

```text
runtime.executor_approval_authority_untrusted
```

[D] `.igapp`, contract, RuntimeMachine, and TBackend identifiers cannot
self-issue authority.

---

## Implemented Proof

Added:

```text
igniter-lang/experiments/executor_approval_authority_ref_proof/
  executor_approval_authority_ref_proof.rb
  out/executor_approval_authority_ref_proof_summary.json
```

Proof cases:

| Case | Expected result |
| --- | --- |
| exact `authority_ref` from decision record | accepted |
| missing `authority_ref` | refused: `runtime.executor_approval_malformed` |
| wrong `authority_ref` | refused: `runtime.executor_approval_authority_untrusted` |
| stale/superseded modeled URI | refused: `runtime.executor_approval_authority_untrusted` |
| self-issued artifact authority | refused: `runtime.executor_approval_authority_untrusted` |

All refusal cases prove no executor, cache, TBackend, Ledger, or live adapter
call is attempted.

---

## Proof Output

Command:

```bash
ruby igniter-lang/experiments/executor_approval_authority_ref_proof/executor_approval_authority_ref_proof.rb
```

Observed output:

```text
PASS executor_approval_authority_ref_proof
exact_match.accepted: ok
exact_match.uses_decision_record_authority: ok
missing_authority_ref.refused: ok
wrong_authority_ref.refused: ok
stale_superseded_authority_ref.refused: ok
self_issued_artifact_authority_ref.refused: ok
refusals_before_live_operations: ok
authority_ref: architect-supervisor://igniter-lang/gates/gate3/runtime-temporal-executor/restricted-history-valid-time-v0/2026-05-09
summary: igniter-lang/experiments/executor_approval_authority_ref_proof/out/executor_approval_authority_ref_proof_summary.json
```

Syntax check:

```text
ruby -c igniter-lang/experiments/executor_approval_authority_ref_proof/executor_approval_authority_ref_proof.rb -> Syntax OK
```

---

## AT-9 Status Recommendation

[R] Mark AT-9 as:

```text
proof-local PASS for Phase 1 exact authority_ref matching
```

Reason:

```text
The proof accepts only the authority URI recorded in the Gate 3 decision
record and refuses missing, wrong, stale/superseded, or self-issued authority
refs before live operations.
```

Keep these as separate gaps:

- production signing/key verification;
- runtime authority registry;
- revocation lookup beyond proof-local modeled stale/superseded refs;
- Phase 2 production authority and Ledger adapter authority.

---

## Non-Authorization

[X] No production signing system.

[X] No runtime authority registry.

[X] No live TBackend.

[X] No Ledger adapter.

[X] No production cache.

[X] No Phase 2 authority.

---

## Handoff

```text
Card: S3-R15-C3-P
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/executor-approval-authority-ref-proof-v0
Status: done

[D] Decisions
- Phase 1 authority_ref validation is exact-match against the Gate 3 decision
  URI.
- Missing authority_ref is malformed.
- Wrong, stale/superseded, and self-issued authority refs are untrusted.

[S] Shipped / Signals
- Added executor_approval_authority_ref_proof experiment and summary JSON.
- Parsed the trusted authority URI from the decision record.
- Proved all refusals happen before executor/cache/TBackend/Ledger/live adapter.

[T] Tests / Proofs
- ruby -c executor_approval_authority_ref_proof.rb -> Syntax OK
- ruby executor_approval_authority_ref_proof.rb -> PASS

[R] Risks / Recommendations
- Mark AT-9 proof-local PASS for Phase 1 exact matching.
- Production signing, authority registry, and revocation lookup remain separate
  gaps before Phase 2 / production authority.

[Next] Suggested next slice
- runtime-temporal-executor-phase1-preflight-v0, or
  gate3-authority-registry-v0.
```
