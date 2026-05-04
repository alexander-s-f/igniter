# Track: Compaction Lifecycle Unification v0

Status date: 2026-05-04
Status: ready
Supervisor: [Architect Supervisor / Codex]
Agent: Package Agent / Companion+Store (pkg:companion-store)

## Goal

Make compaction one coherent lifecycle instead of several competing deletion
mechanisms.

We now have several working primitives:

```text
IgniterStore#compact
  retention policy over hot FactLog

AvailabilityBoundaryLedger#compact_boundary
  semantic boundary compaction, redirects, logical detail_status

IgniterStore#prune_fact_ids
  exact fact-id removal with FileBackend replay barrier

SegmentedFileBackend#purge!
  physical sealed-segment deletion by storage policy

AvailabilityBoundaryLedger#purge_cleanup_execution
  boundary-safe physical detail purge
```

These should not become five different compaction systems. This slice should
establish one vocabulary, one safety shape, and a common receipt/read model
while preserving the specialized executors.

## Read First

Use the compact fresh-chat route:

1. `docs/package-agent-onboarding.md`
2. `docs/progress.md`
3. `docs/intelligent-ledger/ledger-boundaries-compaction-plan.md`
4. `docs/tracks/ledger-cleanup-execution-and-edge-index-v0.md`
5. `docs/tracks/ledger-boundary-physical-purge-barrier-v0.md`
6. this track

Then inspect only the files needed for this track.

## Core Decision

Use one lifecycle vocabulary:

```text
compact
  semantic lifecycle verb:
  reduce retained detail while preserving truth/proof

prune
  exact fact-level executor:
  remove known fact ids from the hot logical log

purge
  physical storage executor:
  remove whole storage artifacts such as sealed segments
```

Rule:

```text
No new deletion/compaction API should bypass the compaction lifecycle.
```

Executors can remain specialized, but their plans and receipts should normalize
into one inspectable compaction activity stream.

## Important Bug Pressure

The physical purge slice proved that normal `FileBackend#write_snapshot` is not
a prune barrier because WAL replay can resurrect dropped facts.

Check whether `IgniterStore#compact` still has the same risk:

```text
compact_store
  -> write compaction receipt
  -> rebuild_log!(survivors)
  -> backend.write_snapshot(@log.all_facts)
```

If the WAL remains intact, retention-compacted facts can resurrect after reopen.
This slice should close that gap or explicitly block unsafe durable compaction.

## Scope A: Retention Compact Uses The Safe Lifecycle

Update `IgniterStore#compact` / `compact_store` so retention compaction does not
use an unsafe checkpoint as its durable barrier.

Preferred behavior:

```text
retention compact
  -> compute keep/drop
  -> write existing :__compaction_receipts summary
  -> exact-prune dropped fact ids through the same safe path as prune_fact_ids
  -> durable replay barrier when FileBackend is present
```

You may refactor internals to avoid double receipts if needed, but keep the
public return shape compatible unless there is a clear reason to improve it.

Required backend behavior:

- In-memory store: retention compact still works.
- FileBackend: compacted facts do not resurrect after close/reopen.
- SegmentedFileBackend: exact retention compaction must not silently pretend to
  be durable if exact segment rewrite is unsupported.

Acceptable SegmentedFileBackend behavior for this slice:

```text
IgniterStore#compact with SegmentedFileBackend -> unsupported / blocked
```

Segment-level `SegmentedFileBackend#purge!` remains a separate executor under
the same lifecycle vocabulary.

## Scope B: Compaction Activity Read Model

Add a compact read model that lets operators and future protocol surfaces see
all compaction activity without knowing each private receipt store.

Suggested API:

```ruby
store.compaction_activity(store: nil)
```

or:

```ruby
store.compaction_events(store: nil)
```

Return normalized entries from available sources:

```text
:__compaction_receipts
:__fact_prune_receipts
backend purge_receipts, when backend responds
```

Boundary-specific receipts can remain proof-local for now, but
`AvailabilityBoundaryLedger` may expose its own normalized helper if useful:

```ruby
ledger.compaction_activity
```

Suggested normalized entry:

```ruby
{
  kind: :retention_compaction | :exact_prune | :segment_purge | :boundary_physical_purge,
  executor: :store_compact | :fact_prune | :segmented_backend | :boundary_ledger,
  store: :orders,
  status: :ok,
  reason: :rolling_window,
  fact_count: 12,
  receipt_id: "...",
  occurred_at: ...
}
```

Do not expose full pruned fact payloads.

## Scope C: Naming / Docs Guardrails

Update package docs/comments so future slices do not introduce competing terms.

Minimum docs to update:

- `docs/progress.md`
- `docs/intelligent-ledger/ledger-boundaries-compaction-plan.md`
- this track handoff

Clarify:

```text
compact = lifecycle/intention
prune   = exact fact-id removal
purge   = physical storage artifact removal
```

## Scope D: Boundary Integration Check

`AvailabilityBoundaryLedger#purge_cleanup_execution` already uses
`prune_fact_ids`.

Add a focused integration check that the boundary physical purge receipt and
Store prune receipt both show up in the normalized activity/read model without
requiring callers to scan internal stores manually.

Keep this proof-local and additive.

## Acceptance

- Full package test suite passes.
- Existing compaction, prune, file backend, segmented backend, and intelligent
  ledger specs remain green.
- Add a failing-first or explicit spec showing whether current retention compact
  resurrects facts with FileBackend; final behavior prevents resurrection.
- `IgniterStore#compact` does not use unsafe `write_snapshot` as a physical
  deletion barrier.
- Retention compaction on FileBackend survives close/reopen.
- Retention compaction on in-memory store still works.
- Retention compaction with unsupported exact-prune backend is explicit, not
  silent.
- `SegmentedFileBackend#purge!` remains available as segment-level purge; no
  exact segment rewrite is attempted.
- A normalized compaction activity/read model exists and includes retention
  compaction + exact prune activity.
- If feasible, normalized activity also includes segmented purge receipts when
  backend supports `purge_receipts`.
- Boundary physical purge can be observed through the normalized activity/read
  model or a proof-local bridge.
- Docs clearly define compact/prune/purge and state that they are one lifecycle
  with multiple executors.
- Track handoff is appended at the end of this file.

## Non-Goals

- Do not add Store Open Protocol / HTTP / MCP endpoints yet.
- Do not implement exact per-fact rewrite of segmented WAL files.
- Do not rename every existing method in this slice.
- Do not move intelligent-ledger boundary proof into core API.
- Do not store full pruned payloads in activity entries.

## Risks / Watch Points

- Avoid double-writing confusing receipts. If both compaction receipt and prune
  receipt are needed, make their relationship explicit with ids/metadata.
- `compact` must not claim success when the backend cannot durably enforce the
  result.
- Segment purge is coarser than fact prune. The shared lifecycle should expose
  this difference, not hide it.
- Keep normal checkpoint non-destructive.

## Handoff Template

```text
[Package Agent / Companion+Store]
Track: igniter-store/compaction-lifecycle-unification-v0
Status: done | partial | blocked

[D] Decisions:
- ...

[S] Shipped:
- ...

[T] Tests:
- ...

[R] Risks / next recommendations:
- ...
```
