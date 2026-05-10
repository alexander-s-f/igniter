# Track: Covenant Promise Enforcement Path Rule v0

Card: S3-R30-C5-P
Agent: `[Igniter-Lang Meta Expert]`
Role: meta-expert
Track: `covenant-promise-enforcement-path-rule-v0`
Status: done
Date: 2026-05-10

---

## Goal

Formalize the rule: every Covenant promise must declare an enforcement path.
Add the Covenant Promise Enforcement Registry to `language-covenant.md`.
Produce the P28 per-surface enforcement table.
Route open questions to Compiler/Grammar Expert.

No compiler semantics. No implementation scope. Documentation only.

---

## Problem Statement

The Language Covenant (`language-covenant.md`) contains 28 postulates and two
governing axioms. Before this card, the Covenant had no systematic answer to the
question: "Is this postulate enforced by the compiler today, or is it an
aspirational commitment?"

The Cross-Reference to Spec table listed PROP numbers and ✅/pending/open status,
but did not distinguish between:
- a postulate that the compiler currently rejects violations of
- a postulate for which a PROP is queued
- a postulate that is intentionally non-compiler (governed by review or filter)
- a postulate that is defined in concept but has no PROP yet

This ambiguity matters because:
1. Agents reading the Covenant may treat any governing postulate as currently
   enforced, leading to incorrect compiler capability claims.
2. PROP authors have no checklist item requiring them to update the enforcement
   registry when enforcement ships.
3. Postulate 28 specifically names five construct families, but R29-C4-P (OQ-1)
   and S3-R29-X1-S (C-3) both flagged that only one of the five is currently
   enforced — with no tracking document for the others.

---

## Deliverables

### 1. Status Vocabulary (5 statuses)

Added to the Covenant as the opening of the Enforcement Registry section:

| Status | Meaning |
|--------|---------|
| `enforced` | Compiler currently rejects violations |
| `planned PROP` | PROP exists or is queued to wire enforcement |
| `spec_candidate` | Concept defined; no PROP queued yet |
| `doctrine-only` | Intentionally non-compiler; explain the mechanism |
| `partial` | Enforced for some named surfaces; expand in subtable |

### 2. The Enforcement Rule

> Every postulate added to the Covenant must carry one of the above statuses
> before it is accepted. A postulate without a status is incomplete.

Added: maintenance rule — when a PROP ships enforcement, the registry must be
updated in the same PROP card or a same-round Meta Expert status card.
Drift = spec-lag item (META-EXPERT-012).

### 3. Postulate Enforcement Status Registry (all 28 postulates)

Full table in `language-covenant.md` §"Postulate Enforcement Status Registry".

Summary of assigned statuses:

| Status | Postulates |
|--------|-----------|
| `enforced` | P1, P2, P3, P5, P13, P18 |
| `planned PROP` | P4, P6, P7, P8, P9, P10, P11, P12, P14, P15, P16, P17, P19, P20, P21, P22 |
| `spec_candidate` | P23, P24, P25, P26 |
| `doctrine-only` | P27 |
| `partial` | P28 |

### 4. Postulate 28 Per-Surface Enforcement Table

| P28 surface | Current enforcement | Path |
|------------|---------------------|------|
| `invariant` block naming | **`enforced`** — parser requires name; parse error today | Already enforced |
| `escape` declaration naming | **Unknown** — OQ-P28-1 (Compiler/Grammar Expert must verify) | `planned PROP` — PROP-035 |
| Loop class declaration naming | **N/A** — not yet implemented | `planned PROP` — PROP-036+ |
| `assumptions {}` block naming | **N/A** — Gap-H not implemented | `planned PROP` — PROP-032 |
| `constraints {}` block naming | **N/A** — Gap-J not implemented | `spec_candidate` → `planned PROP` (Gap-J) |

**Key finding:** OQ-1 from `covenant-accountability-postulates-r29-v0.md` asked
for this table but did not produce it. This card provides the definitive P28
enforcement state. Only `invariant` block naming is currently enforced. Four
surfaces are either unimplemented or unverified. This is a governing commitment
gap, not a safety risk for current code — but future PROP authors for PROP-035,
PROP-036+, PROP-032, and Gap-J must each include a P28 enforcement clause for
their surface.

### 5. Cross-Reference to Spec Table — enforcement column added

The existing Cross-Reference to Spec table in the Covenant was updated to add an
"Enforcement status" column alongside the existing "Spec status" column. This
makes the distinction visible at a glance without requiring a separate lookup in
the registry.

### 4 Open Questions Routed to Compiler/Grammar Expert

| OQ | Summary |
|----|---------|
| OQ-P28-1 | Is an unnamed `escape` declaration currently a parse error? Classify row as `enforced` or `planned PROP`. Closes the "Unknown" entry in the P28 table and the longstanding R29 OQ-1. |
| OQ-P28-2 | Should PROP-035 include an explicit P28 enforcement clause for escape naming, or should a separate PROP handle it? |
| OQ-P28-3 | PROP-036+ (Managed Recursion) must state the P28 loop class naming requirement as an explicit acceptance criterion. Confirm placement: PROP-036+ acceptance criteria or ch13 invariant section? |
| OQ-Enforcement-1 | Should the enforcement registry maintenance rule be added to META-EXPERT-013 §VI PROP acceptance criteria, so every PROP card includes a Covenant registry update obligation? |

