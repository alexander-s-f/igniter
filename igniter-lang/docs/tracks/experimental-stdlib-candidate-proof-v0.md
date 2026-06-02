# Experimental Stdlib Candidate Proof v0

Card: S3-R238-C2-I
Skill: IDD Agent Protocol
Agent: [Implementation Agent]
Role: implementation-agent
Track: experimental-stdlib-candidate-proof-v0
Route: IMPLEMENT
Status: done / PASS
Date: 2026-06-02

Depends on:
- S3-R238-C1-A

---

## Authority Notice

This proof produces proof-local stdlib candidate evidence only.
It does not authorize mainline stdlib replacement, public stdlib API,
runtime/API/CLI/package changes, `igc run` widening, `.igbin` execution,
compiler passport emission, RuntimeSmoke productization, Reference Runtime
support, public runtime support, stable API, production readiness, Spark
integration, release execution, public performance claims, official/reference
status, alternative certification, or portability guarantees.

All generated output is proof-local stdlib candidate evidence only.

---

## [D] Decision — Proof Result

**STD-P1..STD-P12: 30/30 PASS. Zero failures.**

All required proof matrix checks pass. The evidence packet is complete.

The accepted Decimal FFI surface is confirmed. The mandatory C-1/C-2/C-3
scope conditions from R237-C3-X are satisfied by the proof packet. The
verifier scope header has been narrowed to eliminate the exit-string
ambiguity risk identified in R237. The summary.json is machine-readable.

Recommended next route: acceptance decision (C3-X pressure or C4-A).

---

## [S] Summary

```text
Proof script:   playgrounds/igniter-lab/igniter-stdlib/proofs/stdlib_candidate_proof.rb
Summary JSON:   playgrounds/igniter-lab/igniter-stdlib/out/stdlib_candidate_proof/summary.json
Checks:         30 PASS / 0 FAIL / 30 total
Overall:        PASS

runtime_implementation_id: igniter.delegated.experimental.stdlib.rust-cdylib.v0
evidence_class:             proof_local_stdlib_candidate_evidence
authority_status:           non_canonical / candidate_only / proof_local /
                            no_public_api_authority / no_runtime_authority
```

---

## [T] Technical Proof Results

### Command Matrix

| Command | Result | Exit code |
|---------|--------|-----------|
| `ruby verify_stdlib.rb` | 17/17 PASS (14 Decimal FFI + 3 file presence) | 0 |
| `cargo test --manifest-path Cargo.toml` | 0 tests defined; build ok | 0 |
| `ruby proofs/stdlib_candidate_proof.rb` | 30/30 PASS | 0 |

### Proof Matrix: STD-P1..STD-P12

