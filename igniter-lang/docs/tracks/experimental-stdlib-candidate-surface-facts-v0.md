# Experimental Stdlib Candidate Surface Facts v0

Card: S3-R237-C2-P1
Skill: IDD Agent Protocol
Agent: [Implementation Surface Surveyor]
Role: implementation-surface-surveyor
Track: experimental-stdlib-candidate-surface-facts-v0
Route: REVIEW
Status: complete
Date: 2026-06-02

Depends on:
- S3-R236-C4-A

---

## Authority Notice

This is a read-only facts packet. It does not authorize code edits, mainline
stdlib replacement, public stdlib API, runtime/API/package changes, `igc run`
widening, compiler passport emission, RuntimeSmoke productization, Reference
Runtime support, public runtime support, stable API, production readiness,
Spark integration, release evidence, public performance claims, Official
Reference Implementation status, alternative certification, or portability
guarantees.

`playgrounds/igniter-lab/igniter-stdlib` is reviewed here as candidate
evidence and applied pressure on PROP-013. Evidence is not authority.

No lab code was edited. No mainline code was edited.

---

## Inputs Read

```text
igniter-lang/docs/tracks/stage3-round236-status-curation-v0.md
igniter-lang/docs/tracks/experimental-lab-ecosystem-next-route-decision-v0.md
igniter-lang/docs/tracks/experimental-lab-ecosystem-surface-facts-v0.md
igniter-lang/docs/tracks/experimental-stdlib-candidate-intake-and-prop013-pressure-v0.md
igniter-lang/docs/tracks/stdlib-execution-kernel-stage1-v0.md
playgrounds/igniter-lab/igniter-stdlib/Cargo.toml
playgrounds/igniter-lab/igniter-stdlib/Cargo.lock
playgrounds/igniter-lab/igniter-stdlib/src/lib.rs
playgrounds/igniter-lab/igniter-stdlib/src/decimal.rs
playgrounds/igniter-lab/igniter-stdlib/src/collections.rs
playgrounds/igniter-lab/igniter-stdlib/src/temporal.rs
playgrounds/igniter-lab/igniter-stdlib/stdlib/math.ig
playgrounds/igniter-lab/igniter-stdlib/stdlib/collections.ig
playgrounds/igniter-lab/igniter-stdlib/stdlib/temporal.ig
playgrounds/igniter-lab/igniter-stdlib/verify_stdlib.rb
playgrounds/igniter-lab/igniter-vm/Cargo.toml    (dep confirmation only)
```

PROP-013: no proposal file found at `docs/proposals/PROP-013*`; referenced
via `stdlib-execution-kernel-stage1-v0.md` and `canonical-stdlib-registry-runtime-v0.md`.

---

## [D] Decision — Recommendation

**Accept `igniter-stdlib` as stdlib candidate evidence for intake with four
explicit gaps flagged.**

The Decimal FFI surface is the strongest and cleanest component. Collections
exists as internal Rust API (not FFI-exported). Temporal is domain-specific slot
scheduling with misleading "bitemporal" comment wording. `.ig` signatures exist
but use non-current Igniter grammar.

Exact recommendation:

```text
1. Accept Decimal FFI surface as stdlib candidate evidence with OOF-TC5/OOF-DM2
   confirmation.
2. Accept collections as internal Rust-only stdlib evidence (not FFI; used by
   igniter-vm via Rust path dep).
3. Mark temporal module as domain-specific; do not treat as bitemporal stdlib
   evidence.
4. Flag .ig signature syntax as non-current grammar; intake as design pressure
   only.
5. Flag: no Rust unit tests.
6. Do not authorize mainline stdlib mutation, public stdlib API, or runtime
   authority.
```

---

## [S] Signals

```text
igniter-stdlib (playgrounds/igniter-lab/igniter-stdlib/):
  Language:   Rust (edition 2021)
  Package:    igniter_stdlib v0.1.0
  Crate type: ["rlib", "cdylib"]
  Deps:       serde 1.0, serde_json 1.0 (2 deps; no Magnus, no tokio, no network)
  Built:      target/release/libigniter_stdlib.dylib (385200 bytes)
  Digest:     sha256:0d7813a44968fcae8f2dbf4d19f594303f0ff4a86dc4e050c59bf119581bc26d

Commands confirmed in this session:
  ruby verify_stdlib.rb → exit 0 / 17 assertions PASS
  cargo test            → 0 tests (no Rust unit tests); build ok

igniter-vm path dep confirmed:
  igniter_stdlib = { path = "../igniter-stdlib" }
```

