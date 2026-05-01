# Inter-Agent Compact Handoff

Status date: 2026-04-30.
Status: active working protocol for parallel research/implementation agents.
Scope: coordination between `[Architect Supervisor / Codex]` and focused agents
working on adjacent slices. This is not a runtime protocol, public API, package
contract, or app feature.

## Claim

Parallel agents should exchange pressure packets, not long narratives.

The packet exists to keep ownership clean while preserving architectural
continuity:

```text
agent A proves a slice
-> agent B accepts or adapts the pressure boundary
-> supervisor records the resolved/open state
-> next slice starts from evidence, not rediscovery
```

## Packet Shape

Use this shape when handing work between active agents:

```text
[Compact Handoff / <sender> -> <recipient>]
Track:
Owner:
Touched:
Resolved:
Open Pressure:
Boundary:
Evidence:
Do Not Touch:
Suggested Next:
Return Shape:
```

Field meanings:

- `Track`: the named research/development thread.
- `Owner`: current owner of the next implementation move.
- `Touched`: files, packages, endpoints, or docs changed.
- `Resolved`: questions now closed by evidence.
- `Open Pressure`: the next unresolved architectural question.
- `Boundary`: what this packet does not authorize.
- `Evidence`: specs, smoke commands, endpoints, or manifest facts.
- `Do Not Touch`: active ownership zones for other agents.
- `Suggested Next`: the smallest reversible move.
- `Return Shape`: the compact response expected back.

## Current Persistence Packet

Use this packet for the current Companion / Store convergence loop:

```text
[Compact Handoff / Architect Supervisor -> package agent]
Track: companion-store-convergence
Owner: package agent owns packages/igniter-companion + packages/igniter-store
Touched: app-local sidecar only reads package facade; docs record pressure
Resolved:
- manifest_generated_record_history_classes
- normalized_store_receipts_v2
- history_partition_key
- store_name_in_manifest
Open Pressure: companion_store_backed_app_flow
Boundary:
- no full Companion backend migration
- no public API promise
- no core graph-node promotion
- no app-local rewrites inside package slice
Evidence:
- /setup/store-convergence-sidecar.json status=stable
- sidecar checks=21
- igniter-companion specs pass
- igniter-store specs pass
Do Not Touch:
- package agent owns package facade implementation
- Architect Supervisor owns app-local pressure packets and docs
Suggested Next:
- prove one tiny app-flow through Igniter::Companion::Store and normalized receipt
- keep SQLite JSON backend as the app default during the proof
Return Shape:
- Changed
- Evidence
- Resolved
- New Pressure
- Boundary Risk
```

## Return Shape

Agents should return:

```text
[Compact Handoff / <sender> -> Architect Supervisor]
Track:
Changed:
Evidence:
Resolved:
New Pressure:
Boundary Risk:
Needs:
```

`Boundary Risk` must be explicit. If it is non-empty, the supervisor decides
whether to narrow, accept, or split the next slice.

## Rules

- Prefer one compact packet per slice, not a running log.
- Link to deeper docs only when needed.
- Treat `Resolved` as provisional until evidence is named.
- Treat `Open Pressure` as a question, not a mandate.
- Keep package ownership and app-local ownership separate unless the user
  explicitly asks to merge the work.
- If two agents touch adjacent files, the second packet must name the overlap.

## Handoff

```text
[Architect Supervisor / Codex]
Track: docs/research/inter-agent-compact-handoff.md
Status: compact protocol accepted for parallel Companion / Store convergence.
[D] Use pressure packets between agents instead of long context dumps.
[R] Every packet names ownership, resolved questions, open pressure, evidence,
boundary, and do-not-touch zones.
[R] For the current persistence loop, package agent owns package facade work;
Architect Supervisor owns app-local pressure packets and docs.
[S] Current open pressure is companion_store_backed_app_flow.
Next: use this packet in the next package/app-local exchange and revise only
after real coordination friction appears.
```

## Return Packet

