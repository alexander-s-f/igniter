# Experimental igc run Slice 1 VM Candidate Design Pressure v0

Card: S3-R241-C3-X
Skill: IDD Agent Protocol
Agent: [External Pressure Reviewer]
Role: external-pressure-reviewer
Track: experimental-igc-run-slice1-vm-candidate-design-pressure-v0
Route: REVIEW
Status: complete
Date: 2026-06-03

Depends on:
- S3-R241-C1-D
- S3-R241-C2-P1

---

## Inputs Read

- `igniter-lang/docs/tracks/experimental-igc-run-slice1-vm-candidate-design-boundary-v0.md` (C1-D)
- `igniter-lang/docs/tracks/experimental-igc-run-slice1-current-surface-and-vm-candidate-facts-v0.md` (C2-P1)
- `igniter-lang/docs/tracks/stage3-round240-status-curation-v0.md`
- `igniter-lang/docs/tracks/experimental-igniter-vm-candidate-proof-acceptance-decision-v0.md`
- `playgrounds/igniter-lab/igniter-vm/out/vm_candidate_proof/summary.json`
- `igniter-lang/docs/tracks/experimental-igc-run-slice0-implementation-acceptance-decision-v0.md`
- Loop test grep on `playgrounds/igniter-lab/igniter-vm/tests/vm_candidate_proof_tests.rs`

---

## Compact Risk Table

| Risk | Assessment | Fence | Residual |
| --- | --- | --- | --- |
| Design card accidentally authorizes implementation | Zero | C1-D explicit: "Slice 1 implementation authorization: not ready yet"; "Implementation authorization remains explicitly closed until the hardening proof is accepted" | Zero |
| `igniter-vm` naming creates public/Reference Runtime authority | Very low | C1-D: selector = `delegated-experimental:igniter-vm-candidate`; `runtime_implementation_id` = evidence-facing only; C2-P1 section 5 classification: "candidate evidence, not public/Reference Runtime" | Very low |
| `runtime_implementation_id` looks too stable for CLI use | Low | C1-D correctly separates user-facing selector (`delegated-experimental:igniter-vm-candidate`) from evidence-facing metadata (`igniter.delegated.experimental.vm.rust-tokio.v0`); the latter "should not be the primary CLI selector" | Low — see AN-2 |
| Passport mismatch between Add.igapp (ivm.c_resident) and Rust VM (vm.rust-tokio.v0) | Low | C1-D correctly identifies this as the only implementation blocker; design explicitly holds until a VM capability/passport hardening proof closes this mismatch | Low — correctly managed |
| Compiler passport emission smuggled in | Zero | C1-D: "Compiler passport emission remains closed"; boundary matrix: "Closed"; C2-P1: "Closed" | Zero |
| `.igbin` execution smuggled in | Zero | C1-D: "Excluded: .igbin input / .igbin execution"; boundary matrix entry explicit | Zero |
| RuntimeSmoke promoted | Zero | C1-D: "Closed; no fallback, no productization"; C2-P1: "No fallback, no productization" | Zero |
| Loop tests in `vm_candidate_proof_tests.rs` treated as R240 accepted proof evidence | Low | C2-P1 section 6 names them "Active Lab Verification Evidence" — stronger than "pressure input only"; C1-D correctly classifies loops as "pressure input only; excluded from Slice 1"; R240 summary.json (VMG-1..VMG-15) is the authoritative record and contains no loop entries | Low — see AN-1 |
| Recursion/loops blocking Slice 1 | Zero | C1-D: "Slice 1 blocker: no" for recursion/loops; correctly routed to Runtime Spec / PROP-037+ | Zero |
| Runtime Specification gaps blocking Slice 1 design | Very low | C1-D: "No immediate blocker for design. Possible blockers may appear during capability/passport hardening"; correctly deferred | Very low |
| igc run Slice 1 implementation authorized prematurely | Zero | C1-D: "do not open implementation authorization yet"; C4-A recommendation explicitly holds | Zero |
| Public/stable/production/Reference Runtime/Spark/release/performance/portability claims | Zero | Boundary matrix rows all Closed; C2-P1 closed-surface scan confirmed | Zero |

