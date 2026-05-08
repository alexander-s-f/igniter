# Track: Typed Emission Main Path Parity v0

> [!IMPORTANT]
> Stale / superseded as current status. This track records the S3-R1 parity measurement, where the runner passed but the measured verdict was `blocked`.
> Current truth: `CompilerOrchestrator` switched to `emit_typed` in `orchestrator-emit-typed-switch-v0` (S3-R5-C4), after the governance decision in `typed-emission-stage2-switch-decision-v0` (S3-R4-C4).
> Do not treat the blocked verdict below as current Stage 3 state.

Card: S3-R1-C3-P
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `igniter-lang/typed-emission-main-path-parity-v0`
Status: blocked
Date: 2026-05-08

---

## Goal

Prove whether `CompilerOrchestrator` can switch from:

```text
SemanticIREmitter#emit(parsed_program, sample_input:)
```

to:

```text
SemanticIREmitter#emit_typed(typed_program)
```

without changing public SemanticIR/report behavior.

---

## Proof

New proof runner:

```text
ruby igniter-lang/experiments/typed_emission_main_path_parity/typed_emission_main_path_parity.rb
```

Output:

```text
igniter-lang/experiments/typed_emission_main_path_parity/typed_emission_main_path_parity.json
igniter-lang/experiments/typed_emission_main_path_parity/golden/typed_emission_main_path_parity.golden.json
```

Console result:

```text
PASS typed_emission_main_path_parity
verdict: blocked
safe_to_switch_production_path: false
cases_run: 5
package_facade_add: FAIL
invariant_valid: FAIL
olap_point: FAIL
stream_fold: FAIL
history_access: FAIL
sparkcrm_bihistory: NOT_COMPARABLE
ledger_tbackend_descriptor: NOT_COMPARABLE
blocked_items: 9
summary: igniter-lang/experiments/typed_emission_main_path_parity/typed_emission_main_path_parity.json
golden: igniter-lang/experiments/typed_emission_main_path_parity/golden/typed_emission_main_path_parity.golden.json
```

`PASS` here means the parity measurement ran successfully. The measured
verdict is `blocked`.

---

## Fixture Set

The proof uses the Stage 2 close-candidate fixture set where a source-level
comparison is available:

| Case | Surface | Source |
|------|---------|--------|
| `package_facade_add` | package facade | `experiments/source_to_semanticir_fixture/add.ig` |
| `invariant_valid` | invariant runtime observations | inline valid invariant source from `invariant_severity_proof` |
| `olap_point` | OLAPPoint | `experiments/olap_point_proof/revenue_point.ig` |
| `stream_fold` | stream fold | `experiments/stream_t_proof/stream_integer_window.ig` |
| `history_access` | History temporal access | `experiments/history_type_proof/history_integer_point_access.ig` |

Two close-candidate entries are recorded as not source-comparable:

| Case | Reason |
|------|--------|
| `sparkcrm_bihistory` | proof-local Ruby fixture; no `.ig` source fixture goes through parsed and typed emit paths |
| `ledger_tbackend_descriptor` | metadata-only TBackend descriptor evidence, not a SemanticIR emission source |

---

## Result

[D] `CompilerOrchestrator` should not switch to `emit_typed` in this slice.

Parity is not proven. The candidate typed path and current parsed path differ
on the minimal package facade source and diverge more sharply on Stage 2
surfaces.

---

## Deltas

### Add / Package Facade

Both paths emit `pass_result: ok` and produce a `compute` node.

After identity fields are normalized, SemanticIR still differs:

```text
$.contracts[0].nodes[0].expr.deps
$.contracts[0].nodes[0].expr.args[0].deps
$.contracts[0].nodes[0].expr.args[1].deps
```

Typed emission also uses typed identity prefixes:

```text
semanticir/typed/...
compilation_report/typed_...
```

The report shape is otherwise stable for Add after identity normalization.

### Invariant

Both paths emit `pass_result: ok`, but the source-driven typed pipeline does
not produce the expected `invariant_node` from the inline invariant source.

