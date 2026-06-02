# Experimental Stdlib Candidate Pressure v0

Card: S3-R237-C3-X
Skill: IDD Agent Protocol
Agent: [External Pressure Reviewer]
Role: external-pressure-reviewer
Track: experimental-stdlib-candidate-pressure-v0
Route: REVIEW
Status: CONDITIONAL PASS
Date: 2026-06-02

Depends on:
- S3-R237-C1-D
- S3-R237-C2-P1

---

## Authority Notice

This is a read-only pressure document. It does not authorize code edits,
mainline stdlib replacement, public stdlib API, runtime/API/package changes,
`igc run` widening, compiler passport emission, RuntimeSmoke productization,
Reference Runtime support, public runtime support, stable API, production
readiness, Spark integration, release evidence, public performance claims,
official/reference status, alternative certification, or portability
guarantees.

---

## Verdict

```text
CONDITIONAL PASS
```

The Decimal FFI surface survives pressure cleanly. The conditions are not
blockers for candidate intake. They are mandatory reading constraints for
C4-A: if C4-A accepts without explicitly scoping these conditions, authority
leakage becomes possible downstream.

All implementation and public authority remains closed.

---

## Inputs Read

```text
igniter-lang/docs/tracks/
  experimental-stdlib-candidate-intake-and-prop013-pressure-v0.md  (C1-D)
igniter-lang/docs/tracks/
  experimental-stdlib-candidate-surface-facts-v0.md                (C2-P1)
igniter-lang/docs/tracks/stage3-round236-status-curation-v0.md
igniter-lang/docs/tracks/experimental-lab-ecosystem-next-route-decision-v0.md
igniter-lang/docs/tracks/experimental-lab-ecosystem-surface-facts-v0.md
playgrounds/igniter-lab/igniter-stdlib/src/decimal.rs
playgrounds/igniter-lab/igniter-stdlib/src/collections.rs
playgrounds/igniter-lab/igniter-stdlib/src/temporal.rs
playgrounds/igniter-lab/igniter-stdlib/stdlib/math.ig
playgrounds/igniter-lab/igniter-stdlib/stdlib/collections.ig
playgrounds/igniter-lab/igniter-stdlib/stdlib/temporal.ig
playgrounds/igniter-lab/igniter-stdlib/verify_stdlib.rb
```

No code was edited. No verifier was re-run in this pressure review.

---

## Risk Matrix

| Risk ID | Surface | Risk | Severity | Disposition |
|---------|---------|------|----------|-------------|
| R-1 | `temporal.rs` / `stdlib.Temporal` | Module labeled "stdlib.Temporal" and described as "bitemporal" but implements domain-specific slot scheduling. No `as_of`, no `History[T]`, no `BiHistory[T]`, no valid/transaction time. | **HIGH** | Condition C-1: must be explicitly scoped as domain example, not bitemporal stdlib |
| R-2 | `verify_stdlib.rb` exit string | "ALL STANDARD LIBRARY CORRECTNESS AND LINKABILITY TESTS PASSED" covers only Decimal FFI (14 assertions) + signature file presence (3). Collections and temporal are NOT tested. Exit string implies broader correctness than verified scope. | **HIGH** | Condition C-2: any intake citation must scope verifier to Decimal FFI + file presence only |
| R-3 | `.ig` signatures | `Decimal[S]`, `Collection[T]`, `(T) -> Bool`, `Option[T]`, `GeoSignal`, `ScheduleFact`, `TimeSlot`, `AvailabilitySnapshot` — none parse with current `igc compile`. Intake document may be read as implying these are accepted Igniter syntax. | **MEDIUM** | Condition C-3: signatures are design-pressure only; not current Igniter source |
| R-4 | Decimal `div` truncation | `i64 / i64` is truncating division toward zero. No rounding mode documented or configurable. For financial contexts, truncation without explicit policy is a correctness gap. | **MEDIUM** | Non-blocking for candidate intake; must be documented and not promoted as financial-grade |
| R-5 | Collections: no FFI, no verifier | `range`, `filter`, `map`, `fold`, `first`, `count` are internal Rust API only. Not FFI-exported. `verify_stdlib.rb` does not test them. C2-P1 correctly identifies this, but the PASS exit string could mask it. | **MEDIUM** | Condition C-2 covers this; intake must scope collections as "internal Rust-only" |
| R-6 | No Rust unit tests | `cargo test` produces 0 tests. All correctness evidence is from Ruby/FFI verifier only. No Rust-internal invariant tests. | **MEDIUM** | Non-blocking for candidate intake; required before any promoted/mainline intake |
| R-7 | `decimal.rs` comment "High-performance" | Module comment says "High-performance, precise Fixed-Point Decimal arithmetic library." Not exported. Not visible to consumers. | **LOW** | Lab-assertion pattern inside source comment; no public surface impact |
| R-8 | `collections.rs` comment "High-performance" | Same pattern. Not exported. | **LOW** | Lab-assertion pattern; no public surface impact |
| R-9 | `temporal.rs` comment "High-performance bitemporal..." | Same pattern, but compounded by "bitemporal" in a module that is not bitemporal. | **LOW–MEDIUM** | Covered by R-1; address together |
| R-10 | `Decimal::to_f64` / `from_f64` precision | `to_f64` uses `self.value as f64 / 10f64.powi(...)` — imprecise for large values. Not FFI-exported; utility only. | **LOW** | Non-blocking; must not be used for authoritative display or serialization |
| R-11 | `stdlib.integer.add` / `stdlib.float.add` absent from FFI | PROP-013 mentions integer and float stdlib variants. Only Decimal is FFI-exported. | **LOW** | Gap acknowledged; not required for candidate intake; separate future route |
| R-12 | `runtime_implementation_id` absent | Not present anywhere in the stdlib source. Required for full intake packet vocabulary. | **LOW** | Non-blocking for candidate intake authorization review; required for proof-local packet |

