# Track: Covenant — Accountability Postulates and Governance Filter (R29)

Card: S3-R29-C4-P (Meta Expert)
Agent: `[Igniter-Lang Meta Expert]`
Role: `meta-expert`
Track: `covenant-accountability-postulates-r29-v0`
Status: done
Date: 2026-05-10

---

## Purpose

Promote R28 accountability insights (V-1 through V-4) into the Language Covenant
as governing postulates and a formal PROP acceptance filter.

No compiler semantics. No implementation scope. Documentation only.

---

## Deliverables

### 1. Core Axiom → Core Axioms

The single "Core Axiom" (Honesty) was expanded to "Core Axioms" with two named
axioms:

| Axiom | Statement |
|-------|-----------|
| Axiom 1 — Honesty | "A program is an honest account of what it does to the world." |
| Axiom 2 — Accountability (V-1) | "A program is an accountable semantic artifact." |

The two axioms are explicitly distinct: honesty is the ethical commitment (the
language will not let a program hide what it does), accountability is the
architectural commitment (every primitive exists to make accountability legible).
A program can be honest without being accountable — both must hold.

### 2. Postulate 27 — Accountability as Architecture (V-1)

Articulates V-1 with a concrete primitive linkage table:

| Primitive | Accountability role |
|-----------|---------------------|
| `receipt` | Execution trace |
| `evidence` | Claim lineage |
| `assumptions {}` | Epistemic provenance |
| `constraints {}` | Normative boundary |
| `escape` modifier | Declared I/O intent |
| contract modifiers | Effect character |
| managed loops | Controlled iteration surface |
| synthetic markers | Simulated world visibility |
| `form` constructors | Named domain constructor |

This postulate makes V-1 a design test: any feature that cannot be placed in
this table is a candidate for rejection under the PROP Governance Filter.

### 3. Postulate 28 — No Unnamed Block May Carry Semantic Identity (V-4)

Promotes the existing "What the Language Forbids" entry to a governing postulate.

Surfaces named:
- `escape` declarations → referenced in `escape_boundaries` of receipts
- loop class declarations → referenced in managed loop contract
- `assumptions {}` blocks → carried through `evidence []` chain
- `constraints {}` blocks → carried through `constraint_hash`
- `invariant` blocks → referenced in violation observation receipts

The core claim: naming is not bureaucracy — it is the prerequisite for
accountability. An unnamed construct with semantic consequence is a compile error.

"What the Language Forbids" entry updated to reference P28.

### 4. PROP Governance Filter (V-2)

New top-level section between the Epistemic State Machine and the Three Doctrines.

The filter is a mandatory three-way acceptance criterion at PROP review time:

| Answer | Acceptance |
|--------|-----------|
| More legible | Preferred |
| Neutral | Permitted |
| Less legible | Rejected |

Includes feature-category table (pure computation / external access / hidden state /
unnamed blocks / hidden audit), corollary for deprecation, and explicit grounding in
Axiom 2 + Postulate 27.

---

## Linkage to Existing Surfaces

The card required linking V-1 and V-4 to existing language surfaces. All links were
made explicit in Postulate 27's primitive table. No new surfaces were created —
the table is a classification of existing primitives only.

`form` constructors appear in the table as the extension mechanism for domain
vocabulary (V-5). This is classification, not authorization — `form` remains
spec-candidate status.

---

## Open Questions for Compiler/Grammar Expert

**OQ-1: Unnamed block enforcement scope**

Postulate 28 states that unnamed blocks with semantic consequence are a compile
error. The current compiler enforces this for invariant names (parser rejection)
but not yet for all escape declarations or loop classes. The Compiler/Grammar
Expert should confirm which of the following are currently enforced vs. policy-only:

| Construct | Currently enforced? |
|-----------|---------------------|
| Unnamed `escape` declaration | Unknown |
| Unnamed loop class | Unknown (loop classes not yet implemented) |
| Unnamed `assumptions {}` block | N/A (Gap-H not implemented) |
| Unnamed `constraints {}` block | N/A (Gap-J not implemented) |
| Unnamed `invariant` block | Yes — parser requires name |

If enforcement is not yet wired, P28 is a **governing commitment** (binding on
future work) rather than a **current enforcement rule**. The Covenant is the right
place for it regardless — it governs what the compiler must eventually enforce.

**OQ-2: PROP Governance Filter — integration with META-EXPERT-013**

The filter (V-2) was written as a standalone Covenant section. META-EXPERT-013
§VI defines PROP acceptance criteria. These should be reconciled: either the
filter is appended to META-EXPERT-013 §VI as an explicit acceptance criterion, or
META-EXPERT-013 §VI should cite the Covenant section as normative. The Covenant
section alone is sufficient for now; reconciliation is a follow-up for the next
META-EXPERT proposal.

**OQ-3: `form` constructor in Postulate 27**

`form` constructors appear in the primitive table as "Named domain constructor —
no unnamed semantic structure." This presupposes that `form` is an accepted
language primitive. Gap-I (form constructors) is currently spec-candidate status
(no PROP, no parser implementation). The Covenant entry is aspirational. If `form`
does not advance to PROP, the table row should be removed or marked pending.

---

## Scope Boundaries

- No compiler semantics created or modified.
- No new grammar introduced.
- No PROP-032 re-authored (assumptions block remains Gap-H, TBD PROP).
- V-3 (temporal fragment precedence) is already locked in classifier.rb and
  documented in PROP-031 §14.4. No Covenant postulate was added for V-3 — it
  is an implementation rule, not a programmer-facing axiom.
- V-5 (domain constructors as `form` applications) is referenced in P27's table
  but not given its own postulate — it remains an architectural principle pending
  Gap-I / a formal PROP.

---

## Handoff

```text
Card: S3-R29-C4-P
Agent: [Igniter-Lang Meta Expert]
Role: meta-expert
Track: covenant-accountability-postulates-r29-v0
Status: done

[D] Decisions
- "Core Axiom" expanded to "Core Axioms" with explicit Honesty (Axiom 1) and
  Accountability (Axiom 2) distinction. Both are governing; neither supersedes the other.
- Postulate 27 (Accountability as Architecture) names the primitive linkage that V-1 implies.
  It is the design test: can this feature be placed in the accountability table?
- Postulate 28 (No Unnamed Block) promotes the existing Forbids entry to governing level.
  The compiler must eventually enforce it; current enforcement scope is OQ-1.
- PROP Governance Filter (V-2) is now a Covenant section, not just a principle from
  the R28 cross-review. It applies at PROP acceptance time.
- V-3 (temporal fragment precedence) remains in PROP-031 §14.4; not a Covenant postulate.
- V-5 (form constructors) appears in P27 table as spec-candidate classification only.

[S] Shipped / Signals
- language-covenant.md: Core Axioms (2), 28 Postulates (added P27 + P28),
  PROP Governance Filter section, updated Forbids entry, updated cross-reference table.
- Track doc: this file.

[T] Tests / Proofs
- Documentation only. No code changes. No proof surface affected.

[R] Risks / Recommendations
- OQ-1: P28 enforcement scope — Compiler/Grammar Expert should confirm and flag
  any gap between Covenant commitment and current compiler enforcement.
- OQ-2: PROP Governance Filter vs META-EXPERT-013 §VI — reconcile in next META-EXPERT.
- OQ-3: `form` constructor in P27 table — contingent on Gap-I advancing to PROP.

[Next] Suggested next slice
- R29-C2-P: CSM bootstrap — canonical entity index (still open from R28 meta-cards)
- PROP-032: assumptions {} block (Gap-H HIGH priority)
- META-EXPERT reconciliation: PROP Governance Filter → META-EXPERT-013 §VI
```
