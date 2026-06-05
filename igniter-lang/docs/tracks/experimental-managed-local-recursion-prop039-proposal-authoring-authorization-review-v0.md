# Experimental Managed Local Recursion PROP-039 Proposal Authoring Authorization Review v0

Card: S3-R251-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-managed-local-recursion-prop039-proposal-authoring-authorization-review-v0
Route: UPDATE
Status: authorized / proposal-authoring-only
Date: 2026-06-05

Depends on:
- S3-R249-C4-A
- S3-R250-C5-S

---

## Decision

Decision:

```text
authorize bounded PROP-039 proposal authoring
authorize only proposal/index/track docs in the allowed scope
keep implementation, parser, typechecker, SemanticIR, runtime, API, CLI,
package, igc run, .igapp, .igbin, compiler passport, RuntimeSmoke, public
runtime, Reference Runtime, stable API, production, Spark, release,
performance, certification, portability, and lab-canon authority closed
```

R249 accepted the PROP-039+ managed local recursion / loop-class authoring
boundary. R250 closed the reserved forms round and does not block this route.
The R248 proof-local fixtures are sufficient design input, but their grammar
remains non-canonical.

This card authorizes C2-I proposal authoring only. It does not authorize code,
source fixtures, experiments, playground changes, Runtime Specification chapter
edits, or any implementation route.

---

## Inputs Read

- `igniter-lang/docs/tracks/stage3-round249-status-curation-v0.md`
- `igniter-lang/docs/tracks/stage3-round250-status-curation-v0.md`
- `igniter-lang/docs/tracks/experimental-managed-local-recursion-prop039-authoring-boundary-decision-v0.md`
- `igniter-lang/docs/tracks/experimental-managed-local-recursion-and-loop-classes-prop039-authoring-boundary-v0.md`
- `igniter-lang/docs/tracks/experimental-managed-local-recursion-prop039-current-surface-facts-v0.md`
- `igniter-lang/docs/discussions/experimental-managed-local-recursion-prop039-authoring-boundary-pressure-v0.md`
- `igniter-lang/docs/tracks/experimental-loops-recursion-proof-fixture-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/experimental-loops-recursion-proof-fixture-v0.md`
- `igniter-lang/experiments/experimental_loops_recursion_spec_fixtures_v0/out/summary.json`
- `igniter-lang/docs/spec/ch13-managed-recursion.md`
- `igniter-lang/docs/spec/ch8-stdlib.md`
- `igniter-lang/docs/language-covenant.md`
- `igniter-lang/docs/proposals/PROP-037-external-progression-service-liveness-v0.md`
- `igniter-lang/docs/proposals/README.md`

---

## Authorization Boundary

### Allowed Write Scope

C2-I may write only:

```text
igniter-lang/docs/proposals/PROP-039-managed-local-recursion-and-loop-classes-v0.md
igniter-lang/docs/proposals/README.md
igniter-lang/docs/tracks/experimental-managed-local-recursion-prop039-proposal-authoring-v0.md
```

### Read-Only / Closed Unless Explicitly Authorized Later

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

Runtime Specification chapters may be read and cited, but not edited in this
route.

---

## Proposal Scope

C2-I should author PROP-039 as proposal-only text for:

- managed local recursion;
- local loop classes;
- finite collection loops;
- budgeted local loops;
- structural recursion;
- fuel-bounded recursion;
- `decreases fuel` as a fuel-bounded shorthand candidate;
- Postulate 28 loop naming;
- proposed OOF-L / OOF-R candidates without registry authority.

C2-I must preserve:

- service liveness and progression as PROP-037-owned;
- `tick.time` as accepted service/progression event-time input;
- `tick.event_id` as pressure-only;
- source-level `now()` refusal anchored to Ch8 `OOF-L6`;
- `break` as deferred and excluded from the first proposal slice;
- dynamic `max_steps` as deferred pressure.

---

## Required Stances