---

## Pressure-Test Findings

**Design-only status confirmed:** C1-D status field = `"design-ready-with-prerequisite"`. The document does not authorize implementation, and the C4-A recommendation explicitly says "do not open implementation authorization yet." No implementation is triggered by accepting this design.

**Passport binding gap is correctly identified and managed:** The single implementation blocker — that the existing Add.igapp passport targets `igniter.delegated.experimental.ivm.c_resident` while the R240 Rust VM is `igniter.delegated.experimental.vm.rust-tokio.v0` — is precisely identified in both C1-D and C2-P1. The proposed resolution (a bounded VM capability/passport hardening proof) is correct. Compiler passport emission correctly stays closed; the hardening proof produces proof-local binding metadata only.

**Selector architecture is sound:** The two-level design (`delegated-experimental:igniter-vm-candidate` as user-facing string; `runtime_implementation_id` as machine-readable evidence field) correctly separates the unstable pre-v1 CLI appearance from the internal evidence tracing. This is consistent with the Slice 0 precedent where `delegated-experimental:ivm-proof` was the CLI selector, not the proof runtime path.

**Loop tests in vm_candidate_proof_tests.rs:** The grep confirms `test_proof_vmg13_local_loops_and_service_loops` exists in `vm_candidate_proof_tests.rs` (lines 237-345), testing loop array summation, OOF-L-FUEL fuel exhaustion, and tick.time service loops. C2-P1 section 6 describes these as "Active Lab Verification Evidence" — but the R240 summary.json is the authoritative proof record, and it contains no loop entries in VMG-1..VMG-15. The loop tests were added within the authorized `playgrounds/igniter-lab/igniter-vm/**` write scope, and C1-D correctly classifies loop/recursion as "pressure input only; excluded from Slice 1 scope." However, C2-P1 section 6's phrasing ("Active Lab Verification Evidence") is slightly stronger than "pressure input only." AN-1 clarifies this for C4-A.

**Runtime Specification stance is well-calibrated:** C1-D correctly frames Runtime Specification as "a check surface" that becomes a blocker only if hardening finds selector/failure-code/capability specification gaps. This is the right sequencing — spec input does not block design, but may redirect implementation authorization if unresolved semantic questions emerge.

**Recursion/loops correctly excluded:** C1-D boundary matrix: "Pressure input only; excluded from Slice 1." C2-P1 gap matrix: "Excluded from Slice 1 scope." Both consistent with keeping Slice 1 bounded to the R240 VMG accepted evidence envelope.

---

## Explicit Answers

| Question | Answer |
| --- | --- |
| PASS / CONDITIONAL PASS / HOLD / REDIRECT? | PASS with 2 non-blocking acceptance notes |
| Exact blockers? | None. The passport binding gap is a prerequisite for implementation authorization, not a design blocker. |
| Should C4-A accept the design boundary? | Yes. |
| Next route? | VM capability/passport hardening proof authorization review (S3-R242-C1-A per C1-D). |
| Implementation authorization? | Held until hardening proof closes. |
| Runtime Specification input? | Conditional redirect if hardening reveals selector/failure-code/capability specification blockers. |
| `.igbin` output_contract design? | Separate future route; not on the Slice 1 critical path. |
| TBackend wording sidecar? | Lab-internal; not on the Slice 1 critical path. |
| igc run Slice 1 implementation closed? | Yes. Design accepted, implementation held. |
| All public/runtime/reference/stable/performance/portability claims closed? | Yes. |

---

## Non-Blocking Acceptance Notes

**AN-1 — Loop test phrasing in C2-P1 section 6 must not be treated as R240 accepted proof evidence.**

