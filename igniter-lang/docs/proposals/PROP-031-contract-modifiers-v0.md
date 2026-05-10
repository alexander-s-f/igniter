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

## § 3.5 ParsedProgram AST Delta

Each compiler stage gains exactly one field: `modifier`. All other fields are
unchanged. The examples below use `ScoreRisk` (pure, no modifier in source) and
`ReadSensor` (observed).

### Stage 1 — Parser output (`parsed_program.contracts[]`)

```json
{
  "kind": "contract",
  "name": "ScoreRisk",
  "modifier": "pure",
  "type_params": [],
  "body": [
    { "kind": "input",   "name": "contradiction_count", "type_annotation": "Integer" },
    { "kind": "compute", "name": "raw", "expr": { ... } },
    { "kind": "output",  "name": "raw", "type_annotation": "Integer" }
  ]
}
```

`modifier` is always present after parsing. When the source has no modifier keyword
the parser normalises to `"pure"`. Valid values: `"pure"`, `"observed"`, `"effect"`,
`"privileged"`, `"irreversible"`.

### Stage 2 — Classifier output (`classified_program.contracts[]`)

```json
{
  "kind": "classified_contract",
  "contract_id": "Proof.ContractModifiers.PureImplicit/ScoreRisk",
  "name": "ScoreRisk",
  "modifier": "pure",
  "fragment_class": "core",
  "symbols": [ ... ],
  "declarations": [ ... ],
  "dependency_graph": { "nodes": [ ... ], "edges": [ ... ] },
  "oof_log": []
}
```

`modifier` propagated from parser AST. `fragment_class` is set per §4.1.
OOF-M1 fires here when `modifier == "pure"` and body contains `escape` — the
`oof_log` entry is appended and `fragment_class` becomes `"oof"`.

### Stage 3 — TypeChecker output (`typed_program.contracts[]`)

```json
{
  "kind": "typed_contract",
  "contract_id": "Proof.ContractModifiers.PureImplicit/ScoreRisk",
  "name": "ScoreRisk",
  "modifier": "pure",
  "status": "accepted",
  "fragment_class": "core",
  "symbols": [ ... ],
  "declarations": [ ... ],
  "type_errors": []
}
```

`modifier` propagated from `classified_contract`. `status` is `"blocked"` when
OOF-M1 or other type errors are present.

### Stage 4 — SemanticIR Emitter output (`semantic_ir.contracts[]`)

```json
{
  "kind": "contract_ir",
  "contract_ref": "contract/ScoreRisk/sha256:...",
  "contract_name": "ScoreRisk",
  "modifier": "pure",
  "specialization_of": null,
  "type_args": {},
  "fragment_class": "core",
  "inputs":  [ { "name": "contradiction_count", "type": { "name": "Integer", "params": [] }, "lifecycle": "local" } ],
  "outputs": [ { "name": "raw",                 "type": { "name": "Integer", "params": [] }, "lifecycle": "session" } ],
  "nodes":   [ ... ],
  "escape_boundaries": []
}
```

