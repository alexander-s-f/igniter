# Igniter Contract Language — Language Specification v0.1

Date: 2026-04-27.
Status: draft specification — not yet implemented.
Scope: type system, primitive constructs, contract model, annotation system.

*Theoretical basis: [igniter-lang-theory.md](igniter-lang-theory.md) and [igniter-lang-theory2.md](igniter-lang-theory2.md)*

---

## § 0. Notation

```
::=    definition
|      alternative
[x]    zero or one occurrence of x
{x}    zero or more occurrences of x
(x)    grouping
UPPER  terminal token
lower  non-terminal
'x'    literal keyword
⊢      entails / type-checks as
→      maps to / function type
⊑      subtype of
```

---

## § 1. Type System

### § 1.1 Primitive Types

```
prim ::=
  | 'Bool'                     -- true | false
  | 'Int'                      -- arbitrary precision integer
  | 'Float'                    -- IEEE 754 double
  | 'String'                   -- UTF-8 text
  | 'Symbol'                   -- interned atom,   e.g. :pending
  | 'DateTime'                 -- timezone-aware instant
  | 'Date'                     -- calendar date
  | 'Duration'                 -- time span
  | 'Money'                    -- decimal + currency code
  | 'Id'                       -- opaque identifier (UUID / integer)
  | 'Json'                     -- untyped JSON value
  | 'Bytes'                    -- raw byte sequence
  | 'Null'                     -- the absent value (bottom of Option)
```

`Money` is a first-class primitive (not `Float`). Arithmetic on `Money` is
exact decimal; mixed-currency operations are a type error.

### § 1.2 Compound Types

```
type_expr ::=
  | prim                                   -- primitive
  | IDENT                                  -- named type
  | '{' {field_decl ','} '}'              -- record (anonymous)
  | 'Enum' '[' {SYMBOL ','} ']'           -- enumeration
  | '[' type_expr ']'                      -- list (ordered, homogeneous)
  | '{' type_expr '}'                      -- set (unordered, unique)
  | type_expr '?'                          -- option  (T? = Option[T])
  | type_expr 'where' predicate            -- refinement
  | '~' type_expr                          -- approximate value
  | type_expr '→' type_expr               -- function
  | 'Contract' '(' type_expr ')' '→' type_expr  -- contract signature

field_decl ::= IDENT ':' type_expr ['=' expr]
```

### § 1.3 Type Declarations

```
type_decl ::=
  | 'type' IDENT '=' type_expr                          -- alias
  | 'type' IDENT '{' {field_decl} '}'                   -- record
  | 'type' IDENT '=' IDENT 'where' predicate            -- refinement alias
```

**Examples:**

```
type OrderStatus = Enum[:pending, :processing, :complete, :cancelled]

type Product {
  id:        Id
  name:      String
  available: Bool
  stock:     Int where stock >= 0
  price:     Money where price > 0
  category:  Enum[:physical, :digital]
}

type Manager {
  id:             Id
  approved:       Bool
  approval_limit: Money where approval_limit > 0
}

type AvailableProduct = Product where available = true && stock > 0
type ApprovedManager  = Manager  where approved = true
```

### § 1.4 Subtyping Rules

```
─────────────────
τ ⊑ τ                                  (reflexivity)

τ₁ ⊑ τ₂   τ₂ ⊑ τ₃
──────────────────
τ₁ ⊑ τ₃                                (transitivity)

{ x: τ | P(x) ∧ Q(x) } ⊑ { x: τ | P(x) }   (refinement weakening)

{ x: τ | P(x) } ⊑ τ                   (refinement erasure)

τ ⊑ τ?                                 (injection into option)

τ₁ ⊑ τ₂
──────────────────
[τ₁] ⊑ [τ₂]                            (list covariance)

τ₁ ⊑ τ₂
──────────────────
τ₁? ⊑ τ₂?                              (option covariance)

{ l₁: τ₁, l₂: τ₂, l₃: τ₃ } ⊑ { l₁: τ₁, l₂: τ₂ }   (record width)

τ₁' ⊑ τ₁   τ₂ ⊑ τ₂'
──────────────────────────────────────
(τ₁ → τ₂) ⊑ (τ₁' → τ₂')              (function contra/covariance)
```

