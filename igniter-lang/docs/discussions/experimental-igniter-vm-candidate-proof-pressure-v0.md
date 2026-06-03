# Experimental Igniter VM Candidate Proof Pressure v0

Card: S3-R240-C3-X
Skill: IDD Agent Protocol
Agent: [External Pressure Reviewer]
Role: external-pressure-reviewer
Track: experimental-igniter-vm-candidate-proof-pressure-v0
Route: REVIEW
Status: complete
Date: 2026-06-03

Depends on:
- S3-R240-C1-A
- S3-R240-C2-I

---

## Inputs Read

- `igniter-lang/docs/tracks/experimental-igniter-vm-candidate-proof-authorization-review-v0.md` (C1-A)
- `igniter-lang/docs/tracks/experimental-igniter-vm-candidate-proof-v0.md` (C2-I)
- `playgrounds/igniter-lab/igniter-vm/out/vm_candidate_proof/summary.json` (verified)
- `igniter-lang/docs/tracks/experimental-igniter-vm-candidate-intake-decision-v0.md`
- `igniter-lang/docs/tracks/experimental-igniter-vm-candidate-surface-facts-v0.md`

Independent verifications performed:
- `cargo test --test vm_candidate_proof_tests` → 7/7 PASS (re-run confirmed)
- `cargo test --test vm_tests` → 12/12 PASS (confirmed in prior round, stable)
- Forbidden wording scan on track doc + summary.json → 0 hits
- Python non_claims check → 13/13 required items, 0 missing, 0 extra
- Git diff: no mainline source files changed

---

## Compact Risk Table

| Risk | Assessment | Fence | Residual |
| --- | --- | --- | --- |
| VMG-1..VMG-15 incomplete | Zero | 15/15 PASS confirmed; VMG-13 correctly CLASSIFIED not failed | Zero |
| non_claims missing or wrong | Zero | Python check: 13/13 required, 0 missing, 0 extra; exact match to C1-A list | Zero |
| "tamper-evident" / forbidden wording leaked (AN-1 from R239-C3-X) | Zero | Scan: 0 hits; `audit_observation: "hash-based trace identifier generation"` in capability_surface; VMG-11 detail uses "hash-based trace identifier" | Zero |
| Non-selected branch silence not proven (AN-2 from R239-C3-X) | Zero | VMG-8 PASS; detail: "then branch code is not executed and emits zero observations"; observation sink count verified | Zero |
| Reactive/tbackend daemon started as proof evidence | Zero | VMG-13 CLASSIFIED; skipped_or_classified_surfaces: reactive_tests.rs skipped, ReactiveListener/ProjectionPipeline/LedgerTcpBackend classified_only | Zero |
| Mainline source files changed | Zero | Git diff: only C1-A track doc (authorized) and proof track doc (authorized) as new files; 9 closed-surface paths confirmed unchanged | Zero |
| igc run Slice 1 opened | Zero | Track doc explicit; no widening in any changed file | Zero |
| Public/runtime/reference/stable/performance/portability claims | Zero | 13 non_claims present; VMG-15 PASS; authority_status array covers all required stances | Zero |
| R238 stdlib dependency cited as authority | Zero | VMG-4 correctly references "R238 standard library correctness rules"; framed as parity check, not as promoted dependency authority | Zero |
| command_matrix in JSON omits Ruby orchestrator command | Very low | Ruby script generates the JSON; Cargo commands are evidence-producing; track doc lists all 5 commands; informational only | Informational |

---

## Key Pressure-Check Findings

**Both R239-C3-X acceptance conditions fully addressed:**

**AN-1 (observation wording):** `capability_surface.audit_observation` = `"hash-based trace identifier generation"`. VMG-11 detail = `"OP_LOAD_AS_OF generates observation hash-based trace identifier using RFC3339 timestamp coords"`. Forbidden-wording scan returns 0 hits across both the track doc and summary.json. The previous "tamper-evidence" phrasing from C2-P1 does not appear anywhere in C2-I output.

