# Track: Invariant Severity Parser and TypeChecker Ownership v0

Role: `[Igniter-Lang Compiler/Grammar Expert]`
Track: igniter-lang/invariant-severity-parser-and-typechecker-ownership-v0
Card: S2-R4-C3-P
Status: done
Date: 2026-05-07
Depends on: S2-R3-C4-P (invariant-severity-proof-v0 — PASS)
Parallel note: Independent from temporal runtime work.

---

## Context

`invariant_severity_proof.rb` is PASS using hand-authored `invariant_node` fixtures.
Parser has no `invariant` keyword. TypeChecker has no invariant rules.
This track defines the exact source syntax surface and TypeChecker OOF ownership
before parser acceptance work starts. No proof is changed in this slice.

---

## Part 1: Recommended Source Syntax

### Minimal v0 invariant declaration

```text
invariant <name>
  predicate: <compute_ref>
  severity: :<error|warn|soft|metric>
  message: "<string>"
  label: "<string>"             -- optional
  overridable_with: :<symbol>   -- optional; :warn only
```

**[D] `invariant` is a keyword at body position inside a contract.** It is not a compute node and does not produce a value. It is a structural declaration alongside `input / output / compute / read`.

**[D] `predicate:` is a reference to a `compute` node that resolves to `Bool`.** Not an inline expression. This keeps invariant declarations simple and avoids embedding arbitrary logic in the invariant block.

**[D] `severity:` is a symbol literal (`:error`, `:warn`, `:soft`, `:metric`).** Omitting `severity:` defaults to `:error`.

**[D] `label:` is an opaque string identifier for the requirements database.** Optional. The parser accepts any string. Validation against a requirements database (OOF-I5) is deferred to Stage 3.

**[D] `overridable_with:` is a symbol literal naming the override protocol.** Forbidden on `severity: :error` (OOF-I4). Optional on `:warn` only.

### Concrete source example

```text
contract DrugOrderGate {
  input interactions: Collection[DrugInteraction]
  input confidence: Float

  compute contraindicated_interactions_empty =
    interactions.none? { |i| i.contraindicated }

  compute major_interactions_acknowledged =
    interactions.all? { |i| !i.major || i.acknowledged }

  compute confidence_at_least_threshold =
    confidence >= 0.85

  invariant contraindicated_interaction_block
    predicate: contraindicated_interactions_empty
    severity: :error
    label: "CG-INTERACTION-01"
    message: "Contraindicated drug combination - order blocked"

  invariant major_interaction_acknowledgement
    predicate: major_interactions_acknowledged
    severity: :warn
    label: "CG-INTERACTION-02"
    message: "Major drug interaction requires acknowledgement"
    overridable_with: :documented_justification

  invariant confidence_gate
    predicate: confidence_at_least_threshold
    severity: :soft
    message: "Low confidence - output is approximate"

  output approved_dose: Decimal[2] lifecycle :session
}
```

---

## Part 2: Parsed Node Shape (ParsedProgram)

```json
{
  "kind":            "invariant",
  "name":            "contraindicated_interaction_block",
  "predicate_ref":   "contraindicated_interactions_empty",
  "severity":        "error",
  "label":           "CG-INTERACTION-01",
  "message":         "Contraindicated drug combination - order blocked",
  "overridable_with": null
}
```

**Field rules:**

```text
kind:           "invariant"                         -- always
name:           identifier string                   -- required
predicate_ref:  identifier string (no type)         -- required
severity:       "error"|"warn"|"soft"|"metric"      -- required; default "error"
label:          string | null                       -- optional
message:        string | null                       -- optional
overridable_with: string | null                     -- optional; null for :error/:soft/:metric
```

**[D] `predicate_ref` is a plain name string, not a TypeRef.** The parser does not resolve it. The classifier confirms the referenced compute node exists (OOF-P1 path if missing).

---

## Part 3: Typed Node Shape (TypedProgram)

After TypeChecker, the invariant node gains type-resolved fields:

```json
{
  "kind":            "invariant",
  "name":            "contraindicated_interaction_block",
  "predicate_ref":   "contraindicated_interactions_empty",
  "predicate_type":  { "name": "Bool", "params": [] },
  "severity":        "error",
  "label":           "CG-INTERACTION-01",
  "message":         "Contraindicated drug combination - order blocked",
  "overridable_with": null,
  "output_effect":   "blocks"
}
```

**`output_effect` values:**

```text
severity   output_effect
─────────  ─────────────
error      "blocks"        -- execution stops; no output produced
warn       "warns"         -- output produced; warnings_from[] set
soft       "uncertain"     -- output produced; uncertain_from[] set
metric     "metric"        -- no output effect; metric recorded
```

