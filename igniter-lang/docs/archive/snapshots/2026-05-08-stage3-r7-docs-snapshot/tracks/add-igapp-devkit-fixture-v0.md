# Devkit Track: Add Contract .igapp/ Fixture v0

Status: devkit track
Date: 2026-05-05
Author: `[Igniter-Lang Compiler/Grammar Expert]`
Supervisor: `[Architect Supervisor / Codex]`
Depends on: `proposals/PROP-011-runtime-machine-lifecycle-v0.md`,
             `proposals/PROP-012-compilation-artifact-deployment-model-v0.md`,
             `tracks/memory-tbackend-lifecycle-golden-fixtures-v0.md`
Artifact:   `fixtures/add.igapp/`

---

## Purpose

This track delivers the **first hand-authored `.igapp/` artifact** — a
`CompiledProgram` for the canonical `Add` contract from golden fixtures
(FIXTURE-003..005). It exercises the full RuntimeMachine `load` + `evaluate`
lifecycle without requiring a real compiler.

> `compilation-deployment.md`:
> "The first practical artifact should be `.igapp/` or canonical JSON.
> The executable proof may stay hand-authored because it tests
> RuntimeMachine semantics, not source-language compilation."

---

## Artifact Structure

```text
fixtures/add.igapp/
  manifest.json       -- program_id, artifact_hash, language_version, format
  semantic_ir.json    -- SemanticIR: contracts, dependency_graph, eval_targets
  contracts/
    add.json          -- ContractIR: ports, compute_nodes, type_signature
  classified_ast.json -- ClassifiedProgram: fragment classes per node
  requirements.json   -- temporal + lifecycle + capability + required_tbackend_caps
  projections.json    -- [] (no named slices in Add)
  diagnostics.json    -- [] (no compile errors)
```

---

## Contract: Add

**Source equivalent (informative — not parsed; hand-authored IR):**

```text
contract Add do
  input  :a, Integer
  input  :b, Integer
  compute :sum, ->(a, b) { a + b }
  output :sum
end
```

**Fragment class:** `:core` — pure arithmetic, no ambient IO, no effects,
no external state, explicit temporal context required at evaluation.

**Dependency graph:**

```text
input:a ──┐
           ├─→ node_sum ──→ output:sum
input:b ──┘
```

All edges are `:data`. DAG is acyclic (verified).

---

## End-to-End Load Test (FIXTURE-003 replay)

### Step 1: Verify artifact integrity

```ruby
manifest = JSON.parse(File.read("fixtures/add.igapp/manifest.json"))

# The artifact_hash must match the computed hash over canonical content
assert manifest["fragment_class"] == "core"
assert manifest["diagnostics"]    == []
assert manifest["warnings"]       == []
assert manifest["format"]         == "igapp_dir"
```

### Step 2: Load into RuntimeMachine (memory TBackend)

```ruby
# Pseudocode — matches PROP-011 §Step 2 contract

backend = MemoryTBackend.new(version: "0.1.0")
runtime = RuntimeMachine.new(
  backend:         backend,
  axiom_version:   "1.0.0",
  runtime_config:  RuntimeContract.core_only,
  session_id:      "session-test-001",
  started_at:      Time.utc(2026, 5, 5, 10, 0, 0)
)

# Boot (FIXTURE-001 sequence)
boot_receipt = runtime.boot!
assert boot_receipt.status == :ready

# Load the hand-authored artifact
program = CompiledProgram.load_igapp("fixtures/add.igapp/")
load_receipt = runtime.load(program)

assert load_receipt.status            == :loaded
assert load_receipt.contracts_loaded  == 1
```

**Expected observations (in order):**

```text
[1] Obs[:platform_observation, AxiomDescriptor]    lifecycle: :durable
[2] Obs[:platform_observation, RuntimeContract]    lifecycle: :durable
[3] Obs[:platform_observation, TBackendDescriptor] lifecycle: :durable
[4] Obs[:verification_observation, VerificationReport] payload.trust_level: :trusted
[5] Obs[:platform_observation, BootReceipt]        payload.status: :ready

[6] Obs[:descriptor_observation, ContractDescriptor]
      subject:        "contract://add"
      lifecycle:      :durable
      payload.name:   "Add"
      payload.fragment_class: :core
      payload.artifact_hash: manifest["artifact_hash"]

[7] Obs[:platform_observation, ClassifiedAST]
      subject:        "classified://session-test-001/load-1"
      payload.program_id:    "prog_a3f8c2e1d7b4509a"
      payload.contracts:     ["Add"]
      payload.oof_count:     0

[8] Obs[:platform_observation, LoadReceipt]
      subject:        "load://session-test-001/1"
      lifecycle:      :durable
      payload.status: :loaded
      payload.program_id: "prog_a3f8c2e1d7b4509a"
      payload.contracts_loaded: 1
```

