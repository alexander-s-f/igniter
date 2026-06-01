# Experimental Runtime Implementations And Portability Boundary Pressure v0

Card: S3-R229-C3-X
Skill: IDD Agent Protocol
Agent: [External Pressure Reviewer]
Role: external-pressure-reviewer
Track: experimental-runtime-implementations-and-portability-boundary-pressure-v0
Route: REVIEW
Status: complete
Date: 2026-06-01

Depends on:
- S3-R229-C1-D
- S3-R229-C2-P1

---

## Inputs Read

- `igniter-lang/docs/tracks/experimental-runtime-implementations-and-portability-boundary-design-v0.md` (C1-D)
- `igniter-lang/docs/tracks/experimental-runtime-implementation-surface-and-candidate-facts-v0.md` (C2-P1)
- `igniter-lang/docs/tracks/stage3-round228-status-curation-v0.md`
- `igniter-lang/docs/tracks/experimental-runtime-implementation-status-model-v0.md`

---

## Risk Matrix

| Risk | Probability | Severity | C1-D / C2-P1 fence | Residual |
| --- | --- | --- | --- | --- |
| Delegated runtime evidence promoted to public/Reference Runtime authority | Very low | Critical | Status model Rule 2: "A proof does not authorize mainline code, package, CLI, runtime, report, release, or public claims by itself"; C1-D: "they remain unaccepted playground/sandbox material until separate intake/decision"; both documents maintain consistent evidence-class non-promotion | Very low |
| `igc run` opened prematurely from this design | Very low | High | C1-D: "igc run remains closed to implementation"; three-gate requirement (intake → passport → design-only) before implementation; C2-P1: "Attempting to implement `igc run` now will couple CLI to unstable, delegated runtime structures" | Very low |
| Resident supervisor / C temporal backend / Rust TBackend auto-authorized by being classified | Very low | High | All three explicitly "Sandbox candidate / needs intake" in status model; C1-D "Observed but not yet accepted by Main Line"; separate intake required for each | Very low |
| ESP32/mesh creates embedded/portability claim | Very low | High | Status model: "Speculative sandbox research"; C1-D route matrix: "comparison-only until runtime portability exists"; C2-P1: "Marketing Embedded IoT rule execution creates unrealistic hardware support expectations" | Very low |
| Performance numbers from C2-P1 Section 3B used as public claims | Low | High | C2-P1 Section 7 [!CAUTION] explicitly warns against publishing "1.5 million timeline evaluations per second" or "15.6x speedups over Ruby" as official claims; C1-D does not reproduce these numbers | Low — see AN-1 |
| Artifact passport 22-field list is too heavy and blocks intake | Low | Medium | C1-D: "Passport work does not need to block candidate intake"; optional later fields include certification items that are clearly future; passport design runs in parallel with first intake | Very low |
| Runtime_implementation_id naming becomes stable API | Very low | Medium | C1-D: "evidence metadata only / not stable API / not package identity / not certification identity" | Very low |
| Next route continues infinite playground research rather than TTEU progress | Low | Medium | C1-D's preferred ordering (intake → passport → igc run design) is market-aware and forward-moving; intake directly answers the R228 load-once/execute-many question | Very low |
| Reference Runtime, public runtime, production, Spark, release claims | Zero | Critical | Both documents maintain comprehensive non-claims; "closed" designation consistent with every round since R225 | Zero |

---

## Scope-Check Matrix

