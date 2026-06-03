# Experimental Igniter VM Candidate Intake Pressure v0

Card: S3-R239-C3-X
Skill: IDD Agent Protocol
Agent: [External Pressure Reviewer]
Role: external-pressure-reviewer
Track: experimental-igniter-vm-candidate-intake-pressure-v0
Route: REVIEW
Status: complete
Date: 2026-06-03

Depends on:
- S3-R239-C1-A
- S3-R239-C2-P1

---

## Inputs Read

- `igniter-lang/docs/tracks/experimental-igniter-vm-candidate-intake-authorization-review-v0.md` (C1-A)
- `igniter-lang/docs/tracks/experimental-igniter-vm-candidate-surface-facts-v0.md` (C2-P1)
- `igniter-lang/docs/tracks/stage3-round238-status-curation-v0.md`
- `igniter-lang/docs/tracks/experimental-stdlib-candidate-proof-acceptance-decision-v0.md`
- `playgrounds/igniter-lab/igniter-vm/src/lib.rs`, `vm.rs`, `tbackend.rs` (wording scan)
- `playgrounds/igniter-lab/igniter-vm/tests/reactive_tests.rs` (daemon path verification)
- `cargo test --test vm_tests` (12/12 PASS independently re-verified)

---

## Compact Risk Matrix

