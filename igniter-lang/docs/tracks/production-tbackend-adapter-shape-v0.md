# Track: Production TBackend Adapter Shape v0

Card: S2-R9-C3-P
Role: `[Igniter-Lang Bridge Agent]`
Track: `production-tbackend-adapter-shape-v0`
Status: done
Date: 2026-05-07

Affected neighbor roles: `[Igniter-Lang Research Agent]`, `[Igniter-Lang Compiler/Grammar Expert]`

---

## Current Horizon

- Stage 2 is open; History/BiHistory proof stack and RuntimeMachineHook proof are PASS.
- Production RuntimeMachine temporal integration is still open at adapter selection and CompatibilityReport persistence.
- RuntimeMachineHook currently expects capability-gated `read_as_of` and `bihistory_at` methods.
- TBackend remains the six-op temporal substrate contract: `read`, `append`, `replay`, `snapshot`, `compact`, `subscribe`.
- Ledger Open Protocol and Durable Model can satisfy the shape as adapters; neither is language core.

---

## Claim

The first practical production bridge is a thin adapter registry:

```text
.igapp runtime metadata
  -> adapter requirement
  -> adapter descriptor / capability check
  -> RuntimeMachineHook load_check
  -> selected adapter exposes read_as_of / bihistory_at
  -> temporal_access_evaluation with evidence_links
```

This track defines the bridge shape only. It does not authorize package
implementation, production migration behavior, multi-hop migration, Ledger as a
mandatory backend, or Durable Model replay rewrites.

---

## RuntimeMachineHook To TBackend Contract

`RuntimeMachineHook` is the runtime edge. It does not need to know every backend
operation directly; it needs a selected adapter that can present the hook methods
with evidence-producing semantics.

| RuntimeMachineHook need | TBackend op(s) | Required metadata | Evidence output | Boundary |
|---|---|---|---|---|
| Load-time valid-time read check | `read` | `history_read`, `read_as_of`, explicit `as_of` policy, schema fingerprint | `temporal_access_hook_load_check` | blocks on missing cap/method |
| Load-time bitemporal read check | `read` + bitemporal axis support | `bihistory_read`, `bihistory_at`, `valid_time` + `transaction_time`, schema fingerprint | `temporal_access_hook_load_check` | blocks on missing cap/method |
| Evaluate `History[T].at(t)` | `read` | subject/store ref, `as_of`, type hint, adapter descriptor ref | `history_access_observation` + selected append/fact link | CORE only with explicit time |
| Evaluate `BiHistory[T][vt, tt]` | `read` over bitemporal index, optionally backed by `replay` | history ref, `vt`, `tt`, node name, axes descriptor | `bihistory_access_observation` + selected event link | ESCAPE capability-gated |
| Reproducible resume from cursor | `replay` | replay cursor, filter, limit/window, schema fingerprint | `ReplaySessionDescriptor`, cursor evidence | ESCAPE stream; must be bounded for proof |
| Checkpoint / fast resume | `snapshot` | projection horizon, fact scope, rule/schema versions | `SnapshotRef` content hash | reproducibility witness |
| Emit durable observations/receipts | `append` | well-formed ObsPacket, idempotency key when applicable | `AppendReceipt` / receipt observation | append must be observable |
| Retention / compaction | `compact` | compaction policy, preserve set, dry-run/notify flag | `CompactionReceipt`, new baseline cursor | blocked if silent or loses required evidence |
| Live reactive tail | `subscribe` | slice ref, cursor/filter, subscription capability | `SubscriptionDescriptor`, delivered obs links | ESCAPE; not trusted History until snapshotted |

Adapter rule: the registry may bind a rich six-op backend, but the object passed
to `RuntimeMachineHook` must expose:

```ruby
supports_capability?(capability) -> true | false
read_as_of(subject, as_of) -> [Option[T], observation]
bihistory_at(history_ref, vt:, tt:, node_name:) -> [Option[T], observation]
```

The six-op contract is still the compatibility and durability surface. The hook
methods are the production shim used by RuntimeMachine evaluation.

---

## Adapter Selection Shape

The `.igapp` should grow a runtime metadata section that is still metadata-only:

```json
{
  "runtime_requirements": {
    "temporal_backend": {
      "contract_version": "tbackend.v0",
      "required_ops": ["read", "append", "replay", "snapshot"],
      "required_hook_methods": ["read_as_of", "bihistory_at"],
      "required_capabilities": ["history_read", "bihistory_read"],
      "history_axes": ["valid_time", "transaction_time"],
      "schema_fingerprint": "sha256:<compiled-schema>",
      "adapter_kind": "ledger_open_protocol | durable_model | memory | file | custom",
      "evidence_policy": "receipt_required"
    }
  }
}
```

Selection steps:

1. RuntimeMachine reads `.igapp` runtime requirements after manifest and contract
   verification, before CompatibilityReport trust is granted.
2. AdapterRegistry matches an adapter descriptor by `adapter_kind`,
   `contract_version`, required ops, hook methods, axes, and schema fingerprint.
3. Missing capabilities, missing hook methods, wrong axes, or schema mismatch
   produce a blocked load check and a failure observation.
4. A replay-only or subscribe-only source cannot satisfy point temporal access
   until it can expose `read_as_of` / `bihistory_at` or a closed snapshot.
5. The selected adapter descriptor hash is included in CompatibilityReport
   backend/temporal diagnostics and in every temporal access observation.

Minimal adapter descriptor:

```json
{
  "kind": "tbackend_adapter_descriptor",
  "adapter_ref": "adapter:ledger/open-protocol/main",
  "adapter_kind": "ledger_open_protocol",
  "contract_version": "tbackend.v0",
  "supported_ops": ["read", "append", "replay", "snapshot", "compact", "subscribe"],
  "hook_methods": ["read_as_of", "bihistory_at"],
  "capabilities": ["history_read", "bihistory_read"],
  "history_axes": ["valid_time", "transaction_time"],
  "schema_fingerprint": "sha256:<adapter-schema>",
  "evidence_mode": "receipt_required",
  "descriptor_hash": "sha256:<canonical-adapter-descriptor>"
}
```

---

## Ledger / Durable Model Mapping

Ledger Open Protocol maps cleanly as a TBackend adapter:

| TBackend op | Ledger Open Protocol shape | History/BiHistory use |
|---|---|---|
| `read` | `read(store:, key:, as_of:)`, `query(..., as_of:)`, `fact_ref` | point History reads; bitemporal read uses adapter-maintained axes |
| `append` | `write`, `write_fact`, `append(history:, event:, ...)` | append-only events, receipts, causation links |
| `replay` | `replay(from:, to:, filter:)`, sync profile cursors | rebuild History/BiHistory slices by forward cursor |
| `snapshot` | metadata/projection/sync snapshots | checkpoint horizon or read-optimized materialization |
| `compact` | `compact(store:, before:, policy:)` and compaction receipts | preserve required evidence and emit new baseline cursor |
| `subscribe` | `subscribe(subscription_packet)` | live invalidation tail; ESCAPE until snapshotted |

Durable Model can sit above Ledger or another backend as an application facade:

| Durable Model concept | Adapter interpretation |
|---|---|
| Record current state | `Store[T]` / point `read_as_of` projection |
| History class/event stream | `History[T]` append/replay source |
| Partition key | subject/scope component in adapter requests |
| Receipt / command result | `append` receipt or receipt observation |
| Replayable model state | `snapshot` plus forward `replay` cursor |
| Corrections/restatements | `BiHistory[T]` events with valid-time and transaction-time axes |

The adapter must preserve Ledger/Durable evidence links as language evidence:
`caused_by`, `produced_by`, `produced_in`, selected fact/event refs, replay
cursors, snapshot refs, schema fingerprints, and adapter descriptor hashes.

---

## Minimal Pseudo-Proof

```text
Given:
  .igapp runtime_requirements.temporal_backend requires:
    ops: read, replay, snapshot
    hook_methods: read_as_of, bihistory_at
    capabilities: history_read, bihistory_read
    axes: valid_time, transaction_time
    schema_fingerprint: sha256:S

And:
  AdapterRegistry contains LedgerOpenProtocolAdapter descriptor:
    supported_ops includes read, append, replay, snapshot
    hook_methods includes read_as_of, bihistory_at
    capabilities include history_read, bihistory_read
    schema_fingerprint == sha256:S

When:
  RuntimeMachine.load(.igapp) runs adapter selection and RuntimeMachineHook.load_check

Then:
  load_check.status == ok
  CompatibilityReport.backend_check includes selected adapter descriptor hash
  CompatibilityReport.schema_check remains independent and must still be ok/trusted

When:
  RuntimeMachine evaluates temporal_access_node "status_at_dispatch"
  with vt = "2026-05-07T09:00:00Z" and tt = "2026-05-07T10:00:00Z"

Then:
  adapter.bihistory_at(history_ref, vt:, tt:, node_name:) is called
  result is Option[T]
  observation.kind == "bihistory_access_observation"
  evidence_links include selected_event_ref
  no ambient clock or raw latest read is used
```

