# OOF Fragment Registry Parity Proof v0

Card: LANG-R141-P1  
Agent: `[Igniter-Lang Research Agent]`  
Role: `research-agent`  
Route: UPDATE  
Depends on: LANG-R140-P1, LANG-R139-P1  
Track: `oof-fragment-registry-parity-proof-v0`  
Status: done  
Date: 2026-05-22

---

## Role And Neighbor Awareness

Assigned track: prove shadow OOF registry parity for the `oof_registry`
boundary before any compiler-pack/profile migration can use OOF ownership as
live migration evidence.

Affected neighbor roles:

- `[Igniter-Lang Compiler/Grammar Expert]` - owns future OOF semantics,
  diagnostic ownership, and any formal migration into compiler packs.
- `[Igniter-Lang Bridge Agent]` - must review before public API/CLI,
  loader/report, CompatibilityReport, `.igapp`, runtime, production, or Spark
  surfaces open.

---

## Current Horizon

```text
R139 proves a pure internal profile migration projection.
R140 maps pass-boundary ownership and marks oof_registry parity as required.
R141 focuses only on OOF registry parity against observed compiler OOF behavior.
The result is shadow/proof data only; no live registry migration is authorized.
```

---

## Read Set

- `AGENTS.md`
- `roles/README.md`
- `roles/research-agent.md`
- `docs/README.md`
- `docs/operating-model.md`
- `docs/current-status.md`
- `docs/tracks/internal-profile-migration-projection-proof-v0.md`
- `docs/tracks/compiler-pack-pass-boundary-ownership-map-v0.md`
- `docs/tracks/oof-fragment-registry-shadow-proof-v0.md`
- `docs/tracks/oof-fragment-registry-policy-proof-v0.md`
- `experiments/compiler_pack_pass_boundary_ownership_map/out/compiler_pack_pass_boundary_ownership_map.json`
- `experiments/oof_fragment_registry_shadow_proof/out/oof_descriptors.shadow_registry.json`
- `experiments/oof_fragment_registry_policy_proof/out/oof_fragment_registry_policy_model.json`

---

## Proof Artifacts

Parity matrix:

```text
igniter-lang/experiments/oof_fragment_registry_parity_proof/out/oof_fragment_registry_parity_matrix.json
```

Summary:

```text
igniter-lang/experiments/oof_fragment_registry_parity_proof/out/oof_fragment_registry_parity_summary.json
```

Digest:

```text
f96e020c2e75223acb8addbf
```

Source R140 ownership map digest:

```text
2342d159c833e5d0900cf4f4
```

---

## Observed Compiler OOF Codes

Observed proof/compiler-facing OOF codes from parser hardening, classifier,
typechecker, SemanticIR compilation reports, and contract modifier proof
fixtures:

```text
OOF-BT1 OOF-BT2 OOF-BT3 OOF-BT4
OOF-CE4 OOF-DM3 OOF-H1 OOF-I4 OOF-IV3
OOF-M1 OOF-OS2 OOF-P1 OOF-P2
OOF-PG1 OOF-PG2 OOF-PG3 OOF-PG5
OOF-S2 OOF-S3 OOF-S4
OOF-TM1 OOF-TM3 OOF-TM4 OOF-TM5 OOF-TM6
```

Parity result:

```text
observed_code_count: 25
shadow_descriptor_count: 63
missing_observed_descriptors: []
```

All observed public OOF codes have a shadow descriptor. Shadow-only descriptors
that were not observed in the selected emitted fixtures remain allowed proof
data; they are not treated as live compiler behavior.

---

## Alias And Deprecation Parity

| Alias | Replacement | Deprecated | Parity |
| --- | --- | --- | --- |
| `OOF-TM1` | `OOF-H1` | true | PASS |
| `OOF-TM3` | `OOF-BT1` | true | PASS |
| `OOF-TM4` | `OOF-BT2` | true | PASS |
| `OOF-TM5` | `OOF-BT3` | true | PASS |
| `OOF-TM6` | `OOF-BT4` | true | PASS |

Alias parity is proof-only lifecycle metadata. It does not authorize compiler
diagnostic rewriting or public result/report changes.

---

## Excluded Namespaces

| Namespace | Registry result | Parity |
| --- | --- | --- |
| `compiler_profile_contract.*` | excluded from OOF descriptors/aliases | PASS |
| `compiler_profile_contract_refusal.*` | excluded from OOF descriptors/aliases | PASS |

No `compiler_profile_contract.*` or
`compiler_profile_contract_refusal.*` leakage is present in the shadow OOF
descriptor or alias space.

---

## PASS/FAIL Matrix

