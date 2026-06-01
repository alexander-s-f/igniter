# Delegated Experimental Runtime Resident Supervisor Candidate Intake Acceptance Decision v0

Card: S3-R230-C4-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: delegated-experimental-runtime-resident-supervisor-candidate-intake-acceptance-decision-v0
Route: UPDATE
Status: accepted / artifact-passport-minimum-boundary-next
Date: 2026-06-01

Depends on:
- S3-R230-C2-I
- S3-R230-C3-X

---

## Decision

Accept the resident native supervisor candidate intake evidence.

Accepted evidence label:

```text
resident_supervisor_candidate_intake
```

Accepted evidence class:

```text
resident-supervisor candidate intake evidence only
delegated experimental runtime candidate evidence only
playground-only non-canonical evidence
```

Accepted provisional runtime implementation id:

```text
igniter.delegated.experimental.ivm.c_resident
```

Binding interpretation:

```text
runtime_implementation_id is evidence metadata only
not stable API
not package identity
not certification identity
not public runtime name
not Reference Runtime support
```

Next Main Line route:

```text
experimental-runtime-artifact-passport-minimum-boundary-v0
```

This next route should be design/boundary work for minimum artifact passport
metadata before any `igc run` implementation route. It must not authorize
runtime implementation, public runtime support, Reference Runtime support,
release execution, or public claims.

---

## Compact Summary

```text
accepted
RSUP-1..RSUP-16: 16/16 PASS
resident lifecycle accepted as playground-only candidate evidence
load-once / execute-many accepted as proven for the candidate path
Ruby IVM parity accepted for the proved branch fixture
lazy branch semantics accepted for the resident supervisor path
malformed / unsupported behavior accepted as fail-closed
free_module memory lifecycle exercised as proof-local C lifecycle evidence
performance numbers accepted only as informational research-signal
R225-R228 accepted evidence remains immutable
all mainline/runtime/API/CLI/public/release surfaces remain closed
artifact passport minimum boundary opens next
```

---

## Inputs Read

- `igniter-lang/docs/tracks/delegated-experimental-runtime-resident-supervisor-candidate-intake-authorization-review-v0.md`
- `igniter-lang/docs/tracks/delegated-experimental-runtime-resident-supervisor-candidate-intake-v0.md`
- `igniter-lang/docs/discussions/delegated-experimental-runtime-resident-supervisor-candidate-intake-pressure-v0.md`
- `playgrounds/igniter-runtime/out/resident_supervisor_candidate_intake/summary.json`
- `igniter-lang/docs/tracks/stage3-round229-status-curation-v0.md`
- `igniter-lang/docs/tracks/experimental-runtime-implementations-and-portability-boundary-decision-v0.md`

Local validation performed by this decision:

```text
ruby -rjson -e ... playgrounds/igniter-runtime/out/resident_supervisor_candidate_intake/summary.json
git status --short
git -C playgrounds/igniter-runtime status --short
```

Observed validation result:

```text
resident_supervisor_candidate_intake igniter.delegated.experimental.ivm.c_resident 16/16 RSUP-1-RSUP-16
parent repo status: clean before this decision doc
playgrounds/igniter-runtime status: clean before this decision doc
```

---

## Accepted Evidence Record

Exact C2-I changed / produced files recorded by the proof output:

```text
igniter-lang/docs/tracks/delegated-experimental-runtime-resident-supervisor-candidate-intake-v0.md
playgrounds/igniter-runtime/examples/resident_supervisor_candidate_intake_proof.rb
playgrounds/igniter-runtime/out/resident_supervisor_candidate_intake/summary.json
playgrounds/igniter-runtime/out/resident_supervisor_candidate_intake/if_module.igbin
playgrounds/igniter-runtime/out/resident_supervisor_candidate_intake/bad_magic.igbin
playgrounds/igniter-runtime/out/resident_supervisor_candidate_intake/truncated.igbin
playgrounds/igniter-runtime/out/resident_supervisor_candidate_intake/unsupported_module.igbin
playgrounds/igniter-runtime/out/resident_supervisor_candidate_intake/librunner.dylib
```

Command matrix result:

```text
syntax_check_proof: PASS
run_proof: PASS
syntax_check_aot: PASS
run_aot: PASS
git_diff_check: PASS
git_status_short: PASS
git_playground_status: PASS
```

RSUP result:

```text
RSUP-1: PASS  candidate source and entrypoints inventoried
RSUP-2: PASS  runtime_implementation_id and evidence class recorded
RSUP-3: PASS  capability manifest emitted
RSUP-4: PASS  .igbin module loads once through resident supervisor lifecycle
RSUP-5: PASS  same loaded module executes repeatedly without file reload
RSUP-6: PASS  true-branch execution matches Ruby IVM oracle
RSUP-7: PASS  false-branch execution matches Ruby IVM oracle
RSUP-8: PASS  lazy branch semantics silence non-selected branch behavior
RSUP-9: PASS  selected-path failure / invalid selected behavior fails closed
RSUP-10: PASS malformed file/module load fails closed before resident execution
RSUP-11: PASS free_module lifecycle is exercised or structurally proven
RSUP-12: PASS timing/performance data is informational-only and non-public
RSUP-13: PASS accepted R225-R228 evidence is not rewritten
RSUP-14: PASS C temporal, Rust TBackend, ESP32/mesh, todolist separate routes
RSUP-15: PASS mainline closed-surface scan passes
RSUP-16: PASS public/stable/production/Spark/release/performance non-claims pass
```

