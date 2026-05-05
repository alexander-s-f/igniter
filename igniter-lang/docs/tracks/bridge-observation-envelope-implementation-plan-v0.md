# Track: Bridge Observation Envelope Implementation Plan v0

Status: done
Slice state: done on 2026-05-05
Owner: `[Igniter-Lang Research Agent]`
Supervisor: `[Architect Supervisor / Codex]`

## Frame

This slice is an implementation plan, not an implementation.

It defines metadata-only packet builders for Runtime Machine lifecycle
evidence:

- RuntimeMachine
- TBackendAdapter
- SemanticImage
- Checkpoint
- Resume
- CompatibilityReport

The plan is sidecar-only:

- no package API changes
- no runtime code changes
- no database or wire format migration
- no package-level claim that these packets are already emitted
- no edits outside `igniter-lang`

## Source Horizon

- `igniter-lang/docs/proposals/PROP-005-bridge-observation-envelope-v0.md`
- `igniter-lang/docs/proposals/PROP-006-runtime-contract-specification-v0.md`
- `igniter-lang/docs/proposals/PROP-007-conformance-verification-v0.md`
- `igniter-lang/docs/proposals/PROP-008-tbackend-contract-v0.md`
- `igniter-lang/docs/tracks/bridge-observation-envelope-runtime-evidence-v0.md`
- `igniter-lang/docs/tracks/bridge-observation-envelope-package-mapping-v0.md`
- `igniter-lang/docs/tracks/runtime-machine-lifecycle-v0.md`
- `docs/dev/execution-model.md` (read-only platform context)
- `packages/igniter-ledger/lib/igniter/store/igniter_store.rb` (read-only)
- `packages/igniter-ledger/lib/igniter/store/file_backend.rb` (read-only)
- `packages/igniter-ledger/lib/igniter/store/segmented_file_backend.rb`
  (read-only)
- `packages/igniter-ledger/lib/igniter/store/changefeed_buffer.rb`
  (read-only)
- `packages/igniter-ledger/lib/igniter/store/protocol/sync_profile.rb`
  (read-only)

## Compact Claim

[D] The first bridge implementation should be a pure packet-building sidecar.

```text
package object / runtime context / explicit bridge context
  -> packet builder
  -> ObsPacket profile
  -> diagnostics + meaning_status
```

Not:

```text
package object
  -> package rewrite
  -> new runtime semantics
```

[D] The sidecar builders do not make facts more true. They make existing
evidence honest by declaring:

- which required references exist
- which references are synthetic bridge context
- which runtime/backend guarantees are missing
- which results must be downgraded from reproducible to live/provisional/stale
  or unknown

## Non-Edit Boundary

The builders may read package objects and explicit caller context. They must
not mutate package objects or require new package fields.

Allowed:

- inspect existing object fields
- use public read-only methods when available
- accept explicit sidecar context from the caller
- derive IDs, subjects, links, hashes, and diagnostics
- emit in-memory packet profiles or write them to a sidecar artifact later

Not allowed in this slice:

- adding `to_obs_packet` methods to package classes
- changing store write/checkpoint/resume behavior
- changing DurableModel receipt schemas
- changing Ledger fact shape
- emitting packets from package internals
- introducing a new wire protocol

[D] Missing metadata is a diagnostic, not a reason to edit packages in this
track.

## Builder Kernel

All builders share one small kernel contract.

```text
PacketBuilder[Input, Payload] = {
  profile_name
  output_kind
  subject(input, ctx)
  payload(input, ctx)
  links(input, ctx)
  privacy(input, ctx)
  diagnostics(input, ctx)
  meaning_status(input, ctx)
}
```

### Build Context

```text
BridgeBuildContext = {
  bridge_profile_version
  packet_space
  producer_ref
  emitted_at
  canonical_serializer_ref
  hash_algorithm_ref
  runtime_contract_ref
  axiom_descriptor_ref
  execution_environment_ref
  tbackend_adapter_ref
  verification_ref
  privacy_defaults
  synthetic_ref_policy
}
```

`BridgeBuildContext` is explicit. If a field is absent, the builder emits a
diagnostic and downgrades the packet when needed.

### Build Result

```text
BuildResult = {
  packet
  diagnostics
  missing_required_refs
  missing_optional_refs
  synthetic_refs
  meaning_status
}
```

[D] Packet construction is deterministic: same input object plus same context
must produce the same identity fields and payload hash.