---

## [T] Technical Inventory

### 1. Build and Dependency Surface

| Item | Fact | Classification |
|------|------|----------------|
| Package name | `igniter_stdlib` | confirmed by source |
| Version | 0.1.0 | confirmed by source |
| Edition | 2021 | confirmed by source |
| Crate type | `["rlib", "cdylib"]` | confirmed by source |
| Dependencies | `serde 1.0`, `serde_json 1.0` | confirmed by source |
| No Magnus / no tokio / no parking_lot | ✓ | confirmed by source |
| Network required | No | confirmed by Cargo.lock |
| Pre-built dylib | `libigniter_stdlib.dylib` 385200 bytes | confirmed by file |
| Dylib digest | sha256:0d7813a44968... | confirmed by command |

---

### 2. FFI Export Surface

Four exported C-ABI functions via `#[no_mangle] extern "C"`:

| Function | Signature | Return/Error | Classification |
|----------|-----------|--------------|----------------|
| `stdlib_decimal_add` | `(a_val:i64, a_scale:u32, b_val:i64, b_scale:u32, out_val:*mut i64, out_scale:*mut u32) -> i32` | 0=ok, 1=OOF-TC5 scale mismatch | confirmed by source |
| `stdlib_decimal_sub` | same parameter shape as add | 0=ok, 1=OOF-TC5 scale mismatch | confirmed by source |
| `stdlib_decimal_mul` | same parameter shape; `-> void` | infallible (scale addition) | confirmed by source |
| `stdlib_decimal_div` | same parameter shape | 0=ok, 2=OOF-DM2 (div-by-zero or S1<S2) | confirmed by source |

All four confirmed by `verify_stdlib.rb` FFI binding and execution (confirmed by command).

**Not FFI-exported:**
- `collections::{range, filter, map, fold, first, count}` — internal Rust API only
- `temporal::{compute_availability, build_snapshot}` — internal Rust API only
- `Decimal::to_f64`, `Decimal::from_f64` — utility methods, not exported

---

### 3. Decimal Type and Scale Behavior

Source: `src/decimal.rs`

```rust
pub struct Decimal {
    pub value: i64,   // scaled integer: real = value / 10^scale
    pub scale: u32,
}
```

| Operation | Scale rule | Error condition | OOF code |
|-----------|-----------|-----------------|----------|
| add | requires S_a == S_b | returns Err if mismatch | OOF-TC5 |
| sub | requires S_a == S_b | returns Err if mismatch | OOF-TC5 |
| mul | result scale = S1 + S2 | infallible | — |
| div | result scale = S1 - S2 | Err if divisor==0 OR S1 < S2 | OOF-DM2 |

All four scale behaviors confirmed by source inspection and by verifier command.

**Gap: division is integer truncation, no rounding policy documented.**
`Decimal::div` computes `self.value / other.value` (i64 integer division — truncating toward zero).
There is no rounding mode documented or configurable. For production decimal
arithmetic (e.g. financial rounding), truncation-without-rounding policy must
be explicit.

**Gap: `to_f64` uses floating point — not exact.**
`Decimal::to_f64` is a helper method converting to f64 for display. It is not
FFI-exported. It uses `self.value as f64 / 10f64.powi(self.scale as i32)`.
This can lose precision for large `value` or large `scale`. It is a utility
helper only and must not be used as an authoritative decimal-to-string
conversion.

---

### 4. Collections Module

Source: `src/collections.rs`

