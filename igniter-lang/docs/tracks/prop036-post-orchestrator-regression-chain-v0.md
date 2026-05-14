# PROP-036 Post-Orchestrator Regression Chain v0

Card: S3-R43-C2-P1
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `prop036-post-orchestrator-regression-chain-v0`
Route: UPDATE
Status: done
Date: 2026-05-14

Depends on:

- S3-R43-C1-I `prop036-orchestrator-profile-source-pass-through-v0`

Affected neighbor roles:

- `[Igniter-Lang Compiler/Grammar Expert]` owns future compiler-profile
  semantic/diagnostic expansion.
- `[Igniter-Lang Bridge Agent]` may later consume compiler-profile metadata in
  loader/report/package bridge surfaces.

## Goal

Run a targeted regression chain after the S3-R43-C1-I orchestrator pass-through
landed.

This card does not implement code.

## Inputs Read

```text
igniter-lang/AGENTS.md
igniter-lang/roles/README.md
igniter-lang/roles/research-agent.md
igniter-lang/docs/agent-context.md
igniter-lang/docs/current-status.md
igniter-lang/docs/operating-model.md
igniter-lang/docs/tracks/prop036-orchestrator-profile-source-pass-through-v0.md
igniter-lang/experiments/prop036_orchestrator_profile_source_pass_through/prop036_orchestrator_profile_source_pass_through.rb
igniter-lang/experiments/prop036_orchestrator_profile_source_pass_through/out/prop036_orchestrator_profile_source_pass_through_summary.json
igniter-lang/lib/igniter_lang/compiler_orchestrator.rb
```

## C1 Summary

S3-R43-C1-I changed only:

```text
igniter-lang/lib/igniter_lang/compiler_orchestrator.rb
```

The public boundary now accepts:

```ruby
compiler_profile_source: nil
```

and passes that value unchanged to:

```ruby
Assembler#assemble_artifacts(..., compiler_profile_source:)
```

Nil remains `legacy_optional`: no profile source is derived, discovered,
defaulted, finalized, cached, or validated by the orchestrator.

## Regression Matrix

| # | Command / check | Purpose | Result |
| --- | --- | --- | --- |
| 1 | `ruby -c igniter-lang/lib/igniter_lang/compiler_orchestrator.rb` | Syntax check for changed orchestrator file | PASS |
| 2 | `ruby igniter-lang/experiments/prop036_orchestrator_profile_source_pass_through/prop036_orchestrator_profile_source_pass_through.rb` | New C1 proof: pass-through, invalid-source refusal, legacy nil behavior | PASS |
| 3 | `ruby igniter-lang/experiments/igapp_assembler_proof/igapp_assembler_proof.rb` | Existing assembler/runtime proof remains green | PASS |
| 4 | `ruby igniter-lang/experiments/production_compiler_cli/production_compiler_cli_proof.rb` | Narrow compile/orchestrator CLI/API smoke used by current Stage 3 proofs | PASS |
| 5 | Read `experiments/prop036_orchestrator_profile_source_pass_through/out/legacy_compile.igapp/manifest.json` | Confirm legacy nil-source compile omits `manifest.compiler_profile_id` | PASS |

## Exact Output

### 1. Orchestrator syntax

```text
Syntax OK
```

### 2. C1 pass-through proof

```text
Prop036OrchestratorProfileSourcePassThrough: PASS
  11/11 checks PASS
  PASS O1.legacy_compile_omits_field
  PASS O2.profiled_compile_emits_field
  PASS O3.profiled_hash_differs_from_legacy
  PASS O4.invalid_source_returns_assembler_refused
  PASS O5.refusal_includes_profile_source_reason
  PASS O6.no_loader_status_values
  PASS O7.no_runtime_authority
  PASS O8.no_golden_mutation
  PASS INV1.artifact_hash_format_valid
  PASS INV2.backward_compatible_nil_default
  PASS INV3.orchestrator_is_transport_only
Summary: experiments/prop036_orchestrator_profile_source_pass_through/out/prop036_orchestrator_profile_source_pass_through_summary.json
```

### 3. Assembler proof