**AN-2 (non-selected branch silence):** VMG-8 PASS with detail: `"Non-selected branch silence proven: false condition jumps to else branch; then branch code is not executed and emits zero observations"`. The observation-sink zero-count invariant directly matches the R226 AIP-7 / R228 AOT-8 standard. The test `test_proof_vmg7_vmg8_branch_selection_and_silence` in `vm_candidate_proof_tests.rs` provides concrete Rust-level evidence.

**non_claims quality:** All 13 required items present (`not_public_runtime_support`, `not_reference_runtime_support`, `not_stable_api`, `not_production_ready`, `not_spark_integration`, `not_release_evidence`, `not_public_performance_claim`, `not_official_reference_status`, `not_alternative_certification`, `not_portability_guarantee`, `not_igc_run_widening`, `not_compiler_passport_emission`, `not_runtime_smoke_productization`). Exact match to C1-A required set.

**Reactive/tbackend containment:** `skipped_or_classified_surfaces` explicitly lists all four surfaces. No server was started, no port was bound. VMG-13 CLASSIFIED is the correct status — it documents the classification without failing the proof.

**Closed surfaces:** Git diff confirms the only new mainline file is the authorized proof track doc. 9 closed-surface paths all confirmed unchanged.

---

## Explicit Answers

| Question | Answer |
| --- | --- |
| Is the proof sufficient for C4-A acceptance? | Yes. 15/15 checks, all required fields, AN-1 and AN-2 fully addressed. |
| VMG-1..VMG-15 pass? | Yes. VMG-13 correctly CLASSIFIED (not FAIL); all others PASS. |
| Generated output is evidence-only? | Yes. `evidence_class: "proof_local_vm_candidate_evidence"`, authority_status array, non_claims, and summary JSON field all confirm. |
| Forbidden wording leaked? | No. Scan returns 0 hits. "hash-based trace identifier" used throughout; no "tamper-evident", "cryptographic audit chain", or "digital signature". |
| Non-selected branch silence proven? | Yes. VMG-8 PASS; "then branch code is not executed and emits zero observations". |
| Reactive/tbackend surfaces non-authoritative? | Yes. Classified and skipped; no daemon started. |
| `igc run` Slice 1 remains held? | Yes. No widening in any output. |
| Public/runtime/reference/stable/performance/portability claims remain closed? | Yes. All 13 non_claims verified; VMG-15 PASS. |
| Exact C4-A recommendation? | Accept unconditionally. See below. |

---

## Verdict

```text
PASS — unconditional

C2-I igniter-vm candidate proof: 15/15 VMG PASS — accept
Both R239-C3-X acceptance conditions (AN-1, AN-2) fully resolved
No blockers
No acceptance notes
C4-A HOLD: release; proceed to unconditional acceptance
```

---

## Recommendation for S3-R240-C4-A

```text
Card: S3-R240-C4-A (final acceptance)
Route: UPDATE
Mode: unconditional acceptance

Accept:
- C2-I igniter-vm candidate proof (15/15 VMG PASS)
- runtime_implementation_id: igniter.delegated.experimental.vm.rust-tokio.v0
  (evidence metadata only — not stable API, not public runtime name)
- evidence_class: proof_local_vm_candidate_evidence (binding)
- All 13 non_claims present in result packet (binding)
- Decimal delegation parity with R238 accepted stdlib evidence
- Non-selected branch silence: verified (VMG-8 — zero observations)
- Observation trace wording: hash-based trace identifier only (VMG-11)
- Reactive/tbackend surfaces: classified and skipped (VMG-13)
- Closed-surface scan: all 9 paths unchanged (VMG-14)

What this accepts:
- proof-local VM candidate evidence for the igniter-vm Rust crate
- capability surface: stack execution, AOT compilation, Decimal math,
  branch selection/silence, temporal read, map-reduce, audit trace IDs

What this does not accept:
- public runtime support
- Reference Runtime support
- stable API or runtime API authority
- production readiness
- igc run Slice 1 widening
- tbackend / reactive daemon surfaces
- portability or certification guarantees

Keep closed:
- igc run Slice 1 (design-only if next; implementation still closed)
- Reference Runtime implementation
- RuntimeSmoke productization
- lib/** changes
- public runtime / stable API / production / Spark / release claims
- public performance claims
```