| Function | Signature (Rust) | FFI exported | Classification |
|----------|-------------------|-------------|----------------|
| `range` | `(start: i64, end: i64) -> Vec<Value>` | No | confirmed by source |
| `filter` | `(coll: &[Value], predicate: F) -> Vec<Value>` | No | confirmed by source |
| `map` | `(coll: &[Value], mapper: F) -> Vec<Value>` | No | confirmed by source |
| `fold` | `(coll: &[Value], initial: Value, acc: F) -> Value` | No | confirmed by source |
| `first` | `(coll: &[Value]) -> Option<Value>` | No | confirmed by source |
| `count` | `(coll: &[Value]) -> usize` | No | confirmed by source |

Uses `serde_json::Value` as the generic element type. Closures are Rust-level
only; no reflection/callback mechanism for Ruby FFI.

**Gap: Collections module is not externally accessible via FFI.**
`igniter-vm` uses these functions via Rust path dependency. A future collections
FFI surface would require different design (e.g. JSON array in/out, callback ABI,
or a separate bytecode interpreter approach).

Alignment with PROP-013 Stage 1 scope: `fold`, `map`, `filter`, `count`, `first`
are all present. `range` provides collection generation. Coverage is complete
for the Stage 1 `Collection[T]` functional pipeline.

---

### 5. Temporal Module

Source: `src/temporal.rs`

| Function | Signature (Rust) | FFI exported | Classification |
|----------|-------------------|-------------|----------------|
| `compute_availability` | `(geo_signals: &Value, schedule: &Value) -> Result<Value, String>` | No | confirmed by source |
| `build_snapshot` | `(slots: &Value, technician_id: &str, date: &str) -> Result<Value, String>` | No | confirmed by source |

**Gap: temporal module is domain-specific, not general bitemporal.**

The implementation computes slot availability from `geo_signals` and `schedule`
(with `day_off` and `working_hours` fields) and produces `{ hour, status }` slot
arrays. This is a domain-specific scheduling computation, not a general temporal
API.

The `.ig` signature names it `stdlib.Temporal` and the file comment says
"bitemporal metrics and snapshot transformations." Neither description accurately
describes the implementation:

- `stdlib.Temporal` implies a general temporal stdlib module aligned with
  PROP-022/PROP-028 (`History[T]`, `BiHistory[T]`, `as_of`). The implementation
  does not support any of these.
- "bitemporal" in the comment is misleading — the implementation has no
  valid-time / transaction-time axis separation, no `as_of` semantics, and no
  temporal query interface.

**Intake should classify this as:** lab-specific domain example, not a general
temporal stdlib candidate. The `.ig` signature should be retitled and the comment
should be corrected.

---

### 6. `.ig` Signature Surface

| File | Module | Functions | Classification |
|------|--------|-----------|----------------|
| `stdlib/math.ig` | `stdlib.Math` | `add`, `sub`, `mul`, `div` for `Decimal[S]` | confirmed by source |
| `stdlib/collections.ig` | `stdlib.Collections` | `range`, `filter`, `map`, `fold`, `first`, `count` | confirmed by source |
| `stdlib/temporal.ig` | `stdlib.Temporal` | `compute_availability`, `build_snapshot` | confirmed by source |

All three files confirmed present by `verify_stdlib.rb` signature hygiene check.

**Gap: `.ig` type syntax is non-current Igniter grammar.**

The signatures use type syntax not in the accepted Igniter language spec:

| Syntax used | Status | Note |
|-------------|--------|------|
| `Decimal[S]` with type variable `S` | non-current | Current language uses `Decimal` scalar type (PROP-021); scale parameters are not source-level |
| `Collection[T]` | non-current | Current source grammar does not support generic type parameters at source level |
| `(T) -> Bool` higher-order type | non-current | Higher-order function types are not in current Igniter source grammar |
| `Option[T]` | non-current | Not in current type system |
| `GeoSignal`, `ScheduleFact`, `TimeSlot`, `AvailabilitySnapshot` | undefined | Not registered types in any PROP or spec chapter |

The `.ig` files are **aspirational/design-pressure signatures**, not current
Igniter program syntax. They cannot be parsed by the current `igc compile`
pipeline. This is acceptable for candidate intake (they describe *what* the
stdlib should expose), but must be clearly labeled as design-only signatures,
not accepted Igniter source.

---

### 7. Relationship to PROP-013

Source: `stdlib-execution-kernel-stage1-v0.md`

