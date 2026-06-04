# Experimental Managed Local Recursion and Loop Classes PROP-039+ Authoring Boundary v0

Card: S3-R249-C1-D
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-managed-local-recursion-and-loop-classes-prop039-authoring-boundary-v0
Route: UPDATE
Status: done / design-ready
Date: 2026-06-04

Depends on:
- S3-R248-C4-A

---

## Decision

Design-ready.

Open a bounded PROP-039+ proposal-authoring authorization review next.

This card authorizes no implementation and makes no fixture grammar canonical.
It accepts the R248 proof-local fixture packet as design input only.

Decision:

```text
design-ready
route PROP-039+ proposal authoring authorization review next
implementation remains closed
```

---

## Boundary

Accepted as input:

```text
R248 proof-local specification fixture evidence
Chapter 13 deferred draft vocabulary
PROP-037 service-liveness/progression boundary
Chapter 8 OOF-L6 now() prohibition anchor
Language Covenant Postulate 14 and Postulate 28 pressure
igniter-lab frontier pressure only
```

Not accepted:

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
R248 fixture grammar as canon
```

---

## Inputs Read

- `igniter-lang/docs/tracks/stage3-round248-status-curation-v0.md`
- `igniter-lang/docs/tracks/experimental-loops-recursion-proof-fixture-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/experimental-loops-recursion-proof-fixture-v0.md`
- `igniter-lang/docs/discussions/r248-loops-recursion-proof-fixture-pressure-v0.md`
- `igniter-lang/experiments/experimental_loops_recursion_spec_fixtures_v0/manifest.json`
- `igniter-lang/experiments/experimental_loops_recursion_spec_fixtures_v0/out/summary.json`
- `igniter-lang/experiments/experimental_loops_recursion_spec_fixtures_v0/fixtures/**`
- `igniter-lang/docs/tracks/experimental-loops-recursion-runtime-spec-and-prop037-input-decision-v0.md`
- `igniter-lang/docs/tracks/experimental-loops-recursion-runtime-spec-and-prop037-input-slice-v0.md`
- `igniter-lang/docs/tracks/experimental-loops-recursion-runtime-spec-current-surface-facts-v0.md`
- `igniter-lang/docs/spec/ch13-managed-recursion.md`
- `igniter-lang/docs/spec/ch8-stdlib.md`
- `igniter-lang/docs/language-covenant.md`
- `igniter-lang/docs/proposals/PROP-037-external-progression-service-liveness-v0.md`
- `igniter-lang/docs/proposals/README.md`
- `playgrounds/igniter-lab/lab-docs/loops-and-recursion-pressure-package.md`
- `playgrounds/igniter-lab/lab-docs/loops-and-recursion-pressure-package-return.md`

This C1-D adds only:

- `igniter-lang/docs/tracks/experimental-managed-local-recursion-and-loop-classes-prop039-authoring-boundary-v0.md`

---

## Design Position

### 1. Proposal Ownership

PROP-039+ should own managed local recursion and local loop classes.

Owned by PROP-039+:

- `FiniteLoop`;
- `StructuralRecursion`;
- `FuelBoundedRecursion`;
- `ConvergentLoop`;
- `recur()`;
- `decreases <variant>`;
- `decreases fuel`;
- local `max_steps`;
- local loop naming;
- local loop / recursion diagnostics.

Not owned by PROP-039+ as a primary route:

- service-liveness progression semantics;
- progression source descriptors;
- checkpoint/cancellation/backpressure/receipt obligations;
- scheduler/runtime materialization;
- a `PROGRESSION` fragment class.

Those remain PROP-037 territory unless a later decision opens a companion route.

### 2. Service Loop Split

Keep the hard split:

```text
local managed repetition -> PROP-039+
service liveness -> PROP-037 progression descriptors
```

`clock.every` and `tick.time` may be referenced by PROP-039+ only to exclude
them from local loop authority and to preserve the service-loop boundary.

`tick.event_id` remains fixture pressure only. It should not enter PROP-039+
unless C4-A explicitly routes a narrow PROP-037 companion/accessor decision.

### 3. Structural vs Fuel-Bounded Recursion

The authoring route should keep these separate at first:

```text
StructuralRecursion:
  recursive contract ...
  decreases <structural_variant>

FuelBoundedRecursion:
  fuel_bounded contract ...
  max_steps <static_literal>
  optional design shorthand: decreases fuel
```

R248's `recursive contract ... decreases fuel max_steps` fixture is useful
pressure, but it should not become canonical grammar by default. PROP-039+
must decide whether a unified syntax is desirable after the separate class
model is written down.

### 4. `decreases fuel`

`decreases fuel` is ready as proposal-authoring input, not implementation input.

Preferred first stance:

```text
decreases fuel is a fuel-bounded recursion design shorthand
it requires an explicit static fuel budget
it does not replace structural decreases proofs
```

The exact parser shape, SemanticIR fields, and diagnostics remain future work.

### 5. `for` vs `loop`

The authoring route should prefer a conservative split:

```text
for Name item in collection { ... }
  FiniteLoop over a finite Collection[T]
  no explicit max_steps in the first canonical draft

loop Name item in collection max_steps: N { ... }
  managed local loop with explicit fuel/budget
```

R248's `for ... max_steps: claims.count` remains pressure only. It raises two
authoring questions:

- whether `for` may ever carry `max_steps`;
- whether `max_steps` accepts dynamic expressions.

Preferred first stance:

```text
static literal max_steps first
dynamic max_steps deferred
```

Dynamic budgets may come later if typechecking and auditability rules are
specified.

### 6. Postulate 28 Loop Naming

Postulate 28 is ready as proposal-authoring input:

```text
semantic loop blocks must be named
unnamed loop diagnostics should be specified
loop names must be stable enough for trace/receipt/diagnostic identity
```

This does not claim parser enforcement exists.

### 7. OOF Naming and Registry

OOF-L / OOF-R / OOF-SL names remain draft vocabulary.

PROP-039+ authoring should include a proposed diagnostic table, but should not
claim registry authority unless a later C4-A explicitly accepts it.

Recommended stance:

```text
include OOF diagnostic candidates in PROP-039+
mark them as proposed
route registry/errata separately if C4-A decides acceptance needs a standalone lane
```

`OOF-L6` for source-level `now()` is already the current Chapter 8 anchor.
PROP-039+ should cross-reference it rather than minting a replacement ambient
clock code.

### 8. `break`

Keep `break` deferred.

`break` appears in lab/frontier pressure and R248 negative fixture evidence,
but no current canonical route proves source-level semantics, parser/emitter
path, or audit behavior.

Preferred stance:

```text
first PROP-039+ draft excludes break
future break route must specify effect on loop evidence, fuel, receipts, and
postulate naming
```

### 9. Lab Evidence

igniter-lab pressure is valuable as frontier evidence.

It may influence proposal authoring, especially by showing:

- where alternative compiler authors need precision;
- where `fold_stream` is not enough;
- why local loops and service loops must stay separated;
- why OOF naming needs registry treatment.

It does not create canonical authority, conformance, implementation permission,
public support, or release evidence.

---

## Compact PROP-039+ Authoring Matrix

| Surface | C1-D stance | Next route expectation |
| --- | --- | --- |
| Bounded local loops | Ready for PROP-039+ authoring | Specify `FiniteLoop` vs budgeted local loop. |
| `for` | Finite collection iteration candidate | No `max_steps` in first conservative draft. |
| `loop` | Managed budgeted loop candidate | May carry static `max_steps`. |
| Dynamic `max_steps` | Deferred pressure | Require separate type/audit design. |
| Structural recursion | Ready for authoring | Keep `recursive contract` + structural `decreases`. |
| Fuel-bounded recursion | Ready for authoring | Prefer `fuel_bounded contract` + static budget. |
| `decreases fuel` | Design shorthand candidate | Do not merge with structural recursion by default. |
| `recur()` | Ready for authoring | Compiler primitive design only. |
| Service loops | Excluded from PROP-039+ authority | Keep under PROP-037 progression. |
| `tick.time` | Accepted event-time binding input | Cross-reference only. |
| `tick.event_id` | Fixture pressure only | Consider PROP-037 companion/accessor route later. |
| `now()` | Prohibited by Ch8 `OOF-L6` | Cross-reference; do not mint replacement here. |
| Postulate 28 loop naming | Ready for authoring | Specify naming and diagnostics, not enforcement. |
| OOF-L / OOF-R / OOF-SL | Proposed only | Include candidates; registry authority separate. |
| `break` | Deferred | Exclude from first authoring slice. |
| Lab implementation | Frontier evidence only | No canon/conformance/runtime authority. |

---

## Route Options

### Option A: PROP-039+ Proposal Authoring Authorization Review

Recommended.

Why:

- R248 fixtures are accepted as sufficient design input;
- the main unresolved work is language/proposal wording, not code;
- the route can resolve the three R248 fidelity notes directly;
- it keeps implementation closed while giving lab/frontier work a canonical
  target.

### Option B: OOF Registry / Errata Follow-Up

Do not open first as Main Line.

Keep OOF candidates inside PROP-039+ authoring unless C4-A decides the namespace
conflict blocks proposal text.

### Option C: Fixture Hardening Proof

Do not open first.

R248 fixtures are sufficient for authoring. Hardening before wording would
mostly polish non-canonical grammar.

### Option D: Parser/TypeChecker Boundary Design

Hold.

Implementation-facing design should wait until PROP-039+ proposal text is
accepted or at least conditionally accepted.

### Option E: Runtime Specification Follow-Up

Hold as separate Main Line.

The proposal-authoring route may later recommend a Ch13 follow-up, but C1-D
should not edit spec chapters directly.

---

## Explicit Answers

### Is PROP-039+ authoring boundary ready?

Yes. The boundary is ready as proposal-authoring authorization review.

### Are R248 proof fixtures sufficient design input?

Yes. They are sufficient design input with the three C4-A fidelity notes:

- `tick.event_id` is pressure only;
- `recursive contract ... decreases fuel max_steps` is not canonical grammar;
- `for ... max_steps: claims.count` is not canonical grammar.

### May bounded local loops move into proposal authoring?

Yes. Bounded local loops should move into PROP-039+ proposal authoring.

### May recursion / `decreases fuel` move into proposal authoring?

Yes. Recursion and `decreases fuel` should move into PROP-039+ proposal
authoring.

### Should `recursive contract` and `fuel_bounded contract` remain distinct?

Yes for the first authoring route. Keep structural recursion and fuel-bounded
recursion distinct, then decide whether a unified syntax is justified.

### Is `for ... max_steps` allowed?

Not yet. Treat it as pressure only. The conservative first draft should keep
`for` for finite collection iteration and reserve explicit `max_steps` for
`loop` or fuel-bounded constructs.

### Should `max_steps` start static-only?

Yes. Static literal `max_steps` should be the first authoring stance. Dynamic
`max_steps` should be deferred until type/audit rules are specified.

### Does service-loop material remain PROP-037-owned?

Yes. Service liveness, progression descriptors, scheduler/materialization,
checkpoint, cancellation, receipts, and backpressure remain PROP-037-owned.

### What happens to `tick.event_id`?

It remains fixture pressure only. A later PROP-037 companion route may decide
whether `tick` exposes structured accessors beyond `tick.time`.

### Should OOF loop/recursion registry work open separately?

Not first. Include proposed OOF candidates in PROP-039+ authoring. Open a
separate registry/errata route only if C4-A finds namespace acceptance blocked.

### May implementation authorization open next?

No. Implementation remains closed.

### Does lab behavior create canonical authority?

No. Lab behavior remains frontier evidence only.

### Does `igc run` widening remain closed?

Yes.

### Do protected claims remain closed?

Yes. Public, stable, production, Reference Runtime, release, performance,
certification, and portability claims remain closed.

---

## Exact C4-A Recommendation

Accept this boundary and open:

```text
Card: S3-R249-C4-A should recommend the next available Main Line route after
the already-reserved S3-R250 forms round:
  experimental-managed-local-recursion-prop039-proposal-authoring-authorization-review-v0
```

Preferred next dispatch:

```text
Card: S3-R251-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-managed-local-recursion-prop039-proposal-authoring-authorization-review-v0
Route: UPDATE
Depends on:
- S3-R249-C4-A
```

Route type:

```text
proposal-authoring authorization review
```

Expected allowed write scope if authorized:

```text
igniter-lang/docs/proposals/PROP-039-managed-local-recursion-and-loop-classes-v0.md
igniter-lang/docs/proposals/README.md
igniter-lang/docs/tracks/experimental-managed-local-recursion-prop039-proposal-authoring-v0.md
```

Expected closed surfaces:

```text
igniter-lang/lib/**
igniter-lang/bin/igc
igniter-lang/igniter_lang.gemspec
igniter-lang/README.md
igniter-lang/docs/README.md
igniter-lang/docs/ruby-api.md
igniter-lang/docs/spec/**
igniter-lang/source/**
igniter-lang/experiments/**
playgrounds/**
```

Required authoring focus:

- define PROP-039 managed local recursion / loop-class scope;
- separate `FiniteLoop`, `StructuralRecursion`, `FuelBoundedRecursion`,
  `ConvergentLoop`, and `ServiceLoop`;
- keep service liveness mapped to PROP-037;
- specify conservative `for` / `loop` split;
- specify static-only first `max_steps` stance;
- specify structural vs fuel-bounded recursion;
- specify `decreases fuel` as fuel-bounded shorthand or reject it;
- cross-reference Ch8 `OOF-L6` for `now()`;
- include Postulate 28 naming;
- include proposed OOF candidates without claiming registry authority;
- defer `break`;
- keep all implementation/runtime/public/release/performance/certification/
  portability surfaces closed.
