# Track: Invariant Severity Parser Implementation v0

Role: `[Igniter-Lang Compiler/Grammar Expert]`
Track: `igniter-lang/invariant-severity-parser-impl-v0`
Card: S2-R10-C4-P
Status: done
Date: 2026-05-07
Depends on: S2-R4-C3-P (invariant-severity-parser-and-typechecker-ownership-v0 — spec formalized)
Parallel note: Narrow. No stream runtime. No OLAP. No SemanticIR emission.

---

## Context

`invariant-severity-parser-and-typechecker-ownership-v0` (S2-R4-C3-P) defined the
PINV/TINV checklist and left it as Tier 1 deferred work. The spec was:

```text
Parser (PINV-1..4):
  ☐ PINV-1: Add "invariant" to KEYWORDS.
  ☐ PINV-2: Add predicate/severity/label/overridable_with/message to KEYWORDS.
  ☐ PINV-3: Implement parse_invariant_decl.
  ☐ PINV-4: Body dispatcher when "invariant".

TypeChecker (TINV-1..3):
  ☐ TINV-1: Handle "invariant" kind in typecheck_contract.
  ☐ TINV-2: TC-INV-1..5 per Part 6.
  ☐ TINV-3: Add OOF-IV3 to blocking_rule_present?.

Negative fixtures:
  ☐ NF-INV-1: non-Bool predicate → OOF-IV3.
  ☐ NF-INV-2: overridable_with + error → OOF-I4.
  ☐ NF-INV-3: missing predicate → OOF-IV1 (parser-owned).

Regression:
  ☐ INV-REG-1: invariant_severity_proof.rb still PASS.
  ☐ INV-REG-2: stage1_close_candidate.rb still PASS.
  ☐ INV-REG-3: parser acceptance (PINV-1..4 live).
```

This slice implements the full checklist.

---

## Implementation

### `lib/igniter_lang/parser.rb`

**PINV-1/2**: Added `invariant predicate severity label message overridable_with` to `KEYWORDS`.

**PINV-3**: Implemented `parse_invariant_decl`:
```text
invariant <name>
  predicate: <compute_ref>         -- required; OOF-IV1 if missing
  severity: :<error|warn|soft|metric>  -- default "error"; OOF-IV2 if unknown symbol
  label: "<string>"               -- optional
  message: "<string>"             -- optional
  overridable_with: :<symbol>     -- optional; OOF-I4 if on severity:error
```

Attribute parsing loop: `while peek_kw?(attr_key)`. All five attribute keywords are
consumed greedily after the invariant name, in any order. This makes the syntax flexible
(order of attributes does not matter, consistent with window/read attribute parsing).

**OOF codes emitted by parser:**
- `OOF-IV1`: missing `predicate:` field (emitted as parse_error; invariant node still returned with `predicate_ref: nil`)
- `OOF-IV2`: unknown severity value (emitted as parse_error; recovers to `"error"`)
- `OOF-I4`: `overridable_with:` on `severity: :error` (static detection; TypeChecker also catches this for classified-level inputs)

**PINV-4**: Added `when "invariant" then advance; parse_invariant_decl` to `parse_body_decl`.

---

### `lib/igniter_lang/typechecker.rb`

**TINV-1 (TC-INV-1)**: When `kind: "invariant"` encountered in `typecheck_contract`:
- Resolve `predicate_ref` in `symbol_types`.
- If type is not `Bool` (and not `Unknown` — conservatively skip unresolved), emit `OOF-IV3`.

**TINV-2 (TC-INV-2)**: Validate `overridable_with` semantics:
- `overridable_with != nil && severity == "error"` → emit `OOF-I4`.
- (OOF-I1 deferred: `@bitemporal` annotation not yet parseable.)

**TINV-3**: `OOF-IV3` added to `blocking_rule_present?` list (prevents spurious output
type mismatch cascade after invariant error).

**TC-INV-3 (output_effect)**: `invariant_output_effect(severity)` maps:
```text
error  → "blocks"   (no propagation; execution stops)
warn   → "warns"    (propagated to output.warnings_from[])
soft   → "uncertain" (propagated to output.uncertain_from[])
metric → "metric"   (propagated to output.metrics_from[])
```

**TC-INV-4 (output propagation)**: `typed_decl_output` replaces the old `typed_decl`
for `output` nodes. It merges `warnings_from`, `uncertain_from`, `metrics_from` from
accumulated `invariant_effects` into the typed output decl.

**New helper methods:**
- `check_invariant(decl, symbol_types, type_errors, invariant_effects)` — TC-INV-1/2/3
- `typed_decl_invariant(decl, symbol_types)` — builds typed invariant node with `output_effect`
- `typed_decl_output(decl, type, invariant_effects)` — output node with effect propagation
- `invariant_output_effect(severity)` — severity → effect mapping

