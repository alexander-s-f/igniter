# Experimental Runtime Artifact Passport Manifest Proof Acceptance Decision v0

Card: S3-R232-C4-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-runtime-artifact-passport-manifest-proof-acceptance-decision-v0
Route: UPDATE
Status: accepted / igc-run-design-only-boundary-next
Date: 2026-06-02

Depends on:
- S3-R232-C2-I
- S3-R232-C3-X

---

## Decision

Accept the proof-local artifact passport manifest evidence.

Accepted status:

```text
S3-R232-C2-I: PASS / 16 of 16 PPM checks pass
S3-R232-C3-X: PASS / no blockers / one watchpoint
Decision: accept proof-local manifest evidence
```

Generated manifests may be called only:

```text
proof-local artifact passport manifest evidence
evidence/compatibility metadata
non-canonical delegated experimental runtime evidence metadata
```

This acceptance creates no portability guarantee, no certification, no compiler
passport emission authority, no `igc run` implementation authority, no public
runtime support, no Reference Runtime support, no stable API, no production
readiness, no Spark integration, no release evidence, and no public
performance claim.

Next Main Line route:

```text
S3-R233-C1-D
experimental-igc-run-design-only-boundary-v0
```

This next route is design-only. It may define a pre-v1 experimental `igc run`
boundary, prerequisites, and closed surfaces. It must not authorize
implementation.

---

## Inputs Read

- `igniter-lang/docs/tracks/experimental-runtime-artifact-passport-manifest-proof-authorization-review-v0.md`
- `igniter-lang/docs/tracks/experimental-runtime-artifact-passport-manifest-proof-v0.md`
- `igniter-lang/docs/discussions/experimental-runtime-artifact-passport-manifest-proof-pressure-v0.md`
- `igniter-lang/experiments/experimental_runtime_artifact_passport_manifest_v0/out/summary.json`
- `igniter-lang/experiments/experimental_runtime_artifact_passport_manifest_v0/out/Add.igapp.passport.json`
- `igniter-lang/experiments/experimental_runtime_artifact_passport_manifest_v0/out/add.igbin.aot.passport.json`
- `igniter-lang/experiments/experimental_runtime_artifact_passport_manifest_v0/out/if_module.igbin.resident.passport.json`
- `igniter-lang/experiments/experimental_runtime_artifact_passport_manifest_v0/out/quickstart_result.evidence_packet.passport.json`
- `igniter-lang/docs/tracks/stage3-round231-status-curation-v0.md`
- `igniter-lang/docs/tracks/experimental-runtime-artifact-passport-minimum-boundary-decision-v0.md`

Local read-only validation also checked:

```text
ruby -c igniter-lang/experiments/
  experimental_runtime_artifact_passport_manifest_v0/
  experimental_runtime_artifact_passport_manifest_v0.rb
=> Syntax OK

ruby -rjson -e ... generated passport manifest JSON files
=> all four manifests parse; artifact_kind / surface_dimension /
   execution_substrate / authority_status / non_claims spot check passes

git status --short
=> clean before this decision doc
```

The full proof script was not rerun during C4-A because it would regenerate
proof outputs. C4-A accepts the C2-I recorded command matrix plus read-only
validation above.

---

## Exact Changed Files Accepted

Accepted from S3-R232-C2-I:

```text
igniter-lang/docs/tracks/experimental-runtime-artifact-passport-manifest-proof-v0.md
igniter-lang/experiments/experimental_runtime_artifact_passport_manifest_v0/
  experimental_runtime_artifact_passport_manifest_v0.rb
igniter-lang/experiments/experimental_runtime_artifact_passport_manifest_v0/out/
  Add.igapp.passport.json
igniter-lang/experiments/experimental_runtime_artifact_passport_manifest_v0/out/
  add.igbin.aot.passport.json
igniter-lang/experiments/experimental_runtime_artifact_passport_manifest_v0/out/
  if_module.igbin.resident.passport.json
igniter-lang/experiments/experimental_runtime_artifact_passport_manifest_v0/out/
  quickstart_result.evidence_packet.passport.json
igniter-lang/experiments/experimental_runtime_artifact_passport_manifest_v0/out/
  summary.json
```

