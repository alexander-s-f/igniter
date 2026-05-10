# Igniter-Lang Language Covenant

Status: governing
Date: 2026-05-10
Author: `[Igniter-Lang Meta Expert]`
Supersedes: nothing (new document)

> The Covenant is not a spec chapter. It is the set of commitments the language
> makes to the programmer — the reasons why the language is the way it is.

---

## Core Axiom

> **A program is an honest account of what it does to the world.**

If a program cannot say what it does — to which system, with what authority,
with what consequence, and with what evidence — it should not compile.

---

## The 26 Postulates

### Postulate 1 — Contracts, Not Procedures

A contract declares what must be true, not what must be executed in order.
The body is a dependency graph, not a sequence of commands.

```igniter
-- This is not: "first compute a, then compute b"
-- This is: "b depends on a"
compute a = input_x + 1
compute b = a * 2
```

### Postulate 2 — Declared Dependencies

Every computation declares what it depends on. No hidden implicit state.
A node that reads from `x` must name `x` in its dependency declaration.

### Postulate 3 — Explicit Time

Time is a first-class parameter, not a global variable. A contract that reads
historical state must declare `as_of: DateTime` and receive it explicitly.

```igniter
pure contract RevenueAt(region: String, as_of: DateTime) -> amount: Decimal[2]
```

### Postulate 4 — Named Effects

Every side effect is named. There is no I/O without a declaration. A contract
that sends a notification must declare `escape notification_send` and carry the
appropriate modifier.

### Postulate 5 — Immutable Outputs

A contract output is a value, not a reference. Once produced, it does not change.
Temporal history is append-only — correction is a new fact, not a mutation.

### Postulate 6 — Evidence Trails

Every output carries a provenance chain. The evidence clause names the inputs
and observations from which the output was derived.

```igniter
output risk evidence [claim, evidence_bundle]
```

### Postulate 7 — No Hidden Consequences

A contract's effect on the world is declared in its Effect Surface. A reader
who reads only the contract header — not the body — knows the full consequence.

### Postulate 8 — Receipts Are Proof

A receipt is not a log entry. It is a proof that a specific operation completed
with specific inputs and produced a specific output. Receipts are immutable.

### Postulate 9 — Authority Is Explicit

Authority is a value, not a role in a config file. A privileged contract receives
authority as a parameter and can be audited to confirm who authorized what.

### Postulate 10 — Profiles Are Policy

A profile is not configuration. It is a compile-time policy that restricts and
obligates what a contract may do. Profiles cannot be bypassed at runtime.

### Postulate 11 — Uncertainty Is Preserved

A model output is an observation, not a fact. An estimate carries its uncertainty
as a typed field. The language does not allow uncertainty to be silently discarded.

```igniter
type PositionEstimate {
  x: Decimal[3]
  y: Decimal[3]
  uncertainty_m: Decimal[3]   -- required, not optional
  confidence: Decimal[3]
}
```

### Postulate 12 — Simulation Is Labeled

A simulated receipt is a different type from a real receipt. `SimulatedDispatchReceipt`
cannot be used where `DispatchReceipt` is expected. Simulation cannot masquerade
as reality.

### Postulate 13 — Observation Is Typed

There are three kinds of observation: real (from the world), model (from inference),
and human (from judgment). They are different types. A model observation cannot
be used as a real observation without explicit conversion.

### Postulate 14 — Loops Are Managed

Every repetition belongs to a loop class with a compiler-verified contract:
finite by collection size, finite by structural variant, finite by fuel,
convergent by metric, or alive by liveness (service loop). There is no general
recursion and no unbounded loop.

### Postulate 15 — Timeout Is Not Failure

A timeout waiting for an external system is `UnknownExternalOutcome`, not
`ObservedFailure`. These are different types. They require different responses:
reconciliation, not retry.

### Postulate 16 — Idempotency Is Declared

An operation under automatic retry must declare its idempotency key. A
non-idempotent operation in a retry-enabled profile is a compile error.

### Postulate 17 — Compensation Is Named

An irreversible contract must name its compensation contract or explicitly
declare `no_compensation`. The decision is visible at the declaration site.

### Postulate 18 — Decisions Are Separable

The decision of what to do (pure, simulatable, dry-runnable) is separate from
the act of doing it (irreversible, authority-required). The compiler enforces
this separation: an irreversible contract is unreachable from a pure context.

### Postulate 19 — Reversibility Is a Scale

Reversible — Compensatable — Refundable — Append-only — Irreversible — Destructive.

A profile may declare a maximum reversibility level. Exceeding it is a compile error.

### Postulate 20 — Contracts Compose

A contract that calls another contract inherits its evidence obligations. Evidence
chains form a directed acyclic graph. The compiler validates that no evidence is
lost at composition boundaries.

### Postulate 21 — Consequence Ownership

A program owns its consequences. If it cannot name them, it cannot claim them.
If it cannot claim them, it should not act.

