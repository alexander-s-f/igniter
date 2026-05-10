# Track: Agent-D Cross-Review — Values and Meta Expert Cards (R28)

Card: S3-R28-C4-P (Meta Expert)
Agent: `[Igniter-Lang Meta Expert]`
Role: `meta-expert`
Track: `agent-d-cross-review-values-and-meta-cards-r28-v0`
Status: done
Date: 2026-05-10

---

## Purpose

Formalize values and architectural principles surfaced by Agent-D's cross-review
of R27/R28 work. Cut R29 cards for the Meta Expert agenda that follows from those
principles.

This card does not implement language features. It governs what comes next.

---

## Values Crystallized

### V-1 — "Programs Are Accountable Semantic Artifacts"

This is the foundational axiom of Igniter-Lang, retroactively.

It explains why every language primitive exists:

| Primitive | Accountability role |
|-----------|---------------------|
| `receipt` | Execution trace |
| `evidence` | Claim lineage |
| `assumptions {}` | Epistemic provenance (Gap-H) |
| managed loops | Controlled iteration surface |
| effect surface | Authorized escape hatch |
| `synthetic` markers | Simulated world visibility |
| `escape` modifier | Declared I/O intent |

**Implication:** language decisions are not ergonomic tradeoffs. They are
accountability decisions. A feature that makes the programmer's life easier but
hides execution reality from audit violates the core doctrine.

---

### V-2 — Audit Trail as PROP Acceptance Filter

From the review and confirmed by Meta Expert position:

> "If a language feature does not support or is neutral to the audit trail, it
> may enter core. If a feature actively hides execution reality, it must not."

Specific formulation of the filter:

| Feature category | Acceptance |
|-----------------|------------|
| Computation that is deterministic and pure | Allowed without declaration |
| External access (I/O, time, randomness) | Requires explicit modifier |
| Non-deterministic or environment-dependent | Requires explicit declaration |
| Hidden state access | Forbidden |
| Unnamed blocks that carry semantic identity | Forbidden |

This filter should become a governing rule in the Covenant, not just an
observation.

---

### V-3 — Temporal Fragment Class Takes Precedence Over Modifier-Based Escape

Discovered during PROP-031 Stage 3 regression fix.

A contract with `observed` modifier that contains temporal read declarations
(`History[T]`, `BiHistory[T]`) must retain `fragment_class: "temporal"`,
not be overridden to `"escape"` by the modifier.

**Rationale:** the temporal fragment class is a refined escape subtype. Overriding
it loses the semantic distinction that the runtime inspection infrastructure
depends on.

**Implementation:** `contract_fragment_for` in `classifier.rb` gives temporal
declarations precedence; modifier widens escape only when no temporal declarations
are present.

---

### V-4 — "No Unnamed DSL Blocks"

An unnamed block is invisible to audit, linkage, and replay. This is not a style
rule — it is a consequence of V-1.

If a block carries semantic identity (an effect, a loop policy, an assumption
context) but has no name, it cannot be referenced in a receipt, linked in
evidence, or surfaced in an observation.

This principle already governs invariants, escape declarations, and loop classes.
It must be stated as a Covenant postulate.

---

### V-5 — Domain Constructors Are `form` Applications

`population`, `scenario`, `placement`, `group` are not core keywords. They are
`form` applications — user-visible constructors that map to core type primitives.

```
form population -> PopulationSpec
```

The compiler knows `form`. Domain knowledge stays in application code. This is
the correct extension mechanism for domain-specific vocabulary.

---

## R29 Meta Expert Cards

### Card S3-R29-C1-P — Covenant: Postulate 24 + Governance Filter

**Agent:** `[Igniter-Lang Meta Expert]`
**Scope:** `igniter-lang/docs/language-covenant.md`

**Deliverables:**

1. Add **Postulate 24**: "A program is not a procedure. A program is an
   accountable artifact. Every language primitive exists to make that
   accountability legible." Anchor to V-1.

2. Add **Governance Filter** section: formalize V-2 as a decision rule that
   applies at PROP acceptance time. Any PROP that proposes a feature must answer:
   "Does this feature leave the audit trail more legible, neutral, or less
   legible?"

3. Add **Postulate 25**: "No unnamed block may carry semantic identity." Anchor
   to V-4. Link to invariant, escape, loop, and assumption declaration rules.

**Why now:** Agent-D identified that the Covenant became a governing layer in
R27/R28. Making the governance rules explicit locks this in before Stage 3
Language Lane work begins.

---

### Card S3-R29-C2-P — CSM: Canonical Semantic Model Bootstrap

**Agent:** `[Igniter-Lang Meta Expert]`
**Scope:** `igniter-lang/docs/dev/canonical-semantic-model.md` (new)

**Deliverables:**

Create a verifiable entity index with columns:

| Column | Description |
|--------|-------------|
| `entity` | Language concept name |
| `status` | `implemented`, `spec_candidate`, `proposed` |
| `pipeline_entry_point` | Where it first appears in the compiler pipeline |
| `classifier_fragment` | Fragment class assigned by the Classifier |
| `golden_anchor` | Representative golden file path |
| `PROP` | Authorizing or planned PROP |
| `Covenant` | Postulate(s) that govern it |

Initial entities to document:

- Contract (all modifiers)
- Type declaration
- Receipt
- Escape declaration
- Stream node
- Temporal read (History / BiHistory)
- Assumption (Gap-H, spec candidate)
- Form constructor (Gap-I, spec candidate)
- Loop class (spec candidate, Stage 3 Language Lane)
- OOF code registry (OOF-M1 through OOF-S4 as of R28)

**Why:** Agent-D correctly identified that with 10+ semantic entities, the
compiler becomes impossible to reason about without a canonical index. CSM is
that index — verifiable against golden files, not aspirational doc.

**Constraint:** CSM must not become a waterfall design document. It is an index.
If an entity doesn't have a golden anchor, its `status` is at most
`spec_candidate`.

---

### Card S3-R29-C3-P — Gap-H PROP Bootstrap (Assumptions)

**Agent:** `[Igniter-Lang Meta Expert]` → handoff to `[Compiler/Grammar Expert]`
**Scope:** `igniter-lang/docs/proposals/PROP-032-assumptions-v0.md` (new)

**Deliverables:**

Write PROP-032 draft for the `assumptions {}` block:

1. **Motivation:** Gap-H: assumptions are a separate semantic layer distinct from
   type, DTO, config, constant, or annotation. An `Assumption` = named premise +
   optional parameter + audit dependency.

2. **Grammar anchor:** `assumptions { premise :name, requires: :authority_ref }`
   or similar. Must be compatible with `form` extension pattern (Gap-I).

3. **Covenant anchor:** Postulate 22 (Assumption Visibility) — already written.
   PROP-032 is the implementation path.

4. **Compiler stage ownership:** Parser (AST node), Classifier (epistemic
   fragment class?), TypeChecker (authority ref resolution).

5. **Research Agent fixture plan:** at minimum one positive case and one OOF
   case (undeclared assumption used in contract body).

**Why now:** Gap-H was identified as "HIGH priority, Stage 3 Language Lane
candidate" in the gap analysis. PROP-032 bootstrap unblocks the Research Agent
from beginning fixture exploration.

**Scope limit for this card:** PROP draft + fragment class decision only. No
implementation.

---

## R28 Regression Fix Record

The following Stage 3 OOF-M1 regressions were resolved in this card as a
blocking prerequisite:

| Contract | File | Fix |
|----------|------|-----|
| `IntegerWindowSum` | `runtime_smoke_post_switch_full_coverage/runtime_smoke_post_switch_full_coverage.rb` (STREAM_SOURCE constant) | `observed contract` |
| `IntegerWindowSum` | `stream_t_proof/stream_integer_window.ig` | `observed contract` |
| `TechnicianJobCountAt` | `history_type_proof/history_integer_point_access.ig` | `observed contract` |
| `SparkCRMBiHistorySourceParity` | `typed_emission_main_path_parity/sparkcrm_bihistory_source.ig` | `observed contract` |

**Classifier fix:** `contract_fragment_for` was revised so that temporal
declarations (History, BiHistory) take precedence over modifier-based escape
classification. A contract with `modifier: "observed"` and temporal reads retains
`fragment_class: "temporal"`. This is V-3 above.

---

## Full Post-R28 Command Matrix (after fix)

| Surface | Result |
|---------|--------|
| `contract_modifiers_proof --check-golden` | PASS (22/22) |
| `classifier_pass_proof --check-golden` | PASS |
| `typechecker_proof --check-golden` | PASS |
| `source_to_semanticir_fixture --check-golden` | PASS |
| `stage1_close_candidate` | PASS (5/5) |
| `stage2_close_candidate` | PASS (7/7) |
| `runtime_smoke_post_switch_full_coverage` | PASS (9/9) |
| `executor_boundary_cache_key_contract` | PASS (10/10) |
| `executor_approval_token_report_proof` | PASS (16/16) |
| `production_compiler_cli_proof` | PASS (14/14) |

---

## Handoff

```text
Card: S3-R28-C4-P
Agent: [Igniter-Lang Meta Expert]
Role: meta-expert
Track: agent-d-cross-review-values-and-meta-cards-r28-v0
Status: done

[D] Decisions
- V-1 through V-5 are canonical values of the language design, derived from
  Agent-D cross-review and confirmed by R28 implementation experience.
- Temporal fragment class takes precedence over modifier-based escape (V-3).
  Fixed in classifier.rb.
- Stage 3 OOF-M1 regressions resolved by adding `observed` modifier to stream
  and temporal source fixtures.
- R29 agenda: Covenant governance (C1), CSM bootstrap (C2), PROP-032 Gap-H (C3).

[S] Shipped / Signals
- Full post-R28 matrix: 10/10 proof surfaces PASS.
- Classifier fix verified against contract_modifiers_proof golden check.
- Three new R29 Meta Expert cards cut: C1 (Covenant), C2 (CSM), C3 (PROP-032).

[T] Tests / Proofs
- All Stage 1, 2, 3 proofs PASS as of 2026-05-10.

[R] Risks / Recommendations
- PROP-032 (assumptions) is Gap-H HIGH priority. Fixture exploration should
  begin in R29 Research Agent pass before grammar decisions are locked.
- CSM must not grow into a design document. Keep it as a verifiable index.

[Next] Suggested next slice
- R29-C1-P: Covenant Postulate 24 + Governance Filter + Postulate 25
- R29-C2-P: CSM bootstrap — entity index table
- R29-C3-P: PROP-032 assumptions draft
```
