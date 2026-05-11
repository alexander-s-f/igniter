# Spec Extension Gap Analysis

Status: reference · S3-R28
Date: 2026-05-10 (updated 2026-05-11 by S3-R34-C3-S governance sync)
Author: `[Igniter-Lang Meta Expert]`
Governance: META-EXPERT-013

This document records the delta between igniter-lang v0.1.0.pre.stage2
(Stage 1–2 closed) and the extended specification (ch10–ch13, proposed).

Source: external pressure review using three hypothetical application programs.
See `experiments/external_pressure_specimens/` for the programs.

---

## What Aligns (no gap)

| Construct | impl | spec |
|-----------|------|------|
| `contract { input, compute, output }` | ✅ parser.rb | ✅ ch2 |
| `type T { field: Type? }` | ✅ | ✅ ch3 |
| `History[T]`, `BiHistory[T]`, `Option[T]`, `Stream[T]` | ✅ ch9 | ✅ ch3 |
| `history_at(ref, as_of)`, `bihistory_at(ref, vt, tt)` | ✅ | ✅ ch9 |
| `invariant name: cond severity :level` | ✅ | ✅ ch9 |
| `module`, `import` | ✅ | ✅ ch2 |
| `escape capability` | ✅ | partial — spec uses different surface |
| `Decimal[N]`, `OLAPPoint[T, Dims]` | ✅ Stage 2 | not yet in ch10+ |
| `pipeline { step }`, `fold_stream @window_bounded` | ✅ Stage 2 | not yet in ch10+ |

---

## Gap-A: Contract Modifiers — CRITICAL

**Missing from impl:** optional modifier prefix before `contract`.

```igniter
pure         contract ScoreRisk(...)
observed     contract ExtractClaims(...)
effect       contract ChargeCustomer(...)
privileged   contract UnlockDoor(...)
irreversible contract DispatchEmergency(...)
```

**Impl change:** parser + classifier + typechecker + SemanticIR (≈50 lines).
**Backward compatible:** `contract Foo {}` = implicit `pure`. No existing programs break.
**Proposal:** PROP-031 (authored, awaiting regression proof).
**Spec:** ch10.

---

## Gap-B: `via profile` Binding — HIGH

**Missing from impl:** optional `via profile_name` clause on contract declaration.

```igniter
effect contract ChargeCustomer(...) via audited_billing { ... }
```

**Impl change:** parser + TypeChecker scope resolution + SemanticIR.
**Backward compatible:** `via` is optional.
**Proposal:** PROP-033 (not yet authored, gated on PROP-031).
**Spec:** ch11.

---

## Gap-C: Profile Declarations — HIGH

**Missing from impl:** `profile` as a top-level declaration with property enforcement.

```igniter
profile audited_billing {
  time: explicit
  lifecycle: :audit
  backend: :ledger
  evidence: required
  allowed_effects: [payment_gateway.charge]
}
```

**Impl change:** new top-level declaration + new compiler pass.
**Proposal:** PROP-035 (not yet authored, gated on PROP-031 + PROP-033).
**Spec:** ch11.

---

## Gap-D: Effect Surface — HIGH

**Missing from impl:** 7-field Effect Surface for effect/privileged/irreversible contracts.

```igniter
effect contract ChargeCustomer(...)
  affects  external PaymentGateway.ChargeEndpoint
  authority billing_operator
  reversibility :compensatable
  idempotency key content_hash(customer_id, amount, currency)
  receipt  ChargeReceipt
  failure  PaymentFailure
  compensation RefundCustomer
```

**Impl change:** parser (7 new clauses) + TypeChecker validation + SemanticIR.
**Proposal:** TBD — Effect Surface remains queued but unnumbered after S3-R33-C3-A.
**Spec:** ch12.

---

## Gap-E: `output ... evidence [refs]` — MEDIUM

**Missing from impl:** evidence provenance clause on output declarations.

```igniter
output claims evidence [article, model_observation]
```

**Impl change:** parser (optional clause) + SemanticIR (evidence_refs field).
**Backward compatible:** clause is optional.
**Proposal:** PROP-034 (not yet authored, gated on PROP-031, PROP-032).
**Spec:** ch10 §10.5 (field in contract_ir).

---

## Gap-F: Service Loops and Managed Recursion — HIGH / Stage 3 Language Lane

**Missing from impl:** `service contract` form, `loop item in stream`, `loop tick in clock.every(N.ms)`, `write store <- value evidence [refs]`.

