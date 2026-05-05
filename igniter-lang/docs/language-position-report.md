# Igniter-Lang: Position, Strengths, Blind Spots, and Derivatives

Status: meta thesis
Date: 2026-05-05
Author: `[Igniter-Lang Compiler/Grammar Expert]`
Supervisor: `[Architect Supervisor / Codex]`

---

## I. What Igniter-Lang Actually Is

Before comparing, we need a precise statement. Igniter-Lang is not a
general-purpose language. It is a **temporal contract language for
observable business logic**. Its thesis is:

```text
Every computation is:
  - a contract over typed inputs/outputs
  - evaluated at an explicit temporal horizon
  - producing a typed, content-addressed observation
  - with declared lifecycle, capability, and effect constraints
  - verifiable by construction, not by post-hoc testing
```

This is a specific and uncommon conjunction. Most languages handle one or two
of these dimensions. Igniter-Lang handles all of them simultaneously, at the
type level, with no ambient globals.

---

## II. Position Relative to Other Languages

### 2.1 The Space

A useful three-axis framing:

```text
Axis 1: Paradigm gravity
  Imperative ←————————————————→ Declarative

Axis 2: Effect handling
  Everything mutable ←——————→ Effects declared and typed

Axis 3: Time handling
  Ambient clock ←——————————→ Time is an explicit parameter
```

Igniter-Lang sits at: **Declarative / Effects typed / Time explicit**.
This combination is rare. Here is how the field distributes:

| Language / System | Paradigm | Effects | Time |
|------------------|---------|---------|------|
| Ruby, Python, Go | Imperative | Implicit everywhere | Ambient |
| Haskell | Functional | IO monad (typed but not business-semantic) | Ambient |
| Elm | Functional-reactive | Explicit Cmd/Sub | Ambient |
| PureScript | Functional | Effect row types | Ambient |
| Koka | Functional | Effect polymorphism (typed effects) | Ambient |
| Effekt | Functional | Region-based effects | Ambient |
| Rholang | Process calculus | Channel-based concurrency | Causal |
| Marlowe | Financial contracts | No general effects | Event-indexed |
| Solidity / Plutus | Transactional | State machine + IO | Block-indexed |
| Temporal.io (Workflow DSL) | Imperative workflow | Side-effects explicit | Durable function time |
| Lustre / SCADE | Synchronous reactive | Clocked | Explicit cycle time |
| Datalog (Datomic, FoundationDB) | Declarative query | Pure reads | As-of time queries |
| PromQL / Flux | Query/reactive | Pure reads | Range/as_of |
| **Igniter-Lang** | **Declarative contract** | **CORE/ESCAPE/OOF typed** | **Explicit as_of + lifecycle** |

### 2.2 The Closest Relatives

**Closest by temporal semantics:** Datalog with bitemporality (Datomic),
Temporal SQL (SQL:2011), Lustre.

**Closest by effect typing:** Koka, Effekt, Frank — but none of these
couple effects to *business lifecycle* or *observation provenance*.

**Closest by observable output:** Event sourcing architectures (CQRS/ES)
in general — but those are patterns, not typed languages.

**Closest by contract framing:** Marlowe (financial contracts) and Dafny
(program verification) — but Marlowe is narrower (finance only) and Dafny
is a verification tool, not a runtime.

**Closest by agent/audit intent:** None. There is no language we know of
that explicitly designs for *agent-readable, audit-chain-preserving,
content-addressed* business contract evaluation.

### 2.3 The Empty Quadrant

The unique position Igniter-Lang occupies can be described precisely:

```text
No language we know of simultaneously provides:
  1. Temporal explicitness (as_of typed, not ambient)
  2. Lifecycle-typed outputs (:local/:session/:window/:durable/:audit)
  3. CORE/ESCAPE/OOF fragment classification at compile time
  4. Content-addressed observations with provenance chain
  5. A formal bridge from business contracts to persistence (TBackend)
  6. Agent-and-human-readable semantic images for cross-session resumption
```

This is the empty quadrant. It exists because most languages and runtimes
treat these concerns as infrastructure, not language semantics.

Igniter-Lang's thesis is: **these concerns must be first-class language
semantics, not infrastructure conventions**.

---

## III. Strengths

### S-1: Temporal Honesty

By making `as_of` a type parameter of every projection and evaluation,
Igniter-Lang eliminates an entire class of bugs: functions that return
different results depending on when they are called, with no record of
the difference. Every `value_observation` carries the exact temporal
horizon at which it was produced. This is the language equivalent of
bitemporality — but expressed as a type constraint, not a query feature.

### S-2: Observability by Construction

Every computation produces a typed `ObsPacket`. There is no way to
evaluate a CORE contract without producing an observation. This means
observability is not an instrumentation concern — it is a structural
property. A system built in Igniter-Lang is, by construction, fully
observable without any external tracing or logging frameworks.

