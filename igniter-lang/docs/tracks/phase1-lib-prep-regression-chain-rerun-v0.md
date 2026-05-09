# Track: Phase 1 Lib Prep Regression Chain Rerun v0

Card: S3-R17-C1-P
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `igniter-lang/phase1-lib-prep-regression-chain-rerun-v0`
Status: done
Date: 2026-05-09

Affected neighbor roles: `[Igniter-Lang Compiler/Grammar Expert]`,
`[Igniter-Lang Bridge Agent]`

---

## Goal

Rerun the Phase 1 lib-prep regression chain against the landed S3-R16-C1 lib
boundary.

---

## C1 Evidence

S3-R16-C1 landed:

```text
igniter-lang/lib/igniter_lang/temporal_executor.rb
igniter-lang/experiments/temporal_executor_lib_prep/temporal_executor_lib_prep.rb
```

Current lib boundary:

```text
IgniterLang::TemporalExecutor::Phase1
guard order: approval_token -> gate_state -> scope -> cache_key -> kernel
default: gate3_authorized: false
live reads: still blocked unless a future decision addendum explicitly opens them
```

---

## Regression Matrix

All commands were run sequentially.

| Group | Command | Result |
| --- | --- | --- |
| S3-R7/R8 load/eval + executor report | `ruby igniter-lang/experiments/runtime_compatibility_report_temporal_load_check/runtime_compatibility_report_temporal_load_check.rb` | PASS |
| S3-R9 cache-key boundary | `ruby igniter-lang/experiments/executor_boundary_cache_key_contract/executor_boundary_cache_key_contract.rb` | PASS |
| S3-R10 approval-token report matrix | `ruby igniter-lang/experiments/executor_approval_token_report_proof/executor_approval_token_report_proof.rb` | PASS |
| S3-R10 guarded approval enforcement | `ruby igniter-lang/experiments/guarded_runtime_executor_approval_enforcement/guarded_runtime_executor_approval_enforcement.rb` | PASS |
| S3-R10 descriptor consumption | `ruby igniter-lang/experiments/compatibility_report_package_descriptor_consumption/compatibility_report_package_descriptor_consumption.rb` | PASS |
| S3-R8/S3-R9 smoke + stream metadata | `ruby igniter-lang/experiments/runtime_smoke_post_switch_full_coverage/runtime_smoke_post_switch_full_coverage.rb` | PASS |
| S3-R13 CompatibilityReport composition | `ruby igniter-lang/experiments/compatibility_report_composition/compatibility_report_composition.rb` | PASS |
| S3-R13 temporal read observation | `ruby igniter-lang/experiments/temporal_read_observation_proof/temporal_read_observation_proof.rb` | PASS |
| S3-R14 runtime report enforcement preflight | `ruby igniter-lang/experiments/runtime_report_enforcement_preflight/runtime_report_enforcement_preflight.rb` | PASS |
| S3-R14 temporal scope exclusion | `ruby igniter-lang/experiments/temporal_scope_exclusion_runtime_fixture/temporal_scope_exclusion_runtime_fixture.rb` | PASS |
| S3-R15 authority ref proof | `ruby igniter-lang/experiments/executor_approval_authority_ref_proof/executor_approval_authority_ref_proof.rb` | PASS |
| S3-R16 C1 targeted proof | `ruby igniter-lang/experiments/temporal_executor_lib_prep/temporal_executor_lib_prep.rb` | PASS |
| Stage 1 close candidate | `ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb` | PASS |
| Stage 2 close candidate | `ruby igniter-lang/experiments/stage2_close_candidate/stage2_close_candidate.rb` | PASS |

Total:

```text
14/14 PASS
```

---

## Exact PASS Signals

Key output snippets:

```text
PASS runtime_compatibility_report_temporal_load_check
PASS executor_boundary_cache_key_contract
PASS executor_approval_token_report_proof
PASS guarded_runtime_executor_approval_enforcement
PASS runtime_smoke_post_switch_full_coverage
PASS temporal_read_observation_proof
PASS temporal_scope_exclusion_runtime_fixture
PASS executor_approval_authority_ref_proof
PASS temporal_executor_lib_prep
PASS stage1_close_candidate
PASS stage2_close_candidate
```

`temporal_executor_lib_prep` preserved:

```text
at2.happy_path.report_composed: ok
at4.no_token.blocked_at_approval_token: ok
at5.gate_closed.token_stage_passed_first: ok
at6.core_cache_key.blocked_at_cache_key: ok
at7.bihistory.blocked: ok
at9.wrong_authority.refused: ok
at10.happy_path.observation_emitted: ok
at12.core_fragment.blocked: ok
blocked_before_call.all_blocked_paths: ok
```

---

## Recommendation

[D] The post-C1 regression chain is green.

[R] **Safety pressure may proceed** for the landed lib-prep boundary.

[R] This is not live-read authorization. Live reads remain blocked until a
separate Architect decision addendum explicitly opens them.

[R] Continue to keep Phase 2, Ledger adapter binding, BiHistory, stream/OLAP,
production cache, and production signing/registry work outside this proof.

---

## Non-Authorization

[X] No live TBackend read was authorized.

[X] No Ledger adapter was authorized.

[X] No live-read decision addendum was created.

[X] No production cache was authorized.

---

## Handoff

```text
Card: S3-R17-C1-P
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/phase1-lib-prep-regression-chain-rerun-v0
Status: done

[D] Decisions
- S3-R16-C1 lib-prep regression chain is green: 14/14 PASS.
- No behavior drift found across S3-R7..R10 base chain, S3-R13..S3-R15
  pre-live fixtures, S3-R16 C1 targeted proof, Stage 1, or Stage 2.

[S] Shipped / Signals
- Added this post-C1 rerun track doc.
- Recorded exact pass/fail matrix.

[T] Tests / Proofs
- runtime_compatibility_report_temporal_load_check -> PASS
- executor_boundary_cache_key_contract -> PASS
- executor_approval_token_report_proof -> PASS
- guarded_runtime_executor_approval_enforcement -> PASS
- compatibility_report_package_descriptor_consumption -> PASS
- runtime_smoke_post_switch_full_coverage -> PASS
- compatibility_report_composition -> PASS
- temporal_read_observation_proof -> PASS
- runtime_report_enforcement_preflight -> PASS
- temporal_scope_exclusion_runtime_fixture -> PASS
- executor_approval_authority_ref_proof -> PASS
- temporal_executor_lib_prep -> PASS
- stage1_close_candidate -> PASS
- stage2_close_candidate -> PASS

[R] Risks / Recommendations
- Safety pressure may proceed.
- Live reads remain blocked until a separate Architect addendum.

[Next] Suggested next slice
- runtime-temporal-executor-lib-prep-safety-pressure-v0.
```
