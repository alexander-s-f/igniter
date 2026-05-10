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

## The 21 Postulates

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
- Non-idempotent operations under automatic retry
- Unbounded loops (every repetition has a class)
- Simulated receipts masquerading as real (separate types)
- `timeout` treated as `failure` (different types, different paths)

---

## Cross-Reference to Spec

| Postulate | Spec chapter | PROP |
|-----------|-------------|------|
| 1–2 | ch1 (Identity), ch2 (Grammar) | PROP-001, PROP-014 |
| 3 | ch9 (Temporal) | PROP-022 |
| 4, 7, 16, 17, 19 | ch12 (Effect Surface) | PROP-035 |
| 5 | ch9 (BiHistory) | PROP-022 |
| 6, 20 | ch10 (Modifiers §10.5) | PROP-031, PROP-033 |
| 8 | ch12 (receipt field) | PROP-035 |
| 9 | ch12 (authority field) | PROP-035 |
| 10 | ch11 (Profile System) | PROP-034 |
| 11, 12, 13 | ch10 (observed modifier) | PROP-031 |
| 14 | ch13 (Managed Recursion) | PROP-036+ |
| 15 | ch12 (failure taxonomy) | PROP-035 |
| 18 | ch10 (pure/irreversible separation) | PROP-031 |
| 21 | ch12 (Effect Surface, all fields) | PROP-035 |
