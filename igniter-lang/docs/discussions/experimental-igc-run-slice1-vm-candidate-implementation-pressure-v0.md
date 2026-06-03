# Experimental igc run Slice 1 VM Candidate Implementation Pressure v0

Card: S3-R243-C3-X
Skill: IDD Agent Protocol
Agent: [External Pressure Reviewer]
Role: external-pressure-reviewer
Track: experimental-igc-run-slice1-vm-candidate-implementation-pressure-v0
Route: REVIEW
Status: complete
Date: 2026-06-03

Depends on:
- S3-R243-C1-A
- S3-R243-C2-I

---

## Inputs Read

- `igniter-lang/docs/tracks/experimental-igc-run-slice1-vm-candidate-implementation-authorization-review-v0.md` (C1-A)
- `igniter-lang/docs/tracks/experimental-igc-run-slice1-vm-candidate-implementation-v0.md` (C2-I)
- `igniter-lang/experiments/experimental_igc_run_slice1_vm_candidate_v0/out/summary.json` (verified)
- `igniter-lang/experiments/experimental_igc_run_slice1_vm_candidate_v0/out/slice1_integer_add_blocked.result.json` (verified)
- `igniter-lang/experiments/experimental_igc_run_slice1_vm_candidate_v0/out/slice0_compat.result.json` (verified)
- `igniter-lang/docs/tracks/experimental-igc-run-slice1-vm-capability-passport-hardening-decision-v0.md`

