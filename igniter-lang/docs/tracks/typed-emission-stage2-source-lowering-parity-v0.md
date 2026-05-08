# Track: Typed Emission Stage 2 Source Lowering Parity v0

Card: S3-R3-C1-P
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `igniter-lang/typed-emission-stage2-source-lowering-parity-v0`
Status: done
Date: 2026-05-08

---

## Goal

Reduce the remaining `emit_typed` source-path blockers before
`CompilerOrchestrator` can safely switch from parsed emission to typed emission.

This slice does not switch `CompilerOrchestrator` to `emit_typed`.

Affected neighbor roles:

- Compiler/Grammar Expert
- Bridge Agent

---

## Current Horizon

Igniter-Lang remains an Epistemic Contract Language: contracts + explicit time +
observation evidence compiled toward RuntimeMachine-compatible artifacts.

Stage 1 remains closed through proof orchestration. Stage 2 proof surfaces now
exercise invariant severity, stream, OLAPPoint, History/BiHistory, and package
facade boundaries.

Typed emission is the desired production direction, but it must preserve public
artifact shape and behavior before the orchestrator main path switches.

---

## Decisions

[D] Keep production path on parsed emission for now.

[D] Treat typed source blockers separately from legacy parity deltas. The typed
path can now lower the priority Stage 2 source fixtures, but parsed legacy
emission still lacks equivalent Stage 2 nodes or rejects some Stage 2 source
surfaces.

[D] Preserve parsed legacy `source_to_semanticir_fixture` goldens. This slice
does not introduce a canonical delta to Stage 1 parsed SemanticIR goldens.

[D] Use parser-compatible inline source for the stream parity case. The original
stream proof file remains richer than the parser surface and is still covered by
the dedicated `stream_t_proof`.

---

## Before / After Blocker Table

| Case | Before | After |
| --- | --- | --- |
| `package_facade_add` | PASS after S3-R2 | PASS |
| `invariant_valid` | `typed_expected_nodes_missing` | Typed path emits `invariant_node`; still legacy `semantic_ir_shape_delta` and `report_shape_delta` |
| `olap_point` | `typed_path_error` | Typed path emits `olap_access_node`; parsed legacy path still OOFs |
| `stream_fold` | `parse_exception` | Typed path emits `stream_input_node`, `window_decl_node`, `fold_stream_node`; parsed legacy path still OOFs |
| `history_access` | `report_shape_delta` + `typed_expected_nodes_missing` | Typed path emits `temporal_input_node` and `temporal_access_node`; parsed legacy path still OOFs |
| `sparkcrm_bihistory` | `not_source_comparable` | unchanged: proof-local Ruby fixture has no `.ig` source fixture |
| `ledger_tbackend_descriptor` | `not_source_comparable` | unchanged: metadata descriptor, not a SemanticIR emission source |

Summary from the parity proof:

```text
PASS typed_emission_main_path_parity
verdict: blocked
safe_to_switch_production_path: false
cases_run: 5
package_facade_add: PASS
invariant_valid: FAIL
olap_point: FAIL
stream_fold: FAIL
history_access: FAIL
sparkcrm_bihistory: NOT_COMPARABLE
ledger_tbackend_descriptor: NOT_COMPARABLE
blocked_items: 13
typed_source_blocked_items: 0
legacy_parity_delta_items: 11
```

Interpretation:

- `typed_source_blocked_items: 0` means the prioritized Stage 2 typed source
  lowering blockers were removed.
- `legacy_parity_delta_items: 11` means the current parsed emission path still
  differs from typed emission for Stage 2 surfaces.
- `safe_to_switch_production_path: false` remains the correct verdict.

---

## Implementation Notes

[S] Classifier:

- Preserves structured generic `type_annotation` for temporal declarations
  instead of collapsing `History[String]` / `BiHistory[String]` to constructor
  names only.
- Seeds parsed `olap_point` declarations as ESCAPE symbols for source-path
  classification.
- Classifies invariant declarations syntactically and checks their predicate
  references.
- Does not treat call function names such as `fold_stream` or `history_at` as
  data dependency refs.

[S] Parser:

- Accepts stream fold bound annotations on `compute` declarations when the
  expression is `fold_stream(...) @window_bounded` or `@count_bounded(n)`.
- Accepts comma-separated window options in the parser-compatible stream parity
  fixture.

[S] TypeChecker:

- Carries `window` declarations as typed `Window`.
- Adds temporal access semantic-node evidence to accepted
  `history_at` / `bihistory_at` expressions so typed emission can lower
  `temporal_access_node`.

[S] Parity harness:

- Reports `typed_source_blocked_items` separately from legacy parity deltas.
- Uses source-shaped OLAP and stream fixtures that exercise the extracted
  parser/classifier/typechecker/typed-emitter path.

---

## Proofs

```text
ruby igniter-lang/experiments/typed_emission_main_path_parity/typed_emission_main_path_parity.rb
```

PASS, verdict blocked, `typed_source_blocked_items: 0`.

```text
ruby igniter-lang/experiments/classifier_pass_proof/classifier_pass_proof.rb --check-golden
ruby igniter-lang/experiments/typechecker_proof/typechecker_proof.rb --check-golden
```

PASS after updating canonical classifier/typechecker goldens for structured
temporal type refs and temporal semantic-node evidence.

```text
ruby igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb --check-golden
ruby igniter-lang/experiments/production_compiler_cli/production_compiler_cli_proof.rb
ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb
ruby igniter-lang/experiments/stage2_close_candidate/stage2_close_candidate.rb
```

PASS.

---

## Verdict

[D] Improved, still blocked.

The typed path now proves Stage 2 source lowering for the prioritized surfaces:

- invariant severity
- OLAPPoint access
- stream fold with bounded window
- History point access

But the production path is not safe to switch because the current parsed legacy
emitter still diverges from typed emission for those Stage 2 surfaces, and
SparkCRM BiHistory / ledger descriptor remain non-source-comparable.

```text
safe_to_switch_production_path: false
```

---

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/typed-emission-stage2-source-lowering-parity-v0
Status: done
Neighbors: Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- Do not switch CompilerOrchestrator to emit_typed.
- Separate typed source blockers from legacy parity deltas.
- Keep parsed legacy source_to_semanticir goldens stable.

[R] Recommendations:
- Next slice should decide whether parsed legacy Stage 2 emission is deprecated
  behind typed emission or must be brought to parity before switching.
- Compiler/Grammar should replace inline stream parity source with the richer
  stream proof source once aliases/object output syntax is parser-owned.

[S] Signals:
- typed_source_blocked_items dropped to 0.
- legacy_parity_delta_items remains 11.
- safe_to_switch_production_path remains false.

[T] Tests / Proofs:
- ruby igniter-lang/experiments/typed_emission_main_path_parity/typed_emission_main_path_parity.rb -> PASS, verdict blocked
- ruby igniter-lang/experiments/classifier_pass_proof/classifier_pass_proof.rb --check-golden -> PASS
- ruby igniter-lang/experiments/typechecker_proof/typechecker_proof.rb --check-golden -> PASS
- ruby igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb --check-golden -> PASS
- ruby igniter-lang/experiments/production_compiler_cli/production_compiler_cli_proof.rb -> PASS
- ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb -> PASS
- ruby igniter-lang/experiments/stage2_close_candidate/stage2_close_candidate.rb -> PASS

[Files] Changed:
- igniter-lang/lib/igniter_lang/classifier.rb
- igniter-lang/lib/igniter_lang/parser.rb
- igniter-lang/lib/igniter_lang/typechecker.rb
- igniter-lang/experiments/typed_emission_main_path_parity/typed_emission_main_path_parity.rb
- igniter-lang/experiments/typed_emission_main_path_parity/typed_emission_main_path_parity.json
- igniter-lang/experiments/typed_emission_main_path_parity/golden/typed_emission_main_path_parity.golden.json
- igniter-lang/experiments/classifier_pass_proof/golden/*.classified.json (stream/temporal deltas only)
- igniter-lang/experiments/typechecker_proof/golden/*.typed.json (temporal/window deltas only)
- igniter-lang/docs/tracks/typed-emission-stage2-source-lowering-parity-v0.md

[Q] Open Questions:
- Should parsed legacy Stage 2 emission be kept in parity, or should typed
  emission become the sole Stage 2 lowering path after a governance decision?

[X] Rejected:
- Switching CompilerOrchestrator in this slice.
- Building a broader Stage 2 parser grammar for stream aliases/object outputs.

[Next] Proposed next slice:
- typed-emission-stage2-switch-decision-v0: make the governance call on
  deprecating parsed Stage 2 emission versus requiring full legacy parity.
```
