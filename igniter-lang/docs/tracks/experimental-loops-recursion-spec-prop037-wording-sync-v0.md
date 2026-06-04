# Experimental Loops/Recursion Spec PROP-037 Wording Sync v0

Card: S3-R247-C2-I
Skill: IDD Agent Protocol
Agent: [Compiler / Grammar Expert]
Role: compiler-grammar-expert
Track: experimental-loops-recursion-spec-prop037-wording-sync-v0
Route: UPDATE
Status: done / bounded wording sync
Date: 2026-06-04

Depends on:
- S3-R247-C1-A

---

## Authority Boundary

This route is docs/proposal/spec wording sync only.

It does not authorize:

- implementation;
- proof fixtures;
- `igc run` widening;
- `.igbin` execution;
- compiler passport emission;
- RuntimeSmoke productization;
- runtime support;
- public runtime support;
- Reference Runtime support;
- stable API, production, Spark, release, public demo, public performance,
  certification, portability, or alternative implementation claims;
- lab behavior as canon.

---

## Inputs Read

- `igniter-lang/docs/tracks/experimental-loops-recursion-spec-prop037-wording-sync-authorization-review-v0.md`
- `igniter-lang/docs/tracks/stage3-round246-status-curation-v0.md`
- `igniter-lang/docs/tracks/experimental-loops-recursion-runtime-spec-and-prop037-input-decision-v0.md`
- `igniter-lang/docs/tracks/experimental-loops-recursion-runtime-spec-current-surface-facts-v0.md`
- `igniter-lang/docs/discussions/r246-runtime-spec-prop037-input-pressure-v0.md`
- `igniter-lang/docs/spec/ch13-managed-recursion.md`
- `igniter-lang/docs/proposals/PROP-037-external-progression-service-liveness-v0.md`
- `igniter-lang/docs/proposals/README.md`
- `igniter-lang/docs/spec/ch8-stdlib.md`
- `igniter-lang/docs/language-covenant.md`

---

## Changed Files

Changed:

- `igniter-lang/docs/spec/ch13-managed-recursion.md`
- `igniter-lang/docs/proposals/PROP-037-external-progression-service-liveness-v0.md`
- `igniter-lang/docs/spec/ch8-stdlib.md`
- `igniter-lang/docs/language-covenant.md`
- `igniter-lang/docs/tracks/experimental-loops-recursion-spec-prop037-wording-sync-v0.md`

Not changed:

- `igniter-lang/docs/proposals/README.md`

Reason: the proposal index already routes managed local recursion / loop-class
extensions to `PROP-039+ or later`; no additional narrow index wording was
needed for this slice.

---

## Wording Sync Summary

### Chapter 13

Updated `ch13-managed-recursion.md` to:

- route managed local recursion / loop-class extensions to `PROP-039+ or later`;
- state that PROP-037 owns external progression and service liveness;
- remove stale `PROP-037+ placeholder` wording;
- replace `now()` service-loop examples with explicit `tick.time` binding;
- make service-loop source syntax explicitly design-only;
- state that `clock.every` is a progression `source_kind` / source binding, not
  semantically equivalent to `Stream[DateTime]`;
- preserve `fold_stream` as a separate stream/window bounded fold surface;
- add `decreases fuel` as design wording only for future PROP-039+ work;
- mark OOF-R rows as deferred design vocabulary, not registry authority;
- record OOF-L3 unnamed-loop robustness as a future fixture requirement;
- keep source-level `break` deferred.

### PROP-037

Added companion wording to PROP-037:

- future service-loop source surfaces map conceptually to `ProgressionSource`;
- `clock.every` is a progression `source_kind`;
- `tick.time` is explicit event-time binding from materialized progression
  events;
- source-level `now()` remains prohibited;
- local loops, structural recursion, fuel-bounded recursion, and
  `decreases fuel` remain Chapter 13 / PROP-039+ territory.

The companion section explicitly preserves no parser, TypeChecker, SemanticIR,
runtime, scheduler, or public runtime authority.

### Ch8 / Covenant

Updated narrow `now()` cross-references:

- Ch8 `OOF-L6` remains the current source-level ambient-clock wording anchor.
- The wording does not mint a new OOF registry code.
- Covenant references now route source-level `now()` prohibition to Ch8
  `OOF-L6` instead of stale `OOF-M1`.
- Covenant P14/P28 routing now points managed local loops / loop classes to
  `PROP-039+ or later` and service liveness to PROP-037 descriptors.

---

## WSYNC Matrix

