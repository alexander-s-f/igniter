# Track: PROP-030 Executor Approval Token Contract v0

Card: S3-R9-C2-P
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Track: `PROP-030-executor-approval-token-contract-v0`
Status: done
Date: 2026-05-08

---

## Goal

Formalize executor approval token semantics as a Gate 3 prerequisite without
implementing an executor or authorizing Gate 3.

---

## Inputs

- `docs/agent-context.md`
- `docs/current-status.md`
- `docs/value-index.md`
- `docs/discussions/stage3-round8-pre-gate3-pressure-v0.md`
- `docs/tracks/runtime-compatibility-report-executor-boundary-v0.md`
- `docs/spec/ch7-runtime.md`

---

## Decision

[D] Authored `docs/proposals/PROP-030-executor-approval-token-contract-v0.md`.

[D] Proposal status is `proposal`, not implementation.

[D] "Explicit executor approval" means a dedicated
`ExecutorApprovalToken` backed by a signed or recorded Architect authority
decision.

[D] Approval source ownership:

- `.igapp`: declares approval requirements only.
- runtime config: carries token or token ref only.
- CompatibilityReport: validates and reports token state only.
- recorded Architect decision: authority source.
- `ExecutorApprovalToken`: canonical machine-readable contract.

[D] Gate 3 remains closed. A valid token still refuses when Gate 3 is closed.

---

## Refusal Surface

[S] PROP-030 defines load-time approval requirement refusals:

```text
L-AT1..L-AT3
```

[S] PROP-030 defines runtime approval refusals for:

- missing/malformed token
- invalid signature/hash
- untrusted authority
- expired/revoked token
- wrong gate/scope/artifact/contract/capability
- missing evidence
- Gate 3 closed
- TEMPORAL cache schema mismatch

---

## Proposal Index / Status Sync

[S] Updated `docs/proposals/README.md` so `PROP-030` now names the authored
executor approval token proposal.

[S] Updated `docs/current-status.md` narrowly to show PROP-030 as drafted and
proposal-only.

[S] Hoisted the durable Gate 3 prerequisite rule into `docs/value-index.md`.

---

## Recommended Runtime Proof Slices

[Next] C3:

```text
executor-approval-token-report-proof-v0
```

Extend CompatibilityReport with token validation matrix and prove no executor,
TBackend, or Ledger call is attempted.

[Next] C4:

```text
guarded-runtime-executor-approval-enforcement-v0
```

Prove GuardedRuntimeMachine enforces the same decision as CompatibilityReport,
refuses valid-token/Gate-3-closed, and rejects CORE-shaped cache keys for
TEMPORAL executor boundary simulation.

---

## Non-Goals

[X] No executor implementation.

[X] No Gate 3 authorization.

[X] No live Ledger/TBackend operation.

[X] No parser change.

[X] No broad round-close map authored.

---

## Verification

Docs/proposal-only checks:

```text
rg "PROP-030|ExecutorApprovalToken|executor_approval|Gate 3|C3|C4" docs/proposals/PROP-030-executor-approval-token-contract-v0.md docs/proposals/README.md docs/current-status.md docs/value-index.md docs/tracks/prop-030-executor-approval-token-contract-v0.md
git diff --check -- docs/proposals/PROP-030-executor-approval-token-contract-v0.md docs/proposals/README.md docs/current-status.md docs/value-index.md docs/tracks/prop-030-executor-approval-token-contract-v0.md
```

---

## Handoff

```text
Card: S3-R9-C2-P
Agent: [Igniter-Lang Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: PROP-030-executor-approval-token-contract-v0
Status: done

[D] Decisions:
- PROP-030 drafted with status proposal.
- Explicit executor approval is a dedicated ExecutorApprovalToken backed by a
  recorded/signed Architect authority decision.
- .igapp declares requirements; runtime config carries token refs;
  CompatibilityReport validates/reports; RuntimeMachine must enforce later.
- Gate 3 remains closed even with a valid token.

[S] Shipped / Signals:
- New proposal under docs/proposals/.
- Track doc records the decision and non-goals.
- Proposal index/current-status now assign PROP-030 to executor approval token.
- value-index hoists the Gate 3 prerequisite rule.

[T] Tests / Proofs:
- Docs-only; no code proof required.

[R] Risks / Recommendations:
- Gate 3 request must include token enforcement, report/runtime consistency,
  and TEMPORAL cache-key executor-boundary proof before any live executor work.

[Next] Suggested next slices:
- executor-approval-token-report-proof-v0
- guarded-runtime-executor-approval-enforcement-v0
```

## Files Changed

```text
igniter-lang/docs/proposals/PROP-030-executor-approval-token-contract-v0.md
igniter-lang/docs/proposals/README.md
igniter-lang/docs/current-status.md
igniter-lang/docs/value-index.md
igniter-lang/docs/tracks/prop-030-executor-approval-token-contract-v0.md
```
