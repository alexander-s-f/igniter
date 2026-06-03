# Experimental igc run Slice 1 VM Capability Passport Hardening Pressure v0

Card: S3-R242-C3-X
Skill: IDD Agent Protocol
Agent: [External Pressure Reviewer]
Role: external-pressure-reviewer
Track: experimental-igc-run-slice1-vm-capability-passport-hardening-pressure-v0
Route: REVIEW
Status: complete
Date: 2026-06-03

Depends on:
- S3-R242-C1-A
- S3-R242-C2-I

---

## Inputs Read

- `igniter-lang/docs/tracks/experimental-igc-run-slice1-vm-capability-passport-hardening-authorization-review-v0.md` (C1-A)
- `igniter-lang/docs/tracks/experimental-igc-run-slice1-vm-capability-passport-hardening-v0.md` (C2-I)
- `igniter-lang/experiments/experimental_igc_run_slice1_vm_capability_passport_hardening_v0/out/summary.json` (verified)
- `igniter-lang/docs/tracks/experimental-igc-run-slice1-vm-candidate-design-decision-v0.md`
- `playgrounds/igniter-lab/igniter-vm/out/vm_candidate_proof/summary.json` (R240 baseline)

Independent verifications:
- Python: 14/14 S1H PASS confirmed
- Python: artifact digest recomputed = `sha256:c402b014…` — matches R232 accepted value exactly ✓
- Python: `claim_scan.hit_count = 0` ✓
- Python: `written_outside_allowed_scope = []` ✓
- Git diff: only authorized experiment directory + track doc changed ✓

---

## Compact Risk Table

| Risk | Assessment | Fence | Residual |
| --- | --- | --- | --- |
| Hardening proof accidentally authorizes implementation | Zero | C2-I explicit: "Implementation authorization remains closed"; `c4_a_recommendation.implementation_authorization: "closed"` | Zero |
| runtime_implementation_id used as user-facing CLI selector (AN-2 from R241) | Zero | S1H-4/5 PASS; `runtime_implementation_id_is_user_typed_selector=false`; selector separation JSON artifact produced | Zero |
| Capabilities mapped beyond accepted VMG-1..VMG-15 | Very low | S1H-6 PASS; track doc VMG map explicit; `integer_add` gap correctly recorded as fail-closed — not smuggled as capability | Very low |
| Loop/recursion promoted to Slice 1 capability (AN-1 from R241) | Zero | S1H-7 PASS; `loops_and_recursion.ig` read as pressure-only; unsupported feature matrix classifies all loop/recursion markers fail-closed | Zero |
| .igbin execution smuggled in | Zero | S1H-8 PASS; `.igbin` in unsupported/fail-closed matrix | Zero |
| Compiler passport emission present | Zero | S1H-9 PASS; claim_scan: 0 hits for `compiler_passport_emission` | Zero |
| RuntimeSmoke present | Zero | S1H-10 PASS; claim_scan: 0 hits for `runtime_smoke_productization` | Zero |
| Existing Add.igapp or Add.igapp passport mutated | Zero | `closed_surface_scan.proof_access: "read-only / not written"` for both; git diff confirms no change to those paths | Zero |
| Artifact digest incorrect or non-deterministic | Zero | Python recomputation: `sha256:c402b014…` = exact R232 match; S1H-2 PASS | Zero |
| Public/reference/stable/performance/portability claims leaked | Zero | S1H-13 PASS; claim_scan: 0 hits across 13 forbidden keys | Zero |
| `integer_add` / `stdlib_integer_add` gap may block implementation | Low | Correctly identified and labeled `gap_fail_closed_until_runtime_spec_or_vm_integer_parity_evidence`; not a hardening proof failure; C4-A must address before implementation authorization | Low — see AN-1 |
| Closed surfaces changed | Zero | S1H-14 PASS; 12 surfaces confirmed "read-only / not written"; `written_outside_allowed_scope: []`; git diff confirms | Zero |

---

## Pressure-Test Findings

**S1H-1..S1H-14 all PASS:** Python verification confirms 14/14, zero failures.

**Artifact digest independently verified:** Python recomputes the Add.igapp directory digest using the accepted Slice 0 / R232 policy (sort files → SHA256 each → join with `:` → SHA256 → prefix `sha256:`) and produces `sha256:c402b014620fb7c16903861253e362c7b585223b4c26f75a51d3527029d2c5ee` — exact match to the R232 accepted value. S1H-2 is not just self-reported; it is independently verifiable.

**Selector separation correctly resolved (R241 AN-2):** The summary JSON explicitly records both the user-facing selector (`delegated-experimental:igniter-vm-candidate`) and the evidence-facing `runtime_implementation_id` (`igniter.delegated.experimental.vm.rust-tokio.v0`) as distinct, with `runtime_implementation_id_is_user_typed_selector=false`. The `existing_passport_runtime_implementation_id: igniter.delegated.experimental.ivm.c_resident` is also recorded, documenting the passport binding gap that this hardening proof was designed to address.

**Loop/recursion correctly contained (R241 AN-1):** S1H-7 PASS. The unsupported feature fail-closed matrix covers loops, recursion, service-loop clock ticks (`tick.time`, `clock.every`), and `decreases fuel` markers — all classified fail-closed. No loop test from `vm_candidate_proof_tests.rs` is promoted as capability evidence.

