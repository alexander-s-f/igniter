# Ch7: RuntimeMachine

Source PROPs: PROP-006, PROP-008, PROP-009, PROP-009.1, PROP-011, PROP-022,
PROP-022A, PROP-028
Status: synced for Stage 3 temporal load/cache contract (2026-05-08)
Primary evidence:

- `experiments/runtime_machine_memory_proof/` — load/evaluate/checkpoint/resume PASS
- `experiments/stdlib_execution_kernel_stage1/` — stdlib execution kernel PASS
- `experiments/temporal_cache_key_proof/` — CORE vs TEMPORAL cache-key proof PASS
- `experiments/runtime_cache_proof_local_memoization/` — proof-local cache semantics PASS
- `experiments/temporal_runtime_load_guard/` — TEMPORAL load guard PASS

---

## 7.1 Lifecycle

```text
boot        — initialize RuntimeMachine instance, verify environment
load        — parse .igapp/ manifest + contract files -> LoadedProgram
evaluate    — resolve supported nodes -> EvaluationResult
checkpoint  — serialize current evaluation state -> CheckpointBundle (ESCAPE)
resume      — restore from CheckpointBundle -> LoadedProgram (ESCAPE)
```

Each step is typed. Boot must precede load; load must precede evaluate.

---

## 7.2 Load Semantics

```text
RuntimeMachine.load(path) -> LoadedProgram | LoadRefusal
```

Load reads:

- `manifest.json`
- `compilation_report.json`
- `contracts/<Name>.json`
- `requirements.json`
- `compatibility_metadata.json`

Load verifies:

- manifest shape and contract list
- compilation report `pass_result == "ok"`
- each contract artifact exists and is not `fragment_class: "oof"`
- schema descriptor compatibility
- for TEMPORAL contracts, `manifest.contract_index` agrees with contract files

CompatibilityReport is evaluated after boot + verification, not before.

Gate invariant:

```text
CompatibilityReport must not be trusted before Boot + Verification complete.
```

---

## 7.3 Evaluate Semantics

```text
RuntimeMachine.evaluate(program, inputs) -> EvaluationResult | EvaluateRefusal
```

Evaluate:

- validates all required inputs are present and typed;
- resolves supported executable nodes in dependency order;
- emits `computation_observation` for supported CORE computation;
- refuses unsupported runtime surfaces with structured diagnostics.

Supported Stage 1 executable node kinds:

```text
input_node
compute_node
output_node
```

TEMPORAL assembled artifacts may load for inspection, but they are not
production-executable yet. See §7.8.

---

## 7.4 Stdlib and Operator Execution

The previous stdlib/operator line is no longer a blocker.

Stage 1/2 evidence proves:

```text
integer add/sub/mul/div/comparison
float add/mul
decimal add/sub/mul/rescale
bool and/or/not
string concat
collection map/filter/fold/count
option or_else
```

Runtime operator lookup and stdlib kernel execution are PASS in the Stage 1/2
proof suite. Unknown or unresolved stdlib operators remain assembler/compiler
refusals rather than runtime surprises.

---

## 7.5 Checkpoint / Resume

```text
RuntimeMachine.checkpoint(program) -> CheckpointBundle (ESCAPE)
RuntimeMachine.resume(bundle)      -> LoadedProgram    (ESCAPE)
```

Both are ESCAPE because they touch external state/storage.

Resume compatibility states:

```text
trusted      — schema_fingerprint unchanged; full resume
provisional  — safe drift detected; resume with degraded mode
downgraded   — breaking but recoverable; migration required
blocked      — incompatible; cannot resume
```

---

## 7.6 Compatibility Dimensions

`CompatibilityReport` has independent dimensions:

```text
runtime_check   — runtime version compatibility
backend_check   — TBackend adapter compatibility
obs_check       — observation envelope format compatibility
schema_check    — contract schema compatibility
cache_check     — cache key/freshness policy compatibility, when cache exists
```

All required dimensions must be `ok` for trusted execution. A blocked dimension
blocks the relevant load/evaluate/cache path.

Descriptor and temporal capability evidence may be report-only; report-only
metadata does not authorize live Ledger/TBackend binding.

---

## 7.7 Runtime Cache Key Contract

Production RuntimeMachine memoization is not enabled. The cache contract below
defines the required shape before production cache can exist.

### CORE Cache Keys

CORE keys use contract identity plus canonical non-temporal inputs:

```json
{
  "kind": "runtime_cache_key",
  "version": "runtime-cache-key-v1",
  "fragment": "CORE",
  "contract_ref": "contract/Add/sha256:<prefix>",
  "input_hash": "sha256:<canonical non-temporal inputs>",
  "temporal_coordinates": null
}
```

Formula:

```text
cache_key_hash = hash(version, fragment, contract_ref, input_hash)
```

### TEMPORAL Valid-Time Keys

History-style temporal keys add the explicit valid-time coordinate:

```json
{
  "kind": "runtime_cache_key",
  "version": "runtime-cache-key-v1",
  "fragment": "TEMPORAL",
  "axis": "valid_time",
  "contract_ref": "contract/HistoryAxesTest/sha256:<prefix>",
  "input_hash": "sha256:<canonical non-temporal inputs>",
  "temporal_coordinates": {
    "as_of": "2026-05-08T12:00:00Z"
  }
}
```

Formula:

```text
cache_key_hash = hash(version, fragment, axis, contract_ref, input_hash, as_of)
```

### TEMPORAL Bitemporal Keys

BiHistory-style temporal keys add both valid and transaction time:

```json
{
  "kind": "runtime_cache_key",
  "version": "runtime-cache-key-v1",
  "fragment": "TEMPORAL",
  "axis": "bitemporal",
  "contract_ref": "contract/BiHistoryAxesTest/sha256:<prefix>",
  "input_hash": "sha256:<canonical non-temporal inputs>",
  "temporal_coordinates": {
    "valid_time": "2026-05-08T12:00:00Z",
    "transaction_time": "2026-05-08T13:00:00Z"
  }
}
```

Formula:

```text
cache_key_hash = hash(
  version,
  fragment,
  axis,
  contract_ref,
  input_hash,
  valid_time,
  transaction_time
)
```

TEMPORAL coordinates are distinct key material. A CORE-shaped key for a
TEMPORAL contract is a cache schema mismatch, never a fallback.

### Freshness States

| State | Meaning | Runtime may return cached value? |
| --- | --- | --- |
| `fresh` | Key schema matches and dependencies/coordinates are verified current. | yes |
| `stale` | Runtime has evidence that dependency state or coordinate meaning changed. | no |
| `unknown` | Runtime cannot verify freshness because evidence is missing. | no by default |
| `provisional` | Runtime can return only with downgraded trust and explicit observation. | yes, marked provisional |

`unknown` must not silently become `fresh`. `provisional` is a trust mark, not
a convenience synonym for `fresh`.

### Cache Entry Envelope

```json
{
  "kind": "runtime_cache_entry",
  "version": "runtime-cache-entry-v1",
  "cache_key": {
    "key": "cache/<short-hash>",
    "hash": "sha256:<key-material>",
    "schema": "runtime-cache-key-v1"
  },
  "fragment": "CORE | TEMPORAL",
  "axis": "valid_time | bitemporal | null",
  "contract_ref": "contract/...",
  "program_id": "semanticir/...",
  "value_hash": "sha256:<canonical output>",
  "value_ref": "runtime-value/<hash-or-local-ref>",
  "freshness": "fresh | stale | unknown | provisional",
  "temporal_coordinates": null,
  "evidence_links": []
}
```

Cache observations should expose hashes, refs, fragment, axis, and freshness.
They should not expose raw sensitive inputs by default.

---

## 7.8 TEMPORAL Load Guard

Current Stage 3 policy:

```text
load_accept_evaluate_refuse
```

Meaning:

- Load may accept a well-formed TEMPORAL `.igapp/` for inspection,
  descriptor checks, and compatibility reporting.
- Load must validate `manifest.contract_index` against the contract artifact.
- Evaluate must refuse TEMPORAL contracts unless a future RuntimeMachine
  temporal executor and required capabilities are explicitly approved.
- Cache remains disabled for production TEMPORAL execution.
- Ledger/TBackend live binding remains out of scope.

Machine-readable guard in `compatibility_metadata.json`:

```json
{
  "runtime_execution": {
    "status": "unsupported",
    "guard_policy": "load_accept_evaluate_refuse",
    "guard_at": "evaluate",
    "load": {
      "decision": "accept_for_inspection",
      "requires_contract_index": true
    },
    "evaluate": {
      "decision": "refuse_temporal_contract",
      "reason_code": "runtime.temporal_execution_unsupported"
    }
  }
}
```

TEMPORAL load refusal gates include:

```text
L-T1  missing manifest.contract_index for a TEMPORAL contract
L-T2  manifest fragment disagrees with contract fragment
L-T3  manifest axes disagree with temporal access nodes
L-T4  required capabilities disagree with escape_boundaries/node caps
L-T5  TEMPORAL contract advertises CORE cache hint
L-T6  TEMPORAL entry omits explicit temporal coordinates
```

TEMPORAL evaluate refusals include:

```text
runtime.temporal_execution_unsupported
runtime.temporal_capability_missing
```

This section does not authorize production temporal executor work, production
cache, Ledger binding, or live TBackend reads/writes/replay.

---

## 7.9 Proven Behaviour

Stage 1/2 runtime:

```text
PASS RuntimeMachine.load(hand_authored.igapp) -> LoadedProgram
PASS RuntimeMachine.evaluate(program, {a:3, b:4}) -> {result: 7}
PASS RuntimeMachine.checkpoint(program) -> CheckpointBundle
PASS RuntimeMachine.resume(bundle) -> LoadedProgram
PASS CompatibilityReport with schema_check
PASS schema_descriptor carried on LoadedProgram
PASS stdlib execution kernel and operator lookup
```

Stage 3 proof-local temporal/cache:

```text
PASS temporal_cache_key_proof
PASS runtime_cache_proof_local_memoization
PASS temporal_runtime_load_guard
```

The proof-local cache demonstrates key construction, freshness handling, and
observations. It is not production RuntimeMachine memoization.

---

## 7.10 Evidence References

| Evidence | What It Proves |
| --- | --- |
| `tracks/runtime-temporal-cache-contract-v0.md` | S3-R3-C3: cache key schema, freshness states, no production memoization |
| `tracks/runtime-cache-proof-local-memoization-v0.md` | S3-R4-C5: proof-local CORE/TEMPORAL cache behavior |
| `tracks/temporal-assembler-manifest-contract-index-v0.md` | S3-R5-C1: manifest contract index and cache schema hint |
| `tracks/temporal-runtime-load-guard-v0.md` | S3-R5-C2: load accepts for inspection, evaluate refuses unsupported TEMPORAL |
| `experiments/stdlib_execution_kernel_stage1/` | stdlib/operator execution PASS |