Negative cases:

```text
missing history_read / bihistory_read     -> blocked load_check
missing read_as_of / bihistory_at         -> blocked load_check
schema_fingerprint mismatch              -> blocked unless CompatibilityReport allows it
subscribe-only adapter                    -> blocked for point History/BiHistory reads
replay cursor compacted without baseline  -> blocked resume
silent compaction                         -> ESCAPE/failure; no trusted evidence chain
```

---

## Risks

- Compatibility drift: adapter schema and compiled schema can agree on names but
  disagree on meaning. Mitigation: compare schema fingerprint and descriptor hash
  in CompatibilityReport, not just adapter kind.
- Capability leakage: a Ledger/Durable adapter may expose reads broader than the
  contract scope. Mitigation: runtime metadata must include scope/subject refs,
  and adapters must emit failure receipts for unauthorized subjects.
- Axes mismatch: a single-axis History adapter must not satisfy BiHistory access.
  Mitigation: explicit `history_axes` and `bihistory_read` gate.
- Replay nondeterminism: replay without stable cursor/ordering cannot prove
  History reconstruction. Mitigation: require forward cursors and truncation
  evidence for reproducible resume.
- Subscribe confusion: live tails are not trusted temporal reads. Mitigation:
  `subscribe` remains ESCAPE until a snapshot or closed replay window exists.
- Evidence loss during compaction: losing selected event/fact refs breaks
  observation semantics. Mitigation: compaction preserve set must include active
  RuntimeContract, schema descriptors, snapshots, replay cursors, and selected
  evidence refs.
- Ledger-as-core drift: Ledger is useful but must remain an adapter. Mitigation:
  keep `.igapp` requirements backend-neutral and allow memory/file/custom
  conforming adapters.

---

## Recommendation

Package work should not start directly with Ledger or Durable Model execution.
The next authorized implementation slice should be proof-local:

1. Add a small AdapterRegistry fixture inside `igniter-lang/experiments` that
   selects an adapter descriptor from `.igapp`-style metadata.
2. Feed the selected shim to `TemporalAccessRuntime::RuntimeMachineHook`.
3. Persist the selected adapter descriptor hash and load check into a
   proof-local CompatibilityReport packet.

Only after Architect approval should package agents define package-level adapter
interfaces or Ledger/Durable production bindings.

---

## Handoff

```text
[Igniter-Lang Bridge Agent]
Card: S2-R9-C3-P
Track: production-tbackend-adapter-shape-v0
Status: done

[D] Decisions:
- Production binding should select a six-op TBackend adapter, then pass a narrow
  read_as_of / bihistory_at shim into RuntimeMachineHook.
- Adapter selection belongs after .igapp verification and before trusted
  CompatibilityReport status.
- Ledger Open Protocol and Durable Model map as adapters only; neither becomes
  language core.
- Subscribe and replay remain ESCAPE surfaces unless bounded by snapshot/cursor
  evidence.

[S] Signals:
- RuntimeMachineHook proof already defines history_read / bihistory_read and
  read_as_of / bihistory_at.
- PROP-008 defines the six-op TBackend contract and backend descriptor caps.
- Ledger Open Protocol already exposes descriptor, fact IO, replay, compact,
  subscription, and metadata snapshot shapes suitable for an adapter.

[T] Tests / Proofs:
- Docs-only track; no tests run.

[R] Risks / Recommendations:
- Require schema_fingerprint, adapter descriptor hash, explicit axes, and
  receipt evidence in compatibility diagnostics.
- Do not authorize production Ledger/Durable writes, multi-hop migration,
  TBackend rewrite, or package runtime behavior from this note alone.
- Recommended next slice: proof-local AdapterRegistry fixture with
  CompatibilityReport persistence.

[Next] Ask Architect Supervisor to approve a proof-local adapter selection
fixture before any package or production adapter work.
```