```text
PASS igapp_assembler_proof
assembler.positive.add: ok
assembler.positive.claim_evidence: ok
assembler.positive.evidence_linked_alert: ok
assembler.negative.unresolved_symbol_refused: ok
assembler.negative.evidence_less_alert_refused: ok
assembler.negative.confidence_bool_refused: ok
assembler.deterministic_output: ok
assembler.no_legacy_semantic_ir_json: ok
runtime.load_direct_prop0191: ok
runtime.load_assembled_add: ok
runtime.evaluate_assembled_add: ok
runtime.evaluate_assembled_claim_evidence: ok
runtime.evaluate_assembled_evidence_linked_alert: ok
runtime.compatibility_report_trusted: ok
runtime.rejects_legacy_add: ok
runtime.rejects_stdlib_numeric_add: ok
runtime.rejects_unknown_stdlib_operator: ok
runtime.add.load_status: loaded
runtime.add.output_value: 42
runtime.add.compatibility_report_status: trusted
runtime.claim_evidence.load_status: loaded
runtime.claim_evidence.output_value: claim/synthetic/vendor-status
runtime.claim_evidence.compatibility_report_status: trusted
runtime.evidence_linked_alert.load_status: loaded
runtime.evidence_linked_alert.output_value: true
runtime.evidence_linked_alert.compatibility_report_status: trusted
out: experiments/igapp_assembler_proof/out
```

### 4. Production compiler CLI/API smoke

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

### 5. Legacy nil-source check

```text
legacy_manifest_has_compiler_profile_id=false
legacy_check=PASS
nil_default_check=PASS
```

## Decisions

[D] The orchestrator pass-through landed without regressing the existing
assembler proof.

[D] The current compile/orchestrator smoke remains green through the production
compiler CLI/API proof.

[D] Legacy nil-source compile remains unchanged: `manifest.compiler_profile_id`
is absent when `compiler_profile_source:` is omitted.

[D] Invalid profile source still refuses through `assembler_refused`; assembler
validation remains authoritative.

[D] No loader status, CompatibilityReport compiler-profile section, runtime
authority, dispatch migration, `.ilk` reference, signing, Ledger/TBackend, or
production behavior was added by this regression slice.

## Recommendation

Recommendation: ready for next Architect decision.

Suggested next decision should choose one bounded surface, not all at once:

- CLI/API exposure for supplying finalized `compiler_profile_source`;
- explicit golden migration list and expected hash churn;
- loader/report `compiler_profile_id` status implementation;
- CompatibilityReport compiler-profile section design.

## Handoff

```text
Card: S3-R43-C2-P1
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/prop036-post-orchestrator-regression-chain-v0
Status: done

[D] Decisions
- C1 pass-through proof is green on current HEAD.
- Existing assembler proof is green.
- Production compiler CLI/API smoke is green.
- Legacy nil-source compile remains unchanged: no `manifest.compiler_profile_id`.

[S] Signals
- `compiler_profile_source:` is transport-only in CompilerOrchestrator.
- Assembler remains the authoritative validation/refusal boundary.
- No loader/report/runtime/dispatch behavior was added.

[T] Tests / Proofs
- `ruby -c igniter-lang/lib/igniter_lang/compiler_orchestrator.rb` PASS.
- `ruby igniter-lang/experiments/prop036_orchestrator_profile_source_pass_through/prop036_orchestrator_profile_source_pass_through.rb` PASS.
- `ruby igniter-lang/experiments/igapp_assembler_proof/igapp_assembler_proof.rb` PASS.
- `ruby igniter-lang/experiments/production_compiler_cli/production_compiler_cli_proof.rb` PASS.
- Legacy manifest check PASS: `compiler_profile_id` absent.

[R] Recommendation
- Ready for next Architect decision.
- Keep the next scope narrow: CLI/API exposure, golden migration, loader/report status, or CompatibilityReport section.

[Files] Changed
- `igniter-lang/docs/tracks/prop036-post-orchestrator-regression-chain-v0.md`

[Q] Open Questions
- Which surface should receive the next authorization: CLI/API input, golden migration, loader/report status, or CompatibilityReport compiler-profile section?

[X] Rejected
- Broad-patching or changing compiler/runtime semantics during this regression slice.
- Treating nil source as a default profile.

[Next] Proposed next slice
- Architect decision for the next single PROP-036 surface.
```