## Identity Policy

Builders follow PROP-005 identity rules.

```text
packet.id =
  hash(packet.space, packet.kind, packet.subject, packet.payload_hash)
```

When payload is redacted or hash-only:

```text
packet.id =
  hash(packet.space, packet.kind, packet.subject, packet.payload_hash)
```

When no stable canonical serializer is declared:

```text
diagnostic: bridge.canonical_serializer_missing
meaning_status: max(:provisional)
```

[R] The first implementation should use one bridge-local canonical serializer
reference, but every packet must name it. Cross-language canonicalization can
be formalized later.

## Shared Wellformedness Rules

| Rule | Requirement | Failure handling |
|------|-------------|------------------|
| `BWF-1` | output `kind` is a known PROP-005 kind or approved extension | emit failure_observation profile |
| `BWF-2` | `profile_name` lives in payload or extensions, not as a new kind | downgrade malformed packet |
| `BWF-3` | required links are present or diagnostics list missing refs | downgrade to provisional/unknown |
| `BWF-4` | payload and payload_hash match privacy policy | reject builder result |
| `BWF-5` | content_hash computed before redaction | reject builder result |
| `BWF-6` | synthetic refs are labelled synthetic | packet remains inspectable only |
| `BWF-7` | runtime-produced packets link to runtime evidence | no reproducible claim if missing |
| `BWF-8` | no package object mutation | implementation violation |

## Common Link Policy

Runtime lifecycle packets use these links when available.

| Link | From | To | Required for reproducible? |
|------|------|----|----------------------------|
| `:observed_under` | lifecycle packet | `AxiomDescriptor` | yes |
| `:observed_under` | lifecycle packet | `RuntimeContract` | yes |
| `:observed_under` | lifecycle packet | `TBackendDescriptor` | yes for cross-session |
| `:produced_in` | lifecycle packet | `ExecutionEnvironment` | yes, unless redacted with diagnostic |
| `:executed_by` | value/projection/receipt/failure | RuntimeContract | yes for runtime-produced packets |
| `:caused_by` | checkpoint/resume receipt | prior lifecycle packet | yes when transition is causal |
| `:supersedes` | migrated image/report | prior image/report | yes for migration |

`executed_by` and `produced_in` are bridge vocabulary extensions from
`bridge-observation-envelope-runtime-evidence-v0`. Until PROP-005 formally
adds them, the builder should place them in typed links only in the bridge
profile and mark the packet with:

```text
extensions.bridge.link_extension: true
```

## Meaning Status Downgrade Rules

Builders never upgrade beyond the weakest evidence.

| Evidence state | meaning_status |
|----------------|----------------|
| fixed horizon + runtime + axiom + TBackend + compatible resume + trusted verification | `:reproducible` |
| moving/current horizon with visible runtime evidence | `:live` |
| missing verification, synthetic runtime ref, lossy cursor, or buffered durability | `:provisional` |
| known invalidation, incompatible newer descriptor, or cursor behind baseline | `:stale` |
| cannot determine horizon/runtime/backend compatibility | `:unknown` |

[D] `:provisional` is the expected v0 result for many package-derived packets
until session-start runtime evidence exists.

## Builder 1: RuntimeMachinePacketBuilder

Purpose: describe the semantic machine instance that owns lifecycle state.

```text
profile_name: runtime_machine_observation
kind: :descriptor_observation
subject: runtime-machine://<machine_id>
```

### Inputs

```text
RuntimeMachineInput = {
  machine_id
  lifecycle_state
  language_contract_ref
  runtime_contract_ref
  axiom_descriptor_ref
  execution_environment_ref
  tbackend_adapter_ref
  semantic_image_ref
  session_id
}
```

Sources:

- explicit `BridgeBuildContext`
- runtime-machine lifecycle state known by the sidecar caller
- RuntimeContract/AxiomDescriptor packets from boot prelude
- TBackendAdapter packet from adapter builder
- optional SemanticImage packet from checkpoint builder

### Payload

```text
RuntimeMachinePayload = {
  profile: :runtime_machine_observation
  machine_id
  lifecycle_state
  language_contract_ref
  runtime_contract_ref
  axiom_descriptor_ref
  execution_environment_ref
  tbackend_adapter_ref
  semantic_image_ref
  session_id
  bridge_profile_version
}
```

### Required Links