**[D] Conservative OOF-IV3**: If `predicate_ref` resolves to `Unknown` (unresolved symbol),
OOF-IV3 is NOT emitted. The existing OOF-P1 from the classifier already covers this path.
Emitting OOF-IV3 on top of OOF-P1 would be a redundant duplicate error.

---

### Positive fixture: `invariant_severity_valid.classified.json`

Contract `DrugOrderGate` with two Bool-predicate invariants:
- `safety_block`: `severity: "error"`, `overridable_with: null` → `output_effect: "blocks"`
- `interaction_warn`: `severity: "warn"`, `overridable_with: "documented_justification"` → `output_effect: "warns"`

Output `approved` must carry `warnings_from: ["interaction_warn"]` (TINV-4 propagation).

### Negative fixtures

| Fixture | Expected rule | Trigger |
|---------|--------------|---------|
| `negative_invariant_non_bool_predicate.classified.json` | OOF-IV3 | predicate_ref `result` resolves to `Integer` |
| `negative_invariant_overridable_on_error.classified.json` | OOF-I4 | `overridable_with: "supervisor_approval"` on `severity: "error"` |

---

### Proof extensions

**`invariant_severity_proof.rb`** extended with two new sections:

1. **PINV live parser checks (7 new checks)**:
   - `pinv.parser_accepts_valid_invariant` — 4-invariant contract parses without OOF
   - `pinv.invariant_nodes_count_4` — 4 invariant nodes emitted in body[]
   - `pinv.severity_values_correct` — severities: error, warn, soft, metric
   - `pinv.overridable_with_parsed` — `interaction_warn.overridable_with == "documented_justification"`
   - `pinv.missing_predicate_emits_oof_iv1` — PINV-3 negative
   - `pinv.unknown_severity_emits_oof_iv2` — PINV-3 negative
   - `pinv.overridable_on_error_emits_oof_i4` — PINV-3 negative

2. **Uses `IgniterLang::ParsedProgram.parse(source)` public API** (live production parser).

**`typechecker_proof.rb`** extended with:
- 3 new `CASES` entries (positive + 2 negatives)
- 4 new checks: `typed.invariant_severity_valid`, `invariant.tinv1_output_has_warnings_from`, `negative.invariant_non_bool_predicate_oof_iv3`, `negative.invariant_overridable_on_error_oof_i4`
- New helper `invariant_output_effect?` (verifies TINV-4 warnings_from propagation)

---

## Verification

```text
ruby igniter-lang/experiments/invariant_severity_proof/invariant_severity_proof.rb
  → PASS invariant_severity_proof (18 checks: 11 existing + 7 PINV)

ruby igniter-lang/experiments/typechecker_proof/typechecker_proof.rb
  → PASS typechecker_proof (20 checks: 16 existing + 4 TINV)

ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb
  → PASS stage1_close_candidate — no regressions
```

---

## PINV/TINV Matrix — Post-Implementation

| ID | Rule | Owner | Status | Notes |
|----|------|-------|--------|-------|
| PINV-1 | Add `invariant` to KEYWORDS | Parser | ✅ done | |
| PINV-2 | Add `predicate/severity/label/message/overridable_with` to KEYWORDS | Parser | ✅ done | |
| PINV-3 | Implement `parse_invariant_decl` with OOF-IV1/IV2/I4 | Parser | ✅ done | |
| PINV-4 | Body dispatcher `when "invariant"` | Parser | ✅ done | |
| TINV-1 | Handle `invariant` kind in `typecheck_contract` | TypeChecker | ✅ done | |
| TINV-2 | TC-INV-1..5 per Part 6 | TypeChecker | ✅ done (TC-INV-1..4; TC-INV-5 OOF-I3 advisory deferred) | |
| TINV-3 | OOF-IV3 in `blocking_rule_present?` | TypeChecker | ✅ done | |
| NF-INV-1 | OOF-IV3 negative fixture | Fixture | ✅ done | |
| NF-INV-2 | OOF-I4 negative fixture | Fixture | ✅ done | |
| NF-INV-3 | OOF-IV1 negative (parser-level) | Parser proof | ✅ done (in invariant_severity_proof pinv.* checks) | |
| INV-REG-1 | `invariant_severity_proof.rb` PASS | Regression | ✅ PASS | |
| INV-REG-2 | `stage1_close_candidate.rb` PASS | Regression | ✅ PASS | |
| INV-REG-3 | Parser acceptance live | Regression | ✅ PASS (pinv.* checks in invariant_severity_proof) | |

---

## Deferred / Remaining

| Item | Reason |
|------|--------|
| OOF-I1 (`overridable_with:` without `@bitemporal`) | `@bitemporal` annotation not yet parseable; deferred |
| OOF-I2 (caller ignores `warnings_from`) | Advisory in v0; cross-contract analysis out of scope |
| OOF-I3 (caller treats `~T` as `T`) | Probabilistic types (`~T`) not yet in type system |
| OOF-I5 (label not in requirements DB) | Deferred to Stage 3 |
| `output_effect` propagation in SemanticIR emitter | Emitter lowering track; not this slice |

