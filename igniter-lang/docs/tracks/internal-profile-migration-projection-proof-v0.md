# Internal Profile Migration Projection Proof v0

Card: LANG-R139-P1  
Agent: `[Igniter-Lang Research Agent]`  
Role: `research-agent`  
Route: UPDATE  
Depends on: LANG-R138-D1, LANG-R136-P1  
Track: `internal-profile-migration-projection-proof-v0`  
Status: done  
Date: 2026-05-22

---

## Role And Neighbor Awareness

Assigned track: proof-only projection from
`internal_profile_assembly_carrier_map` to a profile/pack migration model.

Affected neighbor roles:

- `[Igniter-Lang Compiler/Grammar Expert]` - owns future CompilerProfile /
  CompilerPack semantics and any ownership pressure before implementation.
- `[Igniter-Lang Bridge Agent]` - must review before public API/CLI,
  loader/report, CompatibilityReport, `.igapp`, runtime, production, or Spark
  carriers open.

---

## Current Horizon

```text
R136 created a deterministic internal_profile_assembly_carrier_map.
R138 defines CompilerProfile as a frozen compiler-surface snapshot.
R138 defines CompilerPack as a declarative contribution unit.
R138 recommends pure projection as the first adapter candidate.
R139 proves that projection shape without implementation or pipeline use.
```

---

## Read Set

- `AGENTS.md`
- `roles/README.md`
- `roles/research-agent.md`
- `docs/current-status.md`
- `docs/tracks/internal-profile-assembly-carrier-map-v0.md`
- `docs/tracks/compiler-pack-profile-migration-design-v0.md`
- `experiments/internal_profile_assembly_carrier_map/out/internal_profile_assembly_carrier_map.json`
- `experiments/internal_profile_assembly_carrier_map/out/internal_profile_assembly_carrier_map_summary.json`

---

## Projection Artifact

Projection:

```text
igniter-lang/experiments/internal_profile_migration_projection/out/internal_profile_migration_projection.json
```

Summary:

```text
igniter-lang/experiments/internal_profile_migration_projection/out/internal_profile_migration_projection_summary.json
```

Digest:

```text
6d80b68b3a73231481759c9d
```

The projection consumes the R136 carrier map digest:

```text
d65c9c3d03dd3358fe7dff10
```

---

## Model Proven

The projection is:

```json
{
  "kind": "internal_profile_migration_projection",
  "projection_status": "proof_only",
  "adapter_candidate": {
    "kind": "pure_projection_adapter_candidate"
  },
  "future_compiler_profile": {
    "model": "frozen_compiler_surface_snapshot"
  },
  "future_compiler_pack": {
    "model": "declarative_contribution_unit"
  }
}
```

This is a model, not an object installed in `lib/`, not a compiler input, and
not a runtime signal.

---

## Future CompilerProfile Responsibilities

Modeled as a frozen compiler-surface snapshot:

```text
installed_pack_set
canonical_pack_order
pass_contribution_index
oof_descriptor_index
fragment_registry_view
compiler_capability_vocabulary
pack_dependency_closure
deterministic_digest_inputs
non_authority_metadata
```

Must not:

- drive live dispatch;
- become public API/CLI input;
- become `compiler_profile_id`;
- become `.igapp` manifest identity;
- become loader/report or CompatibilityReport evidence;
- become runtime capability or readiness.

---

## Future CompilerPack Responsibilities

Modeled as a declarative contribution unit:

```text
stable_pack_ref
slot_name
provided_surfaces_metadata
oof_ownership_metadata
fragment_ownership_metadata
dependencies_and_incompatibilities
compiler_capability_labels
proof_anchors
implementation_variant_label
```

Must not:

- mutate parser/classifier/typechecker/emitter/assembler behavior by presence;
- register live handlers without a gate;
- imply runtime executor availability;
- write `.igapp` or manifest metadata;
- alter PROP-036 or PROP-038 behavior.

---

## Pure Projection Adapter Candidate

Allowed proof-only operations:

```text
read_carrier_map_fields
copy_refs_and_digests
classify_future_responsibilities
emit_projection_model
```

Forbidden operations:

```text
root_require
compiler_pass_invocation
handler_registration
profile_id_derivation
manifest_or_igapp_write
report_or_result_write
runtime_readiness_decision
production_execution
```

---

## Anti-Confusion Checks

The projection asserts false for:

```text
is_compiler_profile
is_compiler_profile_id
is_igapp
is_manifest
is_compilation_report
is_loader_report
is_compatibility_report
is_prop036_authority
is_prop038_authority
is_runtime_readiness
is_production_readiness
```

This is the main result of the proof: the projection can pressure ownership
without becoming identity, report, artifact, runtime, or production authority.

---

## Closed Surfaces

Still closed:

- no `lib/` edits;
- no root require;
- no compiler pipeline usage;
- no public API/CLI;
- no loader/report;
- no CompatibilityReport;
- no `CompilationReport` / public result exposure;
- no `.igapp`, manifest, sidecar, or golden mutation;
- no PROP-036 or PROP-038 behavior mutation;
- no runtime, production, Spark, Ledger/TBackend, Gate 3, cache, or signing
  behavior.

---

## Verification

Command:

```bash
ruby -rjson -rdigest -e 'def c(v); case v; when Hash; v.keys.sort.to_h { |k| [k, c(v[k])] }; when Array; v.map { |x| c(x) }; else v; end; end; projection=JSON.parse(File.read(ARGV[0])); summary=JSON.parse(File.read(ARGV[1])); carrier=JSON.parse(File.read(ARGV[2])); digest=Digest::SHA256.hexdigest(JSON.generate(c(projection)))[0,24]; checks=[]; checks << ["projection_kind", projection["kind"] == "internal_profile_migration_projection"]; checks << ["source_digest", projection.dig("source", "carrier_map_digest") == summary["source_carrier_map_digest"] && summary["source_carrier_map_digest"] == Digest::SHA256.hexdigest(JSON.generate(c(carrier)))[0,24]]; checks << ["projection_digest", summary["projection_digest"] == digest]; checks << ["profile_snapshot", projection.dig("future_compiler_profile", "model") == "frozen_compiler_surface_snapshot"]; checks << ["pack_unit", projection.dig("future_compiler_pack", "model") == "declarative_contribution_unit"]; checks << ["pure_projection", projection.dig("adapter_candidate", "kind") == "pure_projection_adapter_candidate"]; checks << ["anti_confusion", projection["anti_confusion_assertions"].values.all?(false)]; checks << ["closed", projection["closed_surface_assertions"].values.all?(false)]; failed=checks.reject { |_, ok| ok }; puts failed.empty? ? "PASS internal_profile_migration_projection #{digest}" : "FAIL #{failed.map(&:first).join(",")}"; exit(failed.empty? ? 0 : 1)' igniter-lang/experiments/internal_profile_migration_projection/out/internal_profile_migration_projection.json igniter-lang/experiments/internal_profile_migration_projection/out/internal_profile_migration_projection_summary.json igniter-lang/experiments/internal_profile_assembly_carrier_map/out/internal_profile_assembly_carrier_map.json
```

Output:

```text
PASS internal_profile_migration_projection 6d80b68b3a73231481759c9d
```

R136 guard command:

```text
ruby -rjson -rdigest -e ... internal_profile_assembly_carrier_map.json internal_profile_assembly_carrier_map_summary.json
```

Output:

```text
PASS internal_profile_assembly_carrier_map d65c9c3d03dd3358fe7dff10
```

---

## Recommendation

```text
hold implementation
ownership pressure next
```

Best next proof route:

```text
pass-boundary ownership map
```

Reason: the projection is now clear enough to ask which packs own parser,
classifier, TypeChecker, SemanticIR, assembler, OOF, and fragment responsibilities.
Implementation review should remain later, after ownership and parity are
proven.

---

## Changed Files

```text
igniter-lang/docs/tracks/internal-profile-migration-projection-proof-v0.md
igniter-lang/experiments/internal_profile_migration_projection/out/internal_profile_migration_projection.json
igniter-lang/experiments/internal_profile_migration_projection/out/internal_profile_migration_projection_summary.json
```

---

## Handoff

[D] `internal_profile_migration_projection` exists as proof-local JSON only.

[S] Future `CompilerProfile` is modeled only as a frozen compiler-surface
snapshot; future `CompilerPack` is modeled only as a declarative contribution
unit; adapter candidate is pure projection only.

[T] PASS: projection digest, R136 carrier-map digest, anti-confusion checks,
and closed-surface checks.

[R] Hold implementation. Route ownership pressure or next proof before any
adapter implementation review.

[Next] Recommended next proof: pass-boundary ownership map plus OOF/fragment
parity requirements.
