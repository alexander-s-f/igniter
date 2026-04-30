# Contract Persistence: Organic Model

Status date: 2026-04-30.
Scope: Architecture recommendations for organic contract-native persistence.
Not a public API promise, package API, or execution plan.

## Current State (Honest Snapshot)

What the Companion proof has validated:

```
persist → Store[T]            ✓ manifest descriptor
history → History[T]           ✓ manifest descriptor
field/index/scope/command      ✓ DSL metadata
storage_plan (R1)              ✓ report-only lowering candidates
command → mutation intent      ✓ graph returns, store applies
materializer lifecycle         ✓ review-only, no execution
```

What is **not** yet part of the graph:

- `field` — manifest metadata only, not a graph node
- Store reads — happen **outside** the contract, inside `CompanionStore`
- Store writes — intent hash interpreted by the store layer
- Adapter — runtime injection, not compile-time configuration

The graph knows about storage intent — but does not participate in storage.
That is a sound starting point, but not yet organic.

## What "Organic" Means in Igniter

ORM approach: **storage first**

```
Table → Model class → Query methods → Business logic
```

Igniter organic persistence: **semantics first**

```
Contract (rules + shapes) → Storage plan → Adapter lowering → Physical storage
```

Core principles:

1. **The contract IS the schema.** `persist :reminders do field :title end` is
   the schema definition. No separate migration file.
2. **Store[T] is a graph node**, not DSL metadata. The compiler validates it;
   the runtime resolves it.
3. **Reads are graph dependencies.** `store_read :reminder, by: :id` is
   resolved by the runtime with TTL cache and coalescing — the same as
   `compute`.
4. **Writes are typed outputs.** `store_write :reminder, target: :reminders` is
   executed by the runtime at the app boundary, with Saga compensation.
5. **Adapter is a runtime plugin.** The contract declares what to store; the
   adapter declares how.

## Model: Store[T] and History[T] as First-Class Graph Nodes

### New Node Types in the Graph Model

```ruby
# lib/igniter/model/ — new NodeTypes:
# StoreNode      — like ComputeNode, but resolved by the adapter
# HistoryNode    — append-only variant of StoreNode
# StoreReadNode  — adapter resolution (like compute, with cache_ttl/coalesce)
# StoreWriteNode — side effect at app boundary (like effect, with compensate)
```

### DSL (target shape)

```ruby
class ReminderContract < Igniter::Contract
  define do
    # Store[T] declaration — both schema and graph node
    persist :reminders, key: :id, adapter: :sqlite do
      field :id,     type: Types::UUID,  default: -> { SecureRandom.uuid }
      field :title,  type: Types::String
      field :status, type: Types::Enum[:open, :closed], default: :open
      index :status
      scope :open, where: { status: :open }
    end

    # History — append-only, no update/delete semantics
    history :reminder_logs, partition_key: :reminder_id do
      field :reminder_id, type: Types::UUID
      field :action,      type: Types::Symbol
      field :occurred_at, type: Types::DateTime, default: -> { Time.now }
    end

    # --- Inputs ---
    input :reminder_id

    # store_read resolved by runtime — lazy node like compute
    store_read :reminder, from: :reminders, by: :id, using: :reminder_id,
               cache_ttl: 60, coalesce: true

    # Business logic stays in compute — storage-unaware
    compute :updated_reminder, depends_on: [:reminder], call: CompleteReminderTransition

    # store_write — typed side effect at app boundary
    store_write :saved_reminder, from: :updated_reminder, target: :reminders

    # store_append — for histories
    store_append :log_entry, from: :updated_reminder, target: :reminder_logs

    output :saved_reminder
  end
end
```

### What This Provides

| Aspect | ORM | Igniter Organic |
|--------|-----|-----------------|
| Schema | Separate migration file | `persist do field ... end` IS the schema |
| Reads | `Model.where(...)` outside business logic | `store_read` — graph dependency with cache/coalesce |
| Writes | `model.save!` imperatively | `store_write` — typed output with Saga |
| Validation | callbacks/validations in model | type system on fields + graph compiler |
| Relations | belongs_to/has_many | `relation` — typed compiler-validated graph edge |
| Adapter | ActiveRecord + database.yml | runtime plugin declared in contract |
| Migration | `rails generate migration` | diff between `Store[T].version(n)` and `Store[T].version(n+1)` |

## Relations as Graph Edges

Relations are currently manifest metadata with `enforcement: :report_only`.
In the organic model they are typed edges the **compiler validates**:

```ruby
relation :logs_by_reminder,
  from: Store[:reminders],
  to:   History[:reminder_logs],
  join: { id: :reminder_id },
  cardinality: :one_to_many

# In a projection — the relation becomes a graph input
project :reminder_detail,
  using: :logs_by_reminder,
  depends_on: [:reminder]
```

The compiler checks that `id` in `reminders` and `reminder_id` in
`reminder_logs` have compatible types. This is compile-time type-checking of
relations — something no ORM provides.

