# Experimental Loops/Recursion Spec PROP-037 Wording Sync Acceptance Decision v0

Card: S3-R247-C4-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-loops-recursion-spec-prop037-wording-sync-acceptance-decision-v0
Route: UPDATE
Status: accepted
Date: 2026-06-04

Depends on:
- S3-R247-C2-I
- S3-R247-C3-X

---

## Decision

Accept the bounded Runtime Specification / PROP-037+ wording sync.

Decision:

```text
accept bounded wording sync
route proof-local loop/recursion spec fixture authorization review next
```

Accepted only as:

```text
specification/proposal wording evidence
ownership-boundary clarification
future proof-fixture input
```

Not accepted as:

```text
implementation authority
proof fixture execution authority
runtime support
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
S3-R247-C2-I stayed inside the C1-A authorized docs/proposal/spec wording
boundary. S3-R247-C3-X recommends ACCEPT and found no blocking scope, wording,
or claim drift.

The useful Main Line move is now a proof-fixture authorization review, not live
implementation or runtime widening.
```

---

## Accepted Files

The accepted C2-I wording sync reports these changed files:

- `igniter-lang/docs/spec/ch13-managed-recursion.md`
- `igniter-lang/docs/proposals/PROP-037-external-progression-service-liveness-v0.md`
- `igniter-lang/docs/spec/ch8-stdlib.md`
- `igniter-lang/docs/language-covenant.md`
- `igniter-lang/docs/tracks/experimental-loops-recursion-spec-prop037-wording-sync-v0.md`

`igniter-lang/docs/proposals/README.md` was authorized only if needed and was
not changed by C2-I.

This C4-A decision adds:

- `igniter-lang/docs/tracks/experimental-loops-recursion-spec-prop037-wording-sync-acceptance-decision-v0.md`

---

## Acceptance Record

| Surface | Decision |
| --- | --- |
| Authorization boundary adherence | Accepted. C2-I stayed inside docs/proposal/spec wording sync. |
| WSYNC-1..WSYNC-15 | Accepted as PASS. |
| Chapter 13 wording | Accepted. Managed local loops/recursion route to PROP-039+ or later. |
| Chapter 13 section 13.5 | Accepted. `clock.every` is no longer equated with `Stream[DateTime]`. |
| PROP-037 companion wording | Accepted as design/proposal companion text only. |
| Ch8 stdlib wording | Accepted. `OOF-L6` remains the source-level `now()` anchor. |
| Language Covenant wording | Accepted. Covenant routes source-level `now()` to Ch8 `OOF-L6` and local loop/recursion work to PROP-039+ or later. |
| Proposals README / PROP-039+ | Accepted unchanged. Existing README routing was sufficient for this slice. |
| Bounded local loops | Accepted as future Runtime Specification / PROP-039+ input only. |
| Recursion / `decreases fuel` | Accepted as future PROP-039+ design input only. |
| Service-loop / progression descriptor | Accepted as PROP-037 companion mapping only. |
| `clock.every` / `tick.time` | Accepted. `clock.every` is a progression source binding; `tick.time` is explicit event-time binding. |
| Source-level `now()` / OOF reconciliation | Accepted as wording/cross-reference only; no new OOF registry authority. |
| Postulate 28 / loop naming | Accepted as future PROP-039+ loop-class naming input only. |
| `break` | Deferred. |
| Proof fixtures | Held now; may open only via future authorization review. |
| Lab evidence authority | Frontier evidence only; no canonical authority. |
| Closed-surface scan | Accepted. Closed surfaces remain closed. |

---

## Explicit Answers

### Is the wording sync accepted?

Yes. The bounded Runtime Specification / PROP-037+ wording sync is accepted.

### May generated/touched docs be called specification/proposal wording evidence?

Yes. They may be called specification/proposal wording evidence and
ownership-boundary clarification only.

### Does this create implementation authority?

No. Implementation remains closed.

### Does this create proof fixture authority?

No. Proof fixture execution remains closed now.

### May proof-local loop/recursion fixture authorization open next?

Yes. A proof-local loop/recursion spec fixture authorization review may open
next. That route may authorize fixture work only if it explicitly keeps runtime,
CLI, package, public, release, performance, certification, and portability
authority closed.

### Does lab behavior create canonical authority?

No. Lab behavior remains frontier evidence only.

### Does `igc run` widening remain closed?

Yes. `igc run` widening remains closed.

### Do other protected claims remain closed?

Yes. `.igbin`, compiler passport emission, RuntimeSmoke productization, public
runtime, Reference Runtime, stable API, production, Spark, release, public demo,
public performance, official/reference status, alternative certification, and
portability claims remain closed.

---

## Compact Decision Summary

[D] Accept bounded wording sync.

[S] Ch13, PROP-037, Ch8, and Covenant now agree on the main ownership split:
local loops/recursion to PROP-039+ or later; service progression to PROP-037;
source-level `now()` prohibited through Ch8 `OOF-L6`; `tick.time` is explicit
event-time binding.

[T] WSYNC-1..WSYNC-15 are accepted as PASS. C3-X found no blocking scope or
claim drift.

[R] Keep implementation, proof execution, runtime, CLI, public, release,
performance, certification, and portability authority closed.

---

## Exact Next Dispatch Recommendation

Open:

```text
Card: S3-R248-C1-A
Skill: IDD Agent Protocol
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: experimental-loops-recursion-proof-fixture-authorization-review-v0
Route: UPDATE
Depends on:
- S3-R247-C4-A
```

Recommended route type:

```text
authorization review only
```

Recommended boundary:

- proof-local loop/recursion spec fixtures only;
- no live implementation authority unless explicitly and narrowly authorized
  by that future review;
- no `igc run` widening;
- no `.igbin` execution;
- no compiler passport emission;
- no RuntimeSmoke productization;
- no public runtime support;
- no Reference Runtime support;
- no stable API, production, Spark, release, public demo, public performance,
  official/reference status, alternative certification, or portability claims;
- lab behavior remains frontier evidence only.
