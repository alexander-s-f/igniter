# Track: Stream Parser/Classifier Boundary v0

Role: `[Igniter-Lang Compiler/Grammar Expert]`
Track: igniter-lang/stream-parser-classifier-boundary-v0
Card: S2-R5-C2-P
Status: done
Date: 2026-05-07
Depends on: S2-R4-C4-P (stream-t-proof-v0 — PASS)
Parallel note: Independent from temporal runtime work.

---

## Context

`stream_t_proof.rb` was PASS with hand-authored SemanticIR-like JSON.
Parser had no `stream` or `fold_stream` support. This track implements
minimal parser/classifier boundary for stream declarations, bounded windows,
and `fold_stream` with OOF-S1/S5 parse-time checking.

---

## Parser Changes Implemented

File: `igniter-lang/lib/igniter_lang/parser.rb`

### 1. New keywords

```diff
+ stream fold_stream
```

`stream` and `fold_stream` added to `KEYWORDS`. Both are body-position keywords.

### 2. `@` token in lexer

```diff
+ when "@" then advance; Token.new(:at, "@", l, c)
```

`@` added as `:at` token type, enabling `@window_bounded` and `@count_bounded(n)` bound annotations.

### 3. `parse_stream_decl`

```
stream <name>: <Type>
```

Emits:
```json
{
  "kind":              "stream",
  "name":              "readings",
  "type_annotation":   "Integer",
  "fragment_class":    "escape",
  "escape_capability": "stream_input"
}
```

**Classifier impact:** `fragment_class: "escape"` is set at parse time — no classifier logic change needed for stream node classification. Classifier should propagate ESCAPE to `fold_stream` node and mark its `result_fragment` as CORE when `bound` is present.

### 4. `parse_fold_stream_decl`

```
fold_stream <name> = <expr> @window_bounded
fold_stream <name> = <expr> @count_bounded(n)
```

- Parses expression (the `fold_stream(stream_ref, init, fn)` call) via standard `parse_expr`.
- Parses optional `@<annotation>` immediately after expression.
- **OOF-S1** (parse_error): no `@` annotation present → unbounded fold.
- **OOF-S1** (parse_error): unknown annotation name → also OOF-S1.
- **OOF-S5** (parse_error): `@count_bounded(n)` where `n` is not an int_lit.

Emits:
```json
{
  "kind":  "fold_stream",
  "name":  "total",
  "expr":  { "kind": "call", "fn": "fold_stream", "args": [...] },
  "bound": { "kind": "window_bounded" }
}
```

Or with count bound:
```json
{
  "bound": { "kind": "count_bounded", "n": 100 }
}
```

### 5. Body dispatcher entries

```ruby
when "stream"      then advance; parse_stream_decl
when "fold_stream" then advance; parse_fold_stream_decl
```

### 6. `parse_window_decl` — extended value parser

Previous `parse_lifecycle_or_symbol` only handled `:symbol` and `ident`.
Stream windows need `size: 3` (int_lit) and `period: 60` (float_lit) values.

Replaced with `parse_window_value`:
```ruby
def parse_window_value
  if peek_type?(:int_lit)    then advance.value
  elsif peek_type?(:float_lit) then advance.value
  elsif peek_type?(:symbol_lit) then advance.value
  else name_token!(%i[ident keyword])
  end
end
```

Also added `advance if peek_type?(:colon)` before value parsing — window options
use `key: val` with a colon separator.

### 7. `body_boundary_token?` updated

```ruby
%w[... stream fold_stream ...]
```

---

## Classifier Ownership (Specified, Not Yet Implemented)

| Node kind | Classification | Logic |
|-----------|---------------|-------|
| `stream` | ESCAPE | Set at parse time (fragment_class field) |
| `window` | N/A | Structural; no fragment class |
| `fold_stream` with bound | CORE (result) | Classifier sets result_fragment: "core" |
| `fold_stream` without bound | OOF-S1 | Already caught at parser; classifier skips |
| `fold_stream` with ESCAPE fn body | OOF-S3 | TypeChecker-owned (v0: not implemented) |

**[D] ESCAPE propagation rule:** Any `compute` node that references a `stream` directly (not via `fold_stream`) → OOF-S4. This is Classifier-owned, not parser-owned. Parser produces `fragment_class: "escape"` on stream nodes; classifier checks all compute `deps` for direct stream refs.

---

## OOF Ownership Table

