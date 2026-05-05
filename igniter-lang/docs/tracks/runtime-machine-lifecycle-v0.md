# Track: Runtime Machine Lifecycle v0

Status: done
Slice state: done on 2026-05-05
Owner: `[Igniter-Lang Research Agent]`
Supervisor: `[Architect Supervisor / Codex]`

## Frame

This slice expands `runtime-machine.md` into a lifecycle contract.

The Runtime Machine is not Ledger, Redis, Ruby process memory, or a package
server. It is the semantic execution machine that:

```text
boots runtime promises
loads contracts and descriptors
evaluates under explicit TemporalCtx
checkpoints a semantic image
resumes from evidence across sessions
```

Ledger may be a strong durable `TBackend`, but it is not the language core.

## Source Horizon

- `igniter-lang/docs/runtime-machine.md`
- `igniter-lang/docs/axiomatic-contract-model.md`
- `igniter-lang/docs/temporal-positioning.md`
- `igniter-lang/docs/proposals/PROP-006-runtime-contract-specification-v0.md`
- `igniter-lang/docs/proposals/PROP-007-conformance-verification-v0.md`
- `igniter-lang/docs/tracks/runtime-contracts-and-execution-environments-v0.md`
- `igniter-lang/docs/tracks/bridge-observation-envelope-runtime-evidence-v0.md`
- `igniter-lang/docs/tracks/bridge-observation-envelope-package-mapping-v0.md`
- `docs/dev/execution-model.md` (read-only platform context)
- `packages/igniter-ledger/lib/igniter/store/file_backend.rb` (read-only)
- `packages/igniter-ledger/lib/igniter/store/segmented_file_backend.rb`
  (read-only)
- `packages/igniter-ledger/lib/igniter/store/changefeed_buffer.rb`
  (read-only)
- `packages/igniter-ledger/docs/storage-durability-contract.md`
  (read-only)

## Compact Claim

[D] A **RuntimeMachine** is a session-capable semantic machine:

```text
RuntimeMachine = {
  machine_id
  lifecycle_state
  language_contract_ref
  runtime_contract_ref
  axiom_descriptor_ref
  execution_environment_ref
  tbackend_adapter_ref
  semantic_image_ref
}
```

It evaluates:

```text
LanguageContract + RuntimeContract + UserContract + TemporalCtx + TBackend
  -> outputs | observations | failures | receipts | semantic_image
```

[D] Cross-session continuity is not a live process. It is a compatible
evidence chain:

```text
Session A checkpoint
  -> SemanticImageRef
  -> RuntimeContractRef
  -> AxiomDescriptorRef
  -> TBackendAdapterRef
  -> replay_cursor

Session B resume
  -> compatibility check
  -> restore semantic image or replay from cursor
  -> continue under explicit TemporalCtx
```

## Lifecycle State Machine

```text
unbooted
  -> booted
  -> loaded
  -> evaluating
  -> checkpointed
  -> resuming
  -> loaded | evaluating | closed | failed
```

Each transition must be observable when the runtime claims reproducibility.

| State | Meaning | Allowed next |
|-------|---------|--------------|
| `:unbooted` | No semantic promises are in force | `boot` |
| `:booted` | Runtime/Axiom/TBackend descriptors are visible | `load`, `close` |
| `:loaded` | Contract graph and descriptors are loaded, not running | `evaluate`, `checkpoint`, `close` |
| `:evaluating` | Runtime is resolving a contract/projection | `checkpoint`, `loaded`, `failed` |
| `:checkpointed` | Semantic image was persisted or referenced | `resume`, `close` |
| `:resuming` | Runtime is checking compatibility and restoring evidence | `loaded`, `evaluating`, `failed` |
| `:failed` | Lifecycle transition failed with structured evidence | `resume`, `close` |
| `:closed` | Session ended; only evidence remains | none |

[D] A runtime may expose more host states, but these are the semantic lifecycle
states. Host process start, socket connect, thread creation, and file open are
implementation events unless they change semantic promises.