The Stage 2 invariant proof still proves `emit_typed` from a proof-local typed
program, but that is not the same as orchestrator source path parity.

### OLAPPoint

Parsed emission reports OOF diagnostics for the OLAP access source.

The typed path does not reach emission through the library classifier:

```text
KeyError: key not found: "kind"
```

This means the proof-local OLAP typed boundary is ahead of the current
source-to-typed library path.

### Stream Fold

The close-candidate stream source currently fails the library parser in this
parity harness:

```text
IgniterLang::ParseError: Expected name, got comma(,)
```

The stream proof remains green separately, but the exact close-candidate source
cannot yet be used as a main-path parsed/typed emission parity case.

### History Temporal Access

Both paths refuse the history source, but with different report shapes:

```text
parsed diagnostics: OOF-P1, OOF-TY0
typed diagnostics:  OOF-P1
parsed stages: classify=oof, typecheck=skipped
typed stages:  classify=ok,  typecheck=oof
```

Typed emission also misses the expected:

```text
temporal_access_node
```

The History/BiHistory close evidence remains proof-local rather than fully
library source-path integrated.

---

## Blocked List

[R] Before switching the orchestrator, resolve these in order:

1. Define a canonical typed-emission identity mode for the production path.
   It must decide whether public IDs remain `semanticir/<source_hash>` or move
   to `semanticir/typed/<typed_hash>`.
2. Normalize expression JSON shape for core compute nodes, especially nested
   `deps` fields under `expr` and `expr.args`.
3. Carry source-level invariant declarations through classifier/typechecker so
   `emit_typed` produces `invariant_node` from source, not only from proof-local
   typed programs.
4. Fix source-to-typed OLAP classifier handling for `dims_record` /
   `index_access` shapes.
5. Align the stream close-candidate source with the production parser, or add a
   source fixture that exercises the same `fold_stream` surface through the
   library parser.
6. Move History/BiHistory temporal access node construction into the library
   source-to-typed path.
7. Add a source-level BiHistory fixture if BiHistory is expected to be part of
   typed emission parity rather than proof-local runtime evidence only.

---

## No Production Switch

[D] No change was made to:

```text
igniter-lang/lib/igniter_lang/compiler_orchestrator.rb
```

The current production path remains:

```ruby
compilation = @emitter.emit(parsed, sample_input: resolved_sample_input)
```

This is intentional. The proof shows switching now would alter public JSON
shape and still would not cover all Stage 2 close-candidate surfaces through
the source-to-typed path.

---

## Handoff

```text
Card: S3-R1-C3-P
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/typed-emission-main-path-parity-v0
Status: blocked

[D] Decisions
- Do not switch CompilerOrchestrator to emit_typed yet.
- Treat emit_typed as proven for selected proof-local typed surfaces, not as
  source-to-typed main-path parity.
- Keep the current parsed emitter path until public JSON identity/shape and
  Stage 2 source-path gaps are resolved.

[S] Shipped / Signals
- Added a parity proof runner, JSON output, and stable golden comparison.
- Compared Add, invariant, OLAP, stream, and History close-candidate sources.
- Recorded SparkCRM BiHistory and Ledger descriptor as not source-comparable.
- Captured 9 blocked items in machine-readable proof output.

[T] Tests / Proofs
- ruby igniter-lang/experiments/typed_emission_main_path_parity/typed_emission_main_path_parity.rb -> PASS, verdict blocked
- ruby igniter-lang/experiments/stage2_close_candidate/stage2_close_candidate.rb -> PASS

[R] Risks / Recommendations
- A narrow orchestrator switch would be premature: even Add has SemanticIR shape
  deltas after identity normalization.
- The highest-value next slice is not the switch; it is typed emission canonical
  shape normalization plus source-level Stage 2 lowering gaps.

[Next] Suggested next slice
- `typed-emission-canonical-shape-v0`: decide production typed identity mode,
  normalize core compute JSON shape, then rerun this parity proof before
  touching CompilerOrchestrator.
```