---

## Detailed Pressure Analysis

### P-1: Decimal FFI — Does it survive pressure?

**Yes. Decimal FFI survives cleanly.**

The four exported functions (`stdlib_decimal_add`, `stdlib_decimal_sub`,
`stdlib_decimal_mul`, `stdlib_decimal_div`) are:

- Directly inspected from source
- Confirmed `#[no_mangle] extern "C"` — real C ABI
- Verified by Ruby Fiddle FFI binding (17 assertions PASS)
- OOF-TC5 scale mismatch is correctly implemented and returns a typed error
- OOF-DM2 division failure covers both div-by-zero and negative-scale-result
- Scale propagation (sum on mul, difference on div) is correct and confirmed

Decimal FFI is the strongest and cleanest surface in the candidate. It can
be accepted as stdlib candidate evidence without qualification on the FFI
surface itself.

**One precision caveat (R-4):** `Decimal::div` performs integer division
(`self.value / other.value`, i64/i64), which truncates toward zero. There is
no rounding mode. This is acceptable for candidate intake if the evidence
record is explicit: *Decimal division in this candidate truncates; no rounding
policy is defined.* Do not represent the division behavior as "production
financial-grade."

**One inexact helper (R-10):** `Decimal::to_f64` is a display utility using
floating-point conversion. It is NOT FFI-exported. It must not be cited as
authoritative decimal serialization or display. Mark as utility-only in any
intake record.

---

### P-2: Collections — Under-verified. What does that mean for intake?

**Collections survive as internal-Rust-only candidate evidence, with an
explicit scope constraint.**

C2-P1 correctly identifies that `range`, `filter`, `map`, `fold`, `first`,
and `count` exist as internal Rust API only and are not FFI-exported. The
verifier does NOT test them. The only verifier coverage for collections is
the presence of `stdlib/collections.ig` as a file (1 assertion).

This creates one authority risk: the verifier exit string "ALL STANDARD
LIBRARY CORRECTNESS AND LINKABILITY TESTS PASSED" could be read as "all
collection operations are correct," but they are entirely untested by the
verifier.

**For intake, this means:**
- Collections may be cited as "internal Rust-only stdlib candidate evidence"
- Collections may NOT be cited as "verified stdlib" or "FFI-accessible stdlib"
- The verifier PASS does NOT extend to collection behavior
- PROP-013 Stage 1 coverage is noted as present in Rust source but unverified
  by any test (Rust or Ruby)

---

### P-3: Temporal module — Naming is the real problem

**R-1 is the highest-severity individual risk.**

The temporal module presents a naming mismatch severe enough that any intake
record citing it without explicit correction would propagate a false claim.

**What the module claims to be:**

```text
stdlib/temporal.ig comment: "bitemporal metrics and snapshot transformations"
stdlib.Temporal module name: implies general temporal stdlib
temporal.rs comment: "High-performance bitemporal metrics and snapshot transformations"
```

