# Project Status Horizon Report

Status date: 2026-05-02.
Scope: whole-project compact status, current evidence, insights, and horizon
ideas. Not a public API promise.

## Claim

Igniter is no longer only a Ruby contract runtime. The project is becoming a
contracts-native substrate:

```text
contracts kernel
-> application/showcase pressure
-> Companion persistence pressure
-> igniter-companion typed facade
-> igniter-store hot fact engine
-> store server / reactive delivery / future sync hub
-> later language and package consolidation
```

The strongest architecture signal is not one feature. It is the repeated shape:
contracts describe behavior, persistence, diagnostics, handoff, materialization,
and now the infrastructure that may later materialize more contracts.

## Current Package Status

### Core Runtime Family

- `igniter-contracts`: embedded kernel, class DSL, compile/runtime spine,
  diagnostics, Contractable protocol.
- `igniter-extensions`: optional language packs, operational tooling, domain
  behavior, MCP-facing tool semantics.
- `igniter-embed`: host registration and migration/shadow wrappers.
- `igniter-application`: local application runtime, app composition,
  transfer/activation receipts, installed-capsule registries.
- `igniter-ai`: provider-neutral AI request/response envelopes and fake/live/
  recorded provider modes.
- `igniter-agents`: minimal agent definitions, runs, turns, traces, tool-call
  evidence, and app-level agent DSL wiring.
- `igniter-hub`: local capsule catalog discovery and transfer bundle metadata.
- `igniter-web`: mounted web surfaces over explicit app snapshots.
- `igniter-cluster`: distributed planning, routing, ownership, remediation,
  health, and mesh execution.
- `igniter-mcp-adapter`: MCP tool catalog and invocation adapter.

### New Pressure Packages

- `igniter-store`: experimental hot fact engine. Current evidence includes
  immutable facts, fact-id causation, time-travel reads, scope access paths,
  scope-aware invalidation, history partition indexes, LRU time-travel cache,
  read-path schema coercion, CRC32-framed WAL, snapshot checkpoint/replay,
  retention/compaction, derivation/scatter/relation rules, StoreServer,
  NetworkBackend, WireProtocol, subscriptions, stats, drain, CLI, HTTPAdapter
  (Rack, port 7300), and TCPAdapter (WireProtocol framing, port 7401).
- `igniter-companion`: typed Record/History facade over `igniter-store`. It
  turns app-local manifests into Record/History classes, normalized receipts,
  partition replay, projection metadata, schema-graph sidecars, and convergence
  proofs without replacing Companion's app backend or declaring a core API.

## Companion Status

Companion remains the strongest product pressure.

Current proof:

- records: 6
- histories: 6
- projections: 5
- command groups: 5
- relations: 2
- total capabilities: 19

Current graph of pressure:

```text
persist/history -> Store[T]/History[T] descriptors
storage plan -> storage migration plan
field type plan -> relation type plan
access path plan -> typed effect intent plan
store convergence sidecar -> package Record/History facade
projection/schema graph sidecars -> Store metadata evidence
derivation/scatter/relation rules -> Companion typed resolve + as_of resolve
OP1/OP2/OP3/OP4 -> descriptor import, metadata export, wire envelope, sync profile
OP5/companion_protocol_adoption -> Companion#register emits descriptors; OP2 surface on Companion
server_api_transport -> HTTPAdapter (Rack/port 7300) + TCPAdapter (port 7401) over WireEnvelope
materializer lifecycle -> still review-only/no grants
```

Important status: performance pressure was real but app-local. Memoized setup
packets moved aggregate `/setup` from seconds to millisecond-scale warm reads
without changing core contract execution.

## Current Worktree Notes

The Companion sidecar baseline now reports the current Store/Companion protocol
horizon as closed for this POC slice:

- `examples/application/companion/services/companion_store_server_topology_sidecar.rb`
- `examples/application/companion/services/store_convergence_sidecar.rb`

Meaning:

- `reactive_derivation`, `scatter_derivation`, `relation_rule_dsl`,
  `companion_relation_auto_wire`, `companion_typed_resolve`,
  `companion_resolve_time_travel`, `op1_descriptor_packet_import`,
  `op2_metadata_export`, `op3_wire_envelope`, `op4_sync_hub_profile`, and
  `companion_protocol_adoption` are marked resolved in StoreConvergence
- `pressure.next_question` is now `nil`; the next slice should be architect
  selected, not inferred by the previous packet

Current uncommitted changes from this report are docs-only snapshot updates.

## Verification Snapshot

Fresh checks on 2026-05-02:

- `ruby examples/run.rb smoke`: 87 passed, 0 failed, 0 skipped.
- `bundle exec rspec packages/igniter-store/spec`: 350 examples, 0 failures, 2 pending.
- `RUBYLIB=packages/igniter-companion/lib:packages/igniter-store/lib bundle exec rspec packages/igniter-companion/spec`: 89 examples, 0 failures.

Note: running `bundle exec rspec packages/igniter-companion/spec` without
`RUBYLIB` fails to load `igniter/companion`; the package spec helper is not yet
self-contained through root load-path registration.

## Strategic Insights

### 1. The system is building a nervous system

Setup packets, health packets, handoff packets, sidecars, descriptors, and
receipts are not documentation noise. They are the system's sensor layer.

Out-of-box direction: treat every future subsystem as a self-reporting organ.
If a package cannot describe its own readiness, ownership, pressure, next safe
move, and forbidden moves, it is not ready to become substrate.

### 2. Persistence split into semantics and physics

Companion/`igniter-companion` own typed app semantics. `igniter-store` owns fact
physics. This is the right split.

Out-of-box direction: avoid "database abstraction" language. Use a physics
vocabulary:

```text
fact, causation, time, retention, projection, derivation, scatter, relation,
sync, cold hub
```

The DB becomes one possible cold material, not the model.

### 3. StoreServer should not execute contracts

The Store server should host durable facts, projections, access paths, and
delivery. Contract computation stays in the app.

Out-of-box direction: make the store server a projection organism, not an RPC
server. It should know how facts flow, not why business logic decides.

### 4. Migrations can become coercion ecology

Traditional migrations rewrite the past. Igniter facts preserve the past and
coerce on read when needed.

Out-of-box direction:

```text
schema change -> new schema version
old facts stay immutable
coercion contract adapts reads
retention/compaction decides when old facts can disappear
```

This makes rollback, audit, time-travel, and zero-downtime evolution part of
the same model.

### 5. Materialization should be "print to code"

Dynamic specs should not become live runtime code. They should be durable
lineage that can materialize into static contracts.

Out-of-box direction: a future materializer is a printer plus auditor:
it prints static code, records receipts, runs tests, and proves parity. It is
not a magical runtime evaluator.

### 6. Agent coordination should be invalidation-first

Polling agents are ordinary. Store-driven invalidation is the unusual advantage.

Out-of-box direction: proactive agents should subscribe to semantic access
paths and relation/projection descriptors, not endpoints. The store pushes
"something relevant changed"; the agent re-runs its contract.

### 7. The sync hub is a seed bank, not the source of truth

PostgreSQL sync hub should remain cold/async backup, bootstrap, analytics, and
cross-cluster exchange. It must not become the hot write path.

Out-of-box direction: think ecological memory:

- hot local fact engine
- warm store server
- cold sync hub
- retention policies as metabolism
- compaction receipts as digestion/audit

### 8. Package promotion should follow pressure topology

Promotion should not follow enthusiasm. It should follow repeated pressure:

```text
app-local proof
-> package facade
-> package substrate
-> cross-package pressure
-> stable descriptor vocabulary
-> public API
```

Current strongest next pressure is `companion_relation_auto_wire`.

### 9. Store needs an open waist

`igniter-store` should remain part of the Igniter ecosystem, but it should not
be locked to `Igniter::Contract` classes. The strategic surface is an open
descriptor/fact/receipt/query protocol where Igniter contracts are a first-class
client, not the only client.

Out-of-box direction:

```text
custom contract system
external DSL
agent memory model
Companion typed records
Igniter contracts
        -> Igniter Store Open Protocol
        -> igniter-store fact engine
```

This keeps the Lego-style option alive: another ecosystem can implement its own
contract model and still interoperate through Store facts.

## Ideas Beyond The Usual Box

### Semantic Flight Recorder

Every contract execution, store write, relation resolution, materializer
attempt, and agent action emits a fact. The whole system becomes replayable as a
flight recorder:

```text
What did the system know?
Which contract decided?
Which fact changed?
Which agent woke up?
Which materializer step was blocked?
```

### Contract-Native Digital Twin

A deployment can run two futures:

- current contracts over current facts
- proposed contracts over the same facts as-of time T

This turns migration review into simulation rather than static diff.

### Time-Travel UX Everywhere

Every dashboard can get an `as_of` control because time-travel is structural in
Store facts. Debugging becomes visual, not log scraping.

### Capability Firewall

Approval receipts should never grant capabilities directly. They should mint
reviewable capability tokens consumed by a narrow executor. This creates an
auditable firewall between "human approved" and "system acted".

### Projection Marketplace

Packages publish projection descriptors. Agents subscribe to projections by
semantic need, not implementation endpoint:

```text
agent needs pending tasks
-> subscribes to AccessPath[:tasks, :pending]
-> Store invalidates
-> agent reruns contract
```

### Cold Hub As Inter-Cluster Memory Commons

The PostgreSQL hub can become a memory commons shared by clusters, not a central
database. Each cluster writes/pulls facts under retention policy. Conflicts are
facts, not hidden overwrites.

### Relation Auto-Wire As The Next Compiler Test

The next useful compiler-like pressure is not a compiler change. It is
app-level relation auto-wiring:

```text
Companion relation manifest
-> igniter-companion facade
-> igniter-store RelationRule
-> relation_snapshot/resolve proof
```

If this feels boring and inspectable, it earns the right to move lower.

### Store Protocol As Ecosystem API

Publish `igniter-store` as a protocol-compatible fact substrate before treating
it as an Igniter-only persistence layer. The protocol should center on packets:

- descriptors
- facts
- receipts
- queries
- subscriptions
- replay/sync envelopes

This creates space for multi-language clients, external contract DSLs,
simulation engines, and agent memory systems to plug in without depending on
Igniter's Ruby DSL internals.

## Recommended Next Moves

1. Decide the next architect-owned slice after OP1-OP4: conformance kit,
   StoreServer envelope integration, or app-local protocol adoption proof.
2. Make `packages/igniter-companion/spec/spec_helper.rb` self-contained so
   package specs do not require manual `RUBYLIB`.
3. Keep StoreServer lifecycle as operational substrate only; do not route
   contract business logic through it.
4. Keep sync hub as async/cold proof: minimal BackgroundSync next, no write-path
   dependency.
5. Treat materializer dry-run as a separate lane; do not combine it with
   protocol transport work.

## Handoff

```text
[Architect Supervisor / Codex]
Track: docs/research/project-status-horizon-report.md
Status: whole-project status updated on 2026-05-02.
[D] Igniter is now a contracts-native substrate track, not only a contract DSL.
[D] igniter-store is hot fact engine; igniter-companion is typed facade.
[D] igniter-store now has an Open Protocol proposal: descriptor/fact/receipt
waist for non-Igniter clients as well as Igniter contracts.
[D] Companion remains the strongest product pressure; the current
Store/Companion protocol pressure packet is closed and awaits a new
architect-selected slice.
[R] Do not promote Store graph nodes, migrations, materializer execution, or
relation enforcement to core from current evidence.
[R] Do not let StoreServer become a contract-logic RPC surface.
[S] Fresh checks: examples smoke 87/0, store specs 327/0 with 2 pending,
companion specs 89/0 with RUBYLIB.
Next: choose between conformance kit, StoreServer envelope integration,
app-local protocol adoption, or sync-hub follow-through; keep materializer
dry-run separate.
```