```text
links:
  - rel: :observed_under, ref: axiom_descriptor_ref, required: true
  - rel: :observed_under, ref: runtime_contract_ref, required: true
  - rel: :observed_under, ref: tbackend_adapter_ref, required: true
  - rel: :produced_in, ref: execution_environment_ref, required: true
```

### Diagnostics

| Missing | Diagnostic | Status |
|---------|------------|--------|
| runtime contract | `bridge.runtime_contract_missing` | unknown |
| axiom descriptor | `bridge.axiom_descriptor_missing` | unknown |
| TBackend adapter | `bridge.tbackend_adapter_missing` | provisional/unknown |
| execution environment | `bridge.execution_environment_missing` | provisional |
| lifecycle state | `bridge.lifecycle_state_missing` | unknown |

[D] RuntimeMachine packets are descriptors. They do not prove that evaluation
has happened. They prove which semantic machine identity a lifecycle packet
belongs to.

## Builder 2: TBackendAdapterPacketBuilder

Purpose: describe the temporal backend adapter bound to the Runtime Machine.

PROP-008 says every TBackend must emit:

```text
Obs[:platform_observation, TBackendDescriptor]
```

The sidecar builder can produce the same profile metadata before packages emit
it natively.

```text
profile_name: tbackend_adapter_observation
kind: :platform_observation
subject: tbackend://<backend_id>@<adapter_version>
```

### Inputs

```text
TBackendAdapterInput = {
  backend_id
  backend_kind
  adapter_version
  backend_class
  storage_contract_ref
  capabilities
  consistency_model
  durability_model
  cursor_model
  snapshot_model
  compaction_model
  subscription_model
  serialization_model
  schema_policy
}
```

Sources:

- explicit adapter config
- backend object class name
- `respond_to?` capability checks in a future sidecar implementation
- `IgniterStore#storage_stats`
- `IgniterStore#segment_manifest`
- `IgniterStore#compaction_activity`
- `SegmentedFileBackend#durability_snapshot`
- `ChangefeedBuffer#snapshot`
- `SyncProfile#cursor`

### Capability Derivation

| Package signal | TBackend capability |
|----------------|---------------------|
| `IgniterStore#read(as_of:)` | `read_as_of: true` |
| `IgniterStore#write/#append` | `append_atomic: partial/unknown` |
| backend `replay` | `replay_enabled: true` |
| backend `write_snapshot` | `snapshot_enabled: true` |
| backend `replace_with_snapshot!` | `snapshot_replace: true` |
| `IgniterStore#checkpoint` | `checkpoint_request: true` |
| `SegmentedFileBackend#checkpoint!` | `segment_checkpoint: true` |
| `compaction_activity` | `compaction_obs: true` |
| `ChangefeedBuffer#replay(cursor:)` | `replay_cursor: retained_ring` |
| `ChangefeedBuffer#subscribe` | `subscribe_enabled: true` |
| `durability_snapshot` | `durability_model: declared` |

### Backend Profiles

| Backend | Builder classification | Default meaning impact |
|---------|------------------------|------------------------|
| in-memory store | CORE for local read/write, no durable resume | provisional for cross-session |
| FileBackend | snapshot/replay capable | reproducible only with fixed serializer and descriptor refs |
| SegmentedFileBackend | replay/checkpoint/durability visible | provisional if buffered facts exist |
| NetworkBackend | remote adapter | ESCAPE/provisional until server runtime evidence exists |
| ChangefeedBuffer | live cursor/subscription surface | live or provisional, not reproducible alone |
| SyncProfile | sync snapshot/cursor bundle | provisional until source backend and descriptors are linked |

### Payload

```text
TBackendAdapterPayload = {
  profile: :tbackend_adapter_observation
  backend_id
  backend_kind
  adapter_version
  backend_class
  capabilities
  storage_contract_ref
  consistency_model
  durability_model
  cursor_model
  snapshot_model
  compaction_model
  subscription_model
  serialization_model
  schema_policy
  bridge_profile_version
}
```

### Diagnostics

| Condition | Diagnostic | Status |
|-----------|------------|--------|
| backend class unknown | `bridge.tbackend.backend_unknown` | unknown |
| replay required but absent | `bridge.tbackend.replay_unavailable` | unknown/blocked |
| snapshot required but absent | `bridge.tbackend.snapshot_unavailable` | provisional/blocked |
| changefeed cursor too old | `bridge.tbackend.cursor_too_old` | stale |
| buffered durability | `bridge.tbackend.durability_buffered` | provisional |
| remote backend without server runtime ref | `bridge.tbackend.remote_runtime_missing` | provisional |
| silent compaction | `bridge.tbackend.compaction_obs_missing` | provisional/unknown |

