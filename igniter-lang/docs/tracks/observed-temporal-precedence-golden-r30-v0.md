# Track: Observed + Temporal Precedence Golden (R30)

Card: S3-R30-C3-P (Compiler/Grammar Expert)
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: `compiler-grammar-expert`
Track: `observed-temporal-precedence-golden-v0`
Status: done
Date: 2026-05-10

---

## Purpose

Add a dedicated golden proof that an `observed` contract whose body contains
a temporal read (`History[T]` or `BiHistory[T]`) receives `fragment_class: "temporal"` —
not `"escape"`. This anchors V-3 (Temporal Precedence Rule) from the R28/R29
cross-review in a verifiable golden file.

---

## V-3 — Temporal Precedence Rule

> An `observed` contract with temporal declarations in its body is classified
> `fragment_class: "temporal"`, never `"escape"`. Temporal has precedence over
> modifier-based escape assignment.

Implementation site: `classifier.rb` → `contract_fragment_for` (lines 176–185):

```ruby
return "temporal" if declarations.any? { |decl| decl.fetch("fragment_class") == "temporal" } &&
                     declarations.none? { |decl| decl.fetch("fragment_class") == "oof" }
return "escape" if (modifier != "pure" || ...) && ...
```

The `temporal` guard fires before the `escape` guard regardless of which modifier
is on the contract. That ordering is the implementation of V-3.

---

## Deliverables

### 1. Fixture (hand-authored parsed AST)

**`experiments/contract_modifiers_proof/fixtures/observed_temporal_precedence.parsed_ast.json`**

Hand-authored JSON representing the contract:

```igniter
observed contract ReadHistory {
  input sku_id: String
  input as_of: DateTime
  escape history_read
  read price_history: History[String] from "sku/{sku_id}/price" @durable
  output price_history: History[String]
}
```

Hand-authoring is required because `History[T]` grammar is not yet in the parser
(`parser_status: "hand_authored_until_history_read_grammar_lands"`). This follows
the same pattern used in `temporal_semanticir_access_node`.

### 2. Runner extension

**`experiments/contract_modifiers_proof/contract_modifiers_proof.rb`**

Two changes:

**a. `json_source:` support in `build_outputs`** — bypasses `ParsedProgram.parse`
for cases that specify `json_source:` instead of `source:`. The JSON file is loaded
directly as the parsed program hash and fed into the Classifier unchanged.

**b. Three new named checks in `build_checks`:**

| Check label | What it asserts |
|-------------|----------------|
| `parser.observed_temporal` | Fixture carries `modifier: "observed"` in parsed AST |
| `classifier.temporal_precedence_over_modifier` | Classifier assigns `fragment_class: "temporal"` (not `"escape"`) |
| `semanticir.modifier_field.observed_temporal` | SemanticIR preserves both `modifier: "observed"` and `fragment_class: "temporal"` |

**c. New POSITIVE_CASES entry:**

```ruby
"observed_temporal_precedence" => {
  json_source: "observed_temporal_precedence.parsed_ast.json",
  expected_contracts: [{ name: "ReadHistory", modifier: "observed", fragment_class: "temporal" }],
  sample_input: { "sku_id" => "sku-001", "as_of" => "2026-01-01T00:00:00Z" }
}
```

### 3. Golden files generated

| File | Key fields |
|------|-----------|
| `golden/observed_temporal_precedence.parsed.json` | `modifier: "observed"`, temporal `read` node with `History[String]` |
| `golden/observed_temporal_precedence.classified.json` | `fragment_class: "temporal"`, `modifier: "observed"` |
| `golden/observed_temporal_precedence.typed.json` | `status: "accepted"`, no type errors |
| `golden/observed_temporal_precedence.semantic_ir.json` | `modifier: "observed"`, `fragment_class: "temporal"` preserved |

---

## PASS/FAIL Command

```bash
# Write mode (regenerate goldens):
ruby igniter-lang/experiments/contract_modifiers_proof/contract_modifiers_proof.rb

# Check-golden mode (CI verification):
ruby igniter-lang/experiments/contract_modifiers_proof/contract_modifiers_proof.rb --check-golden
```

Expected output (check-golden):

```
parser.observed_temporal: ok
classifier.temporal_precedence_over_modifier: ok
semanticir.modifier_field.observed_temporal: ok
...
PASS contract_modifiers_proof_golden_check
```

Total checks: 25 (20 behavior + 5 golden equality including determinism).

---

## CSM Update Required

The CSM entry for `Contract modifier: observed` carries a footnote:

> †`observed` yields `temporal` when body contains `History[T]` or `BiHistory[T]` reads;
> `escape` otherwise. See PROP-031 §4.1 and §14.4.

The golden anchor for this footnote was previously only the basic `observed` case
(`observed_contract_basic.semantic_ir.json`, which classifies as `"escape"`).
The temporal case is now anchored at:

```
contract_modifiers_proof/golden/observed_temporal_precedence.classified.json
```

This golden should be added as a secondary anchor for the `observed` modifier row in the CSM
under the column `golden_anchor`:

```
observed_contract_basic.semantic_ir.json (escape path)
observed_temporal_precedence.classified.json (temporal path — V-3)
```

---

## Handoff

```text
Card: S3-R30-C3-P
Agent: [Igniter-Lang Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: observed-temporal-precedence-golden-v0
Status: done

[D] Decisions
- Used json_source: pattern (matching temporal_semanticir_access_node approach) because
  History[T] grammar is not in the parser. The hand-authored AST is identical in structure
  to what the parser will eventually produce.
- Extended POSITIVE_CASES rather than creating a separate experiment. The temporal
  precedence proof is a modifier-scoped fact, so it belongs in contract_modifiers_proof.
- No grammar added. No existing proofs altered. All 20 existing checks still pass.

[S] Shipped / Signals
- fixtures/observed_temporal_precedence.parsed_ast.json: hand-authored, observed + History[T]
- golden/observed_temporal_precedence.classified.json: fragment_class: "temporal", modifier: "observed"
- golden/observed_temporal_precedence.semantic_ir.json: both fields preserved through pipeline
- runner: json_source: support + 3 new checks (25 total, all PASS in check-golden mode)

[T] Tests / Proofs
- ruby contract_modifiers_proof.rb --check-golden: PASS (25/25)
- classifier.temporal_precedence_over_modifier: ok — V-3 is golden-anchored

[R] Risks / Recommendations
- CSM row for "Contract modifier: observed" should be updated to cite both golden anchors
  (escape path + temporal path). This is a documentation update only — no new card required.
- When History[T] grammar lands in the parser, the json_source: fixture should be replaced
  with a .ig source file. The golden files will need to be regenerated (modifier and
  fragment_class should be identical; only parser metadata may differ).

[Next] Suggested next slice
- R30: PROP-032 (assumptions block) — bootstrap draft, Research Agent fixture
- R30: OOF-I1/I3/I5 deferred invariant codes — PROP-025 addendum + targeted fixtures
- CSM update: add secondary anchor reference for observed modifier (temporal path)
```
