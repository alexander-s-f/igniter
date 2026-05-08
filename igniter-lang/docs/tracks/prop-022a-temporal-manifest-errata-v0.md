# Track: PROP-022A Temporal Manifest Errata v0

Card: S3-R4-C2-P
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Track: `igniter-lang/prop-022a-temporal-manifest-errata-v0`
Status: done
Date: 2026-05-08

---

## Goal

Specify the Stage 3 errata to PROP-022A for temporal `.igapp/` manifests after
the S3-R3-X1 pressure review found that TEMPORAL survives through SemanticIR but
not through the assembler/load manifest boundary.

---

## Inputs Read

- `docs/proposals/accepted/PROP-022A-igapp-assembler-contract-v0.md`
- `docs/proposals/PROP-028-temporal-fragment-class-v0.md`
- `docs/tracks/temporal-semanticir-access-node-v0.md`
- `docs/tracks/runtime-temporal-cache-contract-v0.md`
- `docs/discussions/temporal-manifest-and-cache-boundary-pressure-v0.md`
- current `.igapp/manifest.json` and `requirements.json` examples from
  `experiments/igapp_assembler_proof/out/add.igapp/`
- temporal SemanticIR example from
  `experiments/temporal_semanticir_access_node/golden/history_valid.semantic_ir.json`

---

## Decision

[D] Use an explicit dual-index:

```text
ContractIR       = canonical semantic source
manifest index   = authoritative load-time dispatch projection
loader invariant = manifest index agrees with ContractIR, or load refuses
```

This means RuntimeMachine may read `manifest.contract_index` first for fragment
and cache-schema dispatch, but it must validate against the contract file before
trusting the bundle.

[D] Do not use the current manifest-level `fragment_class: "mixed"` as a
TEMPORAL source. It is too coarse and collapses `temporal` into generic
non-core.

[D] `requirements.json` is a capability negotiation summary, not the semantic
source for axes. It may summarize required temporal capabilities, but
per-contract temporal axes and coordinate refs belong in `manifest.contract_index`
and must agree with ContractIR.

---

## Proposal Artifact

Created:

```text
igniter-lang/docs/proposals/PROP-022A-temporal-manifest-errata-v0.md
```

It defines:

- `fragment_summary`
- `contract_index`
- minimal TEMPORAL fields:
  - per-contract `fragment_class`
  - `axes`
  - `coordinates`
  - `required_capabilities`
  - `cache_key_schema_hint`
- relationships between `manifest.json`, `requirements.json`, and
  `contracts/<Name>.json`
- loader refusal rules `L-T1` through `L-T6`
- before/after manifest examples

---

## Before / After

Before:

```json
{
  "kind": "igapp_manifest",
  "fragment_class": "mixed",
  "contracts": ["HistoryAxesTest"]
}
```

After:

```json
{
  "kind": "igapp_manifest",
  "fragment_summary": {
    "fragment_classes": ["temporal"],
    "max_fragment_class": "temporal"
  },
  "contracts": ["HistoryAxesTest"],
  "contract_index": {
    "HistoryAxesTest": {
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

The cache-key schema hint is declarative. It does not enable memoization.

---

## C1/C3 Alignment Recommendation

[Next] C1 assembler implementation should:

- fix assembly of `temporal_input_node` / `temporal_access_node`;
- preserve temporal nodes in `contracts/<Name>.json`;
- emit `manifest.fragment_summary` and `manifest.contract_index`;
- derive temporal `requirements.json` from `escape_boundaries` and node
  `required_caps`;
- refuse mismatches between manifest temporal index and ContractIR.

[Next] C3 runtime cache implementation should:

- read `manifest.contract_index` as the first load-time dispatch surface;
- validate against ContractIR before trusting the index;
- treat missing/inconsistent temporal cache hints as load refusals;
- never fallback from TEMPORAL to CORE cache keys;
- keep memoization disabled until a separate runtime implementation track
  authorizes it.

---

## Not Authorized

[X] No RuntimeMachine memoization is authorized.

[X] No Ledger adapter or production TBackend binding is authorized.

[X] No parser syntax is changed.

[X] No assembler code is changed in this slice.

---

## Verification

Docs-only slice. No code proof was required.

JSON examples in the proposal are intentionally minimal manifest fragments, not
full assembled `.igapp/` files.

---

## Handoff

```text
Card: S3-R4-C2-P
[Igniter-Lang Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: igniter-lang/prop-022a-temporal-manifest-errata-v0
Status: done

[D] Decisions:
- Chose explicit dual-index: ContractIR is canonical semantic source;
  manifest.contract_index is load-time dispatch source validated against
  ContractIR.
- Current `fragment_class: "mixed"` cannot be authoritative for TEMPORAL.
- requirements.json is package capability summary, not per-contract temporal
  authority.

[S] Shipped / Signals:
- Added PROP-022A temporal manifest errata proposal.
- Added before/after manifest examples.
- Defined minimal temporal manifest fields and loader refusal rules.
- Gave C1/C3 implementation alignment recommendation.

[T] Tests / Proofs:
- Docs-only; no runtime/proof code changed.

[R] Risks / Recommendations:
- Existing assembler still needs an implementation slice before TEMPORAL
  `.igapp/` bundles can load.
- Runtime cache work must not begin from `fragment_class: "mixed"` or fallback
  TEMPORAL contracts to CORE cache keys.

[Next] Suggested next slice:
- temporal-assembler-boundary-v0: implement assembler handling for temporal
  nodes and emit the manifest/requirements fields specified here.
```

## Files Changed

```text
igniter-lang/docs/proposals/PROP-022A-temporal-manifest-errata-v0.md
igniter-lang/docs/tracks/prop-022a-temporal-manifest-errata-v0.md
```