---

## Acceptance Details

Runtime identity status:

```text
accepted as evidence metadata only
runtime_implementation_id: igniter.delegated.experimental.ivm.c_resident
not stable API
not package identity
not certification identity
```

Capability manifest status:

```text
accepted for intake comparison
implementation_class: delegated.experimental.runtime
artifact_inputs: .igbin proof-local file
execution_model: load_once_execute_many
resident_lifecycle: load_module / execute_module / free_module
authority_status: non-canonical / evidence-only
```

Resident lifecycle status:

```text
accepted as playground-only candidate evidence
load_module loads and validates the module once
execute_module runs the resident module repeatedly
free_module is exercised as proof-local memory lifecycle evidence
```

Load-once / execute-many status:

```text
accepted for the resident supervisor candidate path
not accepted as public runtime architecture
not accepted as Reference Runtime architecture
```

Ruby IVM parity status:

```text
accepted for the proved branch fixture
flag=true returns 42
flag=false returns 99
```

Lazy branch semantics status:

```text
accepted for the resident supervisor path
non-selected branch behavior remains silent in the proved fixture
live runtime non-selected branch evaluation remains closed unless separately authorized
```

Malformed / fail-closed status:

```text
accepted
bad magic fails before resident execution
truncated module fails before resident execution
unsupported selected opcode fails closed
```

Memory lifecycle / free status:

```text
accepted as proof-local C lifecycle evidence only
manual free_module path is exercised
no production memory-safety claim is created
```

Performance wording status:

```text
accepted only as informational research-signal / proof-local timing
no public speedup claim
no production benchmark
no Reference Runtime metric
```

Non-blocking acceptance note:

```text
C3-X AN-1 is accepted.
Future timing prose should apply inline rough / informational-only qualifiers
to ratios such as 15.6x or 1.6x, not rely only on a caution block.
This is not a blocker for C2-I acceptance.
```

Accepted R225-R228 evidence immutability status:

```text
r225_adapter_fit: PASS
r226_branch_hardening: PASS
r227_ffi_acceleration: PASS
r228_aot_file_loading: PASS
```

Separate-route status:

```text
C temporal backend: held / separate candidate intake required
Rust TBackend: held / separate candidate intake required
ESP32/mesh: comparison-only research, no authority
todolist app-consumer surface: held / separate intake required
```

Closed-surface scan status:

```text
PASS
igniter-lang/lib/** remains closed
igniter-lang/bin/igc remains closed
gemspec remains closed
README and public docs remain closed
RuntimeSmoke remains closed
CompilerResult and CompilationReport remain closed
mainline runtime/API/CLI/package surfaces remain closed
```

---

## Explicit Answers

Whether resident supervisor candidate intake is accepted:

```text
Yes. Accepted as resident-supervisor candidate intake evidence only.
```

Whether generated outputs may be called resident-supervisor candidate intake
evidence only:

```text
Yes. That is the only accepted label.
```

Whether this is Reference Runtime support:

```text
No.
```

Whether this is public runtime support:

```text
No.
```

Whether this creates public performance claims:

```text
No. Timing data is informational proof-local research signal only.
```

Whether `igc run` remains closed:

```text
Yes. Implementation remains closed.
```

Whether RuntimeSmoke productization remains closed:

```text
Yes.
```

Whether artifact passport minimum boundary should open next:

```text
Yes. Open artifact passport minimum boundary next.
```

Whether C temporal backend / Rust TBackend / todolist routes remain held or
open next:

```text
C temporal backend: held, separate later intake
Rust TBackend: held, separate later intake
todolist app-consumer surface: held, separate later intake
```

Whether stable API, production, public demo, Spark, release, and public
performance claims remain closed:

```text
Yes. All remain closed.
```

---

## Next Dispatch Recommendation

```text
Card: S3-R231-C1-D
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-runtime-artifact-passport-minimum-boundary-v0
Route: UPDATE

Goal:
Design the minimum artifact passport boundary for experimental executable
runtime evidence after accepted delegated runtime candidate intakes, without
authorizing igc run implementation, Reference Runtime support, public runtime
support, stable API, production readiness, Spark integration, release evidence,
or public performance claims.

Primary focus:
- minimum artifact passport fields;
- runtime_implementation_id and capability matching stance;
- artifact digest/source digest/SemanticIR digest stance;
- evidence class and authority status stance;
- portability non-claims;
- relationship to delegated runtime candidates;
- igc run design-only prerequisites.

Closed:
- implementation;
- mainline runtime/API/CLI/package changes;
- RuntimeSmoke productization;
- Reference Runtime;
- public runtime support;
- stable API / production / Spark / release / public performance claims.
```
