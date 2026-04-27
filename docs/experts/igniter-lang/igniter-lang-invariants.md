# Igniter Contract Language — Invariants as First-Class Contracts

Date: 2026-04-27.
Status: ★ FRONTIER — current peak of the research track.
Priority: HIGH — this vector unlocks compiler-as-verifier and formal enterprise guarantees.
Scope: invariant model, invariant algebra, Hoare logic propagation, compiler verification path, POC roadmap.

*Builds on: [igniter-lang-algebra.md](igniter-lang-algebra.md) ·
[igniter-lang-spec.md](igniter-lang-spec.md) ·
[igniter-lang-theory2.md](igniter-lang-theory2.md)*

---

## § 0. The Core Insight

A `guard` node is local: it checks a condition once, during one contract execution.
An **invariant** is universal: it is a property that must hold across **all instances**
of a type and **all transitions** of an entity's state.

If guards are local contracts, invariants are **global contracts** — and they are
the key to making the language a lightweight formal verifier rather than just a
type-safe runtime.

```
-- Guard: checked once, in this contract execution
guard :within_budget {
  total <= manager.approval_limit
}

-- Invariant: must hold for every Account, everywhere, always
invariant PositiveBalance : Account {
  balance >= 0
}
```

The difference is the **scope of quantification**: guard = existential (this run),
invariant = universal (all instances, all time).

---

## § 1. Invariants as Contracts

### § 1.1 The Invariant Contract Form

An invariant over type `T` with predicate `P` is a contract:

```
Contract({ x: T }) → { verified: T where P(x) }
```

It takes a value of type `T`, asserts `P`, and returns the **refined type**
`T where P`. The output type is stronger than the input type.

Concrete expansion:

```
invariant PositiveBalance : Account {
  balance >= 0
}

-- Expands to:
contract PositiveBalance {
  in  account: Account
  guard :check { account.balance >= 0 }
  out  verified: Account where balance >= 0 = account
}
```

The output is not just `Account` — it is `Account where balance >= 0`. The
invariant acts as a **coercion from `T` to `T where P`** — a type-narrowing
operation with a runtime check.

### § 1.2 Invariant Declaration Syntax

```
invariant_decl ::=
  'invariant' IDENT ':' type_name '{' {invariant_clause} '}'

invariant_clause ::=
  | expr                            -- predicate
  | IDENT ':' expr                  -- named predicate
  | 'when' expr '{' {expr} '}'     -- conditional predicate
  | 'on' SYMBOL '{' {expr} '}'     -- lifecycle-state-specific predicate
```

**Examples:**

```
invariant PositiveBalance : Account {
  balance >= 0
}

invariant ValidOrder : Order {
  items.count > 0
  total >= 0
  total == sum(items |> map { .price * .qty })    -- cross-field consistency
}

invariant ShippedOrder : Order {
  when status == :shipped {
    shipped_at != null
    tracking_number != null
  }
  on :cancelled {
    cancelled_at != null
    refund_issued == true
  }
}
```

---

## § 2. The Invariant Algebra

### § 2.1 Operations

Invariants are first-class values. The following operations are defined:

```
-- Conjunction (strengthening): both must hold
inv_a ∧ inv_b

-- Disjunction (weakening): at least one must hold  
inv_a ∨ inv_b

-- Implication: if inv_a holds, inv_b holds
inv_a → inv_b

-- Parametrisation: family of invariants
inv(param: type)

-- Conditional activation
inv when condition

-- Lifecycle scope: active only in named states
inv on [:state_a, :state_b]
```

### § 2.2 The Invariant Lattice

Invariants over a type `T` form a **bounded lattice**:

```
          True  (no constraint — every value passes)
            │
         inv_a
        /       \
    inv_a ∨ inv_b  ...
        \       /
         inv_b
            │
    inv_a ∧ inv_b  (both must hold — more restrictive)
            │
         False  (no value can satisfy — dead type)
```