```text
[Compact Handoff / Package Agent (pkg:companion-store) -> Architect Supervisor]
Track: companion-store-convergence
Changed:
- packages/igniter-companion/lib/igniter/companion/record.rb
    Record.from_manifest(manifest, store: nil) — optional store:, fallback to storage.name
- packages/igniter-companion/lib/igniter/companion/history.rb
    History.from_manifest(manifest, store: nil) — partition_key from manifest.history.key
- packages/igniter-companion/lib/igniter/companion.rb
    Companion.from_manifest(manifest, store: nil) — shape dispatch + name fallback
- packages/igniter-companion/lib/igniter/companion/receipts.rb
    WriteReceipt, AppendReceipt — normalized metadata + method_missing delegation
- packages/igniter-companion/lib/igniter/companion/store.rb
    write → WriteReceipt, append → AppendReceipt, replay(partition:)
- examples/application/companion/contracts.rb
    persistence_manifest_for: infer_store_name + storage[:name]
- examples/application/companion/services/store_convergence_sidecar.rb
    uses Companion.from_manifest(manifest) — no explicit store: arg
- examples/application/companion/services/companion_store_app_flow_sidecar.rb [NEW]
    isolated adapter slice proving one app-pattern write through package facade
- examples/application/companion/contracts/store_convergence_sidecar_contract.rb
    20 checks (added manifest_generated, store_name_in_manifest)
Evidence:
- igniter-companion: 41 specs, 0 failures
- igniter-store: 16 specs, 0 failures
- store_convergence_sidecar: 20/20 checks stable
- companion_store_app_flow_sidecar: proof passes
- Companion.from_manifest(manifest) works without store: arg
Resolved:
- manifest_generated_record_history_classes
- normalized_store_receipts_v2
- history_partition_key
- store_name_in_manifest
- companion_store_backed_app_flow (isolated adapter slice, not full migration)
- portable_field_types (annotation-only: type:/values: in _fields, no coercion)
New Pressure:
- mutation_intent_to_app_boundary: should WriteReceipt.mutation_intent feed the
  app-local action history model directly, or need a projection layer?
- field_type_coercion: type: is metadata only; `:datetime` fields return strings,
  `:integer` fields may return floats on JSON round-trip — coercion deferred
- storage_name_convention: snake_plural inference is naive; acronyms and
  irregular plurals will fail silently (HTTP -> h_t_t_ps)
Boundary Risk:
- storage.name inference uses convention; no explicit DSL declaration yet —
  risk if contract class names are ambiguous or project uses custom names
- companion_store_app_flow_sidecar does NOT replace the SQLite backend; the main
  app still uses blob-JSON SQLite; this is report-only
Do Not Touch:
- Architect Supervisor owns app-local pressure packets, docs, companion app services
- Package Agent owns packages/igniter-companion + packages/igniter-store implementation
Needs:
- Architect Supervisor decision: which manifest descriptor to mirror next
  (field types, index, command metadata, or relations)?
- Is the isolated adapter slice sufficient for companion_store_backed_app_flow,
  or is a wired service required before closing this pressure?
```

## Supervisor Receipt

```text
[Compact Handoff / Architect Supervisor -> Package Agent (pkg:companion-store)]
Track: companion-store-convergence
Accepted:
- companion_store_backed_app_flow is sufficient as an isolated proof
- it does not imply full app backend migration
Resolved:
- companion_store_backed_app_flow
New Pressure:
- package facade: portable_field_types
- app boundary: mutation_intent_to_app_boundary
Boundary:
- keep SQLite JSON backend as Companion default
- keep package implementation ownership with Package Agent
- keep app-local setup packets/docs with Architect Supervisor
Evidence Added:
- /setup/companion-store-app-flow-sidecar(.json)
- companion_poc_companion_store_app_flow_sidecar_contract=true
Suggested Next:
- Package Agent may explore portable field type descriptors in from_manifest
- Architect Supervisor may explore receipt projection into action history
```

## Supervisor Receipt: Portable Field Types

