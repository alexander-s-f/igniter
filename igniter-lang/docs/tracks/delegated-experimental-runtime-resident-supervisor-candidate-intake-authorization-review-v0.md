# Delegated Experimental Runtime Resident Supervisor Candidate Intake Authorization Review v0

Card: S3-R230-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: delegated-experimental-runtime-resident-supervisor-candidate-intake-authorization-review-v0
Route: UPDATE
Status: authorized / playground-only-intake-proof
Date: 2026-06-01

Depends on:
- S3-R229-C5-S

---

## Decision

Authorize a bounded playground-only resident native supervisor candidate
intake/proof.

Authorized evidence class:

```text
resident-supervisor candidate intake evidence only
delegated experimental runtime candidate evidence only
playground-only non-canonical evidence
proof-local / pre-v1 / no stable API
```

Not authorized:

```text
mainline runtime implementation
igc run implementation
Reference Runtime support
public runtime support
RuntimeSmoke productization
stable API
production readiness
public demo
Spark integration
release evidence
public performance claims
C temporal backend authority
Rust TBackend authority
todolist app-consumer authority
ESP32/mesh promotion
artifact portability or certification claims
```

Next card authorized:

```text
S3-R230-C2-I
delegated-experimental-runtime-resident-supervisor-candidate-intake-v0
```

---

## Compact Decision Summary

```text
authorized
C2-I may begin in this round
writes under playgrounds/igniter-runtime/** are allowed
mainline proof track doc may be written
runtime id: igniter.delegated.experimental.ivm.c_resident
evidence label: resident_supervisor_candidate_intake
performance data: informational-only if measured
all mainline/runtime/API/CLI/public/release surfaces remain closed
```

---

## Inputs Read

- `igniter-lang/docs/tracks/stage3-round229-status-curation-v0.md`
- `igniter-lang/docs/tracks/experimental-runtime-implementations-and-portability-boundary-decision-v0.md`
- `igniter-lang/docs/tracks/experimental-runtime-implementations-and-portability-boundary-design-v0.md`
- `igniter-lang/docs/tracks/experimental-runtime-implementation-surface-and-candidate-facts-v0.md`
- `igniter-lang/docs/discussions/experimental-runtime-implementations-and-portability-boundary-pressure-v0.md`
- `igniter-lang/docs/tracks/experimental-runtime-implementation-status-model-v0.md`
- `igniter-lang/docs/tracks/delegated-experimental-runtime-ivm-aot-bytecode-file-loading-acceptance-decision-v0.md`
- `playgrounds/igniter-runtime/docs/resident_native_supervisor_research_report.md`
- `playgrounds/igniter-runtime/examples/ivm_resident_supervisor_proof.rb`
- `playgrounds/igniter-runtime/examples/ivm_aot_bytecode_file_loading_proof.rb`
- `playgrounds/igniter-runtime/lib/ivm/runner.c`
- `playgrounds/igniter-runtime/lib/ivm/**`
- `playgrounds/igniter-runtime/out/ivm_resident_supervisor_proof/**`
- `playgrounds/igniter-runtime/out/ivm_aot_bytecode_file_loading_proof/summary.json`

No proof or release commands were executed by this authorization review.

---

## Authorization Rationale

R228 accepted AOT `.igbin` file loading and identified a key architectural
signal:

```text
file-per-execution is I/O-bound
load-once / execute-many is the correct next runtime architecture question
```

R229 accepted the implementation arena boundary and routed resident supervisor
candidate intake next. The resident supervisor is the narrowest candidate that
directly answers the R228 bottleneck without needing to open `igc run`,
RuntimeSmoke, Reference Runtime, C temporal backend, Rust TBackend, or public
runtime authority.

The existing playground material shows the candidate shape:

```text
load_module(filepath, error_code) -> LoadedModule*
execute_module(module, inputs, error_code) -> int32 result
free_module(module) -> void
```

The proof still needs an accepted intake packet because current resident
supervisor material is off-track research, has no machine-readable intake
summary, and contains performance numbers that must be re-contextualized.

---

## Authorized C2-I Boundary

```text
Card: S3-R230-C2-I
Skill: IDD Agent Protocol
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: delegated-experimental-runtime-resident-supervisor-candidate-intake-v0
Route: UPDATE
```

