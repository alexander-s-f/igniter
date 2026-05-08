# OLAP Point Proof v0

Card: S2-R5-C4-P
Role: `[Igniter-Lang Research Agent]`
Track: `olap-point-proof-v0`
Status: done
Date: 2026-05-07
Depends on: none

## Goal

Create the first executable proof for PROP-024 `OLAPPoint[T,Dims]`.

This is a proof-local Stage 2 fixture. It does not add parser syntax,
TypeChecker support, production runtime integration, or distributed
scatter/gather.

## Current Horizon

Stage 2 now has proof-local coverage for the temporal/analytical family:

```text
stream T       = ingress / flow
History[T]     = durable temporal memory read by explicit time
OLAPPoint      = analytical projection / cube point with typed dimensions
```

PROP-024 says `History[T]` is equivalent to a one-dimensional OLAP point:

```text
History[T] ~= OLAPPoint[T, {time: DateTime}]
```

This proof starts with a small multi-dimensional point instead of that 1D
special case.

## Fixture

Experiment:

```text
igniter-lang/experiments/olap_point_proof/olap_point_proof.rb
```

Source sketch:

```text
igniter-lang/experiments/olap_point_proof/revenue_point.ig
```

The source sketch is not parsed in this slice. The runner builds a
hand-authored SemanticIR-like program with:

```text
olap_point_decl
olap_access_node
```

OLAP point:

```text
Revenue
  measure: Decimal[2]
  dimensions:
    date: String
    region: String
    channel: String
  granularity:
    date: daily
  indexed:
    date, region
```

Positive access:

```text
Revenue[date: "2026-05-07", region: "west", channel: "online"]
  -> Decimal[2] "35.50"
```

## Runtime Proof

Synthetic fulfilled-order facts:

```text
west / online / 2026-05-07: 12.25
west / online / 2026-05-07: 23.25
west / retail / 2026-05-07: 9.50
east / online / 2026-05-07: 18.00
```

Materialized cells:

```text
west / online -> 35.50
west / retail -> 9.50
east / online -> 18.00
```

Point result:

```text
dimensions:
  date: 2026-05-07
  region: west
  channel: online
measure_type: Decimal[2]
measure: "35.50"
source_fact_refs: 2 facts
```

Local rollup result:

```text
keep dimensions: date, region
execution_plan: local_single_node_no_scatter_gather
west total: 45.00
east total: 18.00
```

## Evidence

Every materialized OLAP cell emits:

```text
kind: olap_cell_observation
lifecycle: analytical
olap_ref: Revenue
dimensions: typed dimension map
measure_type: Decimal[2]
measure: Decimal string
source_fact_refs: [...]
```

The point result links back to:

```text
cell_ref
observation_ref
source_fact_refs
```

## Negative Cases

The proof emits three compact reports:

```text
negative_missing_dimension             -> OOF-O-T1
negative_dimension_type_mismatch       -> OOF-O-T2
negative_empty_without_source_or_data  -> OOF-O3
```

Notes:

```text
OOF-O3 comes from PROP-024.
OOF-O-T1 and OOF-O-T2 are proof-local candidate TypeChecker rules for
dimension-shape and dimension-type validation.
```

All negative reports have:

```text
pass_result: oof
semantic_ir_ref: null
category: olap_oof
```

## Proof Output

```text
PASS olap_point_proof
semanticir.olap_point_decl: ok
semanticir.olap_access_node: ok
type.olap_point_typed_dimensions: ok
type.measure_decimal_string: ok
runtime.materializes_cells: ok
runtime.point_access_deterministic: ok
runtime.local_rollup_no_scatter_gather: ok
evidence.cell_observations_link_sources: ok
negative.dimension_missing_oof: ok
negative.dimension_type_mismatch_oof: ok
negative.empty_without_source_oof_o3: ok
relationship.stream_history_olap_documented: ok
point.measure: 35.50
point.dimensions: {"channel":"online","date":"2026-05-07","region":"west"}
rollup.plan: local_single_node_no_scatter_gather
summary: igniter-lang/experiments/olap_point_proof/summary.json
```

Stage 1 regression:

```text
PASS stage1_close_candidate
classifier: PASS
typechecker: PASS
semanticir: PASS
stdlib_kernel: PASS
igapp_assembler: PASS
summary: igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.json
```

## Generated Artifacts

```text
experiments/olap_point_proof/summary.json
experiments/olap_point_proof/golden/semantic_ir_program.json
experiments/olap_point_proof/golden/cells.json
experiments/olap_point_proof/golden/point_result.json
experiments/olap_point_proof/golden/rollup_result.json
experiments/olap_point_proof/golden/negative_missing_dimension.json
experiments/olap_point_proof/golden/negative_dimension_type_mismatch.json
experiments/olap_point_proof/golden/negative_empty_without_source_or_data.json
```

## Proof-Local vs Target

Proof-local:

```text
source sketch parser bypass
hand-authored SemanticIR-like olap nodes
MemoryOLAPBackend
synthetic fulfilled-order facts
local single-node rollup
candidate OOF-O-T1 / OOF-O-T2 diagnostics
```

Language/compiler/runtime target:

```text
parser support for olap_point top-level declarations
parser support for OLAPPoint[T,Dims] type expressions
classifier ownership for olap_point declarations and access nodes
TypeChecker ownership for dimension map shape/type validation
SemanticIR emission of olap_point_decl and olap_access_node
RuntimeMachine OLAP adapter boundary
stream snapshot -> OLAP cell population path
History[T] specialization over OLAP time dimension
```

Out of scope:

```text
distributed scatter/gather
segment cache hierarchy
drill/compare/transform operations
production cube storage
real adapters
```

## Changed Files

```text
docs/tracks/olap-point-proof-v0.md
experiments/olap_point_proof/olap_point_proof.rb
experiments/olap_point_proof/revenue_point.ig
experiments/olap_point_proof/summary.json
experiments/olap_point_proof/golden/semantic_ir_program.json
experiments/olap_point_proof/golden/cells.json
experiments/olap_point_proof/golden/point_result.json
experiments/olap_point_proof/golden/rollup_result.json
experiments/olap_point_proof/golden/negative_missing_dimension.json
experiments/olap_point_proof/golden/negative_dimension_type_mismatch.json
experiments/olap_point_proof/golden/negative_empty_without_source_or_data.json
```

## Handoff

```text
Card: S2-R5-C4-P
[Igniter-Lang Research Agent]
Track: olap-point-proof-v0
Status: done
Neighbors: Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- Used a synthetic Revenue OLAPPoint with Decimal[2] measure and typed
  date/region/channel dimensions.
- Kept parser syntax proof-local and hand-authored SemanticIR-like nodes.
- Proved point access and local rollup only; no distributed scatter/gather.
- Kept stream/history files untouched.

[S] Signals:
- Positive typed OLAPPoint materializes deterministic analytical cells.
- Point access returns Decimal[2] "35.50" with source fact evidence.
- Local rollup by date/region returns west total "45.00".
- Negative reports cover missing dimension, dimension type mismatch, and OOF-O3.

[T] Tests / Proofs:
- ruby igniter-lang/experiments/olap_point_proof/olap_point_proof.rb -> PASS
- ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb -> PASS

[R] Risks / Recommendations:
- Compiler/Grammar should own parser/type expression shape for OLAPPoint[T,Dims].
- TypeChecker should formalize OOF-O-T1 / OOF-O-T2 or assign equivalent OOF codes.
- Bridge/Runtime should keep OLAP adapter separate from stream ingress and History memory.

[Next] Suggested next slice:
- olap-point-parser-typechecker-boundary-v0
```
