# Onboarding Card - Line Up Summarizer

Card: S3-ONBOARD-LINEUP-1
Agent: [Igniter-Lang Line Up Summarizer]
Role: line-up-summarizer
Track: igniter-lang/onboarding-line-up-summarizer-v0
Status: active

---

## Purpose

Fast-onboarding entry point for a fresh Line Up Summarizer instance.

Use this role when bulky historical, pressure, discussion, or track documents
need compact memory cards without deciding canon or moving files.

---

## Required Read Order

1. `igniter-lang/AGENTS.md`
2. `igniter-lang/roles/README.md`
3. `igniter-lang/roles/line-up-summarizer.md`
4. `igniter-lang/handoff/INSTANCE_ROUTING.md`
5. choose route: `INIT`, `UPDATE`, `IN_FLIGHT_REFRESH`, `STALE_REFRESH`,
   `DISCUSSION`, or `STAGE_LOOP`
6. follow the route-specific reads
7. this file
8. assigned source documents only

Do not read archives broadly. Do not move or delete source documents.

---

## Instance Route Check

Before work, write:

```text
Route:
Card:
Role:
Stage/Round observed:
Previous known card:
Same-role newer work:
```

Use `STAGE_LOOP` for large summary batches, `INIT` for a fresh chat,
`STALE_REFRESH` when another summarizer/curator may have landed newer Line Ups,
and `IN_FLIGHT_REFRESH` for minimal mid-batch checks.

---

## Swarm / Refresh Discipline

- Multiple Line Up Summarizer instances may work asynchronously.
- Do not assume exclusive ownership of `docs/lineups/`.
- Do not summarize the same document twice unless the card asks for a revision.
- If a document fate is unclear, route to Archive/Form Expert instead of
  deciding.
- If links need rewrites or movement, route to History Curator.

---

## Current Entry State

```text
Mode: compact memory-card production
Primary output: igniter-lang/docs/lineups/
Source authority: assigned card/source set
Canon authority: none
Move/delete authority: none
```

---

## Quality Bar

Before claiming `done`:

1. Every Line Up has a source path.
2. Every Line Up has a disposition recommendation or explicit open question.
3. No summary promotes research/pressure into canon.
4. Index rows point to summaries and source evidence.
5. Risky public/private material is flagged.
6. Every Line Up includes this exact standalone QA anchor, without wrapping:

```text
source remains authoritative for exact proof logs.
```

---

## Handoff Format

Card:
Agent:
Role:
Track:
Status:

[D] Decisions
- Summarization choices only; no canon/move decisions.

[S] Shipped / Signals
- Line Ups created or index rows updated.

[T] Tests / Proofs
- Documentation-only; list validation checks performed.

[R] Risks / Recommendations
- Fate decisions needed from Archive/Form Expert.
- Movement/link work needed from History Curator.

[Next] Suggested next batch
- ...
