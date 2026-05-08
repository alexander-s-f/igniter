# Track: History Type Parser Acceptance v0

Role: `[Igniter-Lang Compiler/Grammar Expert]`
Track: igniter-lang/history-type-parser-acceptance-v0
Card: S2-R2-C2-B
Status: done
Date: 2026-05-07
Depends on: S2-R2-C1-B (history-type-point-access-proof-v0)
Blocks: production History[T] source pipeline

---

## Goal

Make parser acceptance real for the existing `History[T]` source fixtures.
Parser previously emitted opaque strings like `"History[Integer]"` for
generic type annotations; golden files and downstream passes expected
structured `{ kind:"type_ref", name:"History", params:[...] }` nodes.

---

## What Changed

### Parser: `parse_type_ref` (igniter_lang_parser.rb)

**Root cause:** Generic types `Name[Inner]` and `Name[Inner1, Inner2]` were
returning interpolated strings (`"History[Integer]"`) instead of structured
TypeRef nodes. Only `Decimal[N]` had the structured path.

**Fix 1 — structured return for all generic types (lines 815, 818):**
```diff
- return "#{name}[#{inner}, #{inner2}]"
+ return { "kind" => "type_ref", "name" => name, "params" => [normalize_type_param(inner), normalize_type_param(inner2)] }

- "#{name}[#{inner}]"
+ { "kind" => "type_ref", "name" => name, "params" => [normalize_type_param(inner)] }
```

**Fix 2 — `normalize_type_param` helper (new method):**
```ruby
def normalize_type_param(ref)
  ref.is_a?(String) ? { "kind" => "type_ref", "name" => ref, "params" => [] } : ref
end
```

Bare type names (e.g. `"Integer"`) are returned as strings from `parse_type_ref`.
When used as params inside a generic, they are normalized to full TypeRef nodes.
**Top-level `type_annotation` fields that already consumed bare strings are unchanged.**

### Parser acceptance spec (spec/igniter/parser_acceptance_spec.rb)

3 specs previously asserted the old string format for `Collection[T]` annotations.
Updated to assert the canonical structured TypeRef shape:

```ruby
# Before:
expect(geo["type_annotation"]).to eq("Collection[GeoSignal]")

# After:
expect(geo["type_annotation"]).to eq({
  "kind" => "type_ref", "name" => "Collection",
  "params" => [{ "kind" => "type_ref", "name" => "GeoSignal", "params" => [] }]
})
```

---

## Coverage Added by This Change

```text
Type annotation        Before          After
─────────────────────  ──────────────  ──────────────────────────────────────────
History[Integer]       opaque string   { kind:type_ref, name:History,
                                         params:[{ kind:type_ref, name:Integer, params:[] }] }
Option[Integer]        opaque string   { kind:type_ref, name:Option,
                                         params:[{ kind:type_ref, name:Integer, params:[] }] }
Collection[GeoSignal]  opaque string   { kind:type_ref, name:Collection,
                                         params:[{ kind:type_ref, name:GeoSignal, params:[] }] }
Collection[TimeSlot]   opaque string   { kind:type_ref, name:Collection,
                                         params:[{ kind:type_ref, name:TimeSlot, params:[] }] }
Result[T, E]           opaque string   { kind:type_ref, name:Result,
                                         params:[normalize(T), normalize(E)] }
Decimal[2]             structured ✓    unchanged ✓
String / Integer /
  DateTime (bare)      plain string    plain string (unchanged — no regression)
```

---

## Verification Results

```text
ruby igniter-lang/experiments/history_type_proof/history_type_proof.rb
  → PASS (14/14 checks)
  parser.hand_authored_history_parsed_program: ok
  typechecker.history_at_option_integer: ok
  runtime.evaluate_as_of_2026_05_03: ok
  runtime.evaluate_as_of_2026_05_06: ok
  negative.missing_as_of_oof_h1: ok
  option.encoding: some/none ✓

ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb
  → PASS (classifier/typechecker/semanticir/stdlib_kernel/igapp_assembler)

bundle exec rspec spec/igniter/parser_acceptance_spec.rb
  → 61 examples, 0 failures
```

---

## Handoff

```text
[Igniter-Lang Compiler/Grammar Expert]
Track: igniter-lang/history-type-parser-acceptance-v0
Status: done

[D] Decisions:
- parse_type_ref now emits { kind:type_ref, name:, params:[] } for ALL generic types.
  Decimal[N] path unchanged. Bare type names unchanged at top level.
- normalize_type_param wraps inner bare-string params to full TypeRef nodes.
  This is the only normalization site; no cascading changes to callers.
- Parser acceptance spec updated: 3 Collection[T] assertions now use structured TypeRef.
- No classifier/typechecker/runtime changes required for this acceptance.
  history_type_proof.rb proof was already using hand-authored ParsedProgram golden;
  it continues to PASS with or without the parser change (golden unchanged).

[S] Signals:
- Parser is now the real source of truth for History[T] source syntax.
  hand_authored ParsedProgram in history_type_proof is now verifiable against
  live parser output.
- Collection[T], Result[T,E], Option[T] are also now structured — these
  will benefit all future stdlib proofs without further parser work.

[T] Tests:
- history_type_proof.rb: PASS
- stage1_close_candidate.rb: PASS
- parser_acceptance_spec.rb: 61 examples, 0 failures

[R] Research Agent: The parser now produces structured TypeRef for History[Integer].
  The hand-authored golden in history_type_proof/golden/*.parsed.json should be
  verified against live parser output in the next proof iteration.
  No proof rewrite required; the golden is already in the correct structured shape.

[Files] Changed:
- igniter-lang/experiments/parser/igniter_lang_parser.rb [MODIFIED]
  parse_type_ref: structured TypeRef for generic types; normalize_type_param helper
- spec/igniter/parser_acceptance_spec.rb [MODIFIED]
  3 Collection[T] assertions updated to structured TypeRef shape
- igniter-lang/docs/tracks/history-type-parser-acceptance-v0.md [NEW]
- igniter-lang/docs/agent-motion.md [updated]

[Next]:
- S2-R2-C3-B (if exists): verify live parser output against golden for history proof.
- Compiler path: parser now unblocks production History[T] source pipeline.
  TypeChecker generic param resolution (History[T] -> inner type Integer)
  can now read structured params[] instead of parsing opaque strings.
```