Partial order: `inv_a ≤ inv_b` iff predicate of `a` implies predicate of `b`.
Stronger invariant = lower in the invariant lattice = higher specificity.

The lattice is a **Galois connection** between the set of values satisfying
an invariant and the invariant predicate: adding constraints shrinks the
satisfying set monotonically.

### § 2.3 Invariant Arithmetic

```
-- Weakening: remove a conjunct (more values pass)
ValidOrder ∧ InStock  →  ValidOrder

-- Strengthening: add a conjunct (fewer values pass)
ValidOrder  →  ValidOrder ∧ InStock

-- Composition: check both invariants in sequence
PositiveBalance >> ValidLimit    -- equivalent to PositiveBalance ∧ ValidLimit

-- Parametric family
invariant WithinLimit(limit: Money) : Order {
  total <= limit
}

-- Specialisation: fix parameter
WithinLimit(10_000)   -- concrete invariant
```

---

## § 3. Invariants ARE Refinement Types

### § 3.1 The Formal Identity

An invariant declaration is syntactic sugar for a **refinement type alias**:

```
invariant P on T  ≡  type T_P = T where P
```

Operations on invariants are operations on the refinement type lattice:

| Invariant operation | Refinement type operation | Subtyping direction |
|---------------------|--------------------------|---------------------|
| `inv_a ∧ inv_b` | `{ x: T \| P_a(x) ∧ P_b(x) }` | subtype of both |
| `inv_a ∨ inv_b` | `{ x: T \| P_a(x) ∨ P_b(x) }` | supertype of both |
| Weakening | Drop conjunct from predicate | `T_PQ ⊑ T_P` |
| Strengthening | Add conjunct | `T_P ⊑ T_PQ` would be wrong — `T_PQ ⊑ T_P` |

The subtyping rule:

```
P(x) ∧ Q(x) → P(x)   for all x
─────────────────────────────────────────────────
{ x: T | P(x) ∧ Q(x) } ⊑ { x: T | P(x) }
```

This is the **refinement weakening** rule from §1.4 of the language spec — now
shown to be the algebraic weakening operation on the invariant lattice.

### § 3.2 Connection to Liquid Types

This model is formally equivalent to **Liquid Types** (Rondon, Kawaguchi, Jhala 2008):
refinement types where predicates are drawn from a restricted logical fragment
(qualifiers), allowing decidable type checking via SMT solving.

The key boundary: the Horn-fragment predicates used in the contract model
(linear arithmetic, structural field access, no universal quantification) are
precisely the qualifiers that Liquid Type inference handles in polynomial time.

This means: **invariant checking in the contract model is decidable in PTIME**
for the Horn fragment — no SMT solver required for the common case, only for
user-defined numeric properties at the boundary.

---

## § 4. Hoare Logic and Invariant Propagation

### § 4.1 Invariants as Pre/Postconditions

Hoare triples `{P} C {Q}` (precondition P, command C, postcondition Q) map
directly to contract nodes:

```
-- Precondition: what must hold on the input
guard :pre { account.balance >= 0 }     -- or: declared invariant on input type

-- Command: the computation
compute :new_balance = account.balance - withdrawal

-- Postcondition: what must hold on the output
out result: Account where balance >= 0  -- or: declared invariant on output type
```

The contract compiler verifies the Hoare triple: given the input invariant and
the computation, does the output type satisfy the declared invariant?

### § 4.2 Sequential Composition and Weakest Preconditions

For sequential composition `A >> B`:

```
wp(B, Q) = weakest precondition of B's input such that Q holds on B's output
wp(A >> B, Q) = wp(A, wp(B, Q))
```

In contract terms:
- `A` produces output type `τ_A`
- `B` requires input type `τ_B`
- Composition is safe iff `τ_A ⊑ τ_B`

The compiler checks: does `A`'s output invariant imply `B`'s input invariant?

```
A outputs:  Account where balance >= 0
B requires: Account where balance >= 0 ∧ balance <= credit_limit

-- UNSAFE: A's guarantee is weaker than B's requirement
-- Compiler error: "invariant gap — A guarantees PositiveBalance,
--                  B requires PositiveBalance ∧ WithinLimit"
```