> Declare it. Own it. Do not outsource responsibility.

### Postulate 22 — Assumption Visibility

Every assumption a program relies on must be declared, typed, and carried through
its evidence chain. A system may rely on assumptions. It must not hide them.

```igniter
assumptions {
  assumption homophily {
    kind :synthetic
    statement "People with similar beliefs interact more often."
    strength 0.70
  }
}

-- Assumptions flow through evidence:
output interaction evidence [a, b, homophily]
```

Hidden assumptions are technical debt against truth. They accumulate inside weights,
prompts, thresholds, and undocumented heuristics. Igniter makes them explicit.

> An assumption is not a weakness. A hidden assumption is.

### Postulate 23 — Synthetic World Visibility

A synthetic world must identify itself as synthetic. Simulated state, generated
populations, and modelled societies are different from observed reality. They must
carry explicit epistemic markers that survive receipts and lineage traversal.

```igniter
receipt SimulationReceipt {
  mode: :synthetic          -- not :observed, not :inferred
  honesty_statement: String -- required for synthetic receipts
  assumption_hash: String   -- hash of the AssumptionSet used
}
```

A simulated receipt cannot be used where an observed receipt is expected.
The type system enforces the distinction at contract boundaries.

### Postulate 24 — Choices Are Not Simplified Away

A system may be forced to choose under uncertainty and resource constraint.
The language forbids pretending the choice was simple.

Every consequential decision must expose:
- what was known (observed inputs with confidence)
- what was assumed (declared assumption set)
- what constraints were obeyed
- what alternatives were rejected (and why)
- who authorized the choice (authority chain)
- what consequences are expected
- what cannot be compensated if it goes wrong

This applies to financial allocation, logistics strategy, medical triage, robot
dispatch, pricing, security action, and resource planning — not only to emergency
rescue. Wherever a system is "forced to choose", the language makes that choice
legible.

> The system may be forced to choose.
> The language forbids pretending the choice was simple.

### Postulate 25 — Constraints Are Declared

