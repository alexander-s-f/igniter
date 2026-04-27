# Igniter Contract Language — Contract Algebra and Enterprise Model

Date: 2026-04-27.
Status: research note — not yet implemented.
Scope: maximal unification (everything is a contract), organic axiom layer,
enterprise-level system thinking.

*Builds on: [igniter-lang-spec.md](igniter-lang-spec.md) ·
[igniter-lang-propmodel.md](igniter-lang-propmodel.md)*

---

## § 1. The Maximal Unification: Everything is a Contract

### § 1.1 Types as Contracts

The standard view treats types as objects and contracts as morphisms between
them. The maximal unification goes further: **types are contracts**.

```
contract Int {
  in  wire: Bit[64]
  guard :valid { is_int(wire) }
  out value: Int = decode(wire)
}

contract Add {
  in  a: Int
  in  b: Int
  out result: Int = a + b
}
```

Under this model:
- Type checking = contract composition
- Type inference = contract synthesis (the property model in action)
- Type errors = "no contract exists with this signature" (not a categorical failure,
  but a synthesis miss — the system can suggest alternatives)

The expression `a + b` becomes `Add { a: a, b: b }.result`. A program is a graph
of contracts, all the way down.

### § 1.2 Contract Algebra

If everything is a contract, all program operations become operations over
contracts. The algebra is closed:

| Operation | Notation | Meaning |
|-----------|----------|---------|
| Sequential | `A >> B` | output of A feeds input of B |
| Parallel | `A ⊗ B` | independent graphs, combined outputs |
| Choice | `A \| B` | branch by condition |
| Refinement | `A where guard` | add constraint to existing contract |
| Lifting | `~A` | approximate version of A |
| Projection | `A.field` | select one output from A |
| Iteration | `A*` | repeat until condition (opt-in, non-DAG) |

These are the laws of a **symmetric monoidal category** where contracts are
morphisms and `⊗` is the tensor product. Sequential composition is associative
with identity `id[τ]`; parallel is commutative up to isomorphism.

### § 1.3 Connection to Arrows

Haskell's `Arrow` typeclass is precisely this abstraction — a generalisation of
functions to "computations with typed inputs and outputs":

```haskell
class Arrow a where
  arr   :: (b -> c) -> a b c        -- lift a function to a contract
  (>>>) :: a b c -> a c d -> a b d  -- sequential composition
  first :: a b c -> a (b,d) (c,d)  -- parallel (left component)
```

Igniter contracts are arrows. Arrow laws give free theorems about contract
composition: associativity, identity, and the interchange law hold by
construction from the DAG property.

### § 1.4 The Axiom Boundary

Every system has an ungrounded bottom. In Peano arithmetic it is the successor
axiom; in type theory it is the formation judgments. Contracts are no different:
at some depth they bottom out into host-language primitives.

The question is not *whether* an axiom layer exists — it always does. The
question is **where to draw the boundary and how to make it invisible**.

Three positions for the boundary:

| Position | What is an axiom | User experience |
|----------|-----------------|-----------------|
| **Thin** | Only arithmetic and IO | All domain logic is contracts |
| **Medium** | Functions/classes in host language (current Igniter) | Contracts compose functions |
| **Thick** | Entire services are axioms | Contracts are just glue |

The vision explored here is the **thin** position — push the boundary as low
as possible so that enterprise users never touch it.

---

## § 2. The Organic Axiom Layer

### § 2.1 The Vocabulary Problem

An axiom layer that speaks the language of mathematics (`Add`, `Compare`,
`Multiply`) is not organic for enterprise development. Enterprise reasoning
uses a different vocabulary:

- *"Approve a purchase order"*
- *"Reserve inventory against a forecast"*
- *"Notify stakeholders of a status change"*
- *"Compensate a failed payment saga"*

Making the axiom layer organic means making the **library vocabulary** speak
the domain language, so that the axiom layer becomes invisible to the user.

### § 2.2 Three-Tier Architecture Without Seams

```
╔══════════════════════════════════════════════════════╗
║  SYSTEM     OrderManagement, InventorySystem, ...   ║  ← user thinks here
╠══════════════════════════════════════════════════════╣
║  LIBRARY    Approve, Notify, Reserve, Audit, Saga   ║  ← standard library
╠══════════════════════════════════════════════════════╣
║  AXIOM      Add, Compare, Fetch, Store, Emit        ║  ← invisible bottom
╠══════════════════════════════════════════════════════╣
║  PLATFORM   Ruby / LLVM / wire                      ║  ← metal
╚══════════════════════════════════════════════════════╝
```

