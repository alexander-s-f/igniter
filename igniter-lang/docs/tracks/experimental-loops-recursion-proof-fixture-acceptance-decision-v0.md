# Experimental Loops/Recursion Proof Fixture Acceptance Decision v0

Card: S3-R248-C4-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-loops-recursion-proof-fixture-acceptance-decision-v0
Route: UPDATE
Status: conditional-accepted
Date: 2026-06-04

Depends on:
- S3-R248-C2-I
- S3-R248-C3-X

---

## Decision

Conditionally accept the proof-local loops/recursion fixture evidence.

Decision:

```text
conditional accept proof-local fixture evidence
route PROP-039+ managed local recursion / loop-class authoring next
```

Accepted only as:

```text
proof-local specification fixture evidence
design-input pressure for PROP-039+ and OOF follow-up
non-executable fixture packet
```

Not accepted as:

```text
implementation authority
parser support
TypeChecker support
SemanticIR support
runtime support
API/CLI/package authority
igc run widening
.igapp execution
.igbin execution
compiler passport emission
RuntimeSmoke productization
public runtime support
Reference Runtime support
stable API
production readiness
Spark integration
release evidence
public demo evidence
public performance evidence
official/reference status
alternative certification
portability guarantee
lab behavior as canon
```

Rationale:

```text
S3-R248-C2-I stayed inside the C1-A authorized proof-local fixture boundary and
produced the required manifest, fixture files, summary JSON, and LRF matrix.

S3-R248-C3-X returned CONDITIONAL PASS: no scope violation, no forbidden claims,
and no lab-to-canon leakage, but three semantic fidelity issues must be recorded
before the packet can safely guide PROP-039+ authoring.
```

---

## Accepted Files

C2-I changed / added:

- `igniter-lang/docs/tracks/experimental-loops-recursion-proof-fixture-v0.md`
- `igniter-lang/experiments/experimental_loops_recursion_spec_fixtures_v0/manifest.json`
- `igniter-lang/experiments/experimental_loops_recursion_spec_fixtures_v0/out/summary.json`
- `igniter-lang/experiments/experimental_loops_recursion_spec_fixtures_v0/fixtures/bounded_local_collection_loop.ig`
- `igniter-lang/experiments/experimental_loops_recursion_spec_fixtures_v0/fixtures/recursion_decreases_fuel.ig`
- `igniter-lang/experiments/experimental_loops_recursion_spec_fixtures_v0/fixtures/service_loop_clock_tick_time.ig`
- `igniter-lang/experiments/experimental_loops_recursion_spec_fixtures_v0/fixtures/source_level_now_prohibited.ig`
- `igniter-lang/experiments/experimental_loops_recursion_spec_fixtures_v0/fixtures/unnamed_loop_robustness.ig`
- `igniter-lang/experiments/experimental_loops_recursion_spec_fixtures_v0/fixtures/break_deferred_unsupported.ig`
- `igniter-lang/experiments/experimental_loops_recursion_spec_fixtures_v0/fixtures/clock_every_not_stream_evidence.md`

C3-X pressure review:

- `igniter-lang/docs/discussions/r248-loops-recursion-proof-fixture-pressure-v0.md`

This C4-A decision adds:

- `igniter-lang/docs/tracks/experimental-loops-recursion-proof-fixture-acceptance-decision-v0.md`

---

## Required Record Items

### 1. `tick.event_id` Is Not Accepted Spec Input

`service_loop_clock_tick_time.ig` introduces `tick.event_id` as a source-level
accessor. This is beyond the R247-accepted `tick.time` binding and is not in
PROP-037 or the R247 wording sync.

Decision:

```text
tick.event_id is accepted as fixture pressure only
tick.event_id is not accepted source-level spec input for R248
```

Future PROP-037 companion or PROP-039+ authoring must decide whether `tick`
exposes a structured accessor object and which fields it carries.

### 2. `recursive contract` With Fuel Modifiers Is Ambiguous

`recursion_decreases_fuel.ig` uses:

```text
recursive contract ... decreases fuel max_steps 100
```

Ch13 separates:

- `StructuralRecursion`: `recursive contract` with `decreases <variant>`;
- `FuelBoundedRecursion`: `fuel_bounded contract` / `max_steps N`.

Decision:

```text
the fixture intent is accepted as Ch13 / PROP-039+ evidence
the grammar form is not accepted as canonical
```

PROP-039+ authoring must resolve whether `decreases fuel` in a `recursive
contract` form is a unified class, a modifier, or a mistaken conflation.

### 3. `for ... max_steps: claims.count` Requires PROP-039+ Resolution

`bounded_local_collection_loop.ig` uses:

```text
for ... max_steps: claims.count
```

This creates two design questions:

- whether `for` accepts `max_steps`, or whether `max_steps` is reserved for
  `loop` forms only;
- whether `max_steps` accepts dynamic expressions, or must be a static literal.

Decision:

```text
the fixture is accepted as bounded local loop pressure
the grammar shape is not accepted as canonical
```

