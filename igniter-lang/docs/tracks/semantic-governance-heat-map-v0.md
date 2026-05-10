# Track: Semantic Governance Heat Map v0

Card: S3-R30-C4-P
Agent: [Igniter-Lang Meta Expert]
Role: meta-expert
Track: semantic-governance-heat-map-v0
Status: done
Date: 2026-05-10

---

## Purpose

Create the first cross-layer drift index exposing gaps between Covenant postulates,
Spec chapters, PROPs, compiler pipeline stages, and proof anchors.

---

## Sources Read

- `igniter-lang/docs/language-covenant.md`
- `igniter-lang/docs/dev/canonical-semantic-model.md`
- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/proposals/README.md`
- `igniter-lang/docs/tracks/stage3-round29-status-curation-v0.md`
- `igniter-lang/AGENTS.md`, `igniter-lang/roles/meta-expert.md`
- `igniter-lang/docs/agent-context.md`, `igniter-lang/docs/operating-model.md`

---

## Delivered

`igniter-lang/docs/dev/semantic-governance-heat-map.md`

Eight domains covered:

1. Core Contract Shape (pure, observed, effect, privileged, irreversible, escape)
2. Epistemic Declarations (assumptions, constraints, epistemic state machine)
3. Effect Surface (PROP-035 and 6 blocking postulates)
4. Temporal Read (History[T], BiHistory[T], TEMPORAL parser syntax)
5. Form Constructor + Loop Class (Gap-I, Gap-J, PROP-036+)
6. OOF Code Registry (6 active / 3 deferred / 3 new governance gaps)
7. Composition + Evidence (PROP-002, PROP-033, Profile System)
8. Governance Layer (PROP-032 conflict, P28 table, META-EXPERT-013 reconciliation)

---

## Key Findings

### Discovered: PROP-032 Queue Conflict (GI-1)

`proposals/README.md` reserves PROP-032 for `via profile binding`.
`canonical-semantic-model.md` and `agent-context.md` assign PROP-032 to the
`assumptions {}` block (Gap-H).

These are mutually exclusive. Neither assumptions nor `via profile` can proceed to
authoring without a number conflict. This is a blocking governance issue that was
not previously surfaced explicitly; it requires an Architect decision.

### Critical: Effect Surface (GI-2)

PROP-035 is queued but unwritten. Seven Covenant postulates (P4, P7, P9, P15, P17,
P19, P21) commit to Effect Surface semantics. `effect`, `privileged`, and
`irreversible` modifiers have no runtime enforcement. Receipts lack authority and
compensation fields. The failure taxonomy has no compiler expression. This is the
highest-leverage open gap in the language.

### High: Managed Recursion Doctrine has zero compiler expression (GI-3)

P14 commits to five loop classes. No PROP has been numbered. PROP-036+ is a
placeholder only. The Managed Recursion Doctrine has no grammar, no fragment class,
and no OOF code.

### Medium: P28 enforcement not codified (GI-4)

P28 is Covenant-governing. Five construct types are subject to it. No OOF code
exists for P28 violations.

---

## Debt Summary

| debt_type | Count | Hotspot |
|-----------|-------|---------|
| `gov` | 15 | Effect Surface blocks 7 postulates |
| `sem/gov` | 7 | assumptions, constraints, synthetic markers, ESM |
| `sem` | 7 | form, loop classes ×4, evidence syntax, composition |
| `impl/gov` | 5 | observed/effect/privileged/irreversible, receipt |
| `impl` | 10 | History parser+RT, BiHistory RT, OOF-I1/I3/I5, startup, V-3 |
| `none` | 9 | core contract, OOF-P1/S2/S4/CE4/OS2, as_of, OOF-M1 |

---

## Handoff

```text
Card: S3-R30-C4-P
Agent: [Igniter-Lang Meta Expert]
Role: meta-expert
Track: semantic-governance-heat-map-v0
Status: done

[D] Decisions
- PROP-032 queue conflict identified: proposals/README.md and CSM assign PROP-032
  to different entities. Documented as GI-1. Requires Architect resolution before
  assumptions or `via profile` work can proceed.
- Effect Surface (PROP-035) named as highest-leverage single governance gap.
- Loop classes named as the domain with zero compiler expression relative to
  Covenant commitments.
- Heat map placed in docs/dev/ (sister to canonical-semantic-model.md) because
  it is a verifiable living index, not a governance decision document.

[S] Shipped / Signals
- Created: docs/dev/semantic-governance-heat-map.md (8 domains, 50+ entities)
- Created: docs/tracks/semantic-governance-heat-map-v0.md (this file)
- Governance issues GI-1..GI-5 formally named and described.

[T] Tests / Proofs
- Map-only curation. No executable proof. No CSM status changes.
- All status symbols derived from landed evidence in current-status.md and CSM.
- No new semantics introduced.

[R] Risks / Recommendations
- PROP-032 queue conflict (GI-1) is blocking: if not resolved, both assumptions
  authoring and `via profile` authoring will produce conflicting proposal files.
  Route to Architect as a decision card before R31 PROP authoring begins.
- Effect Surface (GI-2): recommend bounding PROP-035 scope to the declaration
  shape only; leave compensation/timeout/audit fields as deferred addenda to keep
  the first PROP tractable.
- Do not start PROP-036+ loop class work without a gap analysis track first;
  the domain is entirely unspecified.

[Next] Suggested next slice (R31 route)
1. Architect decision card: PROP-032 queue conflict resolution (GI-1, prerequisite)
2. [Compiler/Grammar Expert]: assumptions block PROP (Gap-H, after GI-1 resolved)
   + [Research Agent]: minimal golden fixture (positive + OOF case)
3. [Research Agent]: OOF-I1 / OOF-I3 / OOF-I5 closure (PROP-025 addendum, no new PROP)
4. [Compiler/Grammar Expert]: P28 enforcement gap table (GI-4)
5. [Compiler/Grammar Expert]: PROP-035 scoped authoring (Effect Surface declaration shape)
6. [Research Agent]: V-3 golden anchor (small, bundle with next PROP-031 touching track)
7. [Meta Expert or Research Agent]: Gap-J discussion track (constraints, after Gap-H settled)
8. Managed Recursion gap analysis track (backlog, before any PROP-036+ authoring)
```
