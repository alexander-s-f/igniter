# Orchestrator Emit Typed Switch v0

Card: S3-R5-C4-P
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/orchestrator-emit-typed-switch-v0
Status: done
Date: 2026-05-08

## Goal

Switch the `CompilerOrchestrator` production path from parsed SemanticIR
emission to typed SemanticIR emission.

Dependency accepted from S3-R5-C3:

```text
sparkcrm_bihistory no longer NOT_COMPARABLE
typed_source_blocked_items: 0
orchestrator_switch_gate: PROCEED
```

## Implementation Diff

[D] Production orchestration now emits from `TypedProgram`:

```ruby
classified = @classifier.classify(parsed, sample_input: resolved_sample_input)
typed = @typechecker.typecheck(classified)
compilation = @emitter.emit_typed(typed)
```

This replaces:

```ruby
compilation = @emitter.emit(parsed, sample_input: resolved_sample_input)
```

[D] `SemanticIREmitter#emit(parsed, sample_input:)` remains in place as the
Stage 1 legacy/internal comparison path. The typed parity harness still calls
both emitter APIs directly for comparison evidence.

[S] A tiny assembler compatibility guard was added for typed type shapes with
scalar params such as `Decimal[2]`:

```ruby
return type.to_s unless type.is_a?(Hash)
```

No parser, classifier, or typechecker edits were made in this switch slice.

## Parsed Baseline

Before updating switch evidence, the final parsed-path comparison baseline was
recorded at:

```text
igniter-lang/experiments/typed_emission_main_path_parity/parsed_path_baseline_before_orchestrator_emit_typed_switch.json
```

Baseline summary:

```text
safe_to_switch_production_path: false
typed_source_blocked_items: 0
legacy_parity_delta_items: 14
orchestrator_switch_gate: PROCEED
```

The baseline records that strict parsed-vs-typed parity stayed blocked because
the parsed Stage 1 path OOFs on Stage 2 surfaces that typed emission lowers.

## Public Behavior Delta

[D] Public `IgniterLang.compile` now follows:

```text
Parser -> Classifier -> TypeChecker -> emit_typed -> Assembler
```

This changes public behavior for Stage 2 source surfaces:

```text
Before: parsed emission could return OOF or no SemanticIR for valid Stage 2 surfaces.
After: typed emission lowers valid Stage 2 sources into SemanticIR nodes.
```

Direct public compile smoke after the switch:

```text
olap_valid:      ok -> olap_access_node
stream_valid:    ok -> stream_input_node, window_decl_node, fold_stream_node
history_valid:   ok -> temporal_input_node, temporal_access_node
bihistory_valid: ok -> temporal_input_node, temporal_access_node
```

The negative unresolved-symbol package fixture also moved later in the pipeline:

```text
Before: classify=oof, typecheck=skipped, category=classifier_oof
After:  classify=ok,  typecheck=oof,    category=typechecker_oof
```

That is the expected consequence of using the typed production path.

## Before / After Proof Table

| Proof | Before switch | After switch |
| --- | --- | --- |
| `typed_emission_main_path_parity` | PASS runner; `sparkcrm_bihistory` measured; strict verdict blocked | Baseline retained; switch gate accepted |
| `production_compiler_cli_proof` | PASS; negative category `classifier_oof` | PASS; negative category `typechecker_oof` |
| `stage1_close_candidate` | PASS | PASS |
| `stage2_close_candidate` | PASS | PASS |
| `release-gate` | PASS; local artifact built | PASS; local artifact rebuilt |

After release gate:

```text
artifact: /private/tmp/igniter_lang_release_gate/igniter_lang-0.1.0.pre.stage2.gem
checksum: /private/tmp/igniter_lang_release_gate/igniter_lang-0.1.0.pre.stage2.gem.sha256
sha256: e1ea1f3ae35aec24aa92b4b92f531f39d837f87019473a68e56e9c61d76a40b8
publish: not_attempted
```

## Proof Output

