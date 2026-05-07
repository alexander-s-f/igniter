# Track: Ledger TBackend Adapter Descriptor v0

Card: S2-R12-C3-P
Role: `[Igniter-Lang Bridge Agent]`
Track: `ledger-tbackend-adapter-descriptor-v0`
Status: done
Date: 2026-05-07

Affected neighbor roles: `[Igniter-Lang Research Agent]`, `[Igniter-Lang Compiler/Grammar Expert]`

---

## Current Horizon

- R11 defined conformance for a future Ledger-backed TBackend adapter without package binding.
- R10 proved metadata-driven adapter selection with descriptor hash and hook load check.
- Ledger Open Protocol has descriptor, metadata snapshot, fact IO, replay, compact, and subscribe vocabulary.
- This slice proves only a metadata descriptor builder in `igniter-lang`.
- No Ledger package code, runtime binding, reads, writes, replay, or migration behavior is introduced.

---

## Descriptor Claim

`LedgerTBackendAdapterDescriptor v0` is a language-facing metadata profile built
from Ledger Open Protocol metadata/descriptor snapshots. It declares what a
future adapter can claim, but it does not execute those operations.

Shape:

```text
Ledger metadata_snapshot + descriptor_snapshot
  -> ledger_tbackend_adapter_descriptor
  -> descriptor_hash + descriptor_registry_hash
  -> diagnostics against .igapp temporal_backend requirements
```

The descriptor is safe to prove inside `igniter-lang` because it uses sample
snapshot packets only. It does not require `packages/igniter-ledger` code.

---

## Descriptor Schema

```json
{
  "kind": "ledger_tbackend_adapter_descriptor",
  "adapter_kind": "ledger_open_protocol",
  "adapter_ref": "adapter:ledger-open-protocol/proof-descriptor",
  "adapter_version": "0.1.0-proof",
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
    "sync_hub_profile",
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
    "truncation_reported": true,
    "tie_breaker": "timestamp_then_fact_id_required"
  },
  "schema_fingerprint": "sha256:<compiled-schema-or-adapter-schema>",
  "descriptor_registry_hash": "sha256:<metadata+descriptor-snapshots>",
  "evidence_mode": "receipt_required",
  "source_snapshots": {
    "metadata_snapshot_present": true,
    "descriptor_snapshot_present": true
  },
  "non_authorization": {
    "runtime_binding": false,
    "ledger_reads": false,
    "ledger_writes": false,
    "ledger_replay": false
  },
  "descriptor_hash": "sha256:<canonical-descriptor>"
}
```

| Field | Source | Meaning |
|---|---|---|
| `adapter_kind` | fixed bridge value | Keeps Ledger explicit and optional |
| `adapter_version` | bridge profile | Version of this metadata descriptor shape |
| `contract_version` | TBackend requirement | Binds claims to `tbackend.v0` |
| `protocol_schema_version` | Ledger snapshot | Records packet version compatibility |
| `ledger_protocol_ops` | package docs / snapshot capability input | Protocol operations the descriptor claims to map |
| `supported_tbackend_ops` | derived | Six-op TBackend subset supported by protocol ops |
| `hook_methods` | derived | RuntimeMachineHook shim methods that a future adapter may expose |
| `capabilities` | derived | `history_read` / `bihistory_read` gates |
| `history_axes` | derived | Valid-time and bitemporal axis claims |
| `cursor_policy` | derived | Replay ordering, cursor kind, truncation, tie-breaker requirement |
| `schema_fingerprint` | caller/compiler input | Schema compatibility anchor |
| `descriptor_registry_hash` | metadata + descriptor snapshots | Binds adapter claims to observed Ledger descriptor state |
| `evidence_mode` | fixed bridge value | Requires receipts/observations later |
| `non_authorization` | fixed bridge value | Makes runtime/package behavior explicitly false |
| `descriptor_hash` | canonical hash | Stable adapter descriptor identity |

---

## Ledger Snapshot Mapping

The proof maps only metadata/descriptor vocabulary:

| Ledger Open Protocol source | Descriptor use |
|---|---|
| `metadata_snapshot.stores` | `read` support and `read_as_of` if store descriptors expose `as_of_read` style capability |
| `metadata_snapshot.histories` | `bihistory_at`, `bihistory_read`, and `transaction_time` axis only when a history descriptor exists |
| `metadata_snapshot.subscriptions` | `subscribe` support only; never trusted History by itself |
| `metadata_snapshot.retention` | `compact` support and future preserve-set diagnostics |
| `descriptor_snapshot` | canonical registry evidence and `descriptor_registry_hash` |
| protocol ops `read` / `query` / `fact_ref` | TBackend `read` claim |
| protocol ops `write` / `write_fact` / `append` | TBackend `append` claim |
| protocol ops `replay` / `sync_hub_profile` | TBackend `replay` claim and timestamp cursor policy |
| protocol ops `metadata_snapshot` / `descriptor_snapshot` / `sync_hub_profile` | TBackend `snapshot` claim, descriptor-only unless state-bearing snapshot is later proven |
| protocol op `compact` | TBackend `compact` claim |
| protocol op `subscribe` | TBackend `subscribe` claim |

