# Experimental Managed Local Recursion PROP-039 Current Surface Facts v0

Card: S3-R249-C2-P1
Skill: IDD Agent Protocol
Agent: [Implementation Surface Surveyor]
Role: implementation-surface-surveyor
Track: experimental-managed-local-recursion-prop039-current-surface-facts-v0
Route: REPORT
Status: done / facts-only
Date: 2026-06-04

Depends on:
- S3-R249-C1-D

---

## Authority Notice

This packet is facts-only current-surface evidence for PROP-039+ managed local
recursion / loop-class authoring.

It does not authorize implementation, parser support, TypeChecker support,
SemanticIR support, runtime support, `igc run` widening, `.igapp` execution,
`.igbin` execution, compiler passport emission, RuntimeSmoke productization,
public runtime support, Reference Runtime support, stable API, production
readiness, release evidence, performance evidence, certification, portability,
or lab behavior as canon.

This packet changed only:

- `igniter-lang/docs/tracks/experimental-managed-local-recursion-prop039-current-surface-facts-v0.md`

---

## Inputs Read

- `igniter-lang/docs/tracks/experimental-managed-local-recursion-and-loop-classes-prop039-authoring-boundary-v0.md`
- `igniter-lang/docs/tracks/stage3-round248-status-curation-v0.md`
- `igniter-lang/docs/tracks/experimental-loops-recursion-proof-fixture-acceptance-decision-v0.md`
- `igniter-lang/experiments/experimental_loops_recursion_spec_fixtures_v0/manifest.json`
- `igniter-lang/experiments/experimental_loops_recursion_spec_fixtures_v0/out/summary.json`
- `igniter-lang/experiments/experimental_loops_recursion_spec_fixtures_v0/fixtures/**`
- `igniter-lang/docs/spec/ch13-managed-recursion.md`
- `igniter-lang/docs/spec/ch8-stdlib.md`
- `igniter-lang/docs/language-covenant.md`
- `igniter-lang/docs/proposals/PROP-037-external-progression-service-liveness-v0.md`
- `igniter-lang/docs/proposals/README.md`
- `playgrounds/igniter-lab/lab-docs/loops-and-recursion-pressure-package.md`
- `playgrounds/igniter-lab/lab-docs/loops-and-recursion-pressure-package-return.md`
- `playgrounds/igniter-lab/igniter-compiler/src/**`
- `playgrounds/igniter-lab/igniter-vm/src/**`

---

## Current Surface Facts

| Surface | Current fact | Authority status |
| --- | --- | --- |
| Bounded local loop wording | Ch13 names `FiniteLoop` and shows `for ClaimLoop item in claims`; R248 fixture uses `for ClaimLoop claim in claims max_steps: claims.count`. | PROP-039+ input only; `for ... max_steps` grammar is unresolved. |
| Structural recursion wording | Ch13 shows `recursive contract SumList ... decreases items.remaining` and `recur(...)`. | Deferred Stage 4 / PROP-039+ design text only. |
| Fuel-bounded recursion wording | Ch13 separates `fuel_bounded contract ... max_steps 10_000` from structural recursion. | Deferred Stage 4 / PROP-039+ design text only. |
| `decreases fuel` | Ch13 calls it design shorthand for static fuel budget; R248 fixture uses `recursive contract ... decreases fuel max_steps 100`. | Intent accepted as evidence; grammar/class split not canonical. |
| `for` / `loop` split | C1-D recommends `for` for finite collection iteration and `loop` for managed budgeted loops. Lab parser currently implements `loop Name in collection max_steps: IntLit`. | Proposal-authoring question; no mainline implementation authority. |
| `max_steps` static/dynamic | Ch13 requires static literal for `FuelBoundedRecursion`; C1-D recommends static literal first. R248 fixture uses dynamic `claims.count`, recorded as pressure only. Lab parser accepts integer literal only. | Static-first authoring stance; dynamic policy unresolved. |
| Service loop / progression | PROP-037 owns service-liveness progression descriptors. Ch13 says `ServiceLoop` is progression-backed and not local repetition territory. | Excluded from PROP-039+ authority except as boundary reference. |
| `tick.time` | PROP-037 companion wording and Ch13 treat `tick.time` as explicit event-time binding from materialized progression event. | Accepted service/progression input; not ambient time. |
| `tick.event_id` | R248 fixture includes `tick.event_id`; C4-A records it as fixture pressure only, not accepted spec input. | Unaccepted pressure; needs later PROP-037 companion/accessor route if desired. |
| `now()` / OOF-L6 | Ch8 says `now() -> DateTime -- OOF-L6: use TemporalCtx.as_of instead`; Ch13 and Covenant cross-reference this. | Current source-level wording anchor; no replacement OOF code should be minted here. |
| Postulate 28 loop naming | Covenant says loop class declarations must be named, but enforcement table marks loop class enforcement N/A until PROP-039+. R248 unnamed-loop fixture is diagnostic pressure only. | Governing commitment; no loop parser enforcement in mainline. |
| OOF-L / OOF-R / OOF-SL | Ch13 lists OOF-R1..R5 as deferred design vocabulary; lab pressure uses OOF-L1..L5 and OOF-SL1..SL2; Ch8 already owns OOF-L6 for `now()`. | Draft/pressure vocabulary except Ch8 OOF-L6; registry authority not created. |
| `break` | R248 negative fixture records `break` as deferred unsupported; lab lexer/VM have pressure support for `break`/`OP_LOOP_BREAK`. | Exclude from first PROP-039+ authoring slice unless a later route opens it. |

