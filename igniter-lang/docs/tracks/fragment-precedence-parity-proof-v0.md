# Fragment Precedence Parity Proof v0

Card: LANG-R142-P1  
Agent: `[Igniter-Lang Research Agent]`  
Role: `research-agent`  
Route: UPDATE  
Depends on: LANG-R141-P1, LANG-R140-P1  
Track: `fragment-precedence-parity-proof-v0`  
Status: done / HOLD  
Date: 2026-05-22

---

## Role And Neighbor Awareness

Assigned track: prove whether the shadow fragment registry precedence can be
used as migration evidence for the `fragment_registry` boundary.

Affected neighbor roles:

- `[Igniter-Lang Compiler/Grammar Expert]` - owns classifier fragment semantics,
  fragment precedence, and future pack migration rules.
- `[Igniter-Lang Bridge Agent]` - must review before public/report/loader,
  CompatibilityReport, `.igapp`, runtime, production, or Spark surfaces open.

---

## Current Horizon

```text
R140 requires fragment assignment, precedence, guarded non-fragment, and OOF
status projection parity before fragment_registry migration.
R141 proved OOF descriptor parity, but not fragment precedence.
R142 proves coverage and guard parity, then identifies two live-precedence holds.
The result is proof-local; no classifier dispatch changes are authorized.
```

---

## Read Set

- `AGENTS.md`
- `roles/README.md`
- `roles/research-agent.md`
- `docs/tracks/compiler-pack-pass-boundary-ownership-map-v0.md`
- `docs/tracks/oof-fragment-registry-parity-proof-v0.md`
- `docs/tracks/oof-fragment-registry-shadow-proof-v0.md`
- `docs/tracks/oof-fragment-registry-policy-proof-v0.md`
- `experiments/compiler_pack_pass_boundary_ownership_map/out/compiler_pack_pass_boundary_ownership_map.json`
- `experiments/oof_fragment_registry_shadow_proof/out/fragment_registry.shadow_registry.json`
- `experiments/oof_fragment_registry_policy_proof/out/oof_fragment_registry_policy_model.json`
- current classifier/classified proof goldens under:
  - `experiments/classifier_pass_proof/golden/*.classified.json`
  - `experiments/contract_modifiers_proof/golden/*.classified.json`
  - `experiments/assumptions_proof/golden/*.classified.json`

---

## Proof Artifacts

Parity matrix:

```text
igniter-lang/experiments/fragment_precedence_parity_proof/out/fragment_precedence_parity_matrix.json
```

Summary:

```text
igniter-lang/experiments/fragment_precedence_parity_proof/out/fragment_precedence_parity_summary.json
```

Digest:

```text
81d9f687b9f59afb362e1ffc
```

Source R140 ownership map digest:

```text
2342d159c833e5d0900cf4f4
```

---

## Observed Classifier Fragment Coverage

Observed contract fragment counts across selected current classifier/classified
goldens:

| Fragment | Count |
| --- | ---: |
| `core` | 5 |
| `escape` | 7 |
| `temporal` | 3 |
| `oof` | 7 |
| `epistemic` | 1 |

All observed fragment names have shadow registry rows:

```text
core epistemic escape oof temporal
missing_shadow_rows: []
```

This is coverage parity, not live dispatch authorization.

---

## Precedence Findings

| Case | Current classifier behavior | Shadow precedence candidate | Result |
| --- | --- | --- | --- |
| Core-only contracts | `core` | `core` row exists | PASS |
| OOF negatives | `oof` | `oof` highest and policy-blocked | PASS |
| Temporal + escape | contract remains `temporal` | `temporal` outranks `escape` | PASS |
| Stream ingress/fold | contract remains `escape`; stream declarations are bucketed under `escape` | `stream` outranks `escape` if live | HOLD |
| Epistemic + escape | contract remains `escape` | `epistemic` outranks `escape` if live | HOLD |
| Epistemic-only | contract remains `epistemic` | `epistemic` row exists | PASS |

The two HOLD rows are the important R142 result. The shadow registry candidate
order:

```text
oof > temporal > stream > epistemic > escape > core
```

is deterministic and proof-local, but it does not currently preserve all
classifier goldens if interpreted as live precedence. Current behavior still
has compatibility buckets:

- stream surfaces classify as `escape`;
- mixed assumptions + escape classify as `escape`.

---

## Guarded Non-Fragments And OOF Projection

Guarded non-fragments:

| Name | Policy | Observed classifier fragment assignments | Result |
| --- | --- | ---: | --- |
| `olap` | `not_fragment_class` | 0 | PASS |
| `progression` | `not_fragment_class` | 0 | PASS |

OOF projection:

```text
primary_semantics: status
secondary_projection: fragment
blocked: true
loadable: false
capability: false
observed_oof_contract_count: 7
```

Result: PASS. OOF remains status-primary and cannot become a loadable or
capability fragment in this proof.

---

## PASS/HOLD Matrix

| Check | Result |
| --- | --- |
| Consume R140 `fragment_registry` boundary | PASS |
| Observed fragment assignments have shadow rows | PASS |
| Temporal precedence preserves current classifier behavior | PASS |
| OOF status projection is non-loadable and non-capability | PASS |
| Guarded non-fragments `olap`/`progression` remain non-fragment | PASS |
| Stream candidate precedence preserves current classifier behavior if live | HOLD |
| Epistemic/escape candidate precedence preserves current classifier behavior if live | HOLD |
| Fragment registry data is not live classifier dispatch | PASS |

