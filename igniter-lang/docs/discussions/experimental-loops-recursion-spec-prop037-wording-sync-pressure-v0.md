# Experimental Loops/Recursion Spec PROP-037 Wording Sync Pressure v0

Card: S3-R247-C3-X
Skill: IDD Agent Protocol
Agent: [External Pressure Reviewer]
Role: external-pressure-reviewer
Track: experimental-loops-recursion-spec-prop037-wording-sync-pressure-v0
Route: REVIEW
Status: done / accept
Date: 2026-06-04

Depends on:
- S3-R247-C1-A
- S3-R247-C2-I

---

## Verdict

Pressure verdict:

```text
ACCEPT
```

C2-I stayed inside the C1-A authorized wording-sync boundary. The touched docs
preserve the R246 ownership split:

- Chapter 13 / Runtime Spec / PROP-039+ owns managed local loops, recursion,
  loop classes, `max_steps`, `decreases fuel`, and future loop-naming fixtures.
- PROP-037 owns service-loop progression descriptor mapping as companion design
  wording only.
- Ch8 remains the source-level `now()` / `OOF-L6` anchor.
- The Language Covenant cross-references `OOF-L6` and routes managed local
  loops/recursion to PROP-039+ without minting new OOF authority.

No hold or redirect is required before C4-A.

---

## Inputs Reviewed

```text
igniter-lang/docs/tracks/
  experimental-loops-recursion-spec-prop037-wording-sync-authorization-review-v0.md
igniter-lang/docs/tracks/
  experimental-loops-recursion-spec-prop037-wording-sync-v0.md
igniter-lang/docs/spec/ch13-managed-recursion.md
igniter-lang/docs/proposals/
  PROP-037-external-progression-service-liveness-v0.md
igniter-lang/docs/spec/ch8-stdlib.md
igniter-lang/docs/language-covenant.md
igniter-lang/docs/proposals/README.md
igniter-lang/docs/tracks/stage3-round246-status-curation-v0.md
igniter-lang/docs/tracks/
  experimental-loops-recursion-runtime-spec-and-prop037-input-decision-v0.md
igniter-lang/docs/cards/S3/S3-R247.md
```

---

## Scope Pressure

### Write Scope

PASS.

C2-I commit `a5035f87` changed only:

```text
igniter-lang/docs/language-covenant.md
igniter-lang/docs/proposals/PROP-037-external-progression-service-liveness-v0.md
igniter-lang/docs/spec/ch13-managed-recursion.md
igniter-lang/docs/spec/ch8-stdlib.md
```

The C2-I track file was added by its own route. `docs/proposals/README.md` was
authorized only if needed and was not edited by C2-I. No `lib/**`, `bin/igc`,
`source/**`, `experiments/**`, `examples/**`, `playgrounds/**`, generated
output, release, public docs, Spark, or production surface was touched.

### Closed Surface Scan

PASS.

Closed surfaces remain closed:

```text
implementation
proof fixtures
igc run widening
.igbin execution
compiler passport emission
RuntimeSmoke productization
runtime support
public runtime support
Reference Runtime support
stable API
production
Spark
release
public demo
public performance
official/reference status
alternative certification
portability guarantees
lab behavior as canon
```

The closed-surface terms that appear in the reviewed files appear as negative
authority statements, future prerequisites, or unrelated pre-existing proposal
index/status vocabulary. They do not create new authority.

---

## Semantic Pressure Matrix

| Check | Verdict | Note |
| --- | --- | --- |
| Bounded local loops stay Chapter 13 / PROP-039+ | PASS | Ch13 and Covenant route local loops / loop classes to PROP-039+ or later. |
| Recursion / `decreases fuel` stays PROP-039+ | PASS | Ch13 says exact syntax, metric model, and diagnostics remain PROP-039+ design work. |
| Service-loop mapping stays PROP-037 companion territory | PASS | PROP-037 §4.1 is explicit companion design text and grants no parser/runtime authority. |
| `clock.every` source meaning | PASS | Ch13 §13.5 and PROP-037 §4.1 describe it as progression `source_kind` / source binding. |
| No `clock.every` / `Stream[DateTime]` equivalence | PASS | The updated wording explicitly denies semantic equivalence. |
| `tick.time` binding | PASS | Both Ch13 and PROP-037 define it as explicit event-time from materialized progression events, not ambient time. |
| Source-level `now()` | PASS | Ch8 `OOF-L6` remains the anchor; Ch13, PROP-037, and Covenant point back to explicit inputs or event-time binding. |
| OOF namespace | PASS | Ch8 and Ch13 both state no new OOF registry code is minted. OOF-R stays deferred design vocabulary. |
| `break` | PASS | Ch13 records source-level `break` as deferred. |
| Proof fixtures | PASS | No fixtures changed; OOF-L3 / unnamed-loop robustness remains future fixture work. |
| Lab-to-canon leakage | PASS | No playground/lab files changed; C2-I explicitly rejects lab behavior as canon. |
| Stale PROP numbering | PASS | Managed local recursion is now PROP-039+ or later; PROP-036 remains compiler profile identity. |

---

## Claim-Risk Notes

No blocking claim drift found.

Low residual wording risk:

- Ch13 still uses spec-intent language such as "compiler-checked obligations"
  for service loops. In isolation, that phrase could be read as stronger than
  current implementation evidence. In context, it is boxed by Stage 4 deferred
  status, "source syntax is not implemented", "future PROP-039+ proposal/proof",
  and PROP-037 "design text only" language. Treat as non-blocking, but C4-A may
  record that future Ch13 cleanup should keep "compiler-checked" phrasing
  visibly future/proposed until enforcement exists.
- PROP-037 contains pre-existing future-proof and readiness language. The C2-I
  addition does not worsen it; §4.1 adds the needed negative authority guard.
- `OOF-R*` and `OOF-PR*` remain distinct namespaces. C2-I did not accept OOF-R
  as registry authority and did not create a replacement for Ch8 `OOF-L6`.

---

## C4-A Recommendation

Exact recommendation:

```text
ACCEPT bounded wording sync
```

C4-A should record:

```text
WSYNC-1..WSYNC-15 pass
changed files are within authorized scope
Chapter 13 / PROP-039+ owns managed local loops and recursion
PROP-037 companion wording owns service-loop progression descriptor mapping
clock.every is progression source_kind / source binding only
tick.time is explicit event-time binding only
source-level now() remains prohibited via Ch8 OOF-L6
OOF-R remains deferred design vocabulary, not registry authority
break remains deferred
proof fixtures remain held
lab behavior remains frontier evidence only
runtime/public/release/performance/certification/portability surfaces remain closed
```

Recommended next route after C4-A acceptance:

```text
experimental-loops-recursion-proof-fixture-authorization-review-v0
```

Boundary for that next route:

```text
proof fixture authorization review only
no implementation authority unless explicitly granted
no igc run widening
no .igbin execution
no compiler passport emission
no RuntimeSmoke productization
no public/runtime/reference/production/Spark/release claims
no lab certification or portability claim
```
