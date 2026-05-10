# Track: Contract Modifiers Proof Fixture Plan v0

Card: S3-R27-C4-P
Agent: `[Igniter-Lang Research Agent]`
Role: `research-agent`
Track: `contract-modifiers-proof-fixture-plan-v0`
Status: done
Date: 2026-05-10

Affected neighbor roles: `[Igniter-Lang Compiler/Grammar Expert]`,
`[Igniter-Lang Bridge Agent]`

---

## Purpose

Prepare the executable proof plan and fixture set for PROP-031 contract
modifiers without implementing parser/compiler support.

This track is a plan only. No fixtures are marked PASS here.

---

## Source Inputs

- `docs/proposals/PROP-031-contract-modifiers-v0.md`
- `docs/spec/ch10-contract-modifiers.md`
- `docs/meta-proposals/META-EXPERT-013-spec-extension-governance-v0.md`

Observed source status:

- PROP-031 exists and is `Status: proposal`.
- Ch10 is `Status: proposed`.
- META-EXPERT-013 asks Research Agent to prepare regression fixtures and keep
  existing Stage 1-2 fixtures unchanged.

[R] Note: PROP-031 acceptance criteria use checkmarks as target criteria in the
proposal text. This planning track treats them as expected future outcomes, not
observed implementation results.

---

## Modifier Surface Under Test

Planned modifiers:

```text
pure
observed
effect
privileged
irreversible
```

Rules to prove later:

- no modifier means implicit `pure`;
- explicit `pure` normalizes to the same AST shape as implicit `pure`;
- `observed`, `effect`, `privileged`, and `irreversible` are accepted
  syntactically;
- non-pure modifiers classify as ESCAPE in PROP-031;
- `pure` with `escape` emits OOF-M1 before SemanticIR;
- `contract_ir.modifier` is always present in SemanticIR, defaulting to
  `"pure"`;
- Stage 1-2 fixtures remain unchanged.

---

## Proposed Experiment Layout

Future directory:

```text
igniter-lang/experiments/contract_modifiers_proof/
  contract_modifiers_proof.rb
  fixtures/
    pure_contract_implicit.ig
    pure_contract_explicit.ig
    observed_contract_basic.ig
    modifier_variants.ig
    oof_m1_pure_with_escape.ig
  expected/
    pure_contract_implicit.parsed.json
    pure_contract_explicit.parsed.json
    observed_contract_basic.parsed.json
    modifier_variants.parsed.json
    oof_m1_pure_with_escape.diagnostics.json
    semantic_ir_modifier_shape.json
  out/
    contract_modifiers_proof_summary.json
```

This card does not create the directory because the parser/compiler do not yet
own the modifier syntax. The next implementation card can create it alongside
code changes.

---

## Fixture List

| Fixture | Purpose | Expected Status After Implementation |
|---------|---------|--------------------------------------|
| `pure_contract_implicit.ig` | Backward compatibility: existing `contract Foo` syntax defaults to `pure`. | ACCEPT |
| `pure_contract_explicit.ig` | Explicit `pure contract Foo` parses and normalizes to modifier `"pure"`. | ACCEPT |
| `observed_contract_basic.ig` | `observed contract` is accepted syntactically and can contain an `escape` read boundary. | ACCEPT |
| `modifier_variants.ig` | `effect`, `privileged`, and `irreversible` are accepted syntactically in one fixture. | ACCEPT |
| `oof_m1_pure_with_escape.ig` | Explicit `pure contract` containing `escape` is rejected by TypeChecker with OOF-M1. | REJECT OOF-M1 |

Optional later negative:

| Fixture | Purpose | Status |
|---------|---------|--------|
| `oof_m1_implicit_pure_with_escape.ig` | Proves implicit `contract Foo` + `escape` also triggers OOF-M1 after normalization. | Deferred unless Compiler/Grammar Expert requests it. |

---

## Fixture Sketches

### `pure_contract_implicit.ig`

```igniter
module Proof.ContractModifiers.PureImplicit

contract ScoreRisk {
  input contradiction_count: Integer
  input corroboration_count: Integer
  compute raw = contradiction_count - corroboration_count
  output raw: Integer
}
```

Expected:

```json
{
  "parsed.contracts[0].modifier": "pure",
  "classified.contracts[0].fragment_class": "CORE",
  "semantic_ir.contracts[0].modifier": "pure"
}
```

