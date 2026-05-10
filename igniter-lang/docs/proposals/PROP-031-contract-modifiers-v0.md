# PROP-031: Contract Modifiers v0

Status: proposal
Date: 2026-05-10
Author: `[Igniter-Lang Compiler/Grammar Expert]`
Depends on: PROP-003 (fragment classification), PROP-014 (source surface), PROP-019 (SemanticIR)
Stage: 3
Source: `docs/meta-proposals/META-EXPERT-013-spec-extension-governance-v0.md`
Governance: META-EXPERT-013 §VI (acceptance criteria)

---

## § 1. Purpose

The current grammar treats all contracts identically:

```igniter
contract Add {
  input a: Integer
  input b: Integer
  compute sum = a + b
  output sum: Integer
}
```

This is correct for pure computation but insufficient when a contract reads from
an external sensor, mutates a payment gateway, or requires operator authority.
The fragment classifier must infer effect character from internal structure alone,
which produces coarse classification and no compile-time enforcement.

PROP-031 introduces five **contract modifiers** as an optional prefix. A modifier
declares the contract's effect character at the declaration site:

```igniter
pure         contract ScoreRisk(...)        -- no IO, deterministic
observed     contract ExtractClaims(...)    -- read-only external observation
effect       contract ChargeCustomer(...)   -- reversible external mutation
privileged   contract UnlockDoor(...)       -- requires explicit authority
irreversible contract DispatchEmergency(...) -- permanent, no rollback
```

This is a **backward-compatible, additive grammar extension**. Contracts without
a modifier are treated as implicitly `pure`. All existing programs compile without
modification.

Non-goals:

- No Effect Surface validation (deferred to PROP-035)
- No `via profile` binding (deferred to PROP-032)
- No authority resolution (deferred to PROP-034 + PROP-035)
- No runtime enforcement of modifier semantics (Phase 2)

---

## § 2. Grammar Change

### § 2.1 New production

```
contract-modifier  ::= "pure"
                     | "observed"
                     | "effect"
                     | "privileged"
                     | "irreversible"

contract-decl      ::= contract-modifier? "contract" ident type-params?
                       "(" param-list? ")" ("->" output-spec)?
                       "{" body-decl* "}"
```

The modifier is optional and precedes the `contract` keyword. No other grammar
productions change in this PROP.

### § 2.2 Backward compatibility guarantee

A `contract` declaration without a modifier is equivalent to `pure contract`.
The parser normalises both to the same AST node. All existing fixtures parse
without modification.

---

## § 3. Modifier Semantics

| Modifier | Effect character | Classifier | Compile-time constraint |
|----------|-----------------|------------|------------------------|
| `pure` (default) | No IO, deterministic | CORE | Body must not contain `escape` declarations |
| `observed` | Read-only external | ESCAPE | Body may contain `escape` for reads |
| `effect` | Reversible external mutation | ESCAPE | (Effect Surface in PROP-035) |
| `privileged` | Requires authority | ESCAPE | (Authority in PROP-035) |
| `irreversible` | Permanent consequence | ESCAPE | (Compensation in PROP-035) |

`observed`, `effect`, `privileged`, and `irreversible` are all ESCAPE at this stage.
The sub-classification within ESCAPE is defined when Effect Surface (PROP-035) lands.

---

## § 4. Classifier Changes

### § 4.1 Modifier → fragment class mapping

The Classifier receives the modifier from the parser AST. Mapping:

```
pure         → propagate existing CORE/ESCAPE logic (no change)
observed     → ESCAPE (regardless of body content)
effect       → ESCAPE (regardless of body content)
privileged   → ESCAPE (regardless of body content)
irreversible → ESCAPE (regardless of body content)
```

For `pure` contracts, the existing CORE/ESCAPE propagation logic applies as before.
The modifier does not override a body-level ESCAPE signal — it only enforces that
pure contracts do not carry ESCAPE content (see § 5 OOF rules).

### § 4.2 Fragment class in classified program

The classified program emits `modifier` alongside `fragment_class` per contract:

```json
{
  "kind": "contract",
  "name": "ScoreRisk",
  "modifier": "pure",
  "fragment_class": "CORE",
  ...
}
```

---

## § 5. TypeChecker Changes

### § 5.1 OOF-M1: pure contract with escape body

A `pure contract` (explicit or implicit) whose body contains an `escape` declaration
is an error. Pure contracts make a determinism promise that escape violates.

```
OOF-M1  pure contract body contains escape declaration
         severity: error
         message:  "pure contract '#{name}' cannot declare escape capabilities;
                    use 'observed' for read-only external access"
```

This is the only TypeChecker addition in PROP-031. Effect Surface constraints
(OOF-M2, OOF-M3) are deferred to PROP-035.