| Check | Result |
| --- | --- |
| Consume R140 `oof_registry` boundary | PASS |
| Observed public OOF codes have shadow descriptors | PASS |
| Message/stage modeled for observed descriptors | PASS |
| Aliases have deprecated replacement metadata | PASS |
| Excluded namespaces absent from OOF descriptors and aliases | PASS |
| No `compiler_profile_contract.*` leakage | PASS |
| Proof-only closed surfaces preserved | PASS |

---

## Verification

Parity proof command:

```bash
ruby -rjson -rdigest -e 'def c(v); case v; when Hash; v.keys.sort.to_h { |k| [k, c(v[k])] }; when Array; v.map { |x| c(x) }; else v; end; end; matrix=JSON.parse(File.read(ARGV[0])); summary=JSON.parse(File.read(ARGV[1])); shadow=JSON.parse(File.read(ARGV[2])); ownership=JSON.parse(File.read(ARGV[3])); digest=Digest::SHA256.hexdigest(JSON.generate(c(matrix)))[0,24]; descriptors=shadow.fetch("descriptors"); by=descriptors.to_h { |d| [d.fetch("code"), d] }; observed=matrix.fetch("observed_emitted_oof_codes"); aliases=matrix.fetch("alias_parity"); excluded=matrix.fetch("excluded_namespace_parity"); checks=[]; checks << ["kind", matrix["kind"]=="oof_fragment_registry_parity_matrix"]; checks << ["digest", summary["parity_matrix_digest"]==digest]; checks << ["r140_boundary", matrix.dig("source_ownership_map","boundary")=="oof_registry" && ownership.fetch("boundaries").any? { |b| b["boundary"]=="oof_registry" }]; checks << ["observed_descriptors", observed.all? { |code| by.key?(code) }]; checks << ["observed_missing_empty", summary["missing_observed_descriptors"].empty?]; checks << ["aliases", aliases.all? { |a| by[a["alias"]]&.fetch("replacement_code")==a["replacement_code"] && by[a["alias"]]&.fetch("deprecated")==true }]; checks << ["excluded", excluded["compiler_profile_contract.*"]=="excluded_from_oof" && excluded["compiler_profile_contract_refusal.*"]=="excluded_from_oof" && excluded["compiler_profile_contract_leakage_detected"]==false]; checks << ["closed", matrix.fetch("closed_surface_assertions").values.all?(false) && summary.fetch("closed_surface_assertions").values.all?(false)]; failed=checks.reject { |_, ok| ok }; puts failed.empty? ? "PASS oof_fragment_registry_parity #{digest}" : "FAIL #{failed.map(&:first).join(",")}"; exit(failed.empty? ? 0 : 1)' igniter-lang/experiments/oof_fragment_registry_parity_proof/out/oof_fragment_registry_parity_matrix.json igniter-lang/experiments/oof_fragment_registry_parity_proof/out/oof_fragment_registry_parity_summary.json igniter-lang/experiments/oof_fragment_registry_shadow_proof/out/oof_descriptors.shadow_registry.json igniter-lang/experiments/compiler_pack_pass_boundary_ownership_map/out/compiler_pack_pass_boundary_ownership_map.json
```

Output:

```text
PASS oof_fragment_registry_parity f96e020c2e75223acb8addbf
```

R140 guard:

```text
PASS compiler_pack_pass_boundary_ownership_map 2342d159c833e5d0900cf4f4
```

---

## Closed Surfaces

Still closed:

- no `lib/` edits;
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
accept OOF parity as shadow/proof-only evidence
hold live registry migration
```

The OOF registry parity requirement from R140 is satisfied for currently
observed compiler-emitted OOF codes and modeled alias/exclusion metadata. This
does not make the registry live migration evidence yet; future migration still
needs implementation authorization plus parity against any broader compiler
goldens selected by Compiler/Grammar.

Recommended next route:

```text
fragment_precedence_parity_proof
```

---

## Changed Files

```text
igniter-lang/docs/tracks/oof-fragment-registry-parity-proof-v0.md
igniter-lang/experiments/oof_fragment_registry_parity_proof/out/oof_fragment_registry_parity_matrix.json
igniter-lang/experiments/oof_fragment_registry_parity_proof/out/oof_fragment_registry_parity_summary.json
```

---

## Handoff

[D] R141 proves OOF registry parity for observed compiler/proof OOF codes
against the current shadow descriptor registry.

[S] 25 observed OOF codes all have shadow descriptors; 5 compatibility aliases
carry deprecated replacement metadata; `compiler_profile_contract.*` namespaces
remain excluded.

[T] PASS: parity digest, R140 boundary consumption, observed descriptor
coverage, alias/deprecation coverage, excluded namespace guard, closed surfaces.

[R] Accept OOF parity as shadow/proof-only evidence. Hold live migration,
dispatch, diagnostics/report integration, and public surfaces.

[Next] Run fragment precedence parity before any CompilerPack/profile migration
implementation review.
