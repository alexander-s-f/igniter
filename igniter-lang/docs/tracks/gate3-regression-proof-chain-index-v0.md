# Track: Gate 3 Regression Proof-Chain Index v0

Card: S3-R12-C3-P
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `igniter-lang/gate3-regression-proof-chain-index-v0`
Status: done
Date: 2026-05-09

Affected neighbor roles: `[Igniter-Lang Compiler/Grammar Expert]`,
`[Igniter-Lang Bridge Agent]`

---

## Goal

Create a compact Gate 3 regression proof-chain index for implementation
readiness.

This is an index, not a new executor proof. Gate 3 remains closed.

---

## Current Horizon

The Gate 3 opening request is drafted but held for revision. The prerequisite
proof package has landed, but production implementation is still required for
RuntimeMachine binding, authority/revocation/signature handling, audit
persistence, unified report composition, and any live TBackend/Ledger work.

No named proof in the requested chain is missing.

---

## Regression Proof Chain

| Chain item | Command | Expected | Risk covered | Boundary |
| --- | --- | --- | --- | --- |
| TEMPORAL load/eval split | `ruby igniter-lang/experiments/runtime_compatibility_report_temporal_load_check/runtime_compatibility_report_temporal_load_check.rb` | `PASS runtime_compatibility_report_temporal_load_check` | Prevents load-for-inspection from becoming evaluation authority; preserves missing-capability blocks-evaluation-not-load behavior | Report-only / proof-local |
| Executor boundary refusal | `ruby igniter-lang/experiments/runtime_compatibility_report_temporal_load_check/runtime_compatibility_report_temporal_load_check.rb` | Checks include `claimed_executor_still_needs_approval`, `approved_placeholder_still_blocks_gate3_closed`, `no_profile_attempts_live_operation` | Prevents positive executor/live-binding flags from bypassing approval, Gate 3, or guard policy | Report-only |
| PROP-030 approval token report matrix | `ruby igniter-lang/experiments/executor_approval_token_report_proof/executor_approval_token_report_proof.rb` | `PASS executor_approval_token_report_proof` | Covers missing/malformed/bad signature/untrusted/expired/revoked/wrong scope-artifact-contract-capability/missing evidence, and valid-token + Gate3-closed refusal | Report-only / proof-local validation |
| Guarded runtime approval enforcement | `ruby igniter-lang/experiments/guarded_runtime_executor_approval_enforcement/guarded_runtime_executor_approval_enforcement.rb` | `PASS guarded_runtime_executor_approval_enforcement` | Prevents report/runtime mismatch; proves missing token, Gate3 closed, and bad TEMPORAL cache key refuse before live paths | Proof-local runtime guard |
| Executor cache-key contract | `ruby igniter-lang/experiments/executor_boundary_cache_key_contract/executor_boundary_cache_key_contract.rb` | `PASS executor_boundary_cache_key_contract` | Prevents silent temporal staleness by refusing CORE-shaped keys for TEMPORAL contracts | Proof-local executor/cache boundary |
| Package descriptor report-only consumption | `ruby igniter-lang/experiments/compatibility_report_package_descriptor_consumption/compatibility_report_package_descriptor_consumption.rb` | `PASS trusted package descriptor is trusted_metadata` and all blocked cases PASS | Prevents Gate 2 descriptor metadata from becoming runtime authority; preserves no package binding/Ledger/temporal reads | Report-only bridge evidence |
| Full six-surface smoke | `ruby igniter-lang/experiments/runtime_smoke_post_switch_full_coverage/runtime_smoke_post_switch_full_coverage.rb` | `PASS runtime_smoke_post_switch_full_coverage` | Protects CORE Add, stream fold, OLAPPoint, History, BiHistory, and invariant severity surfaces after typed emission switch | Mixed: CORE evaluates, TEMPORAL refuses, stream/OLAP/invariant proof-local |
| Stream replay metadata | `ruby igniter-lang/experiments/runtime_smoke_post_switch_full_coverage/runtime_smoke_post_switch_full_coverage.rb` | Summary reports assembled stream replay metadata; stream fold evaluates from `stream_nodes` | Prevents hidden fixture defaults for bounded replay metadata | Proof-local finite replay; no production stream executor |
| Stream compiler metadata regression | `ruby igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb --check-golden` | PASS | Protects emitted STREAM metadata shape used by full smoke | Compiler proof; no live stream ingress |
| Stream classifier/typechecker metadata regression | `ruby igniter-lang/experiments/classifier_pass_proof/classifier_pass_proof.rb --check-golden` and `ruby igniter-lang/experiments/typechecker_proof/typechecker_proof.rb --check-golden` | PASS | Protects parser/classifier/typechecker preservation of stream replay metadata | Compiler proof; no runtime execution authority |

