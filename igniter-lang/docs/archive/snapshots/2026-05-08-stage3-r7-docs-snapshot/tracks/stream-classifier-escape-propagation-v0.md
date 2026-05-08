# Track: Stream Classifier ESCAPE Propagation v0

Role: `[Igniter-Lang Compiler/Grammar Expert]`
Track: igniter-lang/stream-classifier-escape-propagation-v0
Card: S2-R6-C2-P
Status: done
Date: 2026-05-07
Depends on: S2-R5-C2-P (stream-parser-classifier-boundary-v0 — done)

---

## Context

After S2-R5-C2-P, the parser stamped `fragment_class: "escape"` on `stream` nodes.
The classifier silently dropped `stream`, `fold_stream`, `escape`, `read`, and `window`
nodes — causing downstream OOF-P1 for any `compute` that referenced those symbols.
This track implements SC-1..3 inside the classifier proof and adds 3 targeted cases.

---

## SC Rules Implemented

### SC-1: Stream ingress is ESCAPE

```ruby
when "stream"
  symbol_fragments[node.fetch("name")] = "escape"
  symbol_kinds[node.fetch("name")]     = "stream"
  declarations << classified_decl(node, "escape", [], [])
```

Stream nodes are registered in `symbol_fragments` with `"escape"` and in
`symbol_kinds` with `"stream"`. Downstream checks use `symbol_kinds` to
distinguish stream refs from other ESCAPE refs.

### SC-2: Direct stream use in compute → OOF-S4

```ruby
stream_deps = deps.select { |dep| symbol_kinds[dep] == "stream" }
stream_deps.each do |stream_name|
  diagnostics << oof("OOF-S4", "Direct use of stream '#{stream_name}' is OOF — use fold_stream instead", ...)
end
fragment = missing.empty? && stream_deps.empty? && !upstream_oof ? "core" : "oof"
```

A `compute` node that takes a `stream` symbol directly (not via `fold_stream`) emits
`OOF-S4` and is classified `"oof"`. `fold_stream` args referencing stream symbols are
exempt because the fold boundary is explicit.

### SC-3: Bounded `fold_stream` result is CORE

```ruby
when "fold_stream"
  bound = node.fetch("bound", nil)
  result_fragment = bound ? "core" : "oof"
  symbol_fragments[node.fetch("name")] = result_fragment
  symbol_kinds[node.fetch("name")] = "fold_stream"
  declarations << classified_decl(node, result_fragment, deps, [])
```

A `fold_stream` with a `bound` field (present when parser saw `@window_bounded`
or `@count_bounded(n)`) produces a CORE result. Without a bound (OOF-S1 already
fired at parse time), result is `"oof"`.

---

## Other Node Handlers Added to Classifier

These were silently dropped before — causing ghost OOF-P1 for downstream compute:

| Node kind | Classifier action | Fragment |
|-----------|------------------|---------|
| `escape` | registered as structural boundary | `"escape"` |
| `read` | registered in symbol_fragments | `"escape"` |
| `window` | structural only; uses `label` as name | `"escape"` |

---

## Contract Fragment Logic Extended

The contract-level fragment had two states: `"core"` or `"oof"`. A contract with
stream/escape nodes is valid but not fully CORE:

```ruby
contract_fragment = if !diagnostics.empty?
  "oof"
elsif declarations.all? { |decl| decl.fetch("fragment_class") == "core" }
  "core"
elsif has_escape  # any escape/stream/read/fold_stream decl present
  "escape"
else
  "oof"
end
```

**[D] Three-way contract fragment:** `"core"` | `"escape"` | `"oof"`.
A contract with ESCAPE nodes but no OOF diagnostics is classified `"escape"` —
meaning it is valid but requires the RuntimeMachine ESCAPE capability handler.

---

## New Classifier CASES and Checks

3 new CASES added (9 total):

```text
stream_ingress_escape       -> expected_fragment: "escape"  (SC-1)
stream_fold_core            -> expected_fragment: "escape"  (SC-3 fold CORE inside escape contract)
negative_stream_direct_use  -> expected_fragment: "oof"     (SC-2, OOF-S4)
```

3 new checks:

```text
stream.sc1_ingress_escape   -> stream node fragment_class == "escape"
stream.sc2_direct_use_oof_s4 -> OOF-S4 in oof_log
stream.sc3_fold_result_core  -> fold_stream node fragment_class == "core"
```