## Migration as a First-Class Contract

The current `WizardTypeSpecMigrationPlanContract` is already close to this.
Target model:

```ruby
class ReminderContract::Migration < Igniter::Contract
  define do
    # Store[T] is itself versioned — it keeps a history of spec changes
    input :previous_schema, from: Store[ReminderContract].version(:previous)
    input :current_schema,  from: Store[ReminderContract].version(:current)

    compute :schema_diff,    depends_on: %i[previous_schema current_schema], call: StoreSchemaDiff
    compute :migration_plan, depends_on: [:schema_diff], call: MigrationPlanBuilder

    output :migration_plan  # report-only, never self-executing
  end
end
```

Key insight: **schema versioning IS a History[ContractSpecChange]**, which
Companion already has (`WizardTypeSpecChange`). Schema change history is stored
with the same mechanisms as business event history. That is the organic shape.

## Adapter as a Runtime Plugin

```ruby
# Adapter declared in the contract — compile-time decision
class ReminderContract < Igniter::Contract
  adapter :sqlite, database: "companion.db"   # development
  # adapter :postgres, url: ENV["DATABASE_URL"]  # production
  # adapter :memory                               # tests

  define do
    persist :reminders do ... end
  end
end

# In tests:
ReminderContract.execute(
  { reminder_id: "123" },
  adapter: :memory  # override per execution
)
```

Minimal adapter interface:

```ruby
module Igniter::Persistence::Adapter
  def read(store_key, query)           # → Record or nil
  def write(store_key, record)         # → persisted Record
  def append(history_key, event)       # → appended Event
  def query(store_key, scope, params)  # → Array<Record>
end
```

## The Core Distinction from ORM

In an ORM the **unit of storage is an object** (User, Post, Comment). Business
logic is scattered across callbacks, concerns, and service objects.

In Igniter organic persistence the **unit of storage is a contract**. The
contract declares:

- what it stores (`persist`, `history`)
- how to read (`store_read`)
- how to mutate (`store_write`, `store_append`)
- how data relates (`relation`)
- what the adapter needs to lower the schema (`field`, `index`, `scope`)

The runtime handles everything else: lazy resolution, cache, invalidation, Saga
compensation, audit trail. Business logic stays in `compute` — isolated,
testable, storage-unaware.

## What to Preserve from the Current Design

| Current | Status |
|---------|--------|
| `persist → Store[T]` / `history → History[T]` | Keep — correct semantics |
| Command intent → app boundary | Keep — correct boundary pattern |
| Storage plan sketch (R1) | Keep as compile-time artifact |
| Report-only materializer lifecycle | Keep — execution must be explicit |
| Manifest + glossary health | Keep as guardrail |
| `WizardTypeSpec + History[ContractSpecChange]` | Keep — this IS schema versioning |

## Phased Path (on top of existing roadmap)

```
R1 (done)  Storage plan sketch — report-only
R2 (done)  Storage migration plan — report-only
R2a        field → type system — fields participate in type validation
R2b        store_read as compute-like graph node (lazy, cache_ttl, coalesce)
R3         store_write / store_append as typed effect output with Saga
R4         Adapter interface + memory adapter for tests
R5         Migration as diff Store[T].v(n) → Store[T].v(n+1)
R6         Materializer dry run → executable materializer
R7         Extraction: descriptors → igniter-extensions,
           adapters/materializer → igniter-application,
           reserve igniter-persistence
```

## Conclusion

The Companion proof has the right architecture. The boundary "graph computes
intent, store applies it" is correct. The manifest, storage plan, and glossary
health are the right infrastructure.

The move to organic persistence is: make `Store[T]` and `History[T]`
**first-class graph nodes**, not just DSL metadata. Then `store_read` is
resolved by the runtime with the same cache/coalesce as compute nodes,
`store_write` executes as a typed effect with Saga, and relations are
compiler-validated. That is persistence as part of the contract, not an ORM
on top of it.

## Handoff

```text
[Architect Supervisor / Codex]
Track: docs/research/contract-persistence-organic-model.md
Status: architectural recommendations for organic contract-native persistence.
[D] Store[T] and History[T] should become first-class graph node types.
[D] store_read should be a lazy graph node resolved by the runtime adapter.
[D] store_write/store_append should be typed effect outputs with Saga support.
[D] Relations should be compiler-validated typed graph edges.
[D] Fields should participate in Igniter's type system.
[D] Adapter should be declared in the contract, overridable per execution.
[D] Schema versioning IS History[ContractSpecChange] — already present in Companion.
[R] Do not add ORM-style query methods or model callbacks to this path.
[R] Keep the "graph computes intent, store applies" boundary.
[S] Development track is captured in
docs/research/contract-persistence-development-track.md.
[S] Next best slice: R2a — connect field declarations to report-only type
validation before core graph-node changes.
```
