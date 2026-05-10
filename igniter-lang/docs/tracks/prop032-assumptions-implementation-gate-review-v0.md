# Track: PROP-032 Assumptions Implementation Gate Review (R31)

Card: S3-R31-C5-P (Compiler/Grammar Expert)
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: `compiler-grammar-expert`
Track: `prop032-assumptions-implementation-gate-review-v0`
Status: done
Date: 2026-05-10

---

## Purpose

Define the exact implementation gate for PROP-032 (`assumptions {}` block) before
any parser/classifier/typechecker/SemanticIR work begins. This card is a
gate-and-review card; no compiler code is written here.

The gate is organized by pipeline phase. Each phase has its own checklist. A phase
may not begin until its gate is satisfied. An "Allowed next implementation card"
template is produced at the end.

---

## Sources Read

| Document | Key use |
|----------|---------|
| `PROP-032-assumptions-block-v0.md` | Primary specification — grammar, AST shapes, OOF-A1, criteria |
| `docs/dev/semantic-governance-heat-map.md` | GI-1 status, Domain 2 debt classification |
| `docs/tracks/covenant-promise-enforcement-path-rule-v0.md` | P28 enforcement table, OQ-Filter-1, OQ-P28-1 |
| `docs/tracks/prop032-assumptions-block-draft-r30-v0.md` | Decision log, fixture plan |
| `roles/compiler-grammar-expert.md` | Role scope, default output, neighbor awareness |

---

## Gate Authority

This gate enforces the **PROP implementation discipline** from META-EXPERT-013 §VI:

> A PROP may not have compiler code written against it until the proposal is in
> `proposal` status, all acceptance criteria are specified, all open questions
> that would block the first implementation phase are resolved, and all required
> fixtures are designed.

The gate also applies the **Covenant Promise Enforcement Path Rule**
(`covenant-promise-enforcement-path-rule-v0.md`): PROP-032 must include an explicit
P28 enforcement clause for the assumptions surface (§P28-AC-1 below) before its
Classifier implementation is authorized.

---

## Pre-Gate Status Audit

### A. PROP authoring state

| Item | Status | Evidence |
|------|--------|----------|
| PROP-032 in `proposal` status | ✅ | `proposals/README.md` Stage 3 Active table |
| Grammar specified (§2.1) | ✅ | Productions for `assumptions-block`, `assumption-decl`, `uses-assumptions-decl` |
| Backward compat guarantee (§2.2) | ✅ | "No existing grammar changes; all programs without assumptions parse without modification" |
| AST shapes at all 4 stages (§4) | ✅ | Parser, Classifier, TypeChecker, SemanticIR JSON examples with delta notes |
| OOF-A1 message template (§5.4) | ✅ | Rule, severity, message, node, stage ownership — matches OOF-M1 pattern |
| Acceptance criteria (§11) | ✅ | 9 criteria; reviewable against fixture plan |
| Fragment class precedence (§5.2) | ✅ | `oof > temporal > escape > epistemic > core` |
| Non-goals table (§10) | ✅ | 10 explicit deferrals; constraints/form/ESM/runtime all deferred |
| Covenant interaction (§9) | ✅ | P22, P27, P28 each explicitly addressed |
| CSM rows updated | ✅ | `assumptions {}` and `uses assumptions NAME`: `spec_candidate` → `proposed` (R30) |
| `proposals/README.md` updated | ✅ | PROP-032 in Stage 3 Active; queue renumbered (GI-1 resolved) |

### B. Open question resolution required for gate

The following OQs from PROP-032 §13 must be resolved before Phase 1 begins:

| OQ | Blocking phase | Resolution required |
|----|---------------|---------------------|
| OQ-3: evidence list OOF (A1 vs P1) | Classifier phase | Yes — see §Gate Decision G-1 below |
| OQ-Filter-1: authority source | Implementation | No — see §Gate Decision G-2 below |
| OQ-1: contract-level modifier | Future PROP | No — body-level is the specified path |
| OQ-2: `expires_at` field | Future PROP | No — deferred explicitly |
| OQ-4: `assumption_refs` in evidence OOF | PROP-033 | No — PROP-033 scope |
| OQ-5: multiple blocks | Future PROP | No — one block per module is specified |
| OQ-P28-1: escape declaration naming | PROP-035 | No — does not affect PROP-032 |

---

## Gate Decisions

### G-1 — OQ-3 Resolved: Evidence List Names Are Not Validated in PROP-032

**Decision:** OOF-A1 fires **only** on `uses_assumptions` body declarations where
the referenced NAME is absent from the module `assumption_registry`. It does NOT
fire on evidence list entries in `output` nodes.

**Rationale:** PROP-032 §8.1 explicitly marks evidence list enforcement as
"informational in this PROP." The full OOF suite for missing/invalid evidence
citations is PROP-033 scope. Implementing evidence list validation in PROP-032
would introduce unspecified OOF codes and expand scope beyond the PROP boundary.

**Implementation consequence:**
- The Classifier's `when "output"` branch does NOT inspect the `evidence` field.
- The `evidence` field, if present, is passed through to classified/typed/SemanticIR
  output without validation.
- PROP-033 will own the first OOF codes that fire against evidence list contents.

**Gate clause:** Any implementation card that adds evidence list validation to the
PROP-032 Classifier work is out of scope and must be refused or split into a
PROP-033 sub-card.

### G-2 — OQ-Filter-1 Does Not Block PROP-032 Implementation

**Decision:** OQ-Filter-1 (PROP Governance Filter vs META-EXPERT-013 §VI authority
source) does NOT block PROP-032 implementation. Both documents are satisfied by
PROP-032:

1. PROP Governance Filter: PROP-032 is explicitly more legible than the status quo
   (§9.2). Filter check: accepted.
2. META-EXPERT-013 §VI acceptance criteria: 9 specified criteria (§11). All are
   verifiable against the described fixtures.

**Condition:** If the Architect resolves OQ-Filter-1 by declaring one document
non-authoritative, and the remaining authoritative document reveals a new
criterion, the implementation card must pause and the PROP must be amended before
proceeding. This is a monitoring condition, not a current blocker.

### G-3 — P28 Enforcement Clause for Assumptions Surface (Required)

**Decision:** The implementation card must satisfy the Covenant Promise Enforcement
Path Rule obligation for P28:

> PROP-032 (Gap-H) draft: must include P28 enforcement clause for assumptions block.

P28 per-surface table (from `covenant-promise-enforcement-path-rule-v0.md`):
- `assumptions {}` block naming → `planned PROP` — PROP-032

The PROP-032 acceptance criteria must include an explicit P28 enforcement
acceptance criterion (§P28-AC-1). This is added below as a **mandatory gate
addition** to the §11 list:

**§P28-AC-1 (gate-added):**
> Parser rejects any `assumption` body without a name — a parse error is emitted
> and the program does not reach the Classifier. This closes the P28 enforcement
> status for the `assumptions {}` surface from `planned PROP` to `enforced`.

This must appear in the implementation card's acceptance criteria and be verified
by a parse-error fixture. Gate clause: the implementation is not PASS-eligible
without this criterion being tested.

**Covenant Registry update required when PROP-032 reaches `experiment-pass`:**

| Registry entry | Before | After PROP-032 experiment-pass |
|---------------|--------|-------------------------------|
| P22 enforcement status | `planned PROP` (PROP-032) | `enforced` |
| P28 surface: `assumptions {}` naming | `planned PROP` (PROP-032) | `enforced` |

Both entries must be updated in the **same card** that claims experiment-pass.
This is the maintenance rule from `covenant-promise-enforcement-path-rule-v0.md`.

---

## Phase Gate Checklists

### Phase 1 Gate — Classifier Implementation

**Status: SATISFIED** (gate is currently met; implementation card may be issued)