**What the module actually implements:**

```text
compute_availability(geo_signals, schedule):
  - Takes JSON `geo_signals` array and `schedule` with `day_off` / `working_hours`
  - Iterates hours from start_h..end_h, looks up geo_signal for each hour
  - Produces [{hour: N, status: "available"|"blocked"}] array

build_snapshot(slots, technician_id, date):
  - Counts available slots in a pre-built slot array
  - Produces {technician_id, date, available_slots, available_count, snapshot_at}
```

This is a domain-specific technician scheduling computation. There is no
`as_of`, no `valid_time`, no `transaction_time`, no `History[T]`,
no `BiHistory[T]`, and no temporal query interface. The module has nothing
to do with bitemporal semantics as defined by PROP-022/PROP-028.

**Consequence if not scoped at intake:**

A future route that reads "stdlib.Temporal (verified)" from an intake record
may incorrectly conclude that the stdlib has general bitemporal capability.
This would be an authority leakage from a lab-local domain example into the
Igniter temporal vocabulary.

**Mandatory condition for C4-A:**

Temporal must be explicitly classified in the acceptance decision as:

```text
domain-specific scheduling example
not general bitemporal stdlib
not History[T] / BiHistory[T] coverage
not as_of / valid_time / transaction_time coverage
intake value: design-pressure example for domain-specific stdlib helpers only
```

---

### P-4: Verifier scope versus verifier exit string — the hidden overclaim

**R-2 is the second-highest-severity risk, and it is structural.**

`verify_stdlib.rb` runs 17 assertions:

```text
14 assertions: Decimal FFI (A through N)
 3 assertions: file presence for math.ig, collections.ig, temporal.ig
```

Exit string:

```text
"🏆 ALL STANDARD LIBRARY CORRECTNESS AND LINKABILITY TESTS PASSED SUCCESSFULLY!"
```

**What "ALL STANDARD LIBRARY CORRECTNESS" implies versus what is tested:**

| Module | Correctness tested | FFI linkage tested | File present tested |
|--------|-------------------|--------------------|---------------------|
| Decimal | Yes (14 assertions) | Yes (Fiddle bind) | implicitly |
| Collections | **No** | **No** | Yes (1 assertion) |
| Temporal | **No** | **No** | Yes (1 assertion) |

The exit string uses "ALL STANDARD LIBRARY CORRECTNESS" when only Decimal
correctness is tested. Collections and Temporal are only confirmed to exist
as files.

**This is not a failure of C1-D or C2-P1** — both correctly identify this
scope. The risk is that future documents citing the verifier PASS without
reading the detail will import "all stdlib correctness verified" as a claim.

**Mandatory condition for C4-A:**

Any acceptance decision must include explicit scope language such as:

```text
verifier scope: Decimal FFI correctness + signature file presence only
collections behavior: unverified by any test
temporal behavior: unverified by any test
"ALL STANDARD LIBRARY CORRECTNESS" exit string: lab-assertion style;
scope is narrower than the string implies
```

---

### P-5: `.ig` signature grammar — design-pressure or accepted Igniter syntax?

**Signatures are design-pressure only. This is correctly identified by C2-P1.
The risk is that they look like Igniter source.**

The `.ig` files use syntax that does not parse with the current `igc compile`:

```text
Decimal[S]        — type variable; not in current source grammar
Collection[T]     — generic container; not in current source grammar
(T) -> Bool       — higher-order function type; not in current source grammar
Option[T]         — optional type; not in current source grammar
GeoSignal         — undefined type; not in any PROP or spec
ScheduleFact      — undefined type
TimeSlot          — undefined type
AvailabilitySnapshot — undefined type
```

The grammar in `math.ig` is aspirational: it describes what Decimal stdlib
could look like with parametric scale types, but current Igniter uses scalar
`Decimal` (PROP-021), not `Decimal[S]` with type variables.

**Value:** Real. The signatures show what the stdlib API surface *should* be
if the language gains parametric types. They are useful PROP-013 pressure.

**Risk:** If cited as "the stdlib API," they imply a type system that does
not exist and operations that do not yet parse. An intake that calls them
"Igniter stdlib signatures" without qualification would be incorrect.

**Condition C-3** handles this: require the acceptance decision to label
all `.ig` files as design-only signatures, not accepted Igniter source.

---

### P-6: VM sequencing — should it wait?