[D] The TBackendAdapter builder is allowed to be conservative. It should
under-claim rather than infer durable/reproducible guarantees from storage
features alone.

## Builder 3: SemanticImagePacketBuilder

Purpose: describe the cross-session semantic image.

```text
profile_name: semantic_image_observation
kind: :descriptor_observation
subject: semantic-image://<image_id>
```

### Inputs

```text
SemanticImageInput = {
  image_id
  image_kind
  language_contract_ref
  user_contract_ref
  compiled_graph_hash
  runtime_contract_ref
  axiom_descriptor_ref
  execution_environment_ref
  tbackend_adapter_ref
  temporal_horizon
  input_hash
  fact_scope
  replay_cursor
  snapshot_ref
  cache_summary
  pending_tokens
  observation_refs
  receipt_refs
  failure_refs
  verification_ref
  compatibility_policy
}
```

### Payload

```text
SemanticImagePayload = {
  profile: :semantic_image_observation
  image_id
  image_kind
  descriptor_refs
  compiled_graph_hash
  temporal_horizon
  input_hash
  fact_scope
  replay_cursor
  snapshot_ref
  cache_summary
  pending_tokens
  observation_refs
  receipt_refs
  failure_refs
  verification_ref
  compatibility_policy
  content_hash
  bridge_profile_version
}
```

### Privacy

SemanticImage should default to hash-first payloads for user inputs and
potentially sensitive values.

| Field | Default policy |
|-------|----------------|
| descriptors | present |
| compiled graph hash | present |
| temporal horizon | present |
| input payloads | hashed |
| pending token payloads | present_summary or hashed |
| observation refs | present |
| receipt refs | present |
| failure refs | present |
| cache values | omitted or hashed |

[D] SemanticImage is not a dump. It is a portable evidence index.

### Required Links

```text
links:
  - rel: :observed_under, ref: axiom_descriptor_ref, required: true
  - rel: :observed_under, ref: runtime_contract_ref, required: true
  - rel: :observed_under, ref: tbackend_adapter_ref, required: true
  - rel: :produced_in, ref: execution_environment_ref, required: true
  - rel: :depends_on, ref: snapshot_ref, required: false
```

### Diagnostics

| Condition | Diagnostic | Status |
|-----------|------------|--------|
| compiled graph hash missing | `bridge.semantic_image.graph_hash_missing` | provisional |
| temporal horizon missing | `bridge.semantic_image.horizon_missing` | unknown |
| replay cursor missing for resume image | `bridge.semantic_image.cursor_missing` | provisional |
| snapshot ref missing for snapshot image | `bridge.semantic_image.snapshot_ref_missing` | provisional |
| cache summary claims fresh without horizon | `bridge.semantic_image.cache_horizon_missing` | unknown |
| pending tokens not linked to nodes | `bridge.semantic_image.pending_token_unlinked` | provisional |

## Builder 4: CheckpointPacketBuilder

Purpose: record that a semantic image was checkpointed.

```text
profile_name: checkpoint_observation
kind: :receipt_observation
subject: checkpoint://<checkpoint_id>
```

If checkpoint fails or is unsupported:

```text
kind: :failure_observation
subject: checkpoint://<checkpoint_id>
```

### Inputs

```text
CheckpointInput = {
  checkpoint_id
  checkpoint_kind
  machine_ref
  semantic_image_ref
  tbackend_adapter_ref
  snapshot_ref
  replay_cursor
  checkpoint_started_at
  checkpoint_completed_at
  backend_receipt_ref
  status
  warnings
}
```

Sidecar sources:

- caller-known checkpoint boundary
- `SemanticImagePacketBuilder` output
- `IgniterStore#checkpoint` result if invoked by caller outside this plan
- backend snapshot path/ref when visible
- `SegmentedFileBackend#checkpoint!` boundary when visible
- `SyncProfile#next_cursor` if using sync profile as a cursor source

### Payload

```text
CheckpointPayload = {
  profile: :checkpoint_observation
  checkpoint_id
  checkpoint_kind
  machine_ref
  semantic_image_ref
  tbackend_adapter_ref
  snapshot_ref
  replay_cursor
  backend_receipt_ref
  status
  warnings
  meaning_status
  bridge_profile_version
}
```

