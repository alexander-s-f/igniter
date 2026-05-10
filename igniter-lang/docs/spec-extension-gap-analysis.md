# Spec Extension Gap Analysis

Status: reference · S3-R27
Date: 2026-05-10 (updated 2026-05-10)
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
**Proposal:** PROP-032 (not yet authored, gated on PROP-031).
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
**Proposal:** PROP-034 (not yet authored, gated on PROP-031 + PROP-032).
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
**Proposal:** PROP-035 (not yet authored, gated on PROP-031).
**Spec:** ch12.

---

## Gap-E: `output ... evidence [refs]` — MEDIUM

**Missing from impl:** evidence provenance clause on output declarations.

```igniter
output claims evidence [article, model_observation]
```

**Impl change:** parser (optional clause) + SemanticIR (evidence_refs field).
**Backward compatible:** clause is optional.
**Proposal:** PROP-033 (not yet authored, gated on PROP-031).
**Spec:** ch10 §10.5 (field in contract_ir).

---

## Gap-F: Service Loops and Managed Recursion — MEDIUM / Stage 4

**Missing from impl:** `service contract` form, `loop item in stream`, `loop tick in clock.every(N.ms)`, `write store <- value evidence [refs]`.

```igniter
service contract Monitor(...)
  heartbeat every 10.seconds
  checkpoint every 1.minute
  cancellation required
  max_step_latency 2.seconds
  via emergency_service
{
  loop article in live_news max_steps 100_000 on_exhaustion :suspend {
    receipt = RunPipeline(article, now())
    write clarity_reports <- receipt.report evidence [receipt]
  }
}
```

**Impl change:** new loop class, new runtime semantics, new executor obligations.
**Proposal:** PROP-036+ (Stage 4 scope).
**Spec:** ch13.

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
**Proposal:** TBD (candidate PROP after PROP-033)
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
| `observes external/model/robot X` | `observes model ClaimExtractor` | Shorthand for observed contracts; extends PROP-035 |

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

| Priority | PROP | Gap | Stage |
|----------|------|-----|-------|
| 1 | PROP-031 | Gap-A (modifiers) | 3 Language Lane |
| 2 | PROP-032 | Gap-B (via profile) | 3 Language Lane |
| 3 | PROP-033 | Gap-E (evidence) | 3 Language Lane |
| 4 | PROP-034 | Gap-C (profile system) | 3 new Lane |
| 5 | PROP-035 | Gap-D (effect surface) | 3 new Lane |
| 6 | TBD | Gap-H (assumptions block) | 3 Language Lane candidate |
| 7 | TBD | Gap-I (form keyword) | 3 Language Lane candidate |
| 8 | PROP-036+ | Gap-F (service loops) | 4 |
| — | TBD | Gap-G (view, placement) | 4+ |

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