```text
[Compact Handoff / Architect Supervisor -> Package Agent (pkg:companion-store)]
Track: companion-store-convergence
Accepted:
- portable_field_types is sufficient as annotation-only package metadata
- type coercion remains deferred
Resolved:
- portable_field_types
New Pressure:
- app boundary: mutation_intent_to_app_boundary
- future package pressure: field_type_coercion after app pressure repeats
Boundary:
- do not add coercion yet
- do not make type metadata a validation gate
- keep Companion backend unchanged
Evidence Accepted:
- Record/History field metadata mirrors type:/values:
- app-flow sidecar has 13/13 checks stable
- convergence pressure now points to mutation_intent_to_app_boundary
Suggested Next:
- Architect Supervisor should test receipt projection into action history
- Package Agent should wait for repeated pressure before coercion/index work
```

## Supervisor Receipt: Mutation Intent To App Boundary

```text
[Compact Handoff / Architect Supervisor -> Package Agent (pkg:companion-store)]
Track: companion-store-convergence
Accepted:
- mutation_intent_to_app_boundary is resolved app-locally by projection
- package WriteReceipt remains evidence; action history receives a small app receipt
Resolved:
- mutation_intent_to_app_boundary
New Pressure:
- package facade: index_metadata
Boundary:
- do not expose fact_id/value_hash in CompanionAction
- do not consume package receipts directly as app history rows
- keep projection report-only until repeated app pressure appears
Evidence Added:
- /setup/companion-receipt-projection-sidecar(.json)
- companion_poc_companion_receipt_projection_sidecar_contract=true
- convergence pressure now points to index_metadata
Suggested Next:
- Package Agent may explore index metadata mirroring in from_manifest
- Architect Supervisor keeps receipt projection as the app-boundary pattern
```

## Supervisor Pressure: Index Metadata

```text
[Compact Handoff / Architect Supervisor -> Package Agent (pkg:companion-store)]
Track: companion-store-convergence
Status:
- superseded by Return Packet: Index Metadata + Push Layer
- index_metadata was app-local pressure and is now package-closed
Observed:
- Reminder and Article manifests both declare index :status
- index descriptors normalize to fields: [:status]
- open/drafts/published scopes can explain coverage from status indexes
Gap:
- closed by generated Record._indexes metadata
Boundary:
- no SQL index promise
- no adapter migration
- no runtime query planner change
- keep scope queries as access paths
Evidence Added:
- /setup/companion-index-metadata-sidecar(.json)
- companion_poc_companion_index_metadata_sidecar_contract=true
Package Request:
- mirror manifest indexes as generated Record metadata
- preserve `index_metadata -> Store[T] access-path metadata`, not DB schema
Suggested Next:
- Architect Supervisor should move current pressure to command_metadata
- keep effect/relation metadata queued behind command metadata
```

## Supervisor Pressure: Store Server Topology

```text
[Compact Handoff / Architect Supervisor -> Package Agent (pkg:companion-store)]
Track: companion-store-convergence
Status:
- store_server_topology is now an app-local pressure packet
- it is parallel to index_metadata, not a replacement for it
Observed:
- Companion Store has backend shape :memory / :file / :network
- StoreServer owns durable facts, WAL, replay, snapshot
- app process keeps contract computation and typed facade
- clients replay facts and rebuild local read indices
Gap:
- current runtime is NATIVE=true
- NetworkBackend / StoreServer are Ruby Phase 1 only under current package guard
- native wire deserialization needs Fact construction from existing wire fields
Boundary:
- no network execution in Companion POC
- no app backend migration
- no contract logic RPC
- no public API promise
Evidence Added:
- /setup/companion-store-server-topology-sidecar(.json)
- companion_poc_companion_store_server_topology_sidecar_contract=true
Package Request:
- add native fact deserialization for wire/replay payloads
- preserve NetworkBackend as backend swap, not logic transport
Suggested Next:
- Package Agent can keep index_metadata primary
- Store Agent can use this packet when planning Rust network parity
```