### § 4.3 Workflow Invariant Preservation

```
workflow Fulfillment {
  steps:     [ValidateOrder, ReserveInventory, ChargePayment, Ship]
  preserves: [ValidOrder, PositiveInventory]
  establishes: [PaymentReceived, TrackingAssigned]
}
```

The `preserves` declaration is a **proof obligation**: the compiler verifies
that for each step `S`, if the preserved invariants hold before `S`, they hold
after `S`.

The `establishes` declaration is a **postcondition**: at workflow completion,
these additional invariants hold.

Verification algorithm (PTIME for Horn fragment):
1. Assume `preserves` invariants hold at workflow entry
2. For each step, compute the wp-propagated invariant set
3. At each step's output, check the preserved invariants hold
4. At workflow exit, check `establishes` invariants hold
5. Emit diagnostic with the first step that breaks an invariant

---

## § 5. Enterprise Invariant Patterns

### § 5.1 Static Invariants

Properties that must hold for every value of the type, at all times:

```
invariant ValidProduct : Product {
  price > 0
  stock >= 0
  name.length > 0
}

invariant ValidCustomer : Customer {
  email.contains("@")
  credit_limit >= 0
  status in [:active, :suspended, :closed]
}
```

### § 5.2 Lifecycle Invariants

Properties that must hold in specific entity states:

```
invariant OrderLifecycle : Order {
  on :processing {
    reserved_at != null
    inventory_reserved == true
  }
  on :complete {
    payment_received == true
    shipped_at != null
    tracking_number != null
  }
  on :cancelled {
    cancelled_at != null
    cancellation_reason != null
    when total > 0 { refund_issued == true }
  }
}
```

### § 5.3 Cross-Entity Invariants (System-Level)

Properties that span multiple entities — the most powerful kind:

```
invariant OrderConsistency {
  order.total == sum(order.items |> map { .price * .qty })
  order.customer.credit_used >= order.total when order.payment_method == :credit
}

invariant InventoryConsistency {
  product.stock == product.initial_stock
                 - sum(fulfilled_orders |> map { .qty })
                 + sum(received_shipments |> map { .qty })
}
```

Cross-entity invariants cannot be checked locally — they require the system
declaration to scope them:

```
system OrderManagement {
  invariants: [OrderConsistency, InventoryConsistency]
  -- compiler verifies these at every contract boundary in the system
}
```

### § 5.4 Safety and Liveness (Classic Formal Properties)

The invariant model connects directly to classical formal verification properties:

| Formal property | Contract invariant form |
|----------------|------------------------|
| **Safety** (`□ ¬bad`) | `invariant NeverBad : T { not bad_condition }` |
| **Liveness** (`◇ good`) | `workflow W { establishes: GoodCondition }` |
| **Preservation** | `workflow W { preserves: [inv_a, inv_b] }` |
| **Progress** | `entity E { lifecycle: must_reach [:complete, :cancelled] }` |

---

## § 6. Compiler as Verifier

### § 6.1 What the Compiler Can Verify Statically

With invariants as first-class + the algebra + Hoare logic propagation,
the compiler verifies:

| Check | Technique | Complexity |
|-------|-----------|------------|
| Invariant consistency | Satisfiability of predicate (no `False` type) | PTIME (Horn) |
| Invariant preservation at compose | `τ_out ⊑ τ_in` at each `compose` edge | PTIME |
| Workflow preservation | wp-propagation through step sequence | PTIME |
| Guard-invariant alignment | Guard predicate ⊆ required invariant | PTIME |
| Cross-entity consistency | Datalog fixpoint over entity graph | PTIME |
| Lifecycle completeness | Branch coverage of lifecycle states | PTIME |

All checks are PTIME for the Horn fragment. This is a **formal verifier, not
a type checker** — it proves semantic properties, not just syntactic ones. And
it is fast enough to run on every compile.

