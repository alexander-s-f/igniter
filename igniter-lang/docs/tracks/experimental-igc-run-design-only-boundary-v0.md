# Experimental igc run Design-Only Boundary v0

Card: S3-R233-C1-D
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-igc-run-design-only-boundary-v0
Route: UPDATE
Status: design-ready / implementation-authorization-review-next
Date: 2026-06-02

Depends on:
- S3-R232-C5-S

---

## Decision Shape

The pre-v1 experimental `igc run` boundary is design-ready.

This document does not authorize implementation. It defines the narrowest
honest command boundary that may be sent to a later implementation
authorization review.

Recommended C4-A decision:

```text
Accept the design boundary.
Open a later bounded implementation-authorization review for Slice 0.
Keep implementation closed until that review explicitly authorizes it.
```

Recommended next route:

```text
Card: S3-R234-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-igc-run-slice0-implementation-authorization-review-v0
Route: UPDATE
```

Slice 0 should be limited to:

```text
compiler-emitted .igapp input
explicit proof-local passport manifest input
explicit sample input JSON
delegated experimental runtime selector
machine-readable result packet
pre-v1 / no-stable-API / non-production wording
```

Slice 0 must not include:

```text
.igbin execution
compiler passport emission
implicit runtime discovery
Reference Runtime
RuntimeSmoke productization
Rust TBackend execution
benchmark/performance claims
Spark integration
release execution
stable API promises
```

---

## Inputs Read

- `igniter-lang/docs/tracks/stage3-round232-status-curation-v0.md`
- `igniter-lang/docs/tracks/experimental-runtime-artifact-passport-manifest-proof-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/experimental-runtime-artifact-passport-manifest-proof-v0.md`
- `igniter-lang/experiments/experimental_runtime_artifact_passport_manifest_v0/out/summary.json`
- `igniter-lang/experiments/experimental_runtime_artifact_passport_manifest_v0/out/Add.igapp.passport.json`
- `igniter-lang/experiments/experimental_runtime_artifact_passport_manifest_v0/out/add.igbin.aot.passport.json`
- `igniter-lang/experiments/experimental_runtime_artifact_passport_manifest_v0/out/if_module.igbin.resident.passport.json`
- `igniter-lang/experiments/experimental_runtime_artifact_passport_manifest_v0/out/quickstart_result.evidence_packet.passport.json`
- `igniter-lang/docs/tracks/experimental-executable-quickstart-acceptance-decision-v0.md`
- `igniter-lang/examples/experimental_executable_quickstart_v0/quickstart.rb`
- `igniter-lang/examples/experimental_executable_quickstart_v0/out/quickstart_result.json`
- `igniter-lang/lib/igniter_lang/cli.rb`
- `igniter-lang/bin/igc`
- `igniter-lang/lib/igniter_lang/compiler_orchestrator.rb`
- `igniter-lang/lib/igniter_lang/runtime_smoke.rb`
- `playgrounds/igniter-lab/igniter-runtime/docs/*`
- `playgrounds/igniter-lab/igniter-tbackend/src/main.rs`
- `playgrounds/igniter-lab/igniter-tbackend/src/kernel.rs`
- `playgrounds/igniter-lab/igniter-tbackend/src/packs/auth.rs`
- `playgrounds/igniter-lab/igniter-tbackend/src/packs/query.rs`
- `playgrounds/igniter-lab/igniter-tbackend/src/packs/mcp.rs`
- `playgrounds/igniter-lab/igniter-apps/benchmark-app/benchmark.rb`
- `playgrounds/igniter-lab/igniter-apps/benchmark-app/verify_bench.rb`

---

## Current Surface Facts

Current CLI surface:

```text
igc compile SOURCE --out OUT.igapp [--compiler-profile-source PATH.json]
```

Observed from `IgniterLang::CLI`:

```text
command accepted today: compile only
run command today: absent
unsupported command behavior: usage + false
```

Current compiler orchestration:

```text
CompilerOrchestrator#compile emits .igapp through Assembler.
RuntimeSmoke exists as a proof-backed callback path.
RuntimeSmoke is not an igc run surface.
CompilerResult.public_result is compile-result presentation only.
```

Accepted executable evidence:

```text
R223 quickstart:
  .ig source -> compile -> .igapp -> delegated experimental runtime -> sum 42
  14/14 checks PASS
  adapter_used: false
```

Accepted passport evidence:

```text
R232 passport manifest proof:
  16/16 PPM checks PASS
  generated .igapp passport
  generated .igbin AOT passport
  generated resident .igbin passport
  generated quickstart result packet passport
```

This is enough to design a command boundary. It is not enough to implement a
general run command without a separate authorization review.

---

## Boundary Principle

`igc run` should be a pre-v1 experimental executable convenience boundary over
existing evidence, not a new authority surface.

The command may orchestrate:

```text
artifact input
passport/readiness validation
sample input loading
delegated runtime invocation
result packet emission
```

The command must not decide:

```text
canonical runtime semantics
runtime certification
artifact portability
stable CLI/API shape
public performance status
Reference Runtime behavior
compiler passport emission
```