```igniter
service contract TsunamiResponseService()
  heartbeat every 2.seconds
  checkpoint every 30.seconds
  cancellation required
  max_step_latency 500.ms
  via emergency_rescue_mesh
{
  loop tick in clock.every(5.seconds)
    max_steps 1_000_000
    on_exhaustion :suspend
  {
    as_of = tick.time                        -- tick binding, not now()
    signals = CollectSignals(as_of)
    proposal = ProposeRescueAllocation(signals, drones, crews, as_of)
    when proposal.requires_human_review =>
      effect NotifyCommander(proposal)
  }
}
```

**Key semantic:** `service` is a lifecycle/loop class, orthogonal to the effect
modifier axis. A service contract may contain effect calls in its body; its own
modifier class is `service`, not `effect`.

```
effect axis:  pure | observed | effect | privileged | irreversible
loop axis:    service | recursive                        (orthogonal)
```

**Impl change:** new loop class, new runtime semantics, new executor obligations.
**Proposal:** PROP-037+ placeholder only. PROP-036 is occupied by
`compiler_profile_id` manifest identity (S3-R33-C3-A numbering-only decision).
Managed recursion / service loops remain unassigned future work until a formal
Architect/Compiler-Expert routing decision.
**Spec:** ch13.
**Open:** see CL-4 (now() vs tick binding inside loop body).

---

## Gap-H: `assumptions {}` Block — HIGH / Stage 3 Language Lane candidate

**Source:** `social_simulation.ig` pressure specimen + interview-agent-D-2.md

**Missing from impl and proposed spec:** `assumptions {}` as a top-level language
construct. Currently used in specimen but has no grammar, no AST node, no semantics.

```igniter
assumptions {
  assumption homophily {
    kind :synthetic
    statement "People with similar beliefs interact more often."
    strength 0.70
    evidence_note "Synthetic assumption for experiment, not a claim about reality."
  }

  assumption group_pressure {
    kind :synthetic
    statement "A group slowly pulls member beliefs toward its dominant norm."
    strength 0.45
  }
}
```

**Nature:** Epistemic primitive — sibling of `profile`, `receipt`, `type`, not plain
data. An assumption is:

```
Assumption = named premise + optional parameter + audit dependency
```

Three distinct representations:
- `AssumptionRef` — compile-time reference (how it appears in `evidence [...]`)
- `AssumptionRecord` — DTO snapshot (how it enters receipts)
- `AssumptionSet` — module-level collection with stable hash for replay

**Why core (not library):**
1. Assumptions influence audit lineage
2. Must be carried through receipts
3. Must be replayable: `same code + same inputs + same assumption_hash = reproducible`
4. Compiler must see dependency: `SimulateInteraction depends_on assumption homophily`
5. Profile can enforce `hidden_assumptions: forbidden`

**Key operations declared by this construct:**
- `homophily.strength` — assumption field access inside contracts (typed, not a hidden global)
- `evidence [homophily]` — include in output evidence chain
- `current_assumptions()` — stdlib call producing current `AssumptionSet`
- `assumption_hash()` — stable hash of the set for receipts

**Impl change:** new top-level grammar production + new compiler pass (AssumptionRegistry).
**Backward compatible:** additive. Existing programs unaffected.
**Proposal:** PROP-032 (authored; Phase 1 Classifier landed; TypeChecker/SemanticIR
and full experiment-pass remain open)
**Spec:** TBD (ch10 extension or new ch?)

---

## Gap-I: `form` Keyword — MEDIUM / Stage 3 Language Lane candidate

**Source:** `social_simulation.ig` analysis — `population "Small Town Pilot" { }` has
no declared type, no grammar anchor, no formal semantics.

**Problem:** Domain-specific named struct literals appear as top-level module declarations
but have no core primitive to back them. `population`, `groups`, `scenario`, `placement`
all need the same pattern: a named constructor alias over a declared type.

**Solution:** `form` as a core primitive — a named constructor alias:

```igniter
-- Library or module defines the type:
type PopulationSpec {
  name: String
  people: Int
  age_distribution: Map[Range[Int], Decimal]
  traits: Map[Symbol, TraitDistribution]
  beliefs: Map[Symbol, BeliefDistribution]
  epistemic_kind: Symbol
}

-- Module registers the constructor alias:
form population -> PopulationSpec
```

After that declaration, the user writes:

```igniter
population "Small Town Pilot" {
  people 500
  age_distribution { 18..30 => 0.25, 31..50 => 0.45, 51..80 => 0.30 }
  epistemic_kind :synthetic
}
```

