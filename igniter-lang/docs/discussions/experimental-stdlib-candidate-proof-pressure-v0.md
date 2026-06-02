# Experimental Stdlib Candidate Proof Pressure v0

Card: S3-R238-C3-X
Skill: IDD Agent Protocol
Agent: [External Pressure Reviewer]
Role: external-pressure-reviewer
Track: experimental-stdlib-candidate-proof-pressure-v0
Route: REVIEW
Status: PASS
Date: 2026-06-02

Depends on:
- S3-R238-C1-A
- S3-R238-C2-I

---

## Authority Notice

This is a read-only pressure document. It does not authorize code edits,
mainline stdlib replacement, public stdlib API, runtime/API/CLI/package changes,
`igc run` widening, compiler passport emission, RuntimeSmoke productization,
Reference Runtime support, public runtime support, stable API, production
readiness, Spark integration, release evidence, public performance claims,
official/reference status, alternative certification, or portability guarantees.

---

## Verdict

```text
PASS
```

The C2-I proof is complete, within scope, and addresses all three mandatory
C-1/C-2/C-3 conditions from R237-C3-X. STD-P1..STD-P12 are all satisfied with
machine-readable evidence. No authority leakage found. No closed-surface
violations found. Two minor labeling issues noted as advisory — neither blocks
C4-A acceptance.

---

## Inputs Read

```text
igniter-lang/docs/cards/S3/S3-R238.md
igniter-lang/docs/tracks/
  experimental-stdlib-candidate-proof-authorization-review-v0.md   (C1-A)
igniter-lang/docs/tracks/
  experimental-stdlib-candidate-proof-v0.md                        (C2-I track)
playgrounds/igniter-lab/igniter-stdlib/out/
  stdlib_candidate_proof/summary.json                              (C2-I evidence packet)
playgrounds/igniter-lab/igniter-stdlib/proofs/
  stdlib_candidate_proof.rb                                        (proof script header)
playgrounds/igniter-lab/igniter-stdlib/verify_stdlib.rb            (scope header)
igniter-lang/docs/tracks/stage3-round237-status-curation-v0.md
igniter-lang/docs/tracks/
  experimental-stdlib-candidate-intake-decision-v0.md
igniter-lang/docs/discussions/
  experimental-stdlib-candidate-pressure-v0.md                     (R237-C3-X)
```

No code was edited. No verifier was re-run in this pressure review.

---

## Risk Matrix

| Risk ID | Surface | Risk | Severity | Disposition |
|---------|---------|------|----------|-------------|
| R-A | `decimal_division_policy.rounding_documented` JSON field | Field is `false`, meaning "no rounding policy exists in source." A reader skimming JSON keys without reading the `note` field could misread this as "the rounding-policy caveat was not documented." The note and STD-P4 proof check both clarify correctly. | **LOW** | Advisory for C4-A: cite STD-P4.rounding_policy_documented PASS, not the raw JSON field. |
| R-B | `temporal.ig` `non_current_syntax` array contains a prose note | Fifth entry is `"Module comment 'bitemporal' is misleading (see STD-P7)"` — prose mixed with syntax declarations. Structural inconsistency. No impact on classification correctness. | **LOW** | Advisory: a future cleanup should separate `naming_warnings` from `non_current_syntax` entries in this array. |
| R-C | `igniter_vm_dependency_readiness.readiness: "ready"` label | Correct observation: the path dependency exists. A fast reader might infer "VM intake is authorized," which is not the case. The `vm_intake_opened: false` and note field explicitly contradict this. | **LOW** | C4-A must not cite `readiness: "ready"` without quoting the note. VM intake remains held until C4-A closes. |

No HIGH or MEDIUM risks found.

All three risks from R237-C3-X (R-1 temporal naming, R-2 verifier scope gap,
R-3 .ig grammar) are resolved in C2-I.

---

## Authorization-Boundary Compliance

Write scope authorized by C1-A:

```text
playgrounds/igniter-lab/igniter-stdlib/**
igniter-lang/docs/tracks/experimental-stdlib-candidate-proof-v0.md
```

Changed files per C2-I:

```text
playgrounds/igniter-lab/igniter-stdlib/proofs/stdlib_candidate_proof.rb    — new
playgrounds/igniter-lab/igniter-stdlib/out/stdlib_candidate_proof/
  summary.json                                                              — new
playgrounds/igniter-lab/igniter-stdlib/verify_stdlib.rb                    — header only
igniter-lang/docs/tracks/experimental-stdlib-candidate-proof-v0.md        — new
```

Boundary check: **PASS — all 4 changed files are within authorized perimeter.**

---

## Closed-Surface Scan