The user works at the top tier and occasionally reaches into LIBRARY. They
never write AXIOM contracts directly. The PLATFORM is never referenced.

The "no-seam" principle: the boundary between LIBRARY and AXIOM must be
imperceptible. Library contracts should feel like language built-ins, not
third-party dependencies.

### § 2.3 The SQL Analogy

SQL hides B-trees, index scans, and query planning. You declare:

```sql
SELECT order_total FROM orders WHERE status = 'complete'
```

Not: "open B-tree leaf page, scan forward while status = complete, project
order_total column."

The contract language should do the same for business logic. The user declares
**what** the system should compute at the domain level; the contract graph and
its execution are the query plan.

---

## § 3. Enterprise Primitives as First-Class Contract Patterns

The LIBRARY tier must cover the canonical patterns of enterprise systems.
Each pattern is a macro that expands to core contract constructs.

### § 3.1 Entity with Lifecycle

```
entity Order {
  lifecycle: pending → processing → complete | cancelled
  invariants: [
    total >= 0
    items.count > 0
    status in OrderStatus
  ]
}
```

Expands to:
- A `branch` node guarding valid lifecycle transitions
- `guard` nodes enforcing invariants on every transition
- `effect` nodes emitting `order.status_changed` events
- An `await` node for asynchronous transitions

### § 3.2 Workflow (Saga)

```
workflow Fulfillment {
  steps:        [ValidateOrder, ReserveInventory, ChargePayment, Ship]
  compensation: [ReleaseInventory, RefundPayment]
  timeout:      48.hours
}
```

Expands to:
- Sequential `compose` chain for the happy path
- `effect @compensate` links for each compensating step
- A top-level `await` with timeout
- Automatic rollback contract on any step failure

### § 3.3 Policy (Cross-Cutting Rule)

```
policy ApprovalRequired {
  when:     order.total > 10_000
  requires: ManagerApproval { manager: order.manager }
}
```

Expands to:
- A `guard` node injected into every contract that touches `order.total`
- The `ManagerApproval` sub-contract composed conditionally
- Audit `effect` on every approval or rejection

Policies are the contract equivalent of aspect-oriented programming — but
declared explicitly and verified at compile time.

### § 3.4 System Declaration

```
system OrderManagement {
  entities:  [Order, Product, Customer]
  workflows: [Fulfillment, Return, Cancellation]
  policies:  [ApprovalRequired, FraudCheck, RateLimit]
  events:    [OrderPlaced, OrderShipped, PaymentFailed]
}
```

A `system` declaration is the top-level composition unit. It:
- Names the bounded context
- Declares the entity graph
- Wires workflows to entity lifecycle transitions
- Applies policies across all contracts in scope
- Registers event channels for `await` / `effect` bindings

---

## § 4. The Ideal: `compute` Disappears

### § 4.1 compute as disguised compose

Every `compute` node with a non-trivial body is actually a `compose` to a
library contract that has not been named yet.

| As written today | In the contract-algebra ideal |
|-----------------|-------------------------------|
| `compute :price = item.price * qty` | `compose :price = LineTotal { item: item, qty: qty }` |
| `compute :risk = score > 0.8 ? :high : :low` | `compose :risk = RiskBand { score: score }` |
| `compute :filtered = items.select(&:available)` | `collection :available = items \|> Select[available]` |
| `compute :total = items.sum(&:price)` | `aggregate :total = sum(items \|> map { .price })` |

The logic does not disappear — it moves from inline `compute` bodies into
library contracts, where it is named, tested, and reused.

### § 4.2 Topology vs. Steps

At the enterprise level, the user specifies the **topology** of computation —
which things depend on which — not the steps of execution.

This is a qualitative shift in authoring mode:

- **Imperative**: "iterate over items, for each multiply price by qty, accumulate"
- **Contract topology**: "apply `LineTotal` to each item, aggregate with `Sum`"

The second form is higher-level, statically verifiable, and directly
parallelisable by the runtime. It also reads as a business description, not
a technical instruction.

### § 4.3 When `compute` Remains

`compute` does not disappear entirely. It remains for:
- **Inline expressions** that are genuinely one-off and not worth naming
- **Bridge nodes** that adapt between library contract outputs
- **Exploratory code** before a pattern has been identified and promoted to library

The rule of thumb: if you write the same `compute` body twice, it should become
a named library contract.