`modifier` defaults to `"pure"` when not present in typed_contract (defensive).
For `"modifier": "observed"` the `fragment_class` is `"escape"` and
`escape_boundaries` lists the declared escape capabilities.

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
  "contract_ref": "contract/ExtractClaims/sha256:...",
  "contract_name": "ExtractClaims",
  "modifier": "observed",
  "specialization_of": null,
  "type_args": {},
  "fragment_class": "escape",
  "inputs": [...],
  "outputs": [...],
  "nodes": [...],
  "escape_boundaries": [...]
}
```

Default value: `"pure"` (when no modifier is present in source).
Note: `contract_name` is the correct field name in the actual SemanticIR emitter
(not `"name"`). See §3.5 for the complete delta at each stage.

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

### § 10.6 Research Agent (C4) Fixture Plan

**Experiment directory:** `experiments/contract_modifiers_proof/`

**Fixture files to create:**

| File | Kind | Expected `modifier` | Expected `fragment_class` | OOF? |
|------|------|---------------------|--------------------------|------|
| `pure_contract_implicit.ig` | positive | `"pure"` | `"core"` | none |
| `pure_contract_explicit.ig` | positive | `"pure"` | `"core"` | none |
| `observed_contract_basic.ig` | positive | `"observed"` | `"escape"` | none |
| `modifier_variants.ig` | positive | `"effect"`, `"privileged"`, `"irreversible"` | `"escape"` | none |
| `oof_m1_pure_with_escape.ig` | negative | `"pure"` | `"oof"` | OOF-M1 |

**Backward compatibility fixtures (existing regression suite must PASS unchanged):**

Run the full Stage 1–2 suite after implementing PROP-031:

```bash
ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb
ruby igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb --check-golden
```

**New experiment runner:**

```bash
ruby igniter-lang/experiments/contract_modifiers_proof/contract_modifiers_proof.rb
```

The runner must verify for each fixture:

1. Parser emits `"modifier"` field in contract node (§3.5 Stage 1 shape)
2. Classifier propagates `"modifier"` to `classified_contract` (§3.5 Stage 2 shape)
3. TypeChecker propagates `"modifier"` to `typed_contract` (§3.5 Stage 3 shape)
4. SemanticIR emits `"modifier"` in `contract_ir` (§3.5 Stage 4 shape)
5. `fragment_class` matches table above
6. OOF-M1 appears in `oof_log` for the negative fixture

**Expected SemanticIR shape for `pure_contract_implicit.ig`:**

```json
{
  "kind": "contract_ir",
  "contract_name": "ScoreRisk",
  "modifier": "pure",
  "fragment_class": "core",
  "escape_boundaries": []
}
```

**Expected SemanticIR shape for `observed_contract_basic.ig`:**

```json
{
  "kind": "contract_ir",
  "contract_name": "ReadSensor",
  "modifier": "observed",
  "fragment_class": "escape",
  "escape_boundaries": [{ "kind": "escape_boundary", "name": "sensor_read" }]
}
```

**Expected OOF entry for `oof_m1_pure_with_escape.ig`:**

```json
{
  "kind": "oof",
  "code": "OOF-M1",
  "contract": "BrokenPure",
  "message": "pure contract 'BrokenPure' cannot declare escape capabilities; use 'observed' for read-only external access",
  "severity": "error"
}
```

---

## § 11. Open Questions

**Q1:** Should `observed` be sub-classified as TEMPORAL when the observation is a
temporal read (`history_at`)? Current answer: No — TEMPORAL classification is
determined by body content (PROP-028), not by modifier. The modifier is orthogonal.
PROP-028 + PROP-031 compose independently.

**Q2:** Should modifiers be allowed on functions (`def`)? Current answer: No — functions
are pure by definition. Modifier syntax is contract-only in this PROP.

---

## § 12. PROP-032/033 Dependency List

PROP-032 and PROP-033 are both gated on PROP-031. This section documents exactly
what each downstream PROP inherits and what it must NOT add.

### PROP-032 — `via profile_name` binding

**Depends on:**
- Grammar: the `contract-decl` production in §2.1 must already contain
  `contract-modifier?`. PROP-032 extends it to:
  ```
  contract-decl ::= contract-modifier? "contract" ident type-params?
                    "(" param-list? ")" ("->" output-spec)?
                    ("via" ident)?
                    "{" body-decl* "}"
  ```
  The `"via"` clause is positioned after the signature and before the body.
  PROP-032 must not re-define `contract-modifier?` — it reuses the production
  from PROP-031 verbatim.
- Classifier: `classified_contract` must carry `modifier` so the classifier
  can validate that profile constraints match modifier (e.g., a `pure` contract
  cannot bind a profile that requires `effect`).
- SemanticIR: `contract_ir` must carry `modifier` so the profile resolution
  pass can emit `profile_binding` alongside it.

**Must not touch:** OOF-M1 code or the modifier→fragment_class mapping. Those
are frozen by PROP-031.

### PROP-033 — `output ... evidence [refs]`

**Depends on:**
- Grammar: PROP-031 is required only to establish that modifiers exist; PROP-033
  adds an optional `evidence [refs]` suffix to output declarations:
  ```
  output-decl ::= "output" ident (":" type)? ("evidence" "[" ref-list "]")?
  ```
  This is in the body, not on the contract header, so no grammar conflict with
  modifiers.
- SemanticIR: `contract_ir` must carry `modifier` so the emitter can validate
  that evidence refs pointing to external observations are only present in
  `observed`/`effect`/`privileged`/`irreversible` contracts (not `pure`).
  This constraint is in PROP-033 scope, not PROP-031 scope.

**Must not touch:** the contract-decl production or modifier logic. PROP-033 is
body-level only.

---

## § 13. Implementation Notes

Parser change is minimal: one optional token before `expect(:contract)` in
`parse_contract_decl`. The token is stored in the AST node as `modifier` (string).

Classifier change: read `modifier` from AST; if non-nil and not `"pure"`, classify as
ESCAPE before body analysis.

TypeChecker change: after body analysis, if `modifier == "pure"` and any node is ESCAPE,
emit OOF-M1.

SemanticIR change: include `modifier` in the `emit_contract_ir` output.

Total estimated scope: ~50 lines across parser.rb, classifier.rb, typechecker.rb,
semanticir_emitter.rb. Low risk.