| Risk | Assessment | C1-A / C2-P1 fence | Residual |
| --- | --- | --- | --- |
| VM candidate over-promoted to runtime authority | Very low | C2-P1 authority classification: "Non-canonical sandbox prototype"; explicit non-claims for Reference Runtime, public runtime, stable API, production, portability | Very low |
| Stdlib dependency cited as authority rather than dependency context | Very low | C2-P1 correctly cites R238 as "path dependency context only"; evidence classification table separates "accepted dependency evidence from R238" from "VM candidate evidence" | Very low |
| "tamper-evidence" phrasing in C2-P1 section 4 implies security authority | Low | Section 4 says observation IDs "ensur[e] tamper-evidence"; evidence table correctly says "Prototype audit trail; no security or cryptographic signature claims"; SHA256 use is hash-based trace ID only | Low — see AN-1 |
| Non-selected branch silence not explicitly proven | Low | `test_aot_compiler_lowering` covers `if_expr` compilation and branching; non-selected branch *silence* is not a dedicated test check; comparable to R226 AIP-7/8 gap level | Low — see AN-2 |
| Reactive tests / tbackend daemon absolute path leaks into evidence | Very low | G-4 correctly identified; `reactive_tests.rs` excluded from authorized command matrix; "Unrun (Daemon required)" in support matrix; absolute path is lab-only | Very low |
| Adjacent frontier/conformance artifacts included | Zero | C2-P1 explicit: "All adjacent artifacts under conformance/ or polymorphic_traits_proof/ were excluded"; C1-A exclusion reproduced in answers | Zero |
| igc run Slice 1 prematurely opened | Zero | C2-P1: "Widening the mainline igc compiler tool to support runtime execution remains held"; not referenced as next route | Zero |
| Public/stable/production/Reference Runtime/Spark/release/performance claims | Zero | C1-A and C2-P1 close all; non_claims list in C4-A recommendation; closed-surface scan table all No | Zero |
| Closed surfaces (lib/**, bin/igc, gemspec, README, RuntimeSmoke) changed | Zero | C2-P1 closed-surface table: all "No"; confirmed by source inspection | Zero |

---

## Pressure-Test Findings

**VM candidate evidence quality:** Strong. 12/12 `vm_tests.rs` checks cover Decimal math delegation, AOT compiler lowering, `if_expr` conditional branching, map-reduce aggregation, high-concurrency stress (10-task tokio), and bitemporal `OP_LOAD_AS_OF`. This is a richer test surface than required for a facts-packet intake.

**Stdlib dependency chain:** The dependency is confirmed by two independent sources — `Cargo.toml` (source read) and the test coverage in `test_decimal_addition_success` etc. (command confirmed). The VM's `OP_ADD/SUB/MUL/DIV` operations delegate to `igniter_stdlib::decimal::Decimal`, correctly grounding the VM evidence in the accepted R238 proof-local stdlib evidence. C2-P1 citation is accurate and bounded.

**Lazy branch / selected-branch evidence:** The AOT compiler for `if_expr` emits `OP_JMP_UNLESS` → then-body → `OP_JMP` → else-body with backpatched jump targets. `test_aot_compiler_lowering` confirms this lowering exists. However, C2-P1 does not include a test that explicitly proves the non-selected branch does not execute when the condition is false (the R226 standard for "verified_silent"). The proof-local VM proof card should include this as an explicit required check.

**Passive wording risks (low severity):** Three source comments use "Premium, high-performance" phrasing. These are in source code only, not in exported strings, CLI output, or public documentation. Correctly classified as low severity by C2-P1. No escalation needed.

**"tamper-evidence" in C2-P1 section 4:** The document states observation IDs ensure "tamper-evidence" when describing the SHA256 hash used for `observation_id`. The actual implementation is: `sha256_hex(&format!("{}-{}", store, coordinate_value))[..16]` — a hex-truncated hash for tracing, not a signature. The evidence classification table in C2-P1 correctly says "no security or cryptographic signature claims." The wording in section 4 is technically imprecise but not propagated into any result packet, public surface, or claim. AN-1 below carries this forward for the proof card scope.

**Artifact passport / capability metadata gaps:** G-1 (no `runtime_implementation_id` in crate), G-2 (no passport manifest), G-3 (no lib unit tests) are correctly identified. These are the standard intake gaps that a proof-local proof card should resolve by emitting a summary JSON with the required fields. This is the same pattern as R225/R228/R230.

**Reactive tests / tbackend daemon:** G-4 (absolute machine path `/Users/alex/dev/projects/igniter/...` in `reactive_tests.rs`) is correctly identified and correctly excluded from the authorized command matrix. The surface classification is "Playground test only; starts servers and uses local ports." The facts packet does not promote this surface. No propagation risk.

---

## Explicit Answers

| Question | Answer |
| --- | --- |
| Is the facts packet sufficient for C4-A decision? | Yes. The facts packet provides accurate classification of the VM surface, correctly identifies all four structural gaps, cites R238 stdlib evidence as dependency context only, excludes reactive/conformance adjacents, and confirms 12/12 tests via re-verified command. |
| Should `igniter-vm` be accepted as candidate evidence? | Yes. The crate demonstrates a functional execution architecture with verified Decimal delegation, AOT compiler lowering, branch semantics, and map-reduce support — sufficient for candidate intake. |
| May a proof-local VM proof authorization review open next? | Yes. The 12-test baseline provides enough foundation. The proof card should resolve G-1 (runtime_implementation_id), G-2 (passport manifest), G-3 (lib unit tests), and add an explicit non-selected branch silence check (AN-2). |
| Should `igc run` Slice 1 remain held? | Yes. C2-P1 does not open or suggest Slice 1. |
| Did any public/runtime/reference/stable/production/performance claim leak? | No. All claims closed. One low-severity wording watchpoint (AN-1) for the proof card scope. |
| Do all closed surfaces remain closed? | Yes. Confirmed by C2-P1 closed-surface scan and source inspection. |

---

## Verdict

```text
PASS with two non-blocking conditions

C2-P1 igniter-vm candidate intake facts packet: accept
C4-A HOLD: release; proceed to final acceptance decision

No blockers.
AN-1 and AN-2 are acceptance conditions for the NEXT authorization review
(proof-local VM proof card), not blockers for accepting the facts packet now.
```

---

## Acceptance Conditions (for next proof card authorization, not C4-A blockers)

**AN-1 — "tamper-evidence" phrasing in C2-P1 section 4 must not propagate to proof card output.**

C2-P1 section 4 describes the observation ID as "ensuring tamper-evidence." The evidence/authority classification correctly says "no security or cryptographic signature claims." However, the SHA256 use is a hash-based trace identifier (first 8 bytes of SHA256 hex of `"{store}-{coordinate_value}"`), not a digital signature or security mechanism.

When the proof-local VM proof card produces a summary JSON, it must describe observation IDs as:

```text
hash-based trace identifier
proof-local observation trace only
not a digital signature
not tamper-evident in a security sense
not a security authority claim
not a cryptographic audit chain
```

**AN-2 — Proof card must include explicit non-selected-branch silence check.**

`test_aot_compiler_lowering` covers `if_expr` compilation and branching. It does not separately prove that the non-selected branch is silent (i.e., that it does not execute, does not emit observations, and does not modify state). This is the R226 AIP-7 / R228 AOT-8 standard.

The proof-local VM proof card should include as a required proof matrix item:

```text
VMG-N: When condition is false, non-selected (then) branch does not execute
        and emits no observations to the observation sink.
```

This brings the VM proof to parity with the R226/R228 IVM proof standard for lazy branch correctness.

---

## Recommendation for S3-R239-C4-A

```text
Card: S3-R239-C4-A (final acceptance)
Route: UPDATE
Mode: accept candidate intake facts / open proof card next

Accept:
- C2-P1 igniter-vm candidate intake facts packet
- Provisional runtime_implementation_id:
    igniter.delegated.experimental.vm.rust-tokio.v0 (evidence metadata only)
- evidence_class: delegated_experimental_vm_candidate_evidence
- 12/12 vm_tests.rs as baseline candidate evidence
- Stdlib dependency on R238 accepted proof (dependency context only)

Gaps accepted as known:
- G-1: no runtime_implementation_id in crate (to be resolved by proof card)
- G-2: no passport manifest (to be resolved by proof card)
- G-3: no lib unit tests (to be resolved by proof card)
- G-4: reactive_tests excluded (tbackend daemon dependency)

Open next:
  Proof-local VM proof authorization review
  Track: experimental-igniter-vm-candidate-proof-authorization-review-v0

Required scope for proof card (include in C1-A boundary):
  AN-1: observation IDs must be labeled hash-based trace identifiers;
        no "tamper-evident", "cryptographic", or "security authority" language
        in result packet output
  AN-2: non-selected-branch silence must be a required proof matrix item
        (explicit check: false-condition → then-branch does not execute /
         emits no observations to observation sink)

Keep closed:
- igc run Slice 1
- Reference Runtime
- public runtime support
- stable API / production / Spark / release
- RuntimeSmoke productization
- public performance claims
- portability or certification guarantees
- all lib/** / bin/igc / gemspec / README changes
```