| # | Gate item | Status | Notes |
|---|-----------|--------|-------|
| 1 | PROP-032 `proposal` status | ✅ | |
| 2 | Grammar productions specified (§2.1) | ✅ | |
| 3 | `assumption_registry` shape specified (§4.2) | ✅ | JSON example in PROP |
| 4 | `uses_assumptions` node `fragment_class: "epistemic"` specified | ✅ | §5.1 |
| 5 | Precedence rule specified: `oof > temporal > escape > epistemic > core` | ✅ | §5.2 |
| 6 | OOF-A1 specified: rule, severity, message template, stage ownership | ✅ | §5.4 |
| 7 | OQ-3 resolved (evidence list out of scope for Classifier) | ✅ | G-1 above |
| 8 | Positive fixture design: `assumption_basic` (escape + epistemic, accepted) | ✅ | §12 + track fixture plan |
| 9 | Positive fixture design: `epistemic_only_pure` (pure + epistemic → epistemic class) | ✅ | Track fixture plan §Fixture 3 |
| 10 | Negative fixture design: `oof_a1_undeclared_assumption` (OOF-A1, blocked, nil SIR) | ✅ | §12 |
| 11 | Backward compat: `parsed_program.fetch("assumptions", [])` default specified | ✅ | §2.2 guarantee implies this |
| 12 | P28 enforcement clause (§P28-AC-1) — must be in implementation card criteria | ✅ | G-3 above adds it |
| 13 | Regression baseline established: `contract_modifiers_proof --check-golden` PASS | ✅ | S3-R30-C3-P (25/25) |

**One implementation-specific requirement for the Classifier:**

The `contract_fragment_for` method in `igniter-lang/lib/igniter_lang/classifier.rb`
must insert the `epistemic` guard **between** the `escape` return and the final
`"oof"` fallback:

```ruby
# Existing (abridged):
return "escape" if (modifier != "pure" || declarations.any? { |d| d.fetch("fragment_class") == "escape" }) &&
                   declarations.none? { |d| d.fetch("fragment_class") == "oof" }
"oof"   # ← final fallback

# Required after PROP-032:
return "escape" if (modifier != "pure" || declarations.any? { |d| d.fetch("fragment_class") == "escape" }) &&
                   declarations.none? { |d| d.fetch("fragment_class") == "oof" }
return "epistemic" if declarations.any? { |d| d.fetch("fragment_class") == "epistemic" } &&
                      declarations.none? { |d| d.fetch("fragment_class") == "oof" }
"oof"   # ← final fallback (unchanged)
```

**Why this position:** Epistemic must not override escape or temporal. A contract
with `escape` and `epistemic` declarations retains `fragment_class: "escape"`.
The `assumption_refs` field is populated regardless of contract fragment class.

**Backward compatibility guard:** Existing golden files contain no `uses_assumptions`
nodes and no `assumptions: []` field at the program level. The Classifier body loop
uses a `case node.fetch("kind")` that currently silently skips unknown node kinds.
The implementation must add a `when "uses_assumptions"` branch to this case, which
will be dormant for all existing fixtures. `parsed_program["assumptions"]` must be
fetched with a default of `[]` to handle existing fixture JSON that lacks the field.

---

### Phase 2 Gate — TypeChecker Implementation

**Status: BLOCKED — requires Phase 1 golden files**

| # | Gate item | Status | Notes |
|---|-----------|--------|-------|
| 1 | Phase 1 Classifier goldens: `assumption_basic.classified.json` exist and PASS | 🔴 | Classifier not yet implemented |
| 2 | Phase 1 Classifier goldens: `epistemic_only_pure.classified.json` exist and PASS | 🔴 | |
| 3 | Phase 1 Classifier goldens: `oof_a1_undeclared_assumption.classified.json` exist and PASS | 🔴 | |
| 4 | OOF-A1 propagation spec confirmed by Classifier golden (oof_log field present) | 🔴 | Derived from Phase 1 |
| 5 | Strength range check (§5.5): `0.0 ≤ strength ≤ 1.0` — fixture needed | 🔴 | Optional 4th fixture |
| 6 | PROP-032 §6 TypeChecker changes reviewed against Classifier output shape | 🔴 | Needs golden to review against |