## Boot

`boot` establishes the promises that make later observations meaningful.

```text
boot(input: BootConfig)
  -> AxiomDescriptor observation
  -> RuntimeContract observation
  -> TBackendAdapter observation
  -> ExecutionEnvironment observation
  -> optional VerificationReport
```

Required boot outputs:

| Output | Why it matters |
|--------|----------------|
| `AxiomDescriptorRef` | Fixes built-in semantics and content hash rules |
| `RuntimeContractRef` | Fixes scheduler, clock, cache, storage, capability promises |
| `ExecutionEnvironmentRef` | Identifies the concrete instance and bound resources |
| `TBackendAdapterRef` | Identifies temporal storage/replay/snapshot substrate |
| `TemporalCtx policy` | Declares how `as_of` and replay cursors are supplied |

[D] Evaluation without boot evidence is OOF for Igniter-Lang semantics. It may
run as host code, but it cannot produce reproducible language evidence.

### Boot Checks

Boot must check:

- runtime supports required language fragment
- runtime has visible `AxiomDescriptor`
- runtime has visible `RuntimeContract`
- TBackend capabilities satisfy the requested lifecycle profile
- clock/as_of policy can supply required `TemporalCtx`
- capability executor is deny-by-default or explicitly ESCAPE
- conformance evidence is trusted, conditional, or absent

```text
boot_status =
  :ready
  | :ready_conditional
  | :degraded
  | :blocked
```

`ready_conditional` is allowed for live or provisional work. It is not enough
for mutation-grade reproducible resume.

## Load

`load` brings semantic artifacts into the machine without executing them.

```text
load(bundle)
  -> classify CORE / ESCAPE / OOF
  -> typecheck
  -> compile or bind compiled graph
  -> bind package descriptors
  -> attach SemanticImage base
```

Load inputs:

| Input | Required for |
|-------|--------------|
| `LanguageContractRef` | grammar/semantic rules |
| `UserContractRef` | business semantics |
| `CompiledGraphHash` | stable evaluation shape |
| `DescriptorBundle` | stores, histories, projections, effects, capabilities |
| `TemporalPolicy` | expected `TemporalCtx` shape |
| `PackageMappingProfile` | bridge lowering of package facts/receipts |

[D] `load` is where CORE/ESCAPE/OOF classification is attached to the contract
bundle. It should not be delayed until evaluation.

### Load Result

```text
LoadedUnit = {
  unit_id
  language_contract_ref
  user_contract_ref
  compiled_graph_hash
  fragment_class
  required_escapes
  descriptor_refs
  temporal_policy
  semantic_image_base_ref
}
```

[D] A loaded unit is portable only by content and descriptor references. It is
not portable by Ruby object identity.

## Evaluate

`evaluate` resolves a loaded contract or projection under explicit temporal
context.

```text
evaluate(loaded_unit, Tt, inputs, target)
  -> value | projection | failure | pending
  -> observations
  -> receipts
  -> updated semantic image
```

Evaluation must link produced observations to:

- `observed_under` the `AxiomDescriptor`
- `observed_under` the `RuntimeContract`
- `executed_by` the runtime contract
- `produced_in` the execution environment
- `read_from` or `derived_from` TBackend facts/cursors when available

### Evaluation Outcomes

| Outcome | Meaning | Lifecycle impact |
|---------|---------|------------------|
| `:succeeded` | Target resolved | machine returns to `:loaded` |
| `:failed` | Failure is structured and inspectable | machine may return to `:loaded` or `:failed` |
| `:pending` | Deferred result token exists | checkpoint becomes important |
| `:blocked` | Capability, platform, or compatibility guard denied execution | no mutation should occur |
| `:provisional` | Runtime produced a value without full proof | action rights are downgraded |

The current platform already has a useful shape here:

- `DeferredResult` carries token/payload/source metadata.
- runtime docs define `node_pending` and `node_resumed` events.
- store runner snapshots can preserve pending tokens and event identity.

