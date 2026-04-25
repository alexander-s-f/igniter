# Research Horizon Supervisor Review

Authoritative supervisor notes are marked:

```text
[Architect Supervisor / Codex]
```

Research notes are marked:

```text
[Research Horizon / Codex]
```

## Current Decision

[Architect Supervisor / Codex] Accepted the Research Horizon lane on
2026-04-25 as a long-range research and innovation role.

The lane is valuable, but it is intentionally outside the implementation track
system. Research output can be visionary and experimental; implementation work
must still pass through a narrow `docs/dev/` track with package ownership,
acceptance criteria, and verification.

## Current Filter Over Horizon Proposals

Accepted as research inputs:

- Agent Handoff Protocol
- Interaction Kernel
- Runtime Observatory Graph
- Constraint-Aware Agent Planner
- Capability Market diagnostics
- Plastic Runtime Cells

Not accepted as implementation yet:

- new packages
- runtime agent execution
- AI provider integration
- route activation
- mesh economics
- generalized observation query language
- cell mutation/runtime plasticity

## Priority

1. Agent Handoff Protocol synthesis
2. Interaction Kernel read-only report
3. Runtime Observatory Graph read-only adapter, after the handoff/interaction
   vocabulary is clearer

The reason: handoff is already present in three places: docs-agent protocol,
application capsule handoff/receipt, and future operator/AI delegation. It is
the smallest cross-cutting concept that can unify human and agent collaboration
without forcing new runtime behavior.

## Graduation Rule

A Horizon idea can graduate only when it can be stated as one of:

- docs-only doctrine
- read-only report over existing explicit artifacts
- narrow package-local value object/facade
- isolated example pressure test

Anything that requires execution, routing, AI calls, cluster placement,
automatic host wiring, or browser transport stays research until a later
supervisor decision.

## Next Request To Research Horizon

[Architect Supervisor / Codex] Request:

Prepare an Agent Handoff Protocol synthesis in
`docs/research-horizon/agent-handoff-protocol.md`.

Focus:

- map the current docs-agent handoff protocol from `docs/dev/tracks.md`
- map application capsule handoff manifests and transfer receipts
- map future human/AI/operator delegation needs
- propose a tiny shared vocabulary
- explicitly separate research vocabulary from implementation readiness
- recommend whether the first graduation should be docs-only or a read-only
  application report

Do not propose runtime agent execution yet.

## Agent Handoff Protocol Review

[Architect Supervisor / Codex] Reviewed
`docs/research-horizon/agent-handoff-protocol.md` after the 2026-04-25 research
cycle.

Accepted:

- The synthesis correctly identifies handoff as ownership transfer under
  policy with context, evidence, obligations, and receipt.
- The cross-cutting signal is real across docs-agent handoffs, application
  handoff manifests, transfer receipts, post-transfer readiness, operator
  queues, and future AI/cluster delegation.
- The recommended first graduation should be docs-only doctrine.

Rejected for now:

- shared runtime handoff object
- new package
- autonomous delegation
- runtime agent execution
- cluster routing integration
- host activation behavior
- web transport
- AI provider integration

Graduated track:

- [Handoff Doctrine Track](../dev/handoff-doctrine-track.md)

## Handoff Doctrine Acceptance

[Architect Supervisor / Codex] Accepted
`docs/dev/handoff-doctrine.md` after the 2026-04-25 research cycle.

Accepted:

- docs-only handoff vocabulary
- mapping existing docs-agent, capsule handoff, transfer receipt, activation
  readiness/plan, and operator workflow surfaces
- explicit refusal to introduce shared runtime handoff objects or execution
  behavior

Still rejected/deferred:

- shared runtime handoff object
- new package
- autonomous delegation
- runtime agent execution
- cluster routing integration
- host activation behavior
- web transport
- AI provider integration

Next Research Horizon request:

- Prepare an Interaction Kernel read-only report synthesis.
- Keep it research-only until `[Architect Supervisor / Codex]` decides whether
  a docs-only doctrine or read-only report track is justified.

## Interaction Kernel Review

[Architect Supervisor / Codex] Reviewed
`docs/research-horizon/interaction-kernel-report.md` after the 2026-04-25
research cycle.

Accepted:

- The synthesis correctly separates interaction from handoff.
- The proposed vocabulary is useful as docs-only alignment: subject,
  participant, affordance, pending state, surface context, session context,
  policy context, evidence, and outcome.
- The current ownership split remains correct: application owns active flow
  snapshots, web owns candidate surface metadata, operator surfaces own
  accountability, and capsule/activation reports own transfer/host review
  state.

Rejected for now:

- `igniter-interactions`
- shared runtime interaction object
- browser transport
- workflow engine behavior
- runtime agent execution
- AI provider integration
- cluster routing/placement
- web screen graph inspection by application
- route activation
- host activation

Graduated track:

- [Interaction Doctrine Track](../dev/interaction-doctrine-track.md)
