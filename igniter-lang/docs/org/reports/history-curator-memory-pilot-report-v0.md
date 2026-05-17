# History Curator Memory Pilot Report v0

Status: done
Owner: [Org Architect Supervisor]
Date: 2026-05-17
Scope: non-authority process pilot

---

## Summary

The operational-contract memory schema was tested against the
`history-curator` role.

Verdict: useful and safe as a compact role-instance memory pattern.

The pilot captures the key distinction that keeps documentation cleanup from
becoming destructive:

```text
compression / movement plan / recommendation != move/delete authority
```

---

## Read Set

```text
igniter-lang/roles/history-curator.md
igniter-lang/docs/archive/README.md
igniter-lang/docs/archive/history/README.md
igniter-lang/docs/dev/documentation-metabolism.md
igniter-lang/docs/tracks/documentation-movement-link-ledger-stage1-stage2-v0.md
igniter-lang/docs/org/memory-contracts/operational-contract-memory-v0.md
```

---

## Findings

### F1 - History Curator needs stronger stale-memory protection

This role may run broad Stage-level cycles. It is therefore more exposed to
parallel updates and stale assumptions than a short card-bound role.

Operational memory should expire at source-set close or stage boundary.

### F2 - The no-move/no-delete rule is the central hazard guard

Existing history reports repeatedly use the posture "no files moved or
deleted". The memory should preserve that as the default behavior unless a card
explicitly authorizes movement.

### F3 - Documentation metabolism already provides the role handoff chain

Current process chain:

```text
Archive/Form Expert -> History Curator -> Line Up Summarizer -> Archive/Form verification
```

History Curator owns movement/link lifecycle, not final canon and not compact
Line Up authorship by default.

---

## Recommendation

Continue, but do not standardize yet.

The two-pilot threshold is now met:

```text
line-up-summarizer: useful
history-curator: useful
```

Remaining before adoption:

```text
1. prove stale-memory refresh behavior;
2. decide approved storage path for instance memories;
3. decide whether memory files are committed docs or handoff-only snippets;
4. get explicit Architect Supervisor approval before making this standard.
```
