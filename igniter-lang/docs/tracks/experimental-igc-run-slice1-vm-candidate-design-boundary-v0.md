# Experimental igc run Slice 1 VM Candidate Design Boundary v0

Card: S3-R241-C1-D
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-igc-run-slice1-vm-candidate-design-boundary-v0
Route: UPDATE
Status: done / design-ready-with-prerequisite
Date: 2026-06-03

Depends on:
- S3-R240-C4-A

---

## Decision

Design the pre-v1 experimental `igc run` Slice 1 boundary as a VM-candidate
selector boundary, but keep implementation authorization held until a narrow
VM capability/passport hardening proof closes.

Design status:

```text
Slice 1 design boundary: ready
Slice 1 implementation authorization: not ready yet
Immediate prerequisite: VM capability/passport hardening proof
```

Reason:

```text
R240 accepts `igniter-vm` as proof-local delegated experimental VM candidate
evidence. However the existing R232 Add.igapp passport is enough as passport
schema precedent only. Its runtime_implementation_id does not target the R240
Rust VM candidate, and no proof-local Slice 1 capability/passport binding exists
yet for `igniter.delegated.experimental.vm.rust-tokio.v0`.
```

This design does not authorize implementation, `igc run` widening, `.igbin`
execution, compiler passport emission, RuntimeSmoke productization, Reference
Runtime support, public runtime support, stable API, production readiness, Spark
integration, release evidence, public performance claims, alternative
certification, or portability guarantees.

---

## Inputs Read

```text
igniter-lang/docs/tracks/stage3-round240-status-curation-v0.md
igniter-lang/docs/tracks/
  experimental-igniter-vm-candidate-proof-acceptance-decision-v0.md
igniter-lang/docs/tracks/
  experimental-igniter-vm-candidate-proof-v0.md
playgrounds/igniter-lab/igniter-vm/out/
  vm_candidate_proof/summary.json
igniter-lang/docs/tracks/
  experimental-igc-run-slice0-implementation-acceptance-decision-v0.md
igniter-lang/docs/tracks/
  experimental-igc-run-slice0-implementation-v0.md
igniter-lang/experiments/experimental_igc_run_v0/out/summary.json
igniter-lang/lib/igniter_lang/cli.rb
igniter-lang/lib/igniter_lang/experimental_igc_run.rb
igniter-lang/docs/tracks/
  experimental-runtime-artifact-passport-manifest-proof-acceptance-decision-v0.md
igniter-lang/experiments/
  experimental_runtime_artifact_passport_manifest_v0/out/*.passport.json
igniter-lang/docs/tracks/
  experimental-runtime-artifact-passport-minimum-boundary-decision-v0.md
playgrounds/igniter-lab/igniter-vm/Cargo.toml
playgrounds/igniter-lab/igniter-vm/src/**
playgrounds/igniter-lab/igniter-vm/tests/**
playgrounds/igniter-lab/lab-docs/
  loops-and-recursion-pressure-package.md
```

---

## Slice 1 Boundary

Slice 1 should preserve the Slice 0 command spine:

```text
igc run ARTIFACT.igapp \
  --passport ARTIFACT.passport.json \
  --input INPUT.json \
  --runtime RUNTIME_SELECTOR \
  --out RESULT.json \
  --experimental
```

Slice 1 may design a second delegated experimental selector:

```text
delegated-experimental:igniter-vm-candidate
```

Selector meaning:

```text
selects proof-local delegated experimental VM candidate evidence only
does not name public runtime support
does not name Reference Runtime support
does not promise stable API
does not promise portability
does not imply package/release availability
```

The accepted R240 `runtime_implementation_id` remains evidence-facing metadata:

```text
igniter.delegated.experimental.vm.rust-tokio.v0
```

It may appear in machine-readable result packets, proof-local capability
manifests, and proof-local passports. It should not be the primary user-facing
CLI selector, because it looks more stable than the current pre-v1 evidence
allows.

---

## Input Artifact Policy

Slice 1 remains `.igapp` only.

Accepted:

```text
ARTIFACT.igapp directory
passport artifact_kind == igapp_dir
explicit --passport
explicit --input JSON object
explicit --runtime delegated-experimental:igniter-vm-candidate
explicit --out
explicit --experimental
```

