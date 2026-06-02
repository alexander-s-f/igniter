# Experimental Runtime Artifact Passport Manifest Proof Pressure v0

Card: S3-R232-C3-X
Skill: IDD Agent Protocol
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Track: experimental-runtime-artifact-passport-manifest-proof-pressure-v0
Route: REVIEW
Status: complete
Date: 2026-06-02

Depends on:
- S3-R232-C1-A
- S3-R232-C2-I

---

## Inputs Read

- `igniter-lang/docs/tracks/experimental-runtime-artifact-passport-manifest-proof-authorization-review-v0.md` (C1-A)
- `igniter-lang/docs/tracks/experimental-runtime-artifact-passport-manifest-proof-v0.md` (C2-I)
- `igniter-lang/experiments/experimental_runtime_artifact_passport_manifest_v0/out/summary.json` (verified)
- Four generated passport manifest JSON files (spot-checked via Python)
- `igniter-lang/docs/tracks/stage3-round231-status-curation-v0.md`
- `igniter-lang/docs/tracks/experimental-runtime-artifact-passport-minimum-boundary-decision-v0.md`

Mainline git status: clean (no lib/**, bin, gemspec, README, or public doc modifications).

Five output files confirmed under `experiments/experimental_runtime_artifact_passport_manifest_v0/out/`.

---

## Verified Proof State

```text
overall: PASS  (16/16 PPM checks)
generated manifests:
  Add.igapp.passport.json            → igapp_dir
  add.igbin.aot.passport.json        → igbin_aot_binary / c_aot_file_loader
  if_module.igbin.resident.passport.json → igbin_aot_binary / c_resident_in_memory_module
  quickstart_result.evidence_packet.passport.json → evidence_result_packet

source_artifacts_immutability: PASS  (16 digests recorded)
  semantic_ir_program.json: sha256:264b0b40...  (matches R225)
  quickstart_result.json:   sha256:666952db...  (matches R223)
  add.igbin:                sha256:40df5461...  (matches R228)

forbidden_wording_scan: PASS  (0 hits)
closed_surface_scan: PASS
non_claims: 11 entries, machine-readable, all 4 manifests confirmed

igbin_aot_binary canonical kind: used correctly
no igbin_file value emitted
```

---

## Risk Matrix

| Risk | Probability | Severity | Fence | Residual |
| --- | --- | --- | --- | --- |
| `igbin_file` value used instead of `igbin_aot_binary` | Zero | High | PPM-3 PASS; spot check confirms both `.igbin` manifests use `igbin_aot_binary`; PPM-14 forbidden scan clean | Zero |
| Source artifacts (.igapp, .igbin, result JSON) mutated | Zero | Critical | PPM-15 PASS; 16 specific file digests recorded in summary; key digests cross-match R225/R228/R223 known values | Zero |
| Compiler provenance invented for hand-authored .igbin fixtures | Zero | High | PPM-7 PASS; `source_digest: null`, `semantic_ir_digest: null` for all .igbin fixtures; explicit "not invented" in track doc | Zero |
| Forbidden portability/certification wording in manifests | Zero | High | PPM-14 PASS; scanner output: `hits: []` for all 5 forbidden terms including "portable artifact" and "certified alternative implementation" | Zero |
| `runtime_target_kind` absent from `evidence_result_packet` manifest | Low | Low | C1-A: "for executable runtime artifacts" — conditional language; evidence_packet is not a runtime-targeted artifact; PPM-1 PASS; defensible but exception not documented in self-check | Low — watchpoint W-1 |
| `output_contract` deferred for `.igbin` passports permits igc run claim | Very low | Medium | PPM-12 PASS; deferred rationale explicit: "Required before any future igc run design can claim complete executable contract"; igc run design-only is NOT igc run implementation; C1-A: implementation closed | Very low |
| igc run implementation opened from this proof | Very low | High | C2-I: "implementation remains closed"; non_claims: "not igc run implementation" in all 4 manifests; PPM-16 PASS | Very low |
| Rust TBackend / acts-as-tbackend / todolist auto-authorized | Zero | High | Track doc Section "Separate later intakes remain held" explicit for all three; non_claims covers these; PPM-8 PASS | Zero |
| Public/stable/production/Spark/release/performance claims | Zero | Critical | 11-item non_claims array in all manifests; `evidence_boundary` JSON: all claims set to "none" | Zero |

---

## Scope-Check Matrix

| Check | Evidence | Finding | Safe? |
| --- | --- | --- | --- |
| Proof stayed inside authorized write scope | PPM-16 PASS; closed_surface_scan confirms lib, bin, gemspec, README, playgrounds/igniter-lab all unchecked; out dir scoped to `experiments/experimental_runtime_artifact_passport_manifest_v0/out`; mainline git clean | Scope matches C1-A authorization exactly. | ✅ PASS |
| Source artifacts immutable | PPM-15 PASS; 16 digests in `source_artifacts_immutability`; spot cross-match: semantic_ir_program.json `264b0b40...` (= R225 verified), quickstart_result.json `666952db...` (= R223), add.igbin `40df5461...` (= R228) | All major source digests traceable to prior accepted evidence. | ✅ PASS |
| Required field families complete for all manifests | PPM-1 PASS; Python spot check: all three runtime-targeted manifests: `missing=none`; evidence_result_packet: `runtime_target_kind` absent (see W-1) | Complete for runtime-targeted artifacts. Evidence packet exception needs documentation. | ✅ PASS (see W-1) |
| `igbin_aot_binary` canonical kind, no `igbin_file` | PPM-3 PASS; spot check: add.igbin.aot.passport.json → `igbin_aot_binary`, if_module.igbin.resident.passport.json → `igbin_aot_binary` | Canonical kind used correctly. No `igbin_file` emitted. | ✅ PASS |
| `.igapp`, SemanticIR, `.igbin`, result packets not conflated | PPM-2/3 PASS; four manifests have four distinct artifact_kind values; SemanticIR is linked via digest fields, not as a separate manifest kind | Artifact taxonomy is clean. No conflation. | ✅ PASS |
| Digest recomputation deterministic and honest | PPM-4/5/6 PASS; source_digest carried from compiler manifest (read-only provenance); semantic_ir_digest recomputed over actual file; artifact_digest deterministic over sorted directory tree; .igbin source/semantic nil — "not invented" | Digest chain is honest and traceable. | ✅ PASS |
| `execution_substrate` included or explicitly deferred | PPM-10 PASS; spot check: all four manifests explicit — `ruby_delegated_example_local_harness`, `c_aot_file_loader`, `c_resident_in_memory_module`, `none` | No silent omission. | ✅ PASS |
| `output_contract` stance sufficient | PPM-12 PASS; Add.igapp: derived from SemanticIR outputs `[{sum: Integer}]`; .igbin: explicitly deferred with "Required before any future igc run design..." note; evidence_result_packet: has outputs block with sum=42 | Deferred with correct rationale. The note gates igc run design appropriately. | ✅ PASS |
| `non_claims` machine-readable | PPM-13 PASS; 11-item array in all 4 manifests; Python confirms `igc_run_closed: True` for all; includes "not compiler passport emission" and "not igc run implementation" | Machine-readable and comprehensive. | ✅ PASS |
| Forbidden wording scan | PPM-14 PASS; `hits: []` for 5 forbidden terms; scanner correctly strips "not <phrase>" negations | Clean. | ✅ PASS |

---

## Explicit Answers

| Question | Answer |
| --- | --- |
| Can proof output be accepted as proof-local passport manifest evidence only? | Yes. `evidence_only: true`, `portability_claim: "none"`, `certification_claim: "none"`, `stable_api_claim: "none"` all in evidence_boundary JSON. |
| Is any field missing or ambiguous? | One watchpoint (W-1): `runtime_target_kind` absent from `evidence_result_packet` manifest. Defensible per C1-A conditional "for executable runtime artifacts." Not a blocker — see W-1. |
| Do any public/stable/production/performance wording leaks exist? | No. Forbidden wording scan PASS. 11-item non_claims array. No hits. |
| May next route be igc run design-only? | Yes — C1-A condition met: "proof-local passport manifest exists." igc run design-only route may open. Implementation remains closed. Must note `output_contract` deferred for .igbin in the design scope. |
| Should Runtime Specification, Rust TBackend intake, or another route be preferred over igc run design-only? | igc run design-only is the logical next step per C1-A, C1-D R229 preferred ordering, and C2-I recommendation. Rust TBackend and Runtime Specification remain valid parallel tracks but do not block igc run design-only. |

---

## Watchpoint

**W-1 — `runtime_target_kind` absent from `evidence_result_packet` manifest; PPM-1 PASS not qualified.**

Python spot check found `runtime_target_kind` missing from `quickstart_result.evidence_packet.passport.json`. C1-A states this field is required "for executable runtime artifacts." The `evidence_result_packet` has `surface_dimension: evidence_packet`, not `executable_runtime`, so the absence is defensible.

However, C2-I's PPM-1 PASS self-report does not document this exception. A reader comparing the "all required field families" claim against the actual manifest would find an unexplained gap.

C4-A's acceptance record should note: for `surface_dimension: evidence_packet`, `runtime_target_kind` is treated as contextually not-applicable and its absence does not constitute a PPM-1 failure. Future passport schema versions should formalize this conditional through a `not_applicable` placeholder rather than silent absence.

This is a watchpoint, not a blocker. The proof is clean and the reasoning is sound.

---

## Verdict

```text
PASS

C2-I Artifact Passport Manifest Proof: 16/16 PPM PASS — accept
evidence_class: proof-local passport manifest evidence only (binding)
No blockers
1 watchpoint (W-1: runtime_target_kind absent from evidence_result_packet;
  defensible but PPM-1 self-report should document the exception)
C4-A HOLD: release; proceed to final acceptance decision
```

---

## Recommendation for S3-R232-C4-A

```text
Card: S3-R232-C4-A (final acceptance)
Route: UPDATE
Mode: final acceptance decision

Accept:
- C2-I Artifact Passport Manifest Proof (16/16 PPM PASS)
- Four generated passport manifests as proof-local evidence/compatibility
  metadata only
- Canonical artifact kind igbin_aot_binary (binding)
- Digest chain: source_digest→semantic_ir_digest→artifact_digest for igapp_dir
  (hand-authored .igbin chains nil source/SemanticIR, not invented)
- execution_substrate: present in all four manifests
- output_contract: derived for igapp_dir; explicitly deferred for .igbin
  with "Required before any future igc run design" gate note (binding)
- non_claims: 11-item machine-readable array in all manifests (binding)

Note for acceptance record (W-1):
  For surface_dimension: evidence_packet, runtime_target_kind is contextually
  not-applicable and its absence is accepted for this proof. Future schema
  versions should use an explicit not_applicable placeholder.

C1-A condition met: one proof-local passport manifest now exists.

Open next (igc run design-only, not implementation):
  experimental-igc-run-design-only-boundary-v0 or equivalent
  Subject to: output_contract deferred for .igbin must be noted as an open
  design gap in the igc run design scope.

Keep separate (later intake when ready):
  Rust TBackend temporal_backend candidate intake
  acts-as-tbackend app_consumer_bridge intake
  todolist app-consumer product intake
  Runtime Specification input slice (may open in parallel)

Keep closed:
- igc run implementation (design-only route only)
- compiler passport emission
- lib/** changes
- Reference Runtime implementation
- public runtime / stable API / production / Spark / release claims
- public performance claims
- artifact portability or certification claims
```