---

## Accepted Fixture Facts

R248 summary status is `PASS` with 16/16 checks passing, accepted only as
proof-local specification fixture evidence.

| Fixture | Fact |
| --- | --- |
| `bounded_local_collection_loop.ig` | Bounded local loop evidence; not `fold_stream`; grammar unresolved because it uses `for ... max_steps: claims.count`. |
| `recursion_decreases_fuel.ig` | Recursion / fuel pressure; `recursive contract ... decreases fuel max_steps` intent accepted but syntax not canonical. |
| `service_loop_clock_tick_time.ig` | Service-loop event-time pressure; `tick.time` aligns with PROP-037, `tick.event_id` does not. |
| `source_level_now_prohibited.ig` | Negative fixture anchored to Ch8 `OOF-L6`. |
| `unnamed_loop_robustness.ig` | Postulate 28 loop naming pressure only; enforcement not claimed. |
| `break_deferred_unsupported.ig` | `break` remains deferred and unsupported by the accepted packet. |
| `clock_every_not_stream_evidence.md` | `clock.every` is progression source binding, not `Stream[DateTime]`. |

---

## Lab Pressure Facts

`playgrounds/igniter-lab` is private frontier evidence only.

Observed compiler pressure:

- Lexer keyword list includes `loop`, `in`, `max_steps`, `decreases`, `fuel`,
  `clock`, `every`, duration units, and `break`.
- Parser AST includes `BodyDecl::Loop { name, collection, max_steps, body }`
  and `BodyDecl::ServiceLoop { name, interval, body }`.
- Parser accepts `loop Name in collection max_steps: <IntLit> { ... }`,
  records `OOF-L1` when `max_steps` is absent, and records `OOF-L3` for missing
  loop name pressure.
- Parser parses `clock.every(N.unit)` service-loop shape and records `OOF-L2`
  when `now` appears in contract-body identifier position.
- Function parser stores `decreases: Option<String>`.
- TypeChecker records `OOF-L4` for recursive functions without
  `decreases fuel`, and `OOF-L2` for `now()` in functions/contract nodes.
- Classifier creates loop declarations with propagated fragment class and
  service-loop declarations as `escape`.
- Emitter outputs `loop` nodes and `service_loop_node` with
  `temporal_binding` set to `<loop_name>.time`.

Observed VM pressure:

- VM instruction table includes `OP_LOOP_START`, `OP_LOOP_STEP`,
  `OP_LOOP_BREAK`, `OP_LOAD_TICK`, arrays, records, comparisons, jumps, and
  `OP_CALL`.
- VM loop execution keeps a `LoopFrame` with collection index and fuel, returning
  `OOF-L-FUEL` when fuel is exhausted.
- VM `OP_LOAD_TICK` resolves `tick.time` / `time` from temporal context or input
  and returns `OOF-SL1` when unresolved.
- VM has many array helpers and call-like behavior, but unknown/unimplemented
  `OP_CALL` functions still fail. No mainline recursion execution support is
  created by these lab paths.

Stale lab-doc facts:

- `loops-and-recursion-pressure-package-return.md` initially says loop,
  recursion, `now()`, service-loop, and VM loop opcodes were full gaps, then
  proposes draft implementation. Current lab code now contains much of that
  pressure implementation, so the early delta table is stale relative to code.
- The same lab doc uses older/non-canonical names such as `OOF-M1/M2`,
  `OOF-L-NOW`, `OOF-L-NAME`, and `OOF-L-RECURSE`; current canonical anchor for
  source-level `now()` is Ch8 `OOF-L6`.

---

## Support / Gap Matrix