Which is sugar for a module-level named constant of type `PopulationSpec`:

```igniter
const small_town_pilot: PopulationSpec = PopulationSpec {
  name: "Small Town Pilot"
  people: 500
  ...
}
```

**Why this matters:**
- `form` is core; `population`, `appointment`, `part`, `vehicle` are user-defined — nothing
  domain-specific enters the core grammar
- The contract always types its input as `PopulationSpec`, not `population`
- The named artifact gets a content hash, enters lineage, appears in receipts — just like
  any other typed module-level constant

**Answers the question "what type/contract accepts this as input?":**

```igniter
-- Contracts use the type, not the form name:
pure contract GenerateInitialSociety(pop: PopulationSpec, as_of: Timestamp)
  -> state: SocietyState
```

**Impl change:** new top-level grammar production `form-decl`; name registered in module
namespace; no new runtime semantics (compiles to typed constant).
**Backward compatible:** additive.
**Proposal:** TBD (can parallel PROP-034 or follow it)
**Spec:** TBD

---

## Gap-G: Additional Constructs (not yet in proposals)

| Construct | Example | Notes |
|-----------|---------|-------|
| `view V: T { from store, columns [...] }` | `view clarity_dashboard: ClarityReport { ... }` | Read-only projection layer; ch? |
| `placement P { mode, stages { X on :node } }` | `placement realtime_video_cluster { ... }` | Deployment topology; ch? |

---

## Gap-J: `constraints {}` Block — HIGH / Stage 3 Language Lane candidate

**Source:** `rescue_coordination.ig` + `logistics_strategy.ig` specimens (interview-agent-D-3.md).
**Cross-review:** Agent-D confirmed and refined — gap is real and named correctly.

**Missing from impl and spec:** `constraints {}` as a top-level language construct,
parallel to `assumptions {}` but normative rather than epistemic.

```igniter
constraints {
  constraint avoid_total_abandonment {
    kind :ethical
    priority 0.95
    statement "No settlement may be completely ignored."
  }

  constraint budget_limit {
    kind :resource
    priority 1.0
    statement "Do not allocate more crews than available."
  }

  constraint legal_boundary {
    kind :legal
    priority 1.0
    statement "Do not enter restricted zone without authorization."
  }
}
```

**Semantic distinction from `assumptions {}`:**

```
assumption = epistemic premise (what we believe/model)
constraint = normative/operational boundary (what we must respect)
risk       = what may go wrong                    (future Gap)
objective  = what we optimize                     (future Gap)
```

**Why `constraints {}` not `ethical_constraints {}`:**
Agent-D correctly identified that splitting by constraint kind (ethical, resource,
legal, safety) would produce proliferating top-level blocks. One primitive with
typed `kind` is cleaner.

**Key properties:**
- Constraints are compile-known context (not runtime config)
- Contracts that use constraints must declare this explicitly (see CL-5)
- Constraints enter receipts via `constraint_hash` (analogous to `assumption_hash`)
- Profile can enforce `hidden_constraints: :forbidden`
- Constraint violation in output: compiler can warn if `invariant` cross-references
  a declared constraint that is known to be violated

**Impl change:** new top-level grammar production + AssumptionRegistry sibling
(ConstraintRegistry). New compiler pass.
**Backward compatible:** additive.
**Proposal:** TBD (candidate after PROP-033, parallel to Gap-H)
**Spec:** TBD
**Open:** exact relationship between `constraints {}` and invariants (are invariants
a runtime enforcement of constraints?). Needs analysis.

---

## Gap-K: `observes` Clause on Contracts — MEDIUM / Stage 3

**Source:** `rescue_coordination.ig` + `logistics_strategy.ig` (interview-agent-D-3.md).
**Promoted from:** Gap-G (was a one-line note).

**Missing from impl:** the `observes` clause refines `observed contract` by naming
the specific external source being observed:

```igniter
observed contract CollectSignals(as_of: Timestamp)
  observes drone SwarmSensorMesh

observed contract ReadCurrentResources(as_of: Timestamp)
  observes external ERP

observed contract ForecastDemand(as_of: Timestamp)
  observes model DemandModel

observed contract ReadTemperatureHistory(as_of: Timestamp)
  observes sensor CameraNetworkMesh

observed contract ReadOperatorDecision(as_of: Timestamp)
  observes human OperatorInput

observed contract ReadClock(as_of: Timestamp)
  observes clock SystemClock
```

