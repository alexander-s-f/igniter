# Track: TBackend Ledger Bridge Conformance v0

Card: S2-R11-C3-P
Role: `[Igniter-Lang Bridge Agent]`
Track: `tbackend-ledger-bridge-conformance-v0`
Status: done
Date: 2026-05-07

Affected neighbor roles: `[Igniter-Lang Research Agent]`, `[Igniter-Lang Compiler/Grammar Expert]`

---

## Current Horizon

- `production-tbackend-adapter-shape-v0` defined metadata -> AdapterRegistry -> hook shim -> CompatibilityReport evidence.
- `production-tbackend-adapter-fixture-v0` proved that shape with a proof-local adapter descriptor and shim.
- RLM06 asks for production RuntimeMachine temporal TBackend integration.
- RLM09 asks for Ledger Open Protocol -> TBackend operation mapping.
- S16 keeps the bridge language-neutral: Store/Backend/RuntimeContract first, package classes second.

---

## Purpose

This note defines conformance expectations for a future Ledger-backed TBackend
adapter. It is not package binding authorization. The adapter may use
`packages/igniter-ledger` protocol packets, but the language surface remains the
TBackend six-op contract plus RuntimeMachineHook requirements.

Conformance means:

```text
Ledger Open Protocol packet operations
  -> LedgerTBackendAdapter descriptor
  -> six TBackend operation claims
  -> read_as_of / bihistory_at hook shim
  -> CompatibilityReport evidence
```

Ledger is a candidate adapter, not a required language substrate.

---

## Required Descriptor Fields

A conforming Ledger-backed adapter must emit a metadata descriptor before trusted
RuntimeMachine load status is granted:

```json
{
  "kind": "tbackend_adapter_descriptor",
  "adapter_kind": "ledger_open_protocol",
  "adapter_ref": "adapter:ledger-open-protocol:<instance>",
  "contract_version": "tbackend.v0",
  "protocol": "igniter_store",
  "protocol_schema_version": 1,
  "ledger_protocol_ops": [
    "register_descriptor",
    "write",
    "append",
    "write_fact",
    "read",
    "query",
    "metadata_snapshot",
    "descriptor_snapshot",
    "replay",
    "compact",
    "subscribe"
  ],
  "supported_tbackend_ops": ["read", "append", "replay", "snapshot", "compact", "subscribe"],
  "hook_methods": ["read_as_of", "bihistory_at"],
  "capabilities": ["history_read", "bihistory_read"],
  "history_axes": ["valid_time", "transaction_time"],
  "cursor_policy": {
    "ordered": "forward",
    "cursor_kinds": ["timestamp"],
    "truncation_reported": true
  },
  "schema_fingerprint": "sha256:<adapter-schema>",
  "descriptor_registry_hash": "sha256:<ledger-descriptor-snapshot>",
  "evidence_mode": "receipt_required",
  "descriptor_hash": "sha256:<canonical-adapter-descriptor>"
}
```

Minimum required fields:

| Field | Why required |
|---|---|
| `adapter_kind` | prevents Ledger from being implicit or ambient |
| `contract_version` | binds the descriptor to TBackend v0, not package internals |
| `protocol_schema_version` | records Ledger packet compatibility |
| `supported_tbackend_ops` | declares the six-op claim |
| `hook_methods` | proves RuntimeMachineHook can call the selected shim |
| `capabilities` | gates `history_read` / `bihistory_read` |
| `history_axes` | prevents single-axis adapters from satisfying BiHistory reads |
| `cursor_policy` | states replay ordering and cursor semantics |
| `schema_fingerprint` | ties adapter payload semantics to compiled requirements |
| `descriptor_registry_hash` | ties reads/replay to the Ledger descriptor snapshot |
| `evidence_mode` | requires receipts instead of raw package return values |
| `descriptor_hash` | content-addresses adapter identity in CompatibilityReport |

---

## Conformance Table