### § 1.5 The Approximate Type `~T`

`~T` (read: "approximately T") represents a value of type `T` known only up
to a confidence interval. It is produced by `@approximate` nodes and consumed
by downstream nodes that declare `@tolerance`.

```
~T carries:  { value: T, lo: T, hi: T, confidence: Float }
```

Subtyping: `T ⊑ ~T` (exact value is a degenerate approximate with lo = hi = value).

Operations on `~T`:
- Arithmetic operators are lifted: `~T + ~T → ~T` (interval arithmetic)
- Comparison `~T > literal` → `Bool | Uncertain` (three-valued)
- `.exact` coercion: forces exact evaluation, type becomes `T`

### § 1.6 Effect Labels

Every expression carries an effect label set:

```
ε ::= ∅          -- pure
    | IO          -- reads/writes external state
    | Cache       -- reads/writes node cache
    | Rand        -- non-deterministic (sampling)
    | Fail        -- may raise an error
    | ε₁ ∪ ε₂    -- union
```

Function type with effects: `τ₁ →[ε] τ₂`

Pure functions: `τ₁ →[∅] τ₂` (abbreviated `τ₁ → τ₂`)

Compute nodes with `IO` effect are marked `@effect` and execute after all
pure nodes in the same stratum.

---

## § 2. Expressions

### § 2.1 Expression Grammar

```
expr ::=
  | literal                              -- Bool, Int, Float, String, Symbol
  | path                                 -- node_name | node_name.field
  | IDENT '(' {expr ','} ')'            -- function call
  | expr '|>' expr                       -- pipe (left-associative)
  | expr 'op' expr                       -- infix (arithmetic, comparison, logic)
  | 'if' expr 'then' expr 'else' expr   -- conditional
  | '{' {stmt} expr '}'                  -- block (last expr is the value)
  | '[' {expr ','} ']'                   -- list literal
  | IDENT '{' {IDENT ':' expr ','} '}'  -- record construction
  | expr '.' IDENT                       -- field access
  | expr '?.' IDENT                      -- safe field access (Option)
  | '~' expr                             -- approximate lift
  | expr '@exact'                        -- force exact evaluation
  | IDENT '{' {mapping} '}'             -- contract call (inline compose)

literal ::= BOOL | INT | FLOAT | STRING | SYMBOL | NULL
path    ::= IDENT {'.' IDENT}
mapping ::= IDENT ':' expr
```

### § 2.2 The Pipe Operator

`a |> f` is syntactic sugar for `f(a)`.
`a |> f(x, y)` is syntactic sugar for `f(a, x, y)` (partial application left).

Pipes chain without intermediate names:

```
compute :result =
  raw_data
  |> validate
  |> normalize
  |> transform(config)
  |> classify
```

### § 2.3 Block Expressions

A block introduces local bindings visible only within the block:

```
compute :total = {
  let subtotal = sum(items |> map { |i| i.price * i.qty })
  let discount = if coupon.active then subtotal * coupon.rate else 0
  subtotal - discount
}
```

`let` bindings are immutable and not visible outside the block.

---

## § 3. Contract Constructs

### § 3.1 Contract Declaration

```
contract_decl ::=
  'contract' IDENT [':' IDENT] '{' {node_decl} '}'
```

The optional `: IDENT` names a parent contract to extend.
Extending a contract inherits all nodes and may add new ones or refine guards.

```
contract PriceQuote {
  in vendor_id: Id
  in zip_code:  Zip
  ...
}

contract UrgentPriceQuote : PriceQuote {
  // inherits vendor_id, zip_code
  in deadline:  DateTime       // adds a new input
  guard :not_expired { deadline > now() }
}
```

### § 3.2 `in` — Input Node

```
in_node ::= 'in' IDENT ':' type_expr ['=' expr]
```

Declares a named input value. The optional `= expr` is the **default
expression**, evaluated lazily if the caller does not provide the input.
The default expression may reference other `in` nodes.

