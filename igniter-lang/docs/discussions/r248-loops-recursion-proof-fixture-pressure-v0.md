# R248 Loops/Recursion Proof Fixture — External Pressure Review

Card: S3-R248-C3-X
Agent: [External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: pressure-review
Track: experimental-loops-recursion-proof-fixture-pressure-v0

Status: done / conditional-pass
Date: 2026-06-04

Depends on:
- S3-R248-C1-A (experimental-loops-recursion-proof-fixture-authorization-review-v0.md)
- S3-R248-C2-I (experimental-loops-recursion-proof-fixture-v0.md)

Also reviewed:
- All seven fixture files under `experiments/experimental_loops_recursion_spec_fixtures_v0/fixtures/`
- `experiments/experimental_loops_recursion_spec_fixtures_v0/manifest.json`
- `experiments/experimental_loops_recursion_spec_fixtures_v0/out/summary.json`
- `docs/tracks/experimental-loops-recursion-spec-prop037-wording-sync-acceptance-decision-v0.md`
- `docs/spec/ch13-managed-recursion.md`
- `docs/proposals/PROP-037-external-progression-service-liveness-v0.md`

---

## Verdict

**CONDITIONAL PASS** — three semantic fidelity issues found in fixture content.
No scope violations, no authority drift, no lab-to-canon leakage, no forbidden
claims. The issues are fixture wording precision problems that could mislead
future PROP-039+ or PROP-037 companion authoring if accepted without
qualification.

C4-A may accept the fixture packet with three required record items. None of the
issues warrant a hold.

---

## Pressure-Test Results

### 1. C2-I stayed inside authorized write scope?

**Yes — clean.**

Changed files confirmed:

```text
igniter-lang/docs/tracks/experimental-loops-recursion-proof-fixture-v0.md
igniter-lang/experiments/experimental_loops_recursion_spec_fixtures_v0/fixtures/bounded_local_collection_loop.ig
igniter-lang/experiments/experimental_loops_recursion_spec_fixtures_v0/fixtures/break_deferred_unsupported.ig
igniter-lang/experiments/experimental_loops_recursion_spec_fixtures_v0/fixtures/clock_every_not_stream_evidence.md
igniter-lang/experiments/experimental_loops_recursion_spec_fixtures_v0/fixtures/recursion_decreases_fuel.ig
igniter-lang/experiments/experimental_loops_recursion_spec_fixtures_v0/fixtures/service_loop_clock_tick_time.ig
igniter-lang/experiments/experimental_loops_recursion_spec_fixtures_v0/fixtures/source_level_now_prohibited.ig
igniter-lang/experiments/experimental_loops_recursion_spec_fixtures_v0/fixtures/unnamed_loop_robustness.ig
igniter-lang/experiments/experimental_loops_recursion_spec_fixtures_v0/manifest.json
igniter-lang/experiments/experimental_loops_recursion_spec_fixtures_v0/out/summary.json
```

All within the C1-A authorized write scope. No `source/**`, `docs/spec/**`,
`docs/proposals/**`, `language-covenant.md`, `lib/**`, `bin/igc`, gemspec,
README, public docs, RuntimeSmoke, CompilerResult, CompilationReport, or
`playgrounds/**` file was touched.

**Risk level: none.**

---

### 2. Fixtures remain proof-local and outside `source/**`?

**Yes — clean.**

All fixtures are under
`experiments/experimental_loops_recursion_spec_fixtures_v0/fixtures/`. No file
under `source/**` was created or changed. The manifest correctly lists
`source/loops_and_recursion.ig` as a `read_only_pressure_inputs` entry, not a
source-of-truth entry.

**Risk level: none.**

---

### 3. Fixtures are evidence only, not implementation?

**Yes, at the governance level — three semantic fidelity issues found inside
fixture content.**

The structural controls are correct: all fixture files carry provenance headers
(evidence class, authority boundary), the manifest declares all claims as
`not_claimed`, the summary JSON carries a full `non_claims` block, and no
`.igapp`, `.igbin`, compiler passport, or RuntimeSmoke artifacts were generated.

However, reading the fixture source reveals three precision issues that affect
the design signal each fixture sends to future PROP-039+ and PROP-037 companion
authoring. They are documented in detail in items 4–6 below.

---

### 4. Bounded local loops and recursion remain Ch13 / PROP-039+ input?

**Mostly — one grammar-class confusion in `recursion_decreases_fuel.ig`.**

`bounded_local_collection_loop.ig` maps correctly to Ch13 / future PROP-039+
input. `recursion_decreases_fuel.ig` also maps correctly. Both headers and
manifest entries are precise.

**Semantic fidelity issue — `recursive contract` keyword mixed with
`decreases fuel max_steps`:**

`recursion_decreases_fuel.ig` writes:

```igniter
recursive contract FactorialFuel(n: Integer, acc: Integer) -> result: Integer
  decreases fuel
  max_steps 100
```

Chapter 13 distinguishes:

- `recursive contract` → `StructuralRecursion`: the `decreases` expression is a
  structural variant (e.g. `items.remaining`); the compiler verifies it
  decreases at every `recur()` site.
- `fuel_bounded contract` → `FuelBoundedRecursion`: `max_steps` is a static
  literal step budget; `decreases fuel` refers to the fuel counter.

The fixture uses the `recursive contract` keyword (structural class keyword) with
`decreases fuel` and `max_steps 100` (fuel-bounded class modifiers). This
conflates two Ch13 loop classes. `fuel` in `decreases fuel` is not a named
structural variant — it is the implicit step counter in `FuelBoundedRecursion`.
Using `recursive contract` here blurs the grammar boundary that PROP-039+
authoring must eventually settle.

**C4-A should record:**

```text
recursion_decreases_fuel.ig blends the structural recursion keyword (recursive
contract) with fuel-bounded modifiers (decreases fuel, max_steps). Ch13
separates these into StructuralRecursion (recursive contract / decreases
<variant>) and FuelBoundedRecursion (fuel_bounded contract / max_steps N).
The fixture signals Ch13/PROP-039+ territory correctly, but its grammar implies
a combined form that Ch13 does not define. PROP-039+ authoring must resolve
whether these are separate keywords or a unified form.
```

**Risk level: low — fixture authority is correct (Ch13/PROP-039+); grammar
precision needs explicit note for PROP-039+ authoring.**

---

### 5. Service-loop fixture remains PROP-037 progression input?

**Mostly — `tick.event_id` accessor goes beyond authorized `tick.time` binding.**

`service_loop_clock_tick_time.ig` correctly maps to PROP-037 progression
descriptor input. The service loop header, `clock.every`, heartbeat/checkpoint/
cancellation/max_step_latency obligations, and `tick.time` binding are all
within accepted R247 wording.

**Semantic fidelity issue — `tick.event_id` is not in the authorized surface:**

The fixture contains:

```igniter
compute event_identity = tick.event_id
```

R246/R247 authorized `tick.time` as explicit event-time binding from a
materialized progression event. PROP-037 defines `ProgressionEvent` with an
`event_id` field, but it does not specify what source-level accessor syntax a
`tick` binding exposes. The authorized wording does not include `tick.event_id`
as a named source-level accessor.

Using `tick.event_id` in a fixture introduces an implicit proposal: that the
`tick` value is a structured object with at least `.time` and `.event_id` as
named accessors. This is future PROP-037 companion / PROP-039+ territory, not
the accepted `tick.time`-only binding from R247.

If C4-A accepts this fixture without qualification, `tick.event_id` could be
misread as accepted source-level spec input.

**C4-A should record:**

```text
service_loop_clock_tick_time.ig introduces tick.event_id as a source-level
accessor. This goes beyond the R247-accepted tick.time binding. tick.event_id
is not in the accepted PROP-037 wording or R247 wording sync. It must be treated
as unaccepted fixture pressure only. The authorized source-level binding for
R248 is tick.time. Future PROP-037 companion or PROP-039+ authoring must decide
whether tick exposes a structured accessor object and what fields it carries.
```

**Risk level: low — no scope violation; the accessor is inside the experiment
boundary. Risk is that future authoring misreads it as accepted input.**

---

### 6. `tick.time` and `now()` wording aligned with R247?

**Yes for `now()`. Mostly for `tick.time` (affected by issue in §5 above).**

`source_level_now_prohibited.ig` correctly anchors `now()` refusal to Ch8
`OOF-L6` and explicitly says "This fixture does not mint a new OOF registry
code." This is precisely aligned with R247's OOF reconciliation outcome.

`tick.time` appears correctly in `service_loop_clock_tick_time.ig` as:

```igniter
compute explicit_as_of = tick.time
```

This is explicitly labeled as event-time binding, consistent with R247.

The `tick.event_id` accessor issue (§5 above) is the only `tick`-surface
precision concern. The `tick.time` usage itself is correctly aligned.

**Risk level: none for `now()`; low for `tick.time` (shadowed by `tick.event_id`
issue above).**

---

### 7. Grammar form of bounded local loop uses `for` keyword, not `loop`?

**Caution — `for ... max_steps: <expr>` conflates two loop class keywords.**

`bounded_local_collection_loop.ig` writes:

```igniter
for ClaimLoop claim in claims max_steps: claims.count {
```

The accepted pressure from R246 and the canonical source fixture
(`source/loops_and_recursion.ig`) use the `loop Name in collection max_steps: N`
form. Chapter 13 uses `for item in claims {}` for `FiniteLoop` (terminates by
collection exhaustion, no `max_steps`), and `loop article in live_news max_steps:
100` for the service-loop body (inside a `service contract`).

Two distinct precision issues:

(a) **`for` vs `loop` keyword**: `for` appears in Ch13 as the finite collection
iteration keyword; `loop` appears as the managed/service loop keyword with
`max_steps`. Using `for` with `max_steps` creates an ambiguous form not
explicitly in Ch13.

(b) **`max_steps: claims.count`** (dynamic expression) vs `max_steps: 100`
(static literal): Ch13 and R246 accepted pressure use a static literal. A
dynamic `max_steps: <expr>` expands the design surface without explicit
authorization.

Neither issue is a scope violation — the fixture is design pressure only. But
both could mislead PROP-039+ grammar authoring.

**C4-A should record:**

```text
bounded_local_collection_loop.ig uses for ... max_steps: claims.count. This
creates a grammar ambiguity: Ch13 uses for for FiniteLoop (no max_steps) and
loop for managed/service loop bodies (with max_steps as a static literal).
The fixture also uses a dynamic expression (claims.count) where accepted
pressure used a static literal (N). PROP-039+ authoring must resolve whether:
(a) for accepts max_steps, or whether max_steps is reserved for loop forms
    only;
(b) max_steps accepts dynamic expressions, or is a static-only literal.
This note does not block fixture acceptance but is a required design signal for
the PROP-039+ authoring route.
```

**Risk level: low — fixture intent (Ch13/PROP-039+ territory, not `fold_stream`)
is clear; grammar precision is a deferred PROP-039+ authoring question.**

---

### 8. OOF-L / OOF-R remains wording/pressure, not registry authority?

**Yes — clean.**

All fixtures use OOF references only in comments and provenance notes, not in
body claims. `source_level_now_prohibited.ig` anchors to `OOF-L6` as a wording
reference and explicitly says `registry_authority: not_claimed`. The manifest
carries the same. No fixture body promotes any OOF code to registry status.

`unnamed_loop_robustness.ig` captures Postulate 28 pressure without claiming
OOF-L3 enforcement is implemented. This is exactly right.

**Risk level: none.**

---

### 9. Lab behavior remains frontier evidence only?

**Yes — clean.**

The track doc states: "This proof packet does not accept the lab's suggested
draft implementation order as canon." The manifest lists the lab pressure package
docs as `read_only_pressure_inputs`, not `source_of_truth`. The summary JSON
confirms LRF-12 PASS with "Lab behavior is cited as frontier evidence only."

**Risk level: none.**

---

### 10. Forbidden claims remain closed?

**Yes — clean.**

The manifest's `generated_artifacts` block confirms: `"igapp": false`, `"igbin":
false`, `"compiler_passport": false`, `"runtime_smoke": false`.

The summary JSON's `non_claims` block carries `not_claimed` for: implementation,
parser, typechecker, runtime, public runtime, reference runtime, stable API,
production, Spark, release, performance, official reference status, alternative
certification, portability, and lab behavior as canon.

The C2-I track doc boundary statement covers all forbidden claims as explicitly
unclaimed.

**Risk level: none.**

---

### 11. `break_deferred_unsupported.ig` — deferred fixture or premature syntax?

**Acceptable — minor disambiguation convention note.**

The fixture contains actual `break` syntax inside a loop body:

```igniter
for BreakDeferredLoop claim in claims max_steps: claims.count {
  break
}
```

This is a deferred-pressure fixture showing what `break` might look like, not a
claim that `break` is supported. The provenance header is unambiguous: "Source-
level break remains deferred by R247/R248. This fixture does not claim parser,
TypeChecker, or runtime behavior."

The risk is that a `.ig` file containing `break` could be misread by future
tooling or review as a syntax fixture for a supported construct. The
conventional practice for unsupported syntax pressure is to use a comment or
string literal instead of live syntax.

This does not block acceptance. C4-A may add a convention note for future
deferred-pressure fixtures if it chooses.

**Risk level: informational.**

---

## LRF Matrix Self-Assessment Verification

| Check | C2-I claim | This review finding |
| --- | --- | --- |
| LRF-1 | PASS | Confirmed — authorized files only |
| LRF-2 | PASS | Confirmed — no `source/**` |
| LRF-3 | PASS | Confirmed with grammar note (§7) |
| LRF-4 | PASS | Confirmed with class-conflation note (§4) |
| LRF-5 | PASS | Confirmed — maps to PROP-037 progression input |
| LRF-6 | PASS | Confirmed — `tick.time` is explicit event-time binding |
| LRF-7 | PASS | Confirmed — anchored to Ch8 `OOF-L6` |
| LRF-8 | PASS | Confirmed — `clock.every` is not `Stream[DateTime]` |
| LRF-9 | PASS | Confirmed — Postulate 28 as future pressure only |
| LRF-10 | PASS | Confirmed — `break` deferred |
| LRF-11 | PASS | Confirmed — no OOF registry promotion |
| LRF-12 | PASS | Confirmed — lab as frontier evidence |
| LRF-13 | PASS | Confirmed — no closed files changed |
| LRF-14 | PASS | Confirmed — no `igc run`, `.igbin`, `.igapp`, passport, RuntimeSmoke |
| LRF-15 | PASS | Confirmed — forbidden wording in negative/non-claim context only |
| LRF-16 | PASS | Confirmed — summary packet is comprehensive |

Self-assessment is accurate. The three semantic fidelity items (§4, §5, §7) are
genuine design-signal concerns inside otherwise correctly labeled evidence
fixtures — they are not LRF matrix failures.

---

## Claim-Risk Summary

| Risk | Severity | Status |
| --- | --- | --- |
| C2-I scope violation (unauthorized files) | None found | Clean |
| Fixture placed under `source/**` | None found | Clean |
| Forbidden claims (implementation, runtime, public, etc.) | None found | Clean |
| Lab-to-canon leakage | None found | Clean |
| `tick.event_id` beyond authorized `tick.time` binding | Low | C4-A record required |
| `recursive contract` + `decreases fuel max_steps` blurs StructuralRecursion / FuelBoundedRecursion | Low | C4-A record required |
| `for ... max_steps: <expr>` — keyword/static ambiguity | Low | C4-A record required |
| `break_deferred_unsupported.ig` contains live `break` syntax | Informational | Convention note; does not block acceptance |
| OOF registry authority over-claimed | None found | Clean |
| Postulate 28 enforcement over-claimed | None found | Clean |
| `igc run`, `.igbin`, `.igapp`, compiler passport, RuntimeSmoke | None found | Clean |
| Stable API, production, Spark, release, performance, certification, portability | None found | Clean |

---

## Exact C4-A Recommendation

**CONDITIONAL ACCEPT** with three required record items.

### Required C4-A record items

**1. `tick.event_id` is not accepted spec input.**

Record:

```text
service_loop_clock_tick_time.ig introduces tick.event_id as a source-level
accessor. This is beyond the R247-accepted tick.time binding and is not in
PROP-037 or the R247 wording sync. tick.event_id must be treated as fixture
pressure only — it is not accepted source-level spec input for R248. Future
PROP-037 companion or PROP-039+ authoring must decide the tick accessor
object surface.
```

**2. `recursion_decreases_fuel.ig` grammar ambiguity must be flagged for
PROP-039+ authoring.**

Record:

```text
recursion_decreases_fuel.ig uses recursive contract ... decreases fuel
max_steps 100. Ch13 separates StructuralRecursion (recursive contract,
decreases <variant>) from FuelBoundedRecursion (fuel_bounded contract,
max_steps N). The fixture conflates these. PROP-039+ authoring must resolve
whether decreases fuel in a recursive contract form is a unified class or a
mistake. The fixture intent (Ch13/PROP-039+ territory) is correct; the grammar
signal is ambiguous.
```

**3. `bounded_local_collection_loop.ig` grammar note for PROP-039+ authoring.**

Record:

```text
bounded_local_collection_loop.ig uses for ... max_steps: claims.count. This
conflates the Ch13 FiniteLoop for keyword (collection exhaustion, no max_steps)
with managed loop max_steps semantics, and uses a dynamic expression
(claims.count) where accepted pressure used a static literal (N). PROP-039+
authoring must resolve whether for accepts max_steps and whether max_steps
accepts dynamic expressions.
```

### Accept / open

With the three items recorded, C4-A should accept the proof-local fixture packet
as bounded specification evidence. The packet correctly:

- stays inside authorized write scope;
- places all fixtures under the experiment directory;
- labels all output as evidence-only;
- carries a machine-readable summary with all non-claims explicit;
- generates no `.igapp`, `.igbin`, compiler passport, or RuntimeSmoke;
- anchors `now()` to Ch8 `OOF-L6` without minting a new registry code;
- anchors `tick.time` as explicit event-time binding;
- defers `break`;
- keeps lab behavior as frontier evidence only;
- keeps all forbidden claims closed.

Recommended next route after C4-A acceptance:

```text
PROP-039+ authoring / design route, using:
- the fixture packet as design-input evidence;
- the three C4-A record items as explicit authoring blockers to resolve;
- Ch13 as the prior vocabulary draft (with known stale areas);
- PROP-037 and its R247/R248 companion wording as the service-loop boundary.
```

This route must still keep closed: implementation authorization, `igc run`
widening, `.igbin` execution, compiler passport emission, RuntimeSmoke
productization, public runtime support, Reference Runtime support, stable API,
production, Spark, release, public performance, official/reference status,
alternative certification, and portability claims.

---

[Agree]
- Write scope is clean.
- Manifest and summary JSON are well-structured and comprehensive.
- `now()` fixture correctly anchors to Ch8 OOF-L6 without registry over-claim.
- `break` deferred correctly.
- Lab evidence is correctly treated as pressure input only.
- All forbidden claims closed.

[Challenge]
- `tick.event_id` in the service-loop fixture is the sharpest precision issue.
  It introduces an unaccepted object accessor that implies a richer `tick` API
  surface than what R247 authorized.
- `recursive contract ... decreases fuel max_steps` conflates two Ch13 loop
  classes. This is the most likely source of PROP-039+ grammar confusion if
  the fixture is used as a template.

[Missing]
- A convention for negative/deferred-pressure fixtures (like `break_deferred`).
  Using live syntax inside a `.ig` file for an unsupported feature is technically
  correct for design pressure, but a future disambiguation convention would
  prevent tooling or review confusion.

[Sharper Questions for C4-A]
- Does accepting `tick.event_id` as fixture content (not spec input) require an
  explicit C4-A non-acceptance statement, or is the track doc's "authority:
  PROP-037 progression descriptor input only" label sufficient?
- For PROP-039+ authoring: should `recursive contract` and `fuel_bounded
  contract` be explicitly separated in the PROP-039+ proposal surface, or
  should `decreases fuel` be a modifier that works for both?

[Route]
- CONDITIONAL ACCEPT → C4-A with three required record items.
- Next: PROP-039+ authoring / design route, scoped against the fixture packet.