| Path | Authorized? | Changed? | Verdict |
|------|------------|----------|---------|
| `igniter-lang/lib/**` | closed | No | CLEAN |
| `igniter-lang/bin/igc` | closed | No | CLEAN |
| `igniter-lang/igniter_lang.gemspec` | closed | No | CLEAN |
| `igniter-lang/README.md` | closed | No | CLEAN |
| `igniter-lang/docs/README.md` | closed | No | CLEAN |
| `igniter-lang/docs/ruby-api.md` | closed | No | CLEAN |
| `igniter-lang/lib/igniter_lang/runtime_smoke.rb` | closed | No | CLEAN |
| `igniter-lang/lib/igniter_lang/compiler_result.rb` | closed | No | CLEAN |
| `igniter-lang/lib/igniter_lang/compilation_report.rb` | closed | No | CLEAN |
| `playgrounds/igniter-lab/igniter-vm/**` | read-only | No | CLEAN |
| `playgrounds/igniter-lab/igniter-runtime/**` | closed | No | CLEAN |
| `playgrounds/igniter-lab/igniter-compiler/**` | closed | No | CLEAN |

**All 12 closed surfaces: untouched. No authority leakage via file writes.**

---

## Command Matrix Review

| Command | Result | Verdict |
|---------|--------|---------|
| `ruby verify_stdlib.rb` | 17/17 PASS (14 Decimal FFI + 3 file presence) | PASS |
| `cargo test --manifest-path Cargo.toml` | 0 tests defined; build ok; exit 0 | PASS (Gap G-1 pre-existing, documented) |
| `ruby proofs/stdlib_candidate_proof.rb` | 30/30 PASS | PASS |

All three required commands from C1-A and C2-I were run. Results are consistent
with proof matrix claims in both track doc and summary.json.

---

## STD-P1..STD-P12 Review

| Check | Status | Pressure Finding |
|-------|--------|-----------------|
| STD-P1 Decimal FFI add/sub/mul/div | PASS | Confirmed: rc=0, val/scale correct for all 4 ops. Scale rule (S1+S2 for mul, S1-S2 for div) verified. |
| STD-P2 OOF-TC5 scale mismatch | PASS | rc=1 for both add and sub scale mismatch — matches error code contract. |
| STD-P3 OOF-DM2 division failure | PASS | rc=2 for div-by-zero and S1<S2 — both cases confirmed. |
| STD-P4 Decimal division truncation documented | PASS | i64/i64 truncation toward zero confirmed (7÷3→2). No rounding mode. See R-A (labeling advisory only). |
| STD-P5 Verifier scope narrowed | PASS | verify_stdlib.rb header block now explicitly states Collections/Temporal NOT tested. Exit string labeled lab-assertion style. R-2 from R237-C3-X resolved. |
| STD-P6 Collections internal Rust-only | PASS | `ffi_exported: false`, `verifier_tested: false`, `verifier_coverage: "file_presence_only"`. Intake authority: none. |
| STD-P7 Temporal domain-specific only | PASS | classification: domain_specific_scheduling_example. All bitemporal non-coverage items listed. R-1 from R237-C3-X resolved. |
| STD-P8 .ig signatures design-pressure only | PASS | All 3 files: `parseable_by_igc: false`, `classification: design_pressure_only`. Non-current syntax enumerated per file. R-3 from R237-C3-X resolved. |
| STD-P9 runtime_implementation_id / evidence class / non_claims | PASS | runtime_implementation_id: `igniter.delegated.experimental.stdlib.rust-cdylib.v0`. evidence_class: `proof_local_stdlib_candidate_evidence`. All 5 authority_status values present. 13 non_claims machine-readable, matching C1-A required list exactly. |
| STD-P10 igniter-vm dependency readiness | PASS | Path dep confirmed: `igniter_stdlib = { path = "../igniter-stdlib" }`. VM not edited. VM intake not opened. See R-C (labeling advisory for C4-A citation). |
| STD-P11 No mainline changes | PASS | igniter-lang/lib, bin/igc, gemspec, README, ruby-api: untouched. igniter-vm: untouched. |
| STD-P12 Public claims remain closed | PASS | 13 machine-readable non_claims. Authority notice in proof script header, verify_stdlib.rb header, and track doc. |

**All 30 sub-checks: PASS. No failures.**

---

## Explicit Answers

**Whether proof output stays proof-local candidate evidence only:**

```text
Yes. All generated output (summary.json, proof script, track doc) is classified
proof_local_stdlib_candidate_evidence throughout. Authority notices are present
in all three artifacts. No public, runtime, or API authority was created.
```

**Whether verifier overclaim risk is resolved or still present:**

```text
Resolved. The verify_stdlib.rb header now contains an explicit scope block:
  - Decimal FFI correctness: 14 assertions
  - Signature file presence: 3 assertions
  - Collections correctness: NOT tested by this script
  - Temporal correctness: NOT tested by this script
The exit string is labeled as lab-assertion style. R-2 from R237-C3-X is closed.
```

**Whether temporal bitemporal overclaim risk is resolved or still present:**

```text
Resolved. The temporal module is classified domain_specific_scheduling_example.
The not_covered list explicitly enumerates History[T], BiHistory[T], as_of,
valid_time, transaction_time, PROP-022_temporal_semantics, PROP-028_bitemporal_semantics,
and TemporalCtx. intake_authority: none. R-1 from R237-C3-X is closed.
```

