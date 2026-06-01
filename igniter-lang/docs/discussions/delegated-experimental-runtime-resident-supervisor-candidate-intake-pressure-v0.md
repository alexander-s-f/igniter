# Delegated Experimental Runtime Resident Supervisor Candidate Intake Pressure v0

Card: S3-R230-C3-X
Skill: IDD Agent Protocol
Agent: [External Pressure Reviewer]
Role: external-pressure-reviewer
Track: delegated-experimental-runtime-resident-supervisor-candidate-intake-pressure-v0
Route: REVIEW
Status: complete
Date: 2026-06-01

Depends on:
- S3-R230-C1-A
- S3-R230-C2-I

---

## Inputs Read

- `igniter-lang/docs/tracks/delegated-experimental-runtime-resident-supervisor-candidate-intake-authorization-review-v0.md` (C1-A)
- `igniter-lang/docs/tracks/delegated-experimental-runtime-resident-supervisor-candidate-intake-v0.md` (C2-I)
- `playgrounds/igniter-runtime/out/resident_supervisor_candidate_intake/summary.json` (verified)
- `igniter-lang/docs/tracks/stage3-round229-status-curation-v0.md`
- `igniter-lang/docs/tracks/experimental-runtime-implementations-and-portability-boundary-decision-v0.md`

Mainline git status: clean — no tracked files modified outside playground.

Playground output directory confirmed: `if_module.igbin`, `bad_magic.igbin`,
`truncated.igbin`, `unsupported_module.igbin`, `librunner.dylib`, `summary.json`.

---

## Verified Intake State

From summary JSON and track doc:

```text
runtime_implementation_id:  igniter.delegated.experimental.ivm.c_resident
evidence_class:             resident-supervisor candidate intake evidence only
implementation_class:       delegated.experimental.runtime

Resident lifecycle proven:
  load_module(filepath, error_code) → LoadedModule*  once
  execute_module(module, inputs, error_code) → int32  N times
  free_module(module) → void  exercised

Parity (Ruby IVM oracle vs resident supervisor):
  flag=true:  42=42  ✓
  flag=false: 99=99  ✓ (non-selected branch silent)

Load-once / execute-many: native file 0.4689s → native resident 0.0296s
  → I/O bottleneck eliminated (consistent with structural design)

Malformed fail-closed:
  bad magic → NULL + error 11  ✓ (bad_magic.igbin fixture)
  truncated → NULL + error 14  ✓ (truncated.igbin fixture)

Unsupported selected-path: opcode 0x99 → error 3, result -1  ✓

free_module: Fiddle call exercised  ✓

Accepted evidence (R225-R228): all four confirmed PASS / immutable
Separate routes (C temporal, Rust TBackend, ESP32, todolist): all HELD  ✓
Closed surface scan: PASS
Non-claims: PASS

checks: 16/16 PASS
```

---

## Risk Matrix