**Yes. VM intake should wait. The dependency is structural and the sequencing
is correct.**

`igniter-vm/Cargo.toml` declares:

```toml
igniter_stdlib = { path = "../igniter-stdlib" }
```

The VM's 12 Cargo tests (confirmed PASS in R236-C2-P1) use `igniter-stdlib`
through this path dependency. If C4-A accepts stdlib as candidate evidence,
the VM intake can cite this as a grounded precursor. Without that acceptance,
the VM intake would be citing an unclassified dependency.

C1-D's recommendation (hold VM until stdlib candidate status closes) is
correct and survives pressure.

**No blockers in the VM direction.** The sequencing risk is low. Holding
VM intake is prudent, not urgent.

---

### P-7: Authority leakage check — did any public claim slip through?

**No direct leakage found in C1-D or C2-P1.**

Both documents maintain:
- Explicit non-claim wording on mainline stdlib replacement, public stdlib API,
  runtime/package authority, stable API, production, Reference Runtime, Spark,
  release, performance, and portability
- Evidence-only / candidate-only framing throughout
- No mainline code changes authorized
- No playground code edited

**One latent risk (R-2 + R-1):** The combination of the verifier exit string
scope gap and the temporal naming mismatch creates a surface where a future
reader skimming the acceptance decision could infer broader stdlib coverage
than exists. This is why C-1 and C-2 are stated as mandatory conditions, not
advisory notes.

---

### P-8: `runtime_implementation_id` — required later, not a blocker now

C2-P1 correctly flags `runtime_implementation_id` (R-12) as absent. C1-D's
intake minimum packet suggests:

```text
runtime_implementation_id: igniter.delegated.experimental.stdlib.rust_cdylib
```

This field is not in the current source. It is not required for candidate
intake authorization — it belongs in the proof-local packet that opens after
C4-A accepts. The absence is not a blocker at this stage.

---

## Explicit Answers

**Is Decimal FFI behavior enough for candidate evidence?**

```text
Yes. Decimal FFI is sufficient for candidate intake evidence.
OOF-TC5 and OOF-DM2 behaviors are proven via FFI and confirmed by source.
Division truncation must be documented but does not block intake.
```

**Are collections/temporal .ig signatures under-verified?**

```text
Collections: yes — no FFI export, no correctness test, file presence only.
Temporal: yes — no FFI export, no correctness test, AND misnamed/misdescribed.
Neither is a blocker for candidate intake if the acceptance decision
explicitly scopes both as unverified candidates with the temporal module
additionally scoped as domain-specific (not general bitemporal).
```

**Does the lab verifier output overclaim?**

```text
Yes, structurally. "ALL STANDARD LIBRARY CORRECTNESS AND LINKABILITY TESTS
PASSED SUCCESSFULLY!" implies correctness across all three modules.
Only Decimal FFI correctness and three file-presence checks are verified.
This is a real risk if intake records cite "verifier PASS" without scoping.
C-2 is mandatory.
```

**Should intake route proof-local stdlib proof next, or only design/facts?**

```text
Route proof-local stdlib candidate proof authorization review next.
The gap register (no Rust tests, collections unverified, temporal misnamed)
makes a direct acceptance decision without a follow-up proof route premature.
A bounded proof-local route can scope what "proof" means per module before
any broader intake claim is made.
```

**Should VM intake wait?**

```text
Yes. VM intake should wait until C4-A closes stdlib candidate status.
The dependency is structural. The sequencing risk is low; the hold is correct.
```

**Did public stdlib/API/runtime claims leak?**

```text
No direct leakage from C1-D or C2-P1.
Latent leakage risk exists via verifier scope gap (R-2) and temporal naming
(R-1) if not addressed in the C4-A acceptance decision.
```

**PASS / CONDITIONAL / HOLD / REDIRECT?**

```text
CONDITIONAL PASS

The Decimal FFI surface is accepted as candidate evidence.
Three mandatory conditions must appear in the C4-A acceptance decision.
No blockers. No hold. No redirect.
```

**Strongest next route?**

```text
experimental-stdlib-candidate-proof-authorization-review-v0
```

**Biggest semantic gap?**

```text
Temporal module naming mismatch.
"stdlib.Temporal" with "bitemporal" comment describes domain-specific
technician slot scheduling. No general temporal stdlib semantics exist.
This gap is semantic — the module is not what it says it is.
```

**Biggest authority risk?**

