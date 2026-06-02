# Experimental Stdlib Candidate Proof Authorization Review v0

Card: S3-R238-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-stdlib-candidate-proof-authorization-review-v0
Route: UPDATE
Status: authorized / proof-local-only
Date: 2026-06-02

Depends on:
- S3-R237-C4-A

---

## Decision

Authorize bounded proof-local C2-I work:

```text
S3-R238-C2-I
experimental-stdlib-candidate-proof-v0
```

Authorized meaning:

```text
proof-local stdlib candidate evidence only
lab-local proof and evidence-packet work only
not mainline stdlib replacement
not public stdlib API
not runtime/API/CLI/package authority
not public/runtime/reference/stable support
```

Reason:

```text
R237 conditionally accepted igniter-stdlib as candidate evidence and carried
specific C-1/C-2/C-3 scope conditions. The remaining gaps are proof-packaging,
verifier-scope exactness, metadata/non-claims, and lab-local classification
work. These can be handled inside a bounded proof-local route without opening
mainline authority.
```

This authorization does not authorize mainline stdlib replacement, public
stdlib API, runtime/API/CLI/package changes, `igc run` widening, `.igbin`
execution, compiler passport emission, RuntimeSmoke productization, Reference
Runtime support, public runtime support, stable API, production readiness,
Spark integration, release execution, public performance claims,
official/reference status, alternative certification, or portability
guarantees.

---

## Inputs Read

```text
igniter-lang/docs/tracks/stage3-round237-status-curation-v0.md
igniter-lang/docs/tracks/
  experimental-stdlib-candidate-intake-decision-v0.md
igniter-lang/docs/tracks/
  experimental-stdlib-candidate-intake-and-prop013-pressure-v0.md
igniter-lang/docs/tracks/
  experimental-stdlib-candidate-surface-facts-v0.md
igniter-lang/docs/discussions/
  experimental-stdlib-candidate-pressure-v0.md
igniter-lang/docs/proposals/accepted/
  PROP-013-stdlib-fold-aggregate-v0.md
igniter-lang/docs/tracks/stdlib-execution-kernel-stage1-v0.md
playgrounds/igniter-lab/igniter-stdlib/Cargo.toml
playgrounds/igniter-lab/igniter-stdlib/src/lib.rs
playgrounds/igniter-lab/igniter-stdlib/src/decimal.rs
playgrounds/igniter-lab/igniter-stdlib/src/collections.rs
playgrounds/igniter-lab/igniter-stdlib/src/temporal.rs
playgrounds/igniter-lab/igniter-stdlib/verify_stdlib.rb
playgrounds/igniter-lab/igniter-vm/Cargo.toml
```

---

## Compact Decision Summary

```text
C2-I may begin: yes
proof type: proof-local lab candidate proof
allowed code writes: playgrounds/igniter-lab/igniter-stdlib/**
allowed mainline write: proof track doc only
igniter-vm edits: no
mainline lib/CLI/package/docs edits: no
verifier wording hardening: yes, inside lab candidate only
Rust tests/proof scripts: yes, inside lab candidate only
generated output authority: proof-local stdlib candidate evidence only
VM intake: held
igc run Slice 1: held
public/stable/production/reference/performance/portability claims: closed
```

---

## Allowed Write Scope

```text
playgrounds/igniter-lab/igniter-stdlib/**
igniter-lang/docs/tracks/
  experimental-stdlib-candidate-proof-v0.md
```

Allowed lab writes include, but are not limited to:

```text
playgrounds/igniter-lab/igniter-stdlib/proofs/
  stdlib_candidate_proof.rb
playgrounds/igniter-lab/igniter-stdlib/out/
  stdlib_candidate_proof/summary.json
playgrounds/igniter-lab/igniter-stdlib/tests or src test modules
playgrounds/igniter-lab/igniter-stdlib/verify_stdlib.rb
```

`verify_stdlib.rb` may be edited only to narrow or clarify verifier scope. It
must not broaden public claims or imply full stdlib correctness.

---

## Read-Only / Closed Surfaces

