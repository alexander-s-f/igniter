# Fragment Precedence Compatibility Adapter Proof v0

Card: LANG-R144-P1  
Agent: `[Igniter-Lang Research Agent]`  
Role: `research-agent`  
Route: UPDATE  
Depends on: LANG-R143-D1, LANG-R142-P1  
Track: `fragment-precedence-compatibility-adapter-proof-v0`  
Status: done / PASS  
Date: 2026-05-22

---

## Role And Neighbor Awareness

Assigned track: prove the R143 two-layer declaration-presence plus
selected-fragment compatibility adapter against current classifier goldens.

Affected neighbor roles:

- `[Igniter-Lang Compiler/Grammar Expert]` - owns final classifier fragment
  semantics and any future adapter implementation authority.
- `[Igniter-Lang Bridge Agent]` - must review before public/report/loader,
  CompatibilityReport, `.igapp`, runtime, production, or Spark surfaces open.

---

## Current Horizon

```text
R142 held live fragment precedence migration because a single shadow order would
drift stream-vs-escape and epistemic-vs-escape behavior.
R143 resolves this with two layers: declaration presence and selected fragment.
R144 proves the adapter preserves all selected fragment_class goldens exactly.
Live classifier dispatch remains held.
```

---

## Read Set

- `docs/tracks/fragment-precedence-resolution-design-v0.md`
- `docs/tracks/fragment-precedence-parity-proof-v0.md`
- `experiments/fragment_precedence_parity_proof/out/fragment_precedence_parity_matrix.json`
- current classifier/classified proof goldens under:
  - `experiments/classifier_pass_proof/golden/*.classified.json`
  - `experiments/contract_modifiers_proof/golden/*.classified.json`
  - `experiments/assumptions_proof/golden/*.classified.json`

---

## Proof Artifacts

Adapter matrix:

```text
igniter-lang/experiments/fragment_precedence_compatibility_adapter_proof/out/fragment_precedence_compatibility_adapter_matrix.json
```

Summary:

```text
igniter-lang/experiments/fragment_precedence_compatibility_adapter_proof/out/fragment_precedence_compatibility_adapter_summary.json
```

Digest:

```text
65e876f5ae23ce761c16b704
```

Source R142 matrix digest:

```text
81d9f687b9f59afb362e1ffc
```

---

## Adapter Model

Layer 1 records declaration fragment presence:

```text
core
escape
stream
epistemic
temporal
oof
```

Layer 2 selects the current classifier-compatible contract fragment:

```text
if OOF present:
  selected = oof
elsif temporal present:
  selected = temporal
elsif escape present:
  selected = escape
elsif stream present:
  selected = escape
elsif epistemic present:
  selected = epistemic
else:
  selected = core
```

The adapter intentionally keeps `held_live_dispatch: true`. This is a proof
model, not a classifier implementation.

---

## Required Case Matrix

| Case | Presence recorded | Adapter selected | Current classifier | Result |
| --- | --- | --- | --- | --- |
| Stream contracts | `stream`, `escape` | `escape` | `escape` | PASS |
| Epistemic + escape | `epistemic`, `escape` | `escape` | `escape` | PASS |
| Epistemic-only | `epistemic` | `epistemic` | `epistemic` | PASS |
| Temporal + escape | `temporal`, `escape` | `temporal` | `temporal` | PASS |
| OOF | `oof` | `oof` | `oof` | PASS |
| OLAP/progression | guarded non-fragment | none | none observed | PASS |

OOF policy remains:

```text
status-primary
blocked
non-loadable
non-capability
```

---

## Current Classifier Parity

Observed classified contracts:

```text
observed_contract_count: 23
current_classifier_parity_mismatches: []
```

Selected fragment counts preserved:

| Fragment | Count |
| --- | ---: |
| `core` | 5 |
| `escape` | 7 |
| `temporal` | 3 |
| `oof` | 7 |
| `epistemic` | 1 |

Presence recorded by adapter:

| Presence | Count |
| --- | ---: |
| `core` | 23 |
| `escape` | 11 |
| `stream` | 4 |
| `epistemic` | 3 |
| `temporal` | 3 |
| `oof` | 7 |

The key compatibility result is that `stream` can be recorded as presence
without changing selected fragment from `escape`, and mixed `epistemic` +
`escape` can record epistemic presence without changing selected fragment from
`escape`.

---

## PASS Matrix

| Check | Result |
| --- | --- |
| Stream contracts select `escape` while recording stream presence | PASS |
| Epistemic + escape selects `escape` while recording epistemic presence | PASS |
| Epistemic-only selects `epistemic` | PASS |
| Temporal + escape selects `temporal` | PASS |
| OOF remains status-primary, blocked, non-loadable, non-capability | PASS |
| `olap`/`progression` remain guarded non-fragments | PASS |
| All observed classifier goldens keep current `fragment_class` | PASS |
| Adapter output is proof-local and not live classifier dispatch | PASS |

---

## Verification

Adapter proof command:

```bash
ruby -rjson -rdigest -e 'def c(v); case v; when Hash; v.keys.sort.to_h { |k| [k, c(v[k])] }; when Array; v.map { |x| c(x) }; else v; end; end; matrix=JSON.parse(File.read(ARGV[0])); summary=JSON.parse(File.read(ARGV[1])); digest=Digest::SHA256.hexdigest(JSON.generate(c(matrix)))[0,24]; rows=matrix.dig("current_classifier_parity","rows"); checks=[]; checks << ["kind", matrix["kind"]=="fragment_precedence_compatibility_adapter_matrix"]; checks << ["digest", summary["adapter_matrix_digest"]==digest]; checks << ["source_r142", matrix.dig("source_parity_matrix","digest")=="81d9f687b9f59afb362e1ffc"]; checks << ["held_live_dispatch", matrix["held_live_dispatch"]==true && summary["held_live_dispatch"]==true]; checks << ["parity_rows", rows.all? { |r| r["current_fragment_class"]==r["adapter_selected_fragment"] && r["parity"]=="PASS" } && matrix.dig("current_classifier_parity","mismatches").empty?]; checks << ["stream_presence_escape_selected", rows.select { |r| r["presence"].include?("stream") && !r["presence"].include?("oof") }.all? { |r| r["adapter_selected_fragment"]=="escape" }]; checks << ["epistemic_escape_selected", rows.select { |r| r["presence"].include?("epistemic") && r["presence"].include?("escape") && !r["presence"].include?("oof") }.all? { |r| r["adapter_selected_fragment"]=="escape" }]; checks << ["epistemic_only_selected", rows.select { |r| r["presence"].include?("epistemic") && !r["presence"].include?("escape") && !r["presence"].include?("oof") }.all? { |r| r["adapter_selected_fragment"]=="epistemic" }]; checks << ["temporal_escape_selected", rows.select { |r| r["presence"].include?("temporal") && r["presence"].include?("escape") && !r["presence"].include?("oof") }.all? { |r| r["adapter_selected_fragment"]=="temporal" }]; checks << ["oof_selected", rows.select { |r| r["presence"].include?("oof") }.all? { |r| r["adapter_selected_fragment"]=="oof" }]; checks << ["closed", matrix.fetch("proof_only_non_authority").values.all?(false) && summary.fetch("closed_surface_assertions").values.all?(false)]; failed=checks.reject { |_, ok| ok }; puts failed.empty? ? "PASS fragment_precedence_compatibility_adapter #{digest}" : "FAIL #{failed.map(&:first).join(",")}"; exit(failed.empty? ? 0 : 1)' igniter-lang/experiments/fragment_precedence_compatibility_adapter_proof/out/fragment_precedence_compatibility_adapter_matrix.json igniter-lang/experiments/fragment_precedence_compatibility_adapter_proof/out/fragment_precedence_compatibility_adapter_summary.json
```

Output:

```text
PASS fragment_precedence_compatibility_adapter 65e876f5ae23ce761c16b704
```

Regression anchors:

```text
ruby igniter-lang/experiments/classifier_pass_proof/classifier_pass_proof.rb
ruby igniter-lang/experiments/contract_modifiers_proof/contract_modifiers_proof.rb
ruby igniter-lang/experiments/fragment_precedence_parity_proof/out/fragment_precedence_parity_matrix.json # JSON parse only
```

Outputs:

```text
PASS classifier_pass_proof
PASS contract_modifiers_proof
OK fragment_precedence_parity_matrix.json
```

---

## Closed Surfaces

Still closed:

- no `lib/` edits;
- no classifier behavior change;
- no diagnostics, reports, CLI, or public result changes;
- no `.igapp`, manifest, sidecar, or golden mutation;
- no PROP-036 or PROP-038 behavior mutation;
- no compiler pipeline adapter;
- no loader/report or CompatibilityReport;
- no runtime, production, Spark, Ledger/TBackend, Gate 3, cache, signing, or
  deployment behavior.

---

## Recommendation

```text
accept adapter parity
hold live dispatch
```

R144 discharges the two R142 held parity cases at the proof-model level. The
adapter can now be cited as proof-local migration evidence for preserving
current selected `fragment_class` behavior, but implementation remains held
until a separate gate authorizes classifier/write-scope work.

Likely next route:

```text
fragment_registry_adapter_implementation_boundary_design_v0
```

---

## Changed Files

```text
igniter-lang/docs/tracks/fragment-precedence-compatibility-adapter-proof-v0.md
igniter-lang/experiments/fragment_precedence_compatibility_adapter_proof/out/fragment_precedence_compatibility_adapter_matrix.json
igniter-lang/experiments/fragment_precedence_compatibility_adapter_proof/out/fragment_precedence_compatibility_adapter_summary.json
```

---

## Handoff

[D] R144 proves the two-layer compatibility adapter: declaration presence can
record richer fragment signals while selected fragment remains current
classifier-compatible.

[S] Stream presence is recorded while selected fragment stays `escape`.
Epistemic + escape records epistemic presence while selected fragment stays
`escape`. Epistemic-only stays `epistemic`; temporal + escape stays
`temporal`; OOF stays blocked status-primary.

[T] PASS: all 23 observed classified contracts retain current selected
`fragment_class`; no mismatches; closed surfaces preserved.

[R] Accept adapter parity as proof-local migration evidence. Hold live dispatch
and classifier implementation until an explicit implementation boundary gate.

[Next] Consider an implementation-boundary design for a future classifier
adapter, still with no public/report/runtime widening.