---

## Recommended Command Bundle

Run sequentially. Do not run the C2/report writers concurrently because several
proofs refresh nearby summary files.

```bash
ruby igniter-lang/experiments/runtime_compatibility_report_temporal_load_check/runtime_compatibility_report_temporal_load_check.rb
ruby igniter-lang/experiments/executor_approval_token_report_proof/executor_approval_token_report_proof.rb
ruby igniter-lang/experiments/guarded_runtime_executor_approval_enforcement/guarded_runtime_executor_approval_enforcement.rb
ruby igniter-lang/experiments/executor_boundary_cache_key_contract/executor_boundary_cache_key_contract.rb
ruby igniter-lang/experiments/compatibility_report_package_descriptor_consumption/compatibility_report_package_descriptor_consumption.rb
ruby igniter-lang/experiments/runtime_smoke_post_switch_full_coverage/runtime_smoke_post_switch_full_coverage.rb
ruby igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb --check-golden
ruby igniter-lang/experiments/classifier_pass_proof/classifier_pass_proof.rb --check-golden
ruby igniter-lang/experiments/typechecker_proof/typechecker_proof.rb --check-golden
```

Optional wider regression after implementation changes:

```bash
ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb
ruby igniter-lang/experiments/stage2_close_candidate/stage2_close_candidate.rb
```

---

## Proof-Local vs Production-Required

| Surface | Proof-local confidence | Production-required delta |
| --- | --- | --- |
| CompatibilityReport load/eval split | Report shape and refusal reasons are proven | RuntimeMachine must emit/consume composed production report |
| Executor approval | Token matrix and guarded refusal are proven | Authority registry, revocation registry, signature verification, and Gate 3 authority source |
| Runtime guard | GuardedRuntimeMachine proves refusal order | Production RuntimeMachine preflight binding before evaluator/cache/TBackend |
| Cache key | TEMPORAL key shape and CORE-shaped refusal are proven | Production executor/cache boundary enforcement before cache read/write |
| Descriptor metadata | Gate 2 report-only descriptor metadata is trusted | Live adapter binding and physical History/BiHistory serving proof |
| Stream replay | Assembled replay metadata drives finite proof-local replay | Production stream executor, live ingress, ordering, durable replay |
| Full smoke | Six surfaces covered | Production coverage harness and live TEMPORAL executor only after Gate 3 |

---

## Non-Authorization

[X] This index does not open Gate 3.

[X] This index does not authorize live Ledger read/write/replay.

[X] This index does not authorize live TBackend binding.

[X] This index does not authorize production TEMPORAL execution or cache.

[X] This index does not treat descriptor metadata or token validity as runtime
authority.

---

## Verification

Docs-only slice:

```text
git diff --check -- igniter-lang/docs/tracks/gate3-regression-proof-chain-index-v0.md
```

Path existence was checked for all indexed proof scripts.

---

## Handoff

```text
Card: S3-R12-C3-P
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/gate3-regression-proof-chain-index-v0
Status: done

[D] Decisions
- No named proof is missing; no new proof added.
- The Gate 3 regression chain should run sequentially.
- Proof-local confidence and production-required deltas are separated.

[S] Shipped / Signals
- Added compact proof-chain index.
- Added recommended command bundle for future Implementation Agent.
- Marked each proof's covered risk and boundary status.

[T] Tests / Proofs
- Docs-only; no proof suite run.
- git diff --check on this track doc -> PASS.
- Indexed proof script paths checked.

[R] Risks / Recommendations
- Future implementation work should run the bundle after touching
  RuntimeMachine, CompatibilityReport, token validation, descriptor consumption,
  cache-key enforcement, or stream metadata.
- Stage 1/Stage 2 close candidates are optional wider regressions after
  implementation changes.

[Next] Suggested next slice
- runtime-report-enforcement-preflight-v0, or
  compatibility-report-composition-shape-v0.
```
