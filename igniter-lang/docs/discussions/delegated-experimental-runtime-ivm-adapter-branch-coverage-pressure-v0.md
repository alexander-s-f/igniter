# Delegated Experimental Runtime IVM Adapter Branch Coverage Pressure v0

Card: S3-R226-C3-X
Skill: IDD Agent Protocol
Agent: [External Pressure Reviewer]
Role: external-pressure-reviewer
Track: delegated-experimental-runtime-ivm-adapter-branch-coverage-pressure-v0
Route: REVIEW
Status: complete
Date: 2026-06-01

Depends on:
- S3-R226-C1-A
- S3-R226-C2-I

---

## Inputs Read

- `igniter-lang/docs/tracks/delegated-experimental-runtime-ivm-adapter-branch-coverage-authorization-review-v0.md` (C1-A)
- `igniter-lang/docs/tracks/delegated-experimental-runtime-ivm-adapter-branch-coverage-proof-v0.md` (C2-I)
- `playgrounds/igniter-runtime/out/ivm_adapter_branch_coverage_proof/summary.json` (verified)
- `igniter-lang/docs/tracks/stage3-round225-status-curation-v0.md`
- `igniter-lang/docs/tracks/delegated-experimental-runtime-compiler-to-ivm-adapter-acceptance-decision-v0.md` (R225-C4-A)

Mainline git status: clean — no tracked files modified outside playground.

Proof output directory confirmed: `fresh_if_else.igapp`, `fresh_gt.igapp`, `summary.json`.

---

## Verified Proof State

From summary JSON and track doc:

```text
Fresh compile:  minimal_if_else.ig → fresh_if_else.igapp  ✓
                minimal_gt.ig      → fresh_gt.igapp        ✓

semantic_ir_program_sha256:       1526337ba19eaa83671eeae434f77a6f401bb846177a2b6fa6cf39972c7938fa
source_igapp_manifest_sha256:     29e65165bc4fe3a6844a09907ac0454e02218262679b73d886e636d82c8c1766
Digests distinct: YES  ← AN-1 from R225 resolved

stdlib.integer.gt stance: MAPPED → OP_GT (0x10)
  10 > 5 → true  ✓
   3 > 7 → false ✓

Branch (flag=true):   chosen = a (42)   → verified_executes
Branch (flag=false):  chosen = b (99)   → verified_silent (non-selected)

OP_UNSUPPORTED selected path:     → ExecutionError (fail-closed)  ✓
OP_UNSUPPORTED non-selected path: → jumped over, returns 100       ✓

R225 regression:  12/12 PASS (Add → 42)
R223 evidence:    quickstart_result.json PASS, unmodified
```

---

## Risk Matrix

