# Track: Temporal SemanticIR Access Node v0

Card: S3-R3-C2-P
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Track: `igniter-lang/temporal-semanticir-access-node-v0`
Status: done
Date: 2026-05-08

---

## Goal

Carry PROP-028 TEMPORAL metadata from `TypedProgram` into SemanticIR without
enabling RuntimeMachine memoization, parser syntax, or production TBackend
binding.

---

## Formal Decision

[D] A typed temporal read lowers to two SemanticIR nodes:

```text
temporal_input_node
temporal_access_node
```

[D] The access node carries the PROP-028 split:

```text
node_fragment_class:  temporal
value_fragment_class: core
```

[D] The canonical capability names are preserved:

```text
History[T]   -> history_read
BiHistory[T] -> bihistory_read
```

[D] The temporal axis and coordinate refs are explicit:

```text
History[T]:
  temporal_axis: valid_time
  coordinate_refs.as_of
  as_of_ref

BiHistory[T]:
  temporal_axis: bitemporal
  coordinate_refs.valid_time
  coordinate_refs.transaction_time
  valid_time_ref
  transaction_time_ref
```

[D] No cache metadata is emitted in this slice. The proof explicitly checks that
SemanticIR does not contain `cache_key` or memoization fields.

---

## Implementation

`TypeChecker` now carries the remaining read-source metadata needed by
SemanticIR:

```text
from
lifecycle
```

and enriches typed `history_at` / `bihistory_at` expressions with a
`semantic_node` that includes fragment, value, capability, and coordinate
metadata.

`SemanticIREmitter#emit_typed` now lowers typed temporal reads into:

```text
temporal_input_node
temporal_access_node
escape_boundaries.required_caps
```

This stays inside the typed emission path. It does not add source parser syntax.

---

## Proof

Runner:

```text
ruby igniter-lang/experiments/temporal_semanticir_access_node/temporal_semanticir_access_node.rb --check-golden
```

Output:

```text
PASS temporal_semanticir_access_node
history_valid.report_ok: ok
history_valid.contract_fragment_temporal: ok
history_valid.escape_boundary_capability: ok
history_valid.temporal_input_node: ok
history_valid.temporal_access_node: ok
history_valid.coordinate_refs: ok
history_valid.no_runtime_cache_metadata: ok
bihistory_valid.report_ok: ok
bihistory_valid.contract_fragment_temporal: ok
bihistory_valid.escape_boundary_capability: ok
bihistory_valid.temporal_input_node: ok
bihistory_valid.temporal_access_node: ok
bihistory_valid.coordinate_refs: ok
bihistory_valid.no_runtime_cache_metadata: ok
golden.history_valid.semantic_ir: ok
golden.history_valid.compilation_report: ok
golden.bihistory_valid.semantic_ir: ok
golden.bihistory_valid.compilation_report: ok
summary: igniter-lang/experiments/temporal_semanticir_access_node/summary.json
```

Golden outputs:

```text
igniter-lang/experiments/temporal_semanticir_access_node/golden/history_valid.semantic_ir.json
igniter-lang/experiments/temporal_semanticir_access_node/golden/history_valid.compilation_report.json
igniter-lang/experiments/temporal_semanticir_access_node/golden/bihistory_valid.semantic_ir.json
igniter-lang/experiments/temporal_semanticir_access_node/golden/bihistory_valid.compilation_report.json
```

The proof uses existing TypeChecker classified fixtures:

```text
igniter-lang/experiments/typechecker_proof/classified/history_valid.classified.json
igniter-lang/experiments/typechecker_proof/classified/bihistory_valid.classified.json
```

---

## SemanticIR Shape

History access proof shape:

```text
temporal_input_node:
  name: price_history
  type: History[String]
  store_ref: sku/{sku}/price
  axis: valid_time
  node_fragment_class: temporal
  value_fragment_class: core
  required_capability: history_read

temporal_access_node:
  name: price_at
  source_ref: price_history
  temporal_axis: valid_time
  as_of_ref: as_of
  coordinate_refs: { as_of: as_of }
  node_fragment_class: temporal
  value_fragment_class: core
  required_capability: history_read
```

BiHistory access proof shape:

```text
temporal_input_node:
  name: avail_history
  type: BiHistory[String]
  store_ref: t/{technician_id}/avail
  axis: bitemporal
  node_fragment_class: temporal
  value_fragment_class: core
  required_capability: bihistory_read

temporal_access_node:
  name: avail_at
  source_ref: avail_history
  temporal_axis: bitemporal
  valid_time_ref: valid_time
  transaction_time_ref: transaction_time
  coordinate_refs:
    valid_time: valid_time
    transaction_time: transaction_time
  node_fragment_class: temporal
  value_fragment_class: core
  required_capability: bihistory_read
```

---

## Manifest / Assembler Questions

[Q] `Assembler#contract_file` currently assumes executable compute nodes with
`expr` and `type`. Should `temporal_input_node` and `temporal_access_node` be
copied as capability nodes, or split into `requirements.json` plus non-compute
contract nodes?

[Q] Stage 1/2 manifests mostly assume `core | escape | oof`. Should Stage 3
manifests accept `temporal` as a first-class contract fragment before
RuntimeMachine memoization lands?

[Q] What is the source of truth for required temporal capabilities during
assembly: `escape_boundaries`, `node.required_caps`, or a future
requirements-builder pass?

---

## Remaining PROP-028 Gaps

[R] Parser syntax for explicit History/BiHistory coordinate reads remains
unimplemented.

[R] RuntimeMachine load/evaluate support for SemanticIR `temporal_access_node`
remains proof-local.

[R] RuntimeMachine memoization/cache key implementation remains out of scope.

[R] `OOF-TM2` ambient-time misuse is not implemented.

[R] `OOF-TM7` temporal read inside CORE-required lambda/body is not implemented.

[R] `OOF-TM8` production TBackend capability check remains report/fixture-backed.

[R] `OOF-TM9` CORE cache key misuse is proven as a runtime-cache design bug, but
is not enforced by RuntimeMachine.

---

## Verification Notes

```text
ruby igniter-lang/experiments/temporal_semanticir_access_node/temporal_semanticir_access_node.rb --check-golden
  -> PASS

ruby igniter-lang/experiments/typechecker_proof/typechecker_proof.rb --check-golden
  -> PASS

ruby -c igniter-lang/experiments/temporal_semanticir_access_node/temporal_semanticir_access_node.rb
  -> Syntax OK
```

Stage 1 close candidate was also run, but it failed in the classifier stage
because the current worktree classifier output now includes an `olap_points`
top-level field not reflected in classifier goldens. That mismatch appears
outside this SemanticIR temporal-access slice; no classifier goldens were
changed here.

---

## Handoff

```text
Card: S3-R3-C2-P
Agent: [Igniter-Lang Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: igniter-lang/temporal-semanticir-access-node-v0
Status: done

[D] Decisions
- Lower typed History/BiHistory reads into SemanticIR temporal_input_node and
  temporal_access_node.
- Preserve node_fragment_class=temporal and value_fragment_class=core.
- Preserve canonical required capabilities: history_read and bihistory_read.
- Preserve valid_time/as_of and bitemporal vt/tt coordinate refs.
- Do not add parser syntax, RuntimeMachine cache, or production TBackend binding.

[S] Shipped / Signals
- SemanticIR proof/goldens added for History and BiHistory typed fixtures.
- TypeChecker now keeps read `from`/`lifecycle` and enriches temporal semantic
  nodes.
- SemanticIREmitter#emit_typed now carries temporal input/access nodes and
  temporal capability boundaries.

[T] Tests / Proofs
- temporal_semanticir_access_node --check-golden -> PASS
- typechecker_proof --check-golden -> PASS
- script syntax check -> OK
- stage1_close_candidate -> FAIL at classifier golden mismatch; see notes.

[R] Risks / Recommendations
- Assembler and manifest handling for temporal nodes must be decided before
  assembling temporal SemanticIR into production `.igapp/`.
- RuntimeMachine memoization must wait for the separate cache entry/freshness
  contract; this slice intentionally emits no cache metadata.

[Next] Suggested next slice
- temporal-assembler-requirements-boundary-v0: decide how temporal nodes become
  requirements/manifest/contract artifacts without enabling runtime cache.
```