### S-3: The Fragment Classifier as a Trust Boundary

The CORE/ESCAPE/OOF classifier (PROP-003) gives the language a formal
boundary between deterministic, reproducible computations and those that
interact with the outside world. This is more useful than most effect
systems because it directly maps to business concerns:

- CORE = auditable, reproducible, explainable
- ESCAPE = declared, capability-gated, receipt-producing
- OOF = disallowed — caught at compile time

This maps well to compliance, financial audit, and AI agent action policy.

### S-4: The Fractal Contract Stack

The insight that Language, Runtime, and User contracts are all the same
shape (PROP-004b) — all declare promises, capabilities, and evidence —
means the trust model is uniform. A RuntimeContract is verified the same
way a UserContract is executed. This is an elegant self-similar structure.

### S-5: Semantic Resume

The `SemanticImage` + `CompatibilityReport` model (PROP-009/011) is
genuinely novel: it defines session-to-session continuity as a typed
protocol, not as process memory. A new session (agent or human) can
resume a prior session by verifying a compatibility report, not by
inheriting state. This makes the system naturally suitable for
long-running agent workflows with interruptions.

### S-6: Agent-Native Design

Without explicitly targeting AI agents, Igniter-Lang has produced a
language that agents can reason about natively:
- Every computation is a typed contract (agents can inspect inputs/outputs)
- Every effect is declared and capability-gated (agents can evaluate safety)
- Every observation is content-addressed (agents can verify reproducibility)
- Semantic images enable agent handoff (agent B can resume agent A's work)
- CORE/ESCAPE classification tells an agent what is deterministic vs. live

This is a latent capability that has not been formally surfaced yet.

---

## IV. Weaknesses and Blind Spots

### W-1: No Recursion or Iteration Model

The current CORE fragment is a DAG. Contracts can express acyclic
computation graphs but cannot express loops, folds over sequences, or
recursive structures. This is fine for the dispatch example, but limits
expressiveness for:
- Aggregations over collections
- Fixed-point computations (e.g. convergent workflows)
- Graph traversal

**Blind spot**: The current model implicitly assumes all computations
terminate in finite graph evaluation. This needs a formal statement
either as a theorem or as an explicit limitation with ESCAPE for
recursive patterns.

### W-2: No Schema Evolution Model

The formal specification defines `artifact_hash` and `program_id` as
content-addressed. But it does not define how a system handles schema
evolution: when a contract's type signature changes between versions,
how are old observations interpreted?

**Blind spot**: We have `CompatibilityReport` for runtime versions, but
no equivalent for contract schema versions. An `ObsSchemaVersion` or
`DataMigrationContract` concept is missing.

### W-3: The ESCAPE Fragment Is Under-Specified

PROP-003 classifies ESCAPE constructs but does not fully specify:
- The composition rules for ESCAPE contracts (can two ESCAPE contracts
  be composed without escalating to OOF?)
- The capability algebra (can capabilities be delegated? revoked?)
- The ESCAPE isolation model (what prevents an ESCAPE contract from
  contaminating a CORE evaluation?)

**Blind spot**: We know what ESCAPE *is* but not the full *algebra*
of ESCAPE composition and capability delegation.

### W-4: No Error Recovery / Compensation Model

The formal model has `failure_observation` with `reason_codes` and
`status: :blocked/:rejected`. But there is no model for:
- Compensation (Saga pattern): what happens when step N fails after
  steps 1..N-1 have emitted receipts?
- Retry semantics: under what conditions is re-evaluation safe?
- Partial success: when can a partially-evaluated contract produce
  partial output?

**Blind spot**: The current model is strong on failure detection but
weak on failure recovery. This is a known gap in formal contract models.

### W-5: The Stdlib is a Stub

PROP-004b defines three axiom tiers but the actual standard library
(core contracts, temporal primitives, collection operators) has not
been specified. The language currently has no built-in vocabulary for:
- Collection operations (map, filter, reduce, group_by)
- String manipulation
- Date/time arithmetic (beyond as_of comparison)
- Numeric precision and rounding
- Optional/Result chaining

**Blind spot**: Every CORE axiom in Tier 1 is named but not formally
typed. This means the type system is incomplete.

### W-6: Privacy and Redaction Are First-Class but Under-Used

PROP-005 defines `PrivacyPolicy` and payload redaction as part of the
`ObsPacket`. But none of the subsequent proposals formalize how:
- Privacy policies are inherited through contract composition
- A redacted observation participates in a dependency graph
- An agent with partial visibility evaluates a contract with
  privacy-filtered inputs

**Blind spot**: The privacy model exists at the envelope level but
has not been integrated into the type system or the evaluation model.

### W-7: Distribution is ESCAPE Without a Clear Boundary

PROP-006 marks distributed runtime composition as ESCAPE. But it does
not define:
- What distributed evaluation means formally (partial orders? vector clocks?)
- How to compose TBackend instances across nodes
- What consistency guarantees are preserved across a distributed call

**Blind spot**: The formal model is single-process strong-consistency
by default. Distributed semantics are deferred as ESCAPE but never
formally bounded.

---

## V. What Needs to Close the Theoretical Part

### T-1: Fold/Aggregate Primitive (closes W-1)

Add a `fold[T, A](collection: Collection[T], init: A, f: A × T → A) → A`
primitive to the Core Axiom Layer (PROP-004b Tier 1). This gives the
language the ability to express aggregations without recursion (since
`fold` is bounded by the collection size, termination is guaranteed).
This would close the DAG-only limitation for the common case.

### T-2: Contract Schema Version and Migration Protocol (closes W-2)

Define:
```text
ContractSchemaVersion = Record {
  contract_id     : String
  version         : String
  type_signature  : ContractTypeSignature
  migration_from  : Option[ContractSchemaVersion]
  migration_obs   : Option[ObsId]
}
```
A `CompatibilityReport` should include a `schema_version` dimension
alongside the existing 11 dimensions.

### T-3: ESCAPE Composition Algebra (closes W-3)

Formally extend PROP-002 with composition rules for ESCAPE:
- Two CORE contracts compose to CORE (already stated)
- CORE ∘ ESCAPE = ESCAPE (already implied)
- ESCAPE ∘ ESCAPE = ESCAPE iff escape sets are disjoint
- ESCAPE ∘ ESCAPE = requires explicit capability delegation if caps overlap
- Capability delegation: formal `CapabilityGrant` type

### T-4: Compensation Contract and Saga Model (closes W-4)

Define `CompensationContract` as a first-class concept:
```text
CompensationContract = Record {
  for_contract   : ContractRef
  trigger        : :failure | :timeout | :explicit_cancel
  undo_steps     : Collection[CompensationStep]
  must_audit     : Bool
}
CompensationStep = Record {
  step_id       : String
  reverses      : ObsId    -- the receipt_observation being undone
  emits         : ObsKind  -- what the compensation produces
}
```
This gives the language a formal model for Saga-style long-running
distributed transactions — essential for the Technician Dispatch use case.

### T-5: Stdlib Formal Types (closes W-5)

A `PROP-013: igniter-lang-stdlib-v0` pass that formally types all
Tier 1 axioms from PROP-004b, including:
- `Collection[T]` with fold, filter, map, group_by, count, sum
- `Option[T]` with map, flat_map, or_else, get_or
- `Result[T, E]` with map, flat_map, recover
- Date/time arithmetic under explicit `TemporalCtx`

### T-6: Privacy Propagation Through Composition (closes W-6)

Define privacy propagation rules:
- A composition of contracts where any input carries `PrivacyPolicy ≠ :public`
  must propagate that policy to all dependent nodes
- A `privacy_observation` ObsKind for redaction events
- A type-level `Classified[T, policy]` wrapper

---

## VI. Insights and Derivatives

### I-1: The Observation is the Unit of Trust, Not the Function

Most functional languages think in terms of functions as the unit of
meaning. Igniter-Lang's insight is that the **observation** is the unit
of trust. A function result is meaningless without:
- who produced it (ProducerRef)
- under what assumptions (TemporalCtx, rule_version, fact_scope)
- with what evidence chain (links)
- with what lifecycle (can it be relied upon next session?)

This is a fundamentally different epistemology from functional programming.
It is closer to *epistemic logic* (what does an agent know, and how do
they know it?) than to lambda calculus.

**Derivative**: Igniter-Lang could be positioned as an
*epistemic contract language* — a language where every value is a
*justified belief* with an explicit justification structure.

### I-2: CORE/ESCAPE is a Computational Trust Calculus

The three-fragment model is not just a practical classification. It is
a trust calculus:
- CORE = the language vouches for reproducibility
- ESCAPE = the runtime vouches for correctness (via capability gates and receipts)
- OOF = no one vouches — the computation is outside the trust boundary

This maps to a formal notion of *computational trust*: the level of
assurance a relying party (human or agent) can place on a result.

**Derivative**: The fragment model could be extended to a formal
*trust lattice* where compositions of contracts produce typed trust levels,
and agents can query "what is the minimum trust level of this result?"

### I-3: The Fractal Contract Stack as a Meta-Protocol

The self-similar structure of Language/Runtime/User contracts (PROP-004b)
implies that Igniter-Lang is not just a language — it is a **meta-protocol
for expressing trust boundaries at any scale**. A microservice API
contract is an Igniter-Lang contract. A database read policy is an
Igniter-Lang contract. A machine learning model's prediction boundary
is an Igniter-Lang contract.

**Derivative**: Igniter-Lang could be the basis for a
*universal contract registry* — a system where any computation, at any
scale, can declare its semantic boundary, capability requirements, and
evidence chain, and be verified against it.

### I-4: SemanticImage as a New Primitive for Agent Handoff

The `SemanticImage` is, essentially, a typed, content-addressed checkpoint
of an agent's semantic state. This is not just a persistence primitive —
it is a **new primitive for agent-to-agent handoff** in a multi-agent
system. Agent A can produce a `SemanticImage`, publish it to a registry,
and Agent B can resume from it with a formal `CompatibilityReport`.

**Derivative**: A multi-agent orchestration protocol built on
`SemanticImage` as the handoff primitive. Each agent is a
`RuntimeMachine`; the orchestrator is a `CompatibilityReport` evaluator.
This is a fully typed, auditable multi-agent workflow.

### I-5: The .igapp/ Artifact as a Deployable Knowledge Unit

The `.igapp/` format is not just a compiled program. It is a
**deployable knowledge unit** — a self-describing, content-addressed,
human-readable bundle of:
- what the program computes
- under what assumptions
- with what lifecycle constraints
- with what capability requirements

An agent that receives an `.igapp/` artifact can reason about it without
executing it. It can answer: "Is this computation safe to run?" "What
facts does it need?" "What evidence will it produce?" without running the
evaluator.

**Derivative**: An *artifact marketplace* or *contract registry* where
`.igapp/` bundles are published, discovered, and composed by agents and
humans. Each artifact is a typed, verifiable unit of business logic.

### I-6: Lifecycle as a First-Class Policy, Not Infrastructure

Most systems treat data retention as a database concern (TTLs, archiving
policies). Igniter-Lang's insight is that **lifecycle is a semantic
property of the observation, declared at the language level**. The
database implements the policy; the language declares it.

This means the language is the single source of truth for data retention,
compaction, and audit requirements — not the ops team's configuration files.

**Derivative**: Igniter-Lang as a *compliance language* — a language
where GDPR retention policies, financial audit requirements, and data
residency rules are expressed as first-class lifecycle declarations,
verified at compile time, and enforced at runtime.

### I-7: The BoundaryReceipt as a Temporal Git Commit

The `BoundaryReceipt` with its `detail_hash` is structurally equivalent
to a Git tree hash: it proves that exactly these observations were included
in this temporal boundary, even after the observations are compacted.

**Derivative**: Igniter-Lang's observation chain is, essentially, a
**typed, content-addressed history** — closer to a Git repository of
business facts than to a traditional database. This suggests an
alternative positioning: *Igniter-Lang is the language for business
history, not just business logic*.

---

## VII. Strategic Assessment

### What Igniter-Lang Does Better Than Anyone Else

1. **Temporal honesty at the type level** — no ambient clock, ever
2. **Observation-first design** — every result is justified, not just computed
3. **Fragment-level trust classification** — CORE/ESCAPE/OOF is a trust calculus
4. **Cross-session semantic continuity** — SemanticImage + CompatibilityReport
5. **Agent-native by construction** — every property an agent needs is typed

### What Must Be Closed Before v1

| Priority | Gap | Closes With |
|----------|-----|-------------|
| Critical | No fold/aggregate | T-1: fold primitive in stdlib |
| Critical | Stdlib is a stub | T-5: PROP-013 stdlib types |
| High | Schema evolution | T-2: ContractSchemaVersion |
| High | ESCAPE algebra | T-3: capability delegation |
| Medium | Failure recovery | T-4: CompensationContract |
| Medium | Privacy propagation | T-6: Classified[T, policy] |
| Low | Distribution semantics | Deferred to v1+ |

### The Strongest Unique Claim

```text
Igniter-Lang is the only language where:
  "I computed X at time T under assumptions A with evidence E
   and that result is valid for purpose P until condition C"

is a first-class type, not a comment or a convention.
```

This is the sentence that no other language can make.

---

## VIII. The Name for What Igniter-Lang Is

Having mapped the landscape, we can now name the paradigm:

```text
Igniter-Lang is an Epistemic Contract Language (ECL).

Epistemic:  every result is a justified belief with a typed justification
Contract:   every computation is a typed boundary with declared obligations
Language:   these properties are enforced at compile time, not by convention
```

The paradigm is new. The closest prior art is:
- Epistemic logic (knowledge representation, AI planning)
- Contract-based programming (Eiffel, Racket)
- Temporal databases (bitemporality, event sourcing)
- Effect type systems (Koka, Effekt)

Igniter-Lang synthesizes all four into a single coherent design. That is
the source of its uniqueness — and the reason the theoretical gaps listed
above matter: they are gaps in a genuinely novel paradigm, not in
yet-another programming language.