[D] Igniter-Lang should treat pending/resume as semantic lifecycle, not only
async implementation detail.

## Checkpoint

`checkpoint` persists a **semantic image**, not a process image.

```text
checkpoint(machine, horizon)
  -> SemanticImage observation
  -> Checkpoint observation
  -> TBackend snapshot or replay cursor
```

Checkpoint can happen:

- after successful evaluation
- while pending on a deferred token
- after a structured failure
- before process shutdown
- before migrating or upgrading runtime descriptors

### Checkpoint Kinds

| Kind | Meaning | Status impact |
|------|---------|---------------|
| `:metadata_only` | Image contains refs/hashes but no durable state | live or provisional |
| `:replay_cursor` | Image can replay from a cursor | reproducible if cursor is durable |
| `:snapshot` | Image includes a durable snapshot boundary | reproducible if compatibility holds |
| `:partial` | Some state saved, some state ambient/missing | provisional |
| `:diagnostic` | Captures failure evidence only | reproducible failure if refs are fixed |

Current package evidence maps to this:

- `FileBackend#write_snapshot` writes a non-destructive snapshot parallel to
  WAL replay.
- `IgniterStore#checkpoint` snapshots current fact log when backend supports it.
- `SegmentedFileBackend#checkpoint!` seals open segments and starts fresh ones.
- `ChangefeedBuffer#replay(cursor:)` supports retained in-memory replay cursors,
  but has no durable checkpoint in v0.
- `SyncProfile` carries descriptors, facts, retention, compaction receipts,
  cursor, and subscription checkpoints.

[D] These are TBackend capabilities, not the Runtime Machine itself.

## Semantic Image

[D] A **SemanticImage** is the portable meaning surface of a runtime session.
It is not object memory.

```text
SemanticImage = {
  image_id
  image_kind
  created_at
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
  cache_summary
  pending_tokens
  observation_refs
  receipt_refs
  failure_refs
  verification_ref
  compatibility_policy
  content_hash
}
```

### Included

| Component | Reason |
|-----------|--------|
| descriptors | Fix language/runtime/store/capability meanings |
| compiled graph hash | Fix evaluation shape |
| temporal horizon | Fix `as_of`, `rule_version`, `fact_scope`, cursor |
| inputs/content hashes | Rebuild or verify value identity |
| observation refs | Preserve evidence chain |
| receipt refs | Preserve action/capability proof |
| pending tokens | Resume deferred work explicitly |
| cache summary | Explain fresh/stale/provisional state |
| TBackend cursor/snapshot refs | Rebuild state without process memory |

### Excluded

| Excluded | Reason |
|----------|--------|
| raw Ruby heap | Host implementation, not semantic evidence |
| thread stacks | Scheduler internals, not portable meaning |
| open sockets/file handles | Environment resources, not language state |
| ambient `Time.now` | Violates temporal explicitness |
| unhashable closures | Cannot be replayed or verified |
| secret payloads without policy | Must be references or redacted observations |

[D] The image is a proof-carrying bundle of references and hashes. It can be
hydrated by a runtime, but it should remain meaningful without that runtime
process being alive.

## Resume

`resume` loads a semantic image and verifies it can continue under the current
machine.

```text
resume(image_ref, target_runtime)
  -> compatibility report
  -> restored LoadedUnit or EvaluationContinuation
  -> Resume observation
```

Resume phases:

1. Read image descriptor and content hash.
2. Verify `AxiomDescriptor` compatibility.
3. Verify `RuntimeContract` compatibility.
4. Verify `TBackendAdapter` compatibility.
5. Verify language/user contract and compiled graph hashes.
6. Verify replay cursor or snapshot availability.
7. Verify `TemporalCtx` is explicit and allowed by clock policy.
8. Restore pending tokens/cache summary only as declared evidence.
9. Emit `resume_observation` with status.

### Resume Status