**Type rule:**
```
─────────────────────────────────────────────────────
Γ ⊢ (in :a : τ) : Γ ∪ { a : τ }
```

**Examples:**
```
in vendor_id:   Id
in zip_code:    Zip
in as_of:       DateTime = now()
in max_results: Int where max_results > 0 = 100
```

### § 3.3 `compute` — Computation Node

```
compute_node ::=
  'compute' IDENT [':' type_expr] '=' expr {annotation}
```

Declares a named computed value. Dependencies are **inferred** from the free
variables of `expr` that refer to other nodes in the contract.

**Type rule:**
```
Γ ⊢ expr : τ   [τ_ann ⊑ τ if annotation present]
──────────────────────────────────────────────────
Γ ⊢ (compute :y = expr) : Γ ∪ { y : τ }
```

**Examples:**
```
compute :vendor  = fetch_vendor(vendor_id)
compute :slots   = vendor.slots |> select { |s| s.zip == zip_code && s.available }
compute :count   = slots |> count
compute :subtotal: Money = items |> sum { |i| i.price * i.qty }
```

**Purity**: A `compute` node is pure by default. If the expression has an `IO`
effect, the node must be annotated `@effect`.

### § 3.4 `const` — Compile-Time Constant

```
const_node ::= 'const' IDENT '=' literal
```

Evaluated at compile time. No dependencies. Equivalent to `compute` on a
literal but the compiler verifies the value is constant.

```
const :tax_rate    = 0.20
const :max_retries = 3
const :default_tz  = :UTC
```

### § 3.5 `guard` — Constraint Node

```
guard_node ::=
  'guard' IDENT '{' guard_body '}'

guard_body ::=
  ['when' expr]
  {guard_clause}
  ['on_fail' ':' SYMBOL]

guard_clause ::=
  | expr                          -- predicate (must be true)
  | IDENT 'must' 'be' expr        -- named assertion
  | IDENT 'in' expr               -- membership assertion
```

A guard asserts conditions that must hold for the contract to proceed.
If a condition fails, the contract raises an error of the declared type
(default: `:guard_violation`).

`when:` makes the guard conditional — it only activates when the `when`
expression is true.

**Type rule:**
```
Γ ⊢ cond : Bool   (for each clause)
Γ ⊢ when_expr : Bool   (if present)
────────────────────────────────────────────────
Γ ⊢ (guard :g { ... }) : Γ   -- guard does not introduce a new binding
                               -- but refines the types of checked nodes
```

**Refinement effect**: A guard that checks `x.available = true` refines the
type of `x` from `Product` to `AvailableProduct` in nodes that depend on `:g`.

**Examples:**
```
guard :product_ok {
  product.available = true
  product.stock > 0
  on_fail: :out_of_stock
}

guard :discount_consistent {
  when marketing.campaign_active
  marketing.discount_applied must be true
}

guard :within_budget {
  total <= manager.approval_limit
  on_fail: :approval_limit_exceeded
}
```

### § 3.6 `branch` — Conditional Dispatch

```
branch_node ::=
  'branch' IDENT '{' {branch_arm} [default_arm] '}'

branch_arm ::=
  'on' expr '=>' (expr | inline_contract)

default_arm ::=
  'default' '=>' (expr | inline_contract)

inline_contract ::=
  IDENT '{' {mapping} '}'
```

A branch selects exactly one arm. Arms are tested top-to-bottom; the first
matching arm is selected. A `default` arm is required when the arms do not
cover all possible values.

**Type rule:**
```
Γ ⊢ c₁ : Bool  Γ ⊢ e₁ : τ
...
Γ ⊢ cₙ : Bool  Γ ⊢ eₙ : τ
Γ ⊢ e_default : τ
────────────────────────────────────────────────────
Γ ⊢ (branch :b { on c₁ => e₁; ...; default => e_d })
  : Γ ∪ { b : τ }
```

All arms must have the same result type `τ`. If they return sub-contracts,
all sub-contract output types must be compatible (structurally).

**Examples:**
```
branch :routing {
  on order.total > 10_000 => HighValueFlow { order: order }
  on order.type == :digital => DigitalFlow  { order: order }
  default                   => StandardFlow { order: order }
}

branch :slot_result {
  on slots.count > 0 => slots.first
  default            => Null
}
```