| Topic | Docs/spec current | R248 fixtures | Lab pressure | Gap before PROP-039+ authority |
| --- | --- | --- | --- | --- |
| `FiniteLoop` | Named in Ch13 and Covenant | Bounded local loop fixture | Lab loop AST/parser/classifier/emitter/VM pressure | Canonical `for` vs `loop` syntax and acceptance criteria. |
| `StructuralRecursion` | Ch13 `recursive contract` + structural `decreases` | Not directly isolated | Recursive function detection pressure only | Formal syntax, proof obligations, `recur()` behavior, diagnostics. |
| `FuelBoundedRecursion` | Ch13 `fuel_bounded contract` + static `max_steps` | `decreases fuel` fixture conflates forms | `decreases fuel` TypeChecker pressure | Decide separate class vs unified `recursive` modifier. |
| `decreases fuel` | Design shorthand | Present | Present | Static budget requirement and grammar placement. |
| Dynamic `max_steps` | Not accepted | Present as `claims.count` | Lab accepts integer literal only | Dynamic expression policy and auditability. |
| ServiceLoop | Ch13/PROP-037 boundary | `clock.every` fixture | Lab service-loop pressure | Keep PROP-037-owned; do not fold into PROP-039+ local loops. |
| `tick.time` | Accepted event-time binding input | Present | Present as temporal binding pressure | Define accessor object only if PROP-037 companion opens. |
| `tick.event_id` | Not accepted | Present | No clear canonical support | Must remain pressure unless separately routed. |
| `now()` | Ch8 OOF-L6 | Negative fixture | Lab OOF-L2 pressure | Namespace reconciliation; no new code in PROP-039+. |
| P28 loop naming | Covenant planned PROP | Unnamed negative fixture | Lab OOF-L3 pressure | Proposal must state requirement; mainline enforcement closed. |
| `break` | Deferred | Negative fixture | Lab keyword/opcode pressure | Exclude first slice or open separate design route. |

---

## Implementation Surface Risk Map

| Surface | Risk if blurred | Current stance |
| --- | --- | --- |
| Parser / TypeChecker / SemanticIR | Lab pressure could be mistaken for canonical grammar or support. | Closed for mainline; author proposal first. |
| `for` vs `loop` | R248 fixture grammar could become accidental canon. | Resolve in PROP-039+ text before implementation. |
| Dynamic `max_steps` | Dynamic budgets may hide unbounded or unauditable behavior. | Static literal first; dynamic deferred. |
| Structural vs fuel recursion | `recursive contract ... decreases fuel` conflates two Ch13 classes. | Keep classes distinct in first authoring route. |
| Service loop boundary | PROP-039+ could accidentally absorb PROP-037 progression ownership. | Cross-reference only; service liveness remains PROP-037. |
| OOF namespace | Lab OOF-L* / OOF-SL* pressure conflicts with Ch8 OOF-L6 and Ch13 OOF-R*. | Include proposed diagnostics only; registry/errata separate if needed. |
| `tick.event_id` | Accessor could become source-level spec by fixture inertia. | Keep pressure only. |
| `break` | VM opcode pressure could imply source/runtime support. | Defer. |
| Runtime/public claims | Lab VM code could be misread as Reference Runtime or stable API. | Frontier evidence only; no public/stable/runtime support claim. |

---

## Closed-Surface Scan

Confirmed unchanged by this card:

- `igniter-lang/lib/**`
- `igniter-lang/bin/igc`
- `igniter-lang/igniter_lang.gemspec`
- `igniter-lang/README.md`
- `igniter-lang/docs/README.md`
- `igniter-lang/docs/ruby-api.md`
- `igniter-lang/docs/spec/**`
- `igniter-lang/docs/proposals/**`
- `igniter-lang/source/**`
- `igniter-lang/experiments/**`
- `playgrounds/**`

Commands were not required. Inspection was read-only except this facts packet.

---

## Exact C4-A Risk Notes

1. Accept this packet as facts-only current-surface evidence.
2. Preserve S3-R249-C1-D recommendation to open PROP-039+ proposal-authoring
   authorization after the reserved S3-R250 forms round.
3. Require the next authoring card to resolve:
   - `for` vs `loop`;
   - static-only first `max_steps`;
   - structural recursion vs fuel-bounded recursion;
   - `decreases fuel` grammar/meaning;
   - P28 loop naming acceptance criteria;
   - proposed OOF-L / OOF-R / OOF-SL vocabulary without registry authority;
   - `tick.event_id` as held pressure;
   - `break` as deferred.
4. Keep PROP-037 ownership of service liveness, `clock.every`, progression
   descriptors, checkpoint/cancellation/backpressure/receipts, and any future
   `tick` accessor object.
5. Do not open implementation, parser, TypeChecker, SemanticIR, runtime,
   `igc run`, `.igapp`, `.igbin`, compiler passport, RuntimeSmoke, public
   runtime, Reference Runtime, stable API, production, release, performance,
   certification, portability, or lab-canon authority from this evidence.

Recommendation:

```text
C4-A may accept this facts packet and keep the next route as:
experimental-managed-local-recursion-prop039-proposal-authoring-authorization-review-v0
implementation remains closed
```
