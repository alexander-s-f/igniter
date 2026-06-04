# Experimental Loops/Recursion Pressure and Spec Boundary v0

Card: S3-R245-C1-D
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-loops-recursion-pressure-and-spec-boundary-v0
Route: UPDATE
Status: done / recommend-spec-input-boundary-next
Date: 2026-06-04

Depends on:
- S3-R244-C5-S

---

## Decision Shape

The loops/recursion pressure is mature enough to become canonical design input,
but not mature enough to become implementation authority.

Recommended C4-A decision:

```text
accept loops/recursion pressure as specification input
keep lab implementation as frontier draft evidence only
open Runtime Specification / PROP-037+ input boundary next
hold implementation authorization
hold igc run widening
```

Rationale:

```text
R244 accepted Slice 1 docs exposure as Path C fail-closed evidence only.
The lab now shows concrete loops/recursion implementation pressure, but the
current evidence is mixed: source/code surfaces are ahead of the older pressure
return doc, while the observed lab compilation report still records unresolved
item/tick OOFs for loops_and_recursion.ig.

Therefore the useful next step is specification clarification, not executable
widening.
```

This card does not authorize code, `igc run` widening, `.igbin` execution,
compiler passport emission, RuntimeSmoke productization, public runtime support,
Reference Runtime support, stable API, production readiness, release evidence,
Spark integration, public demo, public performance claims, official/reference
status, alternative certification, or portability guarantees.

---

## Inputs Read

```text
igniter-lang/docs/tracks/stage3-round244-status-curation-v0.md
igniter-lang/docs/tracks/
  experimental-igc-run-slice1-quickstart-docs-acceptance-decision-v0.md
igniter-lang/docs/tracks/
  experimental-igc-run-slice1-vm-candidate-implementation-
  acceptance-decision-v0.md
igniter-lang/docs/tracks/
  experimental-igniter-vm-candidate-proof-acceptance-decision-v0.md
igniter-lang/docs/current-status.md
igniter-lang/source/loops_and_recursion.ig
igniter-lang/docs/proposals/
  PROP-037-external-progression-service-liveness-v0.md
igniter-lang/docs/tracks/
  prop037-external-progression-proposal-authoring-v0.md
playgrounds/igniter-lab/lab-docs/
  loops-and-recursion-pressure-package.md
playgrounds/igniter-lab/lab-docs/
  loops-and-recursion-pressure-package-return.md
playgrounds/igniter-lab/igniter-compiler/src/lexer.rs
playgrounds/igniter-lab/igniter-compiler/src/parser.rs
playgrounds/igniter-lab/igniter-compiler/src/classifier.rs
playgrounds/igniter-lab/igniter-compiler/src/typechecker.rs
playgrounds/igniter-lab/igniter-compiler/src/emitter.rs
playgrounds/igniter-lab/igniter-compiler/verify_loops.rb
playgrounds/igniter-lab/igniter-compiler/out/
  loops_and_recursion.compilation_report.json
playgrounds/igniter-lab/igniter-vm/src/instructions.rs
playgrounds/igniter-lab/igniter-vm/src/vm.rs
playgrounds/igniter-lab/igniter-vm/src/compiler.rs
```

No code, runtime, CLI, package, public docs, or playground files were edited.

---

## Boundary Finding

The pressure surface separates into three different concerns:

```text
1. Managed local repetition
   bounded collection loops, explicit max_steps, loop naming

2. Managed recursion
   recursion with explicit decreases fuel / termination witness

3. Service liveness
   service loop surface backed by PROP-037 progression semantics
```

These must not be collapsed.

`fold_stream` is already governed by stream/window semantics and does not prove
arbitrary loops. A service loop is not a local collection loop, not a stream
fold, and not a runtime scheduler. PROP-037 already defines the hard boundary:

```text
service loop is the surface
progression is the semantic substrate
```

The initial PROP-037 stance is metadata/capability first and does not introduce
a new `PROGRESSION` fragment class. That remains the correct default unless a
later proposal proves metadata is insufficient.