---

## Part 4: Grammar / Parser Ownership

```text
Parser-owned checks (structural; no type inference):

PH-INV-1: invariant block missing predicate: key
           → parse_error OOF-IV1 (new rule; parser-owned)
           → "invariant '<name>' missing required predicate: field"
           Severity: error. Classifier skips this invariant.

PH-INV-2: severity: value is not a known symbol literal
           Accepted symbols: :error :warn :soft :metric
           → parse_error OOF-IV2
           → "Unknown severity '<val>'; expected :error :warn :soft :metric"
           Recover: treat as "error". Continue.

PH-INV-3: overridable_with: present with severity: :error (syntactic detection only)
           If severity string is "error" and overridable_with is non-null:
           → emit advisory parse_error OOF-I4 (parser-detectable case)
           Severity: error. This is the static-detectable subset of OOF-I4.
```

**[D] Parser does NOT validate:**
- Whether `predicate_ref` resolves to an existing compute node (Classifier, OOF-P1)
- Whether the predicate compute node has type `Bool` (TypeChecker, OOF-IV3)
- Whether `overridable_with:` has a `@bitemporal` audit store (TypeChecker, OOF-I1)

---

## Part 5: TypeChecker OOF Ownership Table

```text
OOF Rule  Trigger                                     Owner         Action
────────  ──────────────────────────────────────────  ────────────  ─────────────────────────
OOF-P1    predicate_ref resolves to Unknown symbol    Classifier    blocked (existing rule)
OOF-IV1   invariant missing predicate: field          PARSER        parse_error
OOF-IV2   severity: is not error/warn/soft/metric     PARSER        parse_error; recover as error
OOF-IV3   predicate_ref compute node type != Bool     TypeChecker   blocked
           "invariant predicate must be Bool, got <type>"
OOF-I1    overridable_with: without @bitemporal        TypeChecker   blocked
           audit store in contract
           "overridable_with requires a BiHistory audit store"
OOF-I2    caller ignores warnings_from on :warn       TypeChecker   advisory (v0: warning only)
           output
OOF-I3    caller treats ~T as T without @exact         TypeChecker   blocked
           or @best_effort
OOF-I4    overridable_with: on severity: error        PARSER+TC     error (parser detects static
           (static case); TypeChecker catches          (:error)      case; TC catches dynamic)
           dynamic/inferred severity
OOF-I5    label: not found in requirements DB         DEFERRED      Stage 3 (no req DB yet)
```

**New OOF rules defined in this track:**
- `OOF-IV1` — parser, missing predicate
- `OOF-IV2` — parser, unknown severity value
- `OOF-IV3` — TypeChecker, predicate is not Bool

**[D] OOF-IV3 is the primary TypeChecker invariant rule.** The TypeChecker must look up `predicate_ref` in `symbol_types`, confirm its resolved type is `Bool`, and emit `OOF-IV3` if not.

---

## Part 6: TypeChecker Integration — What Changes

When `typecheck_contract` encounters a node with `kind: "invariant"`:

```text
TC-INV-1: Resolve predicate_ref in symbol_types.
           If missing → OOF-P1 (already emitted by classifier; forward only).
           If present and type != Bool → OOF-IV3 (new rule).

TC-INV-2: Validate overridable_with semantics.
           overridable_with != null AND severity == "error" → OOF-I4.
           overridable_with != null AND no @bitemporal store → OOF-I1.
           (v0: defer OOF-I1 to later slice unless @bitemporal annotation is parseable)

TC-INV-3: Compute output_effect from severity.
           error → "blocks"; warn → "warns"; soft → "uncertain"; metric → "metric"

TC-INV-4: Propagate output_effect to output nodes.
           warn invariants → add name to output.warnings_from[].
           soft invariants → add name to output.uncertain_from[].
           metric invariants → add name to output.metrics_from[].

TC-INV-5: Reject ~T → T unguarded use in caller (OOF-I3).
           v0: advisory only. Full enforcement deferred.
```

---

## Part 7: Keyword Addition Required

`invariant` must be added to the parser KEYWORDS list before parser acceptance:

```diff
- KEYWORDS = %w[
-   module import contract contract_shape type def trait impl
-   input output compute read snapshot window escape
-   from lifecycle using implements
-   pipeline step scoped_by cardinality schema_version tenant_free
-   if else let
-   true false nil
-   and or not
- ].freeze
+ KEYWORDS = %w[
+   module import contract contract_shape type def trait impl
+   input output compute read snapshot window escape
+   from lifecycle using implements
+   pipeline step scoped_by cardinality schema_version tenant_free
+   invariant predicate severity label overridable_with
+   if else let
+   true false nil
+   and or not
+ ].freeze
```

