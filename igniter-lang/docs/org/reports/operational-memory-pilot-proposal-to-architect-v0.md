# Operational Memory Pilot Proposal To Architect v0

Status: proposed
Prepared by: [Org Architect Supervisor]
For: [Architect Supervisor / Codex]
Date: 2026-05-17
Source sidecar: `S3-R62-C0-O`

---

## Executive Summary

The org sidecar recommends a bounded operational-contract memory pilot for two
non-authority roles:

```text
Line Up Summarizer
History Curator
```

This is a process pilot only. It does not change role profiles, gates,
proposals, current status, language semantics, or implementation authority.

The goal is to test whether compact instance memory reduces repeated rereads,
captures role-specific hazards, and improves handoff quality without creating a
second authority layer.

---

## Why These Roles

### Line Up Summarizer

Good pilot because the role has narrow, repeatable hazards:

```text
exact QA anchor must remain standalone
Line Ups are memory handles, not canon
summary/disposition recommendation does not authorize movement
public/private risk must be routed
```

Pilot reference:

```text
igniter-lang/docs/org/memory-contracts/line-up-summarizer-operational-memory-pilot-v0.md
igniter-lang/docs/org/reports/line-up-summarizer-memory-pilot-report-v0.md
```

### History Curator

Good pilot because the role runs longer cycles and has higher stale-context
risk:

```text
read only the assigned source set
compression / movement plan / recommendation != move/delete authority
classification before rotation
Line Up before redirect
explicit approval before actual movement
```

Pilot reference:

```text
igniter-lang/docs/org/memory-contracts/history-curator-operational-memory-pilot-v0.md
igniter-lang/docs/org/reports/history-curator-memory-pilot-report-v0.md
```

---

## Proposed Pilot Scope

Open a bounded process pilot:

```text
Track: operational-contract-memory-two-role-pilot-v0
Roles:
  - Line Up Summarizer
  - History Curator
Mode: docs/process only
```

Allowed:

```text
1. Use the two pilot memory files as optional handoff supplements.
2. Ask each role instance to self-check against its memory at card start.
3. Ask each role instance to report whether the memory prevented a reread,
   caught a hazard, or was stale/useless.
4. Record pilot results in docs/org/reports/.
```

Not allowed:

```text
1. No role profile changes.
2. No current-status, gate, proposal, or spec mutation.
3. No document movement or deletion.
4. No automation.
5. No requirement that every role use operational memory.
6. No instance memory overriding AGENTS.md, role profiles, cards, gates,
   proposals, or current-status.
```

---

## Success Criteria

The pilot succeeds if both role instances can answer:

```text
1. Did the memory reduce startup rereads?
2. Did it catch at least one role-specific hazard?
3. Did it stay subordinate to role profile and authority docs?
4. Was stale-memory behavior clear enough to self-refresh?
5. Was it compact enough to include in a handoff without bloating context?
```

The pilot fails or must narrow if:

```text
1. an agent treats memory as canon;
2. an agent widens authority based on memory;
3. memory becomes longer than the role profile;
4. memory conflicts with current-status or a card and is not marked stale;
5. operational memory creates more process overhead than it removes.
```

---

## Requested Architect Decision

Recommended decision:

```text
approve bounded process pilot
```

Exact approval wording:

```text
Operational-contract memory may be tested as an optional non-authority
handoff supplement for Line Up Summarizer and History Curator only.

The pilot may record results under igniter-lang/docs/org/reports/.
It must not mutate role profiles, current-status, gates, proposals, specs,
or move/delete/archive documents.

Operational memory remains subordinate to AGENTS.md, roles, cards, gates,
proposals, current-status, and explicit card scope.
```

---

## Suggested Card

```text
Card: S3-R??-C?-O
Agent: [Org Architect Supervisor]
Role: org-architect-supervisor
Track: operational-contract-memory-two-role-pilot-v0

Route: UPDATE
Mode: process-pilot

Goal:
Run a bounded operational-contract memory pilot for Line Up Summarizer and
History Curator.

Scope:
- Use the existing pilot memory files as optional handoff supplements.
- Ask one Line Up Summarizer instance and one History Curator instance to
  self-check against memory at start and report whether it helped.
- Record pilot results in docs/org/reports/.
- Evaluate stale-memory behavior.
- Do not standardize across all roles yet.

Non-authorizations:
- No role profile changes.
- No current-status/gate/proposal/spec mutation.
- No archive movement/deletion.
- No automation.
- No authority widening.

Deliver:
- Pilot result report in igniter-lang/docs/org/reports/
- Recommendation: standardize / iterate / reject / keep as optional
```

---

## Org Sidecar Recommendation

Approve the pilot, but keep it narrow.

This is a promising swarm hygiene mechanism, not yet a framework-wide rule.
