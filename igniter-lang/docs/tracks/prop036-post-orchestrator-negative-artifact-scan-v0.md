# PROP-036 Post-Orchestrator Negative Artifact Scan v0

Card: S3-R44-C1-P1
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `prop036-post-orchestrator-negative-artifact-scan-v0`
Route: UPDATE
Status: done
Date: 2026-05-14

Affected neighbor roles:

- `[Igniter-Lang Compiler/Grammar Expert]` owns future compiler-profile
  diagnostic vocabulary and semantic widening decisions.
- `[Igniter-Lang Bridge Agent]` may consume this before CLI/API or
  CompatibilityReport bridge exposure.

## Goal

Prove that the current PROP-036 assembler/orchestrator implementation does not
leak loader-status vocabulary or runtime-readiness vocabulary into written JSON
artifacts or refusal reports before public CLI/API exposure is considered.

This track does not implement code and does not mutate goldens.

## Inputs Read

```text
igniter-lang/docs/tracks/prop036-orchestrator-profile-source-pass-through-v0.md
igniter-lang/docs/discussions/r43-orchestrator-profile-source-pressure-v0.md
igniter-lang/docs/tracks/prop036-post-orchestrator-regression-chain-v0.md
igniter-lang/docs/tracks/assembler-compiler-profile-id-field-v0.md
```

## Forbidden Vocabulary

Loader-status vocabulary:

```text
absent_legacy
present_verified
mismatch
missing_required
```

Runtime-readiness vocabulary:

```text
runtime_ready
evaluation_ready
gate3_authorized
runtime_authority
production_ready
```

The scan distinguishes exact JSON tokens from substring matches. Exact JSON
tokens mean a key or scalar value exactly equals one of the forbidden terms.
Substring matches are reviewed as possible false positives.

## Proof Outputs Refreshed

| Command | Purpose | Result |
| --- | --- | --- |
| `ruby igniter-lang/experiments/minimal_compiler_profile_finalization_proof/minimal_compiler_profile_finalization_proof.rb` | Refresh source finalization proof output | PASS 22/22 |
| `ruby igniter-lang/experiments/assembler_compiler_profile_id_field/assembler_compiler_profile_id_field.rb` | Refresh assembler field proof output | PASS 19/19 |
| `ruby igniter-lang/experiments/prop036_orchestrator_profile_source_pass_through/prop036_orchestrator_profile_source_pass_through.rb` | Refresh orchestrator pass-through proof output, including refusal report | PASS 11/11 |

## Scan Commands

Path listing:

```text
find igniter-lang/experiments/minimal_compiler_profile_finalization_proof/out igniter-lang/experiments/assembler_compiler_profile_id_field/out igniter-lang/experiments/prop036_orchestrator_profile_source_pass_through/out -name '*.json' -type f | sort
```

Exact-token JSON scan:

```text
ruby -rjson -e 'forbidden = %w[absent_legacy present_verified mismatch missing_required runtime_ready evaluation_ready gate3_authorized runtime_authority production_ready]; files = ARGV.flat_map { |dir| Dir.glob(File.join(dir, "**", "*.json")) }.sort; hits = []; walk = lambda do |value, path, file|; case value; when Hash; value.each do |k, v|; hits << [file, path + [k], "key", k] if forbidden.include?(k); walk.call(v, path + [k], file); end; when Array; value.each_with_index { |v, i| walk.call(v, path + [i], file) }; else; hits << [file, path, "value", value] if forbidden.include?(value); end; end; files.each { |file| walk.call(JSON.parse(File.read(file)), [], file) }; puts "json_files=#{files.length}"; puts "exact_forbidden_hits=#{hits.length}"; hits.each { |file, path, kind, value| puts [file, kind, path.join("."), value].join(":") }' igniter-lang/experiments/minimal_compiler_profile_finalization_proof/out igniter-lang/experiments/assembler_compiler_profile_id_field/out igniter-lang/experiments/prop036_orchestrator_profile_source_pass_through/out
```

Substring pressure scan:

```text
rg -n "absent_legacy|present_verified|mismatch|missing_required|runtime_ready|evaluation_ready|gate3_authorized|runtime_authority|production_ready" igniter-lang/experiments/minimal_compiler_profile_finalization_proof/out igniter-lang/experiments/assembler_compiler_profile_id_field/out igniter-lang/experiments/prop036_orchestrator_profile_source_pass_through/out -g '*.json'
```

## Scan Result

Exact-token JSON scan:

```text
json_files=49
exact_forbidden_hits=0
```

Substring pressure scan found only allowed proof-local validation terms:

| Term pattern | Where it appears | Rationale |
| --- | --- | --- |
| `slot_order_mismatch`, `id_digest_mismatch`, check names containing `mismatch` | finalization and assembler summary JSON | Compiler-profile source validation reason fragments; not loader status value `mismatch`. |
| `runtime_authority_granted` | canonical source objects in summary JSON | Source-object authority flag that must be `false`; not runtime readiness field `runtime_authority`. |
| `compiler_profile_source.runtime_authority_forbidden`, `runtime_authority_refused`, `no_runtime_authority` | validation summaries/check names | Negative proof that runtime authority is refused; not runtime-readiness vocabulary emitted as an artifact status. |

No `absent_legacy`, `present_verified`, `missing_required`, `runtime_ready`,
`evaluation_ready`, `gate3_authorized`, or `production_ready` substring matches
were found in scanned JSON.

## Scanned Paths

```text
igniter-lang/experiments/assembler_compiler_profile_id_field/out/altered_assembly.igapp/classified_ast.json
igniter-lang/experiments/assembler_compiler_profile_id_field/out/altered_assembly.igapp/compatibility_metadata.json
igniter-lang/experiments/assembler_compiler_profile_id_field/out/altered_assembly.igapp/compilation_report.json
igniter-lang/experiments/assembler_compiler_profile_id_field/out/altered_assembly.igapp/contracts/add.json
igniter-lang/experiments/assembler_compiler_profile_id_field/out/altered_assembly.igapp/diagnostics.json
igniter-lang/experiments/assembler_compiler_profile_id_field/out/altered_assembly.igapp/manifest.json
igniter-lang/experiments/assembler_compiler_profile_id_field/out/altered_assembly.igapp/projections.json
igniter-lang/experiments/assembler_compiler_profile_id_field/out/altered_assembly.igapp/requirements.json
igniter-lang/experiments/assembler_compiler_profile_id_field/out/altered_assembly.igapp/semantic_ir_program.json
igniter-lang/experiments/assembler_compiler_profile_id_field/out/assembler_compiler_profile_id_field_summary.json
igniter-lang/experiments/assembler_compiler_profile_id_field/out/legacy_assembly.igapp/classified_ast.json
igniter-lang/experiments/assembler_compiler_profile_id_field/out/legacy_assembly.igapp/compatibility_metadata.json
igniter-lang/experiments/assembler_compiler_profile_id_field/out/legacy_assembly.igapp/compilation_report.json
igniter-lang/experiments/assembler_compiler_profile_id_field/out/legacy_assembly.igapp/contracts/add.json
igniter-lang/experiments/assembler_compiler_profile_id_field/out/legacy_assembly.igapp/diagnostics.json
igniter-lang/experiments/assembler_compiler_profile_id_field/out/legacy_assembly.igapp/manifest.json
igniter-lang/experiments/assembler_compiler_profile_id_field/out/legacy_assembly.igapp/projections.json
igniter-lang/experiments/assembler_compiler_profile_id_field/out/legacy_assembly.igapp/requirements.json
igniter-lang/experiments/assembler_compiler_profile_id_field/out/legacy_assembly.igapp/semantic_ir_program.json
igniter-lang/experiments/assembler_compiler_profile_id_field/out/profiled_assembly.igapp/classified_ast.json
igniter-lang/experiments/assembler_compiler_profile_id_field/out/profiled_assembly.igapp/compatibility_metadata.json
igniter-lang/experiments/assembler_compiler_profile_id_field/out/profiled_assembly.igapp/compilation_report.json
igniter-lang/experiments/assembler_compiler_profile_id_field/out/profiled_assembly.igapp/contracts/add.json
igniter-lang/experiments/assembler_compiler_profile_id_field/out/profiled_assembly.igapp/diagnostics.json
igniter-lang/experiments/assembler_compiler_profile_id_field/out/profiled_assembly.igapp/manifest.json
igniter-lang/experiments/assembler_compiler_profile_id_field/out/profiled_assembly.igapp/projections.json
igniter-lang/experiments/assembler_compiler_profile_id_field/out/profiled_assembly.igapp/requirements.json
igniter-lang/experiments/assembler_compiler_profile_id_field/out/profiled_assembly.igapp/semantic_ir_program.json
igniter-lang/experiments/minimal_compiler_profile_finalization_proof/out/minimal_compiler_profile_finalization_summary.json
igniter-lang/experiments/prop036_orchestrator_profile_source_pass_through/out/legacy_compile.igapp/classified_ast.json
igniter-lang/experiments/prop036_orchestrator_profile_source_pass_through/out/legacy_compile.igapp/compatibility_metadata.json
igniter-lang/experiments/prop036_orchestrator_profile_source_pass_through/out/legacy_compile.igapp/compilation_report.json
igniter-lang/experiments/prop036_orchestrator_profile_source_pass_through/out/legacy_compile.igapp/contracts/add.json
igniter-lang/experiments/prop036_orchestrator_profile_source_pass_through/out/legacy_compile.igapp/diagnostics.json
igniter-lang/experiments/prop036_orchestrator_profile_source_pass_through/out/legacy_compile.igapp/manifest.json
igniter-lang/experiments/prop036_orchestrator_profile_source_pass_through/out/legacy_compile.igapp/projections.json
igniter-lang/experiments/prop036_orchestrator_profile_source_pass_through/out/legacy_compile.igapp/requirements.json
igniter-lang/experiments/prop036_orchestrator_profile_source_pass_through/out/legacy_compile.igapp/semantic_ir_program.json
igniter-lang/experiments/prop036_orchestrator_profile_source_pass_through/out/profiled_compile.igapp/classified_ast.json
igniter-lang/experiments/prop036_orchestrator_profile_source_pass_through/out/profiled_compile.igapp/compatibility_metadata.json
igniter-lang/experiments/prop036_orchestrator_profile_source_pass_through/out/profiled_compile.igapp/compilation_report.json
igniter-lang/experiments/prop036_orchestrator_profile_source_pass_through/out/profiled_compile.igapp/contracts/add.json
igniter-lang/experiments/prop036_orchestrator_profile_source_pass_through/out/profiled_compile.igapp/diagnostics.json
igniter-lang/experiments/prop036_orchestrator_profile_source_pass_through/out/profiled_compile.igapp/manifest.json
igniter-lang/experiments/prop036_orchestrator_profile_source_pass_through/out/profiled_compile.igapp/projections.json
igniter-lang/experiments/prop036_orchestrator_profile_source_pass_through/out/profiled_compile.igapp/requirements.json
igniter-lang/experiments/prop036_orchestrator_profile_source_pass_through/out/profiled_compile.igapp/semantic_ir_program.json
igniter-lang/experiments/prop036_orchestrator_profile_source_pass_through/out/prop036_orchestrator_profile_source_pass_through_summary.json
igniter-lang/experiments/prop036_orchestrator_profile_source_pass_through/out/refused_compile.compilation_report.json
```