**`integer_add` gap — honest and correctly handled:** The Add.igapp Add contract uses `stdlib.integer.add` (Integer typed inputs, not Decimal). The hardening proof correctly records `integer_add` and `stdlib_integer_add` as feature gaps with label `gap_fail_closed_until_runtime_spec_or_vm_integer_parity_evidence`. This is the right behavior — the VMG-4 Decimal parity was proven against R238 stdlib, but Integer addition has not been separately proven for the Rust VM against a mainline evidence baseline. The proof refuses to bind this capability and defers to a future route. This does not fail the hardening proof; it is honest gap documentation. However, it is a sequencing note for implementation authorization — see AN-1.

**Claim scan:** 13 forbidden positive-claim keys scanned, 0 hits. This is machine-readable, not merely asserted.

**Write scope compliance:** Git diff confirms the 9 files changed are all within the authorized experiment directory plus the proof track doc. No lib/**, bin/igc, gemspec, README, playground, existing Add.igapp, or existing passport changes.

---

## Explicit Answers

| Question | Answer |
| --- | --- |
| PASS / CONDITIONAL PASS / HOLD / REDIRECT? | PASS with 1 non-blocking acceptance note |
| Exact blockers? | None. |
| S1H-1..S1H-14 pass? | Yes. 14/14 PASS, independently verified. |
| Hardening evidence sufficient for C4-A? | Yes. The R241 passport binding prerequisite is closed: a proof-local binding manifest exists that maps Add.igapp to `igniter.delegated.experimental.vm.rust-tokio.v0` with correct digest, capability mapping, and non-claims. |
| Implementation authorization open next? | Not yet. See AN-1 — the `integer_add` gap must be explicitly addressed by C4-A before implementation authorization. |
| Runtime Specification redirect needed? | No, as an immediate blocker. The gap is labeled `gap_fail_closed_until_runtime_spec_or_vm_integer_parity_evidence` — this means a VM integer parity proof or runtime spec input could close it, but neither is a prerequisite for accepting the hardening proof itself. |
| `.igbin` output_contract design needed? | Separate future route; not a current concern. |
| All public/runtime/reference/stable/performance/portability claims closed? | Yes. |

---

## Non-Blocking Acceptance Note

**AN-1 — `integer_add` / `stdlib_integer_add` feature gap must be explicitly addressed by C4-A before implementation authorization.**

The Add.igapp Add contract (`a + b` where both are Integer typed) requires `stdlib.integer.add`. The hardening proof correctly records this as a gap (`gap_fail_closed_until_runtime_spec_or_vm_integer_parity_evidence`) because the R240 VMG-4 proof covered Decimal arithmetic delegation to R238 stdlib, not Integer arithmetic.

This gap does not fail the hardening proof — gap documentation is exactly what the hardening proof should produce. However, before Slice 1 implementation authorization opens, C4-A must explicitly choose one path:

**Path A:** Produce a VM integer parity evidence proof before implementation authorization (small bounded proof showing `OP_ADD` with Integer typed values against the Rust VM).

**Path B:** Implementation authorization uses a different proof artifact (one that only uses Decimal operations) so the `integer_add` gap doesn't surface at runtime.

**Path C:** Slice 1 implementation is designed so that encountering `integer_add` in a contract produces an explicit fail-closed diagnostic (documented gap, not silent failure). C4-A acceptance record should name this as a known fail-closed path.

None of these is a blocker for accepting the hardening proof. C4-A should name one path explicitly when opening the Slice 1 implementation authorization review.

---

## Verdict

```text
PASS

C2-I VM capability/passport hardening proof: 14/14 S1H PASS — accept
R241 passport binding prerequisite: closed
Artifact digest: sha256:c402b014… independently verified ✓
Selector separation: resolved (R241 AN-2 closed)
Loop/recursion: classified pressure-only and fail-closed (R241 AN-1 closed)
Claim scan: 0 hits
No blockers
1 non-blocking acceptance note (AN-1: integer_add gap — C4-A must choose
  path before implementation authorization opens)
C4-A HOLD: release; proceed to acceptance; keep implementation authorization
  held until AN-1 path is named
```

---

## Recommendation for S3-R242-C4-A

```text
Card: S3-R242-C4-A (final acceptance)
Route: UPDATE
Mode: accept hardening evidence / address integer_add gap path / route impl auth

Accept:
- C2-I VM capability/passport hardening proof (14/14 S1H PASS)
- Proof-local binding manifest for Add.igapp ↔ vm.rust-tokio.v0
- artifact_digest: sha256:c402b014620fb7c16903861253e362c7b585223b4c26f75a51d3527029d2c5ee
  (independently verified against R232 accepted value)
- runtime_selector: delegated-experimental:igniter-vm-candidate (binding)
- runtime_implementation_id: igniter.delegated.experimental.vm.rust-tokio.v0
  (evidence-facing metadata only; not CLI selector)
- R241 passport binding prerequisite: closed

Note for acceptance record (AN-1 — choose one path):
  integer_add / stdlib_integer_add: gap_fail_closed_until_runtime_spec_or_vm_integer_parity_evidence
  C4-A must name:
    Path A: open VM integer parity evidence proof before implementation auth
    Path B: use a Decimal-only artifact as Slice 1 proof target
    Path C: Slice 1 implementation records integer_add as explicit fail-closed
             diagnostic; implementation authorized knowing this gap

Open next (after AN-1 path named):
  Bounded Slice 1 implementation authorization review
  Track: experimental-igc-run-slice1-vm-candidate-implementation-authorization-review-v0

Keep closed regardless of chosen AN-1 path:
- igc run Slice 1 implementation (authorization review must open first)
- .igbin execution
- compiler passport emission
- RuntimeSmoke productization
- Reference Runtime
- public runtime / stable API / production / Spark / release claims
- loops/recursion (fail-closed; separate PROP-037+ route)
```
