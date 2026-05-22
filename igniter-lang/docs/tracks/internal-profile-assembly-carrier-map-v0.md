# Internal Profile Assembly Carrier Map v0

Card: LANG-R136-P1  
Agent: `[Igniter-Lang Research Agent]`  
Role: `research-agent`  
Route: UPDATE  
Depends on: LANG-R135-D1, LANG-R134-H1  
Track: `internal-profile-assembly-carrier-map-v0`  
Status: done  
Date: 2026-05-22

---

## Role And Neighbor Awareness

Assigned track: no-code internal carrier map for
`internal_profile_assembly_result`.

Affected neighbor roles:

- `[Igniter-Lang Compiler/Grammar Expert]` - owns future compiler-pack/profile
  migration semantics if this map becomes implementation pressure.
- `[Igniter-Lang Bridge Agent]` - must review before public API/CLI,
  loader/report, CompatibilityReport, `.igapp`, runtime, production, or Spark
  carriers open.

---

## Current Horizon

```text
R134 resolves the stale proof and accepts R133 closure.
R135 recommends an internal carrier map as the next design-only step.
internal_profile_assembly_result is internal-only and not a profile identity.
This slice maps possible consumers and blockers without implementing code.
```

---

## Read Set

- `AGENTS.md`
- `roles/README.md`
- `roles/research-agent.md`
- `docs/README.md`
- `docs/operating-model.md`
- `docs/current-status.md`
- `docs/tracks/internal-profile-assembly-boundary-proof-maintenance-v0.md`
- `docs/tracks/internal-profile-assembly-next-carrier-design-v0.md`
- `docs/tracks/compiler-profile-source-input-lifecycle-owner-design-v0.md`
- `docs/tracks/oof-fragment-registry-compiler-profile-source-input-design-v0.md`
- `docs/tracks/compiler-pack-boundary-report-v0.md`
- `lib/igniter_lang/internal_profile_assembly.rb`
- `experiments/internal_profile_assembly_boundary_proof/out/internal_profile_assembly_result.valid.json`

---

## Carrier Map Artifact

Proof-local JSON map:

```text
igniter-lang/experiments/internal_profile_assembly_carrier_map/out/internal_profile_assembly_carrier_map.json
```

Summary:

```text
igniter-lang/experiments/internal_profile_assembly_carrier_map/out/internal_profile_assembly_carrier_map_summary.json
```

Core shape:

```json
{
  "kind": "internal_profile_assembly_carrier_map",
  "format_version": "0.1.0",
  "source_result_kind": "internal_profile_assembly_result",
  "candidate_consumers": [],
  "blocked_consumers": [],
  "pack_boundary_refs": [],
  "oof_fragment_registry_refs": [],
  "required_parity_proofs": [],
  "bridge_review_required_before": [],
  "closed_surface_assertions": {}
}
```

Digest:

```text
d65c9c3d03dd3358fe7dff10
```

The digest is computed from canonical JSON key ordering over the map object.

---

## Candidate Consumers

| Consumer | Allowed now | Carrier mode | Note |
| --- | --- | --- | --- |
| `track_docs_and_design_docs` | yes | evidence reference only | May cite result shape and digests as design evidence. |
| `proof_local_carrier_map_experiment` | yes | proof-local JSON only | May classify future consumers/blockers. |
| `internal_migration_design_packet` | yes | design only | May describe profile/pack migration checkpoints. |
| `future_internal_profile_assembly_adapter` | no | implementation review required | Needs exact write scope, direct-require proof, rejection cases, and parity matrix. |

Allowed now means evidence use only. It does not authorize compiler input,
public fields, reports, artifacts, or runtime behavior.

---

## Blocked Consumers

| Consumer | Reason |
| --- | --- |
| `lib_igniter_lang_root_require` | Would expose the internal assembly boundary from the package root. |
| `igniter_lang_compile_facade` | Would make the map a public compiler input. |
| `cli` | Would imply path loading and public error/status semantics. |
| `parser_classifier_typechecker_semanticir_assembler_orchestrator` | Would connect the map to the compiler pipeline before pack migration authority. |
| `compilation_report_compiler_result_diagnostics` | Would create report/result vocabulary and public diagnostic exposure. |
| `loader_report_or_compatibility_report` | Would turn internal assembly evidence into load/readiness evidence. |
| `igapp_manifest_sidecar_golden` | Would mutate artifact identity or golden fixtures. |
| `prop036_manifest_identity_or_profile_id` | The source result is not `compiler_profile_id` and not PROP-036 finalization. |
| `prop038_contract_validation_or_strict_terminal` | The source result is not validator authority and not strict-refusal authority. |
| `runtime_gate3_ledger_tbackend_cache_signing_production_spark` | Compiler/profile metadata is not runtime capability, production readiness, or Spark authority. |

---

## Anti-Confusion Checks

The map asserts false for:

```text
is_compiler_profile
is_compiler_profile_id
is_igapp
is_manifest
is_compilation_report
is_loader_report
is_compatibility_report
is_runtime_readiness
is_production_readiness
is_prop036_finalization
is_prop038_authority
```

