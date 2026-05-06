# Track: Decimal Grammar v0

Role: `[Igniter-Lang Compiler/Grammar Expert]`
Track: igniter-lang/decimal-grammar-v0
Status: done
Date: 2026-05-06
Depends on: PROP-014, PROP-015, decimal-idempotency-retention-formalization-v0
Output budget: ~280 lines

---

## Neighbors Affected

- `[Igniter-Lang Research Agent]` — parser fixture in §Part 4; expected JSON in §Part 5.

---

## Part 1: Type Annotation Shape

### Decision: `Decimal[N]` compact form

**[D] The type annotation uses a single positional integer parameter, not a keyword pair.**

```text
-- Source form:
Decimal[2]    -- scale 2 (two decimal places)
Decimal[4]    -- scale 4
Decimal[0]    -- integer-valued Decimal (no fractional part)

-- NOT accepted:
Decimal        -- OOF-DM5: missing scale (compile error)
Decimal[scale: 2]  -- OOF-DM6: keyword params in type annotations not supported in v0
```

Rationale: `Decimal[2]` is consistent with existing `Collection[T]` parameterized type notation. The single-integer form is unambiguous and avoids a keyword-in-type-position grammar conflict.

### Type aliases (recommended pattern)

```text
-- In source files, prefer type aliases for domain names:
type BidAmount    = Decimal[2]
type Price        = Decimal[2]
type TaxRate      = Decimal[4]
type WholeDecimal = Decimal[0]
```

Type aliases are already supported by PROP-015 `TypeDecl`. No grammar change needed for aliases.

---

## Part 2: Grammar Delta

### 2-A. New keywords: none

`Decimal` is already accepted as an `:ident` token. The parser already handles `TypeRef[T]` for `Collection[T]`. The only new production is parsing `Decimal[IntLit]` — a specialization of the existing parameterized type rule.

### 2-B. TypeRef grammar extension

Existing TypeRef production (PROP-015):

```text
TypeRef := Name | Name "[" TypeRef ("," TypeRef)* "]"
```

Extended: no grammar rule change needed. `Decimal[2]` already matches `Name "[" TypeRef "]"` if `2` (`:int_lit`) is accepted as a TypeRef. Currently, the `parse_type_ref` method only accepts idents as type arguments.

**Parser change required**: accept `:int_lit` as a TypeRef leaf for the Decimal scale position.

### 2-C. ParsedProgram type annotation shape

```text
Before (opaque string): "Decimal[2]"
After  (structured):    { "kind": "type_ref", "name": "Decimal", "params": [2] }
                        -- params[0] is an Integer, not a string
```

**[D] All existing parameterized types continue to emit string params.** Only `Decimal[N]` emits an integer param. The classifier detects `name == "Decimal"` and validates `params[0]` is a non-negative integer.

---

## Part 3: Operator Signatures and OOF Rules

### Arithmetic (Pass 1 type inference)

```text
stdlib.decimal.add(Decimal[S], Decimal[S]) -> Decimal[S]
  -- OOF-DM1: scale mismatch -> compile error

stdlib.decimal.sub(Decimal[S], Decimal[S]) -> Decimal[S]
  -- OOF-DM1: scale mismatch -> compile error

stdlib.decimal.mul(Decimal[A], Decimal[B]) -> Decimal[A+B]
  -- output scale = sum of input scales; no OOF for different scales

stdlib.decimal.rescale(Decimal[A], target: Integer, rounding: RoundingMode)
  -> Decimal[target]
  -- CORE if target and rounding are literals
  -- ESCAPE if rounding is from TBackend read
```

### Comparison

```text
stdlib.decimal.lt(Decimal[S], Decimal[S]) -> Bool   -- CORE; OOF-DM1 if scale mismatch
stdlib.decimal.lte(Decimal[S], Decimal[S]) -> Bool
stdlib.decimal.gt(Decimal[S], Decimal[S]) -> Bool
stdlib.decimal.gte(Decimal[S], Decimal[S]) -> Bool
stdlib.decimal.eq(Decimal[S], Decimal[S]) -> Bool
```

### Division (ESCAPE unless literals present)

```text
stdlib.decimal.div(
  Decimal[A], Decimal[B],
  result_scale: Integer,      -- must be a literal
  rounding: RoundingMode      -- must be a literal
) -> Decimal[result_scale]
  -- CORE if result_scale and rounding are both literal values
  -- ESCAPE if either comes from TBackend read (OOF-DM4 carries over)
  -- OOF-DM3: div called without result_scale or rounding -> compile error
```

### Float coercion prohibition

```text
-- The classifier rejects any compute node where:
-- (a) a Float literal is used where Decimal[N] is expected, or
-- (b) a Float-typed ref flows into a Decimal[N] compute position.

OOF-DM2: Float used as Decimal proxy.
  -> compile error (Pass 1 type check).
  -> No implicit coercion. Explicit stdlib.decimal.from_float(f, scale, rounding)
     is ESCAPE (lossy coercion requires explicit acknowledgement).
```

### New OOF rules (grammar level)

```text
OOF-DM5: Decimal type annotation without scale parameter.
  "Decimal" used without "[N]" in an input, output, or compute type annotation.
  -> Parse error (if caught at parse) or Pass 1 type error.
  -> In v0: Pass 1 type error (the parser emits a TypeRef node with empty params;
     classifier rejects it).

OOF-DM6: Keyword param in Decimal type annotation.
  "Decimal[scale: 2]" — keyword-style parameter not supported in v0.
  -> Parse error: colon inside bracket triggers symbol_lit lexing, not TypeRef param.
  -> Emit parse_errors entry; suggest "Decimal[2]" instead.
```

---

## Part 4: Parser Change Specification

### `parse_type_ref` extension

