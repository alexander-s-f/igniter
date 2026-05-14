# PROP-036 Post CLI/API Exposure Regression Chain v0

Card: S3-R44-C4-P2
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `prop036-post-cli-api-exposure-regression-chain-v0`
Route: UPDATE
Status: done
Date: 2026-05-14

Depends on:

- S3-R44-C3-I `prop036-ruby-facade-profile-source-exposure-v0`

Affected neighbor roles:

- `[Igniter-Lang Compiler/Grammar Expert]` owns future compiler-profile
  semantic/diagnostic vocabulary.
- `[Igniter-Lang Bridge Agent]` may later consume this for loader/report or
  external caller-surface mapping.

## Goal

Run targeted regression after C3 implementation landed.

This track does not implement code.

## Inputs Read

```text
igniter-lang/docs/current-status.md
igniter-lang/docs/agent-context.md
igniter-lang/docs/tracks/prop036-ruby-facade-profile-source-exposure-v0.md
igniter-lang/experiments/prop036_ruby_facade_profile_source_exposure/prop036_ruby_facade_profile_source_exposure.rb
igniter-lang/experiments/prop036_ruby_facade_profile_source_exposure/out/prop036_ruby_facade_profile_source_exposure_summary.json
igniter-lang/lib/igniter_lang.rb
```

## C3 Summary

C3 exposed caller-supplied finalized `compiler_profile_source:` through the
public Ruby facade:

```ruby
IgniterLang.compile(..., compiler_profile_source: source)
```

The facade forwards the object unchanged to `CompilerOrchestrator#compile`.
Nil remains the default and preserves legacy optional behavior.

C3 did not add CLI flags, path loading, inline JSON parsing, profile
finalization/discovery/defaulting, loader/report status, CompatibilityReport
profile section, golden migration, RuntimeMachine binding, dispatch migration,
Ledger/TBackend, cache, or production behavior.

## Regression Matrix

| # | Command / check | Purpose | Result |
| --- | --- | --- | --- |
| 1 | `ruby -c igniter-lang/lib/igniter_lang.rb` | Syntax check for facade change | PASS |
| 2 | `ruby -c igniter-lang/experiments/prop036_ruby_facade_profile_source_exposure/prop036_ruby_facade_profile_source_exposure.rb` | Syntax check for C3 proof | PASS |
| 3 | `ruby igniter-lang/experiments/prop036_ruby_facade_profile_source_exposure/prop036_ruby_facade_profile_source_exposure.rb` | C3 Ruby facade exposure proof | PASS 7/7 |
| 4 | `ruby igniter-lang/experiments/production_compiler_cli/production_compiler_cli_proof.rb` | Existing compiler CLI/API smoke | PASS |
| 5 | `ruby igniter-lang/experiments/prop036_orchestrator_profile_source_pass_through/prop036_orchestrator_profile_source_pass_through.rb` | C1 orchestrator pass-through regression | PASS 11/11 |
| 6 | `ruby igniter-lang/experiments/assembler_compiler_profile_id_field/assembler_compiler_profile_id_field.rb` | Assembler field regression | PASS 19/19 |
| 7 | `ruby igniter-lang/experiments/minimal_compiler_profile_finalization_proof/minimal_compiler_profile_finalization_proof.rb` | Source finalization regression | PASS 22/22 |
| 8 | Exact forbidden-token JSON scan across PROP-036 and compiler CLI outputs | Re-run negative artifact scan after public Ruby facade writes JSON/refusal reports | PASS: 88 files, 0 exact hits |
| 9 | Manifest check for nil/default paths | Confirm legacy optional behavior remains | PASS |

## Exact Output

### C3 proof

```text
Prop036RubyFacadeProfileSourceExposure: PASS
  7/7 checks PASS
  exact forbidden-token hits: 0
  PASS F1.facade_signature_has_optional_keyword
  PASS F2.nil_source_preserves_legacy_manifest
  PASS F3.valid_source_emits_profile_id
  PASS F4.invalid_source_refuses_before_artifact_output
  PASS F5.invalid_source_uses_existing_refusal_path
  PASS F6.facade_forwards_source_object_unchanged
  PASS F7.existing_cli_compile_remains_legacy
Summary: experiments/prop036_ruby_facade_profile_source_exposure/out/prop036_ruby_facade_profile_source_exposure_summary.json
```

### Existing compiler CLI/API smoke

```text
PASS production_compiler_cli_proof
compile.add_exit_zero: ok
compile.add_writes_igapp: ok
compile.add_stdout_shape: ok
runtime.load_output_trusted: ok
runtime.evaluate_add_42: ok
compile.oof_exit_nonzero: ok
compile.oof_writes_report: ok
compile.oof_writes_no_igapp: ok
compile.oof_uses_igapp_path: ok
compile.oof_diagnostics_have_category: ok
compile.oof_stages_and_warnings: ok
package_boundary.direct_api_compile_ok: ok
package_boundary.cli_and_api_same_facade_shape: ok
package_boundary.lib_load_path_facade: ok
positive.igapp_path: /Users/alex/dev/projects/igniter/igniter-lang/experiments/production_compiler_cli/out/add.igapp
positive.sum: 42
direct_api.status: ok
load_path.stdout: compile=true
orchestrator=constant
negative.category: typechecker_oof
negative.report: /Users/alex/dev/projects/igniter/igniter-lang/experiments/production_compiler_cli/out/negative_unresolved_symbol.compilation_report.json
summary: igniter-lang/experiments/production_compiler_cli/production_compiler_cli_summary.json
```

