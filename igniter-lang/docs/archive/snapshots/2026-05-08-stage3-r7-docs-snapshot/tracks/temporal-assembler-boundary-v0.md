# Track: Temporal Assembler Boundary v0

Card: S3-R4-C1-P
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `igniter-lang/temporal-assembler-boundary-v0`
Status: done
Date: 2026-05-08

---

## Goal

Make temporal SemanticIR assembleable into `.igapp/` artifacts without claiming
production RuntimeMachine temporal execution, cache, or Ledger/TBackend binding.

Affected neighbor roles:

- Compiler/Grammar Expert
- Bridge Agent

---

## Current Horizon

Temporal source lowering now reaches SemanticIR:

```text
TypedProgram
  -> temporal_input_node
  -> temporal_access_node
  -> SemanticIRProgram
```

Before this slice, `Assembler#contract_file` still assumed every SemanticIR node
had executable `expr` and `type.name` fields. That made temporal SemanticIR
non-assembleable even though the SemanticIR shape was already proven.

---

## Decisions

[D] Temporal nodes are preserved in contract artifact files as non-compute
nodes:

```text
contracts/<contract>.json
  temporal_nodes:
    - temporal_input_node
    - temporal_access_node
```

[D] Temporal capability and coordinate evidence is also copied into
`requirements.json`:

```text
requirements.temporal.axes
requirements.temporal.coordinate_refs
requirements.capabilities.required_caps
```

[D] `manifest.fragment_class` may be `temporal` when every assembled contract
is temporal. Mixed artifacts still use `mixed`.

[D] Runtime execution is explicitly unsupported for this proof. The assembled
artifact carries:

```text
compatibility_metadata.runtime_execution.status = "unsupported"
```

[D] No RuntimeMachine temporal execution, production cache, Ledger binding, or
TBackend adapter is added here.

---

## Implementation

Updated `IgniterLang::Assembler`:

- avoids `expr` / `type.name` assumptions for non-compute nodes
- keeps executable nodes in `compute_nodes`
- places `temporal_input_node` and `temporal_access_node` in `temporal_nodes`
- preserves:
  - `node_fragment_class`
  - `value_fragment_class`
  - `required_capability`
  - `required_caps`
  - `axis` / `temporal_axis`
  - `coordinate_refs`
  - `as_of_ref`
  - `valid_time_ref`
  - `transaction_time_ref`
  - `evidence_policy`
- serializes temporal type constructors such as `History[String]`
- derives temporal requirements from SemanticIR `escape_boundaries` and temporal
  nodes

Added executable proof:

```text
igniter-lang/experiments/temporal_assembler_boundary/temporal_assembler_boundary.rb
```

The proof consumes temporal SemanticIR goldens from:

```text
igniter-lang/experiments/temporal_semanticir_access_node/golden/
```

and writes assembled `.igapp/` artifacts under:

```text
igniter-lang/experiments/temporal_assembler_boundary/out/
```

---

## Artifact Placement

Temporary Stage 3 placement:

| Artifact surface | Temporal placement |
| --- | --- |
| `semantic_ir_program.json` | unchanged canonical SemanticIR |
| `contracts/*.json` | non-compute `temporal_nodes` |
| `requirements.json` | capabilities, axes, coordinate refs, TBackend capability hints |
| `manifest.json` | `fragment_class: temporal` |
| `compatibility_metadata.json` | runtime execution guard, `unsupported` |

This is intentionally redundant. The contract file preserves the local node
shape for inspection, while `requirements.json` provides a compact capability
surface for future loader/spec work.

---

## Proof Output

```text
ruby igniter-lang/experiments/temporal_assembler_boundary/temporal_assembler_boundary.rb
```

Output:

```text
PASS temporal_assembler_boundary
history_valid.assembled: ok
history_valid.compiled_program_validates: ok
history_valid.manifest_fragment_temporal: ok
history_valid.compute_nodes_empty: ok
history_valid.temporal_nodes_in_contract_file: ok
history_valid.temporal_node_metadata_preserved: ok
history_valid.requirements_preserve_temporal_boundary: ok
history_valid.runtime_execution_guard: ok
bihistory_valid.assembled: ok
bihistory_valid.compiled_program_validates: ok
bihistory_valid.manifest_fragment_temporal: ok
bihistory_valid.compute_nodes_empty: ok
bihistory_valid.temporal_nodes_in_contract_file: ok
bihistory_valid.temporal_node_metadata_preserved: ok
bihistory_valid.requirements_preserve_temporal_boundary: ok
bihistory_valid.runtime_execution_guard: ok
summary: igniter-lang/experiments/temporal_assembler_boundary/out/temporal_assembler_boundary_summary.json
```

