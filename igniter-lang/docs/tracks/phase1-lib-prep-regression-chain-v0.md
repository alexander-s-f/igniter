# Track: Phase 1 Lib Prep Regression Chain v0

Card: S3-R16-C2-P
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `igniter-lang/phase1-lib-prep-regression-chain-v0`
Status: blocked
Date: 2026-05-09

Affected neighbor roles: `[Igniter-Lang Compiler/Grammar Expert]`,
`[Igniter-Lang Bridge Agent]`

---

## Goal

Run the regression chain after S3-R16-C1-P lib-prep lands and confirm behavior
did not drift.

---

## Blocker

[D] This card depends on:

```text
S3-R16-C1-P
```

Current workspace check found no landed C1 track, experiment, or dirty lib-prep
work to verify.

Searches performed:

```text
rg -n "S3-R16|runtime-temporal-executor-lib-prep|lib prep|lib-prep" igniter-lang -S
find igniter-lang/docs/tracks -maxdepth 1 -type f
find igniter-lang/experiments -maxdepth 2 -type f
git status --short
```

Observed state:

```text
S3-R16-C1-P track: not found
runtime-temporal-executor-lib-prep-v0 track: not found
git status --short: clean
```

Therefore, the regression chain was not run as post-C1 evidence. Running it now
would only re-prove the pre-lib-prep baseline, not the requested after-C1 state.

---

## Regression Matrix To Run After C1 Lands

| Group | Proof / command | Expected |
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
| Stage 1 close candidate | `ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb` | PASS |
| Stage 2 close candidate | `ruby igniter-lang/experiments/stage2_close_candidate/stage2_close_candidate.rb` | PASS |
| C1 targeted specs/proofs | Commands named by `runtime-temporal-executor-lib-prep-v0` | PASS |

Run sequentially; several proof scripts refresh nearby summary JSON files and
should not be run concurrently.

---

## Recommendation

[R] **HOLD** this regression card until S3-R16-C1-P lands and names its targeted
spec/proof commands.

[R] After C1 lands, rerun this matrix and record pass/fail against the C1
changed boundary.

[R] If any command fails, report the failing command and reason as a blocker.
Do not broad-patch from this verification slice.

---

## Non-Authorization

[X] No live TBackend.

[X] No Ledger adapter.

[X] No live read enablement.

[X] No production cache.

---

## Handoff

```text
Card: S3-R16-C2-P
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/phase1-lib-prep-regression-chain-v0
Status: blocked

[D] Decisions
- Dependency S3-R16-C1-P is not landed in the current workspace.
- Regression chain was not run as post-C1 evidence.
- Matrix is prepared for the after-C1 rerun.

[S] Shipped / Signals
- Added blocked track doc with the exact regression matrix.
- Confirmed no C1 track/experiment/dirty lib-prep work is present.

[T] Tests / Proofs
- Docs-only blocker record.
- git diff --check on this track doc should pass.

[R] Risks / Recommendations
- HOLD until C1 lands.
- Then run the full matrix plus any C1-targeted proof commands and record
  pass/fail.

[Next] Suggested next slice
- S3-R16-C1-P runtime-temporal-executor-lib-prep-v0, then rerun this card.
```