### C1/C9/C7 regressions

```text
Prop036OrchestratorProfileSourcePassThrough: PASS
  11/11 checks PASS

AssemblerCompilerProfileIdFieldProof: PASS
  19/19 checks PASS

MinimalCompilerProfileFinalizationProof: PASS
  22/22 checks PASS
```

### Negative artifact scan

Forbidden exact JSON tokens:

```text
absent_legacy
present_verified
mismatch
malformed
missing_required
runtime_ready
evaluation_ready
gate3_authorized
runtime_authority
production_ready
```

Scanned directories:

```text
igniter-lang/experiments/minimal_compiler_profile_finalization_proof/out
igniter-lang/experiments/assembler_compiler_profile_id_field/out
igniter-lang/experiments/prop036_orchestrator_profile_source_pass_through/out
igniter-lang/experiments/prop036_ruby_facade_profile_source_exposure/out
igniter-lang/experiments/production_compiler_cli/out
```

Result:

```text
json_files=88
exact_forbidden_hits=0
```

Substring pressure scan found only allowed proof-local validation/check terms:

| Substring | Rationale |
| --- | --- |
| `compiler_profile_source.id_digest_mismatch` | Source-validation reason fragment, not loader status `mismatch`. |
| `compiler_profile_source.slot_order_mismatch` | Source-validation reason fragment, not loader status `mismatch`. |
| `runtime_authority_granted=false` | Source-object authority flag in proof summaries; not runtime-readiness field `runtime_authority`. |
| `compiler_profile_source.runtime_authority_forbidden` / `no_runtime_authority` | Negative validation/check vocabulary proving authority remains closed. |

### Nil/default behavior

```text
facade_nil.compiler_profile_id_present=false
cli_from_c3.compiler_profile_id_present=false
orchestrator_nil.compiler_profile_id_present=false
production_cli.compiler_profile_id_present=false
```

## Decisions

[D] C3 Ruby facade exposure is green on current HEAD.

[D] Existing production compiler CLI/API smoke remains green.

[D] C1 orchestrator pass-through, assembler field, and source finalization
proofs remain green.

[D] The post-C3 public Ruby facade output does not leak loader-status or
runtime-readiness exact JSON tokens.

[D] Nil/default behavior remains legacy optional across facade, C3 CLI check,
orchestrator, and production compiler CLI outputs.

[D] CLI profile flags, path-source loading, inline JSON parsing, loader/report
status, CompatibilityReport profile section, golden migration, dispatch
migration, signing, RuntimeMachine binding, Ledger/TBackend, cache, and
production behavior remain closed.

## Recommendation

Recommendation: ready for next Architect decision.

The next decision should stay single-surface. Strong candidates:

- CLI profile-source exposure, with explicit input/refusal contract and the same
  negative artifact scan;
- loader/report `compiler_profile_id` status implementation;
- CompatibilityReport compiler-profile section;
- explicit golden migration list.

## Handoff

```text
Card: S3-R44-C4-P2
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/prop036-post-cli-api-exposure-regression-chain-v0
Status: done

[D] Decisions
- C3 Ruby facade exposure proof PASS 7/7.
- Existing production compiler CLI/API smoke PASS.
- C1/C9/C7 PROP-036 regression proofs remain PASS.
- Negative artifact scan PASS: 88 JSON files, 0 exact forbidden-token hits.
- Nil/default behavior remains legacy optional.

[S] Signals
- Public Ruby facade can transport caller-finalized `compiler_profile_source`.
- CLI still has no profile input surface and produces legacy manifests.
- Refusal reports remain assembler/source-validation reports, not loader/readiness status reports.

[T] Tests / Proofs
- `ruby -c igniter-lang/lib/igniter_lang.rb` PASS.
- `ruby -c igniter-lang/experiments/prop036_ruby_facade_profile_source_exposure/prop036_ruby_facade_profile_source_exposure.rb` PASS.
- `ruby igniter-lang/experiments/prop036_ruby_facade_profile_source_exposure/prop036_ruby_facade_profile_source_exposure.rb` PASS 7/7.
- `ruby igniter-lang/experiments/production_compiler_cli/production_compiler_cli_proof.rb` PASS.
- `ruby igniter-lang/experiments/prop036_orchestrator_profile_source_pass_through/prop036_orchestrator_profile_source_pass_through.rb` PASS 11/11.
- `ruby igniter-lang/experiments/assembler_compiler_profile_id_field/assembler_compiler_profile_id_field.rb` PASS 19/19.
- `ruby igniter-lang/experiments/minimal_compiler_profile_finalization_proof/minimal_compiler_profile_finalization_proof.rb` PASS 22/22.

[R] Recommendation
- Ready for next Architect decision.
- Keep the next card bounded to one of CLI exposure, loader/report status, CompatibilityReport section, or golden migration.

[Files] Changed
- `igniter-lang/docs/tracks/prop036-post-cli-api-exposure-regression-chain-v0.md`

[Q] Open Questions
- Should CLI exposure reuse the Ruby facade source object model, or define a separate file/path input contract with its own refusal vocabulary?

[X] Rejected
- Implementing code or mutating goldens in this regression slice.
- Treating nil/default as profile-required.

[Next] Proposed next slice
- Architect decision for one bounded PROP-036 surface.
```