**Phase 2 note:** The TypeChecker change is minimal — OOF-A1 propagation follows
the identical pattern as OOF-M1 (`oof_log` → `type_errors`, `status: "blocked"`).
No new TypeChecker passes are introduced. Phase 2 should be a small delta on Phase 1.

---

### Phase 3 Gate — SemanticIR Implementation

**Status: BLOCKED — requires Phase 2 golden files**

| # | Gate item | Status | Notes |
|---|-----------|--------|-------|
| 1 | Phase 2 TypeChecker goldens: `assumption_basic.typed.json` exist and PASS | 🔴 | |
| 2 | Phase 2 TypeChecker goldens: `oof_a1_undeclared_assumption.typed.json` exist and PASS | 🔴 | |
| 3 | `assumption_registry` top-level field shape confirmed by Classifier golden | 🔴 | Carried through from Classifier |
| 4 | `contract_ir.assumption_refs: []` default value behavior specified | ✅ | §7.2 ("absent in typed → empty in contract_ir") |
| 5 | Existing `contract_ir` shape unchanged (§7.3) — no existing fields removed | ✅ | |
| 6 | Receipt `assumption_refs` propagation described (§8.2, name-trace only) | ✅ | |

---

### Phase 4 Gate — Experiment PASS Claim

**Status: BLOCKED — requires all three pipeline phase golden files**

| # | Gate item | Status | Notes |
|---|-----------|--------|-------|
| 1 | All 3 positive/negative fixture goldens exist at all 4 stages | 🔴 | |
| 2 | `assumptions_proof --check-golden` PASS | 🔴 | |
| 3 | `contract_modifiers_proof --check-golden` still PASS (regression) | ✅ | Baseline established |
| 4 | `classifier_pass_proof --check-golden` still PASS (regression) | 🔴 | Must re-run after Classifier change |
| 5 | `temporal_semanticir_access_node --check-golden` still PASS (regression) | 🔴 | Must re-run after Classifier change |
| 6 | §P28-AC-1: parse-error fixture for unnamed assumption body exists and fires | 🔴 | |
| 7 | Covenant Enforcement Registry: P22 → `enforced` | 🔴 | Must update in same card as PASS claim |
| 8 | Covenant Enforcement Registry: P28 `assumptions {}` surface → `enforced` | 🔴 | Must update in same card as PASS claim |
| 9 | CSM: `assumptions {}` and `uses assumptions NAME` → `experiment-pass` + golden anchor | 🔴 | Must update in same card as PASS claim |
| 10 | Heat Map Domain 2: `assumptions {}` row Parser/Class/TC/SIR columns → `⚙️` | 🔴 | Must update in same card as PASS claim |
| 11 | PROP-032 status in `proposals/README.md`: `proposal` → `experiment-pass` | 🔴 | Must update in same card as PASS claim |
| 12 | Missing Anchor Log: remove `assumptions {}` and `uses assumptions NAME` entries | 🔴 | Must update in same card as PASS claim |

---

## OOF-A1 Behavior Specification (Authoritative)

For implementation reference, the canonical OOF-A1 behavior:

```
Trigger:    `uses_assumptions` node in contract body where `name` is not a key in the
            module's assumption_registry (built from parsed_program["assumptions"])

Detected:   Classifier — in the body loop, `when "uses_assumptions"` branch

Action:     diagnostics << oof("OOF-A1",
              "contract '#{contract_name}' uses assumptions '#{name}' but no " \
              "assumption named '#{name}' is declared in this module",
              "uses_assumptions:#{name}")

Effect:     contract gets fragment_class: "oof" (via `contract_fragment_for`
            — diagnostics non-empty hits first guard)

TypeChecker: propagates OOF-A1 entry from classified contract's oof_log to
             type_errors; sets status: "blocked"

SemanticIR:  returns nil for any contract where type_errors is non-empty
             (existing behaviour, no change required)

NOT triggered by:  evidence list names in output nodes (G-1 decision)
NOT triggered by:  assumption_registry entries themselves (those are declarations,
                   not usages)
```

