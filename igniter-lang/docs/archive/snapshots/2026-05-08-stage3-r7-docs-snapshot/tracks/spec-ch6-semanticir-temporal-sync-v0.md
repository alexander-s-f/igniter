# Track: Spec Ch6 SemanticIR Temporal Sync v0

Card: S3-R6-C3-P
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Track: `igniter-lang/spec-ch6-semanticir-temporal-sync-v0`
Status: done
Date: 2026-05-08

---

## Goal

Sync the most misleading stale spec chapter first: SemanticIR / Assembler.

Chapter 6 still read like a Stage 1 assembler gate note plus a pending Stage 3
TODO. That was stale after R3-R5 landed TEMPORAL SemanticIR nodes, assembler
temporal artifacts, manifest contract indexes, requirements derivation, and
runtime load guards.

---

## Updated File

```text
igniter-lang/docs/spec/ch6-semanticir.md
```

---

## Decisions

[D] Collapsed stale §6.4/§6.5 "assembler not implemented / migration gate"
language into current Stage 3 artifact rules.

[D] Added `temporal_input_node` and `temporal_access_node` to the SemanticIR
chapter as first-class TEMPORAL node shapes.

[D] Added the assembled contract artifact section:

```text
contracts/<contract>.json
  compute_nodes
  temporal_nodes
  escape_set
```

`temporal_nodes` is now documented as the canonical assembled contract artifact
section for temporal input/access nodes.

[D] Added PROP-022A manifest shape:

```text
manifest.fragment_summary
manifest.contract_index
contract_index[contract].temporal.axes
contract_index[contract].temporal.required_capabilities
contract_index[contract].temporal.coordinates
contract_index[contract].temporal.cache_key_schema_hint
```

[D] Added `requirements.json` derivation from SemanticIR `escape_boundaries`,
including distinct History and BiHistory examples.

[D] Added compatibility metadata guard policy reference:

```text
runtime_execution.status = "unsupported"
guard_policy = "load_accept_evaluate_refuse"
guard_at = "evaluate"
```

---

## Evidence References

S3-R3:

- `tracks/temporal-semanticir-access-node-v0.md`
  - proves `temporal_input_node` / `temporal_access_node` in SemanticIR
- `tracks/runtime-temporal-cache-contract-v0.md`
  - defines CORE vs TEMPORAL cache-key contract without production memoization

S3-R4:

- `tracks/temporal-assembler-boundary-v0.md`
  - proves temporal nodes assemble into contract `temporal_nodes`
- `tracks/prop-022a-temporal-manifest-errata-v0.md`
  - defines the dual-index manifest decision
- `tracks/temporal-requirements-from-escape-boundaries-v0.md`
  - proves `requirements.json` is derived from `escape_boundaries`

S3-R5:

- `tracks/temporal-assembler-manifest-contract-index-v0.md`
  - proves manifest `fragment_summary` and `contract_index`
- `tracks/temporal-runtime-load-guard-v0.md`
  - proves load accepts for inspection and evaluate refuses unsupported TEMPORAL

---

## Non-Goals

[X] No proof fixtures changed.

[X] No assembler/runtime code changed.

[X] No current-status or round-close map changed; that remains Meta Expert
Status Curator ownership.

[X] No runtime cache, Ledger binding, or production temporal executor is
authorized by this spec sync.

---

## Verification

Docs-only sync. Sanity checks:

```text
rg temporal_nodes docs/spec/ch6-semanticir.md
rg contract_index docs/spec/ch6-semanticir.md
rg guard_policy docs/spec/ch6-semanticir.md
```

All expected terms are present.

---

## Handoff

```text
Card: S3-R6-C3-P
Agent: [Igniter-Lang Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: igniter-lang/spec-ch6-semanticir-temporal-sync-v0
Status: done

[D] Decisions:
- Synced Ch6 from Stage 1 assembler-gate language to current Stage 3
  SemanticIR/.igapp TEMPORAL artifact shape.
- Added temporal_input_node, temporal_access_node, temporal_nodes,
  fragment_summary, contract_index, requirements-from-escape-boundaries, and
  compatibility guard policy.
- Preserved no-runtime-execution/no-cache/no-Ledger boundaries.

[S] Shipped / Signals:
- docs/spec/ch6-semanticir.md now names current SemanticIR, assembler manifest,
  requirements, and runtime guard surfaces.
- Evidence references link the chapter to S3-R3/R4/R5 landed tracks.

[T] Tests / Proofs:
- Docs-only; no code proof required.

[R] Risks / Recommendations:
- Other spec chapters may still lag behind R5, especially runtime and TBackend
  language around temporal execution vs load inspection.
- Keep Meta Expert ownership for current-status/round-close maps.

[Next] Suggested next slice:
- spec-runtime-temporal-load-guard-sync-v0, if the runtime chapter still claims
  TEMPORAL cannot load or implies production temporal execution/cache.
```

## Files Changed

```text
igniter-lang/docs/spec/ch6-semanticir.md
igniter-lang/docs/tracks/spec-ch6-semanticir-temporal-sync-v0.md
```