This keeps the map as planning evidence only. It is not a carrier that can be
loaded, reported, executed, or interpreted as readiness.

---

## Required Parity Proofs Before Any Implementation Review

| Proof | Required before |
| --- | --- |
| `r132_r133_r134_matrix` | Any live carrier implementation review. |
| `deterministic_carrier_map_digest` | Using this map as implementation evidence. |
| `not_compiler_profile_or_profile_id` | Profile migration design acceptance. |
| `no_root_require_or_pipeline_usage` | Any lib carrier implementation. |
| `no_public_report_loader_manifest_runtime_mutation` | Any external carrier discussion. |
| `semanticir_compilation_report_igapp_byte_for_byte_parity` | Compiler pack dispatch or pipeline migration. |
| `oof_fragment_registry_parity` | OOF/Fragment registry use as live profile input. |

---

## Bridge Review Required Before

```text
public_api_cli
loader_report
compatibility_report
compilation_report_public_result
igapp_manifest_sidecar
runtime_readiness
production_or_spark_carrier
```

Bridge pressure is not first movement for this slice, but it is mandatory before
any external carrier opens.

---

## Demonstration

Command:

```bash
ruby -rjson -rdigest -e 'def c(v); case v; when Hash; v.keys.sort.to_h{|k| [k,c(v[k])]}; when Array; v.map{|x| c(x)}; else v; end; end; map=JSON.parse(File.read(ARGV[0])); summary=JSON.parse(File.read(ARGV[1])); digest=Digest::SHA256.hexdigest(JSON.generate(c(map)))[0,24]; checks=[]; checks << ["kind", map["kind"] == "internal_profile_assembly_carrier_map"]; checks << ["source", map["source_result_kind"] == "internal_profile_assembly_result"]; checks << ["digest", summary["map_digest"] == digest]; checks << ["not_profile", map.dig("anti_confusion_assertions", "is_compiler_profile") == false]; checks << ["not_profile_id", map.dig("anti_confusion_assertions", "is_compiler_profile_id") == false]; checks << ["closed", map["closed_surface_assertions"].values.all?(false)]; failed=checks.reject{|_, ok| ok}; puts failed.empty? ? "PASS internal_profile_assembly_carrier_map #{digest}" : "FAIL #{failed.map(&:first).join(",")}"; exit(failed.empty? ? 0 : 1)' igniter-lang/experiments/internal_profile_assembly_carrier_map/out/internal_profile_assembly_carrier_map.json igniter-lang/experiments/internal_profile_assembly_carrier_map/out/internal_profile_assembly_carrier_map_summary.json
```

Output:

```text
PASS internal_profile_assembly_carrier_map d65c9c3d03dd3358fe7dff10
```

R134 guard command:

```text
ruby igniter-lang/experiments/internal_profile_assembly_boundary_proof/internal_profile_assembly_boundary_proof.rb
```

Output:

```text
PASS internal-profile-assembly-boundary-proof-v0
cases: 6/6
checks: 5/5
recommendation: ACCEPT_R133_CLOSURE
```

---

## Closed Surfaces

Still closed:

- no `lib/` edits;
- no root require from `lib/igniter_lang.rb`;
- no parser/classifier/TypeChecker/SemanticIR/assembler/orchestrator usage;
- no public API/CLI;
- no loader/report;
- no CompatibilityReport;
- no `.igapp`, manifest, sidecar, or golden mutation;
- no PROP-036 or PROP-038 behavior mutation;
- no runtime, production, Spark, Ledger/TBackend, cache, or signing behavior.

---

## Recommendation

```text
hold live carrier
run Bridge pressure before any external carrier
future implementation review only for a named internal carrier surface
```

The map is useful as a pre-implementation classifier. It should not become a
library class, compiler input, report field, artifact field, or runtime signal
without a new Architect gate.

---

## Changed Files

```text
igniter-lang/docs/tracks/internal-profile-assembly-carrier-map-v0.md
igniter-lang/experiments/internal_profile_assembly_carrier_map/out/internal_profile_assembly_carrier_map.json
igniter-lang/experiments/internal_profile_assembly_carrier_map/out/internal_profile_assembly_carrier_map_summary.json
```

---

## Handoff

[D] `internal_profile_assembly_carrier_map` is a proof-local/design-only map,
not a live carrier.

[S] It can classify future internal compiler-pack/profile consumers, but it
cannot be mistaken for `CompilerProfile`, `compiler_profile_id`, `.igapp`,
report, loader, CompatibilityReport, runtime readiness, or production readiness.

[T] PASS: deterministic map digest and anti-confusion/closed-surface checks.
R134 boundary proof remains PASS.

[R] Hold live carrier. Request Bridge pressure before external surfaces; request
future implementation review only for a named internal carrier surface.

[Next] Candidate next card: Bridge pressure on whether any report/public
carrier is needed, or Implementation review for a direct-require-only internal
adapter if Compiler/Grammar first accepts a migration checkpoint design.