---

## Epistemic Fragment Precedence Guard Specification (Authoritative)

The precedence rule `oof > temporal > escape > epistemic > core` is implemented
by inserting one guard in `contract_fragment_for`:

**Insertion point:** After the `return "escape" if ...` guard, before the final
`"oof"` fallback.

**Guard text:**
```ruby
return "epistemic" if declarations.any? { |d| d.fetch("fragment_class") == "epistemic" } &&
                      declarations.none? { |d| d.fetch("fragment_class") == "oof" }
```

**Invariants verified by this guard:**
- Contracts with escape + epistemic → "escape" (escape wins, epistemic not reached)
- Contracts with temporal + epistemic → "temporal" (temporal wins, epistemic not reached)
- Contracts with ONLY epistemic + core → "epistemic" (new behavior)
- Contracts with oof diagnostics → "oof" (first guard, never reaches epistemic)
- `assumption_refs` field on the contract is populated regardless of fragment class
  (it is set before `contract_fragment_for` is called)

**Required to NOT regress:**
- `contract_modifiers_proof --check-golden` (covers temporal > escape precedence)
- `classifier_pass_proof --check-golden` (covers core, oof cases)

---

## Regression Safety Analysis

### Classifier body loop

Current `classify_contract` body loop uses a `case node.fetch("kind") when "input" / "escape" / ...` structure. Unknown node kinds are silently skipped (no `else` branch). This means:

- Existing fixtures (none contain `uses_assumptions` nodes) → no change in output
- Adding `when "uses_assumptions"` is purely additive

**Required:** `parsed_program.fetch("assumptions", [])` with default `[]`. Existing fixture JSON files do not have an `assumptions` key. Without the default, `Hash#fetch` raises `KeyError` on all existing programs.

### SemanticIR Emitter

The `emit_typed` method builds `contract_ir` nodes. Adding `assumption_refs` as a
field with a default empty array `[]` is purely additive. Existing golden files
will gain this new field when regenerated — they must be updated as part of the
Phase 3 implementation. This is a **golden file regeneration event**, not a
regression.

**Protocol:** When the SemanticIR emitter adds `assumption_refs: []`, run:
```bash
ruby igniter-lang/experiments/contract_modifiers_proof/contract_modifiers_proof.rb
# (write mode to regenerate goldens with new field)
```
Then `--check-golden` on all existing experiments before declaring Phase 3 PASS.

### Parser (deferred)

The PROP-032 proof strategy uses hand-authored parsed AST JSON fixtures (same
pattern as `temporal_semanticir_access_node` and `observed_temporal_precedence`).
The actual Igniter-Lang parser does NOT need to be changed for Phase 1–3 to reach
experiment-pass. Parser implementation is a separate, later card.

---

## Allowed Next Implementation Card Template

**Precondition for issuance:** Phase 1 Gate must be satisfied. It is currently
satisfied (see §Phase 1 Gate — all items ✅ or resolved by G-1/G-2/G-3 above).

---

