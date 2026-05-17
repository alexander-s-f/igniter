# Operational Memory History Curator Live Card Pilot v0

Card: ORG-S3-R63-C2-P1
Agent: [Igniter-Lang History Curator]
Role: history-curator
Track: operational-memory-history-curator-live-card-pilot-v0
Status: done
Date: 2026-05-17

Route: UPDATE
Mode: org-sidecar-pilot
Authority ref:
- `igniter-lang/docs/org/reports/operational-memory-pilot-architect-approval-v0.md`

---

## Scope

This pilot used the History Curator operational memory as an optional,
non-authority handoff supplement on a small movement-planning review slice.

Read set:

- `igniter-lang/AGENTS.md`
- `igniter-lang/roles/README.md`
- `igniter-lang/roles/history-curator.md`
- `igniter-lang/roles/archive-form-expert.md`
- `igniter-lang/docs/org/reports/operational-memory-pilot-architect-approval-v0.md`
- `igniter-lang/docs/org/memory-contracts/history-curator-operational-memory-pilot-v0.md`
- `igniter-lang/docs/dev/documentation-metabolism.md`
- `igniter-lang/docs/tracks/documentation-movement-link-ledger-stage1-stage2-v0.md`

No source documents were moved, deleted, archived, or relinked. No role
profiles, current-status, gates, proposals, spec, or active cards were edited.

## Pilot Checks

| Check | Result | Notes |
| --- | --- | --- |
| Bounded-source-set discipline | Helped | Memory named this as the first hazard, and the review stayed to the assigned docs instead of reopening archive snapshots/history reports from the old ledger. |
| No-move/no-delete default | Helped | Memory's central warning matched both role profile and movement ledger: movement planning is not movement authority. |
| Canon-vs-history confusion | Helped | Memory foregrounded classification/canon risk before reading the Stage 1/2 ledger, which kept old snapshots and proof tracks framed as evidence/history unless current authority says otherwise. |
| Line Up before redirect | Helped | Memory matched documentation metabolism and the ledger's rule that summaries/Line Ups come before redirect or movement. |
| Stale refresh triggers | Clear enough | Memory says to refresh on new source set, stage boundary, documentation-metabolism change, role-profile change, authority conflict, current-status/card conflict, or long pause. This was enough for a small UPDATE card. |

## Required Pilot Answers

1. Did memory reduce startup rereads?

Partly. It did not replace mandatory authority reads: AGENTS, role profile,
Archive/Form inheritance, pilot approval, and the assigned source docs still had
to be read. It did reduce temptation to reread broad archives by turning the
review into a five-hazard checklist.

2. Did it catch a role-specific hazard?

Yes. It caught the highest-risk History Curator hazard for this slice:
movement/link planning can accidentally look like move/delete authorization.
The memory reinforced that the Stage 1/2 ledger is recommendation-first and
that any actual move/delete needs explicit approval.

3. Did it stay subordinate to authority docs?

Yes. The card, AGENTS.md, role profile, Archive/Form inheritance,
documentation-metabolism, and the movement ledger controlled the outcome. The
memory was used only as a checklist. Where it said "current-status" is normally
part of refresh, the card's bounded read set still controlled this pilot slice.

4. Was stale-memory behavior clear?

Yes for this live-card pilot. The memory is marked `pilot` and
`Authority: non-authority example only`, and it lists concrete stale triggers.
The only improvement needed is a shorter "when stale, reread X before acting"
micro-checklist for repeated cards.

5. Was it compact enough for handoff?

Mostly. The YAML is compact enough for a role-instance handoff, but it is still
larger than needed for a live card. A derived five-line checklist would be
better for repeated movement-planning cards.

## Recommendation

Recommendation: `iterate`.

Keep History Curator operational memory optional and subordinate. It is useful
enough to continue, especially for long documentation-lifecycle work, but should
not be standardized yet.

Next iteration should add a small live-card form:

```text
History Curator memory checklist:
1. bounded source set?
2. no move/delete unless explicit?
3. canon/history labels clear?
4. Line Up before redirect?
5. stale trigger present?
```

## Handoff

```text
Card: ORG-S3-R63-C2-P1
Agent: [Igniter-Lang History Curator]
Role: history-curator
Track: operational-memory-history-curator-live-card-pilot-v0
Status: done

[D] Decisions
- No movement, deletion, archive rotation, source relinking, canon decision, or
  authority-doc edit was made.
- Recommendation: iterate; keep memory optional and subordinate.

[S] Signals
- Memory reduced broad-reread pressure and highlighted the movement-authority
  hazard quickly.
- Memory aligned with documentation-metabolism and the Stage 1/2 movement
  ledger on Line Up before redirect.

[T] Tests / Proofs
- Documentation-only pilot review.
- Checked the assigned source docs against the five requested hazards.

[R] Risks / Recommendations
- Do not standardize yet; create a shorter live-card checklist variant first.
- Keep stale-memory override explicit: role/card/current-status/gates/proposals
  always win.

[Next]
- Org-sidecar pilot can compare the short checklist variant against another
  History Curator movement/link card.
```