### Checkpoint Kind Mapping

| Kind | Required evidence | meaning_status ceiling |
|------|-------------------|------------------------|
| `:metadata_only` | SemanticImage descriptor | provisional |
| `:replay_cursor` | durable cursor or explicit cursor source | reproducible/provisional |
| `:snapshot` | SnapshotRef or backend snapshot evidence | reproducible/provisional |
| `:partial` | at least one missing required component | provisional |
| `:diagnostic` | failure refs and descriptors | reproducible failure or provisional |

### Diagnostics

| Condition | Diagnostic | Status |
|-----------|------------|--------|
| checkpoint unsupported | `bridge.checkpoint.unsupported` | blocked |
| semantic image missing | `bridge.checkpoint.semantic_image_missing` | unknown |
| snapshot requested but missing | `bridge.checkpoint.snapshot_missing` | provisional/blocked |
| cursor source is live ring only | `bridge.checkpoint.cursor_not_durable` | provisional |
| backend receipt missing | `bridge.checkpoint.backend_receipt_missing` | provisional |

[D] A checkpoint receipt is not proof of reproducibility by itself. It is proof
that a lifecycle boundary was observed.

## Builder 5: CompatibilityReportPacketBuilder

Purpose: compare a source SemanticImage with a target runtime/backend context.

In v0 bridge implementation, CompatibilityReport lowers to:

```text
profile_name: compatibility_report_observation
kind: :platform_observation
subject: compatibility://<source_image_id>/<target_machine_id>
```

When `verification_observation` is formally added to the envelope, the same
payload can lower to that kind instead.

### Inputs

```text
CompatibilityInput = {
  source_image_ref
  source_image_payload
  target_machine_ref
  target_runtime_contract_ref
  target_axiom_descriptor_ref
  target_tbackend_adapter_ref
  target_execution_environment_ref
  target_verification_ref
  migration_policy
}
```

### Checks

| Check | Pass condition |
|-------|----------------|
| `language.compatible` | same language contract or explicit migration |
| `user_contract.compatible` | same content hash or migration creates new image |
| `compiled_graph.compatible` | same hash or recompilation proof exists |
| `axiom.compatible` | same/superseding AxiomDescriptor with proof |
| `runtime.compatible` | same/sufficient RuntimeContract guarantees |
| `tbackend.compatible` | cursor/snapshot/serializer compatible |
| `temporal.continuity` | no temporal regression |
| `cursor.available` | replay cursor or snapshot anchor exists |
| `verification.trusted` | trust is not untrusted |
| `cache.safe` | cache verified fresh or discarded |
| `pending.routable` | pending tokens still route to declared node/capability |

### Payload

```text
CompatibilityReportPayload = {
  profile: :compatibility_report_observation
  source_image_ref
  target_machine_ref
  checks
  summary
  compatibility_status
  required_migrations
  warnings
  blocking_reasons
  meaning_status
  bridge_profile_version
}
```

### Status Mapping

| compatibility_status | meaning_status |
|----------------------|----------------|
| `:compatible` | `:reproducible` if horizon/backend evidence also passes |
| `:compatible_with_warnings` | `:provisional` |
| `:requires_migration` | `:provisional` until migration receipt exists |
| `:provisional` | `:provisional` |
| `:blocked` | `:unknown` or failure |
| `:incompatible` | `:stale` for old image, failure for resume |

### Diagnostics

| Condition | Diagnostic | Status |
|-----------|------------|--------|
| missing source image | `bridge.compat.source_image_missing` | blocked |
| runtime mismatch | `bridge.compat.runtime_mismatch` | incompatible |
| axiom mismatch | `bridge.compat.axiom_mismatch` | incompatible |
| TBackend mismatch | `bridge.compat.tbackend_mismatch` | blocked/incompatible |
| serializer mismatch | `bridge.compat.serializer_mismatch` | requires_migration |
| cursor unavailable | `bridge.compat.cursor_unavailable` | blocked |
| verification untrusted | `bridge.compat.verification_untrusted` | incompatible |
| cache unsafe | `bridge.compat.cache_discard_required` | compatible_with_warnings |

[D] CompatibilityReport is the gate before Resume. Resume without this report
is OOF for reproducible cross-session claims.

## Builder 6: ResumePacketBuilder

Purpose: record a resume attempt and its result.

```text
profile_name: resume_observation
kind: :receipt_observation | :failure_observation
subject: resume://<resume_id>
```

