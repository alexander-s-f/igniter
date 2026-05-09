# Track: Phase 1 R18 Cleanup Regression Rerun v0

Card: S3-R19-C1-P
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `phase1-r18-cleanup-regression-rerun-v0`
Status: done
Date: 2026-05-09

Affected neighbor roles: `[Igniter-Lang Compiler/Grammar Expert]`,
`[Igniter-Lang Bridge Agent]`

---

## Goal

Re-run the full Gate 3 Phase 1 proof chain after R18 C2/C3/C4 cleanup, using
the R17 14-proof chain as the baseline and adding the R18 backend identity
guard proof.

---

## Scope Notes

[D] This rerun does not authorize live reads.

[D] The backend identity guard proof now also checks that successful
`temporal_live_read_observation` records include `backend_identity`.

[S] The current working tree already had an unrelated modification to
`docs/gates/gate3-live-read-decision-addendum-v0.md`; this card did not edit
that file. Its currently visible guard order is:

```text
approval_token -> gate_state -> backend_identity -> scope -> cache_key -> executor_backend
```

---

## Regression Matrix

All commands were run sequentially against the current worktree after R18
cleanup.

| # | Command | Result |
|---:|---|---|
| 1 | `ruby igniter-lang/experiments/runtime_compatibility_report_temporal_load_check/runtime_compatibility_report_temporal_load_check.rb` | PASS |
| 2 | `ruby igniter-lang/experiments/executor_boundary_cache_key_contract/executor_boundary_cache_key_contract.rb` | PASS |
| 3 | `ruby igniter-lang/experiments/executor_approval_token_report_proof/executor_approval_token_report_proof.rb` | PASS |
| 4 | `ruby igniter-lang/experiments/guarded_runtime_executor_approval_enforcement/guarded_runtime_executor_approval_enforcement.rb` | PASS |
| 5 | `ruby igniter-lang/experiments/compatibility_report_package_descriptor_consumption/compatibility_report_package_descriptor_consumption.rb` | PASS |
| 6 | `ruby igniter-lang/experiments/runtime_smoke_post_switch_full_coverage/runtime_smoke_post_switch_full_coverage.rb` | PASS |
| 7 | `ruby igniter-lang/experiments/compatibility_report_composition/compatibility_report_composition.rb` | PASS |
| 8 | `ruby igniter-lang/experiments/temporal_read_observation_proof/temporal_read_observation_proof.rb` | PASS |
| 9 | `ruby igniter-lang/experiments/runtime_report_enforcement_preflight/runtime_report_enforcement_preflight.rb` | PASS |
| 10 | `ruby igniter-lang/experiments/temporal_scope_exclusion_runtime_fixture/temporal_scope_exclusion_runtime_fixture.rb` | PASS |
| 11 | `ruby igniter-lang/experiments/executor_approval_authority_ref_proof/executor_approval_authority_ref_proof.rb` | PASS |
| 12 | `ruby igniter-lang/experiments/temporal_executor_lib_prep/temporal_executor_lib_prep.rb` | PASS |
| 13 | `ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb` | PASS |
| 14 | `ruby igniter-lang/experiments/stage2_close_candidate/stage2_close_candidate.rb` | PASS |
| 15 | `ruby igniter-lang/experiments/phase1_backend_identity_guard/phase1_backend_identity_guard.rb` | PASS |

Total:

```text
15/15 PASS
```

---

## Backend Identity Observation Check

Added the minimal proof-local observation field:

```json
{
  "kind": "temporal_live_read_observation",
  "backend_identity": {
    "kind": "proof_local_memory_backend"
  }
}
```

The R18 backend identity guard proof now checks:

```text
observation.backend_identity_emitted: ok
```

Covered allowed observation identities:

- `proof_local_memory_backend`
- `proof_local_non_ledger_backend`

Blocked Ledger/unmarked/malformed cases still emit no live read observations
and perform zero backend reads.

---

## Exact PASS Signals

Key observed outputs:

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
PASS phase1_backend_identity_guard
  observation.backend_identity_emitted: ok
```

Syntax checks:

```text
ruby -c igniter-lang/lib/igniter_lang/temporal_executor.rb
Syntax OK

ruby -c igniter-lang/experiments/phase1_backend_identity_guard/phase1_backend_identity_guard.rb
Syntax OK
```

---

## Non-Authorization

[X] No live TBackend read was authorized.

[X] No Ledger adapter/package binding was authorized.

[X] No production cache was authorized.

[X] No Phase 2 surface was opened.

[X] The addendum remains the authority boundary; this rerun is evidence for
signature review, not a signature.

---

## Recommendation

[R] **Ready for signature review** from this card's evidence perspective:
the post-R18 regression chain is green, the R18 backend identity guard is in
the matrix, and the practical `backend_identity` observation assertion is now
covered.

[R] Keep live reads blocked until the Architect explicitly signs/updates the
Gate 3 live-read addendum. Current proof evidence remains proof-local.

---

## Handoff

```text
Card: S3-R19-C1-P
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/phase1-r18-cleanup-regression-rerun-v0
Status: done

[D] Decisions
- R17 baseline plus R18 backend identity guard passes: 15/15 PASS.
- Successful Phase 1 temporal live read observations now carry backend_identity.
- This card does not authorize live reads.

[S] Shipped / Signals
- Added this R19 rerun track doc.
- Added backend_identity to proof-local temporal_live_read_observation.
- Added R18 guard assertion: observation.backend_identity_emitted.

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
- phase1_backend_identity_guard -> PASS
- ruby -c temporal_executor.rb -> Syntax OK
- ruby -c phase1_backend_identity_guard.rb -> Syntax OK

[R] Risks / Recommendations
- Ready for signature review, but still not live-read authorization.
- Phase 2 Ledger/BiHistory/stream/OLAP/cache/write surfaces remain closed.

[Next] Suggested next slice
- Architect signature review for gate3-live-read-decision-addendum-v0 if
  PS-2 guard-order amendment is accepted.
```
