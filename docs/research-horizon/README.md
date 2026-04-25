# Research Horizon

This directory is a research area for Igniter's long-range architecture work.

It is intentionally separate from guide and implementation-track documents. Use
it for bold proposals, system-level analysis, agent handoff drafts, future
runtime models, distributed-computing research, and Human <-> AI Agent interface
directions that may later graduate into `docs/dev/` tracks.

Current research posture:

- think beyond the immediate gem surface without losing contact with the code
- separate observation, proposal, and implementation readiness
- prefer concrete architectural moves over vague futurism
- treat agents, contracts, app capsules, clusters, mesh, and AI interfaces as
  one evolving system
- mark ideas that need `[Architect Supervisor / Codex]` review before they
  become implementation tracks

## Role

`[Research Horizon / Codex]` owns this directory as a long-range research and
innovation lane.

It may:

- write current-state reports
- draft bold proposals
- compare architectural futures
- connect contracts, capsules, web, cluster, agents, AI, and human interfaces
- ask `[Architect Supervisor / Codex]` to review a proposal for graduation

It may not:

- start implementation work directly
- change package code
- create `docs/dev/` implementation tracks without supervisor acceptance
- override active package-agent handoffs

## Supervisor Gate

`[Architect Supervisor / Codex]` filters research output before it affects the
active roadmap.

The filter is:

- What is the smallest concrete move?
- Which package/layer owns it?
- Is it docs-only, read-only reporting, or actual runtime behavior?
- What can be rejected or deferred?
- What verification would make it safe?

Research graduates only when supervisor notes create or update a `docs/dev/`
track with scoped tasks and acceptance criteria.

## Research Artifacts

- [Current State Report](./current-state-report.md)
- [Horizon Proposals](./horizon-proposals.md)
- [Supervisor Review](./supervisor-review.md)
- [Agent Handoff Protocol](./agent-handoff-protocol.md)
- [Interaction Kernel Report](./interaction-kernel-report.md)
- [Grammar-Compressed Interaction](./grammar-compressed-interaction.md)
- [Grammar Compression Research Survey](./grammar-compression-research-survey.md)
- [Line-Up Approximation Method](./line-up-approximation-method.md)
- [DSL And REPL-Like Authoring Research](./dsl-repl-authoring-research.md)
- [Insight Scout Log](./insight-scout-log.md)

## Compact Handoff

Use this format when asking for review:

```text
[Research Horizon / Codex]
Track: docs/research-horizon/<file>.md
Status: research / proposal / needs supervisor filter
Changed:
- <files>
Core idea:
- <one to three bullets>
Recommended graduation:
- <none / docs-only / read-only report / package track>
Risks:
- <main risks>
Needs:
- [Architect Supervisor / Codex] accept / reject / defer / narrow
```
