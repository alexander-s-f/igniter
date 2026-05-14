# Igniter-Lang Cards

Status: active
Owner: [Architect Supervisor / Codex]
Started: 2026-05-14

---

## Purpose

Cards are the dispatch layer for supervisor planning.

They answer:

```text
What did we plan to do, in what order, and under what authority?
```

Tracks remain the evidence layer. They answer:

```text
What did an agent actually do, prove, decide, or discover?
```

Cards do not replace `docs/tracks/`, `docs/gates/`, `docs/discussions/`, or
`docs/current-status.md`.

---

## Structure

```text
cards/
  S<n>/
    S<n>.md            stage entry point: horizon, decisions, round index
    S<n>-R<n>.md       round file: status, lineup, dispatch, card texts, receipt
```

Igniter-Lang starts this structure at Stage 3 Round 44. Earlier rounds remain
available through `current-status.md`, `tracks/README.md`, gates, discussions,
and source track files. Do not backfill R1-R43 unless explicitly requested.

---

## Round File Header

```text
# S<n>-R<n>

Status: open | closed
Date: YYYY-MM-DD
Closed: YYYY-MM-DD | -
Lineup: one line summary

Dispatch:
R<n> = [[C1-P1, C2-P1], C3-S]

---
```

---

## Suffix Legend

- `-P` / `-P1` / `-P2`: parallel-safe; cards with the same `P` series may run together
- `-B`: blocked/ordered; check `Depends on` before starting
- `-S`: serial, supervisor-only, or round-close work
- `-A`: Architect authority decision; no code is authorized unless this says so
- `-I`: implementation/code-writing slice
- `-X`: external pressure/review slice
- `-QA`: verification slice

---

## Lifecycle

1. Supervisor opens a round file with planned card texts.
2. User dispatches cards to agents.
3. Agents write work artifacts to their assigned destination:
   - `docs/tracks/` for work/evidence;
   - `docs/gates/` for Architect decisions;
   - `docs/discussions/` for pressure/review;
   - `docs/lineups/` for compact historical summaries.
4. Round file card text remains a planning record.
5. At close, Supervisor appends a Round Receipt with links to actual outputs.

Do not rewrite completed card text to match what happened. Put actual results in
the Round Receipt and the track/discussion/gate files.

---

## Current Stage

- [Stage 3](S3/S3.md)
- [Stage 3 Round 44](S3/S3-R44.md)
