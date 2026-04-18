# Distributed Contracts v1

Historical reference.

For the current canonical distributed-workflow reading, start with:

- [docs/guide/distributed-workflows.md](./guide/distributed-workflows.md)
- [docs/cluster/README.md](./cluster/README.md)
- [docs/guide/deployment-modes.md](./guide/deployment-modes.md)

## What This Old Document Was Trying To Define

The V1 write-up explored how Igniter should handle long-running, correlation-aware,
event-driven workflows.

The central ideas were:

- correlation first
- external signals should be graph-visible
- transport should stay outside the workflow model
- waiting state should be observable

Those ideas are still valuable.

## What Is Still Historically Useful

### Correlation-oriented thinking

This document is still useful as historical background for why workflow lookup
should be based on business correlation keys rather than process-local state.

### Explicit wait-node thinking

It also preserves the earlier reasoning for explicit wait/signal semantics
instead of hiding delayed continuation inside generic callbacks or polling.

### Store and diagnostics expectations

The old write-up is still useful as a checklist for expectations around:

- resumability
- audit trail
- waiting-state diagnostics
- runtime/store support for delayed continuation

## What Changed Since V1

The current docs now place distributed workflow reading under:

- deployment/runtime guidance in `guide`
- cluster runtime guidance in `cluster`
- package/layer ownership in `dev`

So this V1 document should be treated as design rationale, not as the canonical
API or current implementation contract.

## If You Are Reading Old Workflow Notes

Use this file as background rationale only. For new work, always prefer:

- [docs/guide/distributed-workflows.md](./guide/distributed-workflows.md)
- [docs/cluster/README.md](./cluster/README.md)
- [docs/cluster/STATE_NEXT.md](./cluster/STATE_NEXT.md)