A constraint is a normative or operational boundary that a program must respect.
Constraints are not buried in invariant thresholds, config values, or model weights.
They are declared at the module level alongside assumptions.

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
}
```

A program may optimize within its constraints.
It must not hide the constraints it chose to obey.

A contract that uses a constraint set must declare it explicitly (`uses constraints NAME`).
Constraint sets enter receipts via `constraint_hash` — auditable, replayable, content-addressed.

### Postulate 26 — Audit Completes the Decision

A decision is not complete when it is executed. It is complete only when expected
outcomes can be compared to observed outcomes — or when the system explicitly
declares why such comparison is impossible.

The PostAudit is not an afterthought. It closes the accountability loop:

```
Observe → Estimate → Plan → Decide → Approve → Act → Audit
```

Every consequential decision receipt must either:
1. Carry a reference to its eventual audit receipt; or
2. Declare `audit: :deferred` with a reason; or
3. Declare `audit: :impossible` with a stated reason.

A decision that produces no feedback into the system's understanding is
an accountability debt.

---

## Four Axes of Language Honesty

From the pressure specimens and cross-review (S3-R28), four distinct honesty axes
have emerged. Each is orthogonal. All four must hold simultaneously.

```
epistemic honesty   — what we know, at what certainty, with what assumptions
effect honesty      — what we change, with what authority, with what compensation
constraint honesty  — what we must respect, of what kind, at what priority
audit honesty       — what happened after, how expected vs actual compared
```

These axes map to the canonical execution pipeline:

| Pipeline stage | Honesty axis | Contract class |
|----------------|-------------|----------------|
| Observe | epistemic | `observed contract` |
| Estimate | epistemic | `pure contract` |
| Plan | epistemic | `pure contract` |
| Decide | constraint | `pure contract` + `uses constraints` |
| Approve | effect | `privileged contract` |
| Act | effect | `effect`/`irreversible contract` |
| Audit | audit | `audit contract` / PostAudit pattern |

---

## The Epistemic State Machine

Agent-D (cross-review S3-R28) named this: the honesty stack is not a certainty
scale — it is an **epistemic state machine** with typed transitions.

| State | Meaning | Example |
|-------|---------|---------|
| `observed` | Directly witnessed from the world | `drone.sensor.reading` |
| `inferred` | Derived from observations by reasoning | `survivor_zone = derive_zone(signal)` |
| `estimated` | Probabilistic quantified inference | `confidence: 0.72` |
| `assumed` | Declared premise (`kind: :empirical/:heuristic`) | `assumptions {}` block |
| `simulated` | Synthetic world state | `epistemic_kind: :synthetic` |
| `decided` | Chosen action under constraints | `StrategyDecision` |
| `executed` | External consequence receipt | `DispatchReceipt` |
| `audited` | Expected vs actual comparison | `PostAuditReceipt` |

**Critical rule — No Upward Coercion:**

A value may not move to a higher-certainty epistemic state without an explicit
typed conversion or human review:

```
assumed   → observed    FORBIDDEN without explicit review
simulated → executed    FORBIDDEN (type error)
estimated → known       FORBIDDEN (no silent certainty upgrade)
inferred  → fact        FORBIDDEN
```

This rule is enforced by the type system at contract boundaries.

**Open (S3-R28):** The exact mechanism for the `uses assumptions` / `uses constraints`
declaration and how it gates upward coercion is not yet specified. Requires Gap-H
and Gap-J PROPs.

---

## Three Doctrines

### Honest Computing Doctrine

> The compiler is not only a correctness checker. It is an honesty checker.

The language must not hide:

| What | How it hides | Language response |
|------|-------------|-------------------|
| Consequence | Effect buried in body | Effect Surface at declaration |
| Uncertainty | `confidence: 1.0` without proof | `uncertainty_m` required field |
| Authority | Environment variable / ambient permission | Authority as typed value |
| Simulation | Simulated receipt = real receipt | Different types |
| Mutation | Write disguised as read | `effect`/`privileged`/`irreversible` modifiers |
| Irreversibility | "Just retry" | `compensation` field or `no_compensation` |
| Ambiguity | Generic `Any` at boundary | No `Any` at contract boundaries |
| Provenance | Output with unknown source | `output ... evidence [refs]` |
| Assumptions | Premise buried in weights/config/threshold | `assumptions {}` block — declared, typed, hashable |
| Synthetic world | Simulation presented as observation | `:synthetic` mode + `honesty_statement` in receipt |
| Constraints | Normative boundary in config/hardcoded constant | `constraints {}` block — declared, typed, `constraint_hash` |
| Rejected alternatives | "We chose X" without showing what was rejected | `StrategyDecision.rejected` — discarded options in receipt |
| Audit gap | Decision with no outcome feedback | `audit:` field in decision receipt — Postulate 26 |

### Managed Recursion Doctrine

> A loop is a contract over state transition. It must be declared, not assumed.

Every loop must be:
- **Stoppable** — there is a signal that terminates it
- **Observable** — there is a signal that proves it is alive
- **Bounded** — either termination is proven, or each step is bounded in time

A loop that cannot make these guarantees should not be written.

### Stoicism as Architecture

The language does not prevent bad outcomes. It makes them visible, named, and
owned. A system built in Igniter-Lang fails loudly, with evidence, with a named
compensation path, and with a complete receipt trail. It does not fail silently.

> We cannot control what the network does. We can control what we declare about it.

---

## What the Language Forbids

- Hidden effects (all must be declared in modifier + Effect Surface)
- Silent type erasure (`Any` at boundaries)
- Implicit side effects in pure contracts
- `now()` anywhere — time must enter as explicit input or tick binding (OOF-M1; see CL-4)
- Non-idempotent operations under automatic retry
- Unbounded loops (every repetition has a class)
- Simulated receipts masquerading as real (separate types)
- `timeout` treated as `failure` (different types, different paths)
- Hidden assumptions (must be declared, typed, and carried through evidence)
- Hidden constraints (must be declared in `constraints {}`, not buried in thresholds)
- Unnamed DSL blocks (every top-level construct must declare its nature)
- Upward coercion without review (`assumed → observed` is a type error)
- Pretending a consequential choice was simple (Postulate 24 — rejected alternatives must appear in receipt)

---

## Cross-Reference to Spec

| Postulate | Spec chapter | PROP | Status |
|-----------|-------------|------|--------|
| 1–2 | ch1 (Identity), ch2 (Grammar) | PROP-001, PROP-014 | ✅ |
| 3 | ch9 (Temporal) | PROP-022 | ✅ |
| 4, 7, 16, 17, 19 | ch12 (Effect Surface) | PROP-035 | pending |
| 5 | ch9 (BiHistory) | PROP-022 | ✅ |
| 6, 20 | ch10 (Modifiers §10.5) | PROP-031, PROP-033 | PROP-031 ✅ |
| 8 | ch12 (receipt field) | PROP-035 | pending |
| 9 | ch12 (authority field) | PROP-035 | pending |
| 10 | ch11 (Profile System) | PROP-034 | pending |
| 11, 12, 13 | ch10 (observed modifier) | PROP-031 | ✅ |
| 14 | ch13 (Managed Recursion) | PROP-036+ | pending |
| 15 | ch12 (failure taxonomy) | PROP-035 | pending |
| 18 | ch10 (pure/irreversible separation) | PROP-031 | ✅ |
| 21 | ch12 (Effect Surface, all fields) | PROP-035 | pending |
| 22 | Gap-H (assumptions block) | TBD | open |
| 23 | Gap-H (synthetic receipt type) | TBD | open |
| 24 | Gap-J (constraints block) + ch12 | TBD | open |
| 25 | Gap-J (constraints block) | TBD | open |
| 26 | Gap-N (audit contract/pattern) | TBD | open |
