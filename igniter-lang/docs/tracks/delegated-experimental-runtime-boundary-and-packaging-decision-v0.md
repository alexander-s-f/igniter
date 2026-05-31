# Delegated Experimental Runtime Boundary And Packaging Decision v0

Card: S3-R224-C4-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: delegated-experimental-runtime-boundary-and-packaging-decision-v0
Route: UPDATE
Status: done / accepted-with-sequencing-redirect
Date: 2026-05-31

Depends on:
- S3-R224-C1-D
- S3-R224-C2-P1
- S3-R224-C3-X

---

## Decision Summary

Accept the delegated experimental runtime boundary/options recommendation and
the current-surface facts packet.

Accept the IVM candidate intake as a material late-arriving runtime signal:

```text
IVM is accepted as delegated experimental runtime candidate evidence only.
It is sandbox/playground-only, non-canonical, and not Reference Runtime.
```

Sequencing changes:

```text
Do not open reusable helper extraction first.
Open a playground-only .igapp -> IVM adapter authorization review next.
```

Reason:

```text
R223 proved executable quickstart through the proof RuntimeMachine.
R224 IVM intake proves a stronger bytecode runtime candidate, but not yet from
compiler-emitted .igapp.

The highest-leverage next question is therefore adapter fit:
can compiler output feed the IVM without touching mainline runtime surfaces?
```

---

## Inputs Read

- `igniter-lang/docs/tracks/delegated-experimental-runtime-boundary-and-packaging-options-v0.md`
- `igniter-lang/docs/tracks/delegated-experimental-runtime-current-surface-facts-v0.md`
- `igniter-lang/docs/discussions/delegated-experimental-runtime-boundary-pressure-v0.md`
- `igniter-lang/docs/tracks/delegated-experimental-runtime-ivm-candidate-intake-v0.md`
- `igniter-lang/docs/tracks/stage3-round223-status-curation-v0.md`
- playground verification context:
  `playgrounds/igniter-runtime/`

Note:

```text
The C3-X pressure verdict reviewed the reusable-helper route based on C1-D and
the current-surface facts packet. It did not pressure-review the later IVM
candidate intake. That does not invalidate C3-X; it narrows how far its next
route recommendation should be followed.
```

---

## Accepted Findings

### C1-D Boundary Options

Accepted.

C1-D correctly rejects:

- immediate `igc run`;
- RuntimeSmoke productization;
- Reference Runtime implementation;
- public package/runtime exposure;
- pause after executable evidence.

The reusable helper route remains valid, but no longer first in sequence after
the IVM intake.

### C2-P1 Current Surface Facts

Accepted as accurate facts basis.

Load-bearing facts:

- R223 quickstart executes through proof `CompiledProgram`, not RuntimeSmoke;
- `adapter_used: false`, so quickstart adapter/normalizer behavior is not
  proven reusable;
- examples and experiments are not packaged by the current gemspec;
- result JSON is example-local evidence, not public runtime API, report,
  receipt, cache record, or CompatibilityReport.

### C2-P1 IVM Candidate Intake

Accepted as supplemental material evidence.

Accepted:

- IVM sits beside the R223 quickstart harness;
- IVM does not replace accepted R223 evidence;
- IVM does not execute compiler-emitted `.igapp` yet;
- playground-only `.igapp -> IVM` adapter proof is the correct next pressure
  target;
- `lib/**`, `bin/igc`, gemspec, RuntimeSmoke, Reference Runtime, stable API,
  public runtime, production, Spark, and release surfaces remain closed.

Qualifier:

```text
Strong wording such as signed, tamper-evident, AT-10 compliant, or fully
bitemporal must not be promoted yet.

The currently proven IVM signal is timestamped observation-shaped valid-time
trace evidence with lazy branch behavior, not canonical audit/security or
transaction-time authority.
```

### C3-X Pressure Verdict

Accepted with scope qualifier.

C3-X proves the reusable helper route is safe if chosen. It does not require
that route to remain first after the IVM candidate intake.

---

## Route Decision

Next route:

```text
playground-only compiler-to-ivm adapter authorization review
```

Recommended next card:

```text
Card: S3-R225-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: delegated-experimental-runtime-compiler-to-ivm-adapter-authorization-review-v0
Route: UPDATE
```

Primary question:

```text
Can a compiler-emitted .igapp / semantic_ir_program.json artifact be mapped to
the playground IVM AST/bytecode path and executed through the IVM, while all
mainline runtime, API, CLI, package, and public surfaces remain closed?
```

Future/later routes:

- reusable helper authorization review remains valid after adapter proof;
- Runtime Specification slice may follow once repeated delegated semantics are
  observed;
