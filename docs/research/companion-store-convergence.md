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

## Pressure Points

1. App-local Companion has richer manifests than `igniter-companion` classes.
   The package facade currently has `field` and `scope`, but not the full
   descriptor vocabulary: portable field types, enum values, indexes, command
   metadata, relation metadata, or manifest export.

2. `igniter-store` has facts and access paths, but command intent still lives
   above it. R2d now says commands should keep lowering to `mutation_intent`,
   while future storage effects are typed as `store_write` / `store_append`.

3. Reactive semantics are intentionally cache-invalidation based. This is useful
   for view refresh, but not enough for "every mutation" subscribers. That
   pressure belongs in store research as either WAL tail, event bus, or explicit
   eager access path listeners.

4. History append uses generated fact keys. That is fine for append-only facts,
   but app-level `history key: :tracker_id` still needs a clear lowering:
   partition key, event payload key, or both.

5. Blob-JSON SQLite in the app remains a useful POC backend, but the next true
   convergence proof should be a tiny isolated adapter slice, not a full
   Companion migration.

## Recommendation Requests

For `igniter-store` research:

- What is the minimal fact descriptor needed to represent `Store[T]` versus
  `History[T]` without importing app-level DSL concepts?
- Should append-only histories expose partition keys as first-class access path
  descriptors?
- Should "every mutation" observation be modeled as WAL tail, event bus, eager
  access path, or a separate `History[StoreEvent]`?
- How should typed effect intent map to facts: direct `write/append`, command
  receipt fact, or both?

For `igniter-companion` research:

- Can the package facade accept a manifest-generated class without committing to
  the final public DSL?
- Which app-local descriptors should be mirrored first: field type, scope,
  index, or command metadata?
- Can `Igniter::Companion::Store` return a normalized receipt that matches
  Companion's current `mutation_intent -> app boundary -> action history` model?

For app-local Companion:

- Keep R2a-R2d as the read-before-write ladder.
- Do not replace the SQLite JSON backend yet.
- Next convergence slice should be a tiny sidecar proof, for example one
  `Reminder` record and one `TrackerLog` history flowing through
  `Igniter::Companion::Store` beside the existing app state.

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
Status: alignment note created after reading packages/igniter-companion and
packages/igniter-store.
[D] App-local Companion owns vocabulary pressure; igniter-companion owns typed
developer surface; igniter-store owns fact substrate.
[D] Current bridge should be manifest-generated Record/History bindings over
Igniter::Companion::Store, first as a tiny sidecar proof.
[R] Preserve `persist -> Store[T]`, `history -> History[T]`, and command ->
mutation_intent -> app boundary.
[R] Do not migrate full Companion storage or promote API from this note alone.
[S] Use this note to ask Store/Companion research targeted questions before R3
materializer dry-run or any adapter slice.
Next: decide whether the next implementation remains R3 materializer dry-run or
a small sidecar convergence proof over Reminder/TrackerLog.
```