---

## Command Vocabulary

Preferred future Slice 0 command shape:

```text
igc run ARTIFACT.igapp \
  --passport ARTIFACT.passport.json \
  --input INPUT.json \
  --runtime delegated-experimental:ivm-proof \
  --out RESULT.json \
  --experimental
```

Required properties:

```text
--experimental is mandatory.
--passport is mandatory.
--input is mandatory.
--runtime is mandatory.
--out is mandatory for durable result evidence.
```

Rejected for Slice 0:

```text
igc run SOURCE.ig
igc run ARTIFACT.igbin
igc run --auto-runtime
igc run --reference-runtime
igc run --benchmark
igc run --spark
igc run without --experimental
```

Reason:

```text
SOURCE.ig implies compile+run and widens the command.
.igbin has deferred output_contract and incomplete source/SemanticIR chain.
auto-runtime implies discovery/defaulting authority.
reference-runtime implies a closed canonical surface.
benchmark/spark implies public or integration claims.
```

---

## Input Artifact Policy

Slice 0 accepted input:

```text
artifact_kind: igapp_dir
surface_dimension: executable_runtime
runtime_target_kind: delegated_experimental_runtime
authority_status: non-canonical / evidence-only
```

Slice 0 held input:

```text
artifact_kind: igbin_aot_binary
```

`.igbin` is held because both accepted `.igbin` passports still carry a
proof-local `output_contract` inference:

```text
deferred_rationale:
  hand-authored .igbin fixture; output contract cannot be derived without
  compiler SemanticIR chain.
```

`.igbin` can be reconsidered after a separate proof demonstrates a
compiler-backed bytecode chain with non-deferred output contract.

Evidence result packets:

```text
artifact_kind: evidence_result_packet
surface_dimension: evidence_packet
```

These may be read as prior evidence but must not be executed by `igc run`.

---

## Passport and Readiness Checks

Future Slice 0 implementation authorization should require `igc run` to fail
closed unless the supplied passport satisfies:

```text
passport_kind == artifact_passport
artifact_kind == igapp_dir
artifact_ref points to the supplied .igapp
artifact_digest matches recomputed .igapp digest
surface_dimension == executable_runtime
runtime_target_kind == delegated_experimental_runtime
authority_status contains non-canonical and evidence-only
non_claims includes stable API / production / public runtime / Reference
  Runtime / Spark / release / performance non-claims
input_contract is present
output_contract is present and not deferred
failure_policy is present
runtime_implementation_id is present as evidence metadata only
```

Readiness rejection examples:

```text
missing passport -> fail closed
passport artifact_ref mismatch -> fail closed
digest mismatch -> fail closed
authority_status missing non-canonical/evidence-only -> fail closed
artifact_kind != igapp_dir -> fail closed for Slice 0
runtime_target_kind != delegated_experimental_runtime -> fail closed
deferred output_contract -> fail closed for Slice 0
```

Compiler passport emission is not required before Slice 0. Slice 0 may consume
proof-local manifests explicitly passed by path. Compiler passport emission
remains closed.

---

## Runtime Selection Policy

Delegated runtimes may be named by an experimental command only as unstable
pre-v1 selector labels.

Allowed Slice 0 selector:

```text
delegated-experimental:ivm-proof
```

Meaning:

```text
Use the already accepted delegated experimental runtime evidence path.
The selector is not stable API.
The selector is not package identity.
The selector is not Reference Runtime identity.
The selector may be removed or renamed before v1.
```

Rejected selectors:

```text
reference
official
production
stable
spark
tbackend
benchmark
```

The design may mention the three-runtime model:

```text
Runtime Specification: normative design target, not implemented here.
Official Reference Implementation: future canonical candidate, closed.
Delegated Experimental Runtime: non-canonical executable learning path.
```

---

## Delegated Runtime Adapter Stance

Slice 0 may use a delegated runtime adapter only if it remains inside the
future implementation authorization scope.

Candidate future adapter stance:

```text
example/proof-local adapter allowed
explicit runtime selector required
no implicit RuntimeSmoke productization
no compiler/result/report field widening
no package/gemspec exposure
no public API promise
```

The adapter must preserve:

```text
lazy if_expr behavior where exercised
fail-closed malformed input behavior
no selected-path overclaim beyond supported expression/runtime subset
machine-readable result packet
```

---

## Output and Result Shape

Preferred Slice 0 result packet:

```json
{
  "kind": "experimental_igc_run_v0_result",
  "format_version": "0.1.0",
  "status": "ok | blocked | error",
  "experimental": true,
  "pre_v1": true,
  "stable_api": false,
  "artifact_ref": "...",
  "passport_ref": "...",
  "runtime_selector": "delegated-experimental:ivm-proof",
  "runtime_authority": "non-canonical / delegated experimental",
  "outputs": {},
  "diagnostics": [],
  "non_claims": []
}
```

Result packet rules:

```text
status ok means this bounded command ran successfully.
status ok does not mean public runtime support.
status ok does not mean production readiness.
diagnostics are local result explanations only.
non_claims are mandatory.
```

The result packet must not be:

```text
CompilerResult
CompilationReport
CompatibilityReport
release evidence
public API response contract
stable receipt sidecar
```

---

## Failure Policy

Future `igc run` Slice 0 should fail closed with local experimental result
status for:

```text
missing artifact
missing passport
malformed passport JSON
passport/artifact digest mismatch
unsupported artifact_kind
deferred output_contract
unsupported runtime selector
runtime adapter load failure
runtime evaluation failure
unsupported input shape
```

Failure vocabulary:

```text
blocked
unsupported
invalid_passport
artifact_digest_mismatch
runtime_unavailable
execution_failed
```

Do not introduce canonical diagnostics, report codes, or public error
vocabulary in Slice 0.

---

## Lab Backend and Benchmark Stance

`igniter-tbackend` belongs to backend/substrate vocabulary, not runtime
authority.

Classification:

```text
surface_dimension: temporal_backend
candidate role: delegated backend/substrate candidate signal
current authority: lab-only / unaccepted for Main Line runtime authority
```

Observed signals:

```text
AuthPack: opt-in auth/role middleware signal
QueryPack: temporal query_slice / pushdown signal
McpPack: stdio tool plane signal
```

These may inform future design, especially around temporal reads and tool
planes. They must not be pulled into Slice 0 `igc run`.

`benchmark-app` classification:

```text
surface_dimension: benchmark_consumer
current authority: lab-only / informational evidence only
```

Benchmark evidence may influence internal design tradeoffs. It must not create
public performance claims, package marketing claims, or release evidence.

---

## Boundary Matrix

| Surface | Slice 0 design stance | Authority |
| --- | --- | --- |
| `igc compile` | Existing command, unchanged | Current compiler CLI |
| `igc run` | Design-ready, implementation closed | Future authorization review only |
| `.igapp` | Preferred Slice 0 executable artifact | Requires explicit passport |
| `.igbin` | Held for Slice 0 | Needs compiler-backed output contract |
| Passport manifests | Required explicit metadata input | Evidence/compatibility metadata only |
| Compiler passport emission | Closed | No authority |
| Delegated runtime selector | Allowed as unstable pre-v1 label | Non-canonical evidence only |
| RuntimeSmoke | Closed | No productization |
| Reference Runtime | Closed | No support |
| Rust TBackend | Backend/substrate lab signal | No runtime authority |
| benchmark-app | Lab performance harness | No public performance authority |
| Result packet | Local experimental output | Not CompilerResult/report/receipt |
| Public docs/README | Closed | No public support claim |
| Spark/API/release | Closed | No integration or release claim |

---

## Implementation Authorization Prerequisites

C4-A may open a later implementation authorization review if C2-P1 and C3-X do
not find blockers.

Minimum future C1-A boundary should require:

```text
allowed write scope explicitly includes only CLI/run slice files and proof docs
no package/gemspec/public docs changes unless separately opened
no release execution
explicit command matrix
proof matrix for passport validation, run success, run failure, and closures
forbidden phrase scan
closed-surface scan
```

Candidate future write scope for authorization review to consider:

```text
igniter-lang/lib/igniter_lang/cli.rb
igniter-lang/bin/igc if needed
igniter-lang/experiments/experimental_igc_run_v0/**
igniter-lang/docs/tracks/experimental-igc-run-slice0-implementation-v0.md
```

This design does not authorize that write scope.

---

## Explicit Answers

Is an experimental `igc run` boundary design-ready?

```text
Yes.
```

May implementation authorization open next?

```text
Yes, as a later bounded implementation-authorization review only.
Implementation is not authorized by this card.
```

Are proof-local passport manifests a sufficient prerequisite?

```text
Yes for designing Slice 0 and for considering a narrow implementation
authorization review.

No for general artifact portability, .igbin execution, Reference Runtime, or
public runtime support.
```

Is compiler passport emission required before `igc run`?

```text
No for Slice 0 if an explicit proof-local passport path is required.
Compiler passport emission remains closed.
```

May delegated runtimes be named in an experimental command?

```text
Yes, only as unstable pre-v1 delegated runtime selector labels and only with
non-canonical wording.
```

Does `igniter-tbackend` belong to runtime, backend, or substrate vocabulary?

```text
Backend/substrate vocabulary.
It is a temporal backend candidate signal, not executable runtime authority.
```

May benchmark-app evidence influence design without public performance claims?

```text
Yes. It may inform internal tradeoffs only.
No public performance claim is created.
```

Do Reference Runtime, public runtime, stable API, production, Spark, release,
RuntimeSmoke productization, and public performance claims remain closed?

```text
Yes.
```

---

## C4-A Recommendation

Recommend:

```text
Accept design.
Open S3-R234-C1-A:
  experimental-igc-run-slice0-implementation-authorization-review-v0
```

Recommended C4-A guardrails:

```text
implementation remains closed until C1-A explicitly authorizes it
Slice 0 .igapp only
explicit passport path required
delegated runtime selector required
no .igbin
no compiler passport emission
no Reference Runtime
no RuntimeSmoke productization
no public runtime/stable/production/Spark/release/performance claims
```
