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
- [Stacks](./stacks.md)
- [Cluster State](./cluster-state.md)
- [Cluster Roadmap](./cluster-roadmap.md)

## Current Reading Heuristic

- Read `Contracts And Agents` first for the current doctrine: `contract` is fundamental, `agent` is first-class.
- Read `Agent Node` for the concrete runtime shape: sessions, stream events, orchestration, and operator surfaces.
- Read `Agents Roadmap` for the real next-cycle options rather than older speculative notes.
- Treat the agent query/operator work as active.
- Treat the cluster `MeshQL` line as separate and low-priority for now; the naming cleanup is intentionally deferred and should not drive the current agents roadmap.

## Related Sections

- [Guide](../guide/README.md) for current user-facing guidance
- [Dev](../dev/README.md) for package boundaries and internal rules
