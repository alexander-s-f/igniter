# Active Tracks Index

This is the first file agents should read when they need current architecture
state, ownership, or next tasks.

The goal is context efficiency:

- read this index first
- drill down only into your active track and direct cross-agent dependencies
- report back compactly with changed files, accepted items, blockers, and next
  requested handoff

Authoritative supervisor notes are marked:

```text
[Architect Supervisor / Codex]
```

Package agents should keep reporting with their role labels:

```text
[Agent Contracts / Codex]
[Agent Embed / Codex]
[Agent Application / Codex]
[Agent Web / Codex]
[Agent Cluster / Codex]
```

## Agent Drill-Down Protocol

1. Read this file.
2. Find your agent role in **Active Handoffs**.
3. Read only the linked track document and any explicitly named dependency
   document.
4. Do the task.
5. Append a short labeled handoff note to the track you changed.
6. Return a compact status:

```text
[Agent X / Codex]
Track: <track name>
Changed: <files or docs>
Accepted/Ready: <yes/no + why>
Verification: <commands and result>
Needs: <next agent or supervisor decision>
```

Do not paste long summaries of unrelated tracks. If a track references private
pressure-test material, mention only the public conclusion unless the current
task explicitly requires private details.

## Active Handoffs

| Agent | Current Task | Start Here | Dependencies | Return To |
| --- | --- | --- | --- | --- |
| `[Agent Embed / Codex]` | Host discovery and reload boundary for embed hosts | [Embed Contract Class Integration Track](./embed-contract-class-integration-track.md) | [Embed Target Plan](./embed-target-plan.md), [Contract Class DSL Guide](../guide/contract-class-dsl.md) | `[Architect Supervisor / Codex]`; then `[Agent Contracts / Codex]` if the boundary changes fail-fast needs |
| `[Agent Contracts / Codex]` | Step result / fail-fast ergonomics proposal, design only | [Embed Contract Class Integration Track](./embed-contract-class-integration-track.md) | [Igniter Contracts Spec](./igniter-contracts-spec.md), private pressure-test notes if provided by supervisor | `[Architect Supervisor / Codex]` |
| `[Agent Application / Codex]` | Deferred: prove Application can consume `Class < Igniter::Contract` without Embed | [Embed Contract Class Integration Track](./embed-contract-class-integration-track.md) | [Application Target Plan](./application-target-plan.md), [Embed Target Plan](./embed-target-plan.md) | `[Architect Supervisor / Codex]` after Tasks 1-3 clarify shape |
| `[Agent Application / Codex]` | Agent-native resume/status/pending-state policy | [Agent-Native Interaction Session Track](./agent-native-interaction-session-track.md) | [Application/Web Integration Tasks](./application-web-integration-tasks.md) | `[Agent Web / Codex]` if web rendering/adapter state is affected |
| `[Agent Web / Codex]` | Web/application integration maintenance and web-owned interaction adapters | [Application/Web Integration Tasks](./application-web-integration-tasks.md) | [Agent-Native Interaction Session Track](./agent-native-interaction-session-track.md), [Igniter Web Target Plan](./igniter-web-target-plan.md) | `[Agent Application / Codex]` for application-owned API needs |

## Track Map

### Embed And Contract Class DSL

Status: active.

Primary track:

- [Embed Contract Class Integration Track](./embed-contract-class-integration-track.md)

Public user-facing guide:

- [Contract Class DSL](../guide/contract-class-dsl.md)

Current accepted state:

- `igniter-contracts` owns `Igniter::Contract`.
- `igniter-embed` consumes class contracts.
- `igniter-embed` supports host-level `config.contract SomeContract, as: :name`.
- `Container#register(Class < Igniter::Contract)` can infer a stable name from
  named contract classes and rejects anonymous classes without `as:`.
- Public examples exist under `examples/contracts/class_*.rb`.

Next:

- `[Agent Embed / Codex]`: define host discovery/reload semantics around
  `config.root`, optional discovery, and cache clearing.
- `[Agent Contracts / Codex]`: draft fail-fast/step-result ergonomics as a
  proposal only; do not broadly implement until reviewed.

Private pressure tests:

- App-specific Rails/SparkCRM notes live outside this public track. Use only
  when explicitly directed by supervisor or user.

### Application/Web Integration

Status: mostly landed; maintenance and follow-up active.

Primary tracks:

- [Application/Web Integration Tasks](./application-web-integration-tasks.md)
- [Application And Web Integration](./application-web-integration.md)

Current accepted state:

- Application owns layout, manifest, mounts, sessions, and flow snapshots.
- Web owns mounts, surface structure, surface manifests, interaction targets,
  and web-to-application pending-state adapter.

Next:

- Continue narrow handoffs. Do not move web screen knowledge into
  `igniter-application`.

### Agent-Native Interaction Sessions

Status: active.

Primary track:

- [Agent-Native Interaction Session Track](./agent-native-interaction-session-track.md)

Related proposal:

- [Agent-Native Application Track Proposal](./agent-native-application-track-proposal.md)

Current accepted state:

- Application-owned flow session snapshots and events landed.
- Web-owned interaction metadata and adapter landed.
- Read model/adapter boundary accepted.

Next:

- Define explicit resume/status/pending-state update semantics without building
  a hidden flow state machine, browser transport, or real agent runtime.

### Application Structure And Capsules

Status: landed first pass; design follow-up.

Primary track:

- [Application Structure Research](./application-structure-research.md)

Current accepted state:

- App capsule is the portability boundary.
- Web is an optional surface inside the app capsule.
- Layout profiles, sparse structure plans, exports/imports, and web surface
  structure/manifest are landed.

Next:

- Feature-slice reporting and possible user-facing current docs update.

### Cluster

Status: target planning.

Primary track:

- [Cluster Target Plan](./cluster-target-plan.md)

Dependencies:

- [Application Target Plan](./application-target-plan.md)
- [Embed Target Plan](./embed-target-plan.md)

Next:

- Keep cluster above Embed/Application. Do not pull distributed semantics into
  embedded contracts or local application host layers.

## Public Vs Private Track Rule

Public docs in `docs/dev/` should contain:

- package ownership
- architecture decisions
- generic tasks and acceptance
- cross-agent handoffs
- verification commands/results

Private pressure-test docs should contain:

- private app names and business logic
- concrete model/query/response details
- rollout notes for a private app
- evidence used to inform public design

When private evidence changes a public architecture decision, summarize the
generic conclusion in the public track and keep private specifics private.

## Compact Status Template

Use this when reporting after a cycle:

```text
[Agent Role / Codex]
Track: <public track path>
Status: <landed / needs review / blocked>
Changed:
- <path>
Verification:
- <command> => <result>
Accepted:
- <what is ready for next agent>
Needs:
- <next handoff or supervisor decision>
```

Keep the report short. Link files instead of copying code.
