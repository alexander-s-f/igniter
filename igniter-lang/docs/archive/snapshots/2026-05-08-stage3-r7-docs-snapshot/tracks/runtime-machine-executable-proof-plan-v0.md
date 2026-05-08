# Track: Runtime Machine Executable Proof Plan v0

Status: done
Slice state: done on 2026-05-05
Owner: `[Igniter-Lang Research Agent]`
Supervisor: `[Architect Supervisor / Codex]`
Target executor: Package Agent after Architect approval

## Frame

This slice defines the smallest executable proof for the Runtime Machine
lifecycle.

The proof should demonstrate:

```text
:memory TBackend
  -> boot
  -> load
  -> evaluate
  -> checkpoint
  -> resume
  -> re-evaluate same toy contract under same horizon
```

It is a proof plan, not an implementation.

Non-goals:

- no package edits
- no production runtime API
- no Ledger dependency
- no distributed runtime
- no capability effects
- no final DSL syntax
- no claim that `:memory` proves durable restart

## Source Horizon

- `igniter-lang/docs/runtime-machine.md`
- `igniter-lang/docs/tracks/runtime-machine-lifecycle-v0.md`
- `igniter-lang/docs/tracks/bridge-observation-envelope-implementation-plan-v0.md`
- `igniter-lang/docs/proposals/PROP-006-runtime-contract-specification-v0.md`
- `igniter-lang/docs/proposals/PROP-007-conformance-verification-v0.md`
- `igniter-lang/docs/proposals/PROP-008-tbackend-contract-v0.md`
- `igniter-lang/docs/proposals/PROP-009-semantic-image-resume-compatibility-v0.md`
- `igniter-lang/docs/proposals/PROP-011-runtime-machine-lifecycle-v0.md`

## Compact Claim

[D] The first executable proof should prove lifecycle continuity, not backend
durability.

```text
Session A
  -> semantic image
  -> memory snapshot object
  -> compatibility report
  -> Session B resume
  -> same result hash under same Tt
```

[D] A `:memory` TBackend may support trusted resume inside the proof harness
when the snapshot object is still available and content hashes match. It must
be blocked after memory loss and provisional if it only has synthetic
descriptors.

```text
same in-memory backend + snapshot hash matches
  -> trusted for harness

new empty memory backend + image refs only
  -> blocked

same values but missing runtime/backend evidence
  -> provisional
```

The proof passes only if result equality is backed by an evidence chain.

## Proof Question

Can a minimal Runtime Machine:

1. Boot with explicit runtime, axiom, execution environment, and TBackend
   descriptors?
2. Load a toy CORE contract with a stable compiled graph hash?
3. Evaluate under explicit `TemporalCtx` with no ambient time?
4. Append observations into `:memory` TBackend?
5. Checkpoint a SemanticImage with replay cursor and snapshot hash?
6. Resume a second machine instance from that image?
7. Re-evaluate the same target and produce the same result hash?
8. Downgrade or block when compatibility evidence is missing?

## Minimal Components

### Component 1: MemoryTBackend

Purpose: an in-process temporal substrate with deterministic sequence order.

Required operations:

```text
describe() -> TBackendDescriptor
append(obs_packet, idempotency_key: nil) -> AppendReceipt
read(subject, as_of, type_hint: nil) -> Option[ObsPacket]
replay(cursor, filter: nil, limit: nil) -> ReplayStream
snapshot(horizon) -> SnapshotRef
restore(snapshot_ref) -> MemoryTBackend
```

Optional or unsupported in v0:

```text
compact(policy) -> unsupported
subscribe(slice) -> unsupported
```

Descriptor:

```text
TBackendDescriptor = {
  backend_kind: :memory
  read_as_of: true
  append_atomic: true
  replay_enabled: true
  snapshot_enabled: true
  compact_enabled: false
  subscribe_enabled: false
  durability_model: :process_memory
  loss_window: :all_on_process_loss
}
```

[D] `:memory` can prove ordering, replay, snapshots, and compatibility checks.
It cannot prove persistence across process death.