Excluded:

```text
.igbin input
.igbin execution
implicit passport discovery
compiler passport emission
RuntimeSmoke fallback
default sample input
server/daemon/reactive/tbackend execution
```

`.igbin` may remain a future design/proof route, but it must not enter Slice 1
implementation authorization.

---

## Capability / Passport Requirement

Existing proof-local passport manifests are sufficient for Slice 1 design
vocabulary, but insufficient for Slice 1 VM-candidate execution authorization.

Why:

```text
Add.igapp.passport.json:
  artifact_kind: igapp_dir
  surface_dimension: executable_runtime
  runtime_target_kind: delegated_experimental_runtime
  runtime_implementation_id: igniter.delegated.experimental.ivm.c_resident

R240 VM candidate:
  runtime_implementation_id: igniter.delegated.experimental.vm.rust-tokio.v0
```

The mismatch is not a failure of either artifact. It means Slice 1 needs a
proof-local binding artifact before implementation authorization:

```text
artifact_ref / artifact_digest for the .igapp
runtime_implementation_id matching igniter.delegated.experimental.vm.rust-tokio.v0
capability_surface matching VMG accepted evidence
required_capabilities
required_opcodes or supported SemanticIR node subset
unsupported feature policy
input_contract
output_contract
failure_policy
authority_status
non_claims
producer_track
authorized_by
```

Compiler passport emission remains closed. The needed binding may be produced
only as proof-local metadata in a future hardening proof or implementation
authorization review.

---

## Runtime Specification Input

Runtime Specification input is needed as a check surface, but it does not need
to become the immediate Main Line route before Slice 1 hardening.

Slice 1 should require the next hardening route to classify each capability as:

```text
accepted proof-local VM evidence
accepted Slice 0 invariant
passport-required field
Runtime Specification input gap
unsupported / fail-closed
separate route
```

Known Runtime Specification pressure points:

```text
runtime selector naming
capability matching
unsupported feature failure code vocabulary
result packet shape
observation trace wording
branch silence expectation
temporal read expectation
```

If the hardening route finds that selector semantics or failure codes cannot be
specified without a normative Runtime Specification slice, redirect there before
implementation authorization.

---

## Capability Envelope

Slice 1 may only design around accepted R240 VM candidate evidence:

```text
Decimal add/sub/mul/div parity against R238 stdlib dependency context
AOT compiler lowering
stack/register execution
selected branch execution
non-selected branch silence
unsupported selected-path fail-closed behavior
unknown opcode / malformed input fail-closed behavior
OP_LOAD_AS_OF hash-based trace identifier wording
map-reduce aggregate evidence
closed-surface scan
```

Slice 1 must keep these out of scope:

```text
reactive listener execution
tbackend daemon execution
projection pipeline execution
public performance claims
runtime service loops
recursion
general-purpose language/runtime compatibility
alternative certification
portability guarantees
```

---

## Recursion / Loop Pressure

The loops-and-recursion package is accepted as pressure input only.

Classification:

```text
evidence source: lab pressure package
authority: none
Slice 1 blocker: no
Slice 1 implementation scope: excluded
recommended route: separate Runtime Specification / PROP-037+ pressure route
```

Reason:

```text
Loops, service loops, recursion, explicit fuel/decreases, tick.time, and
progression semantics are larger language/runtime questions. They should not be
smuggled into a bounded `igc run` VM-candidate selector slice.
```

Slice 1 result packets may record unsupported recursion/loop features as
fail-closed diagnostics if encountered, but Slice 1 must not implement or claim
loop/recursion support.

---

## Result Packet Shape

Slice 1 should extend the Slice 0 packet shape minimally:

```text
kind: experimental_igc_run_slice1_result
format_version
status
experimental: true
pre_v1: true
stable_api: false
artifact_ref
passport_ref
input_ref
runtime_selector: delegated-experimental:igniter-vm-candidate
runtime_implementation_id: igniter.delegated.experimental.vm.rust-tokio.v0
runtime_authority: non-canonical / delegated experimental / candidate only
capability_check
passport_check
outputs
diagnostics
non_claims
not_compiler_result: true
not_compilation_report: true
not_compatibility_report: true
not_receipt_sidecar: true
not_release_evidence: true
not_public_api_response_contract: true
```