---

## Regression Proofs

```text
ruby igniter-lang/experiments/igapp_assembler_proof/igapp_assembler_proof.rb
```

PASS.

```text
ruby igniter-lang/experiments/temporal_semanticir_access_node/temporal_semanticir_access_node.rb --check-golden
```

PASS.

```text
ruby igniter-lang/experiments/production_compiler_cli/production_compiler_cli_proof.rb
ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb
ruby igniter-lang/experiments/stage2_close_candidate/stage2_close_candidate.rb
```

PASS.

---

## Residual Questions

[Q] Should `temporal_nodes` become a formal `ContractArtifact` section, or
should future manifests split these into a top-level `requirements/` or
`capabilities/` directory?

[Q] Should `requirements.required_tbackend_caps` remain capability hints, or be
replaced by a formal `TBackendAdapterDescriptor` requirement reference?

[Q] Should future RuntimeMachine load reject temporal artifacts unless a
temporal adapter/hook is supplied, or allow load and reject only evaluation?

[Q] Should `manifest.fragment_class: temporal` become canonical in PROP-028 or
remain a Stage 3 artifact convention until RuntimeMachine temporal execution is
implemented?

---

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/temporal-assembler-boundary-v0
Status: done
Neighbors: Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- Store temporal_input_node / temporal_access_node as non-compute
  contracts/*.json temporal_nodes.
- Duplicate temporal capabilities, axes, and coordinate refs into
  requirements.json for loader/spec pressure.
- Mark temporal runtime execution unsupported in compatibility_metadata.json.
- Do not add RuntimeMachine temporal execution, cache, Ledger binding, or
  production TBackend adapter behavior.

[R] Recommendations:
- Compiler/Grammar Expert should decide whether temporal_nodes and
  manifest.fragment_class=temporal are canonical PROP-028 artifact vocabulary.
- Bridge Agent should wait for a formal TBackend requirement reference before
  mapping this into Ledger package work.

[S] Signals:
- History and BiHistory temporal SemanticIR now assemble into .igapp/.
- CompiledProgram.load_igapp(...).validate! accepts the assembled temporal
  artifact shape.
- Runtime execution is guarded as unsupported instead of silently implied.

[T] Tests / Proofs:
- ruby igniter-lang/experiments/temporal_assembler_boundary/temporal_assembler_boundary.rb -> PASS
- ruby igniter-lang/experiments/igapp_assembler_proof/igapp_assembler_proof.rb -> PASS
- ruby igniter-lang/experiments/temporal_semanticir_access_node/temporal_semanticir_access_node.rb --check-golden -> PASS
- ruby igniter-lang/experiments/production_compiler_cli/production_compiler_cli_proof.rb -> PASS
- ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb -> PASS
- ruby igniter-lang/experiments/stage2_close_candidate/stage2_close_candidate.rb -> PASS

[Files] Changed:
- igniter-lang/lib/igniter_lang/assembler.rb
- igniter-lang/experiments/temporal_assembler_boundary/temporal_assembler_boundary.rb
- igniter-lang/experiments/temporal_assembler_boundary/out/
- igniter-lang/docs/tracks/temporal-assembler-boundary-v0.md

[Q] Open Questions:
- Is temporal_nodes the durable contract artifact section, or a temporary
  Stage 3 pressure shape?
- Should RuntimeMachine load or evaluate own the future unsupported-temporal
  diagnostic?

[X] Rejected:
- RuntimeMachine temporal execution.
- Production temporal cache.
- Ledger/TBackend adapter binding.

[Next] Proposed next slice:
- temporal-runtime-load-guard-v0: formalize whether temporal .igapp load is
  accepted with evaluation blocked, or load itself requires a temporal adapter.
```
