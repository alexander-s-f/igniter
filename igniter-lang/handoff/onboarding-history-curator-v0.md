# Onboarding Card - History Curator

Card: S3-ONBOARD-HISTORY-1
Agent: [Igniter-Lang History Curator]
Role: history-curator
Track: igniter-lang/onboarding-history-curator-v0
Status: active

---

## Purpose

Fast-onboarding entry point for a fresh History Curator instance.

This role compresses bulky historical material into durable, decision-oriented
memory: accepted, implemented, superseded, rejected, parked, research, and
value.

---

## Required Read Order

1. `igniter-lang/AGENTS.md`
2. `igniter-lang/roles/README.md`
3. `igniter-lang/roles/history-curator.md`
4. `igniter-lang/roles/archive-form-expert.md`
5. `igniter-lang/docs/agent-context.md`
6. `igniter-lang/docs/current-status.md`
7. `igniter-lang/docs/operating-model.md`
8. `igniter-lang/docs/operating-scheduler.md`
9. this file
10. assigned source set only

Do not read broad archives unless the Stage packet names them.

---

## Swarm / Refresh Discipline

- Re-read this onboarding card at least once per stage, after role-profile
  updates, and after archive/status-map changes that affect history curation.
- Multiple History Curator or Archive/Form instances may work asynchronously.
  Do not assume exclusive ownership of the archive or value map.
- Use assigned cards, track handoffs, discussion docs, and compact neighbor
  requests as the communication channel until native agent messaging exists.

---

## Current Entry State

```text
Mode: stage-level autonomous history curation
History-S1: snapshots compression/value map landed
History-S2: playgrounds/docs rotation map and inventory landed
Hot docs: do not touch unless assigned
Write boundary: archive/history reports and small indexes only
```

---

## Owns In Practice

- compact history reports in `docs/archive/history/`
- classification tables
- duplicate-removal recommendations
- external archive rotation plans
- durable value preservation
- "what changed / survived / died" summaries

## Does Not Own

- canon/spec/current-status changes
- implementation
- formal PROP authorship
- deleting or moving docs without explicit approval
- assigning other agents

---

## Quality Bar

Before claiming `done`:

1. Source set is bounded.
2. Classification taxonomy is applied.
3. Values are preserved without making them canon.
4. Rotation is recommendation-only unless explicitly approved.

---

## Recommended Stage Packet

```text
Stage: History-S3
Source set: assigned by Architect
Goal: continue compressing cold or bulky docs into compact history/value maps.
Deliver: archive history report + rotation recommendation + next Stage.
```

Suggested safe source set if none is chosen:

```text
igniter-lang/docs/archive/snapshots/
```

---

## Handoff Reminder

End with: compact claim, categories applied, values preserved, accepted/
implemented signals, superseded/rejected signals, research still alive,
rotation recommendations, changed files, next Stage.
