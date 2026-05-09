# Track: Gate 3 Acceptance Condition Matrix v0

Card: S3-R11-C2-P
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `igniter-lang/gate3-acceptance-condition-matrix-v0`
Status: done
Date: 2026-05-09

Affected neighbor roles: `[Igniter-Lang Compiler/Grammar Expert]`,
`[Igniter-Lang Bridge Agent]`

---

## Goal

Extract a precise acceptance matrix for a future Gate 3 request from landed
proof evidence.

This track does not open Gate 3, add an executor proof, or authorize any live
Ledger/TBackend operation.

---

## Current Horizon

Gate 3 prerequisites now exist as a coherent proof package:

```text
full smoke
  -> CompatibilityReport load/eval split
  -> executor profile refusal
  -> PROP-030 token matrix
  -> GuardedRuntimeMachine approval enforcement
  -> executor cache-key proof
  -> descriptor report-only consumption
```

The package is sufficient to formulate a Gate 3 request. It is not sufficient
to execute TEMPORAL contracts in production.

No hard contradiction was found across the evidence set.

---

## Acceptance Matrix

| Gate 3 acceptance condition | Proof exists | Production implementation required | Excluded / live closed | Evidence |
| --- | --- | --- | --- | --- |
| All current compiler/runtime surfaces remain smoke-covered | Yes: all six `emit_typed` surfaces compile/load/evaluate or structurally refuse as appropriate | Production smoke harness should keep the same surfaces as regression coverage | TEMPORAL evaluation still refused; stream/OLAP/invariant runtime remains proof-local where noted | `runtime-smoke-post-switch-full-coverage-v0` |
| TEMPORAL `.igapp` can load for inspection while evaluation is separately blocked | Yes: `bundle_load.accept_for_inspection`; `evaluation_readiness.blocked` | RuntimeMachine must own the same load/eval split in production reports | No temporal executor, live TBackend, Ledger, or production cache | `runtime-compatibility-report-temporal-load-check-v0` |
| Missing TBackend capability blocks evaluation, not bundle load | Yes: report consumes manifest fragment summary, contract index, guard policy, and capabilities | Production CompatibilityReport must preserve this distinction | No adapter selection or live capability negotiation | `runtime-compatibility-report-temporal-load-check-v0` |
| Positive executor/live-binding flags are insufficient | Yes: claimed executor + live binding still blocked without explicit approval | Runtime profile/config must not become authority by itself | No executor call, no TBackend call, no Ledger call | `runtime-compatibility-report-executor-boundary-v0` |
| Valid approval placeholder still refuses when Gate 3 is closed | Yes: approved placeholder reports `runtime.temporal_gate3_closed` | Gate 3 state must have production authority source independent of token shape | Gate 3 remains closed | `runtime-compatibility-report-executor-boundary-v0` |
| `ExecutorApprovalToken` validation matrix exists | Yes: missing/malformed/signature/authority/expiry/revocation/scope/artifact/contract/capability/evidence cases covered | Production token validator, authority registry, revocation registry, signature verification | Proof-local deterministic `recorded-decision-hash`; no production authority | `executor-approval-token-report-proof-v0`, PROP-030 |
| Valid token is necessary but insufficient | Yes: valid token gives approval check `ok`, then evaluation blocks with `runtime.temporal_gate3_closed` | RuntimeMachine must enforce Gate 3 independently from token validity | Valid token does not authorize execution | `executor-approval-token-report-proof-v0` |
| Guarded runtime enforces approval-aware refusal order | Yes: missing token, Gate 3 closed, and bad cache key refused before live paths | Production RuntimeMachine must bind the same order before evaluator/cache/TBackend entry | GuardedRuntimeMachine remains proof-local | `guarded-runtime-executor-approval-enforcement-v0` |
| TEMPORAL cache keys must include temporal coordinates | Yes: History/BiHistory require TEMPORAL-shaped key; CORE-shaped key refused with L-T5-style fault | Production executor/cache boundary must construct and validate keys before cache lookup | No production cache or memoization authorized | `executor-boundary-cache-key-contract-v0`, PROP-028 |
| Descriptor metadata can be trusted as report-only backend evidence | Yes: Gate 2 ratified descriptor metadata consumed into `backend_check.temporal_backend_descriptor` | Production CompatibilityReport composition must ingest descriptor metadata without granting runtime authority | No package binding, live adapter, Ledger call, temporal read, replay, or Gate 3 | `descriptor-gate2-architect-ratification-record-v0`, `compatibility-report-package-descriptor-consumption-v0` |
| Descriptor capability does not prove physical BiHistory serving | Yes: BiHistory warning preserved in package descriptor report | Gate 3 request must include separate physical-serving proof or explicitly defer it | Descriptor claim remains metadata only | `compatibility-report-package-descriptor-consumption-v0` |
| All refusal reports prove no live operation attempted | Yes across report and guarded-runtime proofs | Production enforcement must preserve no-call-before-refusal invariant | Ledger/TBackend/executor/cache calls remain false in proof outputs | `runtime-compatibility-report-executor-boundary-v0`, `executor-approval-token-report-proof-v0`, `guarded-runtime-executor-approval-enforcement-v0` |

