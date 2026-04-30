# Companion / Store Convergence

Status date: 2026-04-30.
Role: compact cross-track note for `[Architect Supervisor / Codex]`.
Scope: synchronization between the app-local Companion persistence proof,
`packages/igniter-companion`, and `packages/igniter-store`.

## Claim

These tracks are one system seen from three levels:

```text
examples/application/companion
  -> contract-declared capability manifests, commands, relations, materializer

packages/igniter-companion
  -> typed application Record/History facade over store primitives

packages/igniter-store
  -> immutable facts, WAL, replay, cache, access paths, time-travel
```

The convergence point is not a bigger `Store` facade. It is the moment a
contract manifest can generate or bind a typed `Record` / `History` class, route
its normalized mutation intent through `Igniter::Companion::Store`, and persist
as facts through `Igniter::Store::IgniterStore`.

## Current Alignment

- app-local Companion proves vocabulary and boundaries:
  `persist`, `history`, `field`, `index`, `scope`, `command`, relations,
  storage plans, access paths, and typed effect intent descriptors
- `igniter-companion` proves the intended developer surface:
  typed records, append-only histories, scopes, replay, time-travel, and
  scope-level invalidation callbacks
- `igniter-store` proves the substrate:
  immutable content-addressed facts, causation chains, current reads,
  time-travel reads, access path registry, read cache invalidation, and WAL
  replay

## Current Sidecar Proof

Companion now exposes a tiny convergence sidecar:

- `/setup/store-convergence-sidecar`
- `/setup/store-convergence-sidecar.json`
- `/setup/companion-store-app-flow-sidecar`
- `/setup/companion-store-app-flow-sidecar.json`

This packet is report-only and ephemeral. It creates an in-memory
`Igniter::Companion::Store`, defines package-level typed classes for one
`Reminder` record and one `TrackerLog` history, and exercises the path into
`Igniter::Store::IgniterStore`.

Proved:

- `Igniter::Companion.from_manifest` now generates typed package Record/History
  classes from app-local persistence manifests
- `Reminder` contract manifest generates the typed package Record class
- Record write/read/scope works through `Igniter::Companion::Store`
- Record time-travel read returns the earlier `:open` state
- Record causation chain has two facts
- Record writes now return normalized `WriteReceipt` data with fact metadata
  and delegation back to the typed record
- `TrackerLog` contract manifest generates the typed package History class
- float values round-trip as `[7.0, 8.5]`
- `TrackerLog` declares `partition_key :tracker_id`
- `Store#replay(partition: "sleep")` filters the append-only history stream by
  the declared partition key
- history appends now return normalized `AppendReceipt` data with fact metadata
  and delegation back to the typed event
- facts expose receipt data through `fact_id`, `value_hash`, and `timestamp`
- app-local manifests now expose `storage.name`, so `from_manifest(manifest)`
  can bind the package store/history name without a `store:` override
- the app-flow sidecar proves one app-pattern `Reminder` write/read/scope cycle
  through `Igniter::Companion::Store` and returns a normalized write receipt
- the packet does not mutate main Companion state or replace the current app
  backend

## Pressure Points

1. App-local Companion has richer manifests than `igniter-companion` classes.
   The sidecar can now generate `field`, `scope`, and `partition_key` from
   manifests through the package facade, but the facade still does not consume
   the full descriptor vocabulary: portable field types, enum values, indexes,
   command metadata, relation metadata, or manifest export.

2. `igniter-store` has facts and access paths, but command intent still lives
   above it. R2d now says commands should keep lowering to `mutation_intent`,
   while future storage effects are typed as `store_write` / `store_append`.

3. Reactive semantics are intentionally cache-invalidation based. This is useful
   for view refresh, but not enough for "every mutation" subscribers. That
   pressure belongs in store research as either WAL tail, event bus, or explicit
   eager access path listeners.

4. History append uses generated fact keys. App-level `history key:
   :tracker_id` now has a first package answer in `igniter-companion`:
   `partition_key :tracker_id` plus `Store#replay(partition:)`. The first
   implementation filters in Ruby after `IgniterStore#history`; future store
   work can decide whether this becomes an indexed access path.

5. Normalized receipts now exist at the package facade. The next app-local
   question is whether `mutation_intent -> app boundary -> action history`
   should consume these receipts directly or project a smaller app receipt
   shape.

6. Blob-JSON SQLite in the app remains a useful POC backend, but the next true
   convergence proof should be a tiny isolated adapter slice, not a full
   Companion migration.

## Recommendation Requests

For `igniter-store` research:

- What is the minimal fact descriptor needed to represent `Store[T]` versus
  `History[T]` without importing app-level DSL concepts?
- Should append-only histories promote partition filtering to first-class store
  access paths, or keep first-pass Ruby-layer filtering?
- Should "every mutation" observation be modeled as WAL tail, event bus, eager
  access path, or a separate `History[StoreEvent]`?
- How should typed effect intent map to facts: direct `write/append`, command
  receipt fact, normalized facade receipt, or all three?

For `igniter-companion` research:

- `manifest_generated_record_history_classes`, `store_name_in_manifest`,
  `companion_store_backed_app_flow`, and `portable_field_types` are resolved as
  report-only proofs. Next app-boundary pressure is
  `mutation_intent_to_app_boundary`, followed by index metadata,
  command/effect metadata, and relation metadata.
- Should `storage.name` remain the canonical capability identity, or should it
  later split into separate package store name and app capability name?
- Which app-local descriptors should be mirrored first: field type, scope,
  index, or command metadata?
- Can `Igniter::Companion::Store` receipts be shaped into the app-local
  `mutation_intent -> app boundary -> action history` model without leaking
  substrate details?

For app-local Companion:

- Keep R2a-R2d as the read-before-write ladder.
- Do not replace the SQLite JSON backend yet.
- The tiny sidecar proof is now present and updated for partition replay plus
  normalized receipts.
- The app-flow sidecar is sufficient to close `companion_store_backed_app_flow`
  as an isolated proof, not as an app backend migration.
- Portable field types are mirrored into generated package classes as
  annotation-only metadata (`type`, `values`), without coercion.
- Next app-boundary pressure is `mutation_intent_to_app_boundary`: decide
  whether package write receipts feed action history directly or via projection.

## Non-Goals

- no core graph nodes from this note
- no public API promise for `persist`, `history`, `field`, `index`, `scope`, or
  `command`
- no migration of the full Companion app to fact storage yet
- no SQL generation or migration execution
- no materializer write/git/test/restart capabilities

## Handoff

```text
[Architect Supervisor / Codex]
Track: companion-store-convergence
Status: alignment note plus tiny sidecar proof updated with partition replay
and normalized receipts.
[D] App-local Companion owns vocabulary pressure; igniter-companion owns typed
developer surface; igniter-store owns fact substrate.
[D] Current bridge proves manifest-generated Record/History bindings over
Igniter::Companion::Store as a tiny sidecar proof, including partition replay
and normalized receipts.
[R] Preserve `persist -> Store[T]`, `history -> History[T]`, and command ->
mutation_intent -> app boundary.
[R] Do not migrate full Companion storage or promote API from this note alone.
[S] `/setup/store-convergence-sidecar.json` proves record/history fact-store
round trip, partition replay, and normalized receipt metadata.
Next: decide the first additional manifest descriptor to mirror into the
package facade before a broader adapter slice.
```