```text
ResumeStatus =
  :compatible
  | :compatible_with_warnings
  | :requires_migration
  | :provisional
  | :blocked
  | :incompatible
```

| Status | Actor posture |
|--------|---------------|
| `:compatible` | May continue and may claim reproducible if all refs are fixed |
| `:compatible_with_warnings` | May inspect; require review before mutation |
| `:requires_migration` | Must run explicit migration/verification before evaluation |
| `:provisional` | May continue live/provisional, not audit-grade |
| `:blocked` | Missing capability, TBackend, or evidence |
| `:incompatible` | Must not resume as same semantic session |

[D] A resume that changes axiom/runtime/backend semantics silently is OOF.
It may start a new session, but it cannot claim continuity with the old one.

## TBackend Adapter

`runtime-machine.md` introduces:

```text
TBackend
  = temporal substrate for state, observations, replay, snapshots
```

[D] In this track, `TBackend` means **Temporal Backend**. It is bridge/runtime
vocabulary, not a current package API name.

```text
TBackendAdapter = {
  adapter_id
  adapter_version
  backend_kind
  capabilities
  consistency_model
  cursor_model
  snapshot_model
  retention_model
  compaction_model
  durability_model
  subscription_model
  serialization_model
  schema_policy
}
```

### TBackend Operations

```text
read(scope, as_of)
append(observation_or_fact)
replay(cursor)
snapshot(horizon)
restore(snapshot_ref)
compact(policy)
subscribe(slice)
describe()
```

### Adapter Capability Matrix

| Capability | Meaning | Current package signal |
|------------|---------|------------------------|
| `current_read` | read current store state | `IgniterStore#read` |
| `as_of_read` | read at timestamp/horizon | `read(as_of:)`, `history(as_of:)` |
| `append_fact` | append durable fact/event | `write`, `append` |
| `replay_all` | replay complete fact log | backend `replay` |
| `replay_cursor` | resume from cursor | `ChangefeedBuffer`, `SyncProfile` |
| `snapshot_write` | persist snapshot boundary | `write_snapshot`, `checkpoint` |
| `snapshot_restore` | load snapshot plus delta | `FileBackend#replay` |
| `segment_checkpoint` | seal storage segments | `SegmentedFileBackend#checkpoint!` |
| `compaction_receipts` | prove what was compacted | `compaction_activity` |
| `live_subscribe` | push changes to consumers | `subscribe`, changefeed |
| `durability_snapshot` | expose loss window | `durability_snapshot` |

[D] A TBackend adapter must describe its durability and loss window. A compact
backend with buffered facts can still be valid, but it cannot support the same
reproducibility claim as a flushed/durable backend.

## Cross-Session Compatibility

Cross-session compatibility compares semantic descriptors, not host identity.

```text
CompatibilityInput = {
  source_image
  target_runtime_contract
  target_axiom_descriptor
  target_tbackend_adapter
  target_execution_environment
}
```

### Compatibility Checks

| Check | Compatible when |
|-------|-----------------|
| language | same language version, or explicit migration exists |
| user contract | same content hash, or migration changes session identity |
| compiled graph | same hash, or recompilation proof preserves semantics |
| axiom descriptor | same hash/version, or supersession is verified |
| runtime contract | same guarantees for required fragment |
| TBackend adapter | cursor/snapshot/serialization semantics compatible |
| temporal horizon | `as_of`, `rule_version`, `fact_scope`, cursor are available |
| cache summary | cache can be trusted or explicitly discarded |
| pending tokens | tokens still route to declared source node/capability |
| verification | trust is trusted/conditional, not untrusted |

### Compatibility Classes

| Class | Meaning |
|-------|---------|
| `same_image` | Same content hash and descriptor refs |
| `compatible_image` | Different refs, but verified equivalent for this slice |
| `migrated_image` | Explicit migration changed refs and produced a new image |
| `provisional_image` | Enough to inspect/live resume, not enough for audit |
| `incompatible_image` | Must not continue as same semantic session |

