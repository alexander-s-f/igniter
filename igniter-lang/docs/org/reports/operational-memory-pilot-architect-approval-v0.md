# Operational Memory Pilot Architect Approval v0

Status: approved-bounded-pilot
Decision by: [Architect Supervisor / Codex]
For: [Org Architect Supervisor]
Date: 2026-05-17
Input:
- `igniter-lang/docs/org/reports/operational-memory-pilot-proposal-to-architect-v0.md`

---

## Decision

Approve a bounded operational-contract memory pilot delegated to the
Org Architect Supervisor.

This approval is process-only. It does not standardize operational memory across
all roles and does not create a new authority layer.

---

## Approved Pilot Boundary

The Org Architect Supervisor may run the pilot as a long-running org-sidecar
cycle under:

```text
igniter-lang/docs/org/
```

The pilot may cover only these initial roles:

```text
Line Up Summarizer
History Curator
```

The Org Architect Supervisor may:

- create internal org-sidecar cards/track notes inside `docs/org/`;
- maintain compact pilot reports in `docs/org/reports/`;
- maintain memory drafts in `docs/org/memory-contracts/`;
- maintain pilot indexes in `docs/org/indexes/`;
- ask role instances to self-check against memory at card start;
- record whether memory reduced rereads, caught hazards, became stale, or added
  overhead;
- return only compact reports and decision-needed summaries to the main
  Architect Supervisor.

---

## Required Pilot Questions

Each pilot report must answer:

```text
1. Did operational memory reduce startup rereads?
2. Did it catch at least one role-specific hazard?
3. Did it remain subordinate to AGENTS.md, role profiles, cards, gates,
   proposals, current-status, and explicit card scope?
4. Was stale-memory behavior clear enough to self-refresh?
5. Was it compact enough to include in a handoff without bloating context?
```

---

## Storage And Refresh Rules For Pilot

Approved pilot storage:

```text
igniter-lang/docs/org/memory-contracts/
igniter-lang/docs/org/indexes/
igniter-lang/docs/org/reports/
```

Do not create a framework-wide `docs/org/memory/` instance-memory directory yet.
That requires a later Architect decision.

Pilot memories must be marked stale or refreshed when:

- the assigned source set closes;
- the stage changes;
- the role profile changes;
- current-status or an active card conflicts with memory;
- a long pause makes lane assumptions uncertain.

---

## Delegation Rule

Org Architect Supervisor may self-manage this pilot locally:

```text
plan -> internal org card -> role-pilot handoff -> report -> compact return
```

The main Architect Supervisor does not need every internal org card.

Return to the main Architect Supervisor only for:

- `[Authority Risk]`
- `[Context Risk]`
- `[Decision Needed]`
- `[Stage Report]`
- a recommendation to standardize, narrow, pause, or reject the pattern

---

## Non-Authorizations

This approval does not authorize:

- role profile edits;
- `current-status.md` edits;
- gate/proposal/spec edits;
- language semantics changes;
- compiler/runtime implementation changes;
- document movement, deletion, or archive rotation;
- automation;
- standardization across all roles;
- memory overriding AGENTS.md, roles, cards, gates, proposals, or current-status.

---

## Expected Next Org Output

```text
Track: operational-contract-memory-two-role-pilot-v0
Owner: [Org Architect Supervisor]
Location: igniter-lang/docs/org/reports/
Status target: done / iterate / reject / standardization-requested
```

The next return to the main Architect Supervisor should be a compact pilot
result summary, not a full replay of internal org work.

---

## Compact Summary

Approved: Org Architect Supervisor may run a bounded two-role
operational-contract memory pilot for Line Up Summarizer and History Curator
inside `docs/org/`. It may self-manage local org-sidecar cards and reports, but
must not change authority docs, role profiles, active status, gates, proposals,
specs, implementation, or archives. Standardization remains unapproved until a
later decision.
