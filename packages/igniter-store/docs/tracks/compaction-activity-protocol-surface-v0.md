# Track: Compaction Activity Protocol Surface v0

Status date: 2026-05-04
Status: ready
Supervisor: [Architect Supervisor / Codex]
Agent: Package Agent / Companion+Store (pkg:companion-store)

## Goal

Expose the unified compaction lifecycle activity through Store Open Protocol and
server read surfaces.

Previous slice established:

```text
compact = semantic/lifecycle
prune   = exact fact-id executor
purge   = physical storage artifact executor

IgniterStore#compaction_activity(store: nil)
  -> normalized retention compaction + exact prune + segment purge activity
```

This slice should make that read model available to remote clients without
direct Ruby access.

Keep this slice read-only. Do not add remote compact/prune/purge commands yet.

## Read First

Use the compact fresh-chat route:

1. `docs/package-agent-onboarding.md`
2. `docs/progress.md`
3. `docs/tracks/compaction-lifecycle-unification-v0.md`
4. this track

Then inspect only protocol/adapter files needed for this track.

## Scope A: Protocol Interpreter

Add a protocol method:

```ruby
Protocol::Interpreter#compaction_activity(store: nil, kind: nil, since: nil, limit: nil)
```

Suggested response shape:

```ruby
{
  schema_version: 1,
  generated_at: "...",
  filters: {
    store: "orders",
    kind: "exact_prune",
    since: 1_714_000_000.0,
    limit: 50
  },
  activity: [
    {
      kind: :retention_compaction,
      executor: :store_compact,
      store: :orders,
      status: :ok,
      reason: :rolling_window,
      fact_count: 12,
      receipt_id: "...",
      occurred_at: 1_714_000_001.25
    }
  ],
  count: 1
}
```

Filtering rules:

- `store:` delegates to `IgniterStore#compaction_activity(store:)` when present.
- `kind:` filters normalized entries by `kind`.
- `since:` returns entries with `occurred_at >= since`.
- `limit:` caps result count after filtering.

Default:

```text
store: nil, kind: nil, since: nil, limit: nil
```

This is acceptable because activity is a compact receipt stream, not full fact
replay. MCP may still require or recommend `limit` if desired.

## Scope B: Wire Envelope Operation

Add a read-only wire op:

```text
:compaction_activity
```

Packet:

```ruby
{
  store: "orders",      # optional
  kind: "exact_prune",  # optional
  since: 1_714_000_000, # optional
  limit: 50             # optional
}
```

Response:

```text
standard WireEnvelope ok/error wrapper
result = Protocol::Interpreter#compaction_activity(...)
```

Acceptance should include:

- operation listed in `WireEnvelope::OPERATIONS`
- dispatch returns same result as interpreter method
- unknown filters do not mutate anything
- errors are envelope errors, not raised exceptions

## Scope C: HTTP Read Endpoint

Add a direct GET endpoint:

```text
GET /v1/compaction/activity
```

Query params:

```text
?store=orders
?kind=exact_prune
?since=1714000000
?limit=50
```

Suggested behavior:

- `GET` returns JSON protocol result.
- Non-GET returns 405.
- Invalid numeric `since` / `limit` returns 400 with a clear JSON error.
- The endpoint uses the interpreter, not backend internals.
- Keep `/v1/dispatch` as the canonical transport; this route is an operator
  convenience like `/v1/metadata` and `/v1/status`.

## Scope D: MCP Tool

Add read tool:

```text
compaction_activity
```

Wire mapping:

```ruby
TOOL_TO_OP[:compaction_activity] = :compaction_activity
```

Tool schema:

```json
{
  "type": "object",
  "properties": {
    "store": { "type": "string" },
    "kind":  { "type": "string" },
    "since": { "type": "number" },
    "limit": { "type": "integer" }
  }
}
```

Required behavior:

- local MCP adapter returns interpreter result
- remote MCP adapter dispatches through `/v1/dispatch`
- source_protocol_op is `:compaction_activity`
- tool list includes the new read tool by default

## Scope E: Sync Profile Alignment

`SyncProfile` currently has `compaction_receipts`.

Do not remove it in this slice.

Additive option, if low impact:

```text
SyncProfile#compaction_activity
```

or include normalized activity under descriptors / metadata if that is the
local pattern.

If adding a field is too much churn, leave a clear TODO in the handoff. The
important requirement for this slice is protocol/wire/http/mcp read access.

## Acceptance

- Full package test suite passes.
- Existing protocol, wire, HTTP, MCP, OP4, and observability specs remain green.
- `Protocol::Interpreter#compaction_activity` returns normalized activity with
  schema_version, generated_at, filters, activity, count.
- Interpreter filtering by store/kind/since/limit is covered.
- `WireEnvelope::OPERATIONS` includes `:compaction_activity`.
- Wire dispatch result agrees with interpreter result.
- `/v1/compaction/activity` returns the same protocol result for GET.
- `/v1/compaction/activity` rejects non-GET with 405.
- Invalid HTTP filter params return 400, not 500.
- MCP default read tools include `:compaction_activity`.
- MCP local and remote paths work and report source op `:compaction_activity`.
- No mutating compact/prune/purge operation is exposed.
- Track handoff is appended at the end of this file.

## Non-Goals

- Do not add remote compact/prune/purge commands.
- Do not add auth/TLS.
- Do not move boundary-specific activity into core store activity beyond the
  already-added proof-local bridge.
- Do not remove `compaction_receipts` from SyncProfile.
- Do not expose full pruned fact payloads.

## Risks / Watch Points

- Keep this operation bounded by compact receipt/activity data, not full fact
  replay.
- HTTP route order matters. Avoid prefix shadowing with existing `/v1/events`.
- JSON parsing can stringify symbols; specs should compare by `.to_s` where
  adapter boundaries serialize values.
- Remote MCP should go through the wire op, not call HTTP convenience endpoint.

## Handoff Template

```text
[Package Agent / Companion+Store]
Track: igniter-store/compaction-activity-protocol-surface-v0
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