---

## § 5. Contract Standard Library Blueprint

### § 5.1 Vocabulary Coverage Target

A minimum contract vocabulary for enterprise systems should cover:

**Data access**
`Fetch[T]`, `FetchMany[T]`, `Store[T]`, `Update[T]`, `Delete[T]`,
`Query[T]` (parameterised by entity type)

**Validation and authorisation**
`Validate[T]`, `Authorize[subject, action, resource]`, `RateLimit[key, limit]`,
`Sanitize[T]`

**Computation patterns**
`Transform[A, B]`, `Classify[T, Label]`, `Score[T]`, `Rank[T]`,
`Deduplicate[T]`, `Reconcile[A, B]`

**Communication and integration**
`Notify[channel, recipient, template]`, `Emit[event]`, `Call[service, op]`,
`Webhook[url, payload]`

**Workflow and state**
`Approve[subject, actor]`, `Escalate[subject, deadline]`, `Schedule[at, contract]`,
`Remind[at, recipient]`

**Observability**
`Audit[entity, action, actor]`, `Trace[node]`, `Metric[name, value]`

### § 5.2 Contract Inference

When a user writes:

```
compose :result = CreditCheck { customer: customer, amount: order.total }
```

and `CreditCheck` does not exist in scope, the system should:

1. Search the library for contracts with matching input signature
2. If found: suggest the canonical name with a diff
3. If not found: invoke the property-model synthesiser with the declared
   input/output types as the goal specification
4. If synthesis succeeds: propose the generated contract for review

This is **type-directed contract synthesis** — the compiler acts as a
pair-programmer that fills in missing library contracts on demand.

### § 5.3 Progressive Disclosure

The three tiers support different authoring modes without conflict:

| User type | Authoring mode | Contracts used |
|-----------|---------------|----------------|
| Domain expert | Declare systems and workflows | SYSTEM + LIBRARY only |
| Application developer | Wire domain contracts | LIBRARY + occasional AXIOM |
| Platform engineer | Build the library | AXIOM + PLATFORM |

Each tier is fully legible on its own. A domain expert reading a `system`
declaration can understand the business logic without knowing the implementation
of `ManagerApproval` or `FraudCheck`.

---

## § 6. Formal Properties

### § 6.1 Compositionality

Because everything is a contract, all composition laws hold uniformly:

```
-- Associativity
(A >> B) >> C  =  A >> (B >> C)

-- Identity
id[τ] >> A  =  A  =  A >> id[τ]

-- Parallel commutativity (up to output reordering)
A ⊗ B  ≅  B ⊗ A
```

These laws are not just theoretical — they drive compiler optimisations
(reordering, fusion, parallelisation) without semantic changes.

### § 6.2 Refinement Monotonicity

Adding a `policy` to a `system` can only make the system **more constrained**,
never less. This is the monotonicity property of the CCP model:

```
system S  ⊑  system S + policy P
```

The compiler can verify this statically: a policy is a `guard` injection,
and guard nodes only reduce the reachable execution space.

### § 6.3 Decidability Preservation

The three-tier architecture preserves the decidability results from
[igniter-lang-theory2.md](igniter-lang-theory2.md):

- SYSTEM and LIBRARY expansions produce contracts in the Horn fragment → PTIME
- `entity` lifecycle expands to stratified `branch`/`guard` → still stratified Datalog
- `workflow` expands to `compose` + `await` → decidable with finite event alphabet
- `policy` injection is monotone → does not introduce new fixed points

The enterprise surface is syntactic sugar over the decidable core.

---

## § 7. Open Research Questions

1. **Minimum library vocabulary** — what is the smallest set of LIBRARY contracts
   that covers 80% of real enterprise codebases? (Empirical study needed.)

2. **Contract inference completeness** — under what conditions can the synthesiser
   guarantee it will find a `CreditCheck` contract given only its type signature?

3. **Policy composition** — when two policies conflict (e.g., `ApprovalRequired`
   and `AutoApproveBelow500`), how does the language detect and resolve the
   contradiction at compile time?

4. **Entity lifecycle and concurrency** — two concurrent workflows both trying
   to transition the same `Order`; what contract construct models optimistic
   vs. pessimistic locking?

5. **System boundary contracts** — how does a `system` declaration express its
   external API so that two systems can be composed safely across bounded-context
   boundaries?

6. **Library evolution** — when a LIBRARY contract's signature changes, what
   migration rules preserve the correctness of all dependent SYSTEM contracts?