Independent verifications:
- Python: blocked result has `status: "blocked"`, 2 explicit diagnostics, `stable_api: false` ✓
- Python: Slice 0 compat result `status: "ok"`, `sum: 42` ✓
- Git log: `source/availability_projection.ig` pre-existing workspace change (commit 66059770), not caused by C2-I ✓
- IGR-S1-18 `authorized_scope_diff` = `[cli.rb, experimental_igc_run.rb]`; correct (new file `experimental_igc_run_vm_candidate.rb` not in diff as it's untracked new file within authorized scope) ✓

---

## Compact Risk Table

| Risk | Assessment | Fence | Residual |
| --- | --- | --- | --- |
| Implementation crept outside C1-A write scope | Zero | `git_diff_name_only`: only `cli.rb` + `experimental_igc_run.rb`; new `experimental_igc_run_vm_candidate.rb` is untracked new file within authorized `lib/igniter_lang/` scope; all 12 closed surfaces confirm empty `git status --short` | Zero |
| Source/*.ig workspace changes caused by C2-I | Zero | Git log confirms `availability_projection.ig` last committed in old commit (66059770); IGR-S1-18 correctly excludes from `authorized_scope_diff`; workspace note explicit | Zero |
| integer_add silently executes (Path C not implemented) | Zero | Blocked result: `status: "blocked"`, 2 diagnostics with `code: unsupported_capability_integer_add` and `code: unsupported_capability_stdlib_integer_add`, both with `policy: "fail_closed"`; exit code 1 | Zero |
| Selector and runtime_implementation_id conflated | Zero | IGR-S1-3 PASS; blocked result `runtime_selector: "delegated-experimental:igniter-vm-candidate"` is user-facing; `runtime_implementation_id: "igniter.delegated.experimental.vm.rust-tokio.v0"` is evidence metadata; distinct in all result packets | Zero |
| Slice 0 `delegated-experimental:ivm-proof` broken | Zero | IGR-S1-13 PASS; `run.slice0_compat`: exit 0, `status: "ok"`, `sum: 42`; same Add.igapp + same inputs | Zero |
| .igbin accepted | Zero | IGR-S1-10 PASS; `run.unsupported_igbin_path`: exit 1, stderr "igc run Slice 0 accepts .igapp directories only\n" | Zero |
| RuntimeSmoke or compiler passport emission present | Zero | IGR-S1-11/12 PASS; `runtime_smoke.rb`, `compiler_result.rb`, `compilation_report.rb` all empty `git status`; claim_scan: 0 hits | Zero |
| Result packet creates public runtime / Reference Runtime authority | Zero | IGR-S1-14/15 PASS; `experimental: true`, `pre_v1: true`, `stable_api: false`, `not_compiler_result: true`, `not_release_evidence: true`; claim_scan hits: 0 | Zero |
| Public/stable/production/Spark/release/performance/portability claims | Zero | IGR-S1-15 PASS; claim_scan.hits: [] | Zero |
| bin/igc, gemspec, README, playground changed | Zero | All confirmed empty `git status --short` in closed_surface_scan | Zero |

---

## Pressure-Test Findings

**Implementation scope:** `authorized_scope_diff = [cli.rb, experimental_igc_run.rb]`. The new `experimental_igc_run_vm_candidate.rb` is a new untracked file within the authorized `igniter-lang/lib/igniter_lang/` write scope — this is correct; `git diff --name-only` shows modified tracked files, not new untracked files.

**Path C implemented exactly:** Two explicit machine-readable diagnostics with codes `unsupported_capability_integer_add` and `unsupported_capability_stdlib_integer_add`, each carrying `details.policy: "fail_closed"` and `details.selected_an1_path: "Path C fail-closed"`. The blocked result exits with code 1. No VM execution was attempted for the integer-add artifact.

**Existing passport mismatch not silently reinterpreted (IGR-S1-6):** The existing Add.igapp passport has `runtime_implementation_id: igniter.delegated.experimental.ivm.c_resident`. The blocked result records `passport_check: "runtime_implementation_id_mismatch_acknowledged"` — the mismatch is documented as an acknowledged evidence boundary, not hidden.

**Slice 0 backward compatibility confirmed:** `delegated-experimental:ivm-proof` with the same Add.igapp + same `{a:19, b:23}` input → `status: "ok"`, `sum: 42`. No regression.

**Workspace diff observation:** `igniter-lang/source/availability_projection.ig` and `igniter-lang/source/tenant_availability_projection.ig` appear in the workspace diff. Git log shows these were last committed in commit `66059770` (much earlier) — they are pre-existing unstaged user changes entirely unrelated to C2-I. The IGR-S1-18 check correctly documents them as `workspace_diff_observation` while the `authorized_scope_diff` only contains the two files that C2-I actually changed.

---

## Explicit Answers

| Question | Answer |
| --- | --- |
| PASS / CONDITIONAL PASS / HOLD / REDIRECT? | PASS — unconditional |
| Exact blockers? | None. |
| Implementation evidence accepted? | Yes. |
| Generated output is experimental delegated-runtime Slice 1 evidence only? | Yes. `experimental: true`, `pre_v1: true`, `stable_api: false`, `not_compiler_result: true`, `not_release_evidence: true`, `selected_an1_path: "Path C fail-closed"`. |
| Creates public runtime support or Reference Runtime support? | No. All claim checks pass with 0 hits. |
| Public/stable/production/Spark/release/performance/portability claims closed? | Yes. |
| C4-A may accept or must hold? | C4-A may accept unconditionally. |

---

## Verdict

```text
PASS — unconditional

C2-I Slice 1 VM candidate implementation: 18/18 IGR-S1 PASS — accept
Path C fail-closed: implemented exactly
Slice 0 compatible: confirmed (sum=42)
No blockers
No acceptance notes
C4-A HOLD: release; proceed to unconditional acceptance
```

---

## Recommendation for S3-R243-C4-A

```text
Card: S3-R243-C4-A (final acceptance)
Route: UPDATE
Mode: unconditional acceptance

Accept:
- C2-I Slice 1 VM candidate implementation (18/18 IGR-S1 PASS)
- Selector: delegated-experimental:igniter-vm-candidate (user-facing)
- runtime_implementation_id: igniter.delegated.experimental.vm.rust-tokio.v0
  (evidence-facing metadata only)
- Path C fail-closed: integer_add / stdlib_integer_add → blocked diagnostics
  (code: unsupported_capability_integer_add / unsupported_capability_stdlib_integer_add)
- Slice 0 delegated-experimental:ivm-proof: backward-compatible (sum=42)
- Passport mismatch: acknowledged evidence (not silently reinterpreted)

What this accepts:
- Experimental igc run Slice 1 selector and proof-local validation boundary
- Machine-readable fail-closed diagnostics for capability gaps
- Evidence-only result packet shape

What this does not accept:
- Positive execution of Add.igapp with integer_add (fail-closed under Path C)
- Public runtime support
- Reference Runtime support
- Stable API guarantee before v1
- Any production/Spark/release/performance/portability claims
- .igbin execution
- RuntimeSmoke productization
- Compiler passport emission

Keep closed:
- igc run Slice 1 widening beyond Path C
- .igbin execution
- compiler passport emission
- RuntimeSmoke productization
- Reference Runtime
- public runtime / stable API / production / Spark / release claims
- public performance claims
```