---

## Missing Production Items

These are required before Gate 3 can be safely requested as production
execution authority:

| Missing item | Why it matters | Current status |
| --- | --- | --- |
| Production RuntimeMachine binding | Proof-local guards must become actual RuntimeMachine preflight checks | Required |
| Authority registry / revocation registry | Tokens need trusted issuers and revocation lookup | Required |
| Production signature verification | Proof-local deterministic hash is not production security | Required |
| CompatibilityReport persistence / audit receipts | Gate 3 decisions need durable audit evidence | Required |
| Unified CompatibilityReport composition | Current evidence lives in separate proof reports; Gate 3 needs one composed report shape | Required |
| Physical TBackend serving proof | Descriptor metadata does not prove actual History/BiHistory reads | Required unless explicitly excluded from first Gate 3 |
| Runtime cache enforcement | TEMPORAL key proof must be bound before production cache lookup | Required before cache enablement |

---

## Excluded From Gate 3 Acceptance Evidence

[X] Live Ledger read/write/replay.

[X] Live TBackend adapter binding.

[X] Production TEMPORAL executor.

[X] Production RuntimeMachine cache or memoization.

[X] Treating descriptor metadata as runtime authority.

[X] Treating `ExecutorApprovalToken` validity as Gate 3 authorization by itself.

---

## Request-Ready Gate 3 Checklist

A Gate 3 request can reference this matrix when it supplies the missing
production bindings:

1. Production RuntimeMachine preflight check consumes composed
   CompatibilityReport dimensions.
2. RuntimeMachine refuses before evaluator/cache/TBackend/Ledger on any failed
   approval, capability, gate, guard-policy, or cache-key check.
3. Token authority registry, revocation registry, and signature verification are
   concrete.
4. Gate 3 authority source is recorded separately from token validity.
5. Descriptor metadata remains report-only until a live adapter proof is named.
6. TEMPORAL cache-key schema is enforced before any cache read/write.
7. Audit/persistence path records the report, authority evidence, and refusal or
   execution decision.

---

## Verification

Docs-only slice:

```text
git diff --check -- igniter-lang/docs/tracks/gate3-acceptance-condition-matrix-v0.md
```

No new executor proof was added because the landed evidence is internally
consistent.

---

## Handoff

```text
Card: S3-R11-C2-P
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/gate3-acceptance-condition-matrix-v0
Status: done

[D] Decisions
- Gate 3 has a coherent prerequisite evidence package.
- Existing proofs are sufficient for a Gate 3 request matrix, not production
  execution authority.
- No live operations are opened by this matrix.

[S] Shipped / Signals
- Added proof/production/excluded acceptance matrix.
- Separated report-only evidence from missing production items.
- Marked descriptor metadata and token validity as prerequisites, not authority.

[T] Tests / Proofs
- Docs-only; no new executor proof added.
- git diff --check on this track doc -> PASS.

[R] Risks / Recommendations
- Gate 3 request should not proceed without production RuntimeMachine binding,
  authority/revocation/signature implementation, report persistence/audit, and
  unified CompatibilityReport composition.

[Next] Suggested next slice
- runtime-report-enforcement-preflight-v0, or
  executor-approval-authority-registry-v0.
```