---

## Current Evidence Readout

The lab evidence is valuable because it is concrete, but it remains frontier
draft evidence only.

Observed support:

```text
lexer: loop / in / max_steps / decreases / fuel / clock / every keywords exist
parser: Loop and ServiceLoop body declarations exist
parser diagnostics: OOF-L1 unbounded loop, OOF-L2 now(), OOF-L3 unnamed loop
typechecker: OOF-L4 recursion without decreases fuel exists
emitter: loop and service_loop_node emitters exist
VM: OP_LOOP_START / OP_LOOP_STEP / OP_LOOP_BREAK / OP_LOAD_TICK exist
VM: loop fuel exhaustion and unresolved tick fail-closed errors exist
```

Observed caution:

```text
loops-and-recursion-pressure-package-return.md says loop/service-loop support is
a full gap, but current lab source has moved beyond that statement.

playgrounds/igniter-lab/igniter-compiler/out/
  loops_and_recursion.compilation_report.json
currently records pass_result=oof with unresolved item/tick diagnostics.
```

Implication:

```text
The lab is a strong pressure source, not accepted conformance evidence.
C2-P1 must verify the current lab code/results before C4-A treats any item as
accepted evidence.
```

---

## Design Stances

### Bounded Collection Loops

Bounded collection loops are ready as canonical design input.

Minimum design shape:

```text
loop Name in collection max_steps: N {
  ...
}
```

Required semantics:

```text
Name is required by Postulate 28.
collection must be finite or explicitly materialized.
max_steps is required as an execution guard, even when the collection is finite.
loop body does not create scheduler/liveness authority.
loop evidence must remain separate from fold_stream evidence.
```

### Recursion / decreases fuel

Recursion with explicit `decreases fuel` is ready as canonical design input, but
not as implementation authority.

Minimum design shape:

```text
def f(...) -> T decreases fuel {
  ...
}
```

Required semantics:

```text
recursive functions require an explicit termination witness;
missing witness should fail closed;
fuel semantics must be specification-defined before any canonical execution;
lab OOF-L4 is a useful draft diagnostic, not an accepted registry entry.
```

### Service Loop / tick.time

Service loops should remain tied to PROP-037 progression, not local loop
semantics.

Minimum design shape for discussion:

```text
loop tick in clock.every(5.seconds) {
  compute as_of = tick.time
}
```

Required stance:

```text
service loops are progression-backed liveness surfaces;
tick.time is an explicit deterministic binding;
service loops require progression source, materialization, receipt,
checkpoint/cancel/backpressure vocabulary before execution authority;
no new fragment class is accepted now.
```

### now() Prohibition

`now()` prohibition is ready as canonical design input.

Stance:

```text
now() must not appear as hidden time in contract/function bodies.
Time must be explicit through source/input/as_of/tick binding.
The exact OOF code should be registered in the next specification route.
```

### Loop Naming / Postulate 28

Loop naming is ready as canonical design input.

Stance:

```text
semantic loop blocks must have explicit names.
Names are needed for diagnostics, receipts, traces, and future proof packets.
```

### OOF Registry

The lab OOF-L draft set is useful, but not accepted as canonical.

Recommended draft registry input:

| Draft code | Candidate meaning |
| --- | --- |
| `OOF-L1` | Unbounded loop / missing `max_steps` |
| `OOF-L2` | Hidden `now()` in contract/function body |
| `OOF-L3` | Unnamed loop / Postulate 28 violation |
| `OOF-L4` | Recursion without `decreases fuel` |
| `OOF-L5` | Loop accumulator or body leaks disallowed ESCAPE dependency |
| `OOF-SL1` | Service loop without explicit clock/tick binding |
| `OOF-SL2` | Service loop hidden in CORE/pure boundary |

These should be routed into a specification/diagnostics registry route before
implementation authority.

---

## Boundary Matrix