```text
playgrounds/igniter-lab/igniter-vm/**
playgrounds/igniter-lab/igniter-runtime/**
playgrounds/igniter-lab/igniter-compiler/**
igniter-lang/lib/**
igniter-lang/bin/igc
igniter-lang/igniter_lang.gemspec
igniter-lang/README.md
igniter-lang/docs/README.md
igniter-lang/docs/ruby-api.md
igniter-lang/lib/igniter_lang/runtime_smoke.rb
igniter-lang/lib/igniter_lang/compiler_result.rb
igniter-lang/lib/igniter_lang/compilation_report.rb
```

`igniter-vm` may be read only to observe dependency readiness. It may not be
edited, rebuilt as part of authority transfer, or opened as an intake route by
C2-I.

---

## Required Evidence Packet Shape

The proof must produce:

```text
playgrounds/igniter-lab/igniter-stdlib/out/
  stdlib_candidate_proof/summary.json
```

Required summary fields:

```text
track
status
runtime_implementation_id
evidence_class
authority_status
non_claims
supported_surface
internal_rust_surface
design_pressure_surface
domain_specific_surface
decimal_ffi
oof_tc5
oof_dm2
decimal_division_policy
verifier_scope
collections_status
temporal_status
ig_signature_status
igniter_vm_dependency_readiness
gap_register
command_matrix
proof_matrix
changed_files
closed_surface_scan
next_recommendation
```

Required `runtime_implementation_id` policy:

```text
Use a proof-local candidate id such as:
  igniter.delegated.experimental.stdlib.rust-cdylib.v0

The id is metadata only. It is not a runtime registry entry, not a package
identifier, not a public API, and not a certification marker.
```

Required evidence class:

```text
proof_local_stdlib_candidate_evidence
```

Required authority status:

```text
non_canonical
candidate_only
proof_local
no_public_api_authority
no_runtime_authority
```

Required machine-readable non-claims:

```text
not_mainline_stdlib_replacement
not_public_stdlib_api
not_runtime_support
not_reference_runtime_support
not_public_runtime_support
not_stable_api
not_production_ready
not_spark_integration
not_release_evidence
not_public_performance_claim
not_official_reference_status
not_alternative_certification
not_portability_guarantee
```

---

## Proof Expectations

Decimal FFI:

```text
Confirm stdlib_decimal_add/sub/mul/div are exported and callable.
Confirm successful add/sub/mul/div behavior.
Confirm OOF-TC5 scale mismatch behavior.
Confirm OOF-DM2 division failure behavior.
Document Decimal division truncation and lack of rounding policy.
Document to_f64/from_f64 as utility-only and not authoritative display or
serialization.
```

Verifier scope:

```text
Narrow verifier output or record exact assertion scope so it cannot be cited as
all-stdlib correctness evidence.

Required scope statement:
  Decimal FFI correctness is tested.
  Signature file presence is tested.
  Collections correctness is not tested by verify_stdlib.rb unless C2-I adds
    explicit tests.
  Temporal correctness is not tested by verify_stdlib.rb unless C2-I adds
    explicit tests.
```

Collections stance:

```text
Classify collections as internal Rust-only unless C2-I explicitly exports and
tests a separate surface. Do not call collections public stdlib API or
FFI-accessible stdlib.
```

Temporal stance:

```text
Classify temporal as domain-specific slot scheduling helper only.
Do not call it general bitemporal stdlib.
Do not claim History[T], BiHistory[T], as_of, valid_time, transaction_time, or
PROP-022/PROP-028 coverage.
```

`.ig` signature stance:

```text
Classify stdlib/*.ig signatures as design-pressure only.
Record that current syntax is non-current for igc compile:
  Decimal[S]
  Collection[T]
  (T) -> Bool
  Option[T]
  GeoSignal / ScheduleFact / TimeSlot / AvailabilitySnapshot
Do not call these files accepted Igniter source or accepted stdlib API.
```

`igniter-vm` stance:

```text
Observe dependency readiness by reading Cargo.toml and/or recording the path
dependency only. Do not edit igniter-vm. Do not open VM intake inside C2-I.
```

---

## Proof Matrix