PROP-013 Stage 1 scope: `stdlib.integer.add`, `stdlib.float.add`,
`stdlib.decimal.add`, `fold`, `map`, `filter`, `count`, `first`.

| PROP-013 item | Lab coverage | Gap |
|---------------|-------------|-----|
| `stdlib.decimal.add` | FFI-exported, verified | — |
| `stdlib.decimal.sub` | FFI-exported, verified | — |
| `stdlib.decimal.mul` | FFI-exported, verified | — |
| `stdlib.decimal.div` | FFI-exported, verified | — |
| `stdlib.integer.add` | Not present (no `i64` FFI export for integer ops) | gap |
| `stdlib.float.add` | Not present | gap |
| `fold` | Internal Rust only (collections.rs) | not FFI |
| `map` | Internal Rust only | not FFI |
| `filter` | Internal Rust only | not FFI |
| `count` | Internal Rust only | not FFI |
| `first` | Internal Rust only | not FFI |

The lab stdlib covers **Decimal arithmetic via FFI** plus **Collection operations
via internal Rust API**. It does not cover `stdlib.integer.add` or
`stdlib.float.add` as FFI exports.

`stdlib-execution-kernel-stage1-v0.md` (proof fixture) covers `stdlib.integer.add`
and `stdlib.decimal.add` via a proof-local interpreter, not via the Rust FFI.
The two approaches are complementary, not conflicting.

---

### 8. Relationship to `igniter-vm`

Confirmed by `igniter-vm/Cargo.toml`:

```toml
igniter_stdlib = { path = "../igniter-stdlib" }
```

`igniter-vm` uses `igniter-stdlib` as a direct Rust path dependency. The VM's
Decimal arithmetic tests (`test_decimal_addition_success`, etc.) use the stdlib
implementation through the Rust API, not through FFI.

This means:
- If `igniter-stdlib` is intaken as candidate evidence, the VM's Decimal
  tests have a grounded stdlib dependency in the evidence chain.
- Any future `igniter-vm` intake can cite this stdlib intake as a precursor.

---

## FFI / Signature Support Matrix

| Component | FFI exported | Verified | PROP-013 | Igniter grammar | Classification |
|-----------|-------------|----------|----------|-----------------|----------------|
| `stdlib_decimal_add` | Yes | Yes | Yes (decimal.add) | N/A (C ABI) | confirmed |
| `stdlib_decimal_sub` | Yes | Yes | Yes (decimal.sub) | N/A | confirmed |
| `stdlib_decimal_mul` | Yes | Yes | Yes (decimal.mul) | N/A | confirmed |
| `stdlib_decimal_div` | Yes | Yes | Yes (decimal.div) | N/A | confirmed |
| collections (range/filter/map/fold/first/count) | No | No | Yes (Rust-only) | non-current sig | internal Rust |
| temporal (compute_availability/build_snapshot) | No | No | No | non-current sig | domain-specific |
| math.ig signatures | N/A | Yes (file present) | Partial | Non-current | design-pressure |
| collections.ig signatures | N/A | Yes (file present) | Yes | Non-current | design-pressure |
| temporal.ig signatures | N/A | Yes (file present) | No | Non-current | misleading (see gap) |

---

## Gap and Wording Register