Required non-claims:

```text
not stable API
not production ready
not public runtime support
not Reference Runtime support
not Spark integration
not release evidence
not public performance claim
not compiler passport emission
not RuntimeSmoke productization
not igc run general runtime support
not certified alternative implementation
not portability guarantee
```

---

## Boundary Matrix

| Surface | Slice 1 Design Stance |
| --- | --- |
| Command vocabulary | Preserve Slice 0 spine; design new selector only. |
| User-facing selector | `delegated-experimental:igniter-vm-candidate`; experimental alias only. |
| `runtime_implementation_id` | Evidence-facing metadata; not stable public selector. |
| Input artifact | `.igapp` directory only. |
| `.igbin` | Excluded; future output_contract design/proof route only. |
| Passport | Required, explicit, fail-closed; VM-specific proof-local binding needed before implementation authorization. |
| Compiler passport emission | Closed. |
| RuntimeSmoke | Closed; no fallback, no productization. |
| VM candidate | May be named as delegated experimental candidate evidence only. |
| Reactive/tbackend | Classified/skipped; no daemon/server execution. |
| Runtime Specification | Check input required; separate route only if hardening finds blockers. |
| Recursion/loops | Pressure input only; excluded from Slice 1. |
| Public runtime support | Closed. |
| Reference Runtime support | Closed. |
| Stable API / production / release | Closed. |
| Performance / portability / certification | Closed. |

---

## Explicit Answers

Whether Slice 1 design is ready:

```text
Yes, as a design boundary.
No, as direct implementation authorization.
```

Whether implementation authorization may open next or must wait:

```text
It should wait for a narrow VM capability/passport hardening proof.
```

Whether `igniter-vm` may be named by an experimental delegated selector:

```text
Yes, as `delegated-experimental:igniter-vm-candidate`, evidence-only and
pre-v1 only.
```

Whether `runtime_implementation_id` is user-facing, evidence-facing, or internal-only:

```text
Evidence-facing. It may appear in machine-readable proof/result metadata, but
should not be the primary CLI selector.
```

Whether proof-local passport manifests are enough for Slice 1 design:

```text
Yes, for design vocabulary and validation shape.
No, for implementation authorization against the Rust VM candidate, because the
current Add.igapp passport targets a different delegated implementation id.
```

Whether compiler passport emission is required before Slice 1:

```text
No. Compiler passport emission remains closed. Slice 1 should use proof-local
binding metadata only.
```

Whether `.igbin` remains excluded:

```text
Yes.
```

Whether Runtime Specification input blockers exist:

```text
No immediate blocker for design. Possible blockers may appear during
capability/passport hardening around selector semantics, failure codes, and
capability matching.
```

Whether recursion/loop pressure affects Slice 1 or remains separate:

```text
Separate. It is a Runtime Specification / PROP-037+ pressure input, not a Slice
1 implementation scope.
```

Whether public/stable/production/Reference Runtime/Spark/release/performance/portability claims remain closed:

```text
Yes. All remain closed.
```

---

## C4-A Recommendation

Recommend C4-A accept this design boundary with one blocking prerequisite before
implementation authorization.

Recommended C4-A decision:

```text
accept Slice 1 design boundary
do not open implementation authorization yet
route VM capability/passport hardening proof next
keep Runtime Specification input as a conditional redirect if hardening finds
selector/failure-code/capability blockers
```

Exact next route recommendation:

```text
Card: S3-R242-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-igc-run-slice1-vm-capability-passport-hardening-authorization-review-v0

Route: UPDATE
Depends on:
- S3-R241-C4-A

Goal:
Decide whether a bounded proof-local VM capability/passport hardening proof may
begin for experimental `igc run` Slice 1, producing evidence-only metadata that
binds an `.igapp` artifact to `igniter.delegated.experimental.vm.rust-tokio.v0`
and its accepted R240 capability envelope, without authorizing implementation,
compiler passport emission, `.igbin` execution, RuntimeSmoke productization,
public runtime support, Reference Runtime support, stable API, production,
Spark, release, public performance claims, certification, or portability
guarantees.
```

Implementation authorization remains explicitly closed until the hardening proof
is accepted or C4-A chooses a different bounded prerequisite route.