| Surface | C1-D stance | Next need |
| --- | --- | --- |
| `fold_stream` | Existing stream/window concept; not arbitrary loop proof | Keep separate |
| `loop Name in coll max_steps: N` | Ready as design input | Runtime Specification / grammar text |
| `decreases fuel` recursion | Ready as design input | Termination/fuel semantics text |
| `loop tick in clock.every(...)` | Ready as PROP-037 service-loop input | Progression source/materialization stance |
| `tick.time` | Ready as explicit temporal binding input | Type/field and receipt wording |
| `now()` ban | Ready as design input | OOF registry and placement |
| Postulate 28 loop naming | Ready as design input | Grammar/diagnostic wording |
| Lab parser/typechecker/emitter/VM | Frontier draft evidence only | C2-P1 facts verification |
| `igc run` Slice 1 widening | Closed | Separate later authorization |
| `.igbin` execution | Closed | Separate output_contract route |

---

## Next Route Options

| Option | Value | Risk | Recommendation |
| --- | --- | --- | --- |
| Runtime Specification input slice | Converts pressure into canonical vocabulary | Could sprawl without PROP-037 focus | Prefer |
| PROP-037+ amendment / companion route | Places service loops/progression under existing proposal | Must avoid accepting implementation | Prefer with Runtime Spec slice |
| Proof-local loop/recursion fixture route | Useful after spec wording exists | Premature before OOF/semantics text | Later |
| Lab-only facts intake first | Clarifies stale-vs-current lab evidence | Does not settle spec | Already covered by C2-P1 in this round |
| VM capability/passport sidecar | Useful for runtime productization | Wrong order for language semantics | Hold |
| Pause | Avoids authority risk | Lets pressure drift | Do not prefer |

---

## Explicit Answers

Whether loops/recursion pressure changes sequencing:

```text
Yes. It should move the Main Line toward Runtime Specification / PROP-037+
spec input before any further executable widening.
```

Whether bounded loops are ready as canonical design input:

```text
Yes, as design input only.
```

Whether recursion with explicit fuel is ready as canonical design input:

```text
Yes, as design input only. Implementation and accepted OOF registry remain
closed.
```

Whether service loops require a progression fragment-class decision first:

```text
No new fragment class is required first. PROP-037 already prefers
metadata/capability first. Service-loop execution still requires progression
source/materialization/receipt/checkpoint/backpressure specification input
before implementation.
```

Whether `now()` prohibition and explicit clock/tick binding should open as
specification input:

```text
Yes.
```

Whether loop naming / Postulate 28 should open as specification input:

```text
Yes.
```

Whether OOF loop/recursion diagnostics should be routed into a registry route:

```text
Yes. Use lab OOF-L/OOF-SL names as draft input only.
```

Whether lab implementation evidence creates canonical authority:

```text
No.
```

Whether implementation authorization should open next or wait:

```text
Wait. The next route should be design/specification input, not implementation.
```

Whether `igc run` Slice 1 widening remains closed:

```text
Yes.
```

Whether public/stable/production/Reference Runtime/Spark/release/performance/
portability claims remain closed:

```text
Yes. All remain closed.
```

---

## Exact C4-A Recommendation

Recommend that S3-R245-C4-A accept this boundary with the following next route:

```text
Card: S3-R246-C1-D
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-loops-recursion-runtime-spec-and-prop037-input-slice-v0

Route type:
design / specification-input

Goal:
Turn accepted loops/recursion pressure into a compact Runtime Specification and
PROP-037+ input slice covering bounded local loops, recursion with explicit
fuel, service-loop/progression separation, tick.time binding, now() prohibition,
Postulate 28 loop naming, and draft OOF-L/OOF-SL registry vocabulary.

Closed:
implementation, igc run widening, .igbin execution, compiler passport emission,
RuntimeSmoke productization, public runtime support, Reference Runtime support,
stable API, production, Spark, release, public performance claims,
certification, and portability guarantees.
```

If C2-P1 finds the current lab facts are too inconsistent to support the above
route, C4-A should conditionally accept the boundary but insert a facts-rerun or
lab-only clarification route before R246.