## Decisions

[D] Current PROP-036 finalization, assembler, and orchestrator proof outputs do
not emit forbidden loader-status or runtime-readiness vocabulary as exact JSON
keys or scalar values.

[D] Refusal artifacts were included. The orchestrator refusal report remains
compiler-profile-source refusal text, not loader-status or runtime-readiness
status.

[D] Substring hits are validation vocabulary and check names, not public
loader/readiness status fields.

[D] This scan does not authorize CLI/API exposure, loader/report status,
CompatibilityReport compiler-profile section, golden migration, dispatch
migration, signing, RuntimeMachine binding, Ledger/TBackend, production cache,
or deployment.

## Recommendation

Recommendation: ready for CLI/API exposure decision, with the condition that the
next card preserves the same negative vocabulary scan over all newly written
JSON and refusal reports.

The next Architect decision should still choose a single bounded surface:

- CLI/API exposure for a caller-supplied finalized `compiler_profile_source`;
- loader/report status implementation;
- CompatibilityReport compiler-profile section;
- explicit golden migration list.

## Handoff

```text
Card: S3-R44-C1-P1
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/prop036-post-orchestrator-negative-artifact-scan-v0
Status: done

[D] Decisions
- Refreshed source finalization, assembler field, and orchestrator pass-through proof outputs.
- Scanned 49 JSON artifacts across relevant PROP-036 proof output dirs.
- Exact forbidden-token hits: 0.
- Substring hits are allowed proof-local validation/check vocabulary, not loader status or runtime readiness.

[S] Signals
- Refusal reports were included in the scan.
- Current output remains free of loader status values and public runtime-readiness vocabulary before CLI/API exposure.

[T] Tests / Proofs
- `ruby igniter-lang/experiments/minimal_compiler_profile_finalization_proof/minimal_compiler_profile_finalization_proof.rb` PASS 22/22.
- `ruby igniter-lang/experiments/assembler_compiler_profile_id_field/assembler_compiler_profile_id_field.rb` PASS 19/19.
- `ruby igniter-lang/experiments/prop036_orchestrator_profile_source_pass_through/prop036_orchestrator_profile_source_pass_through.rb` PASS 11/11.
- Exact-token JSON scan PASS: `json_files=49`, `exact_forbidden_hits=0`.

[R] Recommendation
- Ready for CLI/API exposure decision.
- Require the next CLI/API exposure card to rerun this scan over any newly written JSON/refusal artifacts.

[Files] Changed
- `igniter-lang/docs/tracks/prop036-post-orchestrator-negative-artifact-scan-v0.md`

[Q] Open Questions
- Should the next CLI/API card treat substring validation reasons as explicitly allowed vocabulary in its own acceptance checklist?

[X] Rejected
- Implementing code or mutating goldens during this scan.
- Treating source-validation flags like `runtime_authority_granted=false` as runtime readiness.

[Next] Proposed next slice
- Architect decision for bounded CLI/API exposure or a single alternate PROP-036 surface.
```