```text
STD-P1: Decimal FFI add/sub/mul/div behavior confirmed.
STD-P2: OOF-TC5 scale mismatch behavior confirmed.
STD-P3: OOF-DM2 division failure behavior confirmed.
STD-P4: Decimal division truncation and missing rounding policy documented.
STD-P5: Verifier scope narrowed or exact assertion set recorded.
STD-P6: Collections classified as internal Rust-only unless separately
        exported.
STD-P7: Temporal classified as domain-specific scheduling helper only.
STD-P8: `.ig` signatures classified as design-pressure and non-current syntax.
STD-P9: `runtime_implementation_id`, evidence class, authority status, and
        non-claims packet present.
STD-P10: `igniter-vm` dependency readiness observed without opening VM intake.
STD-P11: No mainline stdlib, runtime, API, CLI, package, RuntimeSmoke, or
         report changes.
STD-P12: Public/stable/production/reference/performance/portability claims
         remain closed.
```

---

## Required Command Matrix

```text
ruby playgrounds/igniter-lab/igniter-stdlib/verify_stdlib.rb
cargo test --manifest-path playgrounds/igniter-lab/igniter-stdlib/Cargo.toml
ruby playgrounds/igniter-lab/igniter-stdlib/proofs/
  stdlib_candidate_proof.rb
```

Command outputs may be summarized in the proof doc and summary JSON. Build
outputs must remain under the lab candidate or its existing build directories.

---

## Explicit Answers

Whether C2-I may begin:

```text
yes.
```

Whether writes under `playgrounds/igniter-lab/igniter-stdlib/**` are allowed:

```text
yes, for proof-local candidate proof work only.
```

Whether the mainline proof track doc may be written:

```text
yes, only:
igniter-lang/docs/tracks/experimental-stdlib-candidate-proof-v0.md
```

Whether `igniter-vm` may be edited:

```text
no.
```

Whether `igniter-lang/lib/**`, `bin/igc`, gemspec, README, public docs,
RuntimeSmoke, CompilerResult, or CompilationReport may be edited:

```text
no.
```

Whether verifier wording may be narrowed inside the lab candidate:

```text
yes, if it clarifies actual verifier scope and does not broaden claims.
```

Whether Rust unit tests or proof scripts may be added inside the lab candidate:

```text
yes.
```

Whether generated output may be called proof-local stdlib candidate evidence
only:

```text
yes. It must not be called public stdlib API, runtime support, Reference
Runtime support, production readiness, stable API, certification, or
portability evidence.
```

Whether VM intake remains held:

```text
yes.
```

Whether `igc run` Slice 1 remains held:

```text
yes.
```

Whether public/stable/production/Reference Runtime/Spark/release/performance
and portability claims remain closed:

```text
yes, all remain closed.
```

---

## Exact C2-I Boundary

```text
Card: S3-R238-C2-I
Skill: IDD Agent Protocol
Agent: [Implementation Agent]
Role: implementation-agent
Track: experimental-stdlib-candidate-proof-v0

Route: IMPLEMENT
Depends on:
- S3-R238-C1-A

Allowed write scope:
- playgrounds/igniter-lab/igniter-stdlib/**
- igniter-lang/docs/tracks/experimental-stdlib-candidate-proof-v0.md

Read-only / closed:
- playgrounds/igniter-lab/igniter-vm/**
- playgrounds/igniter-lab/igniter-runtime/**
- playgrounds/igniter-lab/igniter-compiler/**
- igniter-lang/lib/**
- igniter-lang/bin/igc
- igniter-lang/igniter_lang.gemspec
- igniter-lang/README.md
- igniter-lang/docs/README.md
- igniter-lang/docs/ruby-api.md
- igniter-lang/lib/igniter_lang/runtime_smoke.rb
- igniter-lang/lib/igniter_lang/compiler_result.rb
- igniter-lang/lib/igniter_lang/compilation_report.rb

Required deliverables:
- proof script under playgrounds/igniter-lab/igniter-stdlib/proofs/
- summary JSON under playgrounds/igniter-lab/igniter-stdlib/out/
  stdlib_candidate_proof/
- proof track doc in igniter-lang/docs/tracks/
- command matrix
- STD-P1..STD-P12 matrix
- closed-surface scan
```

---

## Closed Surfaces

```text
mainline stdlib replacement
public stdlib API
runtime/API/CLI/package changes
igc run widening
.igbin execution
compiler passport emission
RuntimeSmoke productization
public runtime support
Reference Runtime support
stable API
production readiness
Spark integration
release execution
public performance claims
official/reference status
alternative certification
portability guarantees
```