Accepted from S3-R232-C3-X:

```text
igniter-lang/docs/discussions/experimental-runtime-artifact-passport-manifest-proof-pressure-v0.md
igniter-lang/docs/discussions/README.md
```

No `igniter-lang/lib/**`, `igniter-lang/bin/igc`, gemspec, README/public docs,
RuntimeSmoke, CompilerResult, CompilationReport, package, release, or
`playgrounds/igniter-lab/**` source/evidence mutation is accepted by this
decision.

---

## Command Matrix Result

Accepted from C2-I:

```text
ruby -c igniter-lang/experiments/
  experimental_runtime_artifact_passport_manifest_v0/
  experimental_runtime_artifact_passport_manifest_v0.rb
=> Syntax OK

ruby igniter-lang/experiments/
  experimental_runtime_artifact_passport_manifest_v0/
  experimental_runtime_artifact_passport_manifest_v0.rb
=> PASS — 16/16 checks pass
```

Local C4-A read-only syntax validation:

```text
ruby -c igniter-lang/experiments/
  experimental_runtime_artifact_passport_manifest_v0/
  experimental_runtime_artifact_passport_manifest_v0.rb
=> Syntax OK
```

---

## Generated Manifest Files

Accepted generated manifests:

```text
Add.igapp.passport.json
  artifact_kind: igapp_dir
  surface_dimension: executable_runtime
  execution_substrate: ruby_delegated_example_local_harness

add.igbin.aot.passport.json
  artifact_kind: igbin_aot_binary
  surface_dimension: executable_runtime
  execution_substrate: c_aot_file_loader

if_module.igbin.resident.passport.json
  artifact_kind: igbin_aot_binary
  surface_dimension: executable_runtime
  execution_substrate: c_resident_in_memory_module

quickstart_result.evidence_packet.passport.json
  artifact_kind: evidence_result_packet
  surface_dimension: evidence_packet
  execution_substrate: none
```

All four carry:

```text
authority_status: non-canonical / evidence-only
non_claims: 11 machine-readable entries
```

---

## PPM Result Record

| Check | Result | Acceptance note |
| --- | --- | --- |
| PPM-1 | PASS | Required minimum field families are present or explicitly deferred. W-1 noted below for evidence_packet `runtime_target_kind`. |
| PPM-2 | PASS | `.igapp` passport uses `artifact_kind: igapp_dir`. |
| PPM-3 | PASS | `.igbin` passports use canonical `artifact_kind: igbin_aot_binary`; no `igbin_file` value emitted. |
| PPM-4 | PASS | Artifact digest recomputation is deterministic. |
| PPM-5 | PASS | Source digest recorded when source-backed evidence exists. |
| PPM-6 | PASS | SemanticIR digest recorded when SemanticIR exists. |
| PPM-7 | PASS | Missing source/SemanticIR links on `.igbin` are explicit, not invented. |
| PPM-8 | PASS | Runtime/backend/app-consumer dimensions remain separated. |
| PPM-9 | PASS | `runtime_implementation_id` remains evidence metadata only. |
| PPM-10 | PASS | `execution_substrate` is present in all four generated manifests. |
| PPM-11 | PASS | `input_contract` and `failure_policy` are present. |
| PPM-12 | PASS | `output_contract` is derived for `.igapp`; explicitly deferred for `.igbin`. |
| PPM-13 | PASS | `evidence_class`, `authority_status`, and `non_claims` are machine-readable. |
| PPM-14 | PASS | Forbidden wording scan passes. |
| PPM-15 | PASS | Source artifact immutability preserved with recorded digests. |
| PPM-16 | PASS | Closed-surface scan passes. |

Accepted proof status:

```text
16/16 PASS
```

---

## Digest and Provenance Status

Accepted:

```text
source_digest -> semantic_ir_digest -> artifact_digest
```