### Component 2: RuntimeMachine

Minimum semantic state:

```text
RuntimeMachine = {
  machine_id
  session_id
  lifecycle_state
  axiom_descriptor_ref
  runtime_contract_ref
  execution_environment_ref
  tbackend_descriptor_ref
  loaded_unit
  semantic_image_ref
}
```

Allowed lifecycle:

```text
unbooted -> booted -> loaded -> evaluating -> loaded
loaded -> checkpointed
checkpointed -> resuming -> loaded
```

Invalid transitions must emit structured failure observations:

- `load` before `boot`
- `evaluate` before `load`
- `checkpoint` before `boot`
- `resume` without SemanticImage
- `resume` with incompatible or missing TBackend snapshot

### Component 3: Toy Contract

Use a tiny dispatch-shaped contract because it exercises temporal reads without
requiring Spark CRM or package code.

```text
ToyDispatchContract

inputs:
  order_id
  technician_id
  as_of

reads:
  TechnicianProfile(technician_id)
  ScheduleSlot(technician_id, as_of)
  OffSchedule(technician_id, as_of)

compute:
  service_match = order.service in technician.services
  schedule_conflict = schedule_slot.occupied == true
  off_schedule_conflict = off_schedule.disabled == true
  available = service_match && !schedule_conflict && !off_schedule_conflict

output:
  DispatchCandidate {
    technician_id
    order_id
    available
    reason_codes
  }
```

Fragment classification:

```text
fragment_class: CORE
required_escapes: []
effects: []
capabilities: []
```

[D] The toy contract should not call host time, network, files, random, or
threads. Its only temporal input is explicit `as_of`.

### Component 4: Observation Mini-Model

The proof may use a compact ObsPacket shape:

```text
ObsPacket = {
  id
  kind
  subject
  payload
  payload_hash
  temporal
  links
}
```

Required kinds:

- `descriptor_observation`
- `platform_observation`
- `fact_observation`
- `value_observation`
- `receipt_observation`
- `failure_observation`

Required links:

- `observed_under -> AxiomDescriptor`
- `observed_under -> RuntimeContract`
- `observed_under -> TBackendDescriptor`
- `produced_in -> ExecutionEnvironment`
- `executed_by -> RuntimeContract` for evaluation outputs
- `read_from -> fact_observation` for TBackend reads
- `caused_by -> lifecycle transition` for checkpoint/resume receipts

### Component 5: SemanticImage

Minimum image:

```text
SemanticImage = {
  image_id
  session_id
  produced_at
  axiom_descriptor_ref
  runtime_contract_ref
  backend_descriptor_ref
  execution_environment_ref
  contract_descriptor_ref
  compiled_graph_hash
  observation_count
  observation_hash
  value_refs
  receipt_refs
  checkpoint
  replay_cursor
  snapshot_ref
  temporal_horizon
  content_hash
}
```

Checkpoint:

```text
CheckpointRef = {
  checkpoint_id
  as_of
  seq_id
  snapshot_ref
  snapshot_hash
  created_at
}
```

[D] The SemanticImage must be content-addressed. Resume should compare hashes,
not host object identity.

### Component 6: CompatibilityReport

Minimum checks:

| Check | Trusted when |
|-------|--------------|
| axiom | same descriptor hash |
| runtime | same runtime contract hash |
| backend | same `:memory` descriptor and snapshot available |
| contract | same contract descriptor and compiled graph hash |
| temporal | requested `as_of` equals exact replay horizon |
| snapshot | snapshot hash matches SemanticImage |
| replay | cursor seq is available in restored backend |
| value | re-evaluation result hash matches checkpointed value |

Outcomes:

```text
:trusted
:provisional
:downgraded
:blocked
```

## Golden Path

### Step 0: Seed Facts

Append three fact observations into MemoryTBackend.

```text
TechnicianProfile tech/t-17:
  services: [:install]
  zone: :north

ScheduleSlot tech/t-17 at 2026-05-05T10:42:00Z:
  occupied: false

OffSchedule tech/t-17 at 2026-05-05T10:42:00Z:
  disabled: false
```

