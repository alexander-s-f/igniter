# Igniter Current

Use this section for active current-state and next-state notes that are useful
while the architecture is still evolving.

## What Belongs Here

- current direction for stack and cluster shape
- near-term state snapshots
- active roadmap notes that are still concrete enough to guide work

## Current Docs

- [Contracts And Agents](./contracts-and-agents.md)
- [Agents](./agents.md)
- [Agent Node](./agent-node.md)
- [Agents Roadmap](./agents-roadmap.md)
- [App Structure](./app-structure.md)
- [Ignite](./ignite.md)
- [Stacks](./stacks.md)
- [Cluster State](./cluster-state.md)
- [Cluster Roadmap](./cluster-roadmap.md)

## Current Snapshot

The current Igniter shape is now centered around three connected lines:

- `contracts & agents` are no longer only runtime primitives; they now extend up into app orchestration, operator query/action surfaces, audit history, and mounted operator UI/API
- app/stack structure is now oriented around pluggable apps, explicit `access_to`, minimal stack configuration, and `igniter-frontend` as the default web authoring path
- `ignite` is no longer only a bootstrap idea; it now has value objects, an agent-owned execution/reporting surface, admission/bootstrap/join lifecycle, durable trail/history, and operator visibility/actions

That means the current platform is past the “make the concepts real” phase.
The active work is now about convergence and hardening:

- converge operator semantics across orchestration and ignition
- deepen remote/routed execution beyond one process
- keep moving stack/app structure and deployment bootstrap toward one coherent model

## Current Reading Heuristic

- Read `Contracts And Agents` first for the current doctrine: `contract` is fundamental, `agent` is first-class.
- Read `App Structure` when you are touching stack/app layout, generators, or frontend authoring shape.
- Read `Stacks` when you are touching the one-connection-point rule, mounting, stack config, node meaning, or local multi-node harness shape.
- Read `Ignite` when you are thinking about cluster bootstrap, deployment agents, or seed-to-peer bring-up.
- Read `Ignite` for the current bootstrap specification: `BootstrapTarget`, `DeploymentIntent`, `IgnitionPlan`, approval, and local-first ignition flow.
- Read `Agent Node` for the concrete runtime shape: sessions, stream events, orchestration, and operator surfaces.
- Read `Agents Roadmap` for the real next-cycle options rather than older speculative notes.
- Treat the agent/operator and ignite/operator convergence work as active.
- Treat the cluster `MeshQL` line as separate and low-priority for now; the naming cleanup is intentionally deferred and should not drive the current agents roadmap.

## Related Sections

- [Guide](../guide/README.md) for current user-facing guidance
- [Dev](../dev/README.md) for package boundaries and internal rules