**Invariant check:**

```ruby
# ContractDescriptor carries artifact_hash — provenance anchor
desc_obs = backend.find_by_kind(:descriptor_observation).first
assert desc_obs.payload["artifact_hash"] == manifest["artifact_hash"]

# All obs carry observed_under links
all_obs = backend.all_observations
all_obs.each do |obs|
  assert obs.links.any? { |l| l[:rel] == "observed_under" }
  assert obs.links.any? { |l| l[:rel] == "produced_in" }
end
```

---

## End-to-End Evaluate Test (FIXTURE-005 replay)

### Step 3: Evaluate Add(3, 4)

```ruby
eval_receipt = runtime.evaluate(
  contract_ref: "Add",
  inputs:       { a: 3, b: 4 },
  temporal_ctx: TemporalCtx.new(as_of: Time.utc(2026, 5, 5, 10, 1, 0)),
  options:      EvaluationOptions.new(observation_emit: :all, dry_run: false)
)

assert eval_receipt.status == :ok
```

**Expected observations (continuing from [8]):**

```text
[9]  Obs[:value_observation, Integer]
       subject:         "contract://add/sum"
       lifecycle:       :session
       payload:         7
       temporal.as_of:  "2026-05-05T10:01:00Z"
       content_hash:    sha256(canonical(payload: 7, as_of: "2026-05-05T10:01:00Z"))

[10] Obs[:platform_observation, EvaluationReceipt]
       subject:         "eval://session-test-001/1"
       lifecycle:       :session
       payload.status:  :ok
       payload.output_obs_ids: [ obs[9].id ]
       payload.temporal_ctx.as_of: "2026-05-05T10:01:00Z"
```

**Temporal isolation assertions (FIXTURE-010):**

```ruby
# Read at evaluation time -> Some(7)
result = backend.read(
  subject: "contract://add/sum",
  as_of:   Time.utc(2026, 5, 5, 10, 1, 0)
)
assert result == Some(7)

# Read before evaluation -> None
result_before = backend.read(
  subject: "contract://add/sum",
  as_of:   Time.utc(2026, 5, 5, 9, 59, 0)
)
assert result_before == None

# Ambient read (no as_of) -> OOF -> failure_observation
ambient = backend.read(subject: "contract://add/sum")  # no as_of
assert ambient.is_a?(FailureObservation)
assert ambient.payload["reason_code"] == "constraint.missing_as_of"
```

**Reproducibility assertion:**

```ruby
# Same inputs + same Tt -> same content_hash
eval2 = runtime.evaluate(
  contract_ref: "Add",
  inputs:       { a: 3, b: 4 },
  temporal_ctx: TemporalCtx.new(as_of: Time.utc(2026, 5, 5, 10, 1, 0))
)
obs2 = backend.find_by_kind(:value_observation).last
assert obs2.content_hash == obs[9].content_hash  # deterministic
```

---

## End-to-End Checkpoint Test (FIXTURE-007 replay)

### Step 4: Checkpoint

```ruby
checkpoint_receipt = runtime.checkpoint(
  CheckpointPolicy.new(
    scope:            :after_session,
    snapshot_slices:  [],
    compact_eligible: true,
    retain_local:     false
  )
)
```

**Expected observations (continuing from [10]):**

```text
[11] Obs[:platform_observation, FlushResult]
       payload.flushed_count:   2      -- [9] and [10] (:session)
       payload.persisted_count: 8      -- [1]..[8] (:durable)
       payload.checkpointed:    true

[12] Obs[:platform_observation, SemanticImage]
       subject:   "image://session-test-001"
       lifecycle: :audit
       payload.observation_count: 10
       payload.checkpoint.seq_id: 10

[13] Obs[:platform_observation, CompactionReceipt]
       payload.removed_count:    0     -- no :local obs; :session flushed
       payload.preserved_count:  12    -- all :durable + :audit + [12]

[14] Obs[:platform_observation, CheckpointReceipt]
       payload.semantic_image:   obs[12].id
       payload.flush_result:     obs[11].id
       payload.compaction_receipt: obs[13].id
```