| Check ID | Status | Detail |
|----------|--------|--------|
| **STD-P1** | **PASS** | Decimal FFI add/sub/mul/div behavior confirmed |
| STD-P1.add.normal | PASS | 10.50+25.25: rc=0 val=3575 scale=2 |
| STD-P1.sub.normal | PASS | 35.75−10.50: rc=0 val=2525 scale=2 |
| STD-P1.mul.scale_sum | PASS | 10.5×2.5: val=2625 scale=2 (S1+S2) |
| STD-P1.div.normal | PASS | 26.25÷2.5: rc=0 val=105 scale=1 (S1−S2) |
| **STD-P2** | **PASS** | OOF-TC5 scale mismatch behavior confirmed |
| STD-P2.add.scale_mismatch | PASS | add Decimal[2]+Decimal[1]: rc=1 (OOF-TC5) |
| STD-P2.sub.scale_mismatch | PASS | sub Decimal[2]−Decimal[1]: rc=1 (OOF-TC5) |
| **STD-P3** | **PASS** | OOF-DM2 division failure behavior confirmed |
| STD-P3.div.zero | PASS | div by zero: rc=2 (OOF-DM2) |
| STD-P3.div.negative_scale | PASS | div S1<S2: rc=2 (OOF-DM2) |
| **STD-P4** | **PASS** | Decimal division truncation and rounding policy documented |
| STD-P4.div.truncation | PASS | 7÷3 → val=2 scale=0 (i64/i64, truncates toward zero) |
| STD-P4.rounding_policy_documented | PASS | No rounding mode defined; documented in packet |
| **STD-P5** | **PASS** | Verifier scope narrowed — exact assertion set recorded |
| STD-P5.verifier_scope_recorded | PASS | Decimal FFI (14 assertions) + file presence (3); collections/temporal NOT tested |
| **STD-P6** | **PASS** | Collections classified as internal Rust-only |
| STD-P6.collections_classified | PASS | range/filter/map/fold/first/count: internal Rust-only; not FFI-exported; not verifier-tested |
| STD-P6.collections_not_ffi | PASS | No C ABI export; Rust closures only |
| **STD-P7** | **PASS** | Temporal classified as domain-specific scheduling helper only |
| STD-P7.temporal_classified | PASS | domain-specific slot scheduling; not general bitemporal stdlib |
| STD-P7.no_bitemporal_semantics | PASS | no as_of / History[T] / BiHistory[T] / valid_time / transaction_time in implementation |
| STD-P7.naming_mismatch_documented | PASS | `stdlib.Temporal` name and "bitemporal" comment are misleading — documented as gap |
| **STD-P8** | **PASS** | .ig signatures classified as design-pressure and non-current syntax |
| STD-P8.math.ig.present | PASS | present; classification=design_pressure_only; non-current grammar |
| STD-P8.collections.ig.present | PASS | present; classification=design_pressure_only; non-current grammar |
| STD-P8.temporal.ig.present | PASS | present; classification=design_pressure_only; non-current grammar |
| STD-P8.not_accepted_source | PASS | stdlib/*.ig: design-pressure only; not parseable by igc |
| **STD-P9** | **PASS** | runtime_implementation_id, evidence class, authority status, non_claims present |
| STD-P9.runtime_implementation_id | PASS | `igniter.delegated.experimental.stdlib.rust-cdylib.v0` |
| STD-P9.evidence_class | PASS | `proof_local_stdlib_candidate_evidence` |
| STD-P9.authority_status | PASS | non_canonical / candidate_only / proof_local / no_public_api / no_runtime |
| STD-P9.non_claims | PASS | 13 non_claims recorded (machine-readable) |
| **STD-P10** | **PASS** | igniter-vm dependency readiness observed; VM intake not opened |
| STD-P10.vm_dep_confirmed | PASS | `igniter_stdlib = { path = "../igniter-stdlib" }` in igniter-vm/Cargo.toml |
| STD-P10.vm_intake_not_opened | PASS | igniter-vm not edited; VM intake not opened |
| **STD-P11** | **PASS** | No mainline stdlib/runtime/API/CLI/package/RuntimeSmoke/report changes |
| STD-P11.mainline_unchanged | PASS | igniter-lang/lib/**, bin/igc, gemspec, README, ruby-api: not edited |
| STD-P11.igniter_vm_not_edited | PASS | playgrounds/igniter-lab/igniter-vm/**: not edited |
| **STD-P12** | **PASS** | Public/stable/production/reference/performance/portability claims closed |
| STD-P12.no_public_claims | PASS | all closed |
| STD-P12.non_claims_enforced | PASS | 13 machine-readable non_claims in summary.json |

---

## Decimal FFI Evidence

### Confirmed behavior

| Operation | Scale rule | Normal result | Failure (OOF code) |
|-----------|-----------|---------------|-------------------|
| `stdlib_decimal_add` | requires S_a == S_b | val=a+b, scale=S | rc=1 on mismatch (OOF-TC5) |
| `stdlib_decimal_sub` | requires S_a == S_b | val=a−b, scale=S | rc=1 on mismatch (OOF-TC5) |
| `stdlib_decimal_mul` | result scale = S1+S2 | val=a×b, scale=S1+S2 | infallible |
| `stdlib_decimal_div` | result scale = S1−S2 | val=a÷b (truncated), scale=S1−S2 | rc=2 on zero or S1<S2 (OOF-DM2) |

### Division truncation policy (STD-P4)

```text
Implementation: self.value / other.value  (i64 / i64)
Truncation:     toward zero
Rounding:       none — no rounding mode defined or configurable
Financial use:  do not use for contexts requiring HALF_UP, HALF_EVEN, or
                explicit rounding without additional wrapper
Confirmed:      7.00 / 3.00 → 2 (not 2.33...) — val=2 scale=0
```

### Helpers not FFI-exported

```text
Decimal::to_f64:    self.value as f64 / 10f64.powi(scale)
                    — imprecise for large value or scale; utility display only
Decimal::from_f64:  (val * factor).round() as i64
                    — uses floating-point intermediary; not authoritative conversion
```

---

## Verifier Scope (STD-P5)

Original exit string: `"🏆 ALL STANDARD LIBRARY CORRECTNESS AND LINKABILITY TESTS PASSED SUCCESSFULLY!"`

Scope correction applied in this proof:

| Module | Correctness tested | FFI linkage tested | File presence tested |
|--------|-------------------|--------------------|---------------------|
| Decimal | Yes (14 assertions) | Yes (Fiddle bind + execution) | — |
| Collections | **No** | **No** | Yes (1 assertion: stdlib/collections.ig) |
| Temporal | **No** | **No** | Yes (1 assertion: stdlib/temporal.ig) |

**Authoritative scope:** Decimal FFI correctness (14 assertions) + signature
file presence (3 assertions) = 17 total.

The verifier header has been updated in `verify_stdlib.rb` to document this
scope explicitly. The exit string is now labeled as lab-assertion style in the
header comment. No assertion logic was changed.

---

## Collections Classification (STD-P6)

```text
classification:          internal_rust_only
ffi_exported:            false
verifier_tested:         false (file presence only)
rust_api:                range, filter, map, fold, first, count
accessible_to_igniter_vm: yes (via Rust path dependency)
accessible_to_ruby:      no (no C ABI export)
prop013_coverage:        present in Rust source; unverified behavior
intake_authority:        none — internal candidate evidence only
```

---

## Temporal Classification (STD-P7)

```text
classification:          domain_specific_scheduling_example
module_name_in_source:   stdlib.Temporal
source_comment:          "High-performance bitemporal metrics and snapshot transformations"
actual_implementation:
  compute_availability:  reads geo_signals + schedule.day_off/working_hours;
                         produces [{hour: N, status: "available"|"blocked"}] array
  build_snapshot:        counts available slots; produces summary JSON
not_covered:
  - History[T], BiHistory[T], as_of, valid_time, transaction_time
  - PROP-022/PROP-028 bitemporal semantics
  - TemporalCtx
naming_risk:             "stdlib.Temporal" and "bitemporal" comment are misleading
intake_authority:        none — domain-specific scheduling example only
```

---

## .ig Signature Classification (STD-P8)

```text
classification:    design_pressure_only
parseable_by_igc:  false (non-current grammar throughout)
```

| File | Non-current syntax |
|------|--------------------|
| `stdlib/math.ig` | `Decimal[S]` (parametric scale), type variables `S`, `S1`, `S2`, type arithmetic `S1+S2`/`S1-S2` |
| `stdlib/collections.ig` | `Collection[T]`, `(T) -> Bool`, `(T) -> U`, `(U, T) -> U`, `Option[T]` |
| `stdlib/temporal.ig` | `GeoSignal`, `ScheduleFact`, `TimeSlot`, `AvailabilitySnapshot` (undefined types); "bitemporal" comment misleading |

Intake value: PROP-013 design pressure and API-shape discussion only.
Not accepted Igniter source. Not accepted stdlib API surface.

---

## igniter-vm Dependency Readiness (STD-P10)

```text
igniter-vm/Cargo.toml:  read-only observation
dependency line:        igniter_stdlib = { path = "../igniter-stdlib" }
dep_type:               path_dependency
dep_confirmed:          true
vm_intake_opened:       false — VM intake not opened by this proof
readiness:              ready to sequence as next-after-stdlib intake
```

VM intake should open only after a C4-A acceptance of this stdlib
candidate proof closes the R238 round.

---

## Gap Register

| Gap | Severity | Addressed in this proof |
|-----|----------|------------------------|
| G-1: No Rust unit tests | medium | partially — FFI proof covers Decimal; Rust-level tests still absent |
| G-2: Collections not FFI-exported | medium | documented in STD-P6 |
| G-3: Temporal module is domain-specific, not general bitemporal | high (wording) | documented in STD-P7 |
| G-4: .ig signature types are non-current grammar | medium | documented in STD-P8 |
| G-5: runtime_implementation_id absent from source | low | supplied as evidence metadata in summary.json |
| G-6: No evidence class or non_claims in source | low | supplied in summary.json |
| G-7: Decimal division truncates; no rounding policy documented | medium | confirmed and documented in STD-P4 |
| G-8: to_f64 is imprecise; utility only | low | documented in Decimal FFI section |
| G-9: stdlib.integer.add / stdlib.float.add not FFI-exported | low | documented as scope gap; not required for Decimal candidate |

---

## Closed Surface Scan

| Path | Changed by this proof |
|------|-----------------------|
| `igniter-lang/lib/**` | No |
| `igniter-lang/bin/igc` | No |
| `igniter-lang/igniter_lang.gemspec` | No |
| `igniter-lang/README.md` | No |
| `igniter-lang/docs/README.md` | No |
| `igniter-lang/docs/ruby-api.md` | No |
| `igniter-lang/lib/igniter_lang/runtime_smoke.rb` | No |
| `igniter-lang/lib/igniter_lang/compiler_result.rb` | No |
| `igniter-lang/lib/igniter_lang/compilation_report.rb` | No |
| `playgrounds/igniter-lab/igniter-vm/**` | No |
| `playgrounds/igniter-lab/igniter-runtime/**` | No |
| `playgrounds/igniter-lab/igniter-compiler/**` | No |

---

## Exact Changed Files

```text
playgrounds/igniter-lab/igniter-stdlib/proofs/stdlib_candidate_proof.rb
  (new) proof script; 30/30 PASS

playgrounds/igniter-lab/igniter-stdlib/out/stdlib_candidate_proof/summary.json
  (new) machine-readable evidence packet

playgrounds/igniter-lab/igniter-stdlib/verify_stdlib.rb
  (edited) header comment narrowed to document exact scope;
  no assertion logic changed; exit string labeled as lab-assertion style

igniter-lang/docs/tracks/experimental-stdlib-candidate-proof-v0.md
  (new) this track document
```

---

## [R] Routing — Recommended Next

```text
Card: S3-R238-C3-X or C4-A
Skill: IDD Agent Protocol
Agent: [Pressure Reviewer or Portfolio Architect Supervisor]
Track: experimental-stdlib-candidate-proof-acceptance-v0

Goal:
Accept the proof-local stdlib candidate evidence, confirm STD-P1..STD-P12
PASS, confirm C-1/C-2/C-3 conditions are satisfied, and route
igniter-vm candidate intake as the next Main Line step.

Depends on: S3-R238-C2-I (this document)

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

```text
igniter-vm candidate intake:  held until R238 closes
TBackend intake:              held pending wording hardening
igc run Slice 1:              held
```