| Gap | Location | Severity | Note |
|-----|----------|----------|------|
| G-1: No Rust unit tests | cargo test → 0 tests | Medium | Correctness only verified via Ruby/FFI verifier, not native Rust tests |
| G-2: Collections not FFI-exported | src/collections.rs | Medium | Accessible to igniter-vm via Rust dep, but not to Ruby or external consumers |
| G-3: Temporal module is domain-specific, not general bitemporal | src/temporal.rs | High (wording) | "stdlib.Temporal" and "bitemporal" comment are misleading; implementation is slot-scheduling only |
| G-4: .ig signature types are non-current grammar | stdlib/*.ig | Medium | `Decimal[S]`, `Collection[T]`, `(T) -> Bool`, `Option[T]`, undefined record types |
| G-5: No runtime_implementation_id | any source file | Low | Required for candidate intake packet; not present |
| G-6: No evidence class or non-claims | any source file | Low | Required for intake packet; not present in source |
| G-7: Division truncates, no rounding policy | src/decimal.rs | Low | `i64 / i64` is truncating division; needs explicit rounding mode documentation for financial contexts |
| G-8: `to_f64` is inexact, no doc warning | src/decimal.rs | Low | Utility helper only; not FFI-exported; but lack of warning could mislead future contributors |
| G-9: `stdlib.integer.add` / `stdlib.float.add` not covered by FFI | src/lib.rs | Medium | PROP-013 mentions integer and float variants; only Decimal covered by FFI exports |
| W-1: "High-performance" in module comments | src/decimal.rs, collections.rs, temporal.rs | Low | Lab-assertion style comment; not exported or visible in any public surface |
| W-2: "bitemporal" in temporal.rs comment | src/temporal.rs | Medium | Misleading; temporal module is domain-specific slot scheduling, not bitemporal in PROP-022/PROP-028 sense |
| W-3: "🏆 ALL STANDARD LIBRARY CORRECTNESS..." verifier exit string | verify_stdlib.rb | Low | Lab-assertion pattern; same as igniter-compiler verifier; acceptable if labeled lab-only |

---

## Command Matrix

| Command | Location | Result | Classification |
|---------|----------|--------|----------------|
| `ruby verify_stdlib.rb` | playgrounds/igniter-lab/igniter-stdlib/ | exit 0 / 17 PASS / 0 FAIL | confirmed by command |
| `cargo test` | playgrounds/igniter-lab/igniter-stdlib/ | 0 tests, 0 failures; build ok | confirmed by command |
| `cargo build --release` | (invoked by verifier) | Already cached; Finished 0.05s | confirmed by command |
| FFI linkage via Fiddle | verify_stdlib.rb | All 4 functions bind successfully | confirmed by command |

Not run (not needed, no server/network):
- `cargo test igniter-vm` (separate directory; already confirmed 12/12 in R236-C2-P1)
- Any igniter-tbackend verify scripts
- Any network-requiring scripts

---

## [R] Risks / Recommendations

```text
1. Accept Decimal FFI surface as the primary intake evidence — 4 verified FFI
   functions, OOF-TC5/OOF-DM2 behavior proven, zero overclaim wording in
   exported surface.

2. Do NOT cite temporal.rs as "bitemporal stdlib" evidence — the implementation
   is domain-specific slot scheduling. Retitling and comment correction are
   lab-internal tasks before temporal can be part of any stdlib intake claim.

3. Collections is correctly internal Rust API — it serves igniter-vm, not Ruby
   consumers. Intake should classify it as "Rust-internal stdlib candidate" not
   "FFI-accessible stdlib".

4. .ig signatures are design-pressure only — they use non-current grammar and
   cannot be compiled by igc today. Intake value is as PROP-013 pressure and
   API-shape discussion, not as accepted Igniter source.

5. No Rust unit tests is the biggest structural gap — the verifier provides
   correctness evidence via FFI, but the absence of native unit tests means no
   Rust-internal invariant tests exist. A future lab hardening step should add
   Rust tests before any promoted intake.
```

---

## [Next] Suggested Next Slice

The R237-C1-D design card (stdlib intake / PROP-013 pressure) is the next
Main Line route. This facts packet provides the supporting surface evidence.

Minimum intake packet should include, per the gap register:

```text
runtime_implementation_id: igniter.delegated.experimental.stdlib.rust_cdylib
evidence_class: stdlib candidate evidence / Decimal FFI subset only
supported_surface: stdlib.decimal.add / sub / mul / div (FFI)
internal_rust_surface: collections (range, filter, map, fold, first, count)
gap_register: G-1..G-9 as documented above
non_claims: not stable API / not production ready / not public runtime support /
  not Reference Runtime support / not Spark integration / not release evidence /
  not public performance claim
temporal_module_status: domain-specific example; not general bitemporal stdlib
```

```text
Card:  S3-R237-C2-P1 (this document)
Agent: [Implementation Surface Surveyor]
Role:  implementation-surface-surveyor
Track: experimental-stdlib-candidate-surface-facts-v0
Status: complete
```
