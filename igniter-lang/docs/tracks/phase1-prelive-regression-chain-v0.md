# Track: Phase 1 Pre-live Regression Chain v0

Card: S3-R15-C4-P
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `igniter-lang/phase1-prelive-regression-chain-v0`
Status: done
Date: 2026-05-09

Affected neighbor roles: `[Igniter-Lang Runtime Agent]`,
`[Igniter-Lang Bridge Agent]`, `[Igniter-Lang Compiler/Grammar Expert]`

---

## Goal

Run and index the S3-R7..S3-R10 regression proof chain after S3-R15
integration changes, then extend it with the newer pre-live fixtures now in
the Phase 1 surface.

---

## Decision

[D] The required regression bundle from
`gate3-regression-proof-chain-index-v0` passes 9/9.

[D] The expanded pre-live surface also passes:

- composed CompatibilityReport proof;
- temporal read observation proof;
- temporal scope exclusion proof;
- Phase1TemporalExecutor proof-local preflight;
- S3-R15-amended runtime report enforcement preflight;
- S3-R15 authority-ref exact-match proof.

[D] Wider Stage 1 and Stage 2 close candidates also pass.

[D] Recommendation: **lib-prep is allowed as the next implementation-prep
slice**, assuming S3-R15 C1-C3 are accepted as landed. This does not authorize
live reads, Ledger binding, production cache, BiHistory, stream/OLAP executor,
or Phase 2 behavior.

---

## Base Regression Matrix

| # | Command | Result | Output summary |
|---:|---|---|---|
| 1 | `ruby igniter-lang/experiments/runtime_compatibility_report_temporal_load_check/runtime_compatibility_report_temporal_load_check.rb` | PASS | `PASS runtime_compatibility_report_temporal_load_check`; History/BiHistory load/eval split, claimed executor, approved placeholder, no live operation checks all ok |
| 2 | `ruby igniter-lang/experiments/executor_approval_token_report_proof/executor_approval_token_report_proof.rb` | PASS | `PASS executor_approval_token_report_proof`; token error matrix and valid-token/Gate3-closed checks ok |
| 3 | `ruby igniter-lang/experiments/guarded_runtime_executor_approval_enforcement/guarded_runtime_executor_approval_enforcement.rb` | PASS | `PASS guarded_runtime_executor_approval_enforcement`; missing approval, Gate3 closed, CORE cache-key refusal ok |
| 4 | `ruby igniter-lang/experiments/executor_boundary_cache_key_contract/executor_boundary_cache_key_contract.rb` | PASS | `PASS executor_boundary_cache_key_contract`; CORE key for TEMPORAL refused L-T5; temporal hashes change across time |
| 5 | `ruby igniter-lang/experiments/compatibility_report_package_descriptor_consumption/compatibility_report_package_descriptor_consumption.rb` | PASS | trusted descriptor consumed as report-only metadata; blocked malformed descriptor cases ok; no package binding/ledger/read auth |
| 6 | `ruby igniter-lang/experiments/runtime_smoke_post_switch_full_coverage/runtime_smoke_post_switch_full_coverage.rb` | PASS | `PASS runtime_smoke_post_switch_full_coverage`; CORE, stream, OLAP, History, BiHistory, invariant, report cross-check all ok; uncovered surfaces none |
| 7 | `ruby igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb --check-golden` | PASS | `PASS source_to_semanticir_fixture_golden_check`; SemanticIR/report/AST goldens canonical and deterministic |
| 8 | `ruby igniter-lang/experiments/classifier_pass_proof/classifier_pass_proof.rb --check-golden` | PASS | `PASS classifier_pass_golden_check`; stream and temporal classifier goldens canonical and deterministic |
| 9 | `ruby igniter-lang/experiments/typechecker_proof/typechecker_proof.rb --check-golden` | PASS | `PASS typechecker_golden_check`; stream, temporal, BiHistory, invariant typed goldens canonical and deterministic |

---

## Added Pre-live Surface

