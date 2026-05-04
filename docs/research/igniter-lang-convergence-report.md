# Igniter Lang Convergence Report

Status: public research synthesis
Date: 2026-05-04
Source horizon: archived `playgrounds/docs/experts/igniter-lang`
Current evidence: `igniter-contracts`, `igniter-ledger`, `igniter-ledger-client`,
and `igniter-durable-model`

## Claim

Igniter is not moving toward a separate language by first designing syntax.
It is moving toward a contract-native platform by proving semantics inside the
Ruby DSL first.

The strongest direction from the old Igniter-Lang research still holds:

```text
contract graph
-> typed descriptors
-> durable model shapes
-> access paths and time
-> materialization as contracts
-> cluster placement and execution later
```

The current implementation has validated the first durable lane:

```text
Record        -> Store[T]
History       -> History[T]
scope         -> query/access path
receipt       -> normalized mutation result
manifest      -> generated model class
LedgerClient  -> remote protocol boundary
Ledger        -> current fact engine / WAL / changefeed
```

This supports the package identity decision:

```text
packages/igniter-durable-model   package name
Igniter::DurableModel            canonical Ruby namespace
```

`Companion` should remain an app/product/example name. The package is becoming
Igniter's typed durable model layer.

## How We Are Moving

### 1. Ruby DSL First, Grammar Later

The old implementation track said the Ruby DSL should be the reference
implementation and grammar should wait until semantics are stable.

Current movement matches this.

Evidence:

- core contracts still run through the Ruby compiler/runtime
- `Igniter::Lang` descriptors are report-only
- `History`, `BiHistory`, `OLAPPoint`, and `Forecast` exist as metadata before
  runtime enforcement
- Ledger and Durable Model work are proving real pressure before a new grammar

Decision:

Do not design `.il` syntax yet. Keep extracting stable semantics from Ruby usage.

### 2. Durable Model, Not Database Abstraction

The persistence research framed persistence as a type/access-pattern property:
`Store[T]`, `History[T]`, `OLAPPoint[T]`, saga logs, caches, and rule sets each
declare their required physical behavior.

Current movement partially validates this:

- `igniter-ledger` owns hot fact physics: immutable facts, WAL, causation,
  query, changefeed, retention, compaction, and server delivery
- the current `igniter-durable-model` package owns typed application ergonomics:
  Record, History, scopes, receipts, and manifest-generated model classes
- `igniter-ledger-client` owns protocol and transport only

Decision:

Promote the package concept as **Durable Model**, not as a database wrapper and
not as `LedgerClient`.

### 3. History First, OLAP Later

The OLAP research makes a strong claim:

```text
History[T] == OLAPPoint[T, { time: DateTime }]
```

Current movement is starting from the simpler 1D form:

- append-only History
- replay
- partition keys
- time-travel reads
- changefeed
- retention/compaction boundary

This is the right order. History is the smallest useful proof of the larger
OLAP model.

Decision:

Keep OLAP as a horizon, but continue building facts/history/compaction first.
Future OLAP should grow from proven History segments, summaries, projections,
and boundary/compaction receipts.

### 4. Invariants as Reports Before Enforcement

The invariant research says invariants are global contracts and refinement-type
claims, not just local guards.

Current movement follows the safe version:

- setup/readiness/health packets are report-only
- storage plans, migration plans, field/type plans, relation type plans, access
  path plans, and effect intent plans are non-executing descriptors
- materializer approval remains review-only and grants no capabilities

Decision:

Do not rush invariant enforcement. First make invariant-like reports observable,
stable, and useful. Enforcement should graduate only after the report vocabulary
is boring and repeated.

### 5. Materialization as a Contract

The old research repeatedly treats materialization as a contract: operational
facts feed analytical or static artifacts through a declared, inspectable graph.

Current movement strongly matches this:

- `WizardTypeSpec` keeps dynamic specs durable
- static materialization is modeled as plan/parity/preflight/runbook/receipt
- materializer attempts and approvals are auditable
- no file/git/test/restart capability is granted by read endpoints

Decision:

Keep materialization as "print to code plus receipts", not live dynamic runtime
magic. A future materializer should be a capability-gated contract/agent that
prints static contracts, runs checks, and records evidence.

### 6. Reactive Delivery Is the Next Practical Bridge

The temporal and persistence research both point toward causal/as-of reads,
events, and reactive state.

Current movement has the engine-side ingredients:

- Ledger changefeed
- SSE `/v1/events`
- replay cursors
- async fan-out
- observability and diagnostics

Current Durable Model movement is now connecting application ergonomics:

- client-backed `scope` works through `LedgerClient#query`
- next slice is client-backed `on_scope` through Ledger Client events