Current behavior: `Name "[" TypeRef ("," TypeRef)* "]"` — each TypeRef is a name or parameterized name. Integer literals are not accepted as TypeRef.

Required change: **When the current name is `"Decimal"` and the next token inside `[...]` is `:int_lit`, consume it as the scale parameter.**

```ruby
# Inside parse_type_ref, after consuming Name and seeing lbracket:
if name == "Decimal" && peek_type?(:int_lit)
  scale = advance.value  # Integer
  expect_type!(:rbracket)
  return { "kind" => "type_ref", "name" => "Decimal", "params" => [scale] }
end
# Otherwise: existing generic TypeRef param parsing
```

This change is targeted — it does not affect `Collection[T]`, `Option[T]`, `Result[T,E]`, or generic contract type params.

### Source fixture for acceptance

```text
-- decimal_contract.ig
-- Parser acceptance fixture: Decimal[N] type annotations.

module SparkCRM.Finance

type BidAmount    = Decimal[2]
type TaxRate      = Decimal[4]

contract BidSummary {
  input  base_bid:   Decimal[2]
  input  tax_rate:   Decimal[4]

  compute gross_bid  = stdlib.decimal.rescale(
    stdlib.decimal.mul(base_bid, tax_rate),
    2, :half_up
  )

  output gross_bid: Decimal[2]
}
```

---

## Part 5: Expected ParsedProgram JSON Delta

```json
{
  "kind": "source_file",
  "grammar_version": "decimal-v0",
  "module": "SparkCRM.Finance",
  "types": [
    { "kind": "type", "name": "BidAmount",
      "fields": [],
      "alias": { "kind": "type_ref", "name": "Decimal", "params": [2] }
    },
    { "kind": "type", "name": "TaxRate",
      "fields": [],
      "alias": { "kind": "type_ref", "name": "Decimal", "params": [4] }
    }
  ],
  "contracts": [
    {
      "kind": "contract",
      "name": "BidSummary",
      "type_params": [],
      "body": [
        { "kind": "input", "name": "base_bid",
          "type_annotation": { "kind": "type_ref", "name": "Decimal", "params": [2] } },
        { "kind": "input", "name": "tax_rate",
          "type_annotation": { "kind": "type_ref", "name": "Decimal", "params": [4] } },
        { "kind": "compute", "name": "gross_bid",
          "expr": {
            "kind": "call", "fn": "stdlib.decimal.rescale",
            "args": [
              { "kind": "call", "fn": "stdlib.decimal.mul",
                "args": [
                  { "kind": "ref", "name": "base_bid" },
                  { "kind": "ref", "name": "tax_rate" }
                ]
              },
              { "kind": "literal", "value": 2, "type": "int" },
              { "kind": "literal", "value": "half_up", "type": "symbol" }
            ]
          }
        },
        { "kind": "output", "name": "gross_bid",
          "type_annotation": { "kind": "type_ref", "name": "Decimal", "params": [2] } }
      ]
    }
  ],
  "parse_errors": []
}
```

**Note on `type_annotation` shape:** In PROP-014, `type_annotation` is a string (`"Collection[GeoSignal]"`). For Decimal, the structured form `{ "kind": "type_ref", ... }` is emitted only when the parser detects `Decimal[N]`. All other type annotations remain opaque strings in v0. The classifier handles both forms.

### grammar_version detection

```text
"decimal-v0"  -- if any type annotation is a structured Decimal TypeRef node
"spark-pipeline-v0" -- if pipelines or scoped reads present
"polymorphic-v0"    -- if traits/impls/contract_shapes present
"0.1.0"             -- baseline
```

---

## Part 6: SemanticIR Gates (additions)

```text
G-DM1: Decimal type annotation must carry exactly one non-negative integer scale param.
        Decimal without param or with negative scale -> type error.

G-DM2: All Decimal comparisons and add/sub must have matching scales.
        Enforced at Pass 1; no implicit scale coercion.

G-DM3: Float literal flowing into Decimal-typed port -> type error (OOF-DM2).

G-DM4: div without literal result_scale + rounding -> OOF-DM3 (compile error).
```

---

## Handoff

```text
[Igniter-Lang Compiler/Grammar Expert]
Track: igniter-lang/decimal-grammar-v0
Status: done

[D] Decisions:
- Decimal[N] compact form (single positional IntLit param). Not Decimal[scale:N].
- parse_type_ref: targeted extension for name=="Decimal" + int_lit param.
  All other parameterized types unaffected.
- Structured TypeRef node { kind, name, params: [Integer] } for Decimal only.
  All other type annotations remain opaque strings in v0.
- Type aliases via existing TypeDecl (PROP-015). No new grammar needed.
- Decimal without scale param -> OOF-DM5 (Pass 1 type error in v0; future: parse error).
- Float-as-Decimal -> OOF-DM2 (compile error). No implicit coercion.
- div ESCAPE unless result_scale + rounding are literals (carried from formalization).
- grammar_version: decimal-v0 when structured Decimal TypeRef present.

[Files] Changed:
- igniter-lang/docs/tracks/decimal-grammar-v0.md [NEW]
- igniter-lang/docs/README.md  [updated]
- igniter-lang/docs/agent-motion.md  [updated]
- Parser change specified in §Part 4; implementation by Research Agent.
- Source fixture in §Part 4; expected JSON in §Part 5.

[Next]:
- [Research Agent]: implement parse_type_ref Decimal[N] extension;
  add decimal_contract.ig fixture; verify against expected JSON in §Part 5.
- [Compiler/Grammar Expert]: decimal-classifier-v0
  Define classifier Pass 1 rules for Decimal scale inference,
  stdlib.decimal.* operator signature resolution, and OOF-DM1..5 checks.
```