---

## Files Changed

```text
igniter-lang/lib/igniter_lang/parser.rb
  + invariant predicate severity label message overridable_with → KEYWORDS
  + when "invariant" → parse_body_decl dispatch
  + parse_invariant_decl (PINV-3; OOF-IV1/IV2/I4)

igniter-lang/lib/igniter_lang/typechecker.rb
  + invariant_effects accumulator in typecheck_contract
  + when "invariant" case → check_invariant + typed_decl_invariant
  + typed_decl_output (output nodes; TINV-4)
  + OOF-IV3 in blocking_rule_present?
  + check_invariant, typed_decl_invariant, typed_decl_output, invariant_output_effect

igniter-lang/experiments/typechecker_proof/classified/invariant_severity_valid.classified.json  [NEW]
igniter-lang/experiments/typechecker_proof/classified/negative_invariant_non_bool_predicate.classified.json  [NEW]
igniter-lang/experiments/typechecker_proof/classified/negative_invariant_overridable_on_error.classified.json  [NEW]
igniter-lang/experiments/typechecker_proof/typechecker_proof.rb
  + 3 CASES, 4 checks, invariant_output_effect? helper

igniter-lang/experiments/invariant_severity_proof/invariant_severity_proof.rb
  + require_relative parser
  + parser_checks (7 PINV checks), PINV source fixtures
  + merged into run → all_checks

igniter-lang/docs/tracks/invariant-severity-parser-impl-v0.md  [NEW — this file]
```

---

## Handoff

```text
Card: S2-R10-C4-P
[Igniter-Lang Compiler/Grammar Expert]
Track: igniter-lang/invariant-severity-parser-impl-v0
Status: done
Neighbors affected: Research Agent (parser + typechecker invariant support complete)

[D] Decisions:
- Attribute parsing loop: while peek_kw?(attr_key). Order-independent, consistent with
  window/read patterns. Any unrecognized keyword terminates the invariant body.
- OOF-IV3 is conservative: if predicate_ref resolves to Unknown, skip the check.
  OOF-P1 (from classifier) already covers the missing-ref case.
- TC-INV-5 (OOF-I3 ~T enforcement): advisory only in v0. Probabilistic types not in
  type system yet.
- OOF-I1 (overridable_with without @bitemporal): deferred — @bitemporal not parseable.
- typed_decl_output replaces typed_decl for output nodes. When no invariant effects
  exist, it produces the same result (fields not added if empty).
- invariant nodes are NOT registered in symbol_types (they don't produce values).
- output_effect: "blocks" is not propagated to output (error severity stops execution).

[S] Signals:
- invariant_severity_proof: 18/18 checks PASS (was 11; +7 PINV parser checks).
- typechecker_proof: 20/20 checks PASS (was 16; +4 TINV checks).
- stage1_close_candidate: PASS — no regressions.
- Full PINV-1..4 + TINV-1..3 checklist: DONE.

[T] Tests / Proofs:
- ruby igniter-lang/experiments/invariant_severity_proof/invariant_severity_proof.rb → PASS (18)
- ruby igniter-lang/experiments/typechecker_proof/typechecker_proof.rb → PASS (20)
- ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb → PASS

[R] Remaining Gaps:
1. OOF-I1 (overridable_with without @bitemporal): needs @bitemporal annotation parseable.
2. OOF-I3 (~T enforcement): needs probabilistic type in type system.
3. OOF-I5 (label DB check): Stage 3.
4. output_effect propagation in SemanticIR emitter: emitter track.

[X] Not implemented:
- OOF-I1, OOF-I3 (see above)
- SemanticIR invariant_node emission (emitter track)

[Files]:
- lib/igniter_lang/parser.rb [MODIFIED — PINV-1..4]
- lib/igniter_lang/typechecker.rb [MODIFIED — TINV-1..3 + helpers]
- typechecker_proof/classified/invariant_severity_valid.classified.json [NEW]
- typechecker_proof/classified/negative_invariant_non_bool_predicate.classified.json [NEW]
- typechecker_proof/classified/negative_invariant_overridable_on_error.classified.json [NEW]
- typechecker_proof/typechecker_proof.rb [MODIFIED — +3 CASES, +4 checks, +1 helper]
- invariant_severity_proof/invariant_severity_proof.rb [MODIFIED — +7 PINV checks]
- docs/tracks/invariant-severity-parser-impl-v0.md [NEW]
- docs/current-status.md [updated]
- docs/agent-motion.md [updated]

[Next]:
- compiler-orchestrator-v0 (Tier 0): all 9 libs extracted; need orchestration spine.
- stream-semanticir-surface-lowering-v0: stream + invariant SemanticIR emission.
- olap-point-typechecker-semanticir-v0 (if not yet done).
```