| Risk | Probability | Severity | Fence | Residual |
| --- | --- | --- | --- | --- |
| runtime_implementation_id becomes stable API or package identity | Very low | High | JSON `authority_status: "non-canonical / evidence-only"`; non_claims array; C1-A explicit: "evidence metadata only, not stable API, not package identity" | Very low |
| load-once / execute-many not actually proven (asserted only) | Very low | High | RSUP-5 PASS; structural: `LoadedModule*` obtained once, `execute_module` called N times; timing confirms (0.0296s resident vs 0.4689s file I/O) — if file I/O were repeated, resident timing would match file timing | Very low |
| Lazy branch semantics not verified via resident path | Very low | High | RSUP-8 PASS: "non-selected branches structurally jumped over and remain silent"; `if_module.igbin` fixture present; flag=true→42 and flag=false→99 parity confirmed | Very low |
| Malformed module behavior silently passes | Very low | High | RSUP-10 PASS; real fixture files (`bad_magic.igbin`, `truncated.igbin`) confirmed in output; error codes 11/14 tested | Very low |
| free_module memory lifecycle not exercised | Very low | Medium | RSUP-11 PASS; "Called memory release Fiddle function on loaded module pointer"; capability manifest has `memory_lifecycle: "manual_free_via_free_module"` | Very low |
| Performance wording promotes public speedup claims | Low | High | RSUP-12 PASS; `performance_policy.public_speedup_claim: "none"`; [!CAUTION] block present; however, prose uses assertive framing for 15.6x/1.6x numbers | Low — see AN-1 |
| C temporal backend / Rust TBackend / ESP32 / todolist auto-authorized | Zero | High | RSUP-14 PASS; `unsupported_features` JSON array names all four; Section 7 explicitly holds each as separate route | Zero |
| lib/**, bin/igc, gemspec, README, public docs changed | Zero | Critical | RSUP-15 PASS; mainline git clean; `closed_surface_scan: "PASS"` | Zero |
| R225-R228 evidence mutated | Zero | Critical | RSUP-13 PASS; `accepted_evidence_immutability` all four PASS; R228 summary JSON unchanged | Zero |
| public/stable/production/Spark/release claims | Zero | Critical | RSUP-16 PASS; `non_claims: "PASS"`; 7 non-claim strings in capability manifest | Zero |

---

## Scope-Check Matrix

| Check | Evidence | Finding | Safe? |
| --- | --- | --- | --- |
| Proof stayed inside authorized write scope | RSUP-15 PASS; mainline git clean; playground output: intake fixtures + summary.json + librunner.dylib only | Scope matches C1-A authorization. | ✅ PASS |
| runtime_implementation_id is evidence metadata only | RSUP-2 PASS; JSON `authority_status: "non-canonical / evidence-only"`; 7-item `non_claims` array | Required status labels present and machine-readable. | ✅ PASS |
| Capability manifest sufficient for intake | RSUP-3 PASS; all 21 C1-A required fields present in machine-readable JSON: runtime_implementation_id through authority_status; temporal_backend_kind: "none / excluded"; supports_temporal_read: false | Complete. Machine-readable. | ✅ PASS |
| Load-once / execute-many actually proven | RSUP-4/5 PASS; `execution_model: "load_once_execute_many"`; structural: pointer obtained once, execute_module called N times; timing delta (0.47s file vs 0.03s resident) confirms I/O bottleneck elimination | Proven by structure and timing confirmation. | ✅ PASS |
| Ruby IVM parity and lazy branch semantics proven | RSUP-6/7 PASS: 42=42 and 99=99; RSUP-8 PASS: non-selected branch silent; `if_module.igbin` fixture on disk; `supports_if_expr_lazy_branching: true` | Both parity and lazy semantics verified through resident path. | ✅ PASS |
| Malformed module behavior fails closed | RSUP-10 PASS; real fixture files (`bad_magic.igbin`: error 11, `truncated.igbin`: error 14); `failure_behavior: "fail_closed_on_malformed_input"` | Real fixtures, not asserted. Two distinct error cases proven. | ✅ PASS |
| Memory lifecycle / free_module proven or explicitly limited | RSUP-11 PASS; `free_module` Fiddle call exercised; `memory_lifecycle: "manual_free_via_free_module"`; C1-A policy: "no claim of production memory safety" — compliant | Exercised and honestly labeled as proof-local C lifecycle evidence only. | ✅ PASS |
| Performance numbers contained as informational-only | RSUP-12 PASS; `performance_policy.label: "informational research-signal / proof-local timing only"`; `public_speedup_claim: "none"`; [!CAUTION] block in track doc | JSON containment is correct. See AN-1 for minor prose framing note. | ✅ PASS (see AN-1) |
| C temporal backend / Rust TBackend / ESP32 / todolist remain separate | RSUP-14 PASS; `unsupported_features` array names all four; Section 7 holds each explicitly | Boundary quarantine maintained. | ✅ PASS |
| Mainline closed surfaces stayed closed | RSUP-15 PASS; git clean; `closed_surface_scan: "PASS"` | Confirmed. | ✅ PASS |

---

## Explicit Answers

| Question | Answer |
| --- | --- |
| PASS / CONDITIONAL / HOLD? | PASS |
| Can C4-A accept the intake proof? | Yes. 16/16 RSUP checks pass. Machine-readable capability manifest complete. Load-once/execute-many proven structurally and by timing. All closed surfaces confirmed. |
| Does any proof matrix item require repair? | No. All 16 RSUP checks are PASS with real fixture files and observable evidence. |
| Does performance wording need cleanup? | Minor: see AN-1. Not a blocker. [!CAUTION] block provides correct containment; prose could use inline "rough" qualifiers for consistency with prior rounds. |
| What next route should C4-A choose? | Artifact passport minimum boundary design next (C1-D preferred ordering, C2-I recommendation, R229-C3-X recommendation all agree). igc run design-only after passport. C temporal backend intake as a separate subsequent route. |

---

## Non-Blocking Acceptance Note

**AN-1 — Timing prose in Section 6 is assertive without inline "rough" qualifiers.**

Section 6 states: "Moving from disk-backed execution to resident native supervisor execution speeds up native timeline iterations by **15.6x**, successfully eliminating the disk I/O bottleneck. In-memory native execution runs approximately **1.6x faster** than the Ruby interpreter loop, validating that bypassing interpreter instruction decoding overhead scales rule execution."

The [!CAUTION] block correctly precedes these numbers and the JSON `public_speedup_claim: "none"` is present. However, prior rounds (R227, R228) consistently labeled measurements inline with `rough_speedup_x` / `rough_speed_ratio` field names and "rough comparison" prose qualifiers. The assertive prose "validating that...scales rule execution" is stronger framing than "informational research signal."

C4-A's acceptance record should note: the 15.6x and 1.6x figures are informational/proof-local timing only, consistent with the RSUP-12 policy. Future intake track docs should apply inline "rough" or "informational-only" qualifiers on the numbers themselves, not only in the CAUTION block header.

This does not block acceptance. RSUP-12 PASS is correct.

---

## Verdict

```text
PASS

C2-I Resident Supervisor Candidate Intake: 16/16 RSUP PASS — accept
evidence_label: resident_supervisor_candidate_intake (binding)
runtime_implementation_id: igniter.delegated.experimental.ivm.c_resident (evidence metadata only)
No blockers
1 non-blocking acceptance note (AN-1: timing prose should use inline rough/
  informational qualifiers in addition to the CAUTION block header)
C4-A HOLD: release; proceed to final acceptance decision
```

---

## Recommendation for S3-R230-C4-A

```text
Card: S3-R230-C4-A (final acceptance)
Route: UPDATE
Mode: final acceptance decision

Accept:
- C2-I Resident Supervisor Candidate Intake (16/16 RSUP PASS)
- runtime_implementation_id: igniter.delegated.experimental.ivm.c_resident
  (evidence metadata only — not stable API, not package identity)
- evidence_class: "resident-supervisor candidate intake evidence only" (binding)
- Capability manifest as machine-readable candidate profile
- Load-once / execute-many proven structurally and by timing delta
- Ruby IVM parity: flag=true→42, flag=false→99 (lazy branch verified)
- Malformed fail-closed: bad magic→error11, truncated→error14 (real fixtures)
- free_module: exercised as proof-local C lifecycle only

Note for acceptance record (AN-1):
  15.6x and 1.6x timing observations are informational/research-signal only
  per RSUP-12 and performance_policy JSON. Future track docs should apply
  inline "rough" qualifiers on the numbers, not only in the CAUTION block.

Open next:
  experimental-runtime-artifact-passport-minimum-boundary-v0
  (C1-D preferred ordering, C2-I recommendation, R229-C3-X recommendation)

After artifact passport:
  experimental igc run design-only route

Separate subsequent route:
  C temporal backend candidate intake (separate authorization required)
  Rust TBackend candidate intake (separate authorization required)

Keep closed:
- igc run implementation
- Reference Runtime implementation
- RuntimeSmoke productization
- lib/** changes
- public runtime / stable API / production / Spark / release claims
- C temporal backend authority (not accepted by this intake)
- Rust TBackend authority (not accepted by this intake)
- ESP32/mesh (comparison-only research)
- artifact portability or certification claims
```