The seed facts are part of the proof fixture. They must have stable subjects,
payload hashes, and temporal metadata.

### Step 1: Boot

Input:

```text
BootConfig = {
  machine_id: runtime-machine/memory-proof-a
  session_id: session/a
  backend_kind: :memory
  clock_policy: :explicit_only
}
```

Expected outputs:

- AxiomDescriptor
- RuntimeContract
- ExecutionEnvironment
- TBackendDescriptor
- BootReceipt

Expected state:

```text
lifecycle_state: :booted
meaning_status: :provisional until verification is emitted
```

### Step 2: Load

Input:

```text
ToyDispatchContract descriptor
compiled_graph_hash: hash(toy-dispatch-contract-v0)
fragment_class: CORE
```

Expected outputs:

- ContractDescriptor
- FragmentClassification
- LoadedUnit
- LoadReceipt

Expected state:

```text
lifecycle_state: :loaded
```

### Step 3: Evaluate

Input:

```text
target: DispatchCandidate
order_id: order/o-1
technician_id: tech/t-17
as_of: 2026-05-05T10:42:00Z
rule_version: toy_dispatch@1
```

Expected output:

```text
DispatchCandidate = {
  order_id: order/o-1
  technician_id: tech/t-17
  available: true
  reason_codes: [:service_match, :schedule_free, :not_off_schedule]
}
```

Expected observations:

- fact reads for technician profile, schedule slot, off schedule
- value observation for DispatchCandidate
- evaluation receipt
- links to runtime, axiom, backend, execution environment

Expected state:

```text
lifecycle_state: :loaded
result_hash: hash(dispatch-candidate-payload)
```

### Step 4: Checkpoint

Input:

```text
horizon:
  as_of: 2026-05-05T10:42:00Z
  rule_version: toy_dispatch@1
  fact_scope:
    technician_id: tech/t-17
    order_id: order/o-1
```

Expected outputs:

- MemoryTBackend snapshot
- replay cursor at latest seq
- CheckpointRef
- SemanticImage
- CheckpointReceipt

Expected state:

```text
lifecycle_state: :checkpointed
```

### Step 5: Resume

Create a new RuntimeMachine instance:

```text
machine_id: runtime-machine/memory-proof-b
session_id: session/b
```

Bind the same restored MemoryTBackend snapshot and request exact replay:

```text
ResumeIntent: :exact_replay
image_ref: image/session-a/checkpoint-1
requested_as_of: 2026-05-05T10:42:00Z
```

Expected outputs:

- CompatibilityReport
- ResumeObservation
- restored LoadedUnit

Expected status:

```text
ResumeStatus: :trusted
meaning_status: :reproducible within proof harness
```

### Step 6: Re-Evaluate

Run the same target under the same horizon.

Pass condition:

```text
session_b.result_hash == session_a.result_hash
session_b.read_refs covered_by session_a.SemanticImage
session_b.compatibility_report.status == :trusted
```

The proof must print or return a compact summary:

```text
PASS runtime_machine_memory_proof
boot: ok
load: ok
evaluate: ok
checkpoint: ok
resume: trusted
same_result_hash: true
```

## Negative Fixtures

The executable proof should include these failure cases.

### Negative 1: Ambient Time

Remove `as_of` from evaluate.

Expected:

```text
failure: temporal.as_of_missing
status: :blocked
```

### Negative 2: Empty Backend Resume

Resume Session B from SemanticImage only, without snapshot or replay cursor
data.

Expected:

```text
compatibility.replay_availability: :blocked
ResumeStatus: :blocked
```

### Negative 3: Runtime Descriptor Drift

Change RuntimeContract hash between Session A and Session B.

Expected:

```text
compatibility.runtime_version: :downgrade
ResumeStatus: :downgraded
allowed_action: inspect only
```

### Negative 4: Contract Hash Drift

Change `compiled_graph_hash`.