| TBackend op | Ledger Open Protocol mapping | Conformance expectation | Evidence required |
|---|---|---|---|
| `read` | `read(store:, key:, as_of:)`, `query(..., as_of:)`, `fact_ref(fact_id)` | Every read must carry explicit `as_of` or bitemporal `vt`/`tt`; result is `Option[T]`; no raw current read satisfies History access | selected `fact_id` / event ref, `value_hash`, `as_of`, adapter descriptor hash |
| `append` | `write`, `write_fact`, `append(history:, event:, partition_key:, producer:)` | Writes must return accepted/rejected/deduplicated receipt; adapter must declare whether package-level append has stable idempotency or supply adapter-level idempotency | receipt status, `fact_id`, `value_hash`, causation / producer refs |
| `replay` | `replay(from:, to:, filter:)`, `sync_hub_profile(cursor:)` | Replay is forward-only, cursor-addressed, filter-scoped, and must expose truncation/next cursor; missing replay blocks exact resume | replay cursor, filter, descriptor registry hash, truncation flag, next cursor |
| `snapshot` | `metadata_snapshot`, `descriptor_snapshot`, `projection_snapshot`, `relation_snapshot`, `sync_hub_profile` | Snapshot must state whether it is descriptor-only, projection-only, or state-bearing; only state-bearing snapshots can satisfy RuntimeMachine checkpoint resume | snapshot ref, horizon/as_of, content hash, included descriptor hash |
| `compact` | `register_retention`, `retention_snapshot`, `compact(store:, before:, policy:)` | Compaction must be observable, must preserve active RuntimeContract/schema/snapshot/replay evidence, and must emit a new baseline cursor | compaction receipt, preserve set, removed/preserved counts, new baseline cursor |
| `subscribe` | `register_subscription`, `subscribe(subscription_packet)` | Subscription is ESCAPE/live; it cannot satisfy trusted History reads until closed into replay cursor or snapshot evidence | subscription descriptor, cursor/checkpoint, observed-under links |

Hook conformance:

| Hook method | Ledger-backed implementation expectation |
|---|---|
| `read_as_of(subject, as_of)` | Resolve subject to store/key/query, call protocol read/query with explicit `as_of`, wrap selected fact as `history_access_observation` |
| `bihistory_at(history_ref, vt:, tt:, node_name:)` | Resolve history descriptor and partition/key, select event valid at `vt` and recorded by `tt`, wrap selected event as `bihistory_access_observation` |
| `supports_capability?` | Answer from descriptor capabilities, not from dynamic package probing |

---

## Capability Checks

Adapter selection must block before RuntimeMachine evaluation when any required
claim is missing:

```text
required_tbackend_ops - supported_tbackend_ops != empty
required_hook_methods - hook_methods != empty
required_capabilities - capabilities != empty
required_axes - history_axes != empty
compiled schema_fingerprint != adapter schema_fingerprint
descriptor_registry_hash missing when Ledger descriptors are used
```

Required failures:

| Failure | Compatibility result |
|---|---|
| Missing `read` or `read_as_of` for History access | `backend_check: blocked` |
| Missing `bihistory_at` or `bihistory_read` for BiHistory access | `backend_check: blocked` |
| `schema_fingerprint` mismatch | `schema_check: blocked` unless explicit approved compatibility evidence exists |
| Cursor policy not forward/replayable | `backend_check: provisional` or `blocked` for exact replay |
| Subscribe-only access | `backend_check: blocked` for point temporal reads |
| Missing receipt evidence | `backend_check: blocked` for trusted status |

---

## Replay Cursor Behavior

Ledger Open Protocol currently exposes timestamp-style sync/replay cursors. A
Ledger-backed TBackend adapter may use that cursor kind if it makes the policy
explicit and observable.

Conformance expectations:

- Replay is forward-only.
- Cursor kind and value are part of evidence, not hidden adapter state.
- Cursor filters include store/history/partition scope when used.
- Replays report `truncated` or equivalent continuation state.
- Exact resume requires either a state-bearing snapshot or a replay cursor that
  has not been compacted away.
- After compaction, the adapter must expose a new baseline cursor and preserve
  evidence refs needed by active CompatibilityReports.
- Timestamp cursors are acceptable only if the adapter declares tie-breaking or
  duplicate handling for facts/events with equal timestamps.

Non-conforming replay:

```text
ambient latest replay
reverse replay
cursor hidden in package instance state
partial replay treated as complete
compacted cursor accepted without baseline evidence
```

---

## CompatibilityReport Evidence Requirements

A trusted RuntimeMachine load using a Ledger-backed adapter must persist:

```json
{
  "dimension": "temporal_backend_adapter",
  "status": "trusted | provisional | blocked",
  "selected_adapter_descriptor_hash": "sha256:<adapter-descriptor>",
  "adapter_ref": "adapter:ledger-open-protocol:<instance>",
  "adapter_kind": "ledger_open_protocol",
  "protocol_schema_version": 1,
  "supported_tbackend_ops": ["read", "append", "replay", "snapshot", "compact", "subscribe"],
  "hook_methods": ["read_as_of", "bihistory_at"],
  "capabilities": ["history_read", "bihistory_read"],
  "history_axes": ["valid_time", "transaction_time"],
  "schema_fingerprint_match": true,
  "descriptor_registry_hash": "sha256:<ledger-descriptor-snapshot>",
  "adapter_selection_check": {
    "status": "ok",
    "missing_ops": [],
    "missing_hook_methods": [],
    "missing_capabilities": [],
    "missing_axes": [],
    "cursor_policy": "forward_timestamp"
  },
  "temporal_access_hook_load_check": {
    "kind": "temporal_access_hook_load_check",
    "status": "ok"
  },
  "evidence_links": [
    { "rel": "observed_under", "to": "sha256:<adapter-descriptor>" },
    { "rel": "described_by", "to": "sha256:<ledger-descriptor-snapshot>" }
  ]
}
```