```
Card: S3-R31-CX-P
Agent: [Igniter-Lang Compiler/Grammar Expert] (primary)
       [Igniter-Lang Research Agent] (fixtures + proof runner)
Role: compiler-grammar-expert + research-agent
Track: prop032-assumptions-classifier-implementation-v0

Gate reference: prop032-assumptions-implementation-gate-review-v0.md
                Phase 1 Gate satisfied as of S3-R31-C5-P.

Goal:
Implement PROP-032 Classifier support (Phase 1), TypeChecker passthrough
(Phase 2), and SemanticIR changes (Phase 3) and reach experiment-pass status
for PROP-032.

Scope:

[Compiler/Grammar Expert]
- Modify `igniter-lang/lib/igniter_lang/classifier.rb`:
  - Add `when "uses_assumptions"` branch to `classify_contract` body loop
  - Build `assumption_registry` from `parsed_program.fetch("assumptions", [])`
  - OOF-A1 detection: name lookup against registry; oof() call to diagnostics
  - `epistemic` fragment class: add guard in `contract_fragment_for`
    (insert after escape guard, before final "oof"; see gate §Epistemic Precedence)
  - `assumption_refs` field on classified contract (list of `uses_assumptions` names)
  - `assumption_registry` top-level field on classified_program output
  - Backward compat: `parsed_program.fetch("assumptions", [])` default
- Modify `igniter-lang/lib/igniter_lang/typechecker.rb`:
  - Propagate `assumption_refs` from classified → typed contract
  - OOF-A1 propagation from oof_log → type_errors (existing pattern; no new logic)
  - Strength range check (§5.5): when strength is non-null, verify 0.0 ≤ strength ≤ 1.0
- Modify `igniter-lang/lib/igniter_lang/semanticir_emitter.rb`:
  - Add `assumption_registry` top-level field to semantic_ir output
  - Add `assumption_refs: []` field to each `contract_ir` (default empty array)

[Research Agent]
- Create `igniter-lang/experiments/assumptions_proof/` directory
- Create `assumptions_proof/fixtures/assumption_basic.parsed_ast.json` (positive)
- Create `assumptions_proof/fixtures/epistemic_only_pure.parsed_ast.json` (positive)
- Create `assumptions_proof/fixtures/oof_a1_undeclared_assumption.parsed_ast.json` (negative)
- Create `assumptions_proof/fixtures/oof_p28_unnamed_assumption_body.parsed_ast.json`
  (negative — §P28-AC-1: parse-error for unnamed assumption; may require parser
   fixture approach; coordinate with Compiler/Grammar Expert on parse_errors field)
- Create `assumptions_proof/assumptions_proof.rb` proof runner
- Run write mode; run --check-golden; confirm PASS

Acceptance criteria (PROP-032 §11 + gate §P28-AC-1):

1. Classifier builds assumption_registry from parsed assumptions
2. Classifier assigns fragment_class: "epistemic" to uses_assumptions nodes
3. Classifier fires OOF-A1 for undeclared assumption reference
4. Classifier: pure contract + uses_assumptions only → fragment_class: "epistemic"
5. Classifier: observed contract + escape + uses_assumptions → fragment_class: "escape",
   assumption_refs populated
6. TypeChecker propagates OOF-A1; sets status: "blocked"
7. SemanticIR emits assumption_registry at top level
8. SemanticIR contract_ir has assumption_refs: ["homophily"] for positive fixture
9. OOF-A1 contract: SemanticIR nil
10. §P28-AC-1: unnamed assumption body → parse error (fixture shows parse_errors field
    populated; or use hand-authored fixture with parse_errors: [{...}] to simulate)
11. All existing golden checks PASS after Classifier/SemanticIR changes:
    - contract_modifiers_proof --check-golden
    - classifier_pass_proof --check-golden
    - temporal_semanticir_access_node --check-golden
    (Existing goldens may need regeneration if SemanticIR adds assumption_refs: [] field)

Do not implement:
- Parser grammar changes (hand-authored fixtures only)
- Evidence list validation (PROP-033 scope; G-1 gate decision)
- Cross-module assumption sharing
- Strength range enforcement beyond null-safe 0.0–1.0 check

On experiment-pass, update in the same card:
- Covenant Enforcement Registry: P22 → "enforced"
- Covenant Enforcement Registry: P28 surface "assumptions {} block" → "enforced"
- CSM: assumption rows → "experiment-pass" with golden anchor
- Heat Map Domain 2: assumption rows Parser/Class/TC/SIR → ⚙️
- PROP-032 status in proposals/README.md: proposal → experiment-pass
- Missing Anchor Log: remove assumption entries
```