Expected:

```text
compatibility.compiled_graph: :blocked
ResumeStatus: :blocked
```

### Negative 5: Result Equality Without Evidence

Force the same value payload but remove read links or runtime links.

Expected:

```text
same_result_hash: true
meaning_status: :provisional
proof_passed: false
```

[D] Equal values are not enough. The proof is about reproducible meaning, not
coincidental output equality.

## Minimal Future Implementation Shape

If approved, the implementation can be a single standalone Ruby proof harness
using only stdlib.

Suggested shape:

```text
MemoryTBackend
ObsPacket
Hashing
RuntimeMachine
ToyDispatchContract
CompatibilityChecker
ProofRunner
```

No existing package classes are required. The first version should avoid
RSpec and expose one direct executable entry point. Tests can be added after
the proof shape is stable.

Recommended runner behavior:

```text
ruby <proof-file>
  -> prints PASS/FAIL summary
  -> exits 0 on golden path + expected negative fixtures
  -> exits non-zero on missing expected evidence
```

## Acceptance Criteria

The executable proof is successful when:

1. Boot emits all descriptor observations.
2. Load produces a CORE LoadedUnit with stable compiled graph hash.
3. Evaluate requires explicit `as_of`.
4. Evaluation output links to runtime, axiom, backend, environment, and reads.
5. Checkpoint emits SemanticImage with snapshot, cursor, and content hash.
6. Resume emits CompatibilityReport.
7. Re-evaluation after trusted resume has the same result hash.
8. Empty memory backend resume is blocked.
9. Runtime/contract drift downgrades or blocks.
10. The proof never claims durable restart from `:memory`.

## Risks

- A proof that imports current package runtime may accidentally test package
  behavior instead of Runtime Machine semantics.
- A proof that only compares Ruby values may miss observation evidence.
- A proof that uses ambient `Time.now` violates the temporal model.
- A proof that treats MemoryTBackend as durable overclaims.
- A proof that omits negative fixtures will not catch false reproducibility.

## Rejected Paths

[X] Build this first inside `packages/`.

[X] Depend on Ledger for the first Runtime Machine proof.

[X] Use Redis/file/network state before the memory lifecycle is clear.

[X] Claim production API shape from the toy proof.

[X] Treat checkpoint as a process heap dump.

[X] Treat resume success as value equality only.

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/docs/tracks/runtime-machine-executable-proof-plan-v0.md
Status: done

[D] Decisions:
- The first executable proof is a standalone `:memory` TBackend lifecycle
  harness, not a package integration.
- The golden path is boot/load/evaluate/checkpoint/resume/re-evaluate on a
  toy CORE dispatch contract.
- `:memory` can prove lifecycle and compatibility within the proof harness,
  but cannot claim durable restart after process memory loss.
- Reproducibility requires evidence links and compatibility checks, not just
  equal output values.
- Negative fixtures are required: missing as_of, empty backend resume, runtime
  drift, contract drift, and value equality without evidence.

[R] Recommendations:
- Give Package Agent this plan only as a standalone proof harness task.
- Keep the first implementation stdlib-only and outside package code.
- Print a PASS/FAIL summary and make failures evidence-specific.
- Reuse this proof later as the golden fixture for packet builders.

[S] Signals:
- The runtime machine concept is now small enough to execute.
- `:memory` is the right first TBackend because it isolates lifecycle semantics
  from durability, storage format, and Ledger concerns.
- The strongest early test is "same result hash after trusted resume, blocked
  when snapshot/cursor evidence is absent."

[Q] Open Questions:
- Where should approved executable research harnesses live:
  `igniter-lang/experiments/` or a docs-local experiments directory?
- Should the first proof use a tiny custom ObsPacket shape or the emerging
  bridge packet builder profile?
- Should verification be synthetic in v0 or should it include a minimal
  VerificationReport packet?

[Next] Proposed next slice:
- `runtime-machine-memory-proof-implementation-v0`
  Implement the standalone proof harness after Architect approves the write
  location and executor.
```
