# Experimental Managed Local Recursion PROP-039 Proposal Authoring Acceptance Decision v0

Card: S3-R251-C4-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-managed-local-recursion-prop039-proposal-authoring-acceptance-decision-v0
Route: UPDATE
Status: accepted / route-proof-fixture-authorization-review
Date: 2026-06-05

Depends on:
- S3-R251-C2-I
- S3-R251-C3-X

---

## Decision

Decision:

```text
accept bounded PROP-039 proposal authoring
accept touched docs as proposal-authoring evidence only
keep implementation, parser, TypeChecker, SemanticIR, runtime, API, CLI,
package, igc run, .igapp, .igbin, compiler passport, RuntimeSmoke, public
runtime, Reference Runtime, stable API, production, Spark, release,
performance, certification, portability, and lab-canon authority closed
route proof-local PROP-039 fixture authorization review next for this lane
```

The C2-I proposal-authoring output stayed inside the S3-R251-C1-A write scope.
C3-X returned `ACCEPT` with no blocking claim drift.

Because S3-R252 is already routed by R250 to the forms type-directed dispatch
proof authorization review, the next PROP-039 lane route should open as S3-R253.

---

## Inputs Read

- `igniter-lang/docs/tracks/experimental-managed-local-recursion-prop039-proposal-authoring-authorization-review-v0.md`
- `igniter-lang/docs/tracks/experimental-managed-local-recursion-prop039-proposal-authoring-v0.md`
- `igniter-lang/docs/discussions/experimental-managed-local-recursion-prop039-proposal-authoring-pressure-v0.md`
- `igniter-lang/docs/proposals/PROP-039-managed-local-recursion-and-loop-classes-v0.md`
- `igniter-lang/docs/proposals/README.md`
- `igniter-lang/docs/tracks/stage3-round250-status-curation-v0.md`
- `igniter-lang/docs/tracks/experimental-managed-local-recursion-prop039-authoring-boundary-decision-v0.md`

---

## Exact Changed Files

C2-I changed:

- `igniter-lang/docs/proposals/PROP-039-managed-local-recursion-and-loop-classes-v0.md`
- `igniter-lang/docs/proposals/README.md`
- `igniter-lang/docs/tracks/experimental-managed-local-recursion-prop039-proposal-authoring-v0.md`

C3-X changed:

- `igniter-lang/docs/discussions/experimental-managed-local-recursion-prop039-proposal-authoring-pressure-v0.md`

This C4-A adds:

- `igniter-lang/docs/tracks/experimental-managed-local-recursion-prop039-proposal-authoring-acceptance-decision-v0.md`

---

## Acceptance Record

| Topic | Status |
| --- | --- |
| Authorization boundary adherence | Accepted. C2-I stayed inside proposal doc, proposals README, and track doc. |
| PROP-039 status | Accepted as `authored-pending-review` proposal-authoring output only. |
| Proposals README status | Accepted. README indexes PROP-039 and removes the stale `PROP-039+` placeholder. |
| Bounded local loop | Accepted as proposal vocabulary; no parser/runtime support. |
| Structural recursion | Accepted as proposal vocabulary; no execution support. |
| Fuel-bounded recursion | Accepted as distinct proposal vocabulary; static budget first. |
| `decreases fuel` | Accepted as proposal shorthand candidate only; not grammar. |
| `for` / `loop` | Accepted as conservative proposal split: `for` finite, `loop` budgeted. |
| Static-vs-dynamic `max_steps` | Static-first accepted; dynamic budgets deferred. |
| Service-loop / PROP-037 | Preserved. Service liveness and progression remain PROP-037-owned. |
| `tick.time` / `tick.event_id` | `tick.time` remains PROP-037 event-time binding; `tick.event_id` remains pressure-only. |
| `now()` / OOF-L6 | Ch8 `OOF-L6` remains the source-level `now()` anchor. |
| OOF-L / OOF-R registry | Candidate diagnostics only; no registry authority. |
| Postulate 28 loop naming | Accepted as proposal requirement; enforcement unimplemented. |
| `break` | Deferred and unsupported in v0 proposal semantics. |
| Fixture/lab evidence authority | R248 fixtures and lab behavior remain evidence/frontier pressure only. |
| Implementation / runtime authority | Closed. |
| Public/stable/production claims | Closed. |

---

## Decision Rationale

The authored PROP-039 text gives the language lane a needed design anchor for
managed local repetition without treating lab or fixture grammar as canon.