### § 3.7 `compose` — Sub-Contract Embedding

```
compose_node ::=
  'compose' IDENT '=' IDENT '{' {mapping} '}'

mapping ::= IDENT ':' expr
```

Embeds a named contract. The `{ }` block maps current-context expressions to
the sub-contract's input nodes. The compose node's value is the sub-contract's
output record.

**Type rule:**
```
C : Contract({ a: τ_a, b: τ_b }) → { x: τ_x, y: τ_y }
Γ ⊢ expr_a : τ_a'   τ_a' ⊑ τ_a
Γ ⊢ expr_b : τ_b'   τ_b' ⊑ τ_b
────────────────────────────────────────────────────────
Γ ⊢ (compose :sub = C { a: expr_a, b: expr_b })
  : Γ ∪ { sub: { x: τ_x, y: τ_y } }
```

Fields of the composed output are accessed as `sub.x`, `sub.y`.

**Example:**
```
compose :pricing  = PriceQuote {
  vendor_id: order.vendor_id
  zip_code:  order.shipping_zip
}

compute :final_price = pricing.quote.total
```

### § 3.8 `collection` — Functor over a List

```
collection_node ::=
  'collection' IDENT '='
    ('map' '(' expr ',' IDENT ')' |          -- apply contract to each
     expr '|>' 'select' block    |           -- filter
     expr '|>' 'map' block)                  -- transform
    {annotation}
```

Applies a contract or function to each element of a list.

**Type rule:**
```
Γ ⊢ source : [τ_elem]
C : Contract({ input: τ_elem }) → τ_out
────────────────────────────────────────────────
Γ ⊢ (collection :ys = map(source, C))
  : Γ ∪ { ys : [τ_out] }
```

**Examples:**
```
collection :quoted_items = map(order.items, ItemQuote)

collection :available_slots =
  vendor.slots |> select { |s| s.available && s.zip == zip_code }
```

### § 3.9 `aggregate` — Fold over a List

```
aggregate_node ::=
  'aggregate' IDENT '='
    (agg_op '(' expr ')'                     -- built-in aggregation
    | expr '|>' 'fold' '(' expr ',' fn ')')  -- custom fold

agg_op ::= 'count' | 'sum' | 'avg' | 'min' | 'max' | 'group_by'
```

**Type rules:**
```
Γ ⊢ source : [τ]
──────────────────────────────────────────────────────────────
Γ ⊢ (aggregate :n = count(source))    : Γ ∪ { n : Int }
Γ ⊢ (aggregate :s = sum(source))      : Γ ∪ { s : τ }      -- τ numeric
Γ ⊢ (aggregate :a = avg(source))      : Γ ∪ { a : Float }

Γ ⊢ source : [τ]
Γ ⊢ init : τ_acc
Γ ⊢ fn : (τ_acc, τ) → τ_acc
──────────────────────────────────────────────────────────────
Γ ⊢ (aggregate :r = source |> fold(init, fn)) : Γ ∪ { r : τ_acc }
```

**Examples:**
```
aggregate :total_value = sum(items |> map { |i| i.price * i.qty })
aggregate :item_count  = count(items)
aggregate :by_category = group_by(items, :category)
```

### § 3.10 `effect` — Side Effect Node

```
effect_node ::=
  'effect' IDENT '=' IDENT '{' {mapping} '}' {effect_annotation}

effect_annotation ::=
  | '@idempotent'
  | '@compensate' ':' IDENT
  | '@on_success' ':' IDENT
```

Executes a registered effect (IO, external call, event emission). Effects
run after all pure nodes in the same stratum. Effect nodes do not contribute
a computed value by default (their result is `Unit` unless the effect
returns a value, in which case the type is declared).

```
effect :send_confirmation =
  EmailEffect {
    to:      customer.email
    subject: "Order #{order.id} confirmed"
    body:    render_template(:order_confirmed, order: order)
  }
  @idempotent
  @compensate: CancelEmailEffect
```

### § 3.11 `await` — Distributed Event Suspension