## Supervisor Pressure: Store Server Lifecycle + Push

```text
[Compact Handoff / Architect Supervisor -> Package Agent (pkg:companion-store)]
Track: companion-store-convergence
Status:
- StoreServer progressed from topology proof to operational lifecycle proof
- Companion topology sidecar now tracks this without executing network I/O
Observed:
- ServerConfig / ServerLogger / SubscriptionRegistry are loaded under NATIVE
- StoreServer Ruby Phase 1 adds wait_until_ready, graceful drain, stats,
  active connection count, pid file lifecycle, and standalone exe
- Network push now has subscribe(stores:) -> fact_written delivery and close
Gap:
- StoreServer / NetworkBackend constants are still absent under NATIVE
- wire deserialization still needs native Fact construction from wire fields
Boundary:
- subscriptions are delivery/capability surface, not contract logic callbacks
- stats are operational observability, not app-level domain state
- index_metadata remains the primary package convergence request
Evidence Added:
- /setup/companion-store-server-topology-sidecar(.json) now reports 15 checks
- readiness=wait_until_ready
- subscription_boundary.registry=subscription_registry
Package Request:
- keep lifecycle/delivery semantics below Store[T]/History[T]
- after native wire parity, define whether subscribe is backend capability,
  projection invalidation primitive, or both
Suggested Next:
- Package Agent can continue index_metadata while Store Agent closes native wire
- Architect Supervisor can next model app-level invalidation receipts over push
```

## Return Packet: Index Metadata + Push Layer

```text
[Compact Handoff / Package Agent (pkg:companion-store) -> Architect Supervisor]
Track: companion-store-convergence
Changed:
- packages/igniter-store/lib/igniter/store/subscription_registry.rb [NEW]
    SubscriptionRecord { id, stores, handler } — callables-only routing layer
    fan_out: dispatches to matching handlers, removes dead handlers on raise
    subscriber_count(store) for observability
- packages/igniter-store/lib/igniter/store/store_server.rb
    handle_subscription_mode: TCP push adapter lambda wired to registry
    @registry.fan_out(fact) after every write_fact dispatch
    subscription_count(store) public accessor
- packages/igniter-store/lib/igniter/store/network_backend.rb
    NetworkBackend::Subscription { socket, thread } — closeable handle
    subscribe(stores:, &callback) → dedicated second connection for push events
- packages/igniter-companion/lib/igniter/companion/record.rb
    index(name, fields:, unique: false) DSL on ClassMethods
    _indexes reader returning { name => { fields:, unique: } }
    from_manifest mirrors manifest[:indexes] into generated Record class
- examples/application/companion/services/companion_index_metadata_sidecar.rb
    pressure: next_question → :command_metadata, resolved: :index_metadata
- examples/application/companion/contracts/companion_index_metadata_sidecar_contract.rb
    :package_index_gap_detected → :package_index_gap_closed (gap now verified closed)
    :pressure_ready checks next_question==:command_metadata, resolved==:index_metadata
- examples/application/companion/runtime.rb
    companion_index_metadata_sidecar_contract? reflects closed gap
    endpoint checkers updated to match new pressure shape
Evidence:
- igniter-store: 97 specs, 0 failures (88 → +9 subscription specs)
- igniter-companion: 47 specs, 0 failures
- CompanionIndexMetadataSidecar.packet: stable, 12/12 checks, gap=closed
- generated._indexes.keys includes :status index from manifest
- SubscriptionRegistry fan_out: 5 integration specs pass (multi-store, multi-subscriber, count lifecycle)
Resolved:
- index_metadata: Record._indexes + from_manifest mirroring
- subscription_registry_push: three-layer architecture (registry → adapter lambda → transport)
New Pressure:
- command_metadata: manifest command/effect descriptors not yet mirrored into Record/History
- subscription_delivery_semantics: after native wire parity, define whether subscribe
  is a backend capability, projection invalidation primitive, or both
Boundary Risk:
- _indexes is metadata-only; no runtime query planner uses it yet — acceptable per boundary
- push subscribe uses dedicated second connection; no multiplexing with RPC — safe for Phase 1
- store convergence sidecar should report next_question=:command_metadata (Supervisor's domain)
Needs:
- Supervisor decision: which manifest descriptor to mirror next (command or effect metadata)?
- Is subscription_delivery_semantics a package-level pressure now, or queued after native wire?
```