Allowed write scope:

```text
playgrounds/igniter-runtime/**
igniter-lang/docs/tracks/delegated-experimental-runtime-resident-supervisor-candidate-intake-v0.md
```

Required result packet:

```text
playgrounds/igniter-runtime/out/resident_supervisor_candidate_intake/summary.json
```

Read-only / closed unless later explicitly authorized:

```text
igniter-lang/lib/**
igniter-lang/bin/igc
igniter-lang/igniter_lang.gemspec
igniter-lang/README.md
igniter-lang/docs/README.md
igniter-lang/docs/ruby-api.md
igniter-lang/lib/igniter_lang/runtime_smoke.rb
igniter-lang/lib/igniter_lang/compiler_result.rb
igniter-lang/lib/igniter_lang/compilation_report.rb
playgrounds/igniter-tbackend/**
playgrounds/igniter-apps/**
```

---

## Runtime Identity

Authorized provisional runtime id:

```text
igniter.delegated.experimental.ivm.c_resident
```

Status:

```text
evidence metadata only
not stable API
not package identity
not certification identity
not public runtime name
```

Evidence label:

```text
resident_supervisor_candidate_intake
```

Generated outputs may be called only:

```text
resident-supervisor candidate intake evidence
delegated experimental runtime candidate evidence
playground-only non-canonical evidence
```

---

## Capability Manifest Expectations

C2-I must emit a capability manifest in the summary packet.

Minimum fields:

```text
runtime_implementation_id
implementation_class
evidence_class
artifact_inputs
execution_model
resident_lifecycle
supported_opcodes
supported_expression_kinds
supports_aot_bytecode_file_input
supports_resident_module_loading
supports_load_once_execute_many
supports_if_expr_lazy_branching
supports_ruby_ivm_parity_subset
supports_temporal_read
temporal_backend_kind
failure_behavior
memory_lifecycle
trace_kind
unsupported_features
authority_status
non_claims
```

Required values / stances:

```text
implementation_class: delegated.experimental.runtime
artifact_inputs: .igbin proof-local file
execution_model: load_once_execute_many
resident_lifecycle: load_module / execute_module / free_module
supports_temporal_read: false for this C2-I unless explicitly proven without
  opening C temporal backend authority
temporal_backend_kind: none / excluded
trace_kind: proof-local only, if any
authority_status: non-canonical / evidence-only
```

---

## Resident Lifecycle Policy

C2-I must prove or structurally record:

```text
load_module reads and validates .igbin once
LoadedModule contains resident instruction memory
execute_module consumes a loaded module pointer and input buffer
same loaded module is executed more than once with different inputs
free_module is exercised or structurally proven
malformed module load fails closed before execute_module
```

Memory lifecycle stance:

```text
free_module must be called in the proof harness where a module is loaded.
No claim of production memory safety or leak-freedom may be made.
Memory behavior is proof-local C lifecycle evidence only.
```

---

## Proof Policy

Required proof matrix:

```text
RSUP-1: candidate source and entrypoints inventoried.
RSUP-2: runtime_implementation_id and evidence class recorded.
RSUP-3: capability manifest emitted.
RSUP-4: .igbin module loads once through resident supervisor lifecycle.
RSUP-5: same loaded module executes repeatedly without file reload.
RSUP-6: true-branch execution matches Ruby IVM oracle.
RSUP-7: false-branch execution matches Ruby IVM oracle.
RSUP-8: lazy branch semantics silence non-selected branch behavior.
RSUP-9: selected-path failure or invalid selected behavior fails closed.
RSUP-10: malformed file/module load fails closed before resident execution.
RSUP-11: free_module lifecycle is exercised or structurally proven.
RSUP-12: timing/performance data is informational-only and non-public.
RSUP-13: accepted R225-R228 evidence is not rewritten.
RSUP-14: C temporal backend, Rust TBackend, ESP32/mesh, and todolist remain
  separate routes.
RSUP-15: mainline closed-surface scan passes.
RSUP-16: public/stable/production/Spark/release/performance non-claims pass.
```

Ruby IVM parity policy:

```text
Parity is required only for the supported proof subset.
At minimum: true branch -> 42 and false branch -> 99 or equivalent fixture
from the existing resident supervisor proof.
```

Lazy branch policy:

```text
Proof must show branch selection through resident execution.
Non-selected branch behavior must remain silent by observable result or
structural jump evidence.
```

Malformed / fail-closed policy:

```text
Bad magic, bad version, file length mismatch, invalid opcode, out-of-bounds
jump, or equivalent malformed module cases must fail before resident execution
or be explicitly held as a follow-up blocker.
```

---

## Performance Wording Policy

Earlier resident supervisor reports contain performance numbers. C2-I must not
promote them.

Policy:

```text
Do not copy old performance numbers as accepted C2-I results.
If timing is remeasured, label it:
  informational research-signal / proof-local timing only.
Do not compare as public speedup.
Do not use public-performance language.
Do not put timing numbers in public docs, release notes, README, or stable API
wording.
```

Accepted terms:

```text
informational-only
proof-local timing
research signal
not a public performance claim
not a production benchmark
```

Forbidden terms:

```text
public performance
production performance
official speedup
certified throughput
Reference Runtime performance
stable benchmark
```

---

## Command Matrix

Required:

```text
ruby -c playgrounds/igniter-runtime/examples/ivm_resident_supervisor_proof.rb
ruby -Iplaygrounds/igniter-runtime/lib playgrounds/igniter-runtime/examples/ivm_resident_supervisor_proof.rb
ruby -c playgrounds/igniter-runtime/examples/ivm_aot_bytecode_file_loading_proof.rb
ruby -Iplaygrounds/igniter-runtime/lib playgrounds/igniter-runtime/examples/ivm_aot_bytecode_file_loading_proof.rb
git diff --check
git status --short
git -C playgrounds/igniter-runtime status --short
```

Optional read-only comparisons:

```text
ruby -rjson -e '...' playgrounds/igniter-runtime/out/ivm_aot_bytecode_file_loading_proof/summary.json
```

C2-I may adjust commands only if the actual playground structure requires it,
and must record the adjustment.

---

## Summary JSON Shape

Required top-level fields:

```text
track
evidence_label
evidence_class
runtime_implementation_id
capability_manifest
command_matrix
checks
accepted_evidence_immutability
performance_policy
non_claims
closed_surface_scan
recommended_next_route
```

`checks` must include `RSUP-1` through `RSUP-16` with machine-readable
`PASS` / `FAIL` / `HELD` status.

---

## Separate Route Stance

Remain separate and unauthorised by this C2-I:

```text
C temporal backend candidate intake
Rust TBackend candidate intake
ESP32/mesh research framing
todolist app-consumer surface intake
artifact passport minimum boundary
experimental igc run design-only route
```

C2-I may mention these only as closed or later route recommendations.

---

## Explicit Answers

| Question | Answer |
| --- | --- |
| May C2-I begin in this round? | Yes. |
| Are writes under `playgrounds/igniter-runtime/**` allowed? | Yes, bounded to resident supervisor candidate intake/proof outputs. |
| May the mainline proof track doc be written? | Yes: `igniter-lang/docs/tracks/delegated-experimental-runtime-resident-supervisor-candidate-intake-v0.md`. |
| Are `igniter-lang/lib/**`, `bin/igc`, gemspec, README, public docs, RuntimeSmoke, CompilerResult, or CompilationReport edits allowed? | No. All remain closed. |
| May resident supervisor use `igniter.delegated.experimental.ivm.c_resident`? | Yes, as provisional evidence metadata only. |
| May generated outputs be called resident-supervisor candidate intake evidence only? | Yes. That is the required label. |
| May performance numbers be copied from earlier reports? | No as accepted result. They may be referenced only as prior sandbox context or remeasured as informational/proof-local timing. |
| Do C temporal backend, Rust TBackend, ESP32/mesh, and todolist remain separate routes? | Yes. |
| Do `igc run`, Reference Runtime, stable API, production, public demo, Spark, release, and public performance claims remain closed? | Yes. |

---

## Non-Authorization

This decision does not authorize:

```text
mainline runtime/API/CLI/package changes
igc run implementation
Reference Runtime implementation
RuntimeSmoke productization
public runtime support
stable API
production readiness
public demo
Spark integration
release execution
public performance claims
C temporal backend authority
Rust TBackend authority
ESP32/mesh authority
todolist app-consumer authority
alternative implementation certification
portable artifact claims
```
