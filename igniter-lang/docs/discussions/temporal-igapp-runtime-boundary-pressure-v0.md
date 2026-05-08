# Discussion: Temporal `.igapp/` Runtime Boundary Pressure

Card: S3-R4-X1-S
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: discussion
Initiator: architect-supervisor
Borrowed lens: applied-pressure-agent
  (Note: card assigned `runtime-systems-reviewer`, which is not in the allowed
  lens list. Using `applied-pressure-agent` as the closest available lens:
  production risk, implementation pressure, proof-vs-production gap detection.)
Track: temporal-igapp-runtime-boundary-pressure-v0
Date: 2026-05-08
Status: complete — routed

Trigger: after S3-R4 C1 (temporal-assembler-boundary-v0), C2
(prop-022a-temporal-manifest-errata-v0), C3
(temporal-requirements-from-escape-boundaries-v0) landed.

---

## Question

Did S3-R4 make temporal `.igapp/` artifacts structurally safe enough for
proof-local RuntimeMachine loading, or are manifest/requirements/cache
metadata still under-specified?

---

## Context

**C1 (S3-R4-C1-P)**: Fixed the crash in `Assembler#contract_file` for temporal
nodes. `temporal_input_node` and `temporal_access_node` now survive assembly
into `contracts/<Name>.json.temporal_nodes`. Manifest emits
`fragment_class: "temporal"` for all-temporal contracts.
`compatibility_metadata.runtime_execution.status = "unsupported"`.
All Stage 1/2 regressions PASS.

**C2 (S3-R4-C2-P)**: Docs-only PROP-022A temporal manifest errata. Specified
the dual-index approach: ContractIR is canonical semantic source;
`manifest.contract_index` is the load-time dispatch projection (validated
against ContractIR). Defines `fragment_summary`, per-contract `contract_index`
with `temporal.axes`, `temporal.required_capabilities`, and
`temporal.cache_key_schema_hint`. Six loader refusal rules L-T1 through L-T6.
No assembler code changed in this slice.

**C3 (S3-R4-C3-P)**: `Assembler#requirements_for` now derived from SemanticIR
`escape_boundaries`. CORE, History, BiHistory, and Stream all get distinct
requirements. PASS.

**C5 (S3-R4-C5-P)** (also landed, relevant context): Proof-local
RuntimeMachine memoization fixture. Reads from current assembled artifact shape
(`contracts/*.json.temporal_nodes` + `requirements.json`). Identifies that
`manifest.contract_index` with `cache_key_schema_hint` is STILL MISSING before
production. Proof PASS by reading deeper artifact fields, not from a manifest
index.

**Inspected artifacts:**
- `experiments/temporal_assembler_boundary/out/history_valid.igapp/manifest.json`
- `experiments/temporal_assembler_boundary/out/history_valid.igapp/requirements.json`
- `experiments/temporal_assembler_boundary/out/history_valid.igapp/contracts/history_axes_test.json`
- `experiments/temporal_assembler_boundary/out/history_valid.igapp/compatibility_metadata.json`

---

## [Agree]

**The assembly crash is closed. This was the hardest blocker.**

C1 fixed the `KeyError` on `"expr"` and `"name"` in `contract_file` for
temporal nodes. `temporal_nodes` is a real artifact section with preserved
`node_fragment_class`, `value_fragment_class`, `required_capability`,
`coordinate_refs`, and `axis` fields. History and BiHistory both assemble and
pass golden checks. Stage 1 and Stage 2 regressions are clean. This is a solid
fix.

**Requirements derivation is correct and discriminating.**

C3 removed the hardcoded `requirements_for`. The new implementation correctly
distinguishes: CORE (no temporal caps), History (`requires_as_of`, `read_as_of:
true`), BiHistory (`requires_valid_time`, `requires_transaction_time`,
`replay_enabled`), Stream (`has_window`, no temporal TBackend caps). These are
the right semantics and the proof demonstrates clean separation.

**The dual-index specification (C2) is architecturally sound.**

The ContractIR-canonical / manifest.contract_index-dispatch split is the right
design. It avoids forcing RuntimeMachine to deep-parse every contract to decide
fragment class, while keeping ContractIR as the authoritative record. The six
loader refusal rules and `cache_key_schema_hint` are well-structured for the
eventual production load gate.

**The `unsupported` runtime execution guard is correct in intent.**

`compatibility_metadata.runtime_execution.status = "unsupported"` makes it
explicit that the assembled artifact is a structural proof, not an execution
target. This prevents silent temporal execution that would fail without an
adapter. The intent is right.

---

## [Challenge]

### Challenge 1: C2 specified `contract_index` — C1 did not implement it

The actual assembled manifest (`history_valid.igapp/manifest.json`) contains:

```json
{
  "kind": "igapp_manifest",
  "fragment_class": "temporal",
  "contracts": ["HistoryAxesTest"],
  "contract_refs": { "HistoryAxesTest": "contract/HistoryAxesTest/..." }
}
```