**[D] `predicate`, `severity`, `label`, `overridable_with` are added as keywords.**
They are attribute keys inside the invariant block, not top-level keywords.
Being keywords prevents them from being parsed as compute expressions accidentally.

---

## Part 8: Acceptance Checklist for Research Agent

```text
Parser (igniter_lang_parser.rb):
  ☐ PINV-1: Add "invariant" to KEYWORDS.
  ☐ PINV-2: Add predicate/severity/label/overridable_with to KEYWORDS.
  ☐ PINV-3: Implement parse_invariant method:
             - consume name (ident)
             - parse "predicate:" -> predicate_ref (ident)
             - parse "severity:" -> symbol literal (default "error")
             - parse optional "label:" -> string literal
             - parse optional "message:" -> string literal
             - parse optional "overridable_with:" -> symbol literal
             - emit OOF-IV1 if predicate missing
             - emit OOF-IV2 if severity value unknown
             - emit OOF-I4 (parse_error) if overridable_with + severity:error
  ☐ PINV-4: Body dispatcher: when "invariant" keyword, call parse_invariant.

TypeChecker (typechecker_proof.rb):
  ☐ TINV-1: Handle "invariant" kind in typecheck_contract.
  ☐ TINV-2: TC-INV-1..5 per §Part 6.
  ☐ TINV-3: Add OOF-IV3 to blocking_rule_present? list.

Negative fixtures:
  ☐ NF-INV-1: invariant with predicate_ref pointing to non-Bool compute -> OOF-IV3.
  ☐ NF-INV-2: invariant with overridable_with: + severity: error -> OOF-I4.
  ☐ NF-INV-3: invariant block missing predicate: -> parse_error OOF-IV1.

Regression:
  ☐ INV-REG-1: invariant_severity_proof.rb still PASS after parser integration.
  ☐ INV-REG-2: stage1_close_candidate.rb still PASS.
  ☐ INV-REG-3: parser_acceptance_spec.rb 61 examples, 0 failures.
```

---

## Verification (current state)

```text
ruby experiments/invariant_severity_proof/invariant_severity_proof.rb -> PASS
ruby experiments/stage1_close_candidate/stage1_close_candidate.rb -> PASS
```

No proof changes were needed in this slice. The track is formalization-only.

---

## Handoff

```text
[Igniter-Lang Compiler/Grammar Expert]
Card: S2-R4-C3-P
Track: igniter-lang/invariant-severity-parser-and-typechecker-ownership-v0
Status: done

[D] Decisions:
- "invariant" is a body-position keyword; predicate/severity/label/overridable_with
  are attribute keywords inside the invariant block.
- predicate_ref is a plain name string (no type). Classifier owns OOF-P1 for missing ref.
- severity defaults to "error" when omitted.
- 3 parser-owned OOF rules: OOF-IV1 (missing predicate), OOF-IV2 (unknown severity),
  OOF-I4 (overridable_with + error; static case).
- 1 new TypeChecker rule: OOF-IV3 (predicate not Bool).
- OOF-I1 (overridable_with without @bitemporal): TypeChecker owned; deferred until
  @bitemporal annotation is parseable.
- OOF-I2 (caller ignores warnings_from): TypeChecker advisory in v0.
- OOF-I3 (caller treats ~T as T): TypeChecker blocked; deferred full enforcement.
- OOF-I5 (label DB check): deferred to Stage 3.
- output_effect field on typed invariant node: blocks/warns/uncertain/metric.
- 10-item implementation checklist: PINV-1..4, TINV-1..3, NF-INV-1..3, INV-REG-1..3.
- No proof changes in this slice.

[S] Proof is PASS (hand-authored). Parser acceptance work is now unblocked.

[T] invariant_severity_proof.rb: PASS. stage1_close_candidate.rb: PASS.

[R] Research Agent: implement PINV-1..4 (parser) + TINV-1..3 (typechecker).
    Add NF-INV-1..3 fixtures. Verify INV-REG-1..3.
    This is Stage 2 Tier 1 work; do not start until Tier 0 (production compiler) closes.

[Files] Changed:
- igniter-lang/docs/tracks/invariant-severity-parser-and-typechecker-ownership-v0.md [NEW]
- igniter-lang/docs/agent-motion.md [updated]

[Next]:
- [Research Agent]: parser + typechecker implementation per PINV-1..4 + TINV-1..3.
- [Compiler/Grammar Expert]: next card per META-EXPERT-008 Stage 2 scoreboard.
```
