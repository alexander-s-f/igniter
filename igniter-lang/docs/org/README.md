# Igniter-Lang Org Sidecar

Status: active sidecar
Owner: [Org Architect Supervisor]
Initialized by: [Architect Supervisor / Codex]
Date: 2026-05-17

---

## Purpose

This directory is the operating surface for the separate organization/process
sidecar.

It supports the main compiler/profile/runtime lane by maintaining compact
orientation maps, documentation hygiene reports, process insights, and
agent-memory experiments without becoming a source of language, compiler,
runtime, gate, proposal, or production authority.

The Portfolio layer now uses
[`portfolio-reporting-protocol-v0.md`](portfolio-reporting-protocol-v0.md) for
cross-lane reports between Igniter-Lang, Igniter Ruby Framework, and Spark CRM.
It uses [`portfolio-guidance-log-v0.md`](portfolio-guidance-log-v0.md) for
high-level directives, nudges, constraints, and questions to local supervisors.
It uses `portfolio-dispatches/` for copyable supervisor-level dispatch packets
that local supervisors can self-plan around.

The main Architect Supervisor remains responsible for active cards, protected
surface decisions, implementation authorization, and gate decisions.

---

## Boundaries

Allowed:

- compact org/process reports;
- documentation and experiment orientation maps;
- proposed schemas for agent operational-contract memory;
- drift/risk reports returned to the main Architect Supervisor;
- recommendations for future cards.

Not allowed without explicit Architect Supervisor approval:

- changing accepted language semantics;
- changing active gate/proposal/current-status authority;
- editing compiler/runtime implementation;
- moving, deleting, or archiving existing documents;
- taking over active compiler/profile/runtime cards.

---

## Expected Shape

```text
docs/org/
  README.md
  current-map.md
  reports/
  memory-contracts/
  indexes/
```

The first Org Architect Supervisor slice should create only the minimal missing
files needed for `S3-R62-C0-O`.

---

## Operating Rule

This surface is **memory and process support**, not authority.

Default flow:

```text
observe -> compact -> map -> recommend -> return only high-signal deltas
```

Return to the main Architect Supervisor only when a finding affects:

- active compiler/profile/runtime cards;
- authority drift or protected-surface risk;
- documentation bloat that blocks agents from using the current map;
- role/onboarding process health;
- a decision that needs explicit main-branch approval.

Everything else should stay here as compact org memory.

---

## Files

```text
README.md
  This operating contract.

current-map.md
  Compact path-indexed map of org/process, code, experiment, and docs surfaces.

reports/
  Compact stage-level reports and sidecar findings.

portfolio-dispatches/
  Supervisor-level dispatch packets from Portfolio to local lane supervisors.

portfolio-reporting-protocol-v0.md
  Cross-lane report packet protocol for Portfolio Architect Supervisor.

portfolio-guidance-log-v0.md
  Portfolio guidance channel checked by supervisors and lane owners.

memory-contracts/
  Draft schemas for operational-contract memory.

indexes/
  Optional small indexes that help future org slices avoid broad rereads.
```

---

## Relationship To Other Roles

- Architect Supervisor: owns authority, cards, gates, implementation decisions.
- History Curator: owns archive/history compression and movement recommendations.
- Archive/Form Expert: owns archaeology and canon-vs-history classification.
- Line Up Summarizer: owns compact per-document memory cards.
- Org Architect Supervisor: owns process memory, role operating memory, and
  cross-role documentation/orchestration hygiene.

The Org Architect Supervisor may recommend work for these roles, but must not
silently perform their authority-bearing tasks.