| # | Command | Result | Output summary |
|---:|---|---|---|
| 10 | `ruby igniter-lang/experiments/compatibility_report_composition/compatibility_report_composition.rb` | PASS | composed report cases pass; split report rejected; report-only remains non-authority; no live operations |
| 11 | `ruby igniter-lang/experiments/temporal_read_observation_proof/temporal_read_observation_proof.rb` | PASS | selected/none read observations valid; persistence proof-local; no live TBackend eval |
| 12 | `ruby igniter-lang/experiments/temporal_scope_exclusion_runtime_fixture/temporal_scope_exclusion_runtime_fixture.rb` | PASS | CORE/STREAM/OLAP/BiHistory/Ledger/unknown excluded; History valid-time control accepted; no live paths |
| 13 | `ruby igniter-lang/experiments/temporal_executor_phase1_preflight/temporal_executor_phase1_preflight.rb` | PASS | happy path evaluates in proof-local preflight; no token, Gate3 closed, CORE cache, BiHistory, CORE fragment refusals ok; AT-11 shown deferred in fixture summary |
| 14 | `ruby igniter-lang/experiments/runtime_report_enforcement_preflight/runtime_report_enforcement_preflight.rb` | PASS | report preflight order passes; approval missing wins before Gate3 when both blocked; blocked cases perform no executor/cache/TBackend/Ledger/read calls |
| 15 | `ruby igniter-lang/experiments/executor_approval_authority_ref_proof/executor_approval_authority_ref_proof.rb` | PASS | exact Gate 3 decision authority URI accepted; missing/wrong/stale/self-issued authority refs refused before live operations |

---

## Wider Close-Candidate Regression

| Command | Result | Output summary |
|---|---|---|
| `ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb` | PASS | classifier, typechecker, semanticir, stdlib kernel, igapp assembler all PASS |
| `ruby igniter-lang/experiments/stage2_close_candidate/stage2_close_candidate.rb` | PASS | package facade, invariant runtime observations, OLAP, stream, History/BiHistory, Ledger descriptor, Stage 1 regression all PASS |

---

## Recommendation

[R] **Allow `runtime-temporal-executor-lib-prep-v0` to proceed** as a
pre-live/lib-prep slice.

Rationale:

- The S3-R7..S3-R10 chain is green.
- S3-R13/S3-R14/S3-R15 pre-live fixtures are green.
- AT-9 exact authority-ref matching is green at proof-local Phase 1 scope.
- Stage 1 and Stage 2 close candidates are green.
- No proof output authorizes live Ledger, live TBackend, production cache, or
  out-of-scope surfaces.

[R] Keep these guardrails on the next slice:

- lib-prep may move/shape code for the Phase 1 abstract non-Ledger
  History[T] valid_time path only;
- live reads remain blocked until the lib-prep slice proves the same report
  enforcement, token authority comparison, scope, cache-key, and observation
  behavior in the prepared boundary;
- BiHistory, stream, OLAP, Ledger adapter/package binding, production cache,
  writes/replay/compact/subscribe remain excluded.

---

## Non-Authorization

[X] This regression pass does not authorize live temporal reads.

[X] This regression pass does not authorize Ledger adapter binding or package
integration.

[X] This regression pass does not authorize BiHistory, stream, OLAP, writes,
replay, compact, subscribe, or production cache behavior.

---

## Handoff

```text
Card: S3-R15-C4-P
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/phase1-prelive-regression-chain-v0
Status: done

[D] Decisions
- Base Gate 3 regression command bundle passes 9/9.
- Expanded pre-live fixture set passes 6/6.
- Stage 1 and Stage 2 close candidates pass.
- Lib-prep is allowed next, but live reads remain blocked.

[S] Shipped / Signals
- Added this regression chain track with command/result matrix.
- Indexed S3-R13/R14/R15 pre-live fixtures alongside S3-R7..S3-R10 chain.
- Recorded lib-prep recommendation and non-authorization boundaries.

[T] Tests / Proofs
- 17 commands run; 17 PASS.
- No code patches made.

[R] Risks / Recommendations
- Do not treat this as live read authorization.
- Next lib-prep slice must preserve Phase 1 narrow scope and operation-attempt
  false guarantees for all blocked paths.

[Next] Suggested next slice
- runtime-temporal-executor-lib-prep-v0.
```