```
await_node ::=
  'await' IDENT ',' 'event' ':' SYMBOL
  [',' 'timeout' ':' duration_expr]
  [',' 'payload' ':' type_expr]
```

Suspends contract execution until a named event arrives (distributed
workflow). The contract persists its state; execution resumes when the
event is delivered via `Contract.deliver_event`.

```
await :payment_confirmed, event: :payment_received,
                          timeout: 24.hours,
                          payload: PaymentPayload
```

### § 3.12 `out` — Output Declaration

```
out_node ::= 'out' IDENT [':' type_expr] '=' expr
```

Declares a named output value. Multiple `out` nodes define the contract's
output record type. The compiler verifies all `out` types are consistent.

**Type rule:**
```
Γ ⊢ expr : τ   [τ_ann ⊑ τ if annotation present]
─────────────────────────────────────────────────────────────
Γ ⊢ (out :x = expr) contributes { x: τ } to contract outputs
```

**Examples:**
```
out quote:  Quote  = pricing.quote
out vendor: Vendor = vendor
out status: OrderStatus = order_status
```

---

## § 4. Contract Signature and Composition

### § 4.1 Contract Signature

A contract's **signature** is inferred from its `in` and `out` declarations:

```
contract Foo {
  in a: A
  in b: B
  ...
  out x: X = ...
  out y: Y = ...
}
```

Signature: `Foo : Contract({ a: A, b: B }) → { x: X, y: Y }`

The signature is the type of the contract as a value. It can be used in
`compose`, `collection`, and `branch` to verify compatibility at compile time.

### § 4.2 Contract as a Value

Contracts are first-class values. A contract name used as an expression has
the type `Contract(I) → O`. This allows:

```
fn choose_strategy(order: Order) -> Contract({order: Order}) → {result: Result} =
  if order.total > 10_000 then HighValueStrategy else StandardStrategy

compose :result = choose_strategy(order) { order: order }
```

### § 4.3 Composition Laws

Let `A : Contract(I_A) → O_A` and `B : Contract(I_B) → O_B` where `O_B ⊇ I_A`
(B's outputs include all of A's inputs):

```
(A after B) : Contract(I_B) → O_A
```

Sequential composition is associative:
```
(A after B) after C = A after (B after C)
```

Identity contract:
```
id[τ] : Contract(τ) → τ    -- passes all inputs directly to outputs
```

---

## § 5. Annotation System

Annotations modify the behaviour of nodes without changing their types.
All annotations begin with `@`.

### § 5.1 Caching Annotations

```
@cache(ttl)          -- cache the node result for `ttl` duration
@cache(:forever)     -- cache until explicitly invalidated
@coalesce            -- deduplicate concurrent requests for the same inputs
@fingerprint         -- use content-based cache key (for mutable inputs)
```

`ttl` is a `Duration` literal: `60s`, `5min`, `1h`, `1d`.

These annotations apply to `compute` nodes only. The cache key is derived
from the node name and the values of all declared dependencies.

### § 5.2 Approximate Computation Annotations

```
@approximate(method: :monte_carlo, samples: 1_000)
@approximate(method: :interval)
@approximate(method: :delta)
@confidence(0.95)          -- minimum required confidence
@tolerance(0.01)           -- maximum acceptable relative error (1%)
```

Applied to `compute` nodes to declare an approximate evaluation strategy.
A node with `@approximate` has type `~T` (where `T` is the exact type).

Downstream nodes declare their precision requirement:
```
@exact                     -- require full computation of upstream
@tolerance(0.05)           -- accept approximation within 5%
```

### § 5.3 Execution Annotations

```
@parallel             -- hint: this node may run concurrently with siblings
@sequential           -- hint: this node should not run concurrently
@timeout(duration)    -- fail if not resolved within duration
@retry(n)             -- retry on transient failure, up to n times
@fallback(expr)       -- if this node fails, use expr instead
```

### § 5.4 Introspection and Observability

```
@trace                -- emit a trace event when this node is resolved
@audit                -- include this node in the audit log
@label("description") -- human-readable description for tooling
```

---

## § 6. Function Declarations