[D] Migration is a new semantic event. It should produce a new image with
`migrated_from` links, not rewrite the old image.

## Observation Profiles

This track does not require new package code, but it names bridge profiles the
implementation plan should be able to lower into `ObsPacket` forms.

### runtime_machine_observation

```text
kind: :descriptor_observation
subject: runtime-machine://<machine_id>
payload:
  machine_id
  lifecycle_state
  runtime_contract_ref
  axiom_descriptor_ref
  execution_environment_ref
  tbackend_adapter_ref
```

### tbackend_adapter_observation

```text
kind: :descriptor_observation
subject: tbackend://<adapter_id>@<adapter_version>
payload:
  backend_kind
  capabilities
  consistency_model
  cursor_model
  snapshot_model
  durability_model
  serialization_model
```

### semantic_image_observation

```text
kind: :descriptor_observation
subject: semantic-image://<image_id>
payload:
  image_kind
  language_contract_ref
  user_contract_ref
  compiled_graph_hash
  temporal_horizon
  replay_cursor
  content_hash
```

### checkpoint_observation

```text
kind: :receipt_observation
subject: checkpoint://<checkpoint_id>
payload:
  checkpoint_kind
  semantic_image_ref
  tbackend_adapter_ref
  snapshot_ref
  replay_cursor
  meaning_status
```

### resume_observation

```text
kind: :receipt_observation | :failure_observation
subject: resume://<resume_id>
payload:
  semantic_image_ref
  source_runtime_ref
  target_runtime_ref
  compatibility_status
  warnings
  meaning_status
```

[D] `checkpoint_observation` and `resume_observation` are receipts because
they prove a lifecycle transition happened. If the transition fails, the same
profile lowers to `failure_observation`.

## CORE vs ESCAPE vs OOF

### CORE

| Lifecycle feature | CORE rule |
|-------------------|-----------|
| boot | visible `AxiomDescriptor` and `RuntimeContract` before evaluation |
| load | content-addressed contract/graph descriptors |
| evaluate | single-runtime evaluation under explicit `TemporalCtx` |
| pending | deferred token is explicit and inspectable |
| checkpoint | semantic image refs/hashes are emitted |
| resume | same descriptor refs or verified compatible refs |
| TBackend read | declared current/as_of/replay capability |
| snapshot restore | declared snapshot semantics with content/hash evidence |
| cache restore | cache either verified fresh or discarded |
| result status | meaning_status honestly reflects evidence |

### ESCAPE

| Lifecycle feature | ESCAPE reason |
|-------------------|---------------|
| runtime supersede mid-session | requires supersession observations |
| semantic image migration | requires migration proof |
| distributed resume | multiple runtime contracts and clocks |
| eventual backend consistency | may produce live/provisional result |
| best-effort changefeed cursor | retained ring may lose cursor |
| partial checkpoint | some state missing or ambient |
| buffered durability backend | accepted facts may be lost on crash |
| speculative evaluation | must mark discarded work |
| cache reuse across runtime versions | requires compatibility proof |

### OOF

| Lifecycle feature | Why rejected |
|-------------------|--------------|
| resume without RuntimeContract | runtime meaning is hidden |
| resume without AxiomDescriptor | built-in semantics are hidden |
| raw heap image as semantic image | not portable or inspectable |
| ambient wall-clock during resume | violates temporal explicitness |
| hidden TBackend swap | changes replay/storage semantics |
| claiming reproducible from live cursor only | cursor may be lossy or moving |
| silent descriptor migration | changes meaning without evidence |
| mutation from incompatible image | acts from false continuity |

## Actor Protocol

A human or agent acting from a resumed projection should:

1. Read the projection and its `meaning_status`.
2. Follow `executed_by` to the runtime contract.
3. Follow `produced_in` to the execution environment.
4. Follow `observed_under` to the axiom/runtime descriptors.
5. Follow image/checkpoint links if result crossed sessions.
6. Check resume compatibility status.
7. Require `:reproducible` for mutation, approval, or audit-grade receipt.
8. For `:live` or `:provisional`, pin or re-evaluate before action.
9. For `:stale`, refresh or use as historical evidence only.
10. For `:unknown`, block mutation and request evidence.

[D] Runtime Machine lifecycle turns "can I act?" into an evidence traversal,
not a guess about whether the current process seems alive.

## Bridge Candidates

[R] The next bridge implementation plan should add sidecar packet builders for:

- runtime machine descriptor
- TBackend adapter descriptor
- semantic image descriptor
- checkpoint receipt
- resume receipt/failure
- compatibility report

[R] Package edits should still wait. The first implementation can be a
metadata-only adapter that reads existing package objects and emits sidecar
profiles. Package runtime changes come after the packet shapes are approved.

## Rejected Paths

[X] Ledger as mandatory language core. Ledger is a possible TBackend, not the
Runtime Machine.

[X] Semantic image as process heap. A heap image hides authority in host memory.

[X] Resume as "restart and hope". Resume is a compatibility-checked lifecycle
transition.

[X] Treating checkpoint as only performance optimization. A checkpoint is
evidence when it supports cross-session meaning.

[X] Backend adapter as storage-only. TBackend affects time, replay, durability,
subscription, compaction, and therefore meaning.

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/docs/tracks/runtime-machine-lifecycle-v0.md
Status: done

[D] Decisions:
- RuntimeMachine is the semantic lifecycle owner for boot, load, evaluate,
  checkpoint, and resume.
- SemanticImage is a portable evidence bundle of descriptors, temporal horizon,
  hashes, observation refs, pending tokens, replay cursor, and receipts. It is
  not process memory.
- TBackend means Temporal Backend adapter vocabulary. Ledger is one possible
  durable adapter, not the language substrate.
- Resume is a compatibility-checked semantic transition. Same process identity
  is irrelevant; descriptor/hash/cursor compatibility is what matters.
- CORE covers single-runtime, explicit-time, descriptor-visible lifecycle.
  Runtime supersession, migration, distributed resume, lossy cursors, and
  buffered durability are ESCAPE. Hidden runtime/axiom/backend changes are OOF.

[R] Recommendations:
- Before package edits, define sidecar packet builders for RuntimeMachine,
  TBackendAdapter, SemanticImage, Checkpoint, Resume, and CompatibilityReport.
- Use RuntimeContract + AxiomDescriptor + TBackendAdapter refs in every
  cross-session reproducibility claim.
- Treat cache restore as optional: verify it or discard it.
- Downgrade resumed results to live/provisional/stale/unknown when evidence is
  missing instead of claiming reproducibility.

[S] Signals:
- Current packages already contain useful substrate signals: FileBackend
  snapshots, SegmentedFileBackend checkpoints/durability snapshots,
  Changefeed cursors, SyncProfile cursors, compaction receipts, and
  DeferredResult tokens.
- The missing layer is not more storage. It is lifecycle evidence that binds
  runtime, axioms, backend, temporal horizon, and observations into a semantic
  image.

[Q] Open Questions:
- Should `SemanticImage` become a formal type in PROP-004/PROP-005, or remain
  a runtime/bridge profile first?
- Should `TBackendAdapter` be part of `RuntimeContract.storage`, or a separate
  descriptor linked from ExecutionEnvironment?
- Which compatibility statuses should agents treat as sufficient for human
  review versus autonomous mutation?

[X] Rejected:
- Ledger as mandatory Runtime Machine.
- Heap image as semantic image.
- Resume without compatibility evidence.
- Hidden backend swaps.
- Reproducibility claims from live/lossy cursors.

[Next] Proposed next slice:
- `igniter-lang/docs/tracks/bridge-observation-envelope-implementation-plan-v0.md`
  as an Architect-reviewed metadata-only plan for packet builders before any
  package edits.
```
