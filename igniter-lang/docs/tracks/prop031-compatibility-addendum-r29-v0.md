# Track: PROP-031 Compatibility Addendum (R29)

Card: S3-R29-C3-P (Meta Expert)
Agent: `[Igniter-Lang Meta Expert]`
Role: `meta-expert`
Track: `prop031-compatibility-addendum-r29-v0`
Status: done
Date: 2026-05-10

---

## Purpose

Clarify PROP-031 compatibility semantics discovered during Stage 3 proof (R28).
Address challenges C-1 and C-4 from the External Pressure Reviewer
(`r28-durable-audit-and-prop031-pressure-v0.md`). Correct five errata in
PROP-031-contract-modifiers-v0.md. No code changes. No new grammar.

---

## Deliverables

### 1. §14 Compatibility Addendum added to PROP-031

Added five subsections to `igniter-lang/docs/proposals/PROP-031-contract-modifiers-v0.md`:

| Subsection | Topic |
|-----------|-------|
| §14.1 | Stage 1 / Stage 2 backward compatibility confirmed (no fixture changes) |
| §14.2 | Stage 3 migration: three contracts required `observed` modifier |
| §14.3 | `stream` inputs trigger OOF-M1 via body-level ESCAPE classification |
| §14.4 | Temporal declarations take precedence over modifier-based ESCAPE |
| §14.5 | OOF-M1 pipeline ownership: Classifier detects, TypeChecker propagates |

### 2. Errata corrected in PROP-031

| Location | Error | Correction |
|----------|-------|-----------|
| §3 modifier table | `observed → ESCAPE` row had no temporal exception | Added `ESCAPE or TEMPORAL†` with footnote |
| §4.1 mapping | `observed → ESCAPE (regardless of body content)` | Corrected to: temporal body content takes precedence → `TEMPORAL`; else `ESCAPE` |
| §5.1 header | "TypeChecker Changes" — OOF-M1 was attributed to TypeChecker | Section renamed to "Classifier and TypeChecker Changes"; stage ownership clarified |
| §10.1 / §10.2 | `contradiction_count - corroboration_count` uses unsupported `-` operator | Changed to `+` |
| §10.4 | `input message: String` — `message` is a reserved keyword | Changed to `input body: String` |
| §11 Q1 | "Current answer: No" with no implementation evidence | Added "Implementation result (R28): Confirmed" paragraph citing §14.4 |
| §13 | "TypeChecker change: emit OOF-M1" | Corrected to Classifier detection + TypeChecker propagation; SemanticIR nil path documented |

### 3. Pressure Review Response

| Challenge | Resolution |
|-----------|-----------|
| C-1: §2.2 backward compat scope needs Stage 3 disclosure | §14.1 confirms Stage 1/2 PASS; §14.2 documents Stage 3 migration requirement |
| C-4: `stream` triggers OOF-M1 via body ESCAPE, not documented | §14.3 added; migration pattern provided |
| M-3 (implicit): PROP-031 addendum noting Stage 3 migration | §14.2 is the M-3 addendum |

---

## Key Facts Locked

**OOF-M1 is a Classifier detection, not a TypeChecker detection.**

```
Classifier  → detects modifier=="pure" + ESCAPE body → oof_log + fragment_class:"oof"
TypeChecker → propagates oof_log → type_errors + status:"blocked"
SemanticIR  → nil when type_errors non-empty
```

**Temporal precedence rule (V-3):**

```
observed + temporal body → fragment_class: "temporal"
observed + escape body   → fragment_class: "escape"
```

This is the implementation behavior of `contract_fragment_for` in `classifier.rb`
as fixed in R28. It is now documented in §4.1 and §14.4 of PROP-031.

**Stage 3 migration contracts:**

- `IntegerWindowSum` — stream ingress (runner STREAM_SOURCE constant, not the .ig file)
- `TechnicianJobCountAt` — escape history_read
- `SparkCRMBiHistorySourceParity` — escape bihistory_read

---

## Scope Boundaries

This card makes no code changes. No grammar was modified. No new OOF codes were
introduced. The addendum is documentation-only.

The §10.1/§10.2 fixture code corrections (`-` → `+`) and the §10.4 keyword fix
(`message` → `body`) apply to the PROP document specimens only — the actual proof
experiment fixtures already use valid syntax.

---

## Handoff

```text
Card: S3-R29-C3-P
Agent: [Igniter-Lang Meta Expert]
Role: meta-expert
Track: prop031-compatibility-addendum-r29-v0
Status: done

[D] Decisions
- OOF-M1 ownership: Classifier (detection) → TypeChecker (propagation) → SemanticIR (nil)
- Temporal precedence over modifier-based escape is now formally documented in PROP-031 §4.1 and §14.4
- Stage 3 migration requirement is now explicit in §14.2 (M-3 pressure response)
- stream inputs trigger OOF-M1 via body classification — documented in §14.3

[S] Shipped / Signals
- PROP-031 §14 Compatibility Addendum: 5 subsections
- 7 errata corrected in-place across §3, §4.1, §5.1, §10.1, §10.2, §10.4, §11, §13
- Pressure challenges C-1 and C-4 formally resolved

[T] Tests / Proofs
- No code changes in this card.
- All R28 proofs remain PASS (10/10 surfaces).

[R] Risks / Recommendations
- §14.4 temporal precedence rule is currently behavioral (derived from implementation).
  It should become a formal Classifier spec rule in PROP-028 addendum or PROP-031 rev.
- Gap-H (assumptions block) and Gap-J (constraints block) are both open and HIGH priority.
  PROP-032 (assumptions) and PROP-035 (Effect Surface) depend on the modifier foundation
  PROP-031 has established.

[Next] Suggested next slice
- R29-C1-P: Covenant Postulates 24–26 governance filter (already written in R28; review pass)
- R29-C2-P: CSM bootstrap — canonical entity index
- R29-C3-P (this card): DONE
- PROP-032: assumptions {} block draft (Gap-H HIGH priority)
```
