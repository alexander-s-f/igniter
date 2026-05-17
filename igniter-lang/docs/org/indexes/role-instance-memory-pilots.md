# Role Instance Memory Pilots

Status: pilot index
Owner: [Org Architect Supervisor]
Date: 2026-05-17

---

## Purpose

Track non-authority operational-contract memory pilots before any wider
adoption across roles.

---

## Pilots

| Role | Pilot file | Status | Verdict | Notes |
| --- | --- | --- | --- | --- |
| `line-up-summarizer` | `../memory-contracts/line-up-summarizer-operational-memory-pilot-v0.md` | done | useful | Captures QA anchor, no-canon, no-movement, and return-report rules |
| `history-curator` | `../memory-contracts/history-curator-operational-memory-pilot-v0.md` | done | useful | Captures bounded source-set, no-move/no-delete, classification, and movement/link preconditions |

---

## Adoption Gate

Do not make operational-contract memory standard until:

```text
1. at least two non-authority role pilots are done;          done
2. stale-memory behavior is proven;                         open
3. Architect Supervisor approves storage and refresh rules; pilot-only approved
4. role profiles remain canonical and memory remains subordinate.
```

## Current Architect Approval

`../reports/operational-memory-pilot-architect-approval-v0.md` approves only a
bounded two-role pilot for Line Up Summarizer and History Curator.

Standardization across all roles remains unapproved.