| Topic | Authorized stance |
| --- | --- |
| Bounded local loop | May be authored as PROP-039 proposal text. |
| Finite loop | Conservative first stance: `for` over finite collection, no `max_steps`. |
| Budgeted local loop | Conservative first stance: `loop` or fuel-bounded construct with static `max_steps`. |
| Structural recursion | Keep distinct from fuel-bounded recursion. |
| Fuel-bounded recursion | Keep distinct; static budget first. |
| `decreases fuel` | Fuel-bounded shorthand candidate only, not parser grammar. |
| `max_steps` | Static-first; dynamic expression policy deferred. |
| Service loop | PROP-037-owned; PROP-039 may reference only to exclude. |
| `tick.time` | Accepted event-time binding input from progression event. |
| `tick.event_id` | Pressure-only; no accepted accessor. |
| `now()` | Cross-reference Ch8 `OOF-L6`; do not mint replacement code. |
| Postulate 28 | Naming requirement may be specified; enforcement unimplemented. |
| OOF-L / OOF-R | Candidate/proposed diagnostics only; no registry authority. |
| `break` | Deferred; exclude from first authoring route. |
| Lab behavior | Frontier evidence only; no canon/conformance authority. |

---

## Forbidden Wording / Claim Scan

C2-I must avoid wording that implies:

```text
implemented
parser support
typechecker support
SemanticIR support
runtime support
igc run support
.igapp execution
.igbin execution
compiler passport emission
RuntimeSmoke support
public runtime support
Reference Runtime support
stable API
production readiness
release readiness
public demo support
public performance claim
official/reference implementation
alternative certification
portability guarantee
lab behavior as canon
R248 fixture grammar as canon
```

These phrases may appear only in explicit non-claim / closed-surface contexts.

---

## Must-Answer Items

### May C2-I begin?

Yes. C2-I may begin as bounded proposal-authoring only.

### May the PROP-039 proposal doc be created?

Yes.

### May `docs/proposals/README.md` be edited?

Yes, only to index / route the new PROP-039 proposal and preserve lifecycle
status.

### May the mainline authoring track doc be written?

Yes.

### May Runtime Specification chapters be edited?

No. `docs/spec/**` remains read-only in this route.

### May code, source, experiments, or playground files be edited?

No.

### Does service-loop material remain PROP-037-owned?

Yes. PROP-039 may reference service-loop material only to preserve the boundary.

### Does `tick.event_id` remain pressure-only?

Yes.

### Does R248 fixture grammar or lab behavior create canonical authority?

No. Both remain evidence only.

### Do protected surfaces remain closed?

Yes. Implementation, `igc run`, `.igapp`, `.igbin`, compiler passport,
RuntimeSmoke, public runtime, Reference Runtime, stable API, production, Spark,
release, performance, certification, and portability claims remain closed.

---

## C2-I Dispatch

```text
Card: S3-R251-C2-I
Skill: IDD Agent Protocol
Agent: [Compiler / Grammar Expert]
Role: compiler-grammar-expert
Track: experimental-managed-local-recursion-prop039-proposal-authoring-v0
Route: UPDATE
Depends on:
- S3-R251-C1-A
```

Allowed write scope:

```text
igniter-lang/docs/proposals/PROP-039-managed-local-recursion-and-loop-classes-v0.md
igniter-lang/docs/proposals/README.md
igniter-lang/docs/tracks/experimental-managed-local-recursion-prop039-proposal-authoring-v0.md
```

Expected result packet:

```text
exact changed files
PROP-039 section matrix
proposal README status
service-loop / PROP-037 separation status
OOF candidate wording status
Postulate 28 naming status
for / loop / max_steps stance
structural vs fuel-bounded recursion stance
forbidden wording scan
closed-surface scan
```

---

## Compact Decision Summary

```text
AUTHORIZED: bounded PROP-039 proposal authoring
ALLOWED: proposal doc, proposals README, authoring track doc
CLOSED: code, spec chapters, source, experiments, playgrounds, runtime,
        public/stable/release/performance/certification/portability claims
NEXT: S3-R251-C2-I proposal-authoring pass
```