Functions are named reusable expressions. They are not contracts — they have
no dependency graph, no caching, no effects. They are compiled to ordinary
functions in the target runtime.

```
fn_decl ::=
  'fn' IDENT '(' {param ','} ')' ['->' type_expr] '=' expr

param ::= IDENT ':' type_expr
```

**Type rule:**
```
x₁: τ₁, ..., xₙ: τₙ ⊢ body : τ_ret
────────────────────────────────────────────────────────
⊢ fn f(x₁: τ₁, ..., xₙ: τₙ) -> τ_ret = body
  : τ₁ → ... → τₙ → τ_ret
```

**Examples:**
```
fn effective_price(price: Money, discount: Float) -> Money =
  price * (1.0 - discount)

fn classify_risk(score: Float) -> Symbol =
  if score > 0.8 then :high
  else if score > 0.5 then :medium
  else :low

fn ~estimate_revenue(summary: SampleSummary, rate: Float) -> ~Money =
  summary.mean * rate
  @confidence(0.95) @method(:delta)
```

The `~` prefix on a function name declares the approximate lifting of a
corresponding exact function (see pre-computation document).

---

## § 7. Complete Grammar

```
program ::= {declaration}

declaration ::=
  | type_decl
  | fn_decl
  | contract_decl
  | model_decl           -- property model (synthesis; see propmodel spec)

-- Types
type_decl ::=
  | 'type' IDENT '=' type_expr
  | 'type' IDENT '{' {field_decl} '}'
  | 'type' IDENT '=' IDENT 'where' predicate

field_decl ::= IDENT ':' type_expr ['=' expr]

type_expr ::=
  | IDENT
  | '{' {field_decl ','} '}'
  | 'Enum' '[' {SYMBOL ','} ']'
  | '[' type_expr ']'
  | '{' type_expr '}'
  | type_expr '?'
  | type_expr 'where' predicate
  | '~' type_expr
  | type_expr '→' type_expr
  | 'Contract' '(' type_expr ')' '→' type_expr

-- Functions
fn_decl ::=
  ['~'] 'fn' IDENT '(' {param ','} ')' ['->' type_expr] '=' expr

param ::= IDENT ':' type_expr

-- Contracts
contract_decl ::=
  'contract' IDENT [':' IDENT] '{' {node_decl} '}'

node_decl ::=
  | 'in'         IDENT ':' type_expr ['=' expr]
  | 'const'      IDENT '=' literal
  | 'compute'    IDENT [':' type_expr] '=' expr {annotation}
  | 'guard'      IDENT '{' guard_body '}'
  | 'branch'     IDENT '{' {branch_arm} [default_arm] '}'
  | 'compose'    IDENT '=' IDENT '{' {mapping} '}'
  | 'collection' IDENT '=' collection_expr {annotation}
  | 'aggregate'  IDENT '=' aggregate_expr
  | 'effect'     IDENT '=' IDENT '{' {mapping} '}' {effect_annotation}
  | 'await'      IDENT ',' 'event' ':' SYMBOL {await_option}
  | 'out'        IDENT [':' type_expr] '=' expr

guard_body ::=
  ['when' expr]
  {expr | IDENT 'must' 'be' expr | IDENT 'in' expr}
  ['on_fail' ':' SYMBOL]

branch_arm ::= 'on' expr '=>' (expr | IDENT '{' {mapping} '}')
default_arm ::= 'default' '=>' (expr | IDENT '{' {mapping} '}')

collection_expr ::=
  | 'map' '(' expr ',' IDENT ')'
  | expr '|>' 'select' block
  | expr '|>' 'map' block

aggregate_expr ::=
  | ('count' | 'sum' | 'avg' | 'min' | 'max') '(' expr ')'
  | 'group_by' '(' expr ',' SYMBOL ')'
  | expr '|>' 'fold' '(' expr ',' fn_expr ')'

mapping     ::= IDENT ':' expr
annotation  ::= '@' IDENT ['(' {arg ','} ')']

-- Expressions
expr ::=
  | literal
  | IDENT
  | expr '.' IDENT
  | expr '?.' IDENT
  | IDENT '(' {expr ','} ')'
  | IDENT '{' {mapping} '}'
  | expr '|>' expr
  | expr op expr
  | 'if' expr 'then' expr 'else' expr
  | '{' {('let' IDENT '=' expr)} expr '}'
  | '[' {expr ','} ']'
  | '~' expr
  | expr '@exact'
  | 'fn' '(' {param ','} ')' '=>' expr

literal ::= BOOL | INT | FLOAT | STRING | SYMBOL | 'null'
op      ::= '+' | '-' | '*' | '/' | '%' | '==' | '!=' | '<' | '>'
          | '<=' | '>=' | '&&' | '||' | '!'
```