| Check | Result | Evidence |
| --- | --- | --- |
| WSYNC-1 only authorized files changed | PASS | Changed files are limited to this track, Ch13, PROP-037, Ch8, and Covenant. |
| WSYNC-2 no stale `PROP-037+` / `PROP-036+` routing in Ch13 | PASS | Ch13 source line now names `PROP-039+` and PROP-037 service liveness. |
| WSYNC-3 PROP-039+ is managed local recursion / loop-class slot | PASS | Ch13 and Covenant route local loops/recursion to `PROP-039+ or later`; proposals README already did. |
| WSYNC-4 Ch13 §13.5 no longer equates `clock.every` with `Stream[DateTime]` | PASS | Equivalence sentence removed. |
| WSYNC-5 `clock.every` is progression source binding only | PASS | Ch13 §13.5 and PROP-037 §4.1 say progression `source_kind` / source binding. |
| WSYNC-6 `tick.time` is explicit event-time binding | PASS | Ch13 and PROP-037 state `tick.time` is event-time, not ambient time. |
| WSYNC-7 source-level `now()` remains prohibited | PASS | Ch8 `OOF-L6`, Ch13, PROP-037, and Covenant all preserve prohibition. |
| WSYNC-8 OOF reconciliation is cross-reference only | PASS | Ch8 and Ch13 state no new OOF registry code is minted. |
| WSYNC-9 bounded local loops remain separate from `fold_stream` | PASS | Ch13 relationship section and PROP-037 preserve stream/window separation. |
| WSYNC-10 recursion / `decreases fuel` remains local managed recursion territory | PASS | Ch13 routes exact syntax/ownership to PROP-039+; PROP-037 excludes it. |
| WSYNC-11 PROP-037 wording remains companion/amendment only | PASS | PROP-037 §4.1 is design text only and grants no parser/runtime authority. |
| WSYNC-12 `break` remains deferred | PASS | Ch13 records source-level `break` as deferred. |
| WSYNC-13 proof fixtures remain held | PASS | No `experiments/**`, `source/**`, or fixture files changed. |
| WSYNC-14 lab evidence remains frontier-only | PASS | No `playgrounds/**` changed; this track does not accept lab behavior as canon. |
| WSYNC-15 forbidden wording scan passes | PASS | Forbidden terms appear only in negative/non-authorization contexts or unrelated pre-existing index rows. |

---

## Command Matrix

Required command:

```text
git diff --check -- \
  igniter-lang/docs/tracks/experimental-loops-recursion-spec-prop037-wording-sync-v0.md \
  igniter-lang/docs/spec/ch13-managed-recursion.md \
  igniter-lang/docs/proposals/PROP-037-external-progression-service-liveness-v0.md \
  igniter-lang/docs/proposals/README.md \
  igniter-lang/docs/spec/ch8-stdlib.md \
  igniter-lang/docs/language-covenant.md
```

Result:

```text
PASS
```

Additional read-only checks:

```text
rg -n 'PROP-037\+|PROP-036\+|OOF-M1|lab behavior as canon|Reference Runtime support|certification|portability guarantee|igc run support|\.igbin execution|compiler passport emission|RuntimeSmoke productization' \
  igniter-lang/docs/spec/ch13-managed-recursion.md \
  igniter-lang/docs/proposals/PROP-037-external-progression-service-liveness-v0.md \
  igniter-lang/docs/spec/ch8-stdlib.md \
  igniter-lang/docs/language-covenant.md \
  igniter-lang/docs/proposals/README.md
```

Result:

```text
PASS:
- authorized spec/proposal/covenant files contain no stale managed-recursion
  `PROP-037+` / `PROP-036+` routing;
- proposals README has one unrelated existing row where PROP-031 summary
  mentions OOF-M1 for contract modifiers;
- this track document contains forbidden-scan terms only in negative
  non-authorization context and in the scan command itself.
```

---

## C4-A Recommendation

Recommended decision:

```text
accept bounded wording sync
confirm WSYNC-1..WSYNC-15 PASS
keep implementation/proof/runtime/public/reference/certification/portability
surfaces closed
open a later proof-fixture authorization review only after this wording sync is
accepted
```

Recommended next route:

```text
experimental-loops-recursion-proof-fixture-authorization-review-v0
```

Recommended boundary for that future route:

- proof fixtures only;
- no canonical runtime support;
- no `igc run` widening;
- no `.igbin` execution;
- no compiler passport emission;
- no lab certification;
- no public/runtime/reference/production/Spark/release claims.

---

## Compact Handoff

[D] Ch13, PROP-037, Ch8, and Covenant now agree on the key wording boundaries:
PROP-039+ owns local loops/recursion, PROP-037 owns service progression, and
`now()` remains prohibited.

[S] `clock.every` is no longer described as `Stream[DateTime]`; it is a
progression source binding. `tick.time` is explicit event-time binding.

[T] WSYNC-1..15 are recorded as PASS; required `git diff --check` passes.

[R] C4-A should accept the wording sync and keep implementation/proof/runtime
support closed.

[Next] Consider proof-fixture authorization review only after acceptance.