```text
Verifier exit string scope gap.
"ALL STANDARD LIBRARY CORRECTNESS AND LINKABILITY TESTS PASSED" covers
Decimal FFI (14 assertions) + file presence (3 assertions) only.
Collections behavior and temporal behavior are entirely unverified.
Any intake citation of "verifier PASS" without scoping imports a false
correctness claim about collections and temporal.
```

---

## Mandatory Conditions for C4-A

These three conditions must appear explicitly in the C4-A acceptance decision.
If any condition is omitted, the CONDITIONAL PASS does not hold.

**C-1: Temporal module scoped as domain-specific example, not general bitemporal stdlib.**

Exact required wording for acceptance decision:

```text
temporal module: domain-specific slot scheduling example
not general bitemporal stdlib
not History[T] / BiHistory[T] coverage
not as_of / valid_time / transaction_time semantics
intake classification: domain-specific stdlib helper example only
not stdlib.Temporal authority for PROP-022/PROP-028 temporal vocabulary
```

**C-2: Verifier scope explicitly bounded in any intake citation.**

Exact required wording for acceptance decision:

```text
verifier scope (verify_stdlib.rb):
  Decimal FFI correctness: 14 assertions PASS
  signature file presence: 3 assertions PASS
  collections correctness: not tested
  temporal correctness: not tested
exit string "ALL STANDARD LIBRARY CORRECTNESS": lab-assertion style;
  scope is narrower than the string implies;
  not accepted as collections or temporal correctness evidence
```

**C-3: .ig signature files are design-pressure only, not accepted Igniter source.**

Exact required wording for acceptance decision:

```text
stdlib/*.ig signatures: design-pressure only
cannot be parsed by current igc compile pipeline
type syntax (Decimal[S], Collection[T], (T) -> Bool, Option[T]) is non-current
domain types (GeoSignal, ScheduleFact, TimeSlot, AvailabilitySnapshot) undefined
intake value: PROP-013 design pressure and API-shape discussion only
not accepted Igniter source
not accepted as stdlib API surface
```

---

## Advisory Gaps (non-blocking for C4-A, required before promoted intake)

```text
G-1: No Rust unit tests — verifier is Ruby/FFI only
G-2: Collections not FFI-exported — internal Rust-only
G-3: Temporal module misnamed — see C-1
G-4: .ig signatures non-current grammar — see C-3
G-5: runtime_implementation_id absent — required for proof-local packet
G-6: No evidence class declaration in source
G-7: Decimal division truncates — no rounding policy documented
G-8: to_f64 is imprecise — utility only; do not use for authoritative display
G-9: stdlib.integer.add / stdlib.float.add not FFI-exported (PROP-013 gap)
```

---

## Exact Recommendation to C4-A

```text
Verdict: CONDITIONAL PASS

Accept:
  Decimal FFI surface (stdlib_decimal_add/sub/mul/div) as stdlib candidate
  evidence, with OOF-TC5 and OOF-DM2 behaviors confirmed.

  Collections (range, filter, map, fold, first, count) as internal Rust-only
  stdlib candidate evidence. Not FFI-accessible. Not verifier-confirmed beyond
  file presence.

  .ig signature files (math.ig, collections.ig, temporal.ig) as design-pressure
  only, not accepted Igniter source and not parseable by current igc.

Required conditions (C-1, C-2, C-3 above — all three must appear in decision):
  C-1: Temporal module = domain-specific example only, not general bitemporal
  C-2: Verifier PASS scope = Decimal FFI + file presence only
  C-3: .ig signatures = design-pressure only, not accepted Igniter source

Do not accept:
  temporal module as general bitemporal stdlib evidence
  verifier exit string as "all stdlib correctness" evidence
  .ig signatures as accepted Igniter source or stdlib API surface
  any implementation authority
  any public stdlib / runtime / API / package authority

Next route:
  experimental-stdlib-candidate-proof-authorization-review-v0

Hold:
  igniter-vm candidate intake until stdlib candidate status closes
  TBackend intake until wording hardening complete
  igc run Slice 1

Closed:
  mainline stdlib replacement
  public stdlib API
  PROP-013 canonical authority change
  runtime/API/package changes
  igc run widening
  .igbin execution
  compiler passport emission
  RuntimeSmoke productization
  Reference Runtime support
  public runtime support
  stable API
  production readiness
  Spark integration
  release evidence
  public performance claims
  official/reference status
  alternative certification
  portability guarantees
```