| Risk | Probability | Severity | Fence | Residual |
| --- | --- | --- | --- | --- |
| Proof did not use fresh compiler — copied artifact as primary | Zero | High | BCP-3 PASS: "Mainline compiler compiled minimal_if_else.ig and minimal_gt.ig successfully"; two fresh .igapp directories confirmed in output | Zero |
| Digest fields still conflated (AN-1 from R225) | Zero | Medium | BCP-2 PASS: `semantic_ir_program_sha256` = `1526337b…`, `source_igapp_manifest_sha256_or_null` = `29e65165…`; distinct values; summary JSON fields correctly separated | Zero |
| `stdlib.integer.gt` silently omitted | Zero | High | BCP-10 PASS stance=MAPPED; BCP-11 PASS: OP_GT tested with `10>5` → true and `3>7` → false; no silent omission | Zero |
| Non-selected branch executes unsupported node | Zero | Critical | BCP-9 PASS: `flag=false` successfully bypassed OP_UNSUPPORTED via relative jump offsets, returned 100 with zero side-effects | Zero |
| Selected unsupported node silently succeeds | Zero | Critical | BCP-8 PASS: OP_UNSUPPORTED in selected path raises `ExecutionError`; fail-closed behavior verified | Zero |
| R223/R225 accepted evidence mutated | Zero | Critical | BCP-12 PASS: R225 Add regression 12/12 PASS; BCP-13 PASS: R223 quickstart_result.json present, unmodified | Zero |
| lib/** or bin/igc changed | Zero | Critical | BCP-14 PASS: `igniter_lang_lib_changed:false`, `bin_igc_changed:false`, `gemspec_changed:false`; mainline git clean | Zero |
| Overclaim: Reference Runtime / public runtime / stable API | Very low | Critical | BCP-15 PASS; `non_claims` all false; evidence_class: "branch/comparison adapter-hardening evidence only"; track doc disclaimer consistent | Very low |
| FFI/C acceleration opened without explicit C4-A sequencing choice | Low | Medium | C2-I recommends FFI/C again; R225-C4-A deferred it; adapter hardening now complete; C4-A must still choose explicitly | Low — AN-1 below |

---

## Scope-Check Matrix

| Check | Evidence | Finding | Safe? |
| --- | --- | --- | --- |
| Proof stayed inside playground-only write scope | BCP-14 PASS; closed_surface_scan all false; mainline git clean; writes: `playgrounds/igniter-runtime/**` + track doc | Scope exactly matches C1-A authorization. | ✅ PASS |
| Branch fixture provenance clear | BCP-1 PASS: fresh compile from proof-local `.ig` fixtures; BCP-3 PASS: `minimal_if_else.ig` and `minimal_gt.ig` freshly compiled; two `.igapp` directories in output | Fully source-backed provenance. No copied-artifact ambiguity. | ✅ PASS |
| Fresh compile attempted | BCP-3 PASS: primary path; `source_fixture_policy: "fresh playground-local compile preferred"` in JSON | Fresh compile succeeded; no fallback needed. | ✅ PASS |
| Digest fields no longer conflated | BCP-2 PASS: `semantic_ir_program_sha256` = `1526337b…` (file), `source_igapp_manifest_sha256_or_null` = `29e65165…` (manifest); values are distinct | AN-1 from R225 fully resolved. | ✅ PASS |
| Selected/non-selected branch behavior actually proven | BCP-6: `flag=true` → 42; BCP-7: `flag=false` → 99; `selected_branch_status: "verified_executes"`, `non_selected_branch_status: "verified_silent"` in JSON | Both paths verified with distinct input/output evidence, not just asserted. | ✅ PASS |
| `stdlib.integer.gt` mapped, held, or rejected explicitly | BCP-10 PASS: `stdlib_integer_gt_stance: "mapped"`; BCP-11 PASS: OP_GT (0x10) compiled and executed for both true and false cases | Mapped and tested. No silent omission. | ✅ PASS |
| Unsupported node behavior honest for both paths | BCP-8: OP_UNSUPPORTED in selected path → ExecutionError; BCP-9: OP_UNSUPPORTED in non-selected path bypassed via JMP, returns 100 silently | The `OP_UNSUPPORTED` bytecode approach is technically sound — unsupported nodes are compiled to a fail-bomb opcode that fires if selected and is silently jumped over if not. This is more honest than a compile-time guard because it verifies runtime lazy evaluation. | ✅ PASS |
| R223/R225 accepted evidence unchanged | BCP-12 PASS: R225 Add regression 12/12; BCP-13 PASS: quickstart_result.json intact | Both prior accepted evidence anchors confirmed. | ✅ PASS |
| Closed surfaces stayed closed | BCP-14 PASS; all three surface scan fields false; mainline git clean | Confirmed. | ✅ PASS |

---

## What AN-1 from R225 Resolved

R225-C3-X AN-1 noted that `source_igapp_sha256` and `semantic_ir_program_sha256` both recorded the `semantic_ir_program.json` digest. C1-A required distinct fields. BCP-2 confirms the resolution: the summary JSON now has:

- `semantic_ir_program_sha256`: file-level digest of `semantic_ir_program.json`
- `source_igapp_manifest_sha256_or_null`: directory-manifest-level digest

Two distinct non-equal values. AN-1 is closed.

---

## Explicit Answers

| Question | Answer |
| --- | --- |
| PASS / CONDITIONAL / HOLD? | PASS |
| Is C2-I evidence enough for C4-A acceptance? | Yes. 15/15 BCP checks pass. Fresh compile verified. Digest fields separated. Branch behavior and comparison both proven. All closed surfaces confirmed. |
| May generated outputs be called branch/comparison adapter-hardening evidence only? | Yes. `evidence_class: "branch/comparison adapter-hardening evidence only"` is the correct and binding label. |
| Did runtime momentum change again? | Yes. The adapter now handles: Add, if_expr branches (JMP semantics), integer comparison (OP_GT), unsupported-node fail-close, and unsupported-non-selected silence. This is a materially more capable substrate than R225. |
| May FFI/C acceleration open next, or should it wait? | It may open next if C4-A explicitly chooses it. Adapter hardening is now complete — the gap that justified C1-A over FFI acceleration (from R225-C4-A) is resolved. The case for FFI is stronger than at R225. But R225-C4-A named four options and FFI was Option A; C4-A must still choose explicitly, not auto-route. See AN-1 below. |
| What exact next route should C4-A choose? | C4-A must choose among the surviving options from R225-C3-X AN-2 (D is now closed): Option A (FFI/C acceleration), Option B (reusable helper), or Option C (Runtime Specification input slice). See AN-1. |

---

## Non-Blocking Acceptance Note

**AN-1 — Adapter hardening is complete; C4-A must now explicitly revisit the R225-C3-X AN-2 option set.**

C2-I recommends FFI/C acceleration for the second consecutive round. The gap that justified adapter hardening over FFI (weak digest, fresh compile question, `gt` silent, branch not source-backed) is now fully resolved. The case for FFI is materially stronger than at R225.

However, R225-C4-A deferred FFI explicitly (AN-2: "C4-A must name one ordering explicitly") and chose adapter hardening as the immediate next route. That was correct. Now that adapter hardening is complete, C4-A faces the same three-way choice:

| Option | Focus | TTEU impact | Toolchain | Next question it answers |
| --- | --- | --- | --- | --- |
| A — FFI/C acceleration | Performance | Low direct | C/Rust added | Can IVM bytecode escape Ruby loop overhead? |
| B — Reusable helper extraction | Developer UX | High direct | Ruby only | Can examples share runtime load/eval logic? |
| C — Runtime Specification input slice | Normative formalization | Medium indirect | Docs only | What semantics have the playground proofs established? |

With adapter hardening now done, all three options are technically unblocked. C4-A should name one. The pressure review does not choose — it confirms all three are safe to open.

---

## Verdict

```text
PASS

C2-I IVM Adapter Branch Coverage Proof: 15/15 BCP PASS — accept
No blockers
1 non-blocking acceptance note (AN-1: adapter hardening complete;
  C4-A must explicitly choose among Options A/B/C from R225-C3-X AN-2)
C4-A HOLD: release; proceed to final acceptance decision
```

AN-1 from R225 is resolved. All C1-A requirements met. The proof is clean and materially advances the adapter surface.

---

## Recommendation for S3-R226-C4-A

```text
Card: S3-R226-C4-A (final acceptance)
Route: UPDATE
Mode: final acceptance decision

Accept:
- C2-I IVM Adapter Branch Coverage Proof (15/15 BCP PASS)
- Fresh-compiled branch/comparison execution evidence
- semantic_ir_program_sha256: 1526337ba19eaa83671eeae434f77a6f401bb846177a2b6fa6cf39972c7938fa
- manifest_sha256: 29e65165bc4fe3a6844a09907ac0454e02218262679b73d886e636d82c8c1766
- evidence_class: "branch/comparison adapter-hardening evidence only" (binding)
- stdlib_integer_gt_stance: "mapped" (binding)
- selected_branch_status: "verified_executes" (binding)
- non_selected_branch_status: "verified_silent" (binding)

Note for acceptance record (AN-1 — adapter hardening complete):
  All C1-A adapter hardening goals are now met. C4-A must explicitly
  choose the next route from the surviving options:
    Option A: FFI/C bytecode acceleration (performance depth)
    Option B: Reusable helper extraction (TTEU / developer ergonomics)
    Option C: Runtime Specification input slice (normative formalization)
  With D (more adapter hardening) now closed, one of A/B/C must be named.

Keep closed regardless of chosen route:
- lib/** changes
- bin/igc, gemspec, README, public docs
- RuntimeSmoke productization
- Reference Runtime implementation
- igc run (implementation)
- public runtime / stable API / production / Spark / release claims
```