---

## What Changed

| File | Change |
|------|--------|
| `docs/language-covenant.md` | Added "Covenant Promise Enforcement Registry" section: status vocabulary, rule, 28-postulate status table, P28 per-surface enforcement table, 4 open questions. Updated Cross-Reference to Spec table with enforcement column. Updated header date. |
| `docs/tracks/covenant-promise-enforcement-path-rule-v0.md` | This track doc. |

---

## Key Decisions

**D1 — Five statuses, not four.**
The card specified four statuses (enforced / planned PROP / spec_candidate /
doctrine-only). A fifth (`partial`) was added for P28, which cannot be honestly
classified as any of the four — it is enforced for one surface and pending for
four others. `partial` requires a per-surface subtable, making it a stricter
status, not a weaker one.

**D2 — P27 is `doctrine-only`.**
P27 (Accountability as Architecture) is the governance axiom from which all
compiler-enforced postulates derive authority. Its enforcement mechanism is the
PROP Governance Filter — a review-time check, not a compiler check. Marking P27
as `doctrine-only` is not a demotion; it is an accurate classification. Every
compiler-enforced postulate is an instance of P27 in action.

**D3 — P28 escape declaration status is `Unknown`, not `planned PROP`.**
The R29-X1-S discussion (C-3) flagged that escape declaration naming enforcement
is unverified. Rather than assume planned PROP, this table records the honest state
(`Unknown`) and routes OQ-P28-1 to the Compiler/Grammar Expert. Once OQ-P28-1 is
answered, the row is updated to either `enforced` or `planned PROP`. Premature
promotion would mislead future agents reading the table.

**D4 — Enforcement registry is in the Covenant, not the CSM.**
The Canonical Semantic Model (CSM) tracks entities. The Covenant tracks
commitments. Enforcement status belongs in the Covenant because it is a governance
commitment (what the language promises to enforce), not an implementation fact
(what exists on disk). When enforcement ships, both the Covenant (status →
`enforced`) and the CSM (golden anchor added) must be updated — but they track
different things.

**D5 — P11 and P12 are `planned PROP`, not `enforced`.**
PROP-031 ✅ classifies `observed` modifier and assigns fragment class. But P11
promises the compiler will not allow uncertainty to be silently discarded (required
field enforcement), and P12 promises simulated receipts are a distinct type that
cannot be substituted for real receipts (type incompatibility at contract
boundaries). Both require PROP-035 for full enforcement. Classifying them as
`enforced` based on PROP-031 alone would overstate current compiler capability.
`planned PROP` is the honest status.

---

## Scope Boundaries

- No compiler semantics created or modified.
- No new grammar introduced.
- No PROP authored or modified.
- P28 enforcement claim for `invariant` blocks (parse error) is accepted as
  known from R29-C4-P + existing parser evidence. It is not independently
  re-verified in this card. If this claim is incorrect, OQ-P28-1 will surface it.

---

## Handoff

```text
Card: S3-R30-C5-P
Agent: [Igniter-Lang Meta Expert]
Role: meta-expert
Track: covenant-promise-enforcement-path-rule-v0
Status: done

[D] Decisions
- Five enforcement statuses: enforced / planned PROP / spec_candidate /
  doctrine-only / partial.
- Every Covenant postulate now has a status. P1/P2/P3/P5/P13/P18 = enforced.
  P27 = doctrine-only. P28 = partial (invariant enforced; others pending/unknown).
- P28 per-surface table: only invariant naming is currently enforced.
  escape declaration status: Unknown (OQ-P28-1 routed to Compiler/Grammar Expert).
- Maintenance rule: enforcement status must be updated when PROP ships enforcement.
  Drift = spec-lag item.

[S] Shipped / Signals
- docs/language-covenant.md: Covenant Promise Enforcement Registry section added.
  Cross-Reference to Spec table updated with enforcement column.
- docs/tracks/covenant-promise-enforcement-path-rule-v0.md: this track doc.

[T] Tests / Proofs
- Documentation only. No code changes. No proof surface affected.

[R] Risks / Recommendations
- OQ-P28-1 (escape declaration naming enforcement) must be answered before PROP-035
  is scoped. If escape declarations are currently unnamed and silently accepted, the
  PROP-035 acceptance criteria must include a P28 enforcement clause.
- OQ-Enforcement-1: adding registry maintenance to META-EXPERT-013 §VI acceptance
  criteria prevents enforcement drift as future PROPs ship.
- The four `spec_candidate` postulates (P23, P24, P25, P26) have no PROP queued.
  Gap-H and Gap-J are HIGH priority (R29-X1-S R30 recommendation). Each Gap-PROP
  draft must include an explicit P28 enforcement clause for its construct family.

[Next]:
- Compiler/Grammar Expert: answer OQ-P28-1 (escape declaration naming).
  Deliverable: single row update to P28 surface table + note in a C/GE track doc.
- META-EXPERT: add OQ-Enforcement-1 resolution to META-EXPERT-013 §VI in a future
  META-EXPERT proposal card.
- PROP-035 draft: must include P28 enforcement clause for escape declarations.
- PROP-036+ draft: must include P28 enforcement clause for loop class naming.
- PROP-032 (Gap-H) draft: must include P28 enforcement clause for assumptions block.
- Gap-J PROP: when queued, must include P28 enforcement clause for constraints block.
```