It does **not** contain `fragment_summary` or `contract_index`. The PROP-022A
errata (C2) specified these as the correct Stage 3 format. The C1 assembler
still emits the Stage 1-era manifest shape.

C2 explicitly disclaimed: "No assembler code is changed in this slice."

The result is that C1 and C2 landed in parallel but did not converge. The
specification exists; the implementation does not emit it. Any load path that
follows the PROP-022A dual-index spec will find an absent `contract_index` and
cannot dispatch correctly.

**Current state of the dual-index:**

| PROP-022A spec field | Present in artifact? |
|----------------------|----------------------|
| `manifest.fragment_summary` | No |
| `manifest.contract_index[]` | No |
| `manifest.contract_index[].fragment_class` | No |
| `manifest.contract_index[].temporal.axes` | No |
| `manifest.contract_index[].temporal.required_capabilities` | No |
| `manifest.contract_index[].temporal.cache_key_schema_hint` | No |

### Challenge 2: The C5 memoization proof works around the missing `contract_index`

C5 (`runtime_cache_proof_local_memoization`) reads:

```ruby
manifest = read_json(igapp_dir / "manifest.json")
requirements = read_json(igapp_dir / "requirements.json")
access_node = contract.fetch("temporal_nodes").find { |node| ... }
```

It reads `contract.temporal_nodes[]` directly from the individual contract
file to derive `coordinate_refs`. It does NOT read from
`manifest.contract_index`. This means the proof validates the cache key logic
correctly for proof-local use, but by reading deeper — not through the load
dispatch path C2 specified.

C5 itself names this explicitly: `"manifest_or_spec_fields_needed_before_
production_runtime_cache"`. The proof works despite the absent manifest
index, not through it.

This creates a confirmed split: proof-local load is functional (deep reads);
production-shaped load (manifest dispatch) is not yet possible.

### Challenge 3: Loader refusal rules L-T1..L-T6 cannot be enforced without `contract_index`

C2 defined six loader rules, for example:

```text
L-T1: manifest.fragment_summary.max_fragment_class = temporal
      → loader must verify temporal access capability before returning loaded
L-T2: contract_index[N].fragment_class = temporal
      → loader must verify backend can serve history_read | bihistory_read
```

Without `manifest.contract_index` present in the assembled artifact, these
rules cannot be evaluated. A loader that receives the current C1-assembled
artifact and tries to apply L-T1 through L-T6 will fail to find the fields.

The refusal rules are spec without enforcement surface. They are not yet
testable from the artifact.

### Challenge 4: The `unsupported` guard semantics are ambiguous

`compatibility_metadata.runtime_execution.status = "unsupported"` guards
against temporal runtime execution. But C1's open question (explicitly in the
track) remains: does this prevent load, or only evaluation?

- If load refuses: the artifact cannot be loaded at all by RuntimeMachine
  until a temporal adapter is supplied. This is safe but may block non-temporal
  evaluation tests that happen to assemble a temporal contract.
- If evaluate refuses: the artifact loads, but temporal evaluation calls are
  rejected at runtime. This is more flexible but puts enforcement later in the
  stack.

Neither behavior is specified in the artifact. The `status: "unsupported"` tag
is a note field, not a machine-readable policy. A loader that does not check
`compatibility_metadata` at load time will ignore it entirely.

---

## [Missing]

### M1. No assembler implementation of `manifest.contract_index`

The PROP-022A errata is approved and correct. The assembler does not emit it.
There is no proof that the assembled artifact can be used through the dual-index
load path. This is a specification-implementation gap.

Next track: `temporal-assembler-manifest-contract-index-v0`. Acceptance:
assembled manifest contains `fragment_summary` and `contract_index` as
specified in PROP-022A, C5 memoization proof loads through `contract_index`
rather than deep contract file reads.

### M2. Loader refusal rule proof is absent

L-T1 through L-T6 are specified but there is no proof that a loader refusing
on a malformed or missing `contract_index` works correctly. No negative case
for "manifest claims temporal but contract_index is absent" exists.

This is lower priority than M1 but needed before any "safe load" claim.

### M3. `unsupported` guard load/evaluate policy is unresolved

C1's open question: should RuntimeMachine load refuse temporal artifacts
without an adapter, or allow load and refuse evaluation? This needs a
specification decision that maps to a field in `compatibility_metadata` (e.g.,
`guard_at: "load" | "evaluate"`). Currently the guard is a note, not a policy.

### M4. Assembler self-label is stale

`manifest.assembler = "igapp-assembler-proof-stage1-v0"` — this is the Stage 1
proof label. After C1, the assembler handles temporal nodes, which is a
Stage 3 capability. This label is technically misleading: an artifact that
contains `temporal_nodes` was not assembled by the Stage 1 assembler.

Minor hygiene, but if an external tool or validator reads the assembler label
to decide what format to expect, it will be wrong.

