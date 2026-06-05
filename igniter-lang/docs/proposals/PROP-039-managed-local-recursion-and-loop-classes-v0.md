# PROP-039: Managed Local Recursion and Loop Classes v0

Status: authored-pending-review
Date: 2026-06-05
Author: `[Igniter-Lang Compiler / Grammar Expert]`
Stage: 3 proposal intake
Authoring card: S3-R251-C2-I
Depends on:
- PROP-037 external progression and service liveness semantics
- Chapter 13 managed recursion draft
- Chapter 8 stdlib `now()` / `OOF-L6` wording
- Language Covenant Postulates 14 and 28
- R248 proof-local loops/recursion fixture packet

---

## Authority Boundary

PROP-039 authors proposal text for managed local recursion and local loop
classes. It does not authorize implementation.

Closed by this proposal:

- parser support;
- TypeChecker support;
- SemanticIR support;
- runtime support;
- API, CLI, and package changes;
- `igc run` widening;
- `.igapp` or `.igbin` execution;
- compiler passport emission;
- RuntimeSmoke productization;
- public runtime support;
- Reference Runtime support;
- stable API or production readiness;
- Spark integration;
- release or public demo evidence;
- public performance claims;
- official/reference status;
- alternative certification;
- portability guarantees;
- lab behavior or R248 fixture grammar as canon.

This proposal may be accepted as language-design authority only after governance
review. Any parser, TypeChecker, SemanticIR, runtime, conformance, or alternate
implementation work requires a separate authorization route.

---

## Purpose

Igniter-Lang requires every repetition to be managed. Postulate 14 states that
repetition must be finite by collection size, finite by structural variant,
finite by fuel, convergent by metric, or alive by liveness. The current accepted
language already separates service liveness from local repetition:

- PROP-037 owns external progression and service liveness.
- PROP-039 owns managed local loops and recursion.

This proposal fills the managed local side. It gives future proof and
implementation cards a bounded vocabulary for local loop classes, recursive
forms, budgets, naming, and candidate diagnostics.

---

## Non-Goals

PROP-039 v0 does not define or authorize:

- service-loop progression descriptors, materialization, checkpoint,
  cancellation, backpressure, scheduler, or receipts;
- a `PROGRESSION` fragment class;
- live recursion execution;
- arbitrary unbounded loops;
- source-level `break`;
- dynamic budget expressions as accepted source form;
- general side-effectful loop bodies;
- public runtime, Reference Runtime, stable API, production, release,
  performance, certification, or portability claims.

---

## Loop-Class Vocabulary

PROP-039 v0 defines the managed local loop-class vocabulary:

| Class | Ownership | v0 stance |
| --- | --- | --- |
| `FiniteLoop` | PROP-039 | Local iteration over finite `Collection[T]`; termination follows from collection boundedness. |
| `BudgetedLocalLoop` | PROP-039 | Local loop with explicit static `max_steps` budget. |
| `StructuralRecursion` | PROP-039 | Recursive contract where a structural variant decreases at every `recur()` site. |
| `FuelBoundedRecursion` | PROP-039 | Recursive contract bounded by static fuel / `max_steps`. |
| `ConvergentLoop` | PROP-039, deferred proof | Local iterative form with metric, threshold, and static budget; included as vocabulary, but later proof must own detailed rules. |
| `ServiceLoop` | PROP-037 | Excluded from PROP-039 except for boundary references. |

`BudgetedLocalLoop` is named separately from Ch13's
`FuelBoundedRecursion` so local loop budgets and recursive fuel do not collapse
into one syntax too early.

---

## Finite Local Loops

The conservative v0 finite-loop stance is:

```igniter
for ClaimLoop claim in claims {
  ...
}
```

where:

- `ClaimLoop` is a stable loop name;
- `claims` must be a finite `Collection[T]`;
- the loop terminates by exhausting the collection;
- the first v0 `for` form does not carry `max_steps`;
- the loop is local repetition, not `fold_stream`;
- body semantics remain future proof work.

The R248 fixture form:

```igniter
for ClaimLoop claim in claims max_steps: claims.count { ... }
```

is accepted as pressure evidence only. PROP-039 v0 does not make `for ...
max_steps` canonical.

---

## Budgeted Local Loops

The conservative v0 budgeted-loop stance is:

```igniter
loop SearchLoop item in candidates max_steps: 1000 {
  ...
}
```

where:

- `SearchLoop` is a stable loop name;
- `max_steps` is a static integer literal in the first accepted design;
- exhausting the budget must be observable in a future proof/runtime model;
- dynamic budget expressions are deferred;
- `break` remains unsupported in v0;
- the loop remains local repetition, not service liveness.

The first implementation proof, if later authorized, should reject or hold
dynamic forms such as:

```igniter
loop SearchLoop item in candidates max_steps: candidates.count { ... }
```

until a separate type/audit rule proves that dynamic budget sources are bounded,
accountable, and not hidden runtime authority.

