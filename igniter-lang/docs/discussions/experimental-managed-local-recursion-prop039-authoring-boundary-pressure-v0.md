# Experimental Managed Local Recursion PROP-039 Authoring Boundary Pressure v0

Card: S3-R249-C3-X
Skill: IDD Agent Protocol
Agent: [External Pressure Reviewer]
Role: external-pressure-reviewer
Track: experimental-managed-local-recursion-prop039-authoring-boundary-pressure-v0
Route: REVIEW
Status: done / accept
Date: 2026-06-04

Depends on:
- S3-R249-C1-D
- S3-R249-C2-P1

---

## Verdict

Pressure verdict:

```text
ACCEPT
```

C1-D and C2-P1 correctly keep R248 fixture evidence in the design-input lane.
They do not convert proof-local fixture grammar, lab implementation behavior, or
current lab parser/VM pressure into canonical language authority.

C4-A may accept the PROP-039+ authoring boundary and route the next Main Line
step to a proposal-authoring authorization review.

---

## Inputs Reviewed

```text
igniter-lang/docs/tracks/
  experimental-managed-local-recursion-and-loop-classes-prop039-authoring-boundary-v0.md
igniter-lang/docs/tracks/
  experimental-managed-local-recursion-prop039-current-surface-facts-v0.md
igniter-lang/docs/tracks/
  experimental-loops-recursion-proof-fixture-acceptance-decision-v0.md
igniter-lang/docs/tracks/experimental-loops-recursion-proof-fixture-v0.md
igniter-lang/docs/discussions/r248-loops-recursion-proof-fixture-pressure-v0.md
igniter-lang/experiments/experimental_loops_recursion_spec_fixtures_v0/
  manifest.json
igniter-lang/experiments/experimental_loops_recursion_spec_fixtures_v0/out/
  summary.json
igniter-lang/experiments/experimental_loops_recursion_spec_fixtures_v0/
  fixtures/**
igniter-lang/docs/cards/S3/S3-R249.md
```

---

## Boundary Pressure Results

| Check | Verdict | Note |
| --- | --- | --- |
| Fixture-to-canon drift | PASS | R248 fixtures are design-input evidence only; C1-D explicitly rejects R248 fixture grammar as canon. |
| `recursive contract` vs `fuel_bounded contract` | PASS | C1-D preserves separate structural and fuel-bounded classes for the first authoring route. |
| `decreases fuel` | PASS | Treated as fuel-bounded design shorthand/input, not parser grammar or implementation authority. |
| `for ... max_steps` | PASS | Kept as pressure only; conservative draft recommends `for` without `max_steps` and `loop` with static budget. |
| Static vs dynamic `max_steps` | PASS | Static literal first; dynamic expressions deferred until type/audit rules exist. |
| `tick.event_id` | PASS | Held as unaccepted fixture pressure and routed, if desired, to a later PROP-037 companion/accessor decision. |
| PROP-037 leakage | PASS | Service liveness, `clock.every`, progression descriptors, materialization, checkpoint, cancellation, receipts, and backpressure remain PROP-037-owned. |
| OOF-L / OOF-R / OOF-SL registry claim | PASS | Draft/proposed vocabulary only, except Ch8 `OOF-L6` as the current `now()` anchor. No registry authority is claimed. |
| Postulate 28 loop naming | PASS | Ready as proposal input; no parser enforcement is claimed. |
| `break` | PASS | First PROP-039+ draft should exclude `break`; future route required for semantics/evidence/fuel/receipt behavior. |
| Lab evidence | PASS | Lab code and docs remain frontier pressure only, not canon, conformance, runtime, or reference evidence. |
| Implementation/public claims | PASS | Parser, TypeChecker, SemanticIR, runtime, API/CLI/package, release, public/stable/reference/performance/certification/portability claims remain closed. |

---

## Claim-Risk Notes

No blocking claim drift found.

Residual non-blocking risks to carry into C4-A:

1. `for` / `loop` wording must stay conservative. The next authorization card
   should not phrase `for ... max_steps` as allowed syntax. It should say R248
   used that shape as pressure and PROP-039+ must decide the canonical split.
2. `decreases fuel` should not be written as if it is already a grammar form.
   It is acceptable as a fuel-bounded design shorthand candidate only.
3. OOF tables in the next proposal draft should be marked "proposed" or
   "candidate" unless C4-A opens a separate registry/errata authority.
4. Lab parser/VM facts in C2-P1 are useful, but they should not become
   implementation acceptance criteria for PROP-039+. The next route should
   author proposal boundaries first.

These are authoring constraints, not reasons to hold R249.

---

## C4-A Recommendation

Exact recommendation:

```text
ACCEPT PROP-039+ authoring boundary
ACCEPT C2-P1 as facts-only current-surface evidence
OPEN proposal-authoring authorization review next
KEEP implementation and public/runtime/release claims closed
```

C4-A should explicitly record:

```text
R248 fixtures are sufficient design input
R248 fixture grammar is not canon
lab behavior is frontier evidence only
recursive contract and fuel_bounded contract remain distinct for first authoring
decreases fuel is a fuel-bounded design shorthand candidate only
for ... max_steps remains pressure only
static literal max_steps is the first stance
dynamic max_steps is deferred
tick.event_id remains unaccepted pressure
service-loop/progression ownership remains PROP-037
OOF-L / OOF-R / OOF-SL are proposed/draft vocabulary only
Ch8 OOF-L6 remains the now() anchor
Postulate 28 loop naming is proposal input, not current enforcement
break remains deferred
implementation/parser/typechecker/SemanticIR/runtime/API/CLI/package authority remains closed
public runtime, Reference Runtime, stable API, production, Spark, release,
performance, official/reference status, certification, and portability claims
remain closed
```

Exact next route:

```text
experimental-managed-local-recursion-prop039-proposal-authoring-authorization-review-v0
```

Recommended dispatch shape, preserving the R250 reservation already recorded in
C1-D:

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

Expected authorization review scope:

```text
decide whether to authorize proposal authoring only
allowed write scope, if authorized:
  igniter-lang/docs/proposals/PROP-039-managed-local-recursion-and-loop-classes-v0.md
  igniter-lang/docs/proposals/README.md
  igniter-lang/docs/tracks/experimental-managed-local-recursion-prop039-proposal-authoring-v0.md
closed:
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

No hold or redirect is recommended.