**Distinction from `escape` capability:**
- `escape capability_name` declares a named escape CAPABILITY (reusable handle)
- `observes KIND Source` declares the observation TARGET (specific external system)
- Both are compatible: a contract can have `escape history_read` AND `observes external ERP`

**`observes` source kinds (proposed):**
| Kind | Description |
|------|-------------|
| `external NAME` | External API/system |
| `model NAME` | ML/statistical model output |
| `sensor NAME` | Physical sensor network |
| `drone/robot NAME` | Autonomous agent mesh |
| `human NAME` | Human input surface |
| `clock NAME` | Time source |

**Why this matters:** `observes` enters the observation closure in `.ifh`/`.ilk`
artifact manifests. Audit tooling can ask "which contracts observe model DemandModel?"

**Impl change:** parser (new optional clause on `observed contract` declaration) +
SemanticIR field + linker manifest.
**Proposal:** extends PROP-035 (Effect Surface) or PROP-031 addendum.
**Open:** whether `observes` is required on all `observed` contracts or optional.

---

## Gap-N: `audit contract` / PostAudit Pattern — HIGH / Stage 3

**Source:** `logistics_strategy.ig` (interview-agent-D-3.md): `RunPostAudit`,
`CompareExpectedToActual`, `StrategyPostAuditReceipt`.

**Missing from impl and spec:** a structured pattern for comparing a prior decision
receipt against actual observed outcomes, producing an audit receipt.

**What it does:**
```
takes: prior decision receipt (from the moment of choice)
takes: later observations (actual outcomes)
produces: audit receipt (expected vs actual delta)
updates: trust/calibration signals (future)
```

**Two possible positions:**