The accepted authoring packet resolves the R248/R249 pressure conservatively:

- `for` is finite collection iteration;
- `loop` is budgeted local repetition;
- static `max_steps` is the first stance;
- structural recursion and fuel-bounded recursion remain distinct;
- `decreases fuel` remains a shorthand candidate only;
- service loops remain PROP-037-owned;
- OOF-L / OOF-R names remain candidate diagnostics;
- `break`, dynamic budgets, and `tick.event_id` stay deferred.

This is strong enough to move to proof-local fixtures, but not strong enough to
open parser, TypeChecker, SemanticIR, runtime, or `igc run` work.

---

## Explicit Answers

### Is PROP-039 proposal authoring accepted?

Yes. PROP-039 proposal authoring is accepted as bounded proposal-authoring
output.

### May generated/touched docs be called proposal-authoring evidence only?

Yes. The touched docs may be called proposal-authoring evidence only.

### Does this create implementation authority?

No.

### Does this create parser / TypeChecker / SemanticIR / runtime support?

No.

### Does lab behavior or fixture grammar create canonical authority?

No. Lab behavior and R248 fixture grammar remain evidence only.

### Should OOF registry / errata work open next?

Not as the immediate main route. OOF-L / OOF-R names can remain candidate
diagnostics for the next fixture proof. A registry / errata route should open
only if fixture pressure shows namespace ambiguity blocks acceptance.

### May parser/typechecker boundary design open next?

Not yet. Parser/typechecker boundary design should wait until proof-local
PROP-039 fixtures exercise the accepted proposal vocabulary.

### Does `igc run` widening remain closed?

Yes.

### Do protected claims remain closed?

Yes. Public, stable, production, Reference Runtime, release, performance,
certification, portability, official/reference, Spark, and public demo claims
remain closed.

---

## Next Route

Open the next PROP-039 lane route after the already-routed S3-R252 forms round:

```text
Card: S3-R253-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-managed-local-recursion-prop039-proof-fixture-authorization-review-v0
Route: UPDATE
Depends on:
- S3-R251-C4-A
- S3-R252-C5-S if present
```

Route type:

```text
proof-local fixture authorization review
```

Candidate C2-I boundary if authorized:

```text
Card: S3-R253-C2-I
Skill: IDD Agent Protocol
Agent: [Compiler / Grammar Expert]
Role: compiler-grammar-expert
Track: experimental-managed-local-recursion-prop039-proof-fixture-v0
```

Expected allowed write scope for that future authorization review to consider:

```text
igniter-lang/experiments/experimental_managed_local_recursion_prop039_fixtures_v0/**
igniter-lang/docs/tracks/experimental-managed-local-recursion-prop039-proof-fixture-v0.md
```

Expected proof focus:

- `FiniteLoop` fixture;
- `BudgetedLocalLoop` fixture;
- `StructuralRecursion` fixture;
- `FuelBoundedRecursion` fixture;
- static-first `max_steps`;
- `decreases fuel` shorthand pressure;
- rejected dynamic `max_steps`;
- rejected `break`;
- `tick.event_id` remains pressure-only / excluded;
- OOF-L / OOF-R candidate diagnostics stay non-registry;
- no parser/typechecker/SemanticIR/runtime support claim.

Closed for the next route:

```text
igniter-lang/lib/**
igniter-lang/bin/igc
igniter-lang/igniter_lang.gemspec
igniter-lang/README.md
igniter-lang/docs/README.md
igniter-lang/docs/ruby-api.md
igniter-lang/docs/spec/**
igniter-lang/docs/proposals/**
igniter-lang/source/**
playgrounds/**
runtime / API / CLI / package authority
igc run widening
.igapp / .igbin execution
compiler passport emission
RuntimeSmoke productization
public runtime / Reference Runtime
stable API / production / Spark / release / public demo
performance / official-reference / certification / portability claims
lab behavior as canon
```

---

## Compact Decision Summary

```text
ACCEPT: PROP-039 proposal authoring
ACCEPT: C3-X pressure verdict
STATUS: proposal-authoring evidence only
CLOSED: implementation, parser/typechecker/SemanticIR/runtime, igc run,
        .igapp/.igbin, public/stable/release/performance/certification claims
NEXT: S3-R253-C1-A proof-local PROP-039 fixture authorization review
NOTE: S3-R252 remains the already-routed forms type-dispatch round
```