---

## § 8. Worked Example

A complete program illustrating the core constructs:

```
// § Ontology
type OrderStatus = Enum[:pending, :processing, :complete, :cancelled]

type Product {
  id:        Id
  available: Bool
  stock:     Int where stock >= 0
  price:     Money where price > 0
}

type Marketing {
  campaign_active:  Bool
  discount_applied: Bool
  discount_rate:    Float where 0.0 <= discount_rate <= 1.0
}

type Manager {
  id:             Id
  approved:       Bool
  approval_limit: Money
}

// § Pure functions
fn effective_price(price: Money, discount: Float, active: Bool) -> Money =
  if active then price * (1.0 - discount) else price

// § Contracts
contract FulfillOrder {
  // Inputs
  in product:   Product
  in marketing: Marketing
  in manager:   Manager

  // Constraints
  guard :product_ready {
    product.available = true
    product.stock > 0
    on_fail: :out_of_stock
  }

  guard :discount_consistent {
    when marketing.campaign_active
    marketing.discount_applied must be true
  }

  // Computation
  compute :unit_price: Money =
    effective_price(
      product.price,
      marketing.discount_rate,
      marketing.discount_applied
    )

  compute :within_limit: Bool =
    unit_price <= manager.approval_limit

  // Dispatch
  branch :result {
    on manager.approved && within_limit =>
      Order {
        status: :complete
        total:  unit_price
      }
    on !manager.approved =>
      Order { status: :pending, total: unit_price }
    default =>
      Order { status: :cancelled, total: unit_price }
  }

  // Outputs
  out order:      Order       = result
  out unit_price: Money       = unit_price
}

// § Composition
contract ProcessOrder {
  in order_id: Id

  compose :raw     = FetchOrder    { id: order_id }
  compose :product = FetchProduct  { id: raw.order.product_id }
  compose :mkt     = FetchMarketing { vendor_id: product.vendor_id }
  compose :mgr     = FetchManager  { order_id: order_id }

  compose :fulfilled = FulfillOrder {
    product:   product
    marketing: mkt
    manager:   mgr
  }

  effect :audit = AuditLog {
    entity: :order
    id:     order_id
    action: :fulfilled
    result: fulfilled.order.status
  } @idempotent

  out result: Order = fulfilled.order
}
```

---

## § 9. Compile-Time Guarantees

A program that passes the type checker and compiler is guaranteed:

| Property | Guarantee |
|----------|-----------|
| **Type safety** | No type error at runtime for well-typed programs |
| **Dependency completeness** | Every referenced node exists and is reachable |
| **Acyclicity** | The contract graph has no cycles (DAG property) |
| **Guard coverage** | Branches over `Enum` types cover all variants or have `default` |
| **Output completeness** | All `out` nodes are reachable from `in` nodes |
| **Effect isolation** | Pure nodes have no `IO` effects |
| **Termination** | Pure DAG contracts always terminate (Datalog decidability) |

---

## § 10. Open Items for v0.2

1. **Recursive contracts**: syntax and type rule for `@recursive` opt-in
2. **Probabilistic types**: formal typing rules for `~T` under composition
3. **Property model integration**: `model` declarations and synthesis trigger
4. **Module system**: `import` / `export` for multi-file programs
5. **Error types**: typed error hierarchy and propagation rules
6. **Streaming contracts**: `stream` input type and continuous evaluation
7. **Generics**: parametric contracts `contract Mapper[T, U] { ... }`