---

## [Sharper Question]

The question "structurally safe enough for proof-local RuntimeMachine loading"
has two interpretations:

> **Interpretation A** (deep-read path):
> Can a proof-local RuntimeMachine read `contracts/*.json.temporal_nodes` and
> `requirements.json` to determine temporal axes and capabilities for safe
> cache keying?
>
> **Answer: Yes.** C1 + C3 + C5 prove this. The artifact has the necessary
> metadata. C5's proof demonstrates it. This interpretation is satisfied.

> **Interpretation B** (manifest dispatch path):
> Can a RuntimeMachine load `.igapp/` by reading `manifest.contract_index` for
> fragment/cache dispatch, then validate against ContractIR per PROP-022A?
>
> **Answer: No.** `contract_index` is not in the assembled artifact.
> L-T1..L-T6 cannot be evaluated. The `unsupported` guard is not machine-
> enforceable from the manifest alone. This interpretation is NOT satisfied.

The sharper question is therefore:

> **Which interpretation does "proof-local RuntimeMachine loading" require?**
>
> If A: S3-R4 is sufficient. C5 proves it.
> If B: one more assembler slice is needed to emit `contract_index`.
>
> The decision determines whether C5 closes the proof-local gate or merely
> validates the deeper-read workaround.

---

## [Route]

| Route | What | Owner | Priority |
|-------|------|-------|----------|
| `track` | `temporal-assembler-manifest-contract-index-v0`: implement `fragment_summary` and `contract_index` in assembler as specified by PROP-022A errata; update C5 proof to load through `contract_index` | Research Agent | **required for Interpretation B** |
| `track` | `temporal-runtime-load-guard-v0` (already proposed in C1 handoff): specify whether RuntimeMachine load refuses or allows temporal artifacts without adapter; map to machine-readable field | Research Agent | prerequisite for safe production load |
| `backlog` | Assembler `assembler` label update: emit `igapp-assembler-stage3-temporal-v0` or equivalent for temporal artifacts | Research Agent | minor hygiene |
| `backlog` | L-T1..L-T6 negative load case proof: loader refuses on missing/malformed `contract_index` | Research Agent | after `contract_index` implementation |

---

## Path Verdict (updated from S3-R3-X1)

```text
Stage                          S3-R3-X1 status   S3-R4 status
───────────────────────────────────────────────────────────────────
Classifier                     ✅ PASS            ✅ unchanged PASS
TypeChecker                    ✅ PASS            ✅ unchanged PASS
SemanticIREmitter#emit_typed   ✅ PASS            ✅ unchanged PASS
Cache key contract design       ✅ PASS            ✅ unchanged PASS
───────────────────────────────────────────────────────────────────
Assembler#contract_file crash   ❌ blocker         ✅ FIXED (C1)
requirements_for hardcoded      ❌ wrong           ✅ FIXED (C3)
manifest fragment_class "mixed" ❌ collapse        ✅ FIXED for all-temporal (C1)
manifest.contract_index         ❌ absent spec     ⚠️ SPECIFIED (C2) / not emitted
cache_key_schema_hint in bundle ❌ no field        ⚠️ SPECIFIED (C2) / not emitted
Loader rules L-T1..L-T6        ❌ no surface      ⚠️ SPECIFIED (C2) / not enforceable
RuntimeMachine load guard       ❌ unspecified     ⚠️ guard present / semantics unclear
───────────────────────────────────────────────────────────────────
Proof-local load (deep-read)    ✗ crash            ✅ PASS (C5 proves it)
Manifest-dispatch load          ✗ broken           ⚠️ spec exists / artifact incomplete
```

**Summary:** S3-R4 is a substantial advance. The assembly crash is gone.
Requirements are correct. Proof-local deep-read loading works and is proven by
C5. The remaining gap is one assembler slice: emit `manifest.contract_index`
as specified in C2. Without it, the PROP-022A dual-index dispatch path is
specified but not exercisable from the artifact.

---

## Summary for Architect Supervisor intake

C1, C2, C3 each delivered exactly what they claimed. The combination is solid
on the language-to-SemanticIR-to-assembly side. The proof-local deep-read
loading path (Interpretation A) is closed by C5.

The one open gap is `manifest.contract_index`: C2 specified it, C1 did not
implement it. This is the natural next assembler slice before any load path
that follows the PROP-022A dispatch contract.

Recommended gate before claiming "temporal `.igapp/` is safe for proof-local
RuntimeMachine loading" in the broad sense:

1. **`temporal-assembler-manifest-contract-index-v0`** — one assembler slice
   to emit `fragment_summary` and `contract_index` per PROP-022A spec.
2. **`temporal-runtime-load-guard-v0`** — resolve whether
   `compatibility_metadata.runtime_execution.status: "unsupported"` is a load
   refusal or evaluate refusal, and map it to a machine-readable policy field.

Neither requires new language semantics. Both are assembler and runtime-contract
implementation work.