---

## § 6. SemanticIR Changes

### § 6.1 contract_ir node

The `contract_ir` node gains a `modifier` field:

```json
{
  "kind": "contract_ir",
  "name": "ExtractClaims",
  "modifier": "observed",
  "fragment_class": "ESCAPE",
  "nodes": [...],
  "outputs": [...],
  "requirements": [...],
  "escape_boundaries": [...]
}
```

Default value: `"pure"` (when no modifier is present in source).

No other SemanticIR nodes change. The `modifier` field is informational in this PROP;
runtime enforcement is Phase 2.

---

## § 7. Assembler Changes

None in this PROP. The Assembler passes `modifier` through from SemanticIR to the
assembled `.igapp` manifest without validation. PROP-035 adds manifest validation.

---

## § 8. Spec Anchor

PROP-031 is the implementation basis for `ch10-contract-modifiers.md` (status: proposed).

The new grammar extends ch2 (source-surface). An addendum note is appended to
`ch2-source-surface.md` when this PROP closes referencing the new production.

---

## § 9. Acceptance Criteria

Per META-EXPERT-013 §VI:

1. ✅ Parser accepts `[modifier] contract Name(params) { body }` — modifier optional
2. ✅ `contract Foo {}` = `pure contract Foo {}` — normalized in AST, backward compat
3. ✅ Classifier maps modifier → fragment class per §4.1 table
4. ✅ TypeChecker: `pure` + `escape` → OOF-M1 error
5. ✅ SemanticIR: `contract_ir` emits `modifier` field (default `"pure"`)
6. ✅ All existing Stage 1–2 regression fixtures PASS without modification
7. ✅ Positive fixture: `pure_contract_basic.ig` — no modifier, implicit pure
8. ✅ Positive fixture: `observed_contract_escape.ig` — observed + escape, ESCAPE class
9. ✅ Positive fixture: `effect_privileged_irreversible_variants.ig` — three modifiers
10. ✅ Negative fixture: `oof_m1_pure_with_escape.ig` → OOF-M1

---

## § 10. Fixtures

### § 10.1 Positive: pure (implicit)

```igniter
-- experiments/contract_modifiers_proof/pure_contract_implicit.ig
module Proof.ContractModifiers.PureImplicit

contract ScoreRisk {
  input contradiction_count: Integer
  input corroboration_count: Integer
  compute raw = contradiction_count - corroboration_count
  output raw: Integer
}
```

Expected: `fragment_class: "CORE"`, `modifier: "pure"`

### § 10.2 Positive: pure (explicit)

```igniter
-- experiments/contract_modifiers_proof/pure_contract_explicit.ig
module Proof.ContractModifiers.PureExplicit

pure contract ScoreRisk {
  input contradiction_count: Integer
  input corroboration_count: Integer
  compute raw = contradiction_count - corroboration_count
  output raw: Integer
}
```

Expected: same as implicit — backward compat proof.

### § 10.3 Positive: observed

```igniter
-- experiments/contract_modifiers_proof/observed_contract_basic.ig
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

Expected: `fragment_class: "ESCAPE"`, `modifier: "observed"`

### § 10.4 Positive: effect, privileged, irreversible

```igniter
-- experiments/contract_modifiers_proof/modifier_variants.ig
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

Expected: all three → `fragment_class: "ESCAPE"`, modifier fields match source.

### § 10.5 Negative: OOF-M1

```igniter
-- experiments/contract_modifiers_proof/oof_m1_pure_with_escape.ig
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

Expected: compilation fails, OOF-M1 reported for `BrokenPure`.

---

## § 11. Open Questions

**Q1:** Should `observed` be sub-classified as TEMPORAL when the observation is a
temporal read (`history_at`)? Current answer: No — TEMPORAL classification is
determined by body content (PROP-028), not by modifier. The modifier is orthogonal.
PROP-028 + PROP-031 compose independently.

**Q2:** Should modifiers be allowed on functions (`def`)? Current answer: No — functions
are pure by definition. Modifier syntax is contract-only in this PROP.

---

## § 12. Implementation Notes

Parser change is minimal: one optional token before `expect(:contract)` in
`parse_contract_decl`. The token is stored in the AST node as `modifier` (string).

Classifier change: read `modifier` from AST; if non-nil and not `"pure"`, classify as
ESCAPE before body analysis.

TypeChecker change: after body analysis, if `modifier == "pure"` and any node is ESCAPE,
emit OOF-M1.

SemanticIR change: include `modifier` in the `emit_contract_ir` output.

Total estimated scope: ~50 lines across parser.rb, classifier.rb, typechecker.rb,
semanticir_emitter.rb. Low risk.