No failed check indicates data corruption. The HOLD checks indicate the shadow
precedence cannot yet be used as live migration evidence.

---

## Verification

Parity proof command:

```bash
ruby -rjson -rdigest -e 'def c(v); case v; when Hash; v.keys.sort.to_h { |k| [k, c(v[k])] }; when Array; v.map { |x| c(x) }; else v; end; end; matrix=JSON.parse(File.read(ARGV[0])); summary=JSON.parse(File.read(ARGV[1])); fragments=JSON.parse(File.read(ARGV[2])); ownership=JSON.parse(File.read(ARGV[3])); digest=Digest::SHA256.hexdigest(JSON.generate(c(matrix)))[0,24]; rows=fragments.fetch("fragments"); row_names=rows.map { |r| r.fetch("name") }; observed=matrix.fetch("observed_fragment_names"); checks=[]; checks << ["kind", matrix["kind"]=="fragment_precedence_parity_matrix"]; checks << ["digest", summary["parity_matrix_digest"]==digest]; checks << ["r140_boundary", matrix.dig("source_ownership_map","boundary")=="fragment_registry" && ownership.fetch("boundaries").any? { |b| b["boundary"]=="fragment_registry" }]; checks << ["observed_rows", observed.all? { |name| row_names.include?(name) } && matrix["observed_fragment_names_missing_shadow_rows"].empty?]; checks << ["guarded_non_fragments", matrix.dig("guarded_non_fragment_observations","olap_fragment_assignments_observed")==0 && matrix.dig("guarded_non_fragment_observations","progression_fragment_assignments_observed")==0 && rows.select { |r| %w[olap progression].include?(r["name"]) }.all? { |r| r["classification_kind"]=="not_fragment_class" && r["precedence_candidate"].nil? }]; checks << ["oof_projection", matrix.dig("oof_status_projection","policy_loadable")==false && matrix.dig("oof_status_projection","policy_capability")==false && matrix.dig("oof_status_projection","policy_blocked")==true]; checks << ["held_checks", summary["held_checks"].sort==matrix["held_checks"].sort && summary["status"]=="HOLD"]; checks << ["closed", matrix.fetch("proof_only_non_authority").values.all?(false) && summary.fetch("closed_surface_assertions").values.all?(false)]; failed=checks.reject { |_, ok| ok }; puts failed.empty? ? "HOLD fragment_precedence_parity #{digest} held=#{summary["held_checks"].join(",")}" : "FAIL #{failed.map(&:first).join(",")}"; exit(failed.empty? ? 0 : 1)' igniter-lang/experiments/fragment_precedence_parity_proof/out/fragment_precedence_parity_matrix.json igniter-lang/experiments/fragment_precedence_parity_proof/out/fragment_precedence_parity_summary.json igniter-lang/experiments/oof_fragment_registry_shadow_proof/out/fragment_registry.shadow_registry.json igniter-lang/experiments/compiler_pack_pass_boundary_ownership_map/out/compiler_pack_pass_boundary_ownership_map.json
```

Output:

```text
HOLD fragment_precedence_parity 81d9f687b9f59afb362e1ffc held=stream_candidate_precedence_preserves_current_classifier_behavior_if_live,epistemic_escape_candidate_precedence_preserves_current_classifier_behavior_if_live
```

Regression anchors run:

```text
ruby igniter-lang/experiments/classifier_pass_proof/classifier_pass_proof.rb
ruby igniter-lang/experiments/contract_modifiers_proof/contract_modifiers_proof.rb
```

Outputs:

```text
PASS classifier_pass_proof
PASS contract_modifiers_proof
```

R140 guard:

```text
PASS compiler_pack_pass_boundary_ownership_map 2342d159c833e5d0900cf4f4
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
hold live fragment precedence migration
more proof required
```

R142 accepts fragment-row coverage and guarded-policy parity as proof-local
evidence, but does not accept the candidate precedence order as live migration
evidence. Before any compiler-pack/profile migration can use fragment ownership
for live classifier behavior, Compiler/Grammar should resolve:

```text
stream vs escape compatibility bucket
epistemic vs escape mixed-contract precedence
```

Likely next bounded route:

```text
fragment_precedence_resolution_design_v0
```

---

## Changed Files

```text
igniter-lang/docs/tracks/fragment-precedence-parity-proof-v0.md
igniter-lang/experiments/fragment_precedence_parity_proof/out/fragment_precedence_parity_matrix.json
igniter-lang/experiments/fragment_precedence_parity_proof/out/fragment_precedence_parity_summary.json
```

---

## Handoff

[D] R142 proves fragment row coverage and guarded non-fragment / OOF projection
parity, but holds live precedence migration.

[S] Current classifier assignments are covered by shadow rows. OOF is blocked,
non-loadable, and capability-free. `olap` and `progression` remain guarded
non-fragments.

[T] HOLD: shadow candidate order would not preserve current classifier behavior
if made live for stream-vs-escape and epistemic-vs-escape mixed contracts.

[R] Do not use fragment ownership as live migration evidence yet. Route a
fragment precedence resolution design/proof before implementation review.

[Next] Ask Compiler/Grammar for the canonical compatibility rule around
`stream`, `escape`, and `epistemic` precedence.