### Inputs

```text
ResumeInput = {
  resume_id
  source_image_ref
  target_machine_ref
  compatibility_report_ref
  resume_anchor
  snapshot_ref
  replay_cursor
  resumed_as_of
  status
  warnings
  failure_reason
}
```

### Payload

```text
ResumePayload = {
  profile: :resume_observation
  resume_id
  source_image_ref
  target_machine_ref
  compatibility_report_ref
  resume_anchor
  snapshot_ref
  replay_cursor
  resumed_as_of
  status
  warnings
  failure_reason
  meaning_status
  bridge_profile_version
}
```

### Required Links

```text
links:
  - rel: :caused_by, ref: source_image_ref, required: true
  - rel: :depends_on, ref: compatibility_report_ref, required: true
  - rel: :observed_under, ref: target_runtime_contract_ref, required: true
  - rel: :observed_under, ref: target_axiom_descriptor_ref, required: true
  - rel: :observed_under, ref: target_tbackend_adapter_ref, required: true
```

### Resume Result Mapping

| Resume status | Packet kind | meaning_status |
|---------------|-------------|----------------|
| `:resumed` | `:receipt_observation` | report-derived |
| `:resumed_with_warnings` | `:receipt_observation` | provisional |
| `:requires_migration` | `:receipt_observation` | provisional |
| `:blocked` | `:failure_observation` | unknown |
| `:incompatible` | `:failure_observation` | stale/failed |

[D] Resume receipt means the lifecycle transition was observed. It does not
mean the resumed result is reproducible unless the CompatibilityReport says so.

## Builder Ordering

The sidecar should build packets in dependency order.

```text
1. AxiomDescriptor packet        (existing PROP-004b/PROP-006 profile)
2. RuntimeContract packet        (existing PROP-006 profile)
3. TBackendAdapter packet        (new builder)
4. ExecutionEnvironment packet   (existing runtime evidence profile)
5. RuntimeMachine packet         (new builder)
6. package fact/projection/receipt packets (existing mapping)
7. SemanticImage packet          (new builder)
8. Checkpoint packet             (new builder)
9. CompatibilityReport packet    (new builder, before resume)
10. Resume packet                (new builder)
```

Missing earlier packets should not stop all packet building. They should mark
later packets incomplete and downgrade meaning status.

## Diagnostics Vocabulary

Minimum diagnostic codes for the first sidecar implementation:

```text
bridge.canonical_serializer_missing
bridge.runtime_contract_missing
bridge.axiom_descriptor_missing
bridge.execution_environment_missing
bridge.tbackend_adapter_missing
bridge.tbackend.backend_unknown
bridge.tbackend.replay_unavailable
bridge.tbackend.snapshot_unavailable
bridge.tbackend.cursor_too_old
bridge.tbackend.durability_buffered
bridge.tbackend.remote_runtime_missing
bridge.semantic_image.horizon_missing
bridge.semantic_image.graph_hash_missing
bridge.semantic_image.pending_token_unlinked
bridge.checkpoint.unsupported
bridge.checkpoint.cursor_not_durable
bridge.compat.runtime_mismatch
bridge.compat.axiom_mismatch
bridge.compat.tbackend_mismatch
bridge.compat.cursor_unavailable
bridge.compat.verification_untrusted
bridge.resume.compatibility_report_missing
```

[R] Diagnostics should be stable strings. Human-facing explanations can change
without changing diagnostic identity.

## Metadata-Only Implementation Phases

### Phase 0: Spec Freeze

- approve packet profiles
- approve required links
- approve diagnostics vocabulary
- approve meaning_status downgrade matrix

Exit: this track is accepted as the builder contract.

### Phase 1: Golden Fixtures

- create example inputs for each builder
- create expected packet profiles
- include missing-ref and downgrade cases
- include one FileBackend snapshot case
- include one SegmentedFileBackend buffered durability case
- include one Changefeed cursor-too-old case

No package edits.

### Phase 2: Pure Sidecar Builders

- implement plain builder objects in a non-package sidecar or experiment area
- input is hashes/structs and package objects passed by caller
- output is in-memory packet profile hashes
- no monkey patching
- no package writes

No package edits.

### Phase 3: Bridge Adapter Read Models

- add readers around package objects
- build Ledger fact, DurableModel projection/receipt, and lifecycle packets
- preserve package behavior exactly
- emit diagnostics for missing evidence

