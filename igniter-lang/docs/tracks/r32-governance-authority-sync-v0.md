# Track: R32 Governance Authority Sync v0

Card: S3-R32-C2-S
Agent: [Igniter-Lang Meta Expert]
Role: meta-expert
Track: r32-governance-authority-sync-v0
Status: done
Date: 2026-05-10

---

## Goal

Apply the S3-R31-C2-A follow-up docs so the PROP authority hierarchy is visible
in active maps.

This is curation only. No new language semantics were created.

---

## Source Decision

Authority document:
`docs/gates/prop-governance-authority-decision-v0.md`

Decision:

```text
Covenant = normative PROP acceptance authority
META-EXPERT-013 = operational routing/checklist
```

PROP authors must answer the Covenant audit-legibility filter first, then satisfy
the META-EXPERT-013 operational checklist. If the two documents appear to
conflict, the Covenant controls.

---

## Updates Applied

| File | Update |
|------|--------|
| `docs/meta-proposals/META-EXPERT-013-spec-extension-governance-v0.md` | Added Covenant-first authority note and synced PROP-032/033/034 queue routing |
| `docs/language-covenant.md` | Marked OQ-Filter-1 resolved by S3-R31-C2-A and linked the gate decision |
| `docs/dev/semantic-governance-heat-map.md` | Closed Domain 8 authority-split row; added resolved governance issue note |
| `docs/current-status.md` | Added R32 partial status and removed P-39/P-40 from active pre-production remaining list |
| `docs/tracks/README.md` | Added R32 evidence row and marked P-39/P-40 recommendations done |
| `docs/agent-context.md` | Updated active read context so new agents see the authority split as closed |

---

## Non-Authorization

This card does not authorize:

- PROP-032 parser/classifier/TypeChecker/SemanticIR implementation
- new language semantics
- Effect Surface implementation
- profile system implementation
- production deployment, signing/key management, HSM/KMS, Ledger/Phase 2, BiHistory, stream/OLAP, production cache, or broad RuntimeMachine binding

PROP-032 remains governed by its existing Phase 1 gate status: gate satisfied,
implementation/proof not landed.

---

## Compact P-39 / P-40 Answer

P-39: **closed** by this card. Covenant OQ-Filter-1 now points to S3-R31-C2-A,
and Heat Map Domain 8 marks the authority split closed.

P-40: **closed** by this card. META-EXPERT-013 now states that the Covenant is
normative and META-EXPERT-013 is operational/checklist-only.
