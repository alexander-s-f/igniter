# Proposal Lifecycle Status Labels Sync

Card: S3-R35-C6-S
Agent: `[Igniter-Lang Meta Expert]`
Role: meta-expert
Track: `proposal-lifecycle-status-labels-sync-v0`
Status: done
Date: 2026-05-11

---

## Goal

Reduce proposal lifecycle ambiguity after R34/R35, especially the recurring
confusion between a completed track and an accepted proposal.

This is curation only. It does not accept or reject any proposal and creates no
language semantics.

---

## Source Signals

Read:

- `docs/proposals/README.md`
- `docs/operating-model.md`
- `docs/tracks/prop036-compiler-profile-id-manifest-proposal-v0.md`
- `docs/discussions/r34-audit-assumptions-profile-progression-pressure-v0.md`

Additional same-round evidence consulted to avoid stale map writes:

- `docs/gates/prop036-compiler-profile-id-acceptance-decision-v0.md`
- `docs/gates/progression-prop-number-assignment-decision-v0.md`
- `docs/tracks/prop032-assumptions-phase4-parser-proof-v0.md`
- `docs/discussions/r35-durable-audit-prop036-progression-prop032-pressure-v0.md`

---

## Lifecycle Label Table

| Label | Meaning |
|-------|---------|
| `draft` | Working text, scope packet, or proposal sketch exists, but no formal proposal file is indexed as the review target |
| `authored-pending-review` | Formal proposal file exists and is indexed; governance has not accepted or rejected it |
| `accepted` | Governance accepted the proposal scope; implementation may still require a separate card |
| `conditional-accepted` | Governance accepts direction with named blockers, exclusions, or required edits |
| `implemented-proof` | Authorized implementation/proof landed for part or all of the proposal, but full experiment-pass or closure is still open |
| `experiment-pass` | Verification matrix for the accepted proposal scope passed; the proposal can be closed/frozen by the owning governance flow |
| `deferred` | Proposal or sub-scope is intentionally postponed; not active implementation work |

Rule:

```text
Track: done != Proposal: accepted
```

Track status says the card delivered its artifact. Proposal lifecycle status says
where the proposal sits in governance.

---

## Updates Applied

| File | Change |
|------|--------|
| `docs/proposals/README.md` | Replaced ambiguous status vocabulary with lifecycle labels; mapped historical aliases; updated active rows (`PROP-036` accepted proposal-only, `PROP-032` implemented-proof, `PROP-028` implemented-proof) |
| `docs/operating-model.md` | Added explicit separation between track completion and proposal lifecycle status |
| `docs/tracks/prop036-compiler-profile-id-manifest-proposal-v0.md` | Added proposal lifecycle line: `authored-pending-review` at authoring time; track `done` was not acceptance |
| `docs/current-status.md` | Synced same-round lifecycle map: PROP-036 accepted proposal-only, PROP-037 assigned numbering-only, PROP-032 Phase 4 proof done but experiment-pass decision open |
| `docs/tracks/README.md` | Added C3-A/C4-A/C5-P/C6-S Round 35 evidence rows and replaced stale next recommendations |

---

## Non-Decisions

- No proposal was accepted or rejected by this track.
- PROP-036 acceptance comes only from `S3-R35-C3-A`.
- PROP-037 assignment comes only from `S3-R35-C4-A`.
- PROP-032 experiment-pass is not granted here; C5-P recommends review only.
- No parser, TypeChecker, SemanticIR, assembler, loader, runtime, `.igapp`, `.ilk`,
  Ledger, Phase 2, production execution, or deployment authorization is created.

---

## Handoff

```text
Card: S3-R35-C6-S
Agent: [Igniter-Lang Meta Expert]
Role: meta-expert
Track: proposal-lifecycle-status-labels-sync-v0
Status: done

[D] Decisions
- Proposal lifecycle labels are now explicit in proposals/README.
- Track completion and proposal acceptance are separate namespaces.

[S] Shipped / Signals
- Proposal index and operating model clarify draft/authored/accepted/proof/pass/deferred labels.
- Current maps record PROP-036 as accepted proposal-only, PROP-037 as numbering-only, and PROP-032 as proof-complete pending experiment-pass governance.

[T] Tests / Proofs
- Docs-only curation; no compiler/runtime tests run.
- `git diff --check` clean.

[R] Risks / Recommendations
- Keep using lifecycle labels in future proposal rows.
- Next governance decision: PROP-032 experiment-pass review.

[Next]
- Open PROP-032 experiment-pass governance card, or a C3-A-authorized PROP-036 design/proof card.
```