No package edits unless Architect explicitly converts this to an integration
slice later.

### Phase 4: Native Package Emission

Deferred. This requires separate approval.

Potential package edits, not part of this plan.

## Acceptance Criteria

A first metadata-only builder slice is accepted when it can:

1. Build all six lifecycle packet profiles from explicit context.
2. Build TBackendAdapter profiles for memory/file/segmented/network-like inputs.
3. Build SemanticImage and Checkpoint profiles without raw heap/process state.
4. Build CompatibilityReport before Resume.
5. Downgrade `meaning_status` when runtime/axiom/backend evidence is missing.
6. Emit stable diagnostics for every missing required ref.
7. Preserve PROP-005 payload/privacy/hash wellformedness.
8. Produce deterministic IDs for identical inputs.
9. Avoid package object mutation.
10. Keep package edits at zero.

## Package Agent Guardrails

[R] If Package Agent receives this plan, the safe next action is **not** package
integration. The safe next action is:

```text
bridge packet builder golden fixtures
  -> sidecar-only
  -> no package edits
  -> no runtime emission
  -> no public API
```

Package Agent should not:

- add methods to Ledger or DurableModel classes
- change Store checkpoint behavior
- change Contract execution lifecycle
- expose package internals through app-safe receipts
- claim reproducible resume without RuntimeContract, AxiomDescriptor,
  TBackendAdapter, and CompatibilityReport refs

## Risks

| Risk | Mitigation |
|------|------------|
| builders become a shadow runtime | keep them pure profile builders |
| synthetic refs look authoritative | label every synthetic ref and downgrade |
| package metadata is over-interpreted | under-claim capabilities |
| canonical serialization is premature | name serializer ref; diagnose if missing |
| CompatibilityReport duplicates verification | keep it bridge profile until formal kind settles |
| sidecar leaks app data | hash/redact by default |

## Rejected Paths

[X] Package edits in the first implementation plan.

[X] Runtime lifecycle packets emitted from package internals before packet
profiles are approved.

[X] New ObsKind values for every bridge profile. Use existing kinds plus profile
names unless a formal proposal extends the closed family.

[X] CompatibilityReport as a test-runner log. It is structured bridge evidence.

[X] Treating backend methods as semantic guarantees without RuntimeContract and
TBackendDescriptor links.

[X] Claiming reproducible resume from a checkpoint receipt alone.

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/docs/tracks/bridge-observation-envelope-implementation-plan-v0.md
Status: done

[D] Decisions:
- First implementation is metadata-only sidecar packet building.
- Six new lifecycle builders are planned: RuntimeMachine, TBackendAdapter,
  SemanticImage, Checkpoint, CompatibilityReport, and Resume.
- TBackendAdapter lowers to platform_observation, aligned with PROP-008.
- CompatibilityReport lowers to platform_observation in v0 and can later lower
  to verification_observation after the formal extension settles.
- Builders must under-claim: missing runtime/axiom/backend/session refs produce
  diagnostics and downgrade meaning_status.
- Checkpoint and Resume receipts prove lifecycle transitions, not
  reproducibility by themselves.

[R] Recommendations:
- Next safe slice: bridge packet builder golden fixtures, still no package edits.
- Give Package Agent only sidecar/golden-fixture work until Architect approves
  an integration slice.
- Keep synthetic refs explicit and never use them for reproducible claims.
- Treat canonical serializer absence as provisional, not fatal.

[S] Signals:
- The existing package surface is enough for read-only profile construction:
  Ledger facts, DurableModel projections/receipts, FileBackend snapshots,
  SegmentedFileBackend durability snapshots, Changefeed cursors, SyncProfile
  cursors, and compaction receipts.
- The main missing piece remains session prelude evidence, not more package
  storage features.

[Q] Open Questions:
- Should CompatibilityReport become a subtype/profile of PROP-007
  verification_observation, or remain platform_observation?
- Where should golden fixtures live: `igniter-lang/docs/fixtures` or an
  approved `igniter-lang/experiments` slice?
- Which canonical serializer should become the bridge-local v0 reference?

[X] Rejected:
- Package edits.
- New packet kinds without formal extension.
- Reproducible resume from checkpoint alone.
- Hidden synthetic refs.

[Next] Proposed next slice:
- `igniter-lang/docs/tracks/bridge-packet-builder-golden-fixtures-v0.md`
  defining sidecar-only fixture cases and expected packet profiles before any
  package code changes.
```
