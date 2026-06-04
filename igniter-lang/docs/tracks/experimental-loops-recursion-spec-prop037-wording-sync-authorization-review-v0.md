# Experimental Loops/Recursion Spec PROP-037 Wording Sync Authorization Review v0

Card: S3-R247-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-loops-recursion-spec-prop037-wording-sync-authorization-review-v0
Route: UPDATE
Status: authorized / route-c2-i
Date: 2026-06-04

Depends on:
- S3-R246-C5-S

---

## Decision

Authorize a bounded C2-I wording-sync authoring route.

Decision:

```text
authorize bounded combined Runtime Spec / PROP-037+ wording sync authoring
```

Authorized as:

```text
docs/proposal/spec wording sync only
specification-input consolidation only
not implementation authority
not proof fixture authority
not runtime support
not public runtime support
not Reference Runtime support
not lab behavior as canon
```

Rationale:

```text
R246 accepted the input slice with scope corrections and required this C1-A
authorization review before any authoring.

The next useful move is to fix stale wording and ownership boundaries so later
proof fixtures can target a clearer contract. The next move is not code,
runtime, igc run widening, proof execution, or public/runtime authority.
```

---

## Inputs Read

```text
igniter-lang/docs/tracks/stage3-round246-status-curation-v0.md
igniter-lang/docs/tracks/
  experimental-loops-recursion-runtime-spec-and-prop037-input-decision-v0.md
igniter-lang/docs/tracks/
  experimental-loops-recursion-runtime-spec-and-prop037-input-slice-v0.md
igniter-lang/docs/tracks/
  experimental-loops-recursion-runtime-spec-current-surface-facts-v0.md
igniter-lang/docs/discussions/
  r246-runtime-spec-prop037-input-pressure-v0.md
igniter-lang/docs/spec/ch13-managed-recursion.md
igniter-lang/docs/spec/ch8-stdlib.md
igniter-lang/docs/language-covenant.md
igniter-lang/docs/proposals/
  PROP-037-external-progression-service-liveness-v0.md
igniter-lang/docs/proposals/README.md
igniter-lang/docs/tracks/
  prop037-external-progression-proposal-authoring-v0.md
igniter-lang/docs/tracks/
  covenant-promise-enforcement-path-rule-v0.md
igniter-lang/docs/current-status.md
```

No code, runtime, CLI, package, public docs, source fixtures, experiments,
examples, playgrounds, generated outputs, release, Spark, or production surface
was edited by this authorization review.

This C1-A decision adds:

```text
igniter-lang/docs/tracks/
  experimental-loops-recursion-spec-prop037-wording-sync-authorization-review-v0.md
```

---

## Authorization Summary

| Question | Decision |
| --- | --- |
| May C2-I begin? | Yes. |
| Route type | Bounded docs/proposal/spec wording sync authoring. |
| Chapter 13 edit | Authorized, narrow. |
| PROP-037 edit | Authorized, narrow companion/amendment wording only. |
| Ch8 stdlib edit | Authorized, narrow `now()` / OOF cross-reference or errata only. |
| Language Covenant edit | Authorized, narrow `now()` / OOF / PROP-039+ routing wording only. |
| Proposals README edit | Authorized only for narrow PROP-039+ routing/index clarification if needed. |
| OOF reconciliation | Included now, but as wording/cross-reference input only, not registry acceptance. |
| Chapter 13 §13.5 | Must be corrected in this pass. |
| `break` | Deferred. |
| Proof fixtures | Held. |
| Lab behavior | Frontier evidence only. |
| Implementation / runtime / public authority | Closed. |

---

## Authorized C2-I Boundary

```text
Card: S3-R247-C2-I
Skill: IDD Agent Protocol
Agent: [Compiler / Grammar Expert]
Role: compiler-grammar-expert
Track: experimental-loops-recursion-spec-prop037-wording-sync-v0

Route: UPDATE
Depends on:
- S3-R247-C1-A

Goal:
Author a bounded Runtime Spec / PROP-037+ wording sync that fixes the accepted
R246 wording gaps for loops/recursion/service-loop progression, source-level
now() prohibition, Chapter 13 section 13.5, and PROP-039+ routing without
authorizing implementation, proof fixtures, runtime support, public claims,
certification, or portability.
```

### Allowed Write Scope

```text
igniter-lang/docs/tracks/
  experimental-loops-recursion-spec-prop037-wording-sync-v0.md

igniter-lang/docs/spec/ch13-managed-recursion.md
  narrow Chapter 13 errata / wording sync only

igniter-lang/docs/proposals/
  PROP-037-external-progression-service-liveness-v0.md
  narrow service-loop-to-progression companion/amendment wording only

igniter-lang/docs/proposals/README.md
  narrow PROP-039+ managed local recursion / loop-class routing/index wording
  only if needed

igniter-lang/docs/spec/ch8-stdlib.md
  narrow source-level now() / OOF cross-reference or errata wording only

igniter-lang/docs/language-covenant.md
  narrow source-level now() / OOF cross-reference and PROP-039+ loop-class
  routing wording only
```