| Check | Evidence | Finding | Safe? |
| --- | --- | --- | --- |
| Implementation hierarchy vocabulary is precise enough | Status model defines 4 tiers (Specification → Official Reference → Delegated Experimental → Alternative Certified Later) with distinct authority levels; C1-D reproduces and extends the model; C2-P1 maps 6 specific candidates against it correctly | Vocabulary is well-defined. Each tier has explicit "current status" and "design stance" sections. The boundary between "delegated experimental" and "alternative certified" is explicit and gated. | ✅ SAFE |
| Delegated runtimes remain evidence-only | Status model Rule 2 explicitly stated; C1-D: "Accepted as implementation arena / evidence-producing / non-canonical / not public runtime support"; C2-P1: "All accepted evidence remains non-canonical and non-authoritative" | Non-promotion is stated as a rule, not just a disclaimer. Multiple layers of repetition across both documents. | ✅ SAFE |
| Official/Reference/public runtime authority stays closed | C1-D "Explicit Answers": "Does Reference Runtime remain closed? Yes. Do public runtime claims remain closed? Yes."; status model: "Reference Runtime support remains closed"; C2-P1 Section 4: "Mainline Code Location: None" for every playground candidate | Closure is consistent and unambiguous. | ✅ SAFE |
| Resident supervisor / C temporal backend / Rust TBackend / ESP32 classified correctly | Status model: resident supervisor → "sandbox candidate / needs intake"; C temporal backend → "sandbox candidate / needs intake"; Rust TBackend → "delegated storage/backend candidate / needs intake"; ESP32/mesh → "speculative sandbox research"; C1-D route matrix differentiates intake risk accurately (resident supervisor: medium, C temporal backend: high for temporal authority, Rust TBackend: medium, ESP32: comparison-only) | Differentiation is correct and well-reasoned. The authority-risk ranking (temporal backend > resident supervisor) reflects the actual risk landscape. | ✅ SAFE |
| Artifact passport fields are sufficient (not too heavy, not too vague) | C1-D minimum passport: 22 required + 7 optional later fields; C2-P1 simpler 5-field implied minimum (spec_version, artifact_format_version, compiled_by, required_capabilities, target_profile); C1-D: "Passport work does not need to block candidate intake" | The 22-field list is a design target, not an immediate implementation requirement. Optional certification fields are clearly labeled "later." C2-P1's 5-field subset is not a contradiction — it's the proof-implied minimum. The full design serves artifact portability design, not intake gating. | ✅ SAFE |
| `igc run` wording is safe | C1-D: "igc run remains closed to implementation"; design-only route conditioned on 6 specific prerequisites (syntax sketch, runtime id selection, artifact passport requirements, capability manifest, non-claim wording, closed implementation boundary); no next card should implement igc run yet | Closure is specific and conditional. No ambiguity about implementation timing. | ✅ SAFE |
| Next route moves toward experimental use (not process drift) | C1-D preferred ordering: resident supervisor intake → artifact passport minimum → experimental igc run design-only; rationale ties each step to a concrete market/runtime question; C2-P1 agrees on passport before igc run (not before intake); the intake directly answers the R228 load-once/execute-many bottleneck | Sequencing is market-aware. No premature specification work before the next concrete runtime question is answered. | ✅ SAFE |
| Public performance and portability claims blocked | C2-P1 Section 7 [!CAUTION] explicitly blocks "1.5M QPS," "15.6x speedups," "15x faster" as public claims; status model Rule 5: portability requires future artifact passport; C1-D: "no current artifact is portable merely because it ran in one runtime" | Blocked at two independent layers. | ✅ SAFE (see AN-1) |

---

## C1-D Assessment: Boundary Design

**Finding: safe to accept.**

The design introduces three important artifacts that the round was missing:

1. **Implementation hierarchy vocabulary** — the four-tier model (Specification → Reference → Delegated → Certified Later) provides a shared routing language that prevents repeated boundary reconstruction. Future intake cards can reference these tiers instead of arguing from first principles.

2. **Candidate intake policy with differentiated risk** — the route matrix correctly ranks resident supervisor (medium risk, high value) above C temporal backend (high risk, temporal authority), above Rust TBackend, above ESP32/mesh (comparison-only). The authority-risk differentiation is sound and will prevent authority creep when specific intake cards open.

3. **igc run gating** — "syntax sketch, runtime id, artifact passport requirements, capability manifest, non-claim wording, closed implementation boundary" as prerequisites before any igc run design-only route is the right set of gates.

The C1-D / C2-P1 sequencing divergence is not a real conflict: both documents agree passport must precede igc run implementation; only the ordering of passport vs intake is open, and C1-D correctly identifies they can run in parallel.

**C1-D verdict: accept.**

---

## C2-P1 Assessment: Surface and Candidate Facts

**Finding: safe to accept as facts basis.**

C2-P1 is source-grounded: reads cli.rb, compiler_orchestrator.rb, assembler.rb, runtime_smoke.rb, compiler_result.rb, compilation_report.rb, playground sources, and Rust Cargo.toml. The 6-row candidate matrix correctly classifies each candidate with implementation class, evidence status, and mainline access rules.

