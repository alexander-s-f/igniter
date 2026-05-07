# Track: Stream OOF-S2 Classifier v0

Role: `[Igniter-Lang Compiler/Grammar Expert]`
Track: igniter-lang/stream-oof-s2-classifier-v0
Card: S2-R7-C2-P
Status: done
Date: 2026-05-07
Depends on: S2-R6-C2-P

---

## Context

S2-R6-C2-P landed stream classifier SC-1/2/3:

- `stream` ingress is ESCAPE.
- direct stream access in `compute` emits `OOF-S4`.
- bounded `fold_stream` result is CORE.

This slice adds the next small classifier-owned stream OOF: `OOF-S2` for a
stream fold that has no declared contract window. It deliberately does not
inspect accumulator lambda bodies and does not implement `OOF-S3`.

---

## Decision

[D] `OOF-S2` now fires at classifier boundary when:

```text
fold_stream(...) consumes a known stream symbol
AND
the enclosing contract has no window declaration
```

Diagnostic:

```text
OOF-S2: stream '<name>' has no window - every stream must declare a window
```

The diagnostic is attached to the stream symbol, not the fold node, because
PROP-023 defines the missing-window rule as a stream declaration obligation.

[D] Existing SC-1/2/3 behavior is preserved:

- `stream_ingress_escape` remains `escape`.
- `stream_fold_core` remains `escape` with the fold declaration classified
  `core`.
- `negative_stream_direct_use` still emits only `OOF-S4`; direct access remains
  the targeted classifier violation for that fixture.

[D] The current parser AST has `window` declarations but no explicit
`stream.window_ref` or `fold_stream.window_ref`. Therefore this slice proves the
classifier-level missing-window guard as "no declared window exists". Per-stream
window matching should wait until the grammar/type boundary carries an explicit
window reference.

---

## Implementation

`IgniterLang::Classifier` now collects:

- contract-local `window` declarations
- stream symbols consumed by `fold_stream`

After body classification, it appends one deterministic `OOF-S2` diagnostic per
fold-consumed stream when the contract has no window declaration.

New targeted classifier proof case:

```text
negative_stream_missing_window
  stream readings: Integer
  fold_stream total = fold_stream(readings, 0, fn) @window_bounded
  # no window declaration
  -> OOF-S2
```

---

## Verification

```text
ruby igniter-lang/experiments/stream_t_proof/stream_t_proof.rb
  -> PASS stream_t_proof

ruby igniter-lang/experiments/classifier_pass_proof/classifier_pass_proof.rb --check-golden
  -> PASS classifier_pass_golden_check
  -> stream.oof_s2_missing_window: ok

ruby igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb --check-golden
  -> PASS source_to_semanticir_fixture_golden_check

ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb
  -> PASS stage1_close_candidate
```

---

## Not Implemented

[X] `OOF-S3` is not implemented here.

Reason: `OOF-S3` requires inspecting the accumulator function body for ESCAPE
constructs. That belongs after the TypeChecker boundary is stable, per card
instruction.

[X] Parser syntax was not changed.

[Q] Future boundary question: should the parser or TypeChecker introduce an
explicit `window_ref` on `stream`/`fold_stream` so classifier diagnostics can
prove per-stream window matching instead of only no-window absence?

---

## Handoff

```text
Card: S2-R7-C2-P
[Igniter-Lang Compiler/Grammar Expert]
Track: igniter-lang/stream-oof-s2-classifier-v0
Status: done

[D] Decisions:
- OOF-S2 implemented at classifier boundary for fold_stream consuming a stream
  when the contract has no window declaration.
- Existing SC-1/2/3 behavior preserved.
- No parser syntax changes.
- OOF-S3 remains TypeChecker-owned and unimplemented.

[S] Shipped / Signals:
- Added negative_stream_missing_window classifier proof case.
- Added deterministic OOF-S2 diagnostic attached to the stream symbol.
- source_to_semanticir golden AST count updated to include the classifier-only
  parsed fixture.

[T] Tests / Proofs:
- stream_t_proof: PASS.
- classifier_pass_proof --check-golden: PASS.
- source_to_semanticir_fixture --check-golden: PASS.
- stage1_close_candidate: PASS.

[R] Risks / Recommendations:
- Current AST lacks explicit window_ref, so this slice proves absence of any
  window declaration, not per-stream window identity matching.
- Keep OOF-S3 as the next TypeChecker-owned stream gap.

[Next] Suggested next slice:
- stream-oof-s3-typechecker-v0 after TypeChecker boundary stabilization.
```

## Files Changed

```text
igniter-lang/lib/igniter_lang/classifier.rb
igniter-lang/experiments/classifier_pass_proof/classifier_pass_proof.rb
igniter-lang/experiments/classifier_pass_proof/golden/negative_stream_missing_window.classified.json
igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb
igniter-lang/experiments/source_to_semanticir_fixture/golden/negative_stream_missing_window.parsed_ast.json
igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.json
igniter-lang/docs/tracks/stream-oof-s2-classifier-v0.md
```