### Read-Only / Closed Surfaces

Closed unless a later card explicitly authorizes them:

```text
igniter-lang/lib/**
igniter-lang/bin/igc
igniter-lang/igniter_lang.gemspec
igniter-lang/README.md
igniter-lang/docs/README.md
igniter-lang/docs/ruby-api.md
igniter-lang/source/**
igniter-lang/experiments/**
igniter-lang/examples/**
playgrounds/**
any generated output under out/**
release/signing/tag/publish/deploy surfaces
```

### Required Authoring Outcomes

The C2-I wording sync must:

```text
1. Preserve the split between fold_stream, bounded local loops, recursion, and
   service-loop/progression.
2. Correct Chapter 13 status/source wording so managed local recursion and loop
   classes route to PROP-039+ or later, not stale PROP-037+ / PROP-036+ wording.
3. Correct Chapter 13 section 13.5 so clock.every is a progression source_kind,
   not semantically equivalent to Stream[DateTime].
4. Replace stale Chapter 13 now() examples with explicit binding language such
   as tick.time / explicit TemporalCtx-style input, without adding execution
   authority.
5. Add bounded local loop / max_steps wording as Chapter 13 / Runtime Spec
   design text only.
6. Add recursion / decreases fuel wording as Chapter 13 / PROP-039+ design text
   only.
7. Add service-loop source binding wording only as a PROP-037 companion or
   amendment to progression descriptor mapping.
8. Preserve the accepted PROP-037 stance: no new PROGRESSION fragment class,
   no parser/runtime/scheduler authority, no public runtime support.
9. Reconcile source-level now() OOF wording as a narrow cross-reference/errata
   stance across Ch8 and the Language Covenant without accepting a new OOF
   registry code.
10. Record OOF-L3 / unnamed-loop robustness as a future fixture requirement,
    not as proven enforcement.
11. Keep break deferred.
12. Keep lab implementation evidence frontier-only.
```

### Required Proof / Review Matrix

C2-I must report these checks:

| Check | Requirement |
| --- | --- |
| WSYNC-1 | Only authorized files changed. |
| WSYNC-2 | Chapter 13 no longer routes managed local recursion to stale `PROP-037+` / `PROP-036+` wording. |
| WSYNC-3 | PROP-039+ or later is the managed local recursion / loop-class slot. |
| WSYNC-4 | Chapter 13 section 13.5 no longer equates `clock.every` with `Stream[DateTime]`. |
| WSYNC-5 | `clock.every` is described as a progression `source_kind` / source binding only. |
| WSYNC-6 | `tick.time` is explicit event-time binding, not ambient time. |
| WSYNC-7 | Source-level `now()` remains prohibited. |
| WSYNC-8 | OOF reconciliation is wording/cross-reference only, no new registry authority. |
| WSYNC-9 | Bounded local loops remain separate from `fold_stream`. |
| WSYNC-10 | Recursion / `decreases fuel` remains local managed recursion territory, not PROP-037 service liveness. |
| WSYNC-11 | PROP-037 service-loop wording remains companion/amendment only, no runtime authority. |
| WSYNC-12 | `break` remains deferred. |
| WSYNC-13 | Proof fixtures remain held. |
| WSYNC-14 | Lab evidence remains frontier-only. |
| WSYNC-15 | Forbidden wording scan passes. |

### Command Matrix

Required:

```text
git diff --check -- \
  igniter-lang/docs/tracks/experimental-loops-recursion-spec-prop037-wording-sync-v0.md \
  igniter-lang/docs/spec/ch13-managed-recursion.md \
  igniter-lang/docs/proposals/PROP-037-external-progression-service-liveness-v0.md \
  igniter-lang/docs/proposals/README.md \
  igniter-lang/docs/spec/ch8-stdlib.md \
  igniter-lang/docs/language-covenant.md
```

Optional, if the agent wants an additional closed-surface scan:

```text
git status --short
```

No Ruby, runtime, compiler, CLI, release, or playground command is required or
authorized by this card.

### Forbidden Wording Scan

C2-I must not introduce wording that claims or implies:

```text
implemented
production-ready
stable API
public runtime support
Reference Runtime support
conformance certification
alternative certified implementation
portability guarantee
performance claim
igc run support
.igbin execution
compiler passport emission
RuntimeSmoke productization
lab behavior as canon
```

The word "implemented" may appear only when describing current negative facts
or existing partial enforcement in quoted/status contexts, not as new authority
for loops/recursion/service-loop execution.