Every temporal evaluation routed through the adapter must also carry:

- selected adapter descriptor hash
- selected fact/event ref
- `value_hash` or event content hash
- explicit `as_of` or `valid_time` + `transaction_time`
- receipt/failure ref for rejected access
- replay cursor or snapshot ref when the value came from replay/snapshot

`CompatibilityReport.schema_check` remains independent from
`backend_check`. Ledger descriptor compatibility is evidence for the backend
dimension, not a substitute for compiled schema compatibility.

---

## Language-Neutral Vs Package-Specific

Language-neutral:

- TBackend six ops and capability names.
- Explicit time requirement: `as_of`, `valid_time`, `transaction_time`.
- RuntimeMachineHook methods and load-check shape.
- CompatibilityReport dimensions and trust outcomes.
- Evidence-link semantics, receipts, schema fingerprints, descriptor hashes.
- CORE / ESCAPE / OOF boundary.

Package-specific:

- Ruby class/module names in `packages/igniter-ledger`.
- `Protocol::Interpreter` handler structure.
- Exact wire envelope class names.
- LedgerServer transport choices.
- Companion/Durable Model registration helpers.
- Internal fact id generation and storage engines.

Bridge rule: package-specific details may be used to implement the adapter, but
they must not appear as required language semantics.

---

## Red Lines / Non-Goals

- No package edits in this slice.
- Do not make Ledger mandatory or language-core.
- Do not require Igniter contracts, Ruby DSL execution, ORM classes, Rails
  conventions, materializer execution, or cluster consensus.
- Do not authorize production migration, Ledger history rewrite, or multi-hop
  migration behavior.
- Do not treat command/effect descriptors as operation execution authority.
- Do not treat live subscription events as trusted History values without
  replay/snapshot closure.
- Do not collapse `backend_check` and `schema_check` into one dimension.
- Do not accept raw package return values as evidence without receipt or
  observation wrapping.

---

## Recommendation For First Package-Side Slice

First package-side slice should be metadata-only and testable without
RuntimeMachine production binding:

```text
LedgerTBackendAdapterDescriptor v0
  -> builds from Ledger Open Protocol metadata_snapshot / descriptor_snapshot
  -> reports supported TBackend ops and hook methods
  -> computes descriptor_hash and descriptor_registry_hash
  -> exposes no production reads/writes yet
```

Acceptance for that future package slice:

- No RuntimeMachine execution path.
- No production Ledger writes.
- No migration behavior.
- Unit tests only for descriptor construction, capability reporting, missing-op
  diagnostics, cursor policy reporting, and canonical hash stability.
- Explicit Architect Supervisor approval before adding `read_as_of`,
  `bihistory_at`, or write/replay bindings.

---

## Handoff

```text
[Igniter-Lang Bridge Agent]
Card: S2-R11-C3-P
Track: tbackend-ledger-bridge-conformance-v0
Status: done

[D] Decisions:
- Ledger-backed TBackend conformance is descriptor-first: package protocol ops
  must be mapped into the language-neutral six-op contract.
- RuntimeMachineHook remains narrow: read_as_of, bihistory_at, and
  supports_capability? are the selected shim surface.
- CompatibilityReport must persist adapter descriptor hash, Ledger descriptor
  registry hash, capability checks, cursor policy, and hook load_check.
- Ledger descriptor compatibility does not replace schema_check.

[S] Signals:
- RLM06/RLM09/S16 form one bridge chain: Store/Backend contract frame ->
  Ledger Open Protocol mapping -> production RuntimeMachine TBackend integration.
- Ledger Open Protocol already has descriptors, facts, receipts, replay,
  metadata snapshots, compaction, and subscription vocabulary.
- R10 proof-local fixture already proved metadata-driven adapter selection and
  CompatibilityReport evidence shape.

[T] Tests / Proofs:
- Docs-only track; no tests run.

[R] Risks / Recommendations:
- Timestamp replay cursors need explicit duplicate/tie handling before exact
  resume can be trusted.
- Adapter-level idempotency may be needed because protocol append v0 does not
  make client-supplied keys a stable idempotency guarantee.
- First package-side slice should be descriptor-only: no reads, writes, replay,
  RuntimeMachine binding, migration, or package runtime behavior without
  explicit Architect approval.

[Next] Ask Architect Supervisor to approve a metadata-only
LedgerTBackendAdapterDescriptor v0 package slice.
```