```text
ruby -c igniter-lang/lib/igniter_lang/compiler_orchestrator.rb
  -> Syntax OK

ruby -c igniter-lang/lib/igniter_lang/assembler.rb
  -> Syntax OK

ruby igniter-lang/experiments/production_compiler_cli/production_compiler_cli_proof.rb
  -> PASS production_compiler_cli_proof
  -> runtime.evaluate_add_42: ok
  -> negative.category: typechecker_oof

ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb
  -> PASS stage1_close_candidate

ruby igniter-lang/experiments/stage2_close_candidate/stage2_close_candidate.rb
  -> PASS stage2_close_candidate

igniter-lang/bin/release-gate
  -> PASS release_gate
  -> publish: not_attempted
```

## Updated Evidence

Intentional generated evidence updates:

```text
igniter-lang/experiments/production_compiler_cli/production_compiler_cli_summary.json
igniter-lang/experiments/production_compiler_cli/out/negative_unresolved_symbol.compilation_report.json
igniter-lang/experiments/stage2_close_candidate/stage2_close_candidate.json
igniter-lang/experiments/release_gate/release_gate.json
```

Existing generated `.igapp` output also reflects current assembler manifest
metadata:

```text
igniter-lang/experiments/production_compiler_cli/out/add.igapp/manifest.json
```

## Changed Files

```text
igniter-lang/docs/tracks/orchestrator-emit-typed-switch-v0.md
igniter-lang/lib/igniter_lang/compiler_orchestrator.rb
igniter-lang/lib/igniter_lang/assembler.rb
igniter-lang/experiments/typed_emission_main_path_parity/parsed_path_baseline_before_orchestrator_emit_typed_switch.json
igniter-lang/experiments/production_compiler_cli/production_compiler_cli_summary.json
igniter-lang/experiments/production_compiler_cli/out/negative_unresolved_symbol.compilation_report.json
igniter-lang/experiments/production_compiler_cli/out/add.igapp/manifest.json
igniter-lang/experiments/stage2_close_candidate/stage2_close_candidate.json
igniter-lang/experiments/release_gate/release_gate.json
```

## Handoff

```text
Card: S3-R5-C4-P
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/orchestrator-emit-typed-switch-v0
Status: done

[D] Decisions
- Switched `CompilerOrchestrator` production emission to `emit_typed(typed)`.
- Preserved `SemanticIREmitter#emit(parsed, sample_input:)` as the Stage 1 legacy/internal comparison path.
- Recorded the final parsed-path comparison baseline before the switch.
- Kept gem publish blocked; release gate stops at local artifact/checksum.

[S] Shipped / Signals
- Public compile now lowers valid Stage 2 typed-source surfaces instead of returning parsed-path OOF behavior.
- Negative unresolved symbol now reaches typechecker OOF, which is expected after the switch.
- Added assembler scalar type-param tolerance for `Decimal[2]` typed output assembly.

[T] Tests / Proofs
- `ruby -c igniter-lang/lib/igniter_lang/compiler_orchestrator.rb` -> Syntax OK
- `ruby -c igniter-lang/lib/igniter_lang/assembler.rb` -> Syntax OK
- `ruby igniter-lang/experiments/production_compiler_cli/production_compiler_cli_proof.rb` -> PASS
- `ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb` -> PASS
- `ruby igniter-lang/experiments/stage2_close_candidate/stage2_close_candidate.rb` -> PASS
- `igniter-lang/bin/release-gate` -> PASS, artifact/checksum built, publish not attempted

[R] Risks / Recommendations
- Strict parsed-vs-typed parity remains historically blocked by design; typed is now the production path for Stage 2+ lowering.
- Next status curation should update the compiler-internals scoreboard from `switch false` to `switched`.
- Keep parsed emitter tests for Stage 1 legacy comparison, not as a production gate.

[Next]
- Status/map curation: update Stage 3 scoreboard and switch-decision docs to reflect the landed typed orchestrator path.
```