Decision:

Treat reactive scopes as the near-term bridge from facts to application value.
This gives ordinary apps immediate use while preserving the long-term temporal
model.

## Valuable Ideas To Carry Forward

### Durable Shape Taxonomy

Keep this as the north star:

```text
Store[T]       record-like point reads/writes
History[T]     append-only log, replay, time ranges
BiHistory[T]   corrections and valid/transaction time
OLAPPoint[T]   multi-dimensional analytical value
WorkflowLog    await/saga execution state
Cache[T]       ephemeral/coalesced derived value
RuleSet[T]     versioned rules and policy
```

Do not implement all at once. Use the taxonomy to avoid painting `Store[T]`,
`History[T]`, projections, receipts, and adapter storage into one object model.

### Type-Directed Storage Requirements

Keep the idea that the model can emit requirements:

```text
shape
access pattern
consistency need
partition strategy
retention/compaction policy
materialization strategy
```

Current manifest work is the first public-safe version of this.

### `as_of` as a First-Class Read Semantics

`as_of` should remain central. It is already useful in Ledger reads and Durable
Model scopes, and later it connects to temporal rules, bitemporal history, and
causal consistency.

### Compaction/Boundary as Semantic Compression

The recent boundary/container work maps well to old HistorySegment thinking:

```text
raw facts
-> sealed boundary/container
-> derived summaries/checks/projections
-> optional purge after references and policy allow it
```

This is the practical path toward long-lived ledgers that do not grow without
limit.

### Conflict Resolution Shares Vocabulary With Rules

The old idea that write conflicts and rule conflicts both use `combines:` is
still valuable. Keep it as a design guardrail for future concurrent writes,
OLAP rollups, and multi-writer histories.

### Property Models and Agents

The property-model research is still early, but one idea is useful now:

```text
ontology/spec -> generated contract/model -> verified runtime behavior
```

This aligns with `WizardTypeSpec`, generated Record/History classes, and future
agent-assisted materialization. LLMs should author specs and proposals first,
then a gated materializer turns accepted specs into static code.

### Probabilistic Precomputation as Later Optimization

The approximate/precompute research is valuable but not immediate.

Carry forward only the principle:

```text
consumer precision should drive computation cost
```

Near-term equivalents are cache TTL, projection freshness, summary confidence,
and approximate analytical reads. Do not add probabilistic runtime semantics yet.

## Ideas To Defer

These remain good research but should not steer near-term package design:

- standalone grammar and parser
- full property-model synthesis
- formal invariant verifier
- Rust backend for contracts
- OLAPPoint runtime
- probabilistic abstract domains
- cluster-wide causal clocks and vector-clock reads
- automated placement/fanout compiler
- cross-store transactions

Each should return only after a small Ruby/package proof creates repeated
pressure.

## Package Direction

Recommended target map:

```text
core igniter / igniter-contracts
  contract graph, compiler, runtime, effects, diagnostics

packages/igniter-ledger
  hot durable fact engine:
  facts, WAL, causation, query, changefeed, compaction, server

packages/igniter-ledger-client
  protocol and transports:
  write/read/append/replay/query/subscribe, HTTP/SSE/object dispatch

packages/igniter-durable-model
  typed durable application model layer:
  Record, History, scopes, receipts, manifest-generated classes,
  later entity/OLAP/workflow-state vocabulary

examples/application/companion
  product/app proof:
  UI, setup packets, materializer playground, user-facing experiments
```

Rename path:

1. Finish the active Ledger Client subscription slice.
2. Add `Igniter::DurableModel` namespace in the current package.
3. Keep `Igniter::Companion` aliases temporarily.
4. Update docs/examples to use Durable Model.
5. Rename package/gem directory once tests are stable.

## Smallest Next Moves

1. Land client-backed `on_scope` over Ledger Client events.
2. Start the `Igniter::DurableModel` namespace shim.
3. Rename package docs from Companion identity to Durable Model identity.
4. Define the first public Durable Model README around `Record`, `History`,
   `Store`, `scope`, `receipt`, and `client:`.
5. Keep OLAP/time-machine/property synthesis as horizon notes, not implementation
   tracks.

## Public Boundary

This report is not a public API promise.

Accepted public direction:

- Ruby DSL proves semantics before grammar.
- Durable models are separate from Ledger engine and Ledger Client transport.
- Ledger is the current hot fact substrate.
- Durable Model is the application-facing typed layer.

Not accepted yet:

- stable `igniter-durable-model` gem API
- `Store[T]` / `History[T]` as core language syntax
- OLAPPoint runtime
- invariant enforcement
- automatic materializer write capabilities
- standalone Igniter language grammar