**Checkpoint invariants:**

```ruby
# SemanticImage before CompactionReceipt (PROP-011 ordering rule)
image_seq = backend.seq_id_for(obs[12].id)
compact_seq = backend.seq_id_for(obs[13].id)
assert image_seq < compact_seq

# SemanticImage in GC roots (must survive compaction)
assert backend.gc_roots.include?(obs[12].id)

# image_id is content-addressed
image = obs[12].payload
assert image["image_id"] == hash_content(
  axiom_descriptor_hash,
  runtime_contract_hash,
  obs_hash_over_all(10),
  image["checkpoint"]["checkpoint_id"]
)
```

---

## Missing TemporalCtx Test (FIXTURE-006 replay)

```ruby
bad_result = runtime.evaluate(
  contract_ref: "Add",
  inputs:       { a: 1, b: 2 },
  temporal_ctx: nil  # MISSING -- OOF
)

assert bad_result.status == :rejected
failure_obs = backend.find_by_kind(:failure_observation).last
assert failure_obs.payload["reason_code"] == "constraint.missing_temporal_ctx"
assert failure_obs.payload["status"]      == "rejected"

# No value_observation should have been emitted
value_obs_count_before = 1  # from FIXTURE-005 (sum=7)
assert backend.find_by_kind(:value_observation).count == value_obs_count_before
```

---

## Artifact Validation Checklist

A `devkit` artifact_validator should verify:

| Check | File | Rule |
|-------|------|------|
| `fragment_class == "core"` | manifest.json | No OOF allowed in CORE artifact |
| `diagnostics == []` | manifest.json | No compile errors |
| `oof_count == 0` | classified_ast.json | PROP-003 Pass 0 |
| `required_caps == []` | requirements.json | No capabilities declared |
| `effect_kinds == []` | requirements.json | No effects declared |
| All edges acyclic | semantic_ir.json | DependencyGraph must be DAG |
| `artifact_hash` matches | manifest.json | Recompute and compare |
| `program_id == hash(semantic_ir)` | manifest.json | Content-addressed identity |
| All node fragment_class == "core" | classified_ast.json | Consistent with program |
| `required_tbackend_caps.read_as_of == true` | requirements.json | PROP-008 |

---

## What This Proves

By loading and evaluating `add.igapp/` against a `:memory` TBackend:

1. **RuntimeMachine.load contract** (PROP-011 §Step 2) works against a hand-authored artifact
2. **descriptor_observation carries artifact_hash** — provenance anchor established
3. **Temporal isolation**: `read(as_of: T)` returns `None` before evaluation, `Some(7)` after
4. **Reproducibility**: same inputs + same `Tt` → same `content_hash`
5. **OOF gate**: missing `TemporalCtx` → `failure_observation`; no `value_observation` emitted
6. **Checkpoint ordering**: `SemanticImage` before `CompactionReceipt` (PROP-011 invariant)
7. **SemanticImage in GC roots**: survives compaction

All seven properties are verifiable against a `:memory` backend without
network, Ledger, or any external infrastructure.

---

## Next Steps for Devkit

1. **Implement `CompiledProgram.load_igapp(path)`** in Ruby: reads the
   `.igapp/` directory, validates `manifest.json`, assembles a
   `CompiledProgram` struct.

2. **Implement `MemoryTBackend`** satisfying the PROP-008 interface:
   `read`, `append`, `replay`, `snapshot`, `compact`, `subscribe`.
   Reference data structure: `OrderedMap[ObsId, ObsPacket]` + subject index.

3. **Wire `RuntimeMachine`** to call `MemoryTBackend` at each lifecycle step
   (PROP-011): `boot!`, `load(program)`, `evaluate(...)`, `checkpoint(...)`.

4. **Run the seven proofs above** as RSpec examples against the hand-authored
   artifact. These become the golden conformance tests.

5. **Add `.igapp/` artifact for `AvailabilityProjection`** (Technician
   Dispatch example from `temporal-lifecycle.md`) as the second fixture —
   this one exercises `:window` lifecycle, `TemporalWindow`, and
   `BoundaryReceipt`.
