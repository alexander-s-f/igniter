# Ch7: RuntimeMachine

Source PROPs: PROP-006, PROP-009, PROP-009.1, PROP-011
Status: accepted; load/evaluate/checkpoint/resume proven
Proof: experiments/runtime_machine_memory_proof/

---

## 7.1 Lifecycle (PROP-011 §Runtime Machine Lifecycle)

```
boot        — initialize RuntimeMachine instance, verify environment
load        — parse .igapp/ manifest + contract files → LoadedProgram
evaluate    — resolve all nodes in resolution_order → EvaluationResult
checkpoint  — serialize current evaluation state → CheckpointBundle (ESCAPE)
resume      — restore from CheckpointBundle → LoadedProgram (ESCAPE)
```

Each step is typed. No step can be skipped. Boot must precede load, etc.

---

## 7.2 Load Semantics (PROP-011 §Load)

```
RuntimeMachine.load(path) → LoadedProgram | LoadError
```

- Reads `manifest.json` → contract name list
- Reads each `contracts/<Name>.json` → ContractIR
- Verifies: `kind == "contract_ir"`, no `fragment_class: "oof"`
- Emits: `descriptor_observation` (Obs[:descriptor, ProgramDescriptor])
- Returns: `LoadedProgram` with `schema_descriptor` for compatibility checks

**CompatibilityReport gate** (PROP-009.1): CompatibilityReport is evaluated
AFTER Boot + Verification, not before. GATE-1 invariant:
```
CompatibilityReport must not be consulted before Boot + Verification complete.
```

---

## 7.3 Evaluate Semantics (PROP-006 §Evaluate)

```
RuntimeMachine.evaluate(program, inputs) → EvaluationResult
```

- Validates all required inputs are present and typed
- Resolves nodes in `resolution_order` (topological order)
- For each node:
  - `input_node`: take from inputs map
  - `compute_node`: call operator with resolved arg values
  - `output_node`: collect into output map
- Emits: `computation_observation` per resolved node (CORE contracts)
- Cache: `@cache(ttl)` nodes are memoized by content-addressed key

**Parallel evaluation**: independent nodes (no shared deps) may be resolved
concurrently (thread_pool runner). CORE nodes are pure → safe to parallelize.

---

## 7.4 Checkpoint / Resume (PROP-011 §Checkpoint, PROP-008)

```
RuntimeMachine.checkpoint(program) → CheckpointBundle (ESCAPE)
RuntimeMachine.resume(bundle)      → LoadedProgram    (ESCAPE)
```

Both are ESCAPE: they touch external storage (TBackend).

**Resume compatibility** (PROP-009 §ResumeStatus):

```
trusted      — schema_fingerprint unchanged; full resume
provisional  — safe drift detected; resume with degraded mode
downgraded   — breaking but recoverable; migration required
blocked      — incompatible; cannot resume
```

---

## 7.5 Schema Check (PROP-017 §CompatibilityReport)

`CompatibilityReport` has four independent check dimensions:

```
runtime_check   — runtime version compatibility
backend_check   — TBackend adapter compatibility
obs_check       — observation envelope format compatibility
schema_check    — contract schema (PROP-017) compatibility
```

All four must be `ok` for `status: trusted`. Any `blocked` dimension → `status: blocked`.

---

## 7.6 Proven Behaviour (experiments/runtime_machine_memory_proof/)

```
✅  RuntimeMachine.load(hand_authored.igapp) → LoadedProgram
✅  RuntimeMachine.evaluate(program, {a:3, b:4}) → {result: 7}
✅  RuntimeMachine.checkpoint(program) → CheckpointBundle
✅  RuntimeMachine.resume(bundle) → LoadedProgram
✅  CompatibilityReport generated with schema_check field
✅  schema_descriptor carried on LoadedProgram
```

**Not yet proven** (Slice C):
```
🔴  evaluate with stdlib operators (numeric.add, fold, map, filter)
    — operator lookup returns nil; RuntimeMachine.evaluate not yet connected
```