```text
Rule    Trigger                                        Owner        Status
──────  ─────────────────────────────────────────────  ───────────  ────────────
OOF-S1  fold_stream without @window_bounded             PARSER       IMPLEMENTED
        or @count_bounded(n)
OOF-S2  stream decl without matching window decl       CLASSIFIER   SPECIFIED
        (requires cross-declaration analysis)
OOF-S3  ESCAPE construct inside fold_stream fn body    TypeChecker  DEFERRED
OOF-S4  stream value used outside fold_stream          CLASSIFIER   SPECIFIED
OOF-S5  @count_bounded(n) where n not int_lit          PARSER       IMPLEMENTED
```

---

## Classifier Changes Required (Next Slice)

For a Research Agent implementing classifier ESCAPE propagation for streams:

```text
SC-1: Detect fold_stream nodes; if bound present, set result_fragment: "core".
SC-2: Detect compute nodes that take stream ref in deps directly (no fold_stream).
      Emit OOF-S4.
SC-3: Detect stream declarations without any matching window label.
      Emit OOF-S2.
```

These are scope-deferred from this card per the parallel-note constraint.

---

## Parsed Source Example (Now Parseable)

```text
contract SensorAggregation {
  input device_id: String
  escape stream_input
  stream readings: Integer
  window "integer/{device_id}" {
    kind: :count
    size: 3
    on_close: :snapshot
  }
  fold_stream total = fold_stream(readings, 0, acc -> acc + val) @window_bounded
  output result: Integer lifecycle :durable
}
```

Parses to:
- `stream readings` → `{ kind: "stream", fragment_class: "escape", escape_capability: "stream_input" }`
- `window "..."` → `{ kind: "window", options: { kind: "count", size: 3, on_close: "snapshot" } }`
- `fold_stream total` → `{ kind: "fold_stream", bound: { kind: "window_bounded" } }`

---

## Verification Results

```text
ruby experiments/stream_t_proof/stream_t_proof.rb
  -> PASS stream_t_proof (13/13 checks)

ruby experiments/stage1_close_candidate/stage1_close_candidate.rb
  -> PASS (classifier/typechecker/semanticir/stdlib_kernel/igapp_assembler)

bundle exec rspec spec/igniter/parser_acceptance_spec.rb
  -> 61 examples, 0 failures
```

---

## Handoff

```text
[Igniter-Lang Compiler/Grammar Expert]
Card: S2-R5-C2-P
Track: igniter-lang/stream-parser-classifier-boundary-v0
Status: done

[D] Decisions:
- Parser implements: stream decl, fold_stream decl, @window_bounded/@count_bounded(n)
  bound annotation, OOF-S1 (unbounded fold), OOF-S5 (non-literal count).
- fragment_class: "escape" and escape_capability: "stream_input" are set at parse time
  on stream nodes. No classifier change needed for stream ESCAPE marking.
- Classifier is responsible for OOF-S2 (missing window) and OOF-S4 (direct stream use).
- TypeChecker is responsible for OOF-S3 (ESCAPE inside fold fn body).
- parse_window_decl extended: colon-separated key-value with int_lit support.
  This is backward-compatible (existing window uses :symbol values, now int_lit also works).
- @ is now a lexed :at token (new). No existing tests broken.
- body_boundary_token? updated with stream and fold_stream.

[S] Signals:
- stream T and fold_stream are now parse-accepted with structural validation.
- OOF-S1 fires at parse time for unbounded folds — early, clear diagnostic.
- stream_t_proof.rb was hand-authored; parser output is structurally compatible
  with the hand-authored SemanticIR-like JSON in the proof.

[T] stream_t_proof.rb: PASS. stage1_close_candidate.rb: PASS. 61 specs, 0 failures.

[R] Research Agent: Classifier ESCAPE propagation for streams needs SC-1..SC-3.
  SC-2 (OOF-S4) is the highest priority — prevents silent stream misuse.
  SC-3 (OOF-S3, TypeChecker) can follow after classifier is stable.

[Files] Changed:
- igniter-lang/lib/igniter_lang/parser.rb [MODIFIED]
  + stream/fold_stream keywords
  + @ :at token in lexer
  + parse_stream_decl
  + parse_fold_stream_decl (OOF-S1/S5)
  + parse_window_value helper (int_lit/float_lit support)
  + body_boundary_token? updated
- igniter-lang/docs/tracks/stream-parser-classifier-boundary-v0.md [NEW]
- igniter-lang/docs/agent-motion.md [updated]

[Next]:
- Classifier: SC-1..SC-3 (OOF-S2/S4 ESCAPE propagation).
- TypeChecker: OOF-S3 (ESCAPE inside fold fn body) — after classifier stable.
```