---

## Structural Recursion

Structural recursion is the class for recursive local computation whose variant
strictly decreases at every `recur()` site:

```igniter
recursive contract SumList(items: Collection[Integer], acc: Integer) -> total: Integer
  decreases items.remaining
{
  ...
}
```

v0 obligations:

- the contract must declare a structural `decreases` expression;
- every `recur()` site must preserve type shape and decrease the variant;
- `recur()` is a language primitive, not an arbitrary self-call;
- `recur()` outside a recursive or fuel-bounded context is a candidate OOF;
- proof of the decreases relation is future TypeChecker work.

PROP-039 v0 does not authorize recursive execution.

---

## Fuel-Bounded Recursion

Fuel-bounded recursion is distinct from structural recursion:

```igniter
fuel_bounded contract SearchOptimal(state: SearchState) -> best: Route
  max_steps 10000
{
  ...
}
```

v0 obligations:

- `max_steps` must be a static integer literal;
- each recursive step consumes one unit of fuel;
- exhaustion behavior must be explicit in a later proof route;
- structural decreases proof is not required for this class;
- fuel is not hidden runtime authority.

`FuelBoundedRecursion` may later support explicit exhaustion policy such as
`:error`, `:suspend`, or `:return_partial`, but v0 treats the policy surface as
deferred unless a later route accepts it.

---

## `decreases fuel` Shorthand Candidate

`decreases fuel` is accepted here as a proposal candidate only:

```igniter
recursive contract FactorialFuel(n: Integer, acc: Integer) -> result: Integer
  decreases fuel
  max_steps 100
{
  ...
}
```

Meaning candidate:

```text
decreases fuel =
  this recursive form is fuel-bounded
  + it requires an explicit static max_steps budget
  + each recur() consumes one fuel unit
```

This does not merge structural and fuel-bounded recursion by default. It is a
shorthand candidate whose final parser shape, TypeChecker obligations,
SemanticIR fields, and diagnostics remain future work.

The R248 fixture using `recursive contract ... decreases fuel max_steps 100` is
evidence for this candidate, not canonical grammar by itself.

---

## `for` / `loop` Split

PROP-039 v0 recommends this conservative split for future proof work:

| Surface | First meaning | Budget stance |
| --- | --- | --- |
| `for Name item in collection { ... }` | Finite collection iteration | No explicit `max_steps` in first v0 form |
| `loop Name item in collection max_steps: N { ... }` | Budgeted local loop | Static integer literal `max_steps` required |

Open questions:

- whether `for` may later carry a budget as a defensive cap;
- whether `loop` must always consume a collection source;
- whether local loops may produce accumulated values directly or only through
  named compute/output nodes;
- how loop-body dependency and evidence identity lower into later compiler
  phases.

---

## Static-First `max_steps`

`max_steps` is static-first in v0.

Accepted for first proof planning:

```igniter
max_steps 1000
max_steps: 1000
```

Held / deferred:

```igniter
max_steps: claims.count
max_steps: budget_input
max_steps: computed_limit()
```

Rationale:

- static budgets are auditable at source review time;
- dynamic budgets need type, provenance, and upper-bound rules;
- dynamic expressions can hide unbounded behavior if accepted too early.

---

## Service-Loop / PROP-037 Exclusion

Service-loop liveness is excluded from PROP-039 authority.

PROP-037 owns:

- `Progression`;
- `ProgressionSource`;
- `ProgressionEvent`;
- materialization;
- checkpoint, cancellation, backpressure, and receipt obligations;
- service-loop source binding such as `clock.every`.

PROP-039 may mention service loops only to preserve the boundary:

```text
local managed repetition -> PROP-039
service liveness -> PROP-037 progression descriptors
```

`clock.every` is therefore not a `Stream[DateTime]` and is not a local loop
source under PROP-039.

---

## `tick.time` And `tick.event_id`

`tick.time` remains accepted as a PROP-037 event-time binding from a materialized
progression event. It is not ambient time and it is not managed local loop
syntax.

`tick.event_id` remains pressure-only. PROP-039 does not accept a structured
`tick` accessor object. If the language needs stable event identity fields, a
later PROP-037 companion/accessor route should own them.

---

## `now()` And OOF-L6

Source-level `now()` remains prohibited through Chapter 8 `OOF-L6`.

PROP-039 does not mint a replacement ambient-clock diagnostic. Local loops,
recursion, and service-loop design examples must receive time through explicit
inputs or accepted event-time bindings, such as:

- `TemporalCtx.as_of`;
- an explicit `as_of: DateTime` parameter;
- PROP-037-owned `tick.time`.

---

## Postulate 28 Loop Naming

Semantic loop blocks must have stable names.

Rationale:

- diagnostics need a stable location and semantic identity;
- future receipts or traces need a loop identity if they ever become
  authorized;
- unnamed repetition hides accountability.

Candidate future source:

```igniter
for ClaimLoop claim in claims { ... }
loop SearchLoop item in candidates max_steps: 1000 { ... }
```

Held / future diagnostic pressure:

```igniter
for claim in claims { ... }
loop item in candidates max_steps: 1000 { ... }
```

This proposal does not claim parser enforcement exists.

---

## `break` Deferral

`break` is deferred from PROP-039 v0.

Reasons:

- `break` changes loop evidence and termination explanation;
- fuel accounting and partial results need explicit rules;
- future receipts or traces need a precise distinction between exhaustion,
  natural completion, and early exit;
- lab VM pressure does not create language authority.

A future `break` route must specify evidence, fuel, naming, and lowering rules
before implementation can be considered.

---

## Candidate Diagnostics

The following diagnostics are proposal candidates only. They do not create OOF
registry authority.

### Local Loop Candidates

| Code | Condition | Severity | Notes |
| --- | --- | --- | --- |
| `OOF-L1` | Local loop has no finite collection proof and no static budget | error | Does not replace Ch8 `OOF-L6`. |
| `OOF-L2` | `max_steps` is dynamic where v0 requires a static literal | error | Dynamic policy is deferred. |
| `OOF-L3` | Semantic loop block is unnamed | error | Postulate 28 pressure. |
| `OOF-L4` | `break` appears in a PROP-039 v0 loop | error | Deferred unsupported surface. |
| `OOF-L5` | Loop body contains unsupported local-repetition form | error | Placeholder for proof-authoring refinement. |

### Recursion Candidates

| Code | Condition | Severity | Notes |
| --- | --- | --- | --- |
| `OOF-R1` | `recur()` appears outside recursive or fuel-bounded context | error | Aligns with Ch13 draft wording. |
| `OOF-R2` | Structural recursion lacks a declared structural variant | error | Candidate for missing `decreases <variant>`. |
| `OOF-R3` | Structural variant is not proven to decrease at a `recur()` site | error | Requires TypeChecker proof design. |
| `OOF-R4` | Fuel-bounded recursion lacks static `max_steps` | error | Includes invalid `decreases fuel` without budget. |
| `OOF-R5` | Recursive step changes output/parameter shape incompatibly | error | Requires type proof design. |

### Service-Loop Names

`OOF-SL*` names remain PROP-037 companion pressure, not PROP-039 authority.
Service-loop diagnostics should not be accepted under PROP-039 unless a later
governance route explicitly moves them.

---

## Fragment And Cache Stance

PROP-039 v0 does not add a fragment class.

Managed local loops and recursion should preserve the surrounding contract's
fragment classification unless a future proof demonstrates a specific reason to
escalate. Service liveness remains PROP-037-owned and does not become a
PROP-039 fragment.

PROP-039 v0 does not define runtime cache behavior, dynamic dependency tracking,
or path-sensitive invalidation.

---

## Evidence And Non-Authority

R248 proof fixtures are accepted only as proof-local specification fixture
evidence. Their grammar is not canonical.

The igniter-lab pressure package and Rust implementation experiments are useful
frontier evidence. They are not the source of truth for Igniter-Lang grammar,
diagnostics, runtime behavior, Reference Runtime behavior, certification, or
portability.

Future Rust or alternate implementation work should consume accepted proposal
text and conformance fixtures after governance accepts them. It should not set
the language contract by implementation inertia.

---

## Future Gates

Before implementation authorization can be considered, the following gates
should close:

1. Governance acceptance or redirect of PROP-039.
2. Proof-local source semantics fixture for `FiniteLoop`,
   `BudgetedLocalLoop`, `StructuralRecursion`, and `FuelBoundedRecursion`.
3. Parser boundary proof, if source syntax is authorized.
4. TypeChecker proof for finite collection, static budget, and recursive
   decreases/fuel obligations.
5. SemanticIR lowering design/proof, only after parser/typechecker boundaries
   are accepted.
6. OOF registry / diagnostic namespace review if candidate diagnostics need
   canonical authority.
7. Alternate implementation conformance consumer route, after canonical proof
   fixtures exist.

Runtime execution, `igc run`, `.igbin`, RuntimeSmoke, Reference Runtime,
production, release, performance, certification, and portability gates remain
closed until separately opened.

---

## Open Questions

- Should `ConvergentLoop` remain in PROP-039 v0 vocabulary but wait for a
  separate detailed proposal/proof?
- Should future `for` accept an optional defensive static cap, or should
  budgeted behavior remain exclusively `loop`?
- Should `decreases fuel` be accepted as syntax, replaced by `fuel_bounded`,
  or held as explanatory shorthand?
- What exhaustion policies are allowed for fuel-bounded recursion and budgeted
  local loops?
- How should loop-local compute nodes expose evidence or accumulated values in
  later SemanticIR work?
- Does `OOF-L*` belong in the same registry namespace as existing Ch8 `OOF-L6`,
  or should local-loop candidates be renumbered during registry review?
