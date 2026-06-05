# Experimental Managed Local Recursion PROP-039 Proposal Authoring v0

Card: `S3-R251-C2-I`
Skill: IDD Agent Protocol
Agent: `[Compiler / Grammar Expert]`
Role: `compiler-grammar-expert`
Track: `experimental-managed-local-recursion-prop039-proposal-authoring-v0`
Route: UPDATE
Status: done / proposal authored
Date: 2026-06-05

Depends on:
- `S3-R251-C1-A`

---

## Decision

PROP-039 was authored inside the C1-A proposal-authoring-only boundary.

This card changes only:

- `igniter-lang/docs/proposals/PROP-039-managed-local-recursion-and-loop-classes-v0.md`
- `igniter-lang/docs/proposals/README.md`
- `igniter-lang/docs/tracks/experimental-managed-local-recursion-prop039-proposal-authoring-v0.md`

No code, spec chapter, source example, experiment, playground, runtime, API,
CLI, package, `.igapp`, `.igbin`, compiler passport, RuntimeSmoke, release,
public, production, Spark, performance, certification, portability, or lab-canon
surface was opened.

---

## Inputs Read

- `docs/tracks/experimental-managed-local-recursion-prop039-proposal-authoring-authorization-review-v0.md`
- `docs/tracks/experimental-managed-local-recursion-prop039-authoring-boundary-decision-v0.md`
- `docs/tracks/experimental-managed-local-recursion-and-loop-classes-prop039-authoring-boundary-v0.md`
- `docs/tracks/experimental-managed-local-recursion-prop039-current-surface-facts-v0.md`
- `docs/tracks/experimental-loops-recursion-proof-fixture-acceptance-decision-v0.md`
- `docs/tracks/experimental-loops-recursion-proof-fixture-v0.md`
- `experiments/experimental_loops_recursion_spec_fixtures_v0/out/summary.json`
- `docs/spec/ch13-managed-recursion.md`
- `docs/spec/ch8-stdlib.md`
- `docs/language-covenant.md`
- `docs/proposals/PROP-037-external-progression-service-liveness-v0.md`
- `docs/proposals/README.md`

---

## PROP-039 Section Matrix

| Required topic | PROP-039 section | Status |
| --- | --- | --- |
| Proposal status and authority boundary | `Authority Boundary` | done |
| Motivation and non-goals | `Purpose`, `Non-Goals` | done |
| Loop-class vocabulary | `Loop-Class Vocabulary` | done |
| Finite local loop stance | `Finite Local Loops` | done |
| Budgeted local loop stance | `Budgeted Local Loops` | done |
| Structural recursion stance | `Structural Recursion` | done |
| Fuel-bounded recursion stance | `Fuel-Bounded Recursion` | done |
| `decreases fuel` shorthand candidate | `decreases fuel` Shorthand Candidate | done |
| Conservative `for` / `loop` split | `for` / `loop` Split | done |
| Static-first `max_steps` | Static-First `max_steps` | done |
| Service-loop / PROP-037 exclusion | `Service-Loop / PROP-037 Exclusion` | done |
| `tick.time` accepted relationship | `tick.time` And `tick.event_id` | done |
| `tick.event_id` pressure-only note | `tick.time` And `tick.event_id` | done |
| `now()` / OOF-L6 cross-reference | `now()` And OOF-L6 | done |
| OOF-L / OOF-R candidate diagnostics | `Candidate Diagnostics` | done |
| Postulate 28 loop naming | `Postulate 28 Loop Naming` | done |
| `break` deferral | `break` Deferral | done |
| Fixture/lab evidence non-authority | `Evidence And Non-Authority` | done |
| Future gates | `Future Gates` | done |

---

## Proposal README Status

`docs/proposals/README.md` now indexes:

```text
PROP-039 | authored-pending-review | managed local recursion and loop classes
```

The previous `PROP-039+` queued placeholder row was removed so the index no
longer presents managed local recursion as unassigned. The README preserves that
PROP-039 is proposal-only and does not open implementation, runtime, public, or
alternate-certification authority.

---

## Service-Loop / PROP-037 Separation

Status: preserved.

PROP-039 states:

```text
local managed repetition -> PROP-039
service liveness -> PROP-037 progression descriptors
```

`clock.every` and `tick.time` remain PROP-037-owned. `tick.event_id` remains
pressure-only and requires a later PROP-037 companion/accessor route if desired.

---

## OOF Naming Status

Status: candidate diagnostics only.

PROP-039 includes proposed `OOF-L*` and `OOF-R*` tables, but explicitly states
they do not create OOF registry authority. Chapter 8 `OOF-L6` remains the
current source-level `now()` prohibition anchor and is not replaced.

---

## Forbidden Wording Scan

Status: pass with explicit non-claim contexts only.

The proposal and track mention closed terms such as parser support, runtime
support, `.igapp`, `.igbin`, RuntimeSmoke, public runtime, Reference Runtime,
stable API, production, release, performance, official/reference status,
certification, portability, lab behavior as canon, and R248 fixture grammar as
canon only as denied or closed surfaces.

---

## Closed-Surface Scan

Status: pass.

Only the authorized proposal/index/track docs changed. Confirmed closed by
write scope:

- `igniter-lang/lib/**`
- `igniter-lang/bin/igc`
- `igniter-lang/igniter_lang.gemspec`
- `igniter-lang/README.md`
- `igniter-lang/docs/README.md`
- `igniter-lang/docs/ruby-api.md`
- `igniter-lang/docs/spec/**`
- `igniter-lang/source/**`
- `igniter-lang/experiments/**`
- `playgrounds/**`

---

## Command Matrix

| Command | Result |
| --- | --- |
| `git diff --check -- igniter-lang/docs/proposals/PROP-039-managed-local-recursion-and-loop-classes-v0.md igniter-lang/docs/proposals/README.md igniter-lang/docs/tracks/experimental-managed-local-recursion-prop039-proposal-authoring-v0.md` | PASS |
| `git status --short -- <authorized-and-closed-surface-paths>` | PASS |
| `rg -n "PROP-039\\+|managed local recursion / loop-class extensions placeholder" igniter-lang/docs/proposals/README.md` | PASS: no stale placeholder |

---

## Compact Return Packet

[D] Authored PROP-039 as proposal-only text for managed local recursion and
loop classes.

[S] The proposal resolves the required R248/R249 issues conservatively:
`for` is finite collection iteration; `loop` is static-budget local loop;
structural recursion and fuel-bounded recursion remain distinct;
`decreases fuel` is a shorthand candidate only; dynamic `max_steps`,
`tick.event_id`, and `break` remain deferred/pressure-only; service liveness
remains PROP-037-owned.

[T] README index now lists PROP-039 as `authored-pending-review` and removes the
queued placeholder row.

[R] C4-A recommendation: accept the authoring packet as bounded
proposal-authoring output and route C3-X pressure review next. Keep
implementation, parser, TypeChecker, SemanticIR, runtime, API, CLI, package,
`igc run`, `.igapp`, `.igbin`, compiler passport, RuntimeSmoke, public runtime,
Reference Runtime, stable API, production, Spark, release, public demo,
performance, official/reference status, certification, portability, and
lab-canon authority closed.
