# Track: Ledger Boundary Physical Purge Barrier v0

Status date: 2026-05-04
Status: ready
Supervisor: [Architect Supervisor / Codex]
Agent: Package Agent / Companion+Store (pkg:companion-store)

## Goal

Prove the first real boundary-detail purge without breaking ledger honesty.

Previous slices proved:

```text
boundary close/settle/compact
  -> fact redirects
  -> relation-edge redirects
  -> cleanup guard planning
  -> cleanup execution receipt
```

This slice should add the missing bridge:

```text
cleanup execution receipt
  -> final safety revalidation
  -> exact hot-log fact pruning
  -> replay barrier so pruned facts do not resurrect after reopen
  -> durable physical purge receipt
```

This is intentionally a large vertical slice. It should still stay narrow:
prove exact boundary-detail purge for the intelligent-ledger example and the
minimum Store primitive needed to make it honest.

## Read First

Use the compact fresh-chat route:

1. `docs/package-agent-onboarding.md`
2. `docs/progress.md`
3. `docs/intelligent-ledger/README.md`
4. `docs/intelligent-ledger/ledger-boundaries-compaction-plan.md`
5. `docs/tracks/ledger-boundary-reference-redirects-v0.md`
6. `docs/tracks/ledger-relation-edge-redirect-projection-v0.md`
7. `docs/tracks/ledger-boundary-cleanup-reference-guards-v0.md`
8. `docs/tracks/ledger-cleanup-execution-and-edge-index-v0.md`
9. this track

Then inspect only the files needed for this track.

## Important Discovery To Validate

`IgniterStore#compact` currently rebuilds the in-memory `FactLog` and writes a
snapshot when the backend supports it.

But `FileBackend#write_snapshot` intentionally leaves the WAL untouched. On
normal checkpoint this is correct. For physical pruning it is dangerous:

```text
snapshot contains kept facts
WAL still contains dropped facts
reopen loads snapshot + WAL facts not present in snapshot
dropped facts can resurrect
```

Validate this with a spec first. If already fixed by the time you read this,
keep the spec and document the actual behavior.

## Scope A: Store Replay Barrier For Pruning

Add the smallest Store-level primitive needed for exact fact pruning.

Suggested API:

```ruby
store.prune_fact_ids(
  fact_ids: [...],
  reason: :boundary_physical_purge,
  metadata: {},
  receipt_store: :__fact_prune_receipts
)
```

The exact name can change if a local naming pattern is clearer.

Required behavior:

- Drops exact live facts by id from the hot `FactLog`.
- Rebuilds all derived read indexes (`fact_id_index`, scope index, partition
  index, cache) by using the existing rebuild path or an equivalent safe path.
- Writes a durable prune receipt before rebuilding.
- Receipt includes compact fact refs, not full fact values.
- Idempotent enough for retries: missing fact ids are reported as missing, not
  treated as fatal.
- If backend supports durable replacement, pruned facts do not return after
  close/reopen.

Suggested receipt fields:

```ruby
{
  type: :fact_prune_receipt,
  reason: :boundary_physical_purge,
  requested_count: 12,
  pruned_count: 12,
  missing_count: 0,
  pruned_fact_refs: [
    { id:, store:, key:, transaction_time:, valid_time:, value_hash: }
  ],
  metadata: {
    source: :availability_boundary_ledger,
    plan_hash: "...",
    boundary_keys: [...]
  },
  pruned_at: ...
}
```

### FileBackend Barrier

For `FileBackend`, add a pruning-safe barrier distinct from normal checkpoint.

Suggested backend shape:

```ruby
backend.replace_with_snapshot!(facts)
```

or:

```ruby
backend.write_compacted_snapshot!(facts)
```

Semantics:

- Atomically write a snapshot containing the surviving facts.
- Only after the snapshot succeeds, truncate/rotate the WAL so old dropped facts
  cannot replay.
- Preserve normal `checkpoint` behavior as non-destructive.
- Add reopen specs proving dropped facts do not resurrect.

If native backend support is awkward, keep this Ruby-path proof explicit and
document native as a follow-up. Do not silently claim native durability if it is
not covered.

### SegmentedFileBackend

Do not implement exact fact deletion inside segments in this slice.

Acceptable behavior:

```text
store.prune_fact_ids on SegmentedFileBackend -> unsupported / blocked
```

Segment-level retention already exists, but exact per-fact rewrite of sealed
segments is a separate storage-engine slice.

## Scope B: Boundary Physical Purge Proof

Add a proof-local method to `AvailabilityBoundaryLedger`.

Suggested API:

```ruby
purge_cleanup_execution(plan_hash:, dry_run: false)
```

or:

```ruby
purge_boundary_details(execution_receipt:, dry_run: false)
```

Required behavior:

- Reads `:ledger_cleanup_execution_receipts` by `plan_hash`.
- Refuses missing or non-success execution receipts.
- Rehydrates/revalidates boundary state before pruning.
- Requires logical boundary compaction first.
- Requires redirects for every source fact that will be pruned.
- Re-runs or re-checks the reference guard immediately before pruning.
- On `dry_run: true`, returns exact facts that would be pruned and blockers.
- On `dry_run: false`, calls the Store prune primitive and writes
  `:ledger_physical_purge_receipts`.

Important: `execute_cleanup_plan` is a commit record for cleanup intent. It is
not by itself permission to delete. Physical purge must revalidate at the last
possible moment.

## Safety Rules

Physical purge is allowed only when all are true:

```text
cleanup execution receipt exists and status == executed_noop
boundary is closed
boundary is settled
boundary is logically compacted
boundary has redirect entries for all source_fact_ids
cleanup guard is still ready with require_reference_redirects: true
all relation edges targeting source facts are redirected or absent
```

If any rule fails:

```text
purge_cleanup_execution(...) -> blocked
no Store facts are removed
no successful physical purge receipt is written
```

Suggested blocked reasons:

```text
:cleanup_execution_receipt_missing
:cleanup_execution_not_successful
:boundary_compaction_required
:fact_redirect_missing
:reference_guard_failed
:store_prune_unsupported
```

## Required Behavior

### Dry Run

For a valid compacted boundary and successful cleanup execution:

```ruby
purge_cleanup_execution(plan_hash: hash, dry_run: true)
```

returns:

```ruby
{
  status: :ready,
  dry_run: true,
  fact_ids_to_prune: [...],
  boundary_keys: [...],
  blockers: []
}
```

No facts are removed.

### Actual Purge

For the same setup with `dry_run: false`:

```text
source facts are removed from live fact_id_index / FactLog
boundary receipt and compact output remain
fact redirects remain
relation edge target index remains
physical purge receipt is written
```

After purge:

```ruby
store.fact_by_id(source_fact_id) # => nil
ledger.resolve_ref(source_fact_id, fidelity: :boundary) # => redirected
ledger.full_replay(...) # => detail_unavailable
ledger.replay(...)      # => boundary output still available
```

### Idempotency

Running physical purge twice for the same cleanup execution should not create a
second successful purge or fail noisily.

Preferred result:

```ruby
{ status: :purged, deduplicated: true, ... }
```

### File-Backed Reopen

For `IgniterStore.open(path)` with `FileBackend`:

1. write boundary/source facts
2. compact boundary
3. execute cleanup plan
4. physical purge
5. close/reopen store
6. prove pruned fact ids do not return
7. prove boundary replay and redirects still work

This is the key acceptance test for the replay barrier.

## Acceptance

- Full package test suite passes.
- Existing retention/compaction specs remain green.
- New specs live under `spec/igniter/store/` and
  `spec/igniter/store/intelligent_ledger/`.
- A spec first captures whether existing FileBackend compaction can resurrect
  dropped facts; final implementation prevents resurrection for pruning.
- Store exact-prune primitive removes live facts by id and rebuilds indexes.
- Store exact-prune writes compact prune receipts without full payloads.
- FileBackend pruning barrier survives close/reopen.
- SegmentedFileBackend exact prune is either explicitly unsupported or clearly
  documented as out of scope.
- Boundary physical purge refuses un-compacted boundaries.
- Boundary physical purge refuses missing redirects.
- Boundary physical purge refuses stale unsafe reference guards.
- Boundary physical purge dry-run removes nothing.
- Boundary physical purge actual run removes source facts and preserves boundary
  replay/redirect semantics.
- Boundary physical purge is idempotent.
- Track handoff is appended at the end of this file.

## Non-Goals

- Do not implement exact per-fact rewrite of segmented WAL files.
- Do not add Store Open Protocol / HTTP / MCP purge endpoints.
- Do not implement Rust-native prune unless it falls out cheaply and is tested.
- Do not encrypt, archive, or cold-sync pruned facts in this slice.
- Do not change normal checkpoint into destructive WAL truncation.

## Risks / Watch Points

- Do not use snapshot checkpoint as a purge barrier unless WAL replay is also
  prevented from resurrecting dropped facts.
- Do not store full pruned fact payloads in receipts; that defeats purge.
- Prune receipts must survive the prune. Write them before rebuild and include
  them in surviving facts.
- Physical purge is irreversible in the hot store. Keep blockers conservative.
- If tests need direct writes to relation edge stores, remember that
  `:ledger_relation_edge_targets` is now the cleanup guard access path.

## Handoff Template

```text
[Package Agent / Companion+Store]
Track: igniter-store/ledger-boundary-physical-purge-barrier-v0
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