The execution/storage decoupling diagram (Section 6) is architecturally accurate and useful: it illustrates why the temporal backend and execution supervisor should have separate intake cards (they have separate authority implications).

Section 7 [!CAUTION] correctly identifies that "1.5 million timeline evaluations per second" and "15.6x speedups over Ruby" from the C temporal backend playground are synthetic, context-specific measurements that must not become public claims. This is the right containment for those numbers.

**C2-P1 verdict: accept as facts basis, with one acceptance note (AN-1).**

---

## Explicit Answers

| Question | Answer |
| --- | --- |
| PASS / CONDITIONAL / HOLD? | PASS |
| Can C4-A accept the design? | Yes. Accept implementation arena vocabulary, delegated runtime naming, intake policy, artifact passport minimum, and igc run gating. |
| Should any route be blocked? | No new routes need to be blocked. Resident supervisor intake may open next. |
| Should next route favor `igc run` design, candidate intake, helper/productization, Runtime Specification, or hold? | Resident supervisor candidate intake next (C1-D preferred). Artifact passport minimum in parallel or immediately after. igc run design-only after both. Runtime Specification input slice may open as a parallel track later. Hold is wrong given market pressure. |

---

## Non-Blocking Acceptance Note

**AN-1 — C2-P1 Section 3B contains specific performance numbers from unaccepted sandbox candidates.**

Section 3B reports: "1.56M iterations/sec (15.2x faster than repeated disk loads and 2.0x faster than the Ruby VM)" for the resident supervisor, and "1.5 million timeline evaluations per second (15.6x faster than pure Ruby FFI callbacks)" for the C temporal backend.

These numbers are correctly confined to the "Unaccepted Sandbox Candidates" section of C2-P1 and are explicitly warned against in Section 7 [!CAUTION]. However, they appear as facts in a Main Line track doc.

C4-A's acceptance record should explicitly state:

```text
Accepting C2-P1 as a facts packet does not accept these performance numbers
as evidence for public wording, Main Line performance claims, or candidate
intake status. They are in-playground sandbox measurements only. They must not
appear in public docs, release notes, experimental use wording, or any
candidate intake authorization review without explicit re-contextualization
under research-signal / informational-only / proof-local-timing labels.
```

This prevents a future intake author from lifting the numbers from C2-P1 and using them in an intake track doc without recontextualization.

---

## Verdict

```text
PASS

C1-D Implementation Arena Boundary Design: accept
C2-P1 Surface and Candidate Facts: accept as facts basis
C4-A HOLD: release; proceed to final acceptance decision
```

No blockers. 1 non-blocking acceptance note (AN-1: C2-P1 performance numbers must not become public claims when accepted).

---

## Recommendation for S3-R229-C4-A

```text
Card: S3-R229-C4-A (final acceptance)
Route: UPDATE
Mode: final acceptance decision

Accept:
- C1-D implementation arena / portability boundary design
- Status model 4-tier hierarchy as routing vocabulary (binding)
- Candidate intake policy with differentiated risk ordering
- igc run three-gate requirement (intake → passport → design-only) as binding
- C2-P1 surface and candidate facts as facts basis

Note for acceptance record (AN-1):
  Performance numbers in C2-P1 Section 3B (1.56M iter/s, 15.2x, 2.0x, 1.5M
  eval/s, 15.6x) are in-playground sandbox measurements only. They are NOT
  accepted as evidence for public wording, Main Line performance claims, or
  candidate intake authorization. Any intake track doc that cites these numbers
  must re-contextualize them as informational/research-signal only.

Open next (preferred ordering from C1-D):
  1. Resident supervisor candidate intake authorization review
     (resident supervisor directly answers R228 load-once/execute-many)
  2. Artifact passport minimum boundary design (parallel or immediately after)
  3. Experimental igc run design-only (after both above complete)
  4. Runtime Specification input slice (parallel track, lower urgency)

Keep closed:
- igc run implementation
- Reference Runtime implementation
- RuntimeSmoke productization
- lib/** changes
- public runtime / stable API / production / Spark / release claims
- public performance claims
- ESP32/mesh promotion beyond comparison-only research
- C temporal backend and Rust TBackend before dedicated intake
```