---

## Explicit Answers

Whether C2-I may begin:

```text
Yes.
```

Whether `docs/spec/ch8-stdlib.md` may be touched:

```text
Yes, narrowly, only for source-level now() / OOF cross-reference or errata
wording. No broad stdlib rewrite is authorized.
```

Whether `docs/language-covenant.md` may be touched:

```text
Yes, narrowly, only for source-level now() / OOF cross-reference and
PROP-039+ loop-class routing wording. No broad Covenant rewrite is authorized.
```

Whether OOF reconciliation is included now or deferred:

```text
Included now, but only as wording/cross-reference/errata input. C2-I must not
accept a new OOF registry code or claim enforcement.
```

Whether PROP-037 receives a direct amendment or companion wording only:

```text
Authorize companion/amendment wording inside the existing PROP-037 proposal
file, limited to service-loop source syntax mapping, progression descriptors,
clock.every source_kind, and tick.time binding. C2-I must not change PROP-037
into a local recursion proposal.
```

Whether `docs/proposals/README.md` may be updated for PROP-039+ routing:

```text
Yes, narrowly, only if needed to keep managed local recursion / loop-class
routing on PROP-039+ or later.
```

Whether Chapter 13 section 13.5 must be corrected in this pass:

```text
Yes.
```

Whether `break` remains deferred:

```text
Yes.
```

Whether proof fixtures remain held:

```text
Yes.
```

Whether lab behavior remains frontier evidence only:

```text
Yes.
```

Whether implementation, `igc run`, `.igbin`, compiler passport emission,
RuntimeSmoke, public runtime, Reference Runtime, stable API, production, Spark,
release, public performance, official/reference status, alternative
certification, and portability claims remain closed:

```text
Yes. All remain closed.
```

---

## Compact Decision Summary

R247-C1-A authorizes the next C2-I wording-sync pass because R246 already
accepted the input slice and identified exact stale wording / write-scope gaps.

The authorization is intentionally narrow:

```text
Chapter 13 / Runtime Spec / PROP-039+:
  bounded local loops
  max_steps
  recursion / decreases fuel
  local loop naming / Postulate 28 future fixture requirement
  local-loop OOF wording input

PROP-037 companion/amendment:
  service-loop source syntax to progression descriptor mapping
  clock.every source_kind binding
  tick.time explicit event-time binding
  no PROGRESSION fragment class

Ch8 / Covenant:
  now() remains forbidden
  OOF naming reconciled as wording/errata input only
```

This authorization does not open proof fixtures. If C2-I is accepted later,
the likely next route is a C4-A decision that may choose between proof-local
loop/recursion spec fixture authorization, OOF registry/errata follow-up,
PROP-039+ proposal authoring, or a hold.

---

## Exact C2-I Dispatch

```text
Card: S3-R247-C2-I
Skill: IDD Agent Protocol
Agent: [Compiler / Grammar Expert]
Role: compiler-grammar-expert
Track: experimental-loops-recursion-spec-prop037-wording-sync-v0

Route: UPDATE
Depends on:
- S3-R247-C1-A

Goal:
Author a bounded Runtime Spec / PROP-037+ wording sync that fixes accepted R246
wording gaps for Chapter 13, PROP-037 service-loop/progression mapping,
source-level now() / OOF cross-references, and PROP-039+ routing, without
authorizing implementation, proof fixtures, runtime support, public claims,
certification, or portability.

Allowed write scope:
- igniter-lang/docs/tracks/
  experimental-loops-recursion-spec-prop037-wording-sync-v0.md
- igniter-lang/docs/spec/ch13-managed-recursion.md
- igniter-lang/docs/proposals/
  PROP-037-external-progression-service-liveness-v0.md
- igniter-lang/docs/proposals/README.md
  only for narrow PROP-039+ routing/index wording if needed
- igniter-lang/docs/spec/ch8-stdlib.md
  only for narrow source-level now() / OOF cross-reference or errata
- igniter-lang/docs/language-covenant.md
  only for narrow source-level now() / OOF / PROP-039+ routing wording

Read-only / closed unless explicitly authorized:
- igniter-lang/lib/**
- igniter-lang/bin/igc
- igniter-lang/igniter_lang.gemspec
- igniter-lang/README.md
- igniter-lang/docs/README.md
- igniter-lang/docs/ruby-api.md
- igniter-lang/source/**
- igniter-lang/experiments/**
- igniter-lang/examples/**
- playgrounds/**
- any generated output under out/**

Required command matrix:
- git diff --check -- relevant authorized files

Deliver:
- Wording-sync doc in `igniter-lang/docs/tracks/`
- Compact WSYNC-1..WSYNC-15 result matrix
- Exact C4-A recommendation
```