**Whether `.ig` signatures remain design-pressure only:**

```text
Yes. All three files (math.ig, collections.ig, temporal.ig) are classified
design_pressure_only with parseable_by_igc: false. Non-current syntax is
enumerated per file. R-3 from R237-C3-X is closed.
```

**Whether collections remain correctly scoped:**

```text
Yes. Collections are classified internal_rust_only with ffi_exported: false
and verifier_tested: false. intake_authority: none — internal candidate
evidence only. No FFI-accessible or verifier-confirmed claim was made.
```

**Whether VM intake can be recommended next or must remain held:**

```text
VM intake CAN be recommended as the next sequenced route after C4-A closes
R238. The path dependency is confirmed. VM intake was not opened by C2-I.
The structural sequencing precondition (stdlib candidate proof accepted) will
be satisfied when C4-A accepts. C4-A must still explicitly authorize the
VM intake route — this pressure review only clears the sequencing precondition.
```

**Whether any mainline/public/runtime authority leaked:**

```text
No. Zero closed-surface violations. Zero public claim assertions. All 13
machine-readable non_claims present. Proof stayed entirely within the
authorized lab perimeter.
```

**Strongest C4-A recommendation:**

```text
Accept the proof-local stdlib candidate evidence unconditionally.
Record C-1/C-2/C-3 conditions as satisfied.
Route igniter-vm candidate intake as the next Main Line step.
All other holds (igc run Slice 1, TBackend) remain in place.
```

---

## Mandatory Conditions from R237-C3-X — Status

| Condition | Required | C2-I Response | Verdict |
|-----------|----------|---------------|---------|
| C-1: Temporal scoped as domain-specific, not bitemporal stdlib | Yes | `classification: domain_specific_scheduling_example`; not_covered list complete; `intake_authority: none` | SATISFIED |
| C-2: Verifier scope bounded in any intake citation | Yes | verify_stdlib.rb header updated; exact scope block present; exit string labeled; STD-P5 PASS recorded | SATISFIED |
| C-3: .ig signatures design-pressure only, not accepted Igniter source | Yes | All 3 files: `design_pressure_only`, `parseable_by_igc: false`, non-current syntax listed | SATISFIED |

**All three R237-C3-X mandatory conditions: SATISFIED.**

---

## Advisory (non-blocking)

1. **R-A: `rounding_documented` field name ambiguity** — `decimal_division_policy.rounding_documented: false`
   means "no rounding policy defined in source," not "this caveat was not documented." C4-A should cite
   STD-P4.rounding_policy_documented PASS directly, not the raw JSON boolean.

2. **R-B: `temporal.ig` non_current_syntax prose mixing** — The fifth entry in `temporal.ig`'s
   `non_current_syntax` array is a prose naming warning rather than a syntax type. Non-structural;
   recommend separating `naming_warnings` from `non_current_syntax` in a future cleanup.

3. **R-C: `readiness: "ready"` label in VM section** — Correctly states path dependency exists.
   C4-A must not cite this as VM intake authorization — quote `vm_intake_opened: false` and the
   note explicitly.

---

## Exact C4-A Recommendation

```text
Verdict: PASS (unconditional)

Accept:
  proof-local stdlib candidate evidence as produced by S3-R238-C2-I
  All STD-P1..STD-P12 checks: 30/30 PASS
  Mandatory C-1/C-2/C-3 conditions from R237-C3-X: all SATISFIED

Record explicitly:
  runtime_implementation_id: igniter.delegated.experimental.stdlib.rust-cdylib.v0
  evidence_class: proof_local_stdlib_candidate_evidence
  authority_status: non_canonical, candidate_only, proof_local,
                    no_public_api_authority, no_runtime_authority
  non_claims: 13 machine-readable entries (see summary.json)
  C-1 temporal: domain-specific scheduling example only; not general bitemporal
  C-2 verifier scope: Decimal FFI (14) + file presence (3); collections/temporal
                      NOT tested; exit string is lab-assertion style
  C-3 .ig signatures: design-pressure only; not parseable by igc; not accepted
                      Igniter source; not stdlib API surface

Advisory notes for acceptance record:
  cite STD-P4.rounding_policy_documented PASS, not rounding_documented JSON field
  vm_intake_opened: false; readiness label does not imply VM intake authorization

Next route:
  Open igniter-vm candidate intake authorization review
  (stdlib proof boundary closes when C4-A accepts — VM intake sequencing
  precondition is now satisfied)

Hold:
  igc run Slice 1
  TBackend intake pending wording hardening

Closed:
  mainline stdlib replacement
  public stdlib API
  runtime/API/CLI/package changes
  igc run widening
  .igbin execution
  compiler passport emission
  RuntimeSmoke productization
  public runtime / Reference Runtime / stable API / production
  Spark / release / public performance / official / certification / portability
```
