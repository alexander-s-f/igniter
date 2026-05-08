# Track: Temporal Assembler Manifest Contract Index v0

Card: S3-R5-C1-P
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `igniter-lang/temporal-assembler-manifest-contract-index-v0`
Status: done
Date: 2026-05-08

---

## Goal

Emit `manifest.fragment_summary` and `manifest.contract_index` for temporal
`.igapp/` artifacts according to PROP-022A temporal manifest errata.

Affected neighbor roles:

- Compiler/Grammar Expert
- Bridge Agent

---

## Current Horizon

Temporal SemanticIR now assembles into `.igapp/` without claiming runtime
execution. The remaining issue was that RuntimeMachine/cache-capability
dispatch still had to inspect contract files deeply to discover fragment and
temporal coordinates.

This slice adds the manifest load-time projection:

```text
ContractIR / contracts/*.json = canonical semantic record
manifest.contract_index      = load-time dispatch projection
loader invariant             = index agrees with contract file
```

---

## Decisions

[D] `manifest.fragment_summary` is emitted for all assembled artifacts:

```json
{
  "fragment_classes": ["temporal"],
  "max_fragment_class": "temporal",
  "precedence_high_to_low": ["oof", "temporal", "stream", "escape", "core"]
}
```

[D] `manifest.contract_index` is emitted per contract.

[D] TEMPORAL entries include:

- `contract_ref`
- `contract_path`
- `fragment_class`
- `temporal.axes`
- `temporal.required_capabilities`
- `temporal.coordinates`
- `temporal.cache_key_schema_hint`

[D] Runtime cache proof now prefers `manifest.contract_index` for temporal key
metadata. Contract files and requirements remain supporting validation sources.

[D] No production RuntimeMachine execution, production cache, or Ledger binding
is enabled.

---

## Before / After Manifest Example

Before:

```json
{
  "kind": "igapp_manifest",
  "fragment_class": "temporal",
  "contracts": ["HistoryAxesTest"],
  "contract_refs": {
    "HistoryAxesTest": "contract/HistoryAxesTest/sha256:7e26cc28736928117931083d"
  }
}
```

After:

```json
{
  "kind": "igapp_manifest",
  "fragment_class": "temporal",
  "fragment_summary": {
    "fragment_classes": ["temporal"],
    "max_fragment_class": "temporal",
    "precedence_high_to_low": ["oof", "temporal", "stream", "escape", "core"]
  },
  "contracts": ["HistoryAxesTest"],
  "contract_index": {
    "HistoryAxesTest": {
      "contract_ref": "contract/HistoryAxesTest/sha256:7e26cc28736928117931083d",
      "contract_path": "contracts/history_axes_test.json",
      "fragment_class": "temporal",
      "temporal": {
        "axes": ["valid_time"],
        "required_capabilities": ["history_read"],
        "coordinates": [
          {
            "name": "as_of",
            "axis": "valid_time",
            "source_ref": "input:as_of",
            "type": "DateTime"
          }
        ],
        "cache_key_schema_hint": {
          "schema": "runtime-cache-key-v1",
          "fragment": "TEMPORAL",
          "axis": "valid_time",
          "coordinate_names": ["as_of"]
        }
      }
    }
  }
}
```

Bitemporal output uses:

```json
{
  "axes": ["valid_time", "transaction_time"],
  "cache_key_schema_hint": {
    "schema": "runtime-cache-key-v1",
    "fragment": "TEMPORAL",
    "axis": "bitemporal",
    "coordinate_names": ["valid_time", "transaction_time"]
  }
}
```

---

## Proof Updates

Updated:

```text
igniter-lang/experiments/temporal_assembler_boundary/temporal_assembler_boundary.rb
```

New checks:

```text
history_valid.manifest_fragment_summary
history_valid.manifest_contract_index
history_valid.missing_contract_index_detected
history_valid.core_cache_hint_mismatch_detected
bihistory_valid.manifest_fragment_summary
bihistory_valid.manifest_contract_index
bihistory_valid.missing_contract_index_detected
bihistory_valid.core_cache_hint_mismatch_detected
```

The proof validates:

- manifest index exists for temporal contracts
- indexed fragment matches contract file fragment
- indexed temporal axes match temporal access coordinates
- indexed capabilities match contract temporal capabilities
- TEMPORAL cache hint uses `runtime-cache-key-v1` and fragment `TEMPORAL`
- missing `contract_index` is detected as `L-T1`
- CORE cache hint on a TEMPORAL contract is detected as `L-T5`

Updated:

```text
igniter-lang/experiments/runtime_cache_proof_local_memoization/runtime_cache_proof_local_memoization.rb
```

The cache proof now reads:

```text
manifest.contract_index[].temporal.cache_key_schema_hint
manifest.contract_index[].temporal.coordinates
manifest.contract_index[].temporal.required_capabilities
```

before using contract files or requirements as supporting metadata.

---

## Proof Output

```text
ruby igniter-lang/experiments/temporal_assembler_boundary/temporal_assembler_boundary.rb
```

PASS, including manifest index and negative mismatch detection checks.

```text
ruby igniter-lang/experiments/runtime_cache_proof_local_memoization/runtime_cache_proof_local_memoization.rb
```

PASS, with `metadata_sources.preferred = manifest.contract_index`.

---

## Non-Goals Preserved

[X] No production RuntimeMachine execution.

[X] No production RuntimeMachine cache.

[X] No durable cache adapter.

[X] No Ledger binding.

---

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/temporal-assembler-manifest-contract-index-v0
Status: done
Neighbors: Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- Added manifest.fragment_summary.
- Added per-contract manifest.contract_index.
- TEMPORAL contract_index entries include axes, required capabilities,
  coordinates, and cache_key_schema_hint.
- Runtime cache proof now prefers manifest.contract_index over deep contract
  reads where possible.

[S] Signals:
- Temporal assembler proof validates index-vs-contract agreement.
- Missing contract_index and CORE cache hint mismatch are detected.
- Cache proof consumes manifest index as the primary metadata source.

[T] Tests / Proofs:
- ruby igniter-lang/experiments/temporal_assembler_boundary/temporal_assembler_boundary.rb -> PASS
- ruby igniter-lang/experiments/runtime_cache_proof_local_memoization/runtime_cache_proof_local_memoization.rb -> PASS

[Files] Changed:
- igniter-lang/lib/igniter_lang/assembler.rb
- igniter-lang/experiments/temporal_assembler_boundary/temporal_assembler_boundary.rb
- igniter-lang/experiments/temporal_assembler_boundary/out/
- igniter-lang/experiments/runtime_cache_proof_local_memoization/runtime_cache_proof_local_memoization.rb
- igniter-lang/experiments/runtime_cache_proof_local_memoization/runtime_cache_proof_local_memoization_summary.json
- igniter-lang/experiments/runtime_cache_proof_local_memoization/assembled/
- igniter-lang/docs/tracks/temporal-assembler-manifest-contract-index-v0.md

[Q] Open Questions:
- Should manifest.contract_index validation move into CompiledProgram.load_igapp
  next, or remain proof-local until runtime load-guard work?

[X] Rejected:
- Production runtime execution.
- Production memoization/cache enablement.
- Ledger/TBackend binding.

[Next] Proposed next slice:
- temporal-runtime-load-guard-v0: enforce manifest.contract_index validation at
  load boundary and decide load-vs-evaluate refusal behavior for TEMPORAL.
```