### `pure_contract_explicit.ig`

```igniter
module Proof.ContractModifiers.PureExplicit

pure contract ScoreRisk {
  input contradiction_count: Integer
  input corroboration_count: Integer
  compute raw = contradiction_count - corroboration_count
  output raw: Integer
}
```

Expected:

```json
{
  "parsed.contracts[0].modifier": "pure",
  "normalization_matches": "pure_contract_implicit",
  "classified.contracts[0].fragment_class": "CORE",
  "semantic_ir.contracts[0].modifier": "pure"
}
```

### `observed_contract_basic.ig`

```igniter
module Proof.ContractModifiers.ObservedBasic

observed contract ReadSensor {
  input sensor_id: String
  input as_of: DateTime
  escape sensor_read
  read reading: Option[Integer]
    from "sensors/{sensor_id}/reading"
    lifecycle :session
  output reading: Option[Integer]
}
```

Expected:

```json
{
  "parsed.contracts[0].modifier": "observed",
  "classified.contracts[0].fragment_class": "ESCAPE",
  "typed.pass_result": "ok",
  "semantic_ir.contracts[0].modifier": "observed"
}
```

### `modifier_variants.ig`

```igniter
module Proof.ContractModifiers.Variants

effect contract NotifyUser {
  input user_id: String
  input message: String
  escape notification_send
  output sent: Bool
}

privileged contract ApproveExpense {
  input expense_id: String
  input amount: Integer
  escape approval_write
  output approved: Bool
}

irreversible contract ArchiveRecord {
  input record_id: String
  escape archive_write
  output archived: Bool
}
```

Expected:

```json
[
  { "name": "NotifyUser", "modifier": "effect", "fragment_class": "ESCAPE" },
  { "name": "ApproveExpense", "modifier": "privileged", "fragment_class": "ESCAPE" },
  { "name": "ArchiveRecord", "modifier": "irreversible", "fragment_class": "ESCAPE" }
]
```

No Effect Surface validation is expected in PROP-031. OOF-M2 and OOF-M3 remain
reserved for PROP-035.

### `oof_m1_pure_with_escape.ig`

```igniter
module Proof.ContractModifiers.OofM1

pure contract BrokenPure {
  input sensor_id: String
  escape sensor_read
  read reading: Option[Integer]
    from "sensors/{sensor_id}/reading"
    lifecycle :session
  output reading: Option[Integer]
}
```

Expected diagnostic:

```json
{
  "code": "OOF-M1",
  "severity": "error",
  "contract": "BrokenPure",
  "message_contains": "pure contract 'BrokenPure' cannot declare escape capabilities"
}
```

---

## SemanticIR Modifier Field Shape

Expected SemanticIR shape after implementation:

```json
{
  "kind": "semantic_ir_program",
  "format_version": "0.1.0",
  "contracts": [
    {
      "kind": "contract_ir",
      "name": "ReadSensor",
      "modifier": "observed",
      "fragment_class": "ESCAPE",
      "nodes": [],
      "outputs": [],
      "requirements": [],
      "escape_boundaries": []
    }
  ]
}
```

Required proof assertions:

- every emitted `contract_ir` has `modifier`;
- missing source modifier emits `"pure"`;
- accepted non-pure modifiers preserve exact source spelling;
- no negative OOF-M1 fixture emits SemanticIR;
- existing Stage 1-2 SemanticIR goldens either remain byte-stable or receive a
  single intentional `modifier: "pure"` canonical-envelope migration with a
  documented golden update.

[Q] Open for Compiler/Grammar Expert: should Stage 1-2 SemanticIR goldens be
updated in-place to include `modifier: "pure"`, or should a compatibility view
inject default modifier while old goldens remain frozen? PROP-031 says the field
is always present in PROP-031+ compiled programs, so the implementation card
should decide the migration boundary explicitly.

---

## Proposed Command Matrix

These commands are expected after implementation, not in this planning card:

| # | Command | Expected Result |
|---|---------|-----------------|
| 1 | `ruby igniter-lang/experiments/contract_modifiers_proof/contract_modifiers_proof.rb --parse-only` | PASS: modifier fixtures parse; OOF fixture parses syntactically |
| 2 | `ruby igniter-lang/experiments/contract_modifiers_proof/contract_modifiers_proof.rb --classify` | PASS: `pure` CORE, non-pure ESCAPE |
| 3 | `ruby igniter-lang/experiments/contract_modifiers_proof/contract_modifiers_proof.rb --typecheck` | PASS: positives typed, `oof_m1_pure_with_escape` rejected with OOF-M1 |
| 4 | `ruby igniter-lang/experiments/contract_modifiers_proof/contract_modifiers_proof.rb --semanticir` | PASS: positives emit `contract_ir.modifier`; negative emits no SemanticIR |
| 5 | `ruby igniter-lang/experiments/contract_modifiers_proof/contract_modifiers_proof.rb --check-golden` | PASS: expected parsed/classified/typed/SemanticIR/diagnostic goldens match |
| 6 | `ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb` | PASS unchanged or documented `modifier: "pure"` migration |
| 7 | `ruby igniter-lang/experiments/stage2_close_candidate/stage2_close_candidate.rb` | PASS unchanged or documented `modifier: "pure"` migration |
| 8 | `ruby igniter-lang/experiments/production_compiler_cli/production_compiler_cli_proof.rb` | PASS; production CLI still compiles existing source |

Recommended default single command:

```bash
ruby igniter-lang/experiments/contract_modifiers_proof/contract_modifiers_proof.rb --check-golden
```

The proof summary should report:

```text
parser.implicit_pure: ok
parser.explicit_pure: ok
parser.observed: ok
parser.effect_privileged_irreversible: ok
classifier.modifier_mapping: ok
typechecker.oof_m1_pure_escape: ok
semanticir.modifier_field: ok
regression.stage1_stage2_unchanged: ok
```

---

## Implementation Dependencies

Required next-card changes:

1. Parser:
   - reserve or recognize modifier tokens before `contract`;
   - store normalized string `modifier`;
   - default missing modifier to `"pure"`;
   - preserve existing `contract Foo` syntax.
2. Classifier:
   - carry `modifier` into ClassifiedProgram;
   - map `observed/effect/privileged/irreversible` to ESCAPE;
   - preserve existing body-driven classification for `pure`;
   - expose body-level ESCAPE signal needed by OOF-M1.
3. TypeChecker:
   - detect explicit or implicit `pure` with `escape`;
   - emit OOF-M1 with contract name and source path/span if available;
   - block SemanticIR emission for OOF-M1.
4. SemanticIR Emitter:
   - emit `contract_ir.modifier` for every contract;
   - default existing contracts to `"pure"`;
   - keep PROP-019.1 envelope shape.
5. Golden/Regression Policy:
   - decide whether Stage 1-2 goldens are updated with `modifier: "pure"` or
     covered by a compatibility view;
   - rerun Stage 1 and Stage 2 close candidates.
6. Assembler:
   - no validation required in PROP-031;
   - pass `modifier` through if contract files/manifests include contract IR.

Out of scope for the next card unless explicitly assigned:

- Effect Surface validation;
- `via profile`;
- authority resolution;
- compensation/no-compensation rules;
- runtime enforcement;
- Bridge/platform integration.

---

## Status

Status: ready for implementation card.

This plan is not executable yet and no PASS result is claimed. It gives the
Compiler/Grammar or Implementation Agent a bounded fixture map and acceptance
matrix for PROP-031.

---

## Handoff

```text
Card: S3-R27-C4-P
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: contract-modifiers-proof-fixture-plan-v0
Status: done

[D] Decisions
- Use PROP-031 as source of truth; Ch10 is proposed spec anchor.
- Fixture set covers implicit pure, explicit pure, observed, effect,
  privileged, irreversible, OOF-M1, and SemanticIR modifier field shape.
- Keep this as plan only; no parser/compiler edits and no PASS claims.

[S] Shipped / Signals
- Added fixture list, expected outcomes, command matrix, SemanticIR expected
  shape, and implementation dependency map.

[T] Tests / Proofs
- No executable proof run; design/planning-only card.

[R] Risks / Recommendations
- Next implementation card must decide Stage 1-2 golden migration policy for
  `modifier: "pure"`.
- OOF-M2 and OOF-M3 remain reserved for PROP-035, not PROP-031.

[Next] Suggested next slice
- Implement `contract_modifiers_proof` with parser/classifier/typechecker/
  SemanticIR changes and run Stage 1-2 regressions.
```