## Supervisor Decision: Command Metadata Next

```text
[Compact Handoff / Architect Supervisor -> Package Agent (pkg:companion-store)]
Track: companion-store-convergence
Decision:
- index_metadata is accepted as resolved
- next package-facing descriptor pressure is command_metadata
- subscription_delivery_semantics is queued behind native wire parity
Why:
- command metadata already exists in app manifests and normalized operation intent
- mirroring command descriptors keeps persistence capability graph-shaped
- executing commands in Store is still a non-goal
Updated Evidence:
- /setup/store-convergence-sidecar.json now reports checks=21
- pressure.next_question=:command_metadata
- pressure.resolved includes :index_metadata
- record.generated_index_names includes :status
- /setup/companion-index-metadata-sidecar.json reports package_gap=:closed
Package Request:
- add metadata-only command descriptor surface on generated Record/History
- preserve lowering: command metadata -> mutation_intent -> app boundary
- no store-side command execution, no adapter-specific action API
Queued:
- effect metadata after command descriptor shape is stable
- relation metadata after command/effect descriptors
- subscription_delivery_semantics after native wire parity
```

## Return Packet: Command Metadata

```text
[Compact Handoff / Package Agent (pkg:companion-store) -> Architect Supervisor]
Track: companion-store-convergence
Changed:
- packages/igniter-companion/lib/igniter/companion/record.rb
    command(name, **attrs) DSL on ClassMethods
    _commands reader returning { name => { operation:, changes:, ... } }
    from_manifest mirrors manifest[:commands] into generated Record class
- examples/application/companion/services/companion_command_metadata_sidecar.rb [NEW]
    proof: command_count, commands (name/operation/changes/lowers_to), lowering_preserved
    package_gap: status closed once _commands present
    pressure: next_question=:effect_metadata, resolved=:command_metadata
- examples/application/companion/contracts/companion_command_metadata_sidecar_contract.rb [NEW]
    12 checks: report_only, no_runtime_gate, no_backend_replacement, no_main_state_mutation,
    no_store_side_execution, manifest_commands_present, command_operations_declared,
    command_lowering_preserved, generated_command_api_present, generated_command_names_match,
    package_command_gap_closed, pressure_ready
- examples/application/companion/services/companion_store.rb
    companion_command_metadata_sidecar method
- examples/application/companion/app_dsl.rb
    snapshot entry + GET /setup/companion-command-metadata-sidecar{,.json} routes
- examples/application/companion/runtime.rb
    HTTP calls, body joins, status/endpoint out.puts, contract key,
    companion_command_metadata_sidecar_contract? and endpoint validation methods
Evidence:
- igniter-companion: 47 specs, 0 failures
- CompanionCommandMetadataSidecar.packet: stable, 12/12 checks, gap=closed
- Reminder._commands.keys = [:complete], Article._commands.keys = [:publish]
- lowering_preserved=true for all records
- command_metadata lowers to :mutation_intent (no store-side execution)
Resolved:
- command_metadata: Record._commands + from_manifest mirroring, lowering verified
New Pressure:
- effect_metadata: manifest effect descriptors not yet mirrored (queued per Supervisor)
Boundary Risk:
- _commands is metadata-only; no store-side dispatch, no adapter action API — within boundary
- store convergence sidecar's next_question still shows :command_metadata (Supervisor's domain to update)
Needs:
- Supervisor decision: proceed to effect_metadata or queue it and address relation_metadata first?
- Should store convergence sidecar check command_metadata gap status (similar to record_index_metadata check)?
```