Position A — stdlib contract pattern (Agent-D's conservative recommendation):
```igniter
contract RunPostAudit(decision_receipt: StrategyDecisionReceipt, as_of: Timestamp)
  conforms PostAudit[StrategyDecisionReceipt, ActualOutcome]
  -> audit: StrategyPostAuditReceipt
```

Position B — new top-level contract class (keyword):
```igniter
audit contract AuditStrategyDecision(
  decision_receipt: StrategyDecisionReceipt,
  as_of: Timestamp
) -> audit: StrategyPostAuditReceipt
```

**Why it matters:** Audit is not just "another contract". It closes the feedback
loop — Postulate 26 (Audit Completes the Decision). Language support (even stdlib)
makes it a canonical operation, not an afterthought.

**Impl change:** if stdlib pattern: no grammar change needed; `PostAudit[D, A]`
type interface in stdlib. If keyword: new contract class, new modifier.
**Proposal:** TBD (depends on Gap-H landing first — assumptions enter audit receipts)
**Open (decision needed):** keyword vs stdlib pattern. Agent-D recommends
starting with stdlib to avoid premature keyword proliferation. **Leaning: stdlib
first, promote to keyword if specimens consistently need it.**

---

## Gap-O: `workflow` / Orchestration Contract — HIGH / Stage 3

**Source:** `logistics_strategy.ig` (interview-agent-D-3.md): `BuildStrategyDecision`
orchestrates `ReadCurrentResources` + `ForecastDemand` + `ChooseStrategy` without
being itself observed/effect/pure in a clean sense.

**Missing from impl:** a modifier class for contracts whose role is to compose
other contracts — not to compute directly, not to observe, not to act, but to
build the dependency graph across contract calls.

```igniter
workflow contract BuildStrategyDecision(as_of: Timestamp)
  -> receipt: StrategyDecisionReceipt
  via audited_strategy_mesh
{
  resources = ReadCurrentResources(as_of)    -- observed sub-call
  forecasts = ForecastDemand(as_of)          -- observed sub-call
  options = GenerateStrategyOptions(...)     -- pure sub-call
  decision = ChooseStrategy(options, as_of)  -- pure sub-call
  ...
}
```

**Semantic properties:**
```
workflow contract composes contracts but does not itself directly touch external world.
Its effect class is the closure of called contracts.
It may produce decision receipts.
It is NOT pure (calls observed sub-contracts).
It is NOT observed (does not directly observe external systems).
It is NOT effect (does not directly change the world).
```

**Fragment class proposal:** `workflow` (new class) — or use `orchestrates`.

**Why this matters:**
1. Currently such contracts default to implicit `pure` and hit OOF-M1 if they
   call observed sub-contracts. This is wrong.
2. The orchestration layer has distinct audit semantics: it tracks the call graph
   of sub-contracts, not just its own computation.
3. Workflow receipts are composition receipts — they aggregate sub-contract receipts.

**Agent-D's naming proposals:** `workflow contract` or `orchestrates contract`.
**Meta Expert preference:** `workflow contract` — shorter, familiar from other domains.

**Impl change:** new modifier, new fragment class in classifier, new SemanticIR
node type for composition receipts.
**Proposal:** TBD (gated on PROP-031 stabilizing modifier axis)
**Open (significant):** this is the most contested new gap. Questions:
- Is `workflow` truly orthogonal to effect axis, or is it a subtype?
- Can a workflow contract be `privileged workflow contract` (privileged orchestration)?
- Does workflow fragment class propagate through the evidence chain correctly?
- Is this Stage 3 or Stage 4? **Currently unresolved.**

---

## Impl-Ahead (in impl, not yet in spec ch10+)

These features are implemented but not described in proposed chapters. They remain
valid and are not affected by the extension.

| Feature | Status |
|---------|--------|
| `olap_point { dimensions, measure }` | ✅ Stage 2, ch9 |
| `pipeline { step }` | ✅ Stage 1, ch5 |
| `fold_stream @window_bounded / @count_bounded(n)` | ✅ Stage 2, ch9 |
| `window { kind, size, on_close }` | ✅ Stage 2, ch9 |
| `trait`, `impl` | ✅ Stage 1, ch3 |

---

## Priority Ordering

| Priority | PROP | Gap | Stage | Status |
|----------|------|-----|-------|--------|
| 1 | PROP-031 | Gap-A (modifiers) | 3 Language Lane | ✅ DONE |
| 2 | PROP-032 | Gap-H (assumptions block) | 3 Language Lane | proposal; Phase 1 Classifier landed |
| 3 | PROP-033 | Gap-B (via profile) | 3 Language Lane | pending |
| 4 | PROP-034 | Gap-E (evidence) | 3 Language Lane | pending |
| 5 | PROP-035 | Gap-C (profile system / authority resolution) | 3 new Lane | pending |
| 6 | TBD | Gap-D (effect surface) | 3 new Lane | queued, unnumbered |
| 7 | TBD | Gap-J (constraints block) | 3 Language Lane candidate | pending |
| 8 | TBD | Gap-I (form keyword) | 3 Language Lane candidate | pending |
| 9 | TBD | Gap-O (workflow contract) | 3–4 — OPEN | open |
| 10 | TBD | Gap-N (audit contract/pattern) | 3 — stdlib first | pending |
| 11 | TBD / Effect Surface extension | Gap-K (observes clause) | 3 | pending |
| 12 | PROP-037+ placeholder | Gap-F (service loops) | 3 Language Lane candidate | placeholder only; no PROP assigned |
| — | TBD | Gap-G (view, placement) | 4+ | future |

---

## Clarifications (S3-R27)

Findings from `social_simulation.ig` pressure specimen (interview-agent-D-2.md).
These are not new gaps — they are architectural decisions that must be settled
before downstream PROPs land.

### CL-1: `recursive` is not an effect modifier

**Problem:** The specimen uses `recursive contract RunSimulation` with `decreases`
and `max_depth`. This places `recursive` in the same syntactic position as
`pure | observed | effect | privileged | irreversible`.

**Decision:** These two axes are orthogonal and must not share the same position:

```
Effect axis:  pure | observed | effect | privileged | irreversible  (PROP-031)
Loop axis:    recursive | service                                   (ch13, Stage 4)
```

A contract can be both `pure` and `recursive` simultaneously:

```igniter
pure recursive contract Fibonacci(n: Int, fuel: Int) decreases fuel -> result: Int
```

**Action:** Add grammar note to PROP-031 §11 forbidding `recursive` as modifier.
`recursive` and `service` are reserved for ch13 syntax, orthogonal to effect axis.

---

### CL-2: Profile field values — `:symbol` is canonical

**Problem:** The specimen mixes two forms:

```igniter
time: explicit    -- bare identifier  ← ambiguous: variable ref or enum literal?
lifecycle: :audit -- symbol literal   ← clear
```

**Decision:** All profile field values that are semantic categories (not strings,
not integers) must use `:symbol` form. Bare identifiers are not valid in profile
field position.

```igniter
-- Canonical (correct):
profile audited_social_simulation {
  time: :explicit
  lifecycle: :audit
  backend: :ledger
  honesty: :strict
}

-- Invalid:
profile p { time: explicit }  -- compile error: bare identifier in profile field
```

Profile field types are symbol unions:

```igniter
type TimeMode     = :explicit | :implicit | :realtime
type LifecycleMode = :audit   | :durable  | :ephemeral
type BackendMode  = :ledger   | :memory   | :network
```

**Action:** PROP-034 (Profile System) must specify profile field types as symbol
unions and enforce `:symbol` literal syntax. `time: explicit` is a grammar error.

---

### CL-4: `now()` inside `service contract` — tick binding required

**Source:** `rescue_coordination.ig` (interview-agent-D-3.md): `TsunamiResponseService`
calls `CollectSignals(now())` inside a managed loop body.

**Problem:** If `now()` is forbidden in `pure` (CL-3 / OOF-M1), what about inside
a `service contract` loop body? The loop has explicit temporal structure
(`clock.every(5.seconds)`), but `now()` still hides the actual time used.

**Decision (Agent-D + Meta Expert):** `now()` is forbidden everywhere, including
inside managed loop bodies. Time must come from the tick binding:

```igniter
-- Forbidden (even inside service contract):
loop tick in clock.every(5.seconds) {
  signals = CollectSignals(now())    -- hidden time source
}

-- Correct:
loop tick in clock.every(5.seconds) {
  as_of = tick.time                  -- tick is an observed event
  signals = CollectSignals(as_of)
}
```

**Rationale:** `tick.time` is an observable tick event — reproducible, logged,
auditable. `now()` is a global non-deterministic call — even inside a loop, it
couples the computation to wall-clock state.

> Clock is an observed input, not an ambient global.

**Action:** Add `now()` to OOF-M2 (forbidden everywhere, not just in `pure`)
or extend OOF-M1 to cover all contract forms. **Open: exact OOF code assignment.**
Document `tick.time` as the canonical temporal binding inside `service` loops.

---

### CL-5: `uses assumptions` / `uses constraints` — explicit context declaration

**Source:** `rescue_coordination.ig` + `logistics_strategy.ig` (interview-agent-D-3.md).
**Problem:** Specimens reference `assumptions` and `ethical_constraints` inside
contract bodies without declaring them as inputs. These are not global ambients.

**Problem example:**
```igniter
pure contract ProposeRescueAllocation(...)
{
  -- ethical_constraints referenced here but not declared as input
  decisions = ethical_allocation_solver(estimates, drones, crews, ethical_constraints)
  output decisions evidence [estimates, ethical_constraints, assumptions]
}
```

**Decision (Agent-D):** not "ambient reference" — better called **declared module
context**. Contracts must explicitly declare what context they consume:

```igniter
pure contract ProposeRescueAllocation(...)
  uses assumptions storm_response_premises
  uses constraints rescue_ethics
  -> decisions: Collection[RescuePriorityDecision]
{
  decisions = ethical_allocation_solver(
    estimates, drones, crews, current_constraints()
  )
  output decisions evidence [estimates, current_constraints(), current_assumptions()]
}
```

Or using set references:
```igniter
  uses assumption_set storm_response_premises
  uses constraint_set rescue_ethics
```

**Key rule:** assumptions and constraints must NOT "float up from the air". The
contract declares them, the compiler resolves them at the module level, and they
enter the compiled artifact's dependency graph.

**Action:** PROP for Gap-H (assumptions) must include `uses assumptions NAME` clause.
Gap-J (constraints) follows the same pattern.
**Open:** exact syntax of `uses` clause — `uses assumptions NAME` vs
`uses assumption_set NAME` vs simply listing in the contract header.

---

### CL-3: `now()` is forbidden in `pure` contracts

**Problem:** The specimen calls `now()` inside `RunSocialSimulation` which has no
modifier (implicit `pure`). `now()` is non-deterministic — a hidden temporal dependency.

**Decision:** `now()` in a `pure` or implicit-pure contract body is OOF-M1 violation.
Time must be an explicit input:

```igniter
-- Forbidden (OOF-M1):
pure contract Foo { ... produced_at: now() ... }

-- Correct:
pure contract Foo(as_of: Timestamp) { ... produced_at: as_of ... }
```

`now()` is only valid in `observed`, `effect`, `privileged`, or `irreversible` contracts,
or in the top-level orchestration call site.

**Action:** Already covered by OOF-M1 in PROP-031 §5. No new PROP needed.
Document as a specific instance: `now()` call = implicit escape dependency.
