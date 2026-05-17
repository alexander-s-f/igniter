# Operational Contract Memory Two-Role Pilot Result v0

Status: done
Card: `S3-R63-C0-O`
Agent: [Org Architect Supervisor]
Role: org-architect-supervisor
Date: 2026-05-17
Authority ref: `igniter-lang/docs/org/reports/operational-memory-pilot-architect-approval-v0.md`

---

## Executive Summary

The bounded operational-contract memory pilot ran for two non-authority roles:

```text
Line Up Summarizer
History Curator
```

Both role-instance self-checks returned the same verdict:

```text
iterate
```

Operational memory is useful enough to keep testing as an optional handoff
supplement. It is not ready for framework-wide standardization.

---

## Boundary Check

Stayed inside approved scope:

```text
docs/org/reports/
docs/org/memory-contracts/
docs/org/indexes/
```

No changes were made to:

```text
role profiles
current-status.md
gates
proposals
spec
language semantics
compiler/runtime implementation
archives or source document movement
automation
```

Operational memory remains subordinate to:

```text
AGENTS.md
roles/*.md
docs/cards/*
docs/gates/*
docs/proposals/*
docs/current-status.md
explicit card scope
```

---

## Role Self-Check Results

| Role | Reduced rereads? | Caught hazard? | Subordinate to authority? | Stale behavior | Compact enough? | Verdict |
| --- | --- | --- | --- | --- | --- | --- |
| Line Up Summarizer | yes, likely | yes: standalone QA anchor, no-canon, no-move, public/private risk | yes | mostly clear | yes, with possible trimming | iterate |
| History Curator | yes | yes: bounded-source-set, no-move-default, canon-history-confusion | yes | mostly clear; missing conflict/long-pause triggers | yes, with possible evidence-ref trimming | iterate |

---

## Hazards Caught

Line Up Summarizer:

```text
source remains authoritative for exact proof logs.
```

The exact QA anchor must remain a standalone line.

History Curator:

```text
compression / movement plan / recommendation != move/delete authority
```

The role can plan movement and link lifecycle, but cannot move/delete/archive
without explicit approval.

---

## Stale-Memory Finding

History Curator found a useful gap:

```text
memory should refresh on authority conflict, current-status/card conflict,
and long pause.
```

Action taken inside pilot memory only:

```text
igniter-lang/docs/org/memory-contracts/history-curator-operational-memory-pilot-v0.md
```

The refresh policy now includes:

```text
authority conflict
current-status or active card conflict
long pause
```

---

## Decision Needed

No urgent main-lane decision is needed.

If Architect Supervisor wants to continue the pilot, the next decision should
be narrow:

```text
Allow one live future Line Up card and one live future History Curator card to
include the pilot memory as an optional handoff supplement, then report whether
it helped in real work.
```

Do not standardize across all roles yet.

---

## Recommendation

```text
iterate / keep optional
```

Next approved-shape pilot:

```text
Use operational memory only as an optional supplement on the next real
Line Up Summarizer and History Curator cards.
Measure:
  - rereads avoided
  - hazards caught
  - stale refresh behavior
  - handoff compactness
  - authority discipline
```

Reject standardization for now.

---

## Short Return Summary For Architect Supervisor

Operational-contract memory worked as a role-instance handoff supplement for
Line Up Summarizer and History Curator. Both self-checks recommend `iterate`,
not `standardize`. It reduced reread pressure, caught real hazards, stayed
subordinate to authority docs, and exposed one stale-memory gap, now patched in
the History Curator pilot memory. Recommended next step: keep optional and test
on the next real Line Up and History Curator cards before any broader adoption.