C2-P1 section 6 calls the loop tests in `vm_candidate_proof_tests.rs` "Active Lab Verification Evidence" — this is technically accurate (they pass locally) but the phrasing is stronger than C1-D's "pressure input only." The R240 summary.json is the authoritative proof record; it contains VMG-1..VMG-15 only and has no loop evidence entries.

C4-A acceptance record should note:

```text
The loop/recursion tests added to vm_candidate_proof_tests.rs are lab-local
additions beyond the R240 authorized VMG-1..VMG-15 proof scope. They are
pressure input only per C1-D, not accepted Slice 1 evidence. The R240
summary.json is the authoritative proof record. Slice 1 implementation must
fail-closed if loop/recursion constructs are encountered in contract input.
```

**AN-2 — `runtime_implementation_id` must not become the primary CLI selector.**

C1-D correctly states `runtime_implementation_id: igniter.delegated.experimental.vm.rust-tokio.v0` "should not be the primary user-facing CLI selector, because it looks more stable than the current pre-v1 evidence allows." The user-facing CLI selector is `delegated-experimental:igniter-vm-candidate`.

C4-A acceptance record should name this explicitly so that the implementation authorization review (when it opens) cannot conflate them:

```text
CLI selector (user-facing, pre-v1, unstable): delegated-experimental:igniter-vm-candidate
Proof-local metadata (evidence-facing, not CLI): igniter.delegated.experimental.vm.rust-tokio.v0
The runtime_implementation_id appears only in machine-readable result packets
and passport metadata, not as a user-typed CLI argument.
```

---

## Verdict

```text
PASS with 2 non-blocking acceptance notes

C1-D Slice 1 VM candidate design boundary: accept
C2-P1 current surface and VM candidate facts: accept as accurate facts basis
Implementation authorization: HELD pending hardening proof
C4-A HOLD: release; proceed to acceptance and open hardening authorization
```

---

## Recommendation for S3-R241-C4-A

```text
Card: S3-R241-C4-A (final acceptance)
Route: UPDATE
Mode: accept design boundary / route hardening proof next

Accept:
- C1-D Slice 1 VM candidate design boundary
- C2-P1 current surface facts as accurate facts basis
- Slice 1 design boundary: delegated-experimental:igniter-vm-candidate selector
- Passport binding gap correctly identified (ivm.c_resident vs vm.rust-tokio.v0)
- Implementation authorization held pending VM capability/passport hardening proof

Note for acceptance record (AN-1):
  Loop/recursion tests in vm_candidate_proof_tests.rs are lab pressure input only.
  R240 summary.json (VMG-1..VMG-15) is the authoritative proof record.
  Slice 1 must fail-closed if loop/recursion constructs are encountered.

Note for acceptance record (AN-2):
  CLI selector: delegated-experimental:igniter-vm-candidate (user-facing, pre-v1)
  runtime_implementation_id: igniter.delegated.experimental.vm.rust-tokio.v0
  (evidence-facing metadata only; not the user-typed CLI argument)

Open next:
  Card: S3-R242-C1-A
  Track: experimental-igc-run-slice1-vm-capability-passport-hardening-
         authorization-review-v0
  Goal: Bounded proof-local VM capability/passport hardening proof producing
        evidence-only binding manifest for igniter.delegated.experimental.vm.rust-tokio.v0

Conditional redirect after hardening:
  If hardening finds selector/failure-code/capability specification blockers
  that require normative rules → redirect to Runtime Specification input slice
  before implementation authorization opens.

Keep closed:
- igc run Slice 1 implementation (design accepted; implementation held)
- .igbin execution
- compiler passport emission
- RuntimeSmoke productization
- Reference Runtime
- public runtime / stable API / production / Spark / release claims
- recursion/loop support (pressure input only; excluded from Slice 1)
- reactive/tbackend daemon execution
```