---

## Gate Summary

| Phase | Gate status | Blocker |
|-------|------------|---------|
| Phase 1 — Classifier | **SATISFIED — implementation card may be issued** | None |
| Phase 2 — TypeChecker | BLOCKED | Phase 1 golden files required |
| Phase 3 — SemanticIR | BLOCKED | Phase 2 golden files required |
| Phase 4 — Experiment PASS | BLOCKED | All phases + Covenant/CSM updates required |

**The Phase 1 gate is satisfied as of this card.** All pre-conditions are met,
all blocking OQs are resolved (G-1 through G-3), and the implementation path is
fully specified. The "Allowed next implementation card" template above may be
issued immediately.

---

## Handoff

```text
Card: S3-R31-C5-P
Agent: [Igniter-Lang Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: prop032-assumptions-implementation-gate-review-v0
Status: done

[D] Decisions
- G-1: OQ-3 resolved. Evidence list names NOT validated in PROP-032 Classifier.
  OOF-A1 fires only on uses_assumptions nodes. Evidence validation is PROP-033 scope.
- G-2: OQ-Filter-1 does NOT block implementation. PROP-032 satisfies both PROP
  Governance Filter and META-EXPERT-013 §VI. Monitoring condition only.
- G-3: P28 enforcement clause §P28-AC-1 added as a mandatory gate criterion.
  Implementation card must include a parse-error fixture for unnamed assumption body.
  Covenant Registry P22 + P28 must both be updated on experiment-pass.
- Epistemic guard insertion point specified exactly: after escape guard, before
  final "oof" fallback in contract_fragment_for.
- Regression risk identified: SemanticIR adding assumption_refs: [] is a golden
  file regeneration event for all existing experiments. Protocol specified.
- Phase 1 gate: SATISFIED. Implementation card may be issued immediately.

[S] Shipped / Signals
- Gate checklist: 4 phases, 13/6/6/12 items respectively
- OOF-A1 canonical behavior specification (authoritative, implementation-ready)
- Epistemic fragment precedence guard specification (authoritative, code-ready)
- Regression safety analysis (Classifier body loop + SemanticIR emit)
- "Allowed next implementation card" template (Compiler/Grammar Expert + Research Agent)

[T] Tests / Proofs
- Gate review only. No code written. No golden files modified.

[R] Risks / Recommendations
- Biggest regression risk: SemanticIR assumption_refs: [] field addition will
  invalidate all existing .semantic_ir.json goldens (they will lack the field).
  Protocol: regenerate all experiment goldens immediately after SemanticIR change,
  then run --check-golden on all. Do this in a single atomic card, not piecemeal.
- §P28-AC-1 (unnamed assumption body → parse error): the current parser may not
  support the `assumptions {}` grammar at all. The "parse error" fixture may need
  to be implemented as a hand-authored `parse_errors` field in the parsed AST JSON,
  documenting what the parser SHOULD produce when the grammar lands. This is
  acceptable for experiment-pass; the parser enforcement note should be in the
  fixture header.
- OQ-P28-1 (escape declaration naming) is still Unknown. This does not block
  PROP-032 but must be answered before PROP-035 is scoped. Route to
  Compiler/Grammar Expert as a dedicated OQ-answer card.

[Next]
- Issue implementation card (S3-R31-CX-P) for PROP-032 Phase 1 Classifier.
- Coordinate with Research Agent for fixture authoring (can begin in parallel
  with Classifier implementation; fixtures are hand-authored and do not require
  the Classifier to exist first).
- After Phase 1 PASS: issue Phase 2 card for TypeChecker passthrough.
- After Phase 3 PASS: issue experiment-pass claim card with Covenant/CSM updates.
- Separate OQ-answer card: OQ-P28-1 (escape declaration naming enforcement state).
```