The fixture intentionally does not inspect package classes or call package
methods. It treats Ledger Open Protocol as packet vocabulary.

---

## Diagnostics Shape

The proof-local diagnostics compare a requirement against the descriptor:

```json
{
  "kind": "ledger_tbackend_adapter_descriptor_diagnostics",
  "status": "ok | blocked",
  "missing_ops": [],
  "missing_hook_methods": [],
  "missing_capabilities": [],
  "missing_axes": [],
  "schema_fingerprint_match": true,
  "descriptor_hash": "sha256:<descriptor>",
  "descriptor_registry_hash": "sha256:<snapshots>"
}
```

The required metadata-only requirement used by the proof:

```json
{
  "required_ops": ["read", "append", "replay", "snapshot"],
  "required_hook_methods": ["read_as_of", "bihistory_at"],
  "required_capabilities": ["history_read", "bihistory_read"],
  "history_axes": ["valid_time", "transaction_time"],
  "schema_fingerprint": "sha256:compiled-schema-proof"
}
```

Negative diagnostic:

```text
metadata_snapshot without histories
  -> missing_hook_methods: ["bihistory_at"]
  -> missing_capabilities: ["bihistory_read"]
  -> missing_axes: ["transaction_time"]
  -> status: blocked
```

---

## Proof Fixture

Added:

```text
igniter-lang/experiments/ledger_tbackend_adapter_descriptor_fixture/ledger_tbackend_adapter_descriptor_fixture.rb
```

The fixture proves:

- canonical `descriptor_hash` stability for identical snapshot input
- full metadata descriptor satisfies the metadata-only requirement
- missing history descriptors block `bihistory_at` / `bihistory_read`
- descriptor explicitly does not authorize runtime binding or Ledger operations

Proof command:

```bash
ruby igniter-lang/experiments/ledger_tbackend_adapter_descriptor_fixture/ledger_tbackend_adapter_descriptor_fixture.rb
```

Observed result:

```text
PASS descriptor hash is stable
PASS full descriptor satisfies metadata-only requirement
PASS missing history blocks bihistory capability
PASS fixture does not authorize runtime or ledger operations
```

---

## Red Lines Before Package Implementation

- No package edits were made.
- No Ledger package classes are required by the fixture.
- No Ledger reads, writes, replay, compact, subscribe, or RuntimeMachine binding.
- No production adapter API is authorized by this descriptor alone.
- No migration execution, Ledger history rewrite, or multi-hop migration.
- No `read_as_of` or `bihistory_at` implementation against Ledger yet.
- No claim that descriptor-only snapshots can satisfy RuntimeMachine checkpoint
  resume; state-bearing snapshot proof is separate.
- No collapsing of `backend_check` and `schema_check`.
- No raw package return values count as language evidence without receipt or
  observation wrapping.

---

## Recommendation

The first package-side slice can now be precise and still metadata-only:

```text
LedgerTBackendAdapterDescriptor v0
  -> build from metadata_snapshot / descriptor_snapshot
  -> report supported TBackend ops, hook methods, capabilities, axes
  -> compute descriptor_hash and descriptor_registry_hash
  -> expose diagnostics only
```

Do not include RuntimeMachine binding, Ledger reads/writes/replay, package
adapter selection, or migration behavior in that first package slice.

---

## Handoff

```text
[Igniter-Lang Bridge Agent]
Card: S2-R12-C3-P
Track: ledger-tbackend-adapter-descriptor-v0
Status: done

[D] Decisions:
- LedgerTBackendAdapterDescriptor v0 is descriptor-only and packet-shaped.
- Descriptor hash and descriptor registry hash are canonical evidence anchors.
- Hook methods/capabilities/axes are derived from protocol ops plus descriptor
  snapshot content, not from package class probing.
- Missing history descriptors block bihistory capability claims.

[S] Signals:
- R11 conformance expectations are now backed by a proof-local descriptor fixture.
- The fixture maps Ledger Open Protocol snapshot vocabulary into TBackend
  metadata without binding Ledger runtime behavior.
- Non-authorization is explicit in descriptor payload.

[T] Tests / Proofs:
- ruby igniter-lang/experiments/ledger_tbackend_adapter_descriptor_fixture/ledger_tbackend_adapter_descriptor_fixture.rb -> PASS

[R] Risks / Recommendations:
- Timestamp cursor policy still needs package-side tie-breaking proof before
  exact replay/resume can be trusted.
- Descriptor-only snapshots are not state-bearing checkpoint evidence.
- First package implementation should remain metadata-only and diagnostics-only.

[Next] Ask Architect Supervisor to approve package-side
LedgerTBackendAdapterDescriptor v0 with no RuntimeMachine or Ledger operation binding.
```