- Reference Runtime boundary survey remains later;
- `igc run` remains design-only/future and closed to implementation.

Rejected for next:

- internal experimental runtime package design;
- pre-v1 `igc run` design;
- RuntimeSmoke productization;
- Reference Runtime boundary survey;
- keep example-local and pause.

---

## Candidate Next Boundary

If S3-R225-C1-A authorizes a proof card, the preferred C2-I boundary should be:

```text
Card: S3-R225-C2-I
Skill: IDD Agent Protocol
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: delegated-experimental-runtime-compiler-to-ivm-adapter-proof-v0
Route: UPDATE
```

Allowed write scope:

```text
playgrounds/igniter-runtime/**
igniter-lang/docs/tracks/delegated-experimental-runtime-compiler-to-ivm-adapter-proof-v0.md
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
igniter-lang/examples/experimental_executable_quickstart_v0/**
```

Expected proof matrix for the later proof card:

- compile or consume a compiler-emitted `.igapp` fixture;
- read `semantic_ir_program.json`;
- map supported nodes/operators into IVM AST or directly into IVM bytecode;
- execute through playground IVM;
- prove positive CORE Add path if supported by the artifact;
- prove at least one branch/lazy path if a compatible fixture exists;
- prove unsupported node kinds fail closed with playground-local error only;
- prove non-selected branch remains non-evaluated when using IVM jumps;
- prove no `lib/**`, `bin/igc`, RuntimeSmoke, result/report, gemspec, README,
  public docs, Spark, release, or package surface mutation;
- record whether adapter is direct, partial, or blocked by artifact shape;
- record valid-time trace evidence carefully without signed/tamper/bitemporal
  overclaim.

Required command matrix should include at minimum:

```text
ruby -Ilib examples/demo.rb
ruby -c playgrounds/igniter-runtime/examples/compiler_to_ivm_adapter_proof.rb
ruby -Iplaygrounds/igniter-runtime/lib playgrounds/igniter-runtime/examples/compiler_to_ivm_adapter_proof.rb
git diff --check
```

The authorization review may adjust names and commands to match the actual
playground structure.

---

## Explicit Answers

| Question | Answer |
| --- | --- |
| Are delegated runtime boundary/options accepted? | Yes. C1-D is accepted. |
| Does runtime momentum change sequencing again? | Yes. The IVM intake changes the best next route from reusable helper extraction to `.igapp -> IVM` adapter authorization review. |
| May implementation authorization open next? | Yes, only as a future authorization review for a playground-only adapter proof. This C4-A does not authorize implementation. |
| Does CLI `run` remain closed? | Yes. `igc run` remains closed to implementation and public CLI claims. |
| Does RuntimeSmoke productization remain closed? | Yes. RuntimeSmoke source/result shape and productization remain closed. |
| Does Reference Runtime remain closed? | Yes. IVM is not Reference Runtime and does not open Reference Runtime implementation. |
| Do stable API, production, public demo, Spark, and release claims remain closed? | Yes. All remain closed. |
| Is public runtime support opened? | No. Generated outputs may be described only as delegated experimental runtime evidence. |
| Is reusable helper work rejected? | No. It is deferred until adapter fit is tested or explicitly reselected. |

---

## Compact Decision Packet

```text
[D]
- Accept C1-D boundary/options.
- Accept current-surface facts.
- Accept IVM as sandbox-only delegated experimental runtime candidate evidence.
- Redirect next route to playground-only .igapp -> IVM adapter authorization
  review.

[S]
- R223 executable quickstart remains accepted.
- IVM demo signal is strong for lazy bytecode execution, but not yet .igapp-fed.
- C3-X helper route safety remains useful but no longer controls first next
  step after the IVM intake.

[T]
- No code or release command executed by this card.
- Playground demo was previously verified as executable evidence only.

[R]
- Do not overclaim signed/tamper-evident/bitemporal/AT-10 authority.
- Keep helper extraction, RuntimeSmoke productization, igc run, Reference
  Runtime, and package exposure closed until later gates.

[Next]
- S3-R225-C1-A:
  delegated-experimental-runtime-compiler-to-ivm-adapter-authorization-review-v0
```

---

## Closed Surfaces

Remain closed:

- `igniter-lang/lib/**`;
- `igniter-lang/bin/igc`;
- gemspec/package metadata;
- README/public docs/body spec;
- RuntimeSmoke productization, source changes, or result-shape changes;
- CompilerResult / CompilationReport / report / receipt / cache authority;
- Reference Runtime;
- Runtime Specification implementation;
- public runtime support;
- stable API / v1 compatibility claim;
- production readiness;
- public demo claim;
- Spark integration;
- release execution.