PROP-039+ authoring must resolve the keyword and static-vs-dynamic
`max_steps` policy before implementation authorization can open.

---

## Acceptance Record

| Surface | Decision |
| --- | --- |
| C3-X pressure verdict | Accepted: conditional-pass with three required record items. |
| Command matrix | Accepted as PASS. |
| LRF-1..LRF-16 | Accepted as PASS with the three semantic fidelity notes above. |
| Fixture provenance | Accepted. All fixtures are proof-local and under the experiment directory. |
| Bounded local loop fixture | Accepted as Ch13 / future PROP-039+ input only; grammar form remains unresolved. |
| Recursion / `decreases fuel` fixture | Accepted as Ch13 / future PROP-039+ input only; class/keyword split remains unresolved. |
| Service-loop / `tick.time` fixture | Accepted as PROP-037 progression descriptor input only; `tick.event_id` remains unaccepted pressure. |
| `now()` prohibition fixture | Accepted as Ch8 `OOF-L6` wording anchor only. |
| `clock.every` non-stream status | Accepted. `clock.every` is not `Stream[DateTime]`. |
| Postulate 28 / unnamed-loop robustness | Accepted as future diagnostic pressure only. |
| `break` deferral | Accepted as deferred / unsupported pressure only. |
| OOF-L / OOF-R registry status | No registry authority created. |
| Lab evidence authority | Frontier evidence only. |
| Closed-surface scan | Accepted. Closed surfaces remain closed. |

---

## Explicit Answers

### Is proof-local loop/recursion fixture evidence accepted?

Yes. It is conditionally accepted as proof-local specification fixture evidence
with the three required record items above.

### May generated/touched outputs be called proof-local specification fixture evidence?

Yes. They may be called proof-local specification fixture evidence only.

### Does this create implementation authority?

No. Implementation remains closed.

### Does this create parser/typechecker/runtime support?

No. Parser, TypeChecker, SemanticIR, runtime, API, CLI, and package support
remain unclaimed and unauthorized.

### May PROP-039+ proposal authoring open next?

Yes. PROP-039+ managed local recursion / loop-class authoring should open next.
It must use this fixture packet as design-input evidence and must explicitly
resolve the three C4-A record items.

### Should OOF registry / errata follow-up open next?

Not as the immediate Main Line route. OOF naming and registry reconciliation
should be included as a required section inside the PROP-039+ authoring route,
with a later registry/errata route only if authoring proves it needs a separate
lane.

### Does lab behavior create canonical authority?

No. Lab behavior remains frontier evidence only.

### Does `igc run` widening remain closed?

Yes. `igc run` widening remains closed.

### Do protected claims remain closed?

Yes. `.igbin`, `.igapp` execution, compiler passport emission, RuntimeSmoke,
public runtime, Reference Runtime, stable API, production, Spark, release,
public demo, public performance, official/reference status, alternative
certification, and portability claims remain closed.

---

## Compact Decision Summary

[D] Conditionally accept R248 proof-local loops/recursion fixture evidence.

[S] The fixture packet is useful and cleanly scoped: it stays under
`experiments/**`, produces manifest/summary JSON, avoids generated runtime
artifacts, and keeps all implementation/public/reference claims closed.

[T] LRF-1..LRF-16 are accepted as PASS. C3-X identified three non-blocking but
binding semantic fidelity notes: `tick.event_id`, `recursive contract` with fuel
modifiers, and `for ... max_steps: claims.count`.

[R] Open PROP-039+ managed local recursion / loop-class authoring next. Keep all
implementation, runtime, CLI, release, performance, certification, and
portability authority closed.

---

## Exact Next Dispatch Recommendation

Open:

```text
Card: S3-R249-C1-D
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-managed-local-recursion-and-loop-classes-prop039-authoring-boundary-v0
Route: UPDATE
Depends on:
- S3-R248-C4-A
```

Route type:

```text
design / proposal-authoring boundary
```

Required focus:

- authoring boundary for PROP-039+ managed local recursion / loop classes;
- resolve `recursive contract` vs `fuel_bounded contract` vs `decreases fuel`;
- resolve `for` vs `loop` and static-vs-dynamic `max_steps`;
- decide whether `tick.event_id` belongs to PROP-037 companion wording or stays
  out of source-level syntax;
- preserve service-loop progression ownership under PROP-037;
- include OOF-L / OOF-R naming and registry stance;
- preserve Postulate 28 naming pressure;
- keep `break` deferred unless the authoring route explicitly keeps it as a
  design question only;
- keep lab evidence frontier-only.

Closed surfaces for the next route:

- no implementation authorization;
- no parser/typechecker/runtime/API/CLI/package changes;
- no `igc run` widening;
- no `.igbin` or `.igapp` execution;
- no compiler passport emission;
- no RuntimeSmoke productization;
- no public runtime support;
- no Reference Runtime support;
- no stable API, production, Spark, release, public performance, official/
  reference status, alternative certification, or portability claims.