for source/SemanticIR-backed `.igapp` evidence.

Accepted for `.igbin` evidence:

```text
source_digest: null / missing hand-authored fixture
semantic_ir_digest: null / missing hand-authored fixture
artifact_digest: recomputed sha256 over .igbin payload
```

C2-I correctly does not invent compiler provenance for hand-authored proof
bytecode fixtures.

Digest fields remain evidence integrity aids only. They do not create release
authority, signature authority, compatibility guarantees, or certification.

---

## Runtime / Backend / Consumer Separation Status

Accepted:

```text
surface_dimension separates executable_runtime and evidence_packet in this
proof.

runtime_implementation_id remains runtime-targeted evidence metadata only.

backend_implementation_id remains distinct and not applicable/deferred for
this proof.

consumer_surface_id remains distinct and not applicable/deferred for this
proof.
```

Rust TBackend remains held as a separate `temporal_backend` candidate intake.
acts-as-tbackend remains held as a separate `app_consumer_bridge` intake.
todolist remains held as a separate app-consumer/product path intake.

---

## output_contract Status

Accepted:

```text
Add.igapp:
  output_contract derived from SemanticIR outputs:
  sum: Integer

.igbin passports:
  output_contract explicitly deferred with rationale.
  Known outputs are proof-local inference only, not certified.
```

Carry-forward:

```text
Future igc run design-only route must treat deferred .igbin output_contract
as an open design gap.
igc run implementation remains closed.
```

---

## Authority and Non-Claims Status

Accepted machine-readable non-claims:

```text
not stable API
not production ready
not public runtime support
not Reference Runtime support
not Spark integration
not release evidence
not public performance claim
not certified alternative implementation
not artifact portability guarantee
not compiler passport emission
not igc run implementation
```

Forbidden wording scan status:

```text
PASS
0 hits in generated manifests and JSON
```

Public/stable/production/Spark/release/performance claims remain closed.

---

## Watchpoint

W-1:

```text
quickstart_result.evidence_packet.passport.json does not include
runtime_target_kind.
```

Accepted interpretation:

```text
For surface_dimension: evidence_packet, runtime_target_kind is contextually
not applicable. Its absence does not fail PPM-1 for this proof because C1-A
requires runtime_target_kind for executable runtime artifacts.
```

Carry-forward:

```text
Future passport schema versions should prefer explicit `not_applicable`
markers for contextually inapplicable fields instead of silent absence.
```

This is a watchpoint, not a blocker.

---

## Explicit Answers

Is proof-local passport manifest evidence accepted?

```text
Yes.
```

May generated manifests be called evidence/compatibility metadata only?

```text
Yes.
```

Does this create portability guarantees?

```text
No.
```

Does this create compiler passport emission authority?

```text
No.
```

May `igc run` design-only open next?

```text
Yes. The R231/R232 precondition is now met: at least one proof-local passport
manifest exists. The next route must remain design-only.
```

Does `igc run` implementation remain closed?

```text
Yes.
```

Should Runtime Specification or Rust TBackend intake open before `igc run`
design?

```text
No required blocker. Runtime Specification and Rust TBackend intake remain
valid later or parallel routes, but they do not need to precede the next
igc run design-only boundary.
```

Do Reference Runtime, public runtime support, stable API, production, Spark,
release, and public performance claims remain closed?

```text
Yes.
```

---

## Exact Next Dispatch Recommendation

Open:

```text
Card: S3-R233-C1-D
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-igc-run-design-only-boundary-v0
Route: UPDATE
```

Goal:

```text
Design the pre-v1 experimental `igc run` boundary now that proof-local
artifact passport manifests exist, without authorizing implementation.
```

Required carry-forward:

```text
implementation closed
compiler passport emission closed
Reference Runtime closed
public runtime support closed
stable API / production / Spark / release / performance claims closed
deferred .igbin output_contract is an open design gap
evidence_packet runtime_target_kind W-1 should be schema-not-applicable later
Rust TBackend / acts-as-tbackend / todolist remain separate intakes
```