### § 6.2 The PTIME Guarantee

From [igniter-lang-theory2.md](igniter-lang-theory2.md), Theorem 2.1: synthesis
in the Horn fragment is PTIME. Invariant checking is synthesis in reverse —
given a contract and an invariant, check if the contract preserves it.

Formally: invariant preservation checking reduces to Datalog bottom-up
evaluation + the Farkas lemma for linear arithmetic (no SMT required for
linear predicates). The combined procedure is in PTIME.

This means the compiler can **prove** enterprise-level properties in the same
time it takes to type-check — with no interactive theorem proving required
from the user.

### § 6.3 The Verification Gradient

The system supports a gradient from "light checks" to "full verification":

```
Level 0  -- no invariants declared: runtime errors only (current Igniter)
Level 1  -- invariants declared, checked at runtime: catch violations
Level 2  -- invariants + guard alignment: static check at compose points
Level 3  -- invariants + workflow preserves: PTIME formal verification
Level 4  -- cross-entity invariants + system: full system verification
```

Users opt into the level they need. Enterprise teams can adopt gradually.

---

## § 7. Towards POC

### § 7.1 Iteration 1: Strengthen the Model

Research tasks before implementation:
1. **Invariant quantifier depth** — which predicate fragments stay in PTIME?
   (Linear arithmetic: yes. Polynomial: borderline. Universal quantification: no.)
2. **Cross-entity invariant scope** — how does the system declaration bound the
   verification domain?
3. **Invariant inheritance** — when `entity Child : Parent`, what are the
   inheritance rules for invariants?
4. **Parametric invariants** — `inv(param)` — how does parametrisation interact
   with the lattice structure?
5. **Approximate invariants** — `~inv` — invariant over `~T` (probabilistic
   satisfaction, confidence bound)?

### § 7.2 Iteration 2: POC Design

Minimal implementation surface:
```
-- DSL additions:
invariant NAME : TYPE { ... }         -- declaration
workflow W { preserves: [...] }        -- preservation obligation
compose :x = C { ... }                -- checked at compose edge (τ_out ⊑ τ_in)
system S { invariants: [...] }         -- system-wide scope

-- Compiler additions:
- Invariant registry (name → predicate)
- Refinement type representation (T where P)
- Subtype check at compose edges
- wp-propagation for workflow steps
- Diagnostic: "invariant gap at step 3: P is not implied by Q"
```

### § 7.3 Iteration 3: POC Implementation (Ruby)

Target: extend the existing Igniter compiler with:
1. `invariant` DSL keyword → creates a named `InvariantNode` in the model
2. Refinement type representation in `CompiledGraph`
3. `SubtypeChecker` — checks `τ_out ⊑ τ_in` at each `compose` edge
4. `WorkflowVerifier` — wp-propagation for `preserves` obligations
5. Diagnostic report extension — invariant violation reports with proof trace

Smoke test target: the `FulfillOrder`/`ProcessOrder` example with explicit
invariants on `Order`, `Account`, and `Product` — verified by the compiler with
no runtime failures.

---

## § 8. Open Questions

1. **Negative invariants** — can an invariant assert the *absence* of a property
   (`account.frozen == false`)? How does this interact with the monotonicity of
   the CCP model?

2. **Temporal invariants** — `inv always` vs. `inv eventually` — does the
   contract model need a linear temporal logic layer, or is lifecycle-scoped
   invariants sufficient?

3. **Invariant conflict detection** — if two invariants in the same system are
   mutually inconsistent (`balance > 0` and `balance < 0`), can the compiler
   detect this without exhaustive search?

4. **Probabilistic invariants** — `~inv` with confidence `0.95` — for `~T`
   nodes where exact invariant checking is too expensive, can approximate
   invariant satisfaction be propagated?

5. **Invariant-guided synthesis** — given a set of invariants and a goal
   predicate, can the property model synthesiser generate a contract that
   provably achieves the goal while preserving all invariants?
   This would close the loop: **declare invariants + goal → get verified contract**.