Total classifier proof checks: 16 (was 11).

---

## Fixture Files Created

3 new parsed AST fixtures in `source_to_semanticir_fixture/golden/`:

```text
stream_ingress_escape.parsed_ast.json
stream_fold_core.parsed_ast.json
negative_stream_direct_use.parsed_ast.json
```

Generated via live parser from `.ig` source (no hand-authoring).

`source_to_semanticir_fixture.rb` golden AST count updated: 6 → 9.

---

## Verification Results

```text
ruby classifier_pass_proof/classifier_pass_proof.rb
  -> PASS classifier_pass_proof (16/16 checks)

ruby source_to_semanticir_fixture/source_to_semanticir_fixture.rb --check-golden
  -> PASS source_to_semanticir_fixture_golden_check

ruby stream_t_proof/stream_t_proof.rb
  -> PASS stream_t_proof (13 checks)

ruby stage1_close_candidate/stage1_close_candidate.rb
  -> PASS stage1_close_candidate (classifier/typechecker/semanticir/stdlib_kernel/igapp_assembler)

bundle exec rspec spec/igniter/parser_acceptance_spec.rb
  -> 61 examples, 0 failures
```

---

## Still Proof-Local / Not Implemented

```text
OOF-S3: ESCAPE inside fold_stream accumulator fn body
         -> TypeChecker-owned; deferred. fold_stream fn body is parsed but
            not inspected for fragment class violations.
OOF-S2: stream decl without matching window
         -> Classifier could cross-reference stream.window_ref vs window.label;
            deferred to a follow-up slice.
```

---

## Handoff

```text
[Igniter-Lang Compiler/Grammar Expert]
Card: S2-R6-C2-P
Track: igniter-lang/stream-classifier-escape-propagation-v0
Status: done

[D] Decisions:
- SC-1/2/3 implemented in classifier_pass_proof.rb.
- symbol_kinds["name"] = "stream" used as discriminator for OOF-S4 detection.
- Contract fragment extended to three-way: core | escape | oof.
  escape = valid contract with ESCAPE boundary nodes but no OOF diagnostics.
- escape/read/window nodes now handled (were silently dropped before).
- 3 new parsed AST fixtures generated via live parser (not hand-authored).
- source_to_semanticir_fixture golden AST count updated 6 -> 9.
- OOF-S2 and OOF-S3 deferred; clearly noted as proof-local gaps.

[S] Signals:
- Classifier now has sound stream ESCAPE propagation.
- OOF-S4 fires at classify time for any compute node directly referencing a stream.
- fold_stream with bound is registered as CORE result - usable by output nodes.
- Three-way contract fragment (core/escape/oof) is a stable semantic.

[T] classifier_pass_proof: PASS (16/16).
    source_to_semanticir_fixture --check-golden: PASS.
    stream_t_proof: PASS.
    stage1_close_candidate: PASS.
    parser_acceptance_spec: 61/61.

[R] Research Agent:
  - OOF-S2 (missing window): classifier cross-ref stream.window_ref vs window.label.
    Small and bounded; can follow.
  - OOF-S3 (ESCAPE in fold fn body): TypeChecker slice; after classifier stable.
  - Contract fragment three-way model should be reflected in ClassifiedProgram
    type annotation when TypedProgram boundary is formalized.

[Files] Changed:
- igniter-lang/experiments/classifier_pass_proof/classifier_pass_proof.rb [MODIFIED]
  + SC-1/2/3 node handlers (stream, escape, read, window, fold_stream)
  + OOF-S4 in compute handler
  + 3-way contract_fragment logic
  + 3 new CASES + 5 new build_checks + 2 new helper methods
- igniter-lang/experiments/source_to_semanticir_fixture/golden/
  stream_ingress_escape.parsed_ast.json [NEW]
  stream_fold_core.parsed_ast.json [NEW]
  negative_stream_direct_use.parsed_ast.json [NEW]
- igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb
  golden AST count 6 -> 9 [MODIFIED]
- igniter-lang/docs/tracks/stream-classifier-escape-propagation-v0.md [NEW]
- igniter-lang/docs/agent-motion.md [updated]

[Next]:
- OOF-S2 (missing window) classifier slice — small, bounded.
- OOF-S3 (ESCAPE in fold fn) TypeChecker slice.
- Three-way contract fragment model → TypedProgram boundary formalization.
```
